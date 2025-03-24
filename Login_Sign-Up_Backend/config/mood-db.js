// config/mood-db.js
const { connectWithMongoose, getMongoose } = require('../db');

// Tracking connection state
let moodDBConnected = false;

/**
 * Connect to MongoDB for the mood tracker using your .env configuration
 * @returns {Promise<object>} Mongoose connection
 */
const connectMoodDB = async () => {
  try {
    console.log('Initializing mood tracker database connection...');
    
    // Connect using the centralized connection
    const connection = await connectWithMongoose();
    
    // Once connected, ensure the moods collection exists
    const mongoose = getMongoose();
    const dbName = process.env.DB_NAME || 'myapp';
    
    console.log(`Using database for mood tracker: ${dbName}`);
    
    // Get existing collections
    const collections = await mongoose.connection.db.listCollections().toArray();
    const collectionNames = collections.map(c => c.name);
    
    console.log('Checking for moods collection among existing collections:', collectionNames.join(', '));
    
    // Create moods collection if it doesn't exist
    if (!collectionNames.includes('moods')) {
      console.log('Creating moods collection...');
      try {
        await mongoose.connection.db.createCollection('moods');
        console.log('Moods collection created successfully');
      } catch (collError) {
        // In case of error - try a different approach
        console.error('Error creating collection directly:', collError.message);
        
        // Sometimes Atlas has permission issues with createCollection command
        // Try creating it by inserting a document
        try {
          await mongoose.connection.db.collection('moods').insertOne({
            _test: true,
            createdAt: new Date()
          });
          console.log('Moods collection created via insertion');
          
          // Clean up test document
          await mongoose.connection.db.collection('moods').deleteOne({ _test: true });
        } catch (insertError) {
          console.error('Failed to create collection via insertion:', insertError.message);
          throw insertError;
        }
      }
      
      // Create indexes for better performance
      try {
        await mongoose.connection.db.collection('moods').createIndex({ userId: 1 });
        await mongoose.connection.db.collection('moods').createIndex({ date: -1 });
        await mongoose.connection.db.collection('moods').createIndex({ userId: 1, date: -1 });
        console.log('Indexes created for moods collection');
      } catch (indexError) {
        console.warn('Could not create indexes:', indexError.message);
        // Continue anyway, indexes can be created later
      }
    } else {
      console.log('Moods collection already exists');
    }
    
    // Verify we can access the moods collection
    try {
      const count = await mongoose.connection.db.collection('moods').countDocuments();
      console.log(`Found ${count} existing mood documents`);
      
      // Set connection flag
      moodDBConnected = true;
      console.log('Mood tracker database initialized successfully');
    } catch (countError) {
      console.error('Error counting mood documents:', countError);
      throw countError;
    }
    
    return connection;
  } catch (error) {
    console.error('Error initializing mood tracker database:', error);
    moodDBConnected = false;
    throw error;
  }
};

/**
 * Check if mood database is connected
 * @returns {boolean} Connection status
 */
const isMoodDBConnected = () => {
  return moodDBConnected;
};

/**
 * Reset mood database connection flag (for reconnection attempts)
 */
const resetMoodDBConnection = () => {
  moodDBConnected = false;
};

module.exports = {
  connectMoodDB,
  isMoodDBConnected,
  resetMoodDBConnection
};