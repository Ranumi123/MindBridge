// // routes/profileRoutes.js

// const express = require("express");
// const profileController = require("../controllers/profileController");

// const router = express.Router();

// // Profile routes
// router.get("/", profileController.getProfile); // GET /api/profile
// router.put("/", profileController.updateProfile); // PUT /api/profile
// router.put("/preferences", profileController.updatePreferences); // PUT /api/profile/preferences
// router.put("/privacy-settings", profileController.updatePrivacySettings); // PUT /api/profile/privacy-settings

// module.exports = router;

// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');
const { getDB } = require('../db');

// Get user profile by ID or email
router.get('/:identifier', async (req, res) => {
  try {
    const identifier = req.params.identifier;
    const db = getDB();
    let user;
    
    // Check if the identifier is an email (contains @)
    if (identifier.includes('@')) {
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

// Update user profile
router.put('/:id', async (req, res) => {
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
    if (bio) updateFields.bio = bio;
    if (organization) updateFields.organization = organization;
    if (location) updateFields.location = location;
    if (phone) updateFields.phone = phone;
    if (profileImageUrl) updateFields.profileImageUrl = profileImageUrl;

    const result = await db.collection('users').updateOne(
      { _id: new ObjectId(userId) },
      { $set: updateFields }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ msg: 'User not found' });
    }

    const updatedUser = await db.collection('users').findOne({ _id: new ObjectId(userId) });
    const { password, ...userData } = updatedUser;
    
    res.json(userData);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server error' });
  }
});

module.exports = router;