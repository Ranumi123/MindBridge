const { getDB } = require('../db');

/**
 * Initialize the database with required collections and indexes for chat functionality
 * @returns {Promise<boolean>} Success status
 */
async function initializeChatCollections() {
  try {
    const db = getDB();
    
    // Check if collections exist
    const collections = await db.listCollections().toArray();
    const collectionNames = collections.map(c => c.name);
    
    // Create chatGroups collection if it doesn't exist
    if (!collectionNames.includes('chatGroups')) {
      await db.createCollection('chatGroups');
      console.log('Created chatGroups collection');
      
      // Create indexes for chatGroups collection
      await db.collection('chatGroups').createIndex({ name: 1 });
      console.log('Created index for chatGroups collection');
    }
    
    // Create chatMessages collection if it doesn't exist
    if (!collectionNames.includes('chatMessages')) {
      await db.createCollection('chatMessages');
      console.log('Created chatMessages collection');
      
      // Create indexes for chatMessages collection
      await db.collection('chatMessages').createIndex({ groupId: 1 });
      await db.collection('chatMessages').createIndex({ timestamp: 1 });
      console.log('Created indexes for chatMessages collection');
    }
    
    return true;
  } catch (error) {
    console.error('Error initializing chat collections:', error);
    return false;
  }
}

/**
 * Initialize the database with default data for chat functionality
 * @returns {Promise<boolean>} Success status
 */
async function initializeDatabase() {
  try {
    console.log('Initializing database for chat functionality...');
    
    // Initialize collections (creates them if they don't exist)
    await initializeChatCollections();
    
    // Check if we need to create default chat groups
    const db = getDB();
    const existingGroups = await db.collection('chatGroups').countDocuments({});
    
    if (existingGroups === 0) {
      console.log('No chat groups found, creating default groups...');
      
      // Create default chat groups matching the frontend expectations
      const defaultGroups = [
        {
          name: 'Mind Haven',
          members: '0/10',
          description: 'A peaceful space for mindfulness and mental wellness. Share experiences and support on your journey to peace.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Brighter Days',
          members: '0/10',
          description: 'Focus on positivity and hope. Share uplifting stories and encouragement for brighter days ahead.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Safe Space Chat',
          members: '0/10',
          description: 'A judgment-free zone where you can express yourself openly. Support and understanding for all.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Soulful Support',
          members: '0/10',
          description: 'Deep conversations about life challenges and growth. Connect with others on a meaningful level.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Rise Together',
          members: '0/10',
          description: 'Community for motivation and overcoming obstacles. Share victories and encourage each other to rise.',
          membersList: [],
          createdAt: new Date()
        }
      ];
      
      // Insert the default groups
      const result = await db.collection('chatGroups').insertMany(defaultGroups);
      console.log(`Created ${result.insertedCount} default chat groups`);
      
      // Add welcome messages to each group
      for (let i = 0; i < defaultGroups.length; i++) {
        const groupId = result.insertedIds[i].toString();
        
        await db.collection('chatMessages').insertOne({
          groupId: groupId,
          message: `Welcome to ${defaultGroups[i].name}! This is a safe space to chat and connect with others.`,
          sender: 'Admin',
          isAnonymous: false,
          timestamp: new Date(),
          isMe: false
        });
      }
      
      console.log('Added welcome messages to all groups');
    } else {
      console.log(`Found ${existingGroups} existing chat groups, skipping initialization`);
    }
    
    console.log('Chat database initialization complete');
    return true;
  } catch (error) {
    console.error('Error initializing database:', error);
    return false;
  }
}

module.exports = { 
  initializeDatabase,
  initializeChatCollections
};