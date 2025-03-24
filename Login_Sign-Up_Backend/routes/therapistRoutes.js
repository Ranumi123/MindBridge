const express = require('express');
const { ObjectId } = require('mongodb'); // Import ObjectId
const router = express.Router();
const { getDB } = require('../db'); // Ensure this is correctly imported

// GET all therapists
router.get('/', async (req, res) => {
  console.log('GET /api/therapists request received'); // Log the request
  try {
    const db = getDB(); // Get the database connection
    const therapists = await db.collection('therapists')
      .find({})
      .maxTimeMS(30000) // Increase timeout to 30 seconds
      .toArray(); // Fetch all therapists
    console.log(`Fetched ${therapists.length} therapists`); // Log the result
    res.json(therapists); // Send the response
  } catch (error) {
    console.error('Error fetching therapists:', error); // Log the error
    res.status(500).json({ error: 'Failed to fetch therapists', details: error.message }); // Send error response
  }
});

// GET popular therapists
router.get('/popular', async (req, res) => {
  console.log('GET /api/therapists/popular request received');
  try {
    const db = getDB();
    const therapists = await db.collection('therapists')
      .find({ isPopular: true })
      .maxTimeMS(30000)
      .toArray();
    console.log(`Fetched ${therapists.length} popular therapists`);
    res.json(therapists);
  } catch (error) {
    console.error('Error fetching popular therapists:', error);
    res.status(500).json({ error: 'Failed to fetch popular therapists', details: error.message });
  }
});

// GET available therapists
router.get('/available', async (req, res) => {
  console.log('GET /api/therapists/available request received');
  try {
    const db = getDB();
    const therapists = await db.collection('therapists')
      .find({ isAvailable: true })
      .maxTimeMS(30000)
      .toArray();
    console.log(`Fetched ${therapists.length} available therapists`);
    res.json(therapists);
  } catch (error) {
    console.error('Error fetching available therapists:', error);
    res.status(500).json({ error: 'Failed to fetch available therapists', details: error.message });
  }
});

// Search therapists by name or specialty
router.get('/search', async (req, res) => {
  const { keyword } = req.query;
  console.log(`GET /api/therapists/search?keyword=${keyword} request received`);
  
  if (!keyword) {
    return res.status(400).json({ error: 'Keyword is required for search' });
  }
  
  try {
    const db = getDB();
    const therapists = await db.collection('therapists')
      .find({
        $or: [
          { name: { $regex: keyword, $options: 'i' } },
          { specialty: { $regex: keyword, $options: 'i' } }
        ]
      })
      .maxTimeMS(30000)
      .toArray();
    
    console.log(`Found ${therapists.length} therapists matching "${keyword}"`);
    res.json(therapists);
  } catch (error) {
    console.error('Error searching therapists:', error);
    res.status(500).json({ error: 'Failed to search therapists', details: error.message });
  }
});

// GET a therapist by ID
router.get('/:id', async (req, res) => {
  const therapistId = req.params.id;
  console.log(`GET /api/therapists/${therapistId} request received`);
  
  // Validate ObjectId format
  if (!ObjectId.isValid(therapistId)) {
    console.log(`Invalid therapist ID format: ${therapistId}`);
    return res.status(400).json({ error: 'Invalid therapist ID format' });
  }

  try {
    const db = getDB(); // Get the database connection
    const therapist = await db.collection('therapists')
      .findOne({ _id: new ObjectId(therapistId) });
    
    if (!therapist) {
      console.log(`Therapist with ID ${therapistId} not found`);
      return res.status(404).json({ error: 'Therapist not found' });
    }
    
    console.log(`Fetched therapist: ${therapist.name}`);
    res.json(therapist);
  } catch (error) {
    console.error('Error fetching therapist:', error);
    res.status(500).json({ error: 'Failed to fetch therapist', details: error.message });
  }
});

// POST create a new therapist
router.post('/', async (req, res) => {
  console.log('POST /api/therapists request received');
  try {
    const db = getDB();
    
    // Validate required fields
    const requiredFields = ['name', 'specialty', 'description', 'experience'];
    const missingFields = requiredFields.filter(field => !req.body[field]);
    
    if (missingFields.length > 0) {
      return res.status(400).json({ 
        error: 'Missing required fields', 
        missingFields 
      });
    }
    
    // Create new therapist with default values for optional fields
    const newTherapist = {
      name: req.body.name,
      specialty: req.body.specialty,
      rating: req.body.rating || 0,
      totalReviews: req.body.totalReviews || 0,
      description: req.body.description,
      experience: req.body.experience,
      clientsHelped: req.body.clientsHelped || 0,
      imageUrl: req.body.imageUrl || '',
      isPopular: req.body.isPopular || false,
      isAvailable: req.body.isAvailable || true,
      calComUserId: req.body.calComUserId || 'default_cal_user_id',
      calComEventTypeId: req.body.calComEventTypeId || 'default_cal_event_type_id',
      createdAt: new Date()
    };
    
    const result = await db.collection('therapists').insertOne(newTherapist);
    
    // Return the created therapist with its ID
    console.log(`Created new therapist: ${newTherapist.name} with ID ${result.insertedId}`);
    res.status(201).json({ 
      ...newTherapist, 
      _id: result.insertedId 
    });
  } catch (error) {
    console.error('Error creating therapist:', error);
    res.status(500).json({ error: 'Failed to create therapist', details: error.message });
  }
});

module.exports = router;