const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const users = []; // Temporary user storage

// Signup Function
exports.signup = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Check if user already exists
    if (users.some(user => user.email === email)) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    // Hash password before storing
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create and store user
    const newUser = { id: users.length + 1, name, email, password: hashedPassword };
    users.push(newUser);

    console.log("User registered:", newUser); // Debugging
    res.status(201).json({ msg: 'User registered successfully' });
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({ error: error.message });
  }
};

// Login Function
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log("Login attempt:", email);

    // Find user
    const user = users.find(user => user.email === email);
    if (!user) {
      console.log("User not found");
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    console.log("User found:", user);

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log("Password mismatch");
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    console.log("Login successful!");

    // Generate JWT token
    const token = jwt.sign({ userId: user.id }, "your_jwt_secret", { expiresIn: '1h' });

    res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: error.message });
  }
};
