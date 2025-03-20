// db.js - MongoDB Connection Setup
const { MongoClient, ObjectId } = require('mongodb');
require('dotenv').config();

let db;

async function connectToMongoDB() {
  try {
    const client = new MongoClient(process.env.MONGO_URI);
    await client.connect();
    console.log('Connected to MongoDB successfully');
    
    // Get reference to the database
    db = client.db(process.env.DB_NAME || 'myapp');
    
    return db;
  } catch (error) {
    console.error('Failed to connect to MongoDB:', error);
    throw error;
  }
}

function getDB() {
  if (!db) {
    throw new Error('Database not initialized. Call connectToMongoDB first.');
  }
  return db;
}

module.exports = { connectToMongoDB, getDB, ObjectId };