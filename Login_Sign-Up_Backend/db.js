// db.js - Centralized MongoDB Connection
const mongoose = require('mongoose');
const { MongoClient, ObjectId } = require('mongodb');
require('dotenv').config();

// Connection state tracking
let mongoClient = null;
let nativeDb = null;
let isMongooseConnected = false;
let connectionPromise = null;

/**
 * Connect to MongoDB using Mongoose (for schema-based models)
 * @returns {Promise<mongoose.Connection>} Mongoose connection
 */
async function connectWithMongoose() {
  try {
    // If already connected, return existing connection
    if (mongoose.connection.readyState === 1) {
      console.log('Reusing existing Mongoose connection');
      return mongoose.connection;
    }
    
    // Get MongoDB URI from environment variables - specifically using your .env variables
    const mongoUri = process.env.MONGO_URI;
    const dbName = process.env.DB_NAME || 'myapp';
    
    if (!mongoUri) {
      throw new Error('MONGO_URI environment variable is not defined - check your .env file');
    }
    
    // Log sanitized connection URI (hide credentials)
    const sanitizedUri = mongoUri.replace(/mongodb(\+srv)?:\/\/([^:]+):([^@]+)@/, 'mongodb$1://**:**@');
    console.log(`Connecting to MongoDB with URI: ${sanitizedUri}`);
    console.log(`Using database: ${dbName}`);
    
    // Connection options for Mongoose
    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      dbName: dbName // Explicitly set database name
    };
    
    // Connect with Mongoose
    await mongoose.connect(mongoUri, options);
    console.log('MongoDB connection established successfully with Mongoose');
    isMongooseConnected = true;
    
    // Set up event handlers for connection
    mongoose.connection.on('error', (err) => {
      console.error('Mongoose connection error:', err);
      isMongooseConnected = false;
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('Mongoose disconnected');
      isMongooseConnected = false;
    });
    
    mongoose.connection.on('reconnected', () => {
      console.log('Mongoose reconnected');
      isMongooseConnected = true;
    });
    
    // List all collections to verify connection
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log('Available collections:', collections.map(c => c.name).join(', ') || 'No collections found');
    
    // Return the connection
    return mongoose.connection;
  } catch (error) {
    console.error('MongoDB connection error (Mongoose):', error);
    isMongooseConnected = false;
    throw error;
  }
}

/**
 * Connect to MongoDB using native driver
 * @returns {Promise<object>} MongoDB database instance
 */
async function connectToMongoDB() {
  // If we're already connecting, return the existing promise
  if (connectionPromise) {
    return connectionPromise;
  }

  connectionPromise = (async () => {
    try {
      // If already connected, return existing connection
      if (mongoClient && nativeDb) {
        console.log('Reusing existing MongoDB native connection');
        return nativeDb;
      }
      
      // Get MongoDB URI from environment variables
      const mongoUri = process.env.MONGO_URI;
      const dbName = process.env.DB_NAME || 'myapp';
      
      if (!mongoUri) {
        throw new Error('MONGO_URI environment variable is not defined - check your .env file');
      }
      
      // Log sanitized connection URI (hide credentials)
      const sanitizedUri = mongoUri.replace(/mongodb(\+srv)?:\/\/([^:]+):([^@]+)@/, 'mongodb$1://**:**@');
      console.log(`Connecting to MongoDB with URI: ${sanitizedUri}`);
      
      // Create a new client with appropriate options
      mongoClient = new MongoClient(mongoUri, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        connectTimeoutMS: 5000,
        serverSelectionTimeoutMS: 5000,
        maxPoolSize: 10
      });
      
      // Connect to MongoDB
      await mongoClient.connect();
      console.log('Connected to MongoDB successfully using native driver');
      
      // Get database name from environment
      nativeDb = mongoClient.db(dbName);
      console.log(`Using database: ${dbName}`);
      
      // List all collections to verify connection
      const collections = await nativeDb.listCollections().toArray();
      console.log(`Available collections: ${collections.map(c => c.name).join(', ') || 'None yet'}`);
      
      // Set up connection monitoring and cleanup
      setupConnectionHandlers();
      
      // Return the database instance
      return nativeDb;
    } catch (error) {
      console.error('Failed to connect to MongoDB with native driver:', error);
      mongoClient = null;
      nativeDb = null;
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
  process.on('SIGINT', closeConnections);
  process.on('SIGTERM', closeConnections);

  // Handle potential connection timeout
  if (mongoClient) {
    mongoClient.on('timeout', () => {
      console.warn('MongoDB connection timeout occurred');
    });

    // Handle connection errors
    mongoClient.on('error', (error) => {
      console.error('MongoDB connection error:', error);
    });
  }
}

/**
 * Check if database is connected and accessible
 * @returns {Promise<boolean>} Database connection status
 */
async function checkDatabase() {
  try {
    // Check Mongoose connection if it's being used
    if (mongoose.connection.readyState !== 1 && isMongooseConnected) {
      console.warn('Mongoose not connected, attempting to connect...');
      await connectWithMongoose();
    }
    
    // Check native MongoDB connection
    if (!nativeDb) {
      console.warn('Native MongoDB not connected, attempting to connect...');
      await connectToMongoDB();
    }
    
    // Perform simple query to verify connection
    await pingDatabase();
    console.log('Database check successful - MongoDB is responsive');
    return true;
  } catch (error) {
    console.error('Database check failed:', error);
    return false;
  }
}

/**
 * Verify database connectivity with ping
 * @returns {Promise<boolean>} Whether the database is reachable
 */
async function pingDatabase() {
  try {
    if (!nativeDb) {
      throw new Error('Database not initialized');
    }
    
    // MongoDB ping command
    const result = await nativeDb.command({ ping: 1 });
    return result.ok === 1;
  } catch (error) {
    console.error('Database ping failed:', error);
    return false;
  }
}

/**
 * Get the database instance
 * @returns {object} MongoDB database instance
 */
function getDB() {
  if (!nativeDb) {
    throw new Error('Database not initialized. Call connectToMongoDB first.');
  }
  return nativeDb;
}

/**
 * Close all database connections
 */
async function closeConnections() {
  try {
    if (mongoose.connection && mongoose.connection.readyState === 1) {
      await mongoose.connection.close();
      console.log('Mongoose connection closed');
    }
    
    if (mongoClient) {
      await mongoClient.close();
      console.log('MongoDB native client connection closed');
    }
    
    mongoClient = null;
    nativeDb = null;
    isMongooseConnected = false;
    connectionPromise = null;

    // Optional: process.exit(0) if this is used on server shutdown
    // process.exit(0);
  } catch (error) {
    console.error('Error closing MongoDB connections:', error);
  }
}

// Export functions
module.exports = {
  connectWithMongoose,
  connectToMongoDB,
  getDB,
  checkDatabase,
  pingDatabase,
  closeConnections,
  ObjectId,
  getMongoose: () => mongoose
};