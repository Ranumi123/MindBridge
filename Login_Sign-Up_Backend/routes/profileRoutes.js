// routes/profileRoutes.js

const express = require("express");
const profileController = require("../controllers/profileController");

const router = express.Router();

// Profile routes
router.get("/", profileController.getProfile); // GET /api/profile
router.put("/", profileController.updateProfile); // PUT /api/profile
router.put("/preferences", profileController.updatePreferences); // PUT /api/profile/preferences
router.put("/privacy-settings", profileController.updatePrivacySettings); // PUT /api/profile/privacy-settings

module.exports = router;