// routes/profileRoutes.js

const express = require("express");
const profileController = require("../controllers/profileController");
const { ObjectId } = require('mongodb');
const { getDB } = require('../db');

const router = express.Router();

// Profile routes with controller
router.get("/", profileController.getProfile); // GET /api/profile
router.put("/", profileController.updateProfile); // PUT /api/profile
router.put("/preferences", profileController.updatePreferences); // PUT /api/profile/preferences
router.put("/privacy-settings", profileController.updatePrivacySettings); // PUT /api/profile/privacy-settings

// Get user profile by ID or email
router.get('/user/:identifier', async (req, res) => {
  try {
    const identifier = req.params.identifier;
    const db = getDB();
    let user;
    
    // Check if the identifier is a userId (starts with 'user_')
    if (identifier.startsWith('user_')) {
      user = await db.collection('users').findOne({ userId: identifier });
    }
    // Check if the identifier is an email (contains @)
    else if (identifier.includes('@')) {
      user = await db.collection('users').findOne({ email: identifier });
    } else {
      // Try to find by ID
      try {
        user = await db.collection('users').findOne({ _id: new ObjectId(identifier) });
      } catch (err) {
        return res.status(404).json({ msg: 'Invalid user ID format' });
      }
    }
    
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }
    
    // Don't return the password
    const { password, ...userData } = user;
    
    res.json(userData);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

// Update user profile (direct DB method)
router.put('/user/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const db = getDB();
    const {
      name,
      email,
      bio,
      organization,
      location,
      phone,
      profileImageUrl
    } = req.body;

    // Build update object with only provided fields
    const updateFields = {};
    if (name) updateFields.name = name;
    if (email) updateFields.email = email;
    
    // Handle profile fields
    const profileFields = {};
    if (bio) profileFields.bio = bio;
    if (phone) profileFields.phone = phone;
    
    // Other fields
    if (organization) updateFields.organization = organization;
    if (location) updateFields.location = location;
    if (profileImageUrl) updateFields.profilePicture = profileImageUrl;
    
    // Add profile fields if any were provided
    if (Object.keys(profileFields).length > 0) {
      // Use $set with dot notation for nested fields to avoid overwriting the entire profile object
      Object.entries(profileFields).forEach(([key, value]) => {
        updateFields[`profile.${key}`] = value;
      });
    }

    let result;
    
    // Check if the userId is a consistent ID or ObjectId
    if (userId && userId.startsWith('user_')) {
      result = await db.collection('users').updateOne(
        { userId },
        { $set: updateFields }
      );
    } else {
      // If not a consistent ID, treat as ObjectId
      try {
        result = await db.collection('users').updateOne(
          { _id: new ObjectId(userId) },
          { $set: updateFields }
        );
      } catch (err) {
        return res.status(404).json({ msg: 'Invalid user ID format' });
      }
    }

    if (result.matchedCount === 0) {
      return res.status(404).json({ msg: 'User not found' });
    }

    // Get the updated user with proper ID handling
    let updatedUser;
    if (userId && userId.startsWith('user_')) {
      updatedUser = await db.collection('users').findOne({ userId });
    } else {
      updatedUser = await db.collection('users').findOne({ _id: new ObjectId(userId) });
    }
    
    const { password, ...userData } = updatedUser;
    
    res.json(userData);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;