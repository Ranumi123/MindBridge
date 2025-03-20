// models/User.js - User Model Functions
const { getDB, ObjectId } = require('../db');
const bcrypt = require('bcryptjs');

const usersCollection = () => getDB().collection('users');

async function createUser(userData) {
  const { email, password, name } = userData;
  
  // Check if user already exists
  const existingUser = await usersCollection().findOne({ email });
  if (existingUser) {
    throw new Error('User already exists');
  }
  
  // Hash password
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);
  
  // Create user object
  const newUser = {
    name,
    email,
    password: hashedPassword,
    createdAt: new Date(),
    emergencyContacts: [],
    profile: {
      bio: '',
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
  
  // Insert into database
  const result = await usersCollection().insertOne(newUser);
  
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

module.exports = {
  createUser,
  findUserById,
  findUserByEmail,
  verifyPassword,
  updateUser,
  updateEmergencyContacts
};