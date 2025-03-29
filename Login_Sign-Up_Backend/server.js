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
const mongoose = require('mongoose');
const http = require('http');
const socketIo = require('socket.io');

// Import MongoDB connections
const { connectToMongoDB, getDB, connectWithMongoose, checkDatabase } = require('./db');
const connectFeedDB = require("./config/feed-db");

// Import models
const { findUserById } = require('./models/user');

// Import routes
const feedRoutes = require("./routes/feed-page-routes");
const authRoutes = require("./routes/authRoutes"); 
const userRoutes = require("./routes/profileRoutes");
const moodRoutes = require("./routes/moodRoutes");
const therapistRoutes = require('./routes/therapistRoutes');
const appointmentRoutes = require('./routes/appointmentRoutes');

// Import community chat routes
const chatGroupRoutes = require('./routes/chatGroupRoutes');
const chatMessageRoutes = require('./routes/chatMessageRoutes');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE']
  }
});

// Middleware
app.use(cors({
  origin: '*', // Allow all origins or specify your frontend domain
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(bodyParser.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Make io available to routes
app.set('io', io);

// Google Generative AI Setup
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

// Path to the suicidal dataset
const datasetPath = path.join(__dirname, 'datasets', 'Suicide_Ideation_Dataset(Twitter-based).csv');

// In-memory storage for processed dataset
let suicideDataset = [];
let suicidalPatterns = [];
let initialized = false;

// In-memory store for moods when the database is not available
const moodEntriesStore = [];

// Socket.io setup for real-time chat
io.on('connection', (socket) => {
  console.log('New client connected', socket.id);
  
  // Handle joining a chat group
  socket.on('joinGroup', (groupId) => {
    socket.join(groupId);
    console.log(`Client joined chat group: ${groupId}`);
  });
  
  // Handle leaving a chat group
  socket.on('leaveGroup', (groupId) => {
    socket.leave(groupId);
    console.log(`Client left chat group: ${groupId}`);
  });
  
  // Handle new messages
  socket.on('newMessage', async (messageData) => {
    try {
      const db = getDB();
      
      // Check for toxic content
      const ToxicWordsFilter = require('./middleware/toxicFilter');
      const toxicCheck = ToxicWordsFilter.containsToxicWord(messageData.message);
      
      if (toxicCheck.containsToxicWord) {
        socket.emit('messageError', { 
          error: 'Your message contains inappropriate language',
          toxicWord: toxicCheck.toxicWord
        });
        return;
      }
      
      // Store message in database
      const message = {
        groupId: messageData.groupId,
        message: messageData.message,
        sender: messageData.sender,
        isAnonymous: messageData.isAnonymous || false,
        timestamp: new Date(),
        isMe: false, // This will be set to true by the client for their own messages
      };
      
      const result = await db.collection('chatMessages').insertOne(message);
      
      // Get the inserted message with ID
      const insertedMessage = {
        ...message,
        _id: result.insertedId
      };
      
      // Broadcast message to all clients in the group
      io.to(messageData.groupId).emit('receiveMessage', insertedMessage);
      
      console.log(`Message sent to group ${messageData.groupId}`);
    } catch (error) {
      console.error("Error handling new message:", error);
      socket.emit('messageError', { error: 'Failed to send message' });
    }
  });
  
  // Handle typing events
  socket.on('typing', (data) => {
    socket.to(data.groupId).emit('userTyping', {
      userId: data.userId,
      groupId: data.groupId,
      isTyping: data.isTyping
    });
  });
  
  // Handle disconnection
  socket.on('disconnect', () => {
    console.log('Client disconnected', socket.id);
  });
});

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

// Enhanced MongoDB-integrated functions for emergency contacts
async function getEmergencyContacts(userId) {
  try {
    // Check if userId is in the consistent ID format
    if (userId && typeof userId === 'string' && userId.startsWith('user_')) {
      const db = getDB();
      const user = await db.collection('users').findOne({ userId });
      
      if (user && user.emergencyContacts && user.emergencyContacts.length > 0) {
        return user.emergencyContacts.filter(contact => 
          contact && contact.phone && contact.phone.trim() !== ''
        );
      }
    } else {
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

// Enhanced notifyEmergencyContacts function
async function notifyEmergencyContacts(userId) {
  try {
    const emergencyContacts = await getEmergencyContacts(userId);
    
    // Get user info for the message
    let userName = "A user";
    try {
      let user;
      
      // Check if userId is in the consistent ID format
      if (userId && typeof userId === 'string' && userId.startsWith('user_')) {
        const db = getDB();
        user = await db.collection('users').findOne({ userId });
      } else {
        // Convert string ID to ObjectId if necessary
        const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
        user = await findUserById(id);
      }
      
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

// Enhanced SMS sending function
async function sendSMS(phone, message) {
  // This is a placeholder function - replace with your actual SMS provider integration
  console.log(`[SMS WOULD BE SENT] To: ${phone}, Message: ${message}`);
  
  // For development/testing, just return success
  return {
    success: true,
    messageId: `msg_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
    timestamp: new Date()
  };
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

// Register routes
// First, verify each route before registering
console.log('Setting up routes...');

// Check if our route files export valid Express routers
if (typeof feedRoutes === 'function') {
  app.use("/api/feed", feedRoutes);
  console.log('Feed routes registered');
} else {
  console.error('Warning: feedRoutes is not a valid Express router');
}

if (typeof authRoutes === 'function') {
  app.use("/api/auth", authRoutes);
  console.log('Auth routes registered');
} else {
  console.error('Warning: authRoutes is not a valid Express router');
}

if (typeof userRoutes === 'function') {
  app.use("/api/users", userRoutes);
  console.log('User/profile routes registered');
} else {
  console.error('Warning: userRoutes is not a valid Express router');
}

if (typeof moodRoutes === 'function') {
  app.use("/api/moods", moodRoutes);
  console.log('Mood tracker routes registered');
} else {
  console.error('Warning: moodRoutes is not a valid Express router');
}

// Add therapy appointment routes
if (typeof therapistRoutes === 'function') {
  app.use('/api/therapists', therapistRoutes);
  console.log('Therapist routes registered');
} else {
  console.error('Warning: therapistRoutes is not a valid Express router');
}

if (typeof appointmentRoutes === 'function') {
  app.use('/api/appointments', appointmentRoutes);
  console.log('Appointment routes registered');
} else {
  console.error('Warning: appointmentRoutes is not a valid Express router');
}

// Add community chat routes
app.use('/api/chat/groups', chatGroupRoutes);
console.log('Chat group routes registered');

app.use('/api/chat/messages', chatMessageRoutes);
console.log('Chat message routes registered');

// Health check route
app.get("/", (req, res) => {
  res.send("MindBridge Server with Feed, Auth, Profile, Mood Tracker, Therapy Appointment, and Community Chat functionality is running!");
});

// Health check route with DB status
app.get("/health", async (req, res) => {
  try {
    // Get database connection status
    const dbStatus = await checkDatabase();
    
    // Check mood database connection
    let moodDbConnected = false;
    try {
      const { isMoodDBConnected } = require('./config/mood-db');
      moodDbConnected = isMoodDBConnected();
    } catch (err) {
      console.warn('Could not check mood DB connection:', err.message);
    }
    
    res.status(200).json({ 
      status: 'UP', 
      services: {
        main: 'running',
        database: dbStatus ? 'connected' : 'disconnected',
        feedAPI: 'running',
        authAPI: 'running',
        userAPI: 'running',
        moodTrackerAPI: moodDbConnected ? 'running' : 'limited',
        therapistAPI: 'running',
        appointmentAPI: 'running',
        communityChat: 'running' // Added community chat status
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
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
// Global variable to track mood database connection state
let moodDbConnected = false;

(async function() {
  try {
    console.log('Starting server initialization...');
    
    // 1. Connect to main MindBridge DB
    await connectToMongoDB();
    console.log('Main database connected successfully');
    
    // 2. Connect to Feed DB
    try {
      await connectFeedDB();
      console.log('Feed database connected successfully');
    } catch (feedDbError) {
      console.error('Failed to connect to feed database:', feedDbError.message);
      console.warn('Server will start with limited feed functionality');
    }
    
    // 3. Connect to Mongoose for ORM operations
    try {
      await connectWithMongoose();
      console.log('Mongoose connected successfully');
    } catch (mongooseError) {
      console.error('Failed to connect with Mongoose:', mongooseError.message);
      console.warn('Server will start with limited ORM functionality');
    }
    
    // 4. Connect to Mood Tracker DB
    try {
      const { connectMoodDB } = require('./config/mood-db');
      await connectMoodDB();
      moodDbConnected = true;
      console.log('Mood tracker database connected successfully');
      
      // Verify connectivity by testing the Mood model
      const Mood = require('./models/mood-model');
      if (typeof Mood.verifyConnection === 'function') {
        const isConnected = await Mood.verifyConnection();
        
        if (isConnected) {
          console.log('Mood model connection verified successfully');
        } else {
          console.error('Mood model connection verification failed');
          console.warn('Server will continue but mood tracker functionality may be limited');
        }
      } else {
        // If verifyConnection method is not available, try a simpler check
        console.log('Verifying Mood model with basic check...');
        try {
          const count = await Mood.countDocuments({});
          console.log(`Found ${count} mood documents in database`);
          console.log('Mood model basic connection check passed');
        } catch (countError) {
          console.error('Mood model basic connection check failed:', countError.message);
          console.warn('Server will continue but mood tracker functionality may be limited');
        }
      }
    } catch (moodDbError) {
      console.error('Failed to connect to mood tracker database:', moodDbError.message);
      console.warn('Server will start with limited mood tracker functionality');
    }
    
    // 5. Initialize chat database collections
    try {
      const { initializeDatabase } = require('./models/initializeDB');
      await initializeDatabase();
      console.log('Chat database collections initialized successfully');
    } catch (dbInitError) {
      console.error('Failed to initialize chat database collections:', dbInitError.message);
      console.warn('Server will start with limited chat functionality');
    }
    
    // 6. Load the suicide detection dataset
    await loadSuicideDataset();
    
    // 7. Start the server
    const PORT = process.env.PORT || 5001;
    server.listen(PORT, () => {
      console.log(`MindBridge server running on http://localhost:${PORT}`);
      console.log('----------------------------------------------------');
      console.log('Services available:');
      console.log('- Feed API');
      console.log('- Authentication API');
      console.log('- User Profiles API');
      console.log(`- Mood Tracker API (${moodDbConnected ? 'Available' : 'Limited'})`);
      console.log('- Therapist API');
      console.log('- Appointment API');
      console.log('- Community Chat API');
      console.log('- AI Chat');
      console.log('----------------------------------------------------');
    });
  } catch (error) {
    console.error('Critical initialization error:', error);
    console.error('Server cannot start due to critical initialization failure');
    process.exit(1);
  }
})();

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down server gracefully...');
  
  // Close any open database connections
  try {
    if (mongoose.connection.readyState === 1) {
      console.log('Closing mongoose connections...');
      await mongoose.connection.close();
    }
    
    // Close server
    server.close(() => {
      console.log('HTTP server closed');
    });
    
    console.log('All connections closed. Exiting process.');
    process.exit(0);
  } catch (err) {
    console.error('Error during shutdown:', err);
    process.exit(1);
  }
});