const jwt = require('jsonwebtoken');
const {
  createUser,
  findUserByEmail,
  verifyPassword
} = require('../models/user');

// Signup Function
exports.signup = async (req, res) => {
  try {
    const { name, email, password, phone, emergencyContact } = req.body;
    
    // Log raw incoming data
    console.log("Raw signup data received:", req.body);
    
    // Validate input
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        msg: 'Please provide name, email and password'
      });
    }
    
    // Create user data object with required fields
    const userData = { 
      name, 
      email, 
      password,
      // Initialize profile with phone if provided
      profile: {
        bio: "",
        phone: phone || ""
      },
      // Initialize emergencyContacts array
      emergencyContacts: []
    };
    
    console.log("Phone value received:", phone);
    
    // Handle emergency contact information - support both string and object formats
    if (emergencyContact) {
      // Log the emergency contact data received
      console.log("Emergency contact received:", typeof emergencyContact, emergencyContact);
      
      // Handle different formats of emergency contact data
      if (typeof emergencyContact === 'string' && emergencyContact.trim() !== '') {
        // If it's just a string (phone number), format it as an object
        const formattedContact = {
          name: "Emergency Contact",
          phone: emergencyContact.trim(),
          relationship: "Not specified",
          isPrimary: true
        };
        
        userData.emergencyContacts.push(formattedContact);
        console.log("Added emergency contact from string:", formattedContact);
      } 
      else if (typeof emergencyContact === 'object' && emergencyContact !== null && emergencyContact.phone) {
        // If it's already an object with a phone property
        const formattedContact = {
          name: emergencyContact.name || "Emergency Contact",
          phone: emergencyContact.phone,
          relationship: emergencyContact.relationship || "Not specified",
          isPrimary: true
        };
        
        userData.emergencyContacts.push(formattedContact);
        console.log("Added emergency contact from object:", formattedContact);
      }
    }
    
    // Log the final user data being created
    console.log("Creating user with data:", {
      name: userData.name,
      email: userData.email,
      profile: userData.profile,
      emergencyContacts: userData.emergencyContacts
    });
    
    // Create user in database with all fields
    const newUser = await createUser(userData);
    
    console.log("User registered successfully:", {
      id: newUser._id,
      name: newUser.name,
      profile: newUser.profile,
      emergencyContacts: newUser.emergencyContacts ? 
        `${newUser.emergencyContacts.length} contact(s)` : 
        "No contacts found"
    });
    
    // Return success without sensitive data
    res.status(201).json({
      success: true,
      msg: 'User registered successfully',
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        phone: newUser.profile?.phone || "",
        emergencyContacts: newUser.emergencyContacts || [],
        hasEmergencyContact: newUser.emergencyContacts && newUser.emergencyContacts.length > 0
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
    
    // Log user data for debugging
    console.log("User profile data:", {
      name: user.name,
      profile: user.profile || {},
      emergencyContacts: user.emergencyContacts ? 
        `${user.emergencyContacts.length} contact(s)` : 
        "No contacts"
    });
    
    // Generate JWT token with fallback secret
    const secret = process.env.JWT_SECRET || 'your_jwt_secret';
    const token = jwt.sign(
      { userId: user._id },
      secret,
      { expiresIn: '24h' }
    );
    
    // Send response with token and user info including emergency contacts
    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.profile?.phone || "",
        emergencyContacts: user.emergencyContacts || [],
        hasEmergencyContact: user.emergencyContacts && user.emergencyContacts.length > 0
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