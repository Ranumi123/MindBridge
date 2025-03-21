// Combined MindBridge and Chat Forum Server
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { GoogleGenerativeAI } = require("@google/generative-ai");
const tf = require('@tensorflow/tfjs');
const toxicity = require('@tensorflow-models/toxicity');
const fs = require('fs').promises;
const path = require('path');

// Import MongoDB connection
const { connectToMongoDB, getDB, pingDatabase } = require('./db');

// Import routes
const authRoutes = require("./routes/authRoutes");
const profileRoutes = require("./routes/profileRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Google Generative AI Setup
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

// Path to the suicidal dataset
const datasetPath = path.join(__dirname, 'datasets', 'Suicide_Ideation_Dataset(Twitter-based).csv');

// In-memory storage for processed dataset
let suicideDataset = [];
let suicidalPatterns = [];
let initialized = false;

// Chat forum in-memory data (will be moved to MongoDB later)
let chatGroups = [
  {
    id: '1',
    name: 'Depression Support',
    members: '0/10',
    description: 'A safe space to discuss depression and support each other',
    membersList: []
  },
  {
    id: '2',
    name: 'Anxiety Management',
    members: '0/8',
    description: 'Share anxiety coping strategies and experiences',
    membersList: []
  }
];

let messages = {
  '1': [
    {
      id: '1',
      message: 'Welcome to Depression Support group!',
      sender: 'Admin',
      timestamp: new Date().toISOString(),
      isMe: false
    }
  ],
  '2': [
    {
      id: '1',
      message: 'Welcome to Anxiety Management group!',
      sender: 'Admin',
      timestamp: new Date().toISOString(),
      isMe: false
    }
  ]
};

// Helper function to generate IDs
function generateId() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

// Helper function to update member count
function updateMembersCount(groupId) {
  const group = chatGroups.find(g => g.id === groupId);
  if (group) {
    const parts = group.members.split('/');
    const maxMembers = parseInt(parts[1]);
    group.members = `${group.membersList.length}/${maxMembers}`;
  }
}

// Load and process suicide dataset
async function loadSuicideDataset() {
  if (initialized) {
    return true;
  }
  
  try {
    // Check if the file exists
    if (!await fileExists(datasetPath)) {
      console.error("Dataset file not found at:", datasetPath);
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
      return { Tweet: columns[tweetIndex].trim(), Suicide: columns[suicideIndex].trim() };
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

  suicideDataset.forEach(item => {
    if (item.Suicide.toLowerCase().includes("suicide") || item.Suicide.toLowerCase().includes("potential")) {
      baseIndicators.forEach(indicator => {
        if (item.Tweet.toLowerCase().includes(indicator) && !suicidalPatterns.includes(indicator)) {
          suicidalPatterns.push(indicator);
        }
      });
    }
  });

  console.log(`Extracted ${suicidalPatterns.length} suicide patterns from dataset`);
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

// MongoDB-integrated functions
async function getEmergencyContacts(userId) {
  try {
    const db = getDB();
    const user = await db.collection('users').findOne({ _id: userId });
    
    if (user && user.emergencyContacts && user.emergencyContacts.length > 0) {
      return user.emergencyContacts;
    }
    
    // Default if no contacts found
    return [
      { name: "Contact 1", phone: "+1234567890" },
      { name: "Contact 2", phone: "+0987654321" }
    ];
  } catch (error) {
    console.error("Error getting emergency contacts:", error);
    return [
      { name: "Contact 1", phone: "+1234567890" },
      { name: "Contact 2", phone: "+0987654321" }
    ];
  }
}

async function notifyEmergencyContacts(userId) {
  const emergencyContacts = await getEmergencyContacts(userId);
  
  // Store crisis event in MongoDB
  try {
    const db = getDB();
    
    await db.collection('crisisEvents').insertOne({
      userId,
      timestamp: new Date(),
      contactsNotified: emergencyContacts,
      status: 'notified'
    });
  } catch (error) {
    console.error("Error logging crisis event:", error);
  }
  
  emergencyContacts.forEach(contact => {
    sendSMS(contact.phone, `Urgent: User ${userId} may be in danger. Please check on them immediately.`);
  });
}

function sendSMS(phone, message) {
  console.log(`Sending SMS to ${phone}: ${message}`);
  // Implement actual SMS sending here
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

// Store forum messages in MongoDB - IMPROVED VERSION
async function storeForumMessage(groupId, message) {
  try {
    // Make sure DB is initialized
    const db = getDB();
    
    // Make sure message has the right format for MongoDB
    const messageToStore = {
      groupId,
      ...message,
      // Convert string timestamp to Date object if it's not already
      timestamp: message.timestamp ? new Date(message.timestamp) : new Date()
    };
    
    // Insert the message and wait for the operation to complete
    const result = await db.collection('forumMessages').insertOne(messageToStore);
    
    // Log success to verify in the console
    console.log(`Forum message stored in MongoDB with ID: ${result.insertedId}`);
    return result;
  } catch (error) {
    console.error("Error storing forum message:", error);
    // Throw the error so calling function can handle it if needed
    throw error;
  }
}

// Initialize forum groups in database
async function initializeForumGroups() {
  try {
    const db = getDB();
    
    // Check if groups collection exists and has data
    const existingGroups = await db.collection('chatGroups')
      .find({})
      .toArray();
    
    if (existingGroups && existingGroups.length > 0) {
      console.log(`Found ${existingGroups.length} existing chat groups in database`);
      // Optionally sync in-memory groups with DB groups
      chatGroups = existingGroups;
    } else {
      // Store the initial groups in the database
      const result = await db.collection('chatGroups').insertMany(chatGroups);
      console.log(`Initialized ${result.insertedCount} chat groups in database`);
    }
    
    // Now initialize messages for each group
    for (const group of chatGroups) {
      const groupMessages = messages[group.id] || [];
      
      // Check if this group already has messages in the database
      const existingMessages = await db.collection('forumMessages')
        .find({ groupId: group.id })
        .toArray();
      
      if (existingMessages && existingMessages.length === 0 && groupMessages.length > 0) {
        // Store initial messages for this group
        const messagePromises = groupMessages.map(msg => 
          db.collection('forumMessages').insertOne({
            groupId: group.id,
            ...msg,
            timestamp: msg.timestamp ? new Date(msg.timestamp) : new Date()
          })
        );
        
        await Promise.all(messagePromises);
        console.log(`Initialized ${groupMessages.length} messages for group ${group.id}`);
      } else {
        console.log(`Group ${group.id} already has ${existingMessages.length} messages in database`);
      }
    }
  } catch (error) {
    console.error("Error initializing forum groups in database:", error);
  }
}

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/profile", profileRoutes);

// Health check route
app.get("/", (req, res) => {
  res.send("Server is running!");
});

// AI Chat route
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

// Group forum routes

// Get all chat groups
app.get('/groups', (req, res) => {
  res.json(chatGroups);
});

// Get a specific group by ID
app.get('/groups/:groupId', (req, res) => {
  const { groupId } = req.params;
  const group = chatGroups.find(g => g.id === groupId);
  
  if (!group) {
    return res.status(404).json({ error: 'Group not found' });
  }
  
  res.json(group);
});

// Get messages for a specific group - IMPROVED VERSION
app.get('/groups/:groupId/messages', async (req, res) => {
  const { groupId } = req.params;
  
  // Check if group exists in memory
  if (!messages[groupId]) {
    return res.status(404).json({ error: 'Group not found' });
  }
  
  try {
    // Get database connection
    const db = getDB();
    
    // Ping database to verify connection
    const isConnected = await pingDatabase();
    if (!isConnected) {
      console.warn("Database connection issue, falling back to in-memory messages");
      return res.json(messages[groupId]);
    }
    
    // Try to fetch from MongoDB
    const dbMessages = await db.collection('forumMessages')
      .find({ groupId })
      .sort({ timestamp: 1 })
      .toArray();
    
    console.log(`Retrieved ${dbMessages.length} messages from MongoDB for group ${groupId}`);
    
    // If we have messages in the database, return those
    if (dbMessages && dbMessages.length > 0) {
      return res.json(dbMessages);
    } else {
      // If no messages in DB, store the in-memory messages in DB for future use
      const storePromises = messages[groupId].map(msg => storeForumMessage(groupId, msg).catch(err => console.error(err)));
      await Promise.allSettled(storePromises);
      console.log(`Initialized DB with ${messages[groupId].length} in-memory messages for group ${groupId}`);
    }
  } catch (error) {
    console.error("Error fetching messages from MongoDB:", error);
    // Fall back to in-memory messages if database fetch fails
  }
  
  res.json(messages[groupId]);
});

// Send a message to a group - IMPROVED VERSION
app.post('/groups/:groupId/messages', async (req, res) => {
  const { groupId } = req.params;
  const { message, sender = 'You', userId } = req.body || {};
  
  if (!message) {
    return res.status(400).json({ error: 'Message is required' });
  }
  
  if (!messages[groupId]) {
    return res.status(404).json({ error: 'Group not found' });
  }
  
  // Check for harmful content
  const { harmful, type } = await detectHarmfulText(message);
  
  if (harmful) {
    if (type === 'suicidal') {
      // For forum posts, we handle suicidal content differently
      // Still store the message but flag it for moderators
      const moderationNote = "⚠️ This message contains concerning content. A moderator has been notified.";
      
      const newMessage = {
        id: generateId(),
        message: message,
        sender,
        timestamp: new Date().toISOString(),
        isMe: sender === 'You',
        flagged: true,
        moderationNote
      };
      
      messages[groupId].push(newMessage);
      
      try {
        // Store in MongoDB and wait for completion
        await storeForumMessage(groupId, newMessage);
        console.log("Flagged message stored in MongoDB");
        
        // Notify emergency contacts if userId is provided
        if (userId) {
          await notifyEmergencyContacts(userId);
        }
      } catch (dbError) {
        console.error("Failed to store flagged message in MongoDB:", dbError);
        // Continue with response even if DB storage fails
      }
      
      return res.status(201).json({
        ...newMessage,
        warning: "Your message contains concerning content. Resources are available if you need help."
      });
    } else {
      return res.status(400).json({ error: 'Your message contains inappropriate content and cannot be posted.' });
    }
  }
  
  const newMessage = {
    id: generateId(),
    message,
    sender,
    timestamp: new Date().toISOString(),
    isMe: sender === 'You'
  };
  
  // Add to in-memory storage
  messages[groupId].push(newMessage);
  
  try {
    // Store in MongoDB and wait for completion
    await storeForumMessage(groupId, newMessage);
    console.log("Message successfully stored in MongoDB");
  } catch (dbError) {
    console.error("Failed to store message in MongoDB:", dbError);
    // Continue with response even if DB storage fails
  }
  
  res.status(201).json(newMessage);
});

// Join a group
app.post('/groups/:groupId/join', (req, res) => {
  const { groupId } = req.params;
  const { username } = req.body || {};
  
  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }
  
  const group = chatGroups.find(g => g.id === groupId);
  
  if (!group) {
    return res.status(404).json({ error: 'Group not found' });
  }
  
  const parts = group.members.split('/');
  const currentMembers = parseInt(parts[0]);
  const maxMembers = parseInt(parts[1]);
  
  if (currentMembers >= maxMembers) {
    return res.status(400).json({ error: 'Group is full' });
  }
  
  // Check if user is already in the group
  if (group.membersList.includes(username)) {
    return res.status(400).json({ error: 'User is already a member of this group' });
  }
  
  group.membersList.push(username);
  updateMembersCount(groupId);
  
  res.status(200).json({ message: 'Successfully joined the group', group });
});

// Leave a group
app.post('/groups/:groupId/leave', (req, res) => {
  const { groupId } = req.params;
  const { username } = req.body || {};
  
  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }
  
  const group = chatGroups.find(g => g.id === groupId);
  
  if (!group) {
    return res.status(404).json({ error: 'Group not found' });
  }
  
  const userIndex = group.membersList.indexOf(username);
  
  if (userIndex === -1) {
    return res.status(400).json({ error: 'User is not a member of this group' });
  }
  
  group.membersList.splice(userIndex, 1);
  updateMembersCount(groupId);
  
  res.status(200).json({ message: 'Successfully left the group', group });
});

// Create a new group
app.post('/groups', (req, res) => {
  const { name, description } = req.body || {};
  
  if (!name) {
    return res.status(400).json({ error: 'Group name is required' });
  }
  
  const newGroup = {
    id: generateId(),
    name,
    members: '0/10',
    description: description || '',
    membersList: []
  };
  
  chatGroups.push(newGroup);
  messages[newGroup.id] = [
    {
      id: generateId(),
      message: `Welcome to ${newGroup.name}!`,
      sender: 'Admin',
      timestamp: new Date().toISOString(),
      isMe: false
    }
  ];
  
  res.status(201).json(newGroup);
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: "Something went wrong!",
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Initialize MongoDB and the dataset when server starts
(async function() {
  try {
    // Connect to MongoDB first
    await connectToMongoDB();
    console.log("MongoDB connection established");
    
    // Then load the dataset
    await loadSuicideDataset();
    
    // Initialize forum groups in database
    await initializeForumGroups();
  } catch (error) {
    console.error("Initialization error:", error);
    process.exit(1);
  }
})();

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});