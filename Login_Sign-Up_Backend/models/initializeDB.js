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
          name: 'Tech Talk',
          members: '0/10',
          description: 'Discuss the latest tech trends and innovations. Share news about gadgets, software, and tech events!',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Fitness Club',
          members: '0/10',
          description: 'Stay fit and healthy with others! Share workout routines, nutrition tips, and fitness motivation.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Book Lovers',
          members: '0/10',
          description: 'Share and discuss your favorite books! From classics to contemporary, fiction to non-fiction.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Gaming Zone',
          members: '0/10',
          description: 'Talk about games and play together! PC, console, or mobile - all gamers welcome here.',
          membersList: [],
          createdAt: new Date()
        },
        {
          name: 'Music Vibes',
          members: '0/10',
          description: 'Share your favorite music and artists! Discover new songs, discuss concerts, and connect through music.',
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