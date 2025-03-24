// controllers/moodController.js
const Mood = require('../models/mood-model');
const { getMongoose } = require('../db');
const mongoose = getMongoose();
const { connectMoodDB } = require('../config/mood-db');

// Map of days in the week for formatting
const DAYS_OF_WEEK = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

// Helper function to ensure database connection
const ensureConnection = async () => {
  if (mongoose.connection.readyState !== 1) {
    console.log('Database connection not ready, attempting to reconnect...');
    await connectMoodDB();
    
    if (mongoose.connection.readyState !== 1) {
      throw new Error('Unable to establish database connection after reconnection attempt');
    }
    
    console.log('Database reconnection successful');
  }
  return true;
};

// Helper function to get start and end of a day
const getDayBoundaries = (date) => {
  const startOfDay = new Date(date);
  startOfDay.setHours(0, 0, 0, 0);
  
  const endOfDay = new Date(date);
  endOfDay.setHours(23, 59, 59, 999);
  
  return { startOfDay, endOfDay };
};

// Controller object with methods for handling mood-related operations
const moodController = {
  // Get weekly mood data for a user
  getWeeklyMoods: async (req, res) => {
    try {
      const { userId } = req.query;
      
      if (!userId) {
        return res.status(400).json({ error: "userId is required" });
      }
      
      // Ensure connection before proceeding
      await ensureConnection();
      
      // Calculate the start of the week (7 days ago)
      const weekStart = new Date();
      weekStart.setDate(weekStart.getDate() - 7);
      weekStart.setHours(0, 0, 0, 0);
      
      console.log(`Fetching moods since ${weekStart} for user ${userId}`);
      console.log('Mongoose connection state:', mongoose.connection.readyState);
      
      // Find moods for the current week
      let moods;
      try {
        moods = await Mood.find({
          userId,
          date: { $gte: weekStart }
        }).sort({ date: -1 }).lean();
      } catch (findError) {
        console.error('Error finding moods:', findError);
        throw new Error(`Database query failed: ${findError.message}`);
      }
      
      console.log(`Found ${moods.length} mood entries for the week`);
      if (moods.length > 0) {
        console.log('Sample mood entry:', JSON.stringify(moods[0]));
      } else {
        console.log('No mood entries found for this week');
      }
      
      // Initialize weekly structure with zeros
      const weeklyMoods = {
        "Mon": 0, "Tue": 0, "Wed": 0, 
        "Thu": 0, "Fri": 0, "Sat": 0, "Sun": 0
      };
      
      // Use a Map to track the latest mood for each day
      const dailyMoods = new Map();
      
      // Process found moods - group by day of week
      moods.forEach(mood => {
        const date = new Date(mood.date);
        const dayOfWeek = DAYS_OF_WEEK[date.getDay()];
        console.log(`Processing mood: ${mood.mood} (${mood.moodValue}) for ${dayOfWeek}`);
        
        // Only keep the first (most recent) mood for each day
        if (!dailyMoods.has(dayOfWeek)) {
          dailyMoods.set(dayOfWeek, mood.moodValue);
        }
      });
      
      // Update our result with found moods
      dailyMoods.forEach((value, key) => {
        weeklyMoods[key] = value;
      });
      
      console.log('Returning weekly moods:', weeklyMoods);
      res.json(weeklyMoods);
    } catch (error) {
      console.error('Error fetching weekly moods:', error);
      res.status(500).json({ 
        error: 'Failed to fetch mood data', 
        message: error.message 
      });
    }
  },
  
  // Add a new mood entry - with day persistence logic
  addMood: async (req, res) => {
    try {
      const { userId, mood, notes } = req.body;
      
      console.log('Processing mood save request:', { 
        userId, 
        mood, 
        notes: notes ? notes.substring(0, 20) + (notes.length > 20 ? '...' : '') : 'none'
      });
      
      if (!userId || !mood) {
        return res.status(400).json({ error: "userId and mood are required" });
      }
      
      // Ensure connection before proceeding
      await ensureConnection();
      
      // Check if mood is valid using the values from the model
      if (!Mood.MOOD_VALUES[mood]) {
        console.error('Invalid mood:', mood, 'Valid moods:', Object.keys(Mood.MOOD_VALUES));
        return res.status(400).json({ 
          error: "Invalid mood",
          validMoods: Object.keys(Mood.MOOD_VALUES)
        });
      }
      
      // Check if user already has a mood for today
      const today = new Date();
      const { startOfDay, endOfDay } = getDayBoundaries(today);
      
      const existingMood = await Mood.findOne({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ date: -1 });
      
      if (existingMood) {
        console.log(`User already has a mood (${existingMood.mood}) for today.`);
        
        // Return the existing mood without creating a new one
        return res.status(200).json({
          success: true,
          message: "User already has a mood for today",
          exists: true,
          data: existingMood
        });
      }
      
      console.log(`Creating new mood entry with value: ${Mood.MOOD_VALUES[mood]}`);
      
      // Create mood document
      const newMood = new Mood({
        userId,
        mood,
        moodValue: Mood.MOOD_VALUES[mood],
        date: today,
        notes: notes || ""
      });
      
      console.log('Saving mood to database...');
      
      // Save to database
      const savedMood = await newMood.save();
      
      if (!savedMood || !savedMood._id) {
        throw new Error('Failed to persist mood to database - save operation did not return a valid document');
      }
      
      console.log('Mood saved successfully with ID:', savedMood._id);
      
      // Verify the save by fetching the mood we just created
      try {
        const verifiedMood = await Mood.findById(savedMood._id);
        
        if (!verifiedMood) {
          // If direct lookup fails, try a more general search
          console.warn('Direct verification failed, trying expanded search...');
          const searchResult = await Mood.find({
            userId,
            mood,
            createdAt: { $gte: new Date(Date.now() - 60000) } // last minute
          });
          
          if (searchResult && searchResult.length > 0) {
            console.log('Alternative verification successful - found mood:', searchResult[0]._id);
          } else {
            console.error('Verification failed - mood not found in database after save');
            throw new Error('Verification failed - mood not found in database after save');
          }
        } else {
          console.log('Verified mood in database with ID:', verifiedMood._id);
        }
      } catch (verifyError) {
        console.warn('Verification lookup failed, but save appeared successful:', verifyError.message);
        // Continue anyway since the save succeeded
      }
      
      // Respond with success
      res.status(201).json({
        success: true,
        message: "Mood saved successfully",
        exists: false,
        data: savedMood
      });
    } catch (error) {
      console.error('Error saving mood:', error);
      // Return detailed error in development
      res.status(500).json({ 
        error: 'Failed to save mood data',
        message: error.message,
        stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
      });
    }
  },
  
  // Check if the user already has a mood for today
  checkTodayMood: async (req, res) => {
    try {
      const { userId } = req.query;
      
      if (!userId) {
        return res.status(400).json({ error: "userId is required" });
      }
      
      // Ensure connection before proceeding
      await ensureConnection();
      
      // Get today's boundaries
      const today = new Date();
      const { startOfDay, endOfDay } = getDayBoundaries(today);
      
      // Find mood for today
      const todayMood = await Mood.findOne({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ date: -1 });
      
      if (todayMood) {
        return res.json({
          hasMood: true,
          mood: todayMood
        });
      } else {
        return res.json({
          hasMood: false
        });
      }
    } catch (error) {
      console.error('Error checking today\'s mood:', error);
      res.status(500).json({ 
        error: 'Failed to check today\'s mood', 
        message: error.message 
      });
    }
  },
  
  // Update today's mood (if user wants to change it)
  updateTodayMood: async (req, res) => {
    try {
      const { userId, mood, notes } = req.body;
      
      if (!userId || !mood) {
        return res.status(400).json({ error: "userId and mood are required" });
      }
      
      // Ensure connection before proceeding
      await ensureConnection();
      
      // Check if mood is valid
      if (!Mood.MOOD_VALUES[mood]) {
        return res.status(400).json({ 
          error: "Invalid mood",
          validMoods: Object.keys(Mood.MOOD_VALUES)
        });
      }
      
      // Get today's boundaries
      const today = new Date();
      const { startOfDay, endOfDay } = getDayBoundaries(today);
      
      // Find existing mood for today
      const existingMood = await Mood.findOne({
        userId,
        date: { $gte: startOfDay, $lte: endOfDay }
      }).sort({ date: -1 });
      
      if (existingMood) {
        // Update existing mood
        existingMood.mood = mood;
        existingMood.moodValue = Mood.MOOD_VALUES[mood];
        existingMood.notes = notes || existingMood.notes;
        existingMood.updatedAt = new Date();
        
        const updatedMood = await existingMood.save();
        
        return res.json({
          success: true,
          message: "Mood updated successfully",
          data: updatedMood
        });
      } else {
        // Create new mood if none exists
        const newMood = new Mood({
          userId,
          mood,
          moodValue: Mood.MOOD_VALUES[mood],
          date: today,
          notes: notes || ""
        });
        
        const savedMood = await newMood.save();
        
        return res.status(201).json({
          success: true,
          message: "New mood created for today",
          data: savedMood
        });
      }
    } catch (error) {
      console.error('Error updating today\'s mood:', error);
      res.status(500).json({ 
        error: 'Failed to update mood', 
        message: error.message 
      });
    }
  },
  
  // Clear all mood entries for a user
  clearMoods: async (req, res) => {
    try {
      const { userId } = req.query;
      
      if (!userId) {
        return res.status(400).json({ error: "userId is required" });
      }
      
      // Ensure connection before proceeding
      await ensureConnection();
      
      // Delete all mood entries for the user
      const result = await Mood.deleteMany({ userId });
      
      console.log(`Deleted ${result.deletedCount} mood entries for user ${userId}`);
      
      res.json({
        success: true,
        message: "All mood entries cleared",
        count: result.deletedCount
      });
    } catch (error) {
      console.error('Error clearing moods:', error);
      res.status(500).json({ 
        error: 'Failed to clear mood data', 
        message: error.message 
      });
    }
  },
  
  // Get a user's mood history (paginated)
  getMoodHistory: async (req, res) => {
    try {
      const { userId } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const skip = (page - 1) * limit;
      
      if (!userId) {
        return res.status(400).json({ error: "userId is required" });
      }
      
      // Ensure connection before proceeding
      await ensureConnection();
      
      // Get paginated mood entries
      const moods = await Mood.find({ userId })
        .sort({ date: -1 })
        .skip(skip)
        .limit(limit)
        .lean();
      
      // Get total count for pagination
      const total = await Mood.countDocuments({ userId });
      
      res.json({
        success: true,
        data: moods,
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit)
        }
      });
    } catch (error) {
      console.error('Error fetching mood history:', error);
      res.status(500).json({ 
        error: 'Failed to fetch mood history', 
        message: error.message 
      });
    }
  },
  
  // Debug endpoint to check database connection
  debugConnection: async (req, res) => {
    try {
      // Get connection state
      const connectionState = mongoose.connection.readyState;
      const connectionStateText = ['disconnected', 'connected', 'connecting', 'disconnecting'][connectionState];
      
      // Try to insert a test document
      let testResult = null;
      let testFind = null;
      let collections = [];
      
      if (connectionState === 1) {
        try {
          // Test collection access
          collections = await mongoose.connection.db.listCollections().toArray();
          collections = collections.map(c => c.name);
          
          // Test save operation
          const TestMood = new Mood({
            userId: 'debug-test',
            mood: 'Happy',
            moodValue: 3,
            date: new Date(),
            notes: 'Debug test'
          });
          
          // Save test document
          const savedTest = await TestMood.save();
          testResult = { 
            success: true, 
            id: savedTest._id.toString() 
          };
          
          // Test find operation
          testFind = await Mood.findById(savedTest._id);
          
          // Clean up test document
          await Mood.findByIdAndDelete(savedTest._id);
          console.log('Test document created and deleted successfully');
        } catch (testError) {
          console.error('Error during test operations:', testError);
          testResult = { 
            success: false, 
            error: testError.message 
          };
        }
      }
      
      // Return detailed connection info
      res.json({
        connectionState,
        connectionStateText,
        databaseName: mongoose.connection.name,
        collections,
        moodsCollection: collections.includes('moods'),
        testSave: testResult,
        testFind: testFind ? true : false,
        models: Object.keys(mongoose.models),
        environment: {
          nodeEnv: process.env.NODE_ENV,
          mongoUri: process.env.MONGODB_URI ? 'defined' : 'undefined',
          mongoUriAlt: process.env.MONGO_URI ? 'defined' : 'undefined'
        }
      });
    } catch (error) {
      console.error('Error in debug route:', error);
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = moodController;