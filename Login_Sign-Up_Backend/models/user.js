// models/User.js - User Model Functions
const { getDB, ObjectId } = require('../db');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const usersCollection = () => getDB().collection('users');

// Helper function to generate a consistent userId from email
function generateUserId(email) {
  // Create a consistent hash from the email
  return `user_${crypto.createHash('md5').update(email.toLowerCase().trim()).digest('hex')}`;
}

async function createUser(userData) {
  const { email, password, name } = userData;
  
  // Log the complete incoming userData for debugging
  console.log("FULL USER DATA RECEIVED:", JSON.stringify(userData, null, 2));
  
  // Check if user already exists
  const existingUser = await usersCollection().findOne({ email });
  if (existingUser) {
    throw new Error('User already exists');
  }
  
  // Hash password
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);
  
  // Generate a consistent userId based on email
  const userId = userData.userId || generateUserId(email);
  
  // Create user object with default values
  const newUser = {
    userId, // Include consistent userId
    name,
    email,
    password: hashedPassword,
    createdAt: new Date(),
    emergencyContacts: [],
    profile: {
      bio: '',
      phone: ''
    },
    preferences: {
      enableNotifications: true,
      anonymousMode: false,
    },
    privacySettings: {
      allowDataSharing: true,
      enableEncryption: true,
    },
    profilePicture: "https://via.placeholder.com/150"
  };
  
  // Set phone from userData
  if (userData.profile && userData.profile.phone) {
    // If phone is in profile object
    newUser.profile.phone = userData.profile.phone;
    console.log("Setting phone from profile:", userData.profile.phone);
  } else if (userData.phone) {
    // If phone is direct property
    newUser.profile.phone = userData.phone;
    console.log("Setting phone from direct property:", userData.phone);
  }
  
  // Handle emergencyContacts
  if (userData.emergencyContacts && Array.isArray(userData.emergencyContacts) && userData.emergencyContacts.length > 0) {
    // If emergencyContacts is already an array, use it
    newUser.emergencyContacts = userData.emergencyContacts;
    console.log("Using provided emergencyContacts array:", userData.emergencyContacts);
  } else if (userData.emergencyContact) {
    // Handle single emergencyContact (could be string or object)
    if (typeof userData.emergencyContact === 'string' && userData.emergencyContact.trim() !== '') {
      // If it's a string (phone number), add as formatted contact
      newUser.emergencyContacts.push({
        name: "Primary Emergency Contact",
        phone: userData.emergencyContact.trim(),
        relationship: "Not specified",
        isPrimary: true
      });
      console.log("Added emergency contact from string:", userData.emergencyContact);
    } else if (typeof userData.emergencyContact === 'object' && userData.emergencyContact !== null) {
      // If it's an object with phone property
      if (userData.emergencyContact.phone) {
        newUser.emergencyContacts.push({
          name: userData.emergencyContact.name || "Primary Emergency Contact",
          phone: userData.emergencyContact.phone,
          relationship: userData.emergencyContact.relationship || "Not specified",
          isPrimary: true
        });
        console.log("Added emergency contact from object:", userData.emergencyContact);
      }
    }
  }
  
  // Log final structure before saving
  console.log("FINAL USER TO BE SAVED:", {
    userId: newUser.userId,
    name: newUser.name,
    email: newUser.email,
    profile: newUser.profile,
    emergencyContacts: newUser.emergencyContacts
  });
  
  // Insert into database
  const result = await usersCollection().insertOne(newUser);
  
  // Verify the saved user by retrieving it
  const savedUser = await usersCollection().findOne({ _id: result.insertedId });
  console.log("VERIFIED SAVED USER:", {
    userId: savedUser.userId,
    name: savedUser.name,
    profile: savedUser.profile,
    emergencyContacts: savedUser.emergencyContacts
  });
  
  // Return user without password
  const { password: _, ...userWithoutPassword } = newUser;
  return { ...userWithoutPassword, _id: result.insertedId };
}

async function findUserById(userId) {
  // Check if the userId is a consistent ID or ObjectId
  if (userId && typeof userId === 'string' && userId.startsWith('user_')) {
    return usersCollection().findOne({ userId });
  }
  
  // If not a consistent ID, treat as ObjectId
  try {
    const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
    return usersCollection().findOne({ _id: id });
  } catch (error) {
    console.error("Invalid ObjectId format:", userId);
    return null;
  }
}

async function findUserByEmail(email) {
  return usersCollection().findOne({ email });
}

async function verifyPassword(user, password) {
  return bcrypt.compare(password, user.password);
}

async function updateUser(userId, updateData) {
  // Check if the userId is a consistent ID or ObjectId
  if (userId && typeof userId === 'string' && userId.startsWith('user_')) {
    return usersCollection().updateOne(
      { userId },
      { $set: updateData }
    );
  }
  
  // If not a consistent ID, treat as ObjectId
  try {
    const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
    return usersCollection().updateOne(
      { _id: id },
      { $set: updateData }
    );
  } catch (error) {
    console.error("Invalid ObjectId format:", userId);
    return { modifiedCount: 0, matchedCount: 0 };
  }
}

async function updateEmergencyContacts(userId, contacts) {
  return updateUser(userId, { emergencyContacts: contacts });
}

async function addEmergencyContact(userId, contact) {
  // Check if the userId is a consistent ID or ObjectId
  if (userId && typeof userId === 'string' && userId.startsWith('user_')) {
    return usersCollection().updateOne(
      { userId },
      { $push: { emergencyContacts: contact } }
    );
  }
  
  // If not a consistent ID, treat as ObjectId
  try {
    const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
    return usersCollection().updateOne(
      { _id: id },
      { $push: { emergencyContacts: contact } }
    );
  } catch (error) {
    console.error("Invalid ObjectId format:", userId);
    return { modifiedCount: 0, matchedCount: 0 };
  }
}

async function updatePhone(userId, phone) {
  // Check if the userId is a consistent ID or ObjectId
  if (userId && typeof userId === 'string' && userId.startsWith('user_')) {
    return usersCollection().updateOne(
      { userId },
      { $set: { "profile.phone": phone } }
    );
  }
  
  // If not a consistent ID, treat as ObjectId
  try {
    const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
    return usersCollection().updateOne(
      { _id: id },
      { $set: { "profile.phone": phone } }
    );
  } catch (error) {
    console.error("Invalid ObjectId format:", userId);
    return { modifiedCount: 0, matchedCount: 0 };
  }
}

// Add migration function to ensure all users have a userId
async function migrateUsers() {
  const users = await usersCollection().find({ userId: { $exists: false } }).toArray();
  
  let migratedCount = 0;
  for (const user of users) {
    if (user.email) {
      const userId = generateUserId(user.email);
      await usersCollection().updateOne(
        { _id: user._id },
        { $set: { userId } }
      );
      console.log(`Added userId ${userId} to user ${user.email}`);
      migratedCount++;
    } else {
      console.warn(`User ${user._id} has no email, cannot generate userId`);
    }
  }
  
  console.log(`Migration completed: ${migratedCount} users updated`);
  return migratedCount;
}

module.exports = {
  createUser,
  findUserById,
  findUserByEmail,
  verifyPassword,
  updateUser,
  updateEmergencyContacts,
  addEmergencyContact,
  updatePhone,
  generateUserId,
  migrateUsers
};