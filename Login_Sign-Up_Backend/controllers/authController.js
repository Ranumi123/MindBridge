// controllers/authController.js
const jwt = require('jsonwebtoken');
const {
  createUser,
  findUserByEmail,
  verifyPassword
} = require('../models/user');

// Signup Function
exports.signup = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        msg: 'Please provide name, email and password'
      });
    }
    
    // Create user in database
    const newUser = await createUser({ name, email, password });
    
    console.log("User registered:", email);
    
    // Return success without sensitive data
    res.status(201).json({
      success: true,
      msg: 'User registered successfully',
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email
      }
    });
    
  } catch (error) {
    console.error("Signup error:", error);
    
    // Handle duplicate email error
    if (error.message === 'User already exists') {
      return res.status(400).json({
        success: false,
        msg: 'Email already registered'
      });
    }
    
    res.status(500).json({
      success: false,
      msg: 'Server error during registration',
      error: error.message
    });
  }
};

// Login Function
exports.login = async (req, res) => {
  try {
    // Ensure req.body exists
    if (!req.body) {
      console.error("Request body is undefined");
      return res.status(400).json({
        success: false,
        msg: 'Invalid request format'
      });
    }

    const { email, password } = req.body;
    
    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        msg: 'Please provide email and password'
      });
    }
    
    console.log("Login attempt:", email);
    
    // Find user by email
    const user = await findUserByEmail(email);
    if (!user) {
      console.log("User not found:", email);
      return res.status(401).json({
        success: false,
        msg: 'Invalid credentials'
      });
    }
    
    // Verify password
    const isMatch = await verifyPassword(user, password);
    if (!isMatch) {
      console.log("Password mismatch for:", email);
      return res.status(401).json({
        success: false,
        msg: 'Invalid credentials'
      });
    }
    
    console.log("Login successful for:", email);
    
    // Generate JWT token with fallback secret
    const secret = process.env.JWT_SECRET || 'your_jwt_secret';
    const token = jwt.sign(
      { userId: user._id },
      secret,
      { expiresIn: '24h' }
    );
    
    // Send response with token and user info
    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email
      }
    });
    
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      success: false,
      msg: 'Server error during login',
      error: error.message
    });
  }
};