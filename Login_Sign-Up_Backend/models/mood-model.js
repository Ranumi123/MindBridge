// models/mood-model.js
const { getMongoose } = require('../db');
const mongoose = getMongoose();

// Import mood configuration
const moodConfig = require('../config/mood-config');

// Define the mood schema
const moodSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  mood: {
    type: String,
    enum: moodConfig.moodTypes,
    required: true
  },
  moodValue: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  date: {
    type: Date,
    default: Date.now,
    index: true
  },
  notes: {
    type: String,
    default: ""
  }
}, {
  timestamps: true,  // Adds createdAt and updatedAt timestamps
  collection: 'moods' // Explicitly set collection name to match your needs
});

// Add indexes for performance
moodSchema.index({ userId: 1, date: -1 });

// Static property for mood values from config
moodSchema.statics.MOOD_VALUES = moodConfig.moodValues;

// Method to verify connection - this is critical for Atlas to ensure connectivity
moodSchema.statics.verifyConnection = async function() {
  try {
    // Check mongoose connection
    if (mongoose.connection.readyState !== 1) {
      console.error('Mongoose not connected! Current state:', mongoose.connection.readyState);
      return false;
    }
    
    // Try a lightweight find operation
    await this.findOne().exec();
    
    // Try to count documents
    const count = await this.countDocuments();
    console.log(`Mood model connection verified - found ${count} documents`);
    
    return true;
  } catch (error) {
    console.error('Mood model connection verification failed:', error);
    // Try to get more detailed error information
    console.error(`Error details: ${error.name} - ${error.message}`);
    if (error.codeName) {
      console.error(`MongoDB error code: ${error.codeName}`);
    }
    return false;
  }
};

// Enhanced method to create a mood document with better error handling
moodSchema.statics.createMood = async function(moodData) {
  try {
    const newMood = new this(moodData);
    const savedMood = await newMood.save();
    
    // Verify the save by immediately retrieving
    const verifiedMood = await this.findById(savedMood._id);
    if (!verifiedMood) {
      throw new Error('Verification failed - saved mood not found in database');
    }
    
    return savedMood;
  } catch (error) {
    console.error('Error creating mood:', error);
    throw error;
  }
};

// Create the model - handle potential duplicate model errors
let Mood;
try {
  // Check if model already exists to avoid OverwriteModelError
  if (mongoose.models && mongoose.models.Mood) {
    Mood = mongoose.models.Mood;
    console.log('Retrieved existing Mood model from mongoose');
  } else {
    Mood = mongoose.model('Mood', moodSchema);
    console.log('Created new Mood model');
  }
} catch (modelError) {
  console.error('Error with Mood model creation:', modelError);
  // As a fallback, try to create it again with a different approach
  try {
    delete mongoose.models.Mood;
    Mood = mongoose.model('Mood', moodSchema);
    console.log('Created Mood model after cleanup');
  } catch (secondError) {
    console.error('Fatal error creating Mood model:', secondError);
    throw secondError;
  }
}

// Export the model
module.exports = Mood;