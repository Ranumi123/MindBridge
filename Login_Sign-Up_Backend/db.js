// db.js - MongoDB Connection Setup
const { MongoClient, ObjectId } = require('mongodb');
require('dotenv').config();

// Keep a reference to the client for proper connection management
let client;
let db;
let connectionPromise = null;

/**
 * Connect to MongoDB database
 * @returns {Promise<object>} MongoDB database instance
 */
async function connectToMongoDB() {
  // If we're already connecting, return the existing promise
  if (connectionPromise) {
    return connectionPromise;
  }

  connectionPromise = (async () => {
    try {
      // Check for required environment variables
      if (!process.env.MONGO_URI) {
        throw new Error('MONGO_URI environment variable is not defined');
      }

      // Create a new client and connect
      client = new MongoClient(process.env.MONGO_URI, {
        // MongoDB connection options for better reliability
        connectTimeoutMS: 5000,
        serverSelectionTimeoutMS: 5000,
        maxPoolSize: 10
      });

      await client.connect();
      console.log('Connected to MongoDB successfully');

      // Get database name from environment or use default
      const dbName = process.env.DB_NAME || 'myapp';
      db = client.db(dbName);
      console.log(`Using database: ${dbName}`);

      // Test the connection
      const collections = await db.listCollections().toArray();
      console.log(`Available collections: ${collections.map(c => c.name).join(', ') || 'None yet'}`);

      // Set up connection monitoring and cleanup
      setupConnectionHandlers();

      return db;
    } catch (error) {
      console.error('Failed to connect to MongoDB:', error);
      connectionPromise = null;
      throw error;
    }
  })();

  return connectionPromise;
}

/**
 * Set up handlers for connection events
 */
function setupConnectionHandlers() {
  // Handle process termination gracefully
  process.on('SIGINT', closeConnection);
  process.on('SIGTERM', closeConnection);

  // Handle potential connection timeout
  client.on('timeout', () => {
    console.warn('MongoDB connection timeout occurred');
  });

  // Handle connection errors
  client.on('error', (error) => {
    console.error('MongoDB connection error:', error);
  });
}

/**
 * Close the MongoDB connection
 */
async function closeConnection() {
  try {
    if (client) {
      await client.close();
      console.log('MongoDB connection closed');
    }
  } catch (error) {
    console.error('Error closing MongoDB connection:', error);
  } finally {
    // Reset variables
    client = null;
    db = null;
    connectionPromise = null;
    process.exit(0);
  }
}

/**
 * Get the database instance
 * @returns {object} MongoDB database instance
 */
function getDB() {
  if (!db) {
    throw new Error('Database not initialized. Call connectToMongoDB first.');
  }
  return db;
}

/**
 * Verify database connectivity
 * @returns {Promise<boolean>} Whether the database is reachable
 */
async function pingDatabase() {
  try {
    if (!db) {
      throw new Error('Database not initialized');
    }
    
    // MongoDB ping command
    const result = await db.command({ ping: 1 });
    return result.ok === 1;
  } catch (error) {
    console.error('Database ping failed:', error);
    return false;
  }
}

// Export all the needed functions
module.exports = {
  connectToMongoDB,
  getDB,
  ObjectId,
  closeConnection,
  pingDatabase
};