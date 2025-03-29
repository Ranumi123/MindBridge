const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');
const { getDB } = require('../db');

// Get all chat groups
router.get('/', async (req, res) => {
  try {
    const db = getDB();
    const groups = await db.collection('chatGroups').find({}).toArray();
    
    res.status(200).json(groups);
  } catch (error) {
    console.error('Error getting chat groups:', error);
    res.status(500).json({ message: 'Failed to fetch chat groups', error: error.message });
  }
});

// Get a specific chat group
router.get('/:id', async (req, res) => {
  try {
    const db = getDB();
    const groupId = req.params.id;
    
    // Try to get the group, whether it's stored with ObjectId or as string id
    let group;
    
    // First try getting it as ObjectId if valid format
    if (ObjectId.isValid(groupId)) {
      group = await db.collection('chatGroups').findOne({ _id: new ObjectId(groupId) });
    }
    
    // If not found, try as string id
    if (!group) {
      group = await db.collection('chatGroups').findOne({ _id: groupId });
    }
    
    if (!group) {
      return res.status(404).json({ message: 'Chat group not found' });
    }
    
    res.status(200).json(group);
  } catch (error) {
    console.error('Error getting chat group:', error);
    res.status(500).json({ message: 'Failed to fetch chat group', error: error.message });
  }
});

// Create a new chat group
router.post('/', async (req, res) => {
  try {
    const db = getDB();
    const { name, description } = req.body;
    
    if (!name) {
      return res.status(400).json({ message: 'Group name is required' });
    }
    
    const newGroup = {
      name,
      description: description || '',
      members: '0/10', // Initial member count with maximum
      membersList: [],
      createdAt: new Date()
    };
    
    const result = await db.collection('chatGroups').insertOne(newGroup);
    
    // Get the created group with ID
    const createdGroup = {
      ...newGroup,
      _id: result.insertedId
    };
    
    res.status(201).json(createdGroup);
  } catch (error) {
    console.error('Error creating chat group:', error);
    res.status(500).json({ message: 'Failed to create chat group', error: error.message });
  }
});

// Join a chat group
router.post('/:id/join', async (req, res) => {
  try {
    const db = getDB();
    const groupId = req.params.id;
    const { username } = req.body;
    
    if (!username) {
      return res.status(400).json({ message: 'Username is required' });
    }
    
    // Get the current group, handle both ObjectId and string ID formats
    let group;
    
    // First try getting it as ObjectId if valid format
    if (ObjectId.isValid(groupId)) {
      group = await db.collection('chatGroups').findOne({ _id: new ObjectId(groupId) });
    }
    
    // If not found, try as string id
    if (!group) {
      group = await db.collection('chatGroups').findOne({ _id: groupId });
    }
    
    if (!group) {
      return res.status(404).json({ message: 'Chat group not found' });
    }
    
    // Parse the current member count
    const [currentMembers, maxMembers] = group.members.split('/').map(Number);
    
    // Check if the group is full
    if (currentMembers >= maxMembers) {
      return res.status(400).json({ message: 'This group is full! Max 10 members.' });
    }
    
    // Check if the user is already a member
    if (group.membersList.includes(username)) {
      return res.status(400).json({ message: 'User is already a member of this group' });
    }
    
    // Add the user to the group
    const updatedMembersList = [...group.membersList, username];
    const updatedMembers = `${currentMembers + 1}/${maxMembers}`;
    
    // Update the group
    const groupIdQuery = ObjectId.isValid(group._id) ? 
      { _id: new ObjectId(group._id) } : 
      { _id: group._id };
      
    await db.collection('chatGroups').updateOne(
      groupIdQuery,
      { 
        $set: { 
          members: updatedMembers,
          membersList: updatedMembersList 
        } 
      }
    );
    
    // Get the updated group
    const updatedGroup = await db.collection('chatGroups').findOne(groupIdQuery);
    
    // Notify all connected clients about the new member
    const io = req.app.get('io');
    if (io) {
      io.to(groupId).emit('memberJoined', { groupId, username, memberCount: updatedMembers });
    }
    
    res.status(200).json(updatedGroup);
  } catch (error) {
    console.error('Error joining chat group:', error);
    res.status(500).json({ message: 'Failed to join chat group', error: error.message });
  }
});

// Leave a chat group
router.post('/:id/leave', async (req, res) => {
  try {
    const db = getDB();
    const groupId = req.params.id;
    const { username } = req.body;
    
    if (!username) {
      return res.status(400).json({ message: 'Username is required' });
    }
    
    // Get the current group, handle both ObjectId and string ID formats
    let group;
    
    // First try getting it as ObjectId if valid format
    if (ObjectId.isValid(groupId)) {
      group = await db.collection('chatGroups').findOne({ _id: new ObjectId(groupId) });
    }
    
    // If not found, try as string id
    if (!group) {
      group = await db.collection('chatGroups').findOne({ _id: groupId });
    }
    
    if (!group) {
      return res.status(404).json({ message: 'Chat group not found' });
    }
    
    // Parse the current member count
    const [currentMembers, maxMembers] = group.members.split('/').map(Number);
    
    // Check if the user is a member
    if (!group.membersList.includes(username)) {
      return res.status(400).json({ message: 'User is not a member of this group' });
    }
    
    // Remove the user from the group
    const updatedMembersList = group.membersList.filter(member => member !== username);
    const updatedMembers = `${Math.max(0, currentMembers - 1)}/${maxMembers}`;
    
    // Update the group
    const groupIdQuery = ObjectId.isValid(group._id) ? 
      { _id: new ObjectId(group._id) } : 
      { _id: group._id };
      
    await db.collection('chatGroups').updateOne(
      groupIdQuery,
      { 
        $set: { 
          members: updatedMembers,
          membersList: updatedMembersList 
        } 
      }
    );
    
    // Get the updated group
    const updatedGroup = await db.collection('chatGroups').findOne(groupIdQuery);
    
    // Notify all connected clients about the member leaving
    const io = req.app.get('io');
    if (io) {
      io.to(groupId).emit('memberLeft', { groupId, username, memberCount: updatedMembers });
    }
    
    res.status(200).json(updatedGroup);
  } catch (error) {
    console.error('Error leaving chat group:', error);
    res.status(500).json({ message: 'Failed to leave chat group', error: error.message });
  }
});

// Initialize chat groups (for testing)
router.post('/initialize', async (req, res) => {
  try {
    const { initializeDatabase } = require('../models/initializeDB');
    const success = await initializeDatabase();
    
    if (success) {
      res.status(200).json({ message: 'Chat groups initialized successfully' });
    } else {
      res.status(500).json({ message: 'Failed to initialize chat groups' });
    }
  } catch (error) {
    console.error('Error initializing chat groups:', error);
    res.status(500).json({ message: 'Failed to initialize chat groups', error: error.message });
  }
});

module.exports = router;