// controllers/profileController.js

// In-memory storage for user profile and preferences
let userProfile = {
  id: 1,
  name: "John Doe",
  bio: "Mental Health Advocate | Lover of Mindfulness",
  profilePicture: "https://via.placeholder.com/150",
  preferences: {
    enableNotifications: true,
    anonymousMode: false,
  },
  privacySettings: {
    allowDataSharing: true,
    enableEncryption: true,
  },
};

// Get user profile
exports.getProfile = (req, res) => {
  res.json(userProfile);
};

// Update user profile
exports.updateProfile = (req, res) => {
  const { name, bio, profilePicture } = req.body;

  if (name) userProfile.name = name;
  if (bio) userProfile.bio = bio;
  if (profilePicture) userProfile.profilePicture = profilePicture;

  res.json({ message: "Profile updated successfully", userProfile });
};

// Update preferences
exports.updatePreferences = (req, res) => {
  const { enableNotifications, anonymousMode } = req.body;

  if (enableNotifications !== undefined)
    userProfile.preferences.enableNotifications = enableNotifications;
  if (anonymousMode !== undefined)
    userProfile.preferences.anonymousMode = anonymousMode;

  res.json({ message: "Preferences updated successfully", userProfile });
};

// Update privacy settings
exports.updatePrivacySettings = (req, res) => {
  const { allowDataSharing, enableEncryption } = req.body;

  if (allowDataSharing !== undefined)
    userProfile.privacySettings.allowDataSharing = allowDataSharing;
  if (enableEncryption !== undefined)
    userProfile.privacySettings.enableEncryption = enableEncryption;

  res.json({ message: "Privacy settings updated successfully", userProfile });
};