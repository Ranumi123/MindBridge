require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { GoogleGenerativeAI } = require("@google/generative-ai");
const tf = require('@tensorflow/tfjs');
const toxicity = require('@tensorflow-models/toxicity');
const fs = require('fs').promises;
const path = require('path');
const { ObjectId } = require('mongodb');

// Import MongoDB connections
const { connectToMongoDB, getDB } = require('./db');
const connectFeedDB = require("./config/feed-db");

// Import models
const { findUserById } = require('./models/user');

// Import routes
const feedRoutes = require("./routes/feed-page-routes");
// Import authentication routes
const authRoutes = require("./routes/authRoutes"); 
// Import user routes for profile functionality
const userRoutes = require("./routes/profileRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
// Add URL-encoded parser for form submissions
app.use(express.urlencoded({ extended: true }));

// Google Generative AI Setup
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

// Path to the suicidal dataset
const datasetPath = path.join(__dirname, 'datasets', 'Suicide_Ideation_Dataset(Twitter-based).csv');

// In-memory storage for processed dataset
let suicideDataset = [];
let suicidalPatterns = [];
let initialized = false;

// Load and process suicide dataset
async function loadSuicideDataset() {
  if (initialized) {
    return true;
  }
  
  try {
    // Check if the file exists
    if (!await fileExists(datasetPath)) {
      console.warn("Dataset file not found at:", datasetPath);
      console.warn("Continuing without suicide dataset...");
      initialized = true;
      return false;
    }

    const data = await fs.readFile(datasetPath, 'utf8');
    const lines = data.split('\n');
    
    // Process header and data
    const [header, ...records] = lines;
    const [tweetIndex, suicideIndex] = getColumnIndexes(header);
    
    if (tweetIndex === -1 || suicideIndex === -1) {
      console.error("Dataset does not contain required columns (Tweet, Suicide)");
      return false;
    }

    suicideDataset = parseDataset(records, tweetIndex, suicideIndex);
    
    // Extract patterns after loading dataset
    extractSuicidePatterns();
    initialized = true;
    console.log(`Loaded ${suicideDataset.length} records from suicide dataset`);
    return true;
  } catch (error) {
    console.error("Error loading suicide dataset:", error);
    console.warn("Continuing without suicide dataset...");
    initialized = true;
    return false;
  }
}

// Helper functions
async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

function getColumnIndexes(header) {
  const headerColumns = header.split(',');
  const tweetIndex = headerColumns.findIndex(col => col.trim().toLowerCase() === 'tweet');
  const suicideIndex = headerColumns.findIndex(col => col.trim().toLowerCase() === 'suicide');
  return [tweetIndex, suicideIndex];
}

function parseDataset(records, tweetIndex, suicideIndex) {
  return records
    .filter(record => record.trim())
    .map(record => {
      const columns = record.split(',');
      return { Tweet: columns[tweetIndex]?.trim() || '', Suicide: columns[suicideIndex]?.trim() || '' };
    });
}

// Extract suicide keywords and patterns from the dataset
function extractSuicidePatterns() {
  const baseIndicators = [
    "kill myself", "suicide", "end my life", "want to die", 
    "tired of living", "don't want to be here", "end it all",
    "put myself to rest", "roll over and die", "hate my life",
    "life is miserable", "hope i die"
  ];
  
  suicidalPatterns = [...baseIndicators];

  if (suicideDataset && suicideDataset.length > 0) {
    suicideDataset.forEach(item => {
      if (item.Suicide.toLowerCase().includes("suicide") || item.Suicide.toLowerCase().includes("potential")) {
        baseIndicators.forEach(indicator => {
          if (item.Tweet.toLowerCase().includes(indicator) && !suicidalPatterns.includes(indicator)) {
            suicidalPatterns.push(indicator);
          }
        });
      }
    });
  }

  console.log(`Using ${suicidalPatterns.length} suicide patterns for detection`);
}

// Detect harmful content
async function detectHarmfulText(text) {
  const suicidalCheck = detectSuicidalContent(text);
  if (suicidalCheck.isSuicidal) {
    return { harmful: true, type: 'suicidal', details: suicidalCheck };
  }

  try {
    const toxicityModel = await toxicity.load(0.8);
    const predictions = await toxicityModel.classify([text]);
    
    for (const prediction of predictions) {
      if (prediction.results[0].match) {
        return { harmful: true, type: 'toxicity', category: prediction.label };
      }
    }
  } catch (error) {
    console.error("Error with toxicity model:", error);
  }

  return { harmful: false };
}

// Detect suicidal content in text
function detectSuicidalContent(text) {
  if (!text) return { isSuicidal: false };
  
  const textLower = text.toLowerCase();
  
  for (const phrase of suicidalPatterns) {
    if (textLower.includes(phrase)) {
      return { isSuicidal: true, matchedPhrase: phrase };
    }
  }

  const suicidePatterns = [
    /i (?:want|need|wish) to d[ie]{2}/i,
    /(?:kill(?:ing)? myself|end(?:ing)? (?:my life|it all))/i,
    /(?:don'?t|do not) want to (?:live|be here|exist)/i,
    /(?:hate|tired of) (?:my )?life/i,
    /(?:put (?:myself|me) to rest)/i,
    /(?:no reason to (?:live|be here|continue))/i
  ];

  for (const pattern of suicidePatterns) {
    if (pattern.test(textLower)) {
      return { isSuicidal: true, matchedPattern: pattern.toString() };
    }
  }

  return { isSuicidal: false };
}

// Response functions
function getSuicidalResponse() {
  const responses = [
    "I notice you're expressing thoughts about harming yourself. Please know that help is available. Would you like me to provide crisis resources?",
    "I'm concerned about what you've shared. If you're feeling suicidal, please talk to someone right away. The National Suicide Prevention Lifeline is available 24/7 at 988 or 1-800-273-8255.",
    "It sounds like you're going through a difficult time. Your life matters, and there are people who want to help. Would you like information about crisis support services?"
  ];
  return responses[Math.floor(Math.random() * responses.length)];
}

// UPDATED: Enhanced MongoDB-integrated functions for emergency contacts
async function getEmergencyContacts(userId) {
  try {
    // Convert string ID to ObjectId if necessary
    const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
    
    const db = getDB();
    const user = await db.collection('users').findOne({ _id: id });
    
    // Check for emergency contacts array from updated schema
    if (user && user.emergencyContacts && user.emergencyContacts.length > 0) {
      // Filter out any incomplete or invalid contacts
      const validContacts = user.emergencyContacts.filter(contact => 
        contact && contact.phone && contact.phone.trim() !== ''
      );
      
      if (validContacts.length > 0) {
        return validContacts;
      }
    }
    
    // Check phone in profile as fallback (if we have a name)
    if (user && user.profile && user.profile.phone && user.name) {
      return [{
        name: `${user.name} (Self)`,
        phone: user.profile.phone,
        relationship: "Self",
        isPrimary: true
      }];
    }
    
    // Default emergency services if no contacts found
    return [
      { 
        name: "National Crisis Hotline", 
        phone: "988",
        relationship: "Crisis Service",
        isPrimary: true
      },
      { 
        name: "Crisis Text Line", 
        phone: "741741",
        relationship: "Crisis Service",
        isPrimary: false
      },
      {
        name: "National Suicide Prevention Lifeline",
        phone: "1-800-273-8255",
        relationship: "Crisis Service",
        isPrimary: false
      }
    ];
  } catch (error) {
    console.error("Error getting emergency contacts:", error);
    // Log the specific error for debugging
    console.error("Error details:", error.message);
    
    // Return default emergency services in case of error
    return [
      { 
        name: "National Crisis Hotline", 
        phone: "988",
        relationship: "Crisis Service", 
        isPrimary: true
      },
      { 
        name: "Crisis Text Line", 
        phone: "741741",
        relationship: "Crisis Service",
        isPrimary: false
      }
    ];
  }
}

// UPDATED: Enhanced notifyEmergencyContacts function
async function notifyEmergencyContacts(userId) {
  try {
    const emergencyContacts = await getEmergencyContacts(userId);
    
    // Get user info for the message
    let userName = "A user";
    try {
      // Convert string ID to ObjectId if necessary
      const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
      
      const user = await findUserById(id);
      if (user && user.name) {
        userName = user.name;
      }
    } catch (userError) {
      console.error("Error getting user details for notification:", userError);
    }
    
    // Store crisis event in MongoDB
    try {
      const db = getDB();
      
      await db.collection('crisisEvents').insertOne({
        userId,
        userName: userName,
        timestamp: new Date(),
        contactsNotified: emergencyContacts,
        status: 'notified'
      });
      
      console.log(`Crisis event logged for user: ${userId}`);
    } catch (dbError) {
      console.error("Error logging crisis event:", dbError);
    }
    
    // Attempt to notify each contact
    let notificationResults = [];
    
    for (const contact of emergencyContacts) {
      try {
        // Send the actual notification
        const result = await sendSMS(contact.phone, 
          `URGENT: ${userName} may need immediate help. This is an automated alert from MindBridge. Please check on them right away.`
        );
        
        notificationResults.push({
          contact: contact.name,
          phone: contact.phone,
          success: true,
          timestamp: new Date()
        });
        
        console.log(`Crisis notification sent to ${contact.name} at ${contact.phone}`);
      } catch (smsError) {
        console.error(`Failed to notify contact ${contact.name}:`, smsError);
        
        notificationResults.push({
          contact: contact.name,
          phone: contact.phone,
          success: false,
          error: smsError.message,
          timestamp: new Date()
        });
      }
    }
    
    // Update the crisis event with notification results
    try {
      const db = getDB();
      
      await db.collection('crisisEvents').updateOne(
        { userId, status: 'notified' },
        { 
          $set: { 
            notificationResults,
            status: notificationResults.some(r => r.success) ? 'contact_reached' : 'notification_failed'
          }
        }
      );
    } catch (updateError) {
      console.error("Error updating crisis event with notification results:", updateError);
    }
    
    return {
      notified: notificationResults.filter(r => r.success).length,
      failed: notificationResults.filter(r => !r.success).length,
      contacts: notificationResults
    };
  } catch (error) {
    console.error("Error in notifyEmergencyContacts:", error);
    return { notified: 0, failed: 0, error: error.message };
  }
}

// UPDATED: Enhanced SMS sending function
async function sendSMS(phone, message) {
  // This is a placeholder function - replace with your actual SMS provider integration
  console.log(`[SMS WOULD BE SENT] To: ${phone}, Message: ${message}`);
  
  // For development/testing, just return success
  return {
    success: true,
    messageId: `msg_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
    timestamp: new Date()
  };
  
  // When implementing with a real SMS provider, uncomment and modify:
  /*
  // Example with Twilio:
  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;
  const client = require('twilio')(accountSid, authToken);
  
  const result = await client.messages.create({
    body: message,
    from: process.env.TWILIO_PHONE_NUMBER,
    to: phone
  });
  
  return {
    success: true,
    messageId: result.sid,
    timestamp: new Date()
  };
  */
}

// Store chat message in MongoDB
async function storeChatMessage(userId, message, reply, status) {
  try {
    const db = getDB();
    
    await db.collection('chatHistory').insertOne({
      userId,
      message,
      reply,
      status,
      timestamp: new Date()
    });
  } catch (error) {
    console.error("Error storing chat message:", error);
  }
}

// Routes
app.use("/api/feed", feedRoutes); // Feed routes
app.use("/api/auth", authRoutes); // Auth routes
app.use("/api/users", userRoutes); // User profile 
// app.use("/api/profile", profileRoutes); // Profile routes

// Health check route
app.get("/", (req, res) => {
  res.send("MindBridge Server with Feed, Auth, and User Profile functionality is running!");
});

// AI Chat route (no authentication)
app.post('/chat', async (req, res) => {
  try {
    const { message, userId } = req.body;

    if (!message) {
      return res.status(400).json({ error: "Message is required" });
    }

    const sanitizedMessage = message.trim();

    if (sanitizedMessage.length < 5) {
      return res.json({ reply: "I need a bit more information to help you. Could you please elaborate?", status: "normal" });
    }

    const commonPhrases = ['hello', 'good morning', 'how are you', 'test', 'thanks', 'bye'];
    if (commonPhrases.some(phrase => sanitizedMessage.toLowerCase().includes(phrase))) {
      const reply = "Thank you for reaching out! How can I assist you today?";
      await storeChatMessage(userId, sanitizedMessage, reply, "normal");
      return res.json({ reply, status: "normal" });
    }

    const { harmful, type, details } = await detectHarmfulText(sanitizedMessage);
    
    if (harmful) {
      if (type === 'suicidal') {
        console.log(`Suicidal content detected: "${sanitizedMessage}"`);
        console.log(`Matched with: ${JSON.stringify(details)}`);
        
        await notifyEmergencyContacts(userId);
        
        const reply = getSuicidalResponse();
        await storeChatMessage(userId, sanitizedMessage, reply, "crisis");
        
        return res.status(200).json({ 
          reply,
          status: "crisis",
          resources: {
            hotline: "988 or 1-800-273-8255",
            text: "Text HOME to 741741",
            chat: "https://suicidepreventionlifeline.org/chat/"
          }
        });
      } else {
        const reply = "I'm not able to respond to that type of content. How can I help you with something else?";
        await storeChatMessage(userId, sanitizedMessage, reply, "inappropriate");
        
        return res.status(200).json({ 
          reply,
          status: "inappropriate"
        });
      }
    }

    const result = await model.generateContent(sanitizedMessage);
    const response = await result.response;
    const text = response.candidates[0]?.content?.parts[0]?.text || "I'm sorry, I couldn't generate a response. How else can I help you?";

    await storeChatMessage(userId, sanitizedMessage, text, "normal");
    
    res.json({ reply: text, status: "normal" });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Something went wrong with processing your message. Please try again.", status: "error" });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: "Something went wrong!",
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Initialize MongoDB connections and the dataset when server starts
(async function() {
  try {
    // Connect to both MongoDB databases
    await connectToMongoDB(); // Main MindBridge DB
    await connectFeedDB();    // Feed DB
    console.log("MongoDB connections established");
    
    // Then load the dataset
    await loadSuicideDataset();
  } catch (error) {
    console.error("Initialization error:", error);
    process.exit(1);
  }
})();

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`Integrated MindBridge server running on http://localhost:${PORT}`);
});