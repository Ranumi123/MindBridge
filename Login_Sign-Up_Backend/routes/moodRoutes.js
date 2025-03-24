// routes/moodRoutes.js
const express = require('express');
const router = express.Router();
const moodController = require('../controllers/moodController');

// Get weekly mood data
router.get('/weekly', moodController.getWeeklyMoods);

// Add a new mood entry (will check if user already has a mood for today)
router.post('/', moodController.addMood);

// Check if user has a mood for today
router.get('/today', moodController.checkTodayMood);

// Update today's mood (allows changing today's mood)
router.put('/today', moodController.updateTodayMood);

// Clear all mood entries for a user
router.delete('/', moodController.clearMoods);

// Get mood history (paginated)
router.get('/history', moodController.getMoodHistory);

// Debug route to check database connection
router.get('/debug', moodController.debugConnection);

module.exports = router;