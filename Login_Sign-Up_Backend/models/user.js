// models/User.js - User Model Functions
const { getDB, ObjectId } = require('../db');
const bcrypt = require('bcryptjs');

const usersCollection = () => getDB().collection('users');

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
  
  // Create user object with default values
  const newUser = {
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
    if (typeof userData.emergencyContact === 'string') {
      // If it's a string (phone number), add as formatted contact
      newUser.emergencyContacts.push({
        name: "Primary Emergency Contact",
        phone: userData.emergencyContact,
        relationship: "Not specified",
        isPrimary: true
      });
      console.log("Added emergency contact from string:", userData.emergencyContact);
    } else if (typeof userData.emergencyContact === 'object' && userData.emergencyContact !== null) {
      // If it's an object with phone property
      newUser.emergencyContacts.push({
        name: userData.emergencyContact.name || "Primary Emergency Contact",
        phone: userData.emergencyContact.phone,
        relationship: userData.emergencyContact.relationship || "Not specified",
        isPrimary: true
      });
      console.log("Added emergency contact from object:", userData.emergencyContact);
    }
  }
  
  // Log final structure before saving
  console.log("FINAL USER TO BE SAVED:", {
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
    name: savedUser.name,
    profile: savedUser.profile,
    emergencyContacts: savedUser.emergencyContacts
  });
  
  // Return user without password
  const { password: _, ...userWithoutPassword } = newUser;
  return { ...userWithoutPassword, _id: result.insertedId };
}

async function findUserById(userId) {
  // Convert string ID to ObjectId if necessary
  const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
  return usersCollection().findOne({ _id: id });
}

async function findUserByEmail(email) {
  return usersCollection().findOne({ email });
}

async function verifyPassword(user, password) {
  return bcrypt.compare(password, user.password);
}

async function updateUser(userId, updateData) {
  // Convert string ID to ObjectId if necessary
  const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
  
  return usersCollection().updateOne(
    { _id: id },
    { $set: updateData }
  );
}

async function updateEmergencyContacts(userId, contacts) {
  return updateUser(userId, { emergencyContacts: contacts });
}

async function addEmergencyContact(userId, contact) {
  // Convert string ID to ObjectId if necessary
  const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
  
  return usersCollection().updateOne(
    { _id: id },
    { $push: { emergencyContacts: contact } }
  );
}

async function updatePhone(userId, phone) {
  // Convert string ID to ObjectId if necessary
  const id = typeof userId === 'string' ? new ObjectId(userId) : userId;
  
  return usersCollection().updateOne(
    { _id: id },
    { $set: { "profile.phone": phone } }
  );
}

module.exports = {
  createUser,
  findUserById,
  findUserByEmail,
  verifyPassword,
  updateUser,
  updateEmergencyContacts,
  addEmergencyContact,
  updatePhone
};