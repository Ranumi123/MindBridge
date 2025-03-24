const Therapist = require('../models/therapist');

// Get all therapists
exports.getAllTherapists = async (req, res) => {
    try {
      console.log("Getting all therapists...");
      // Add a limit to prevent excessive data retrieval
      const therapists = await Therapist.find({}).limit(20).lean();
      console.log(`Found ${therapists.length} therapists`);
      res.status(200).json(therapists);
    } catch (error) {
      console.error("Error getting therapists:", error);
      res.status(400).json({ message: error.message });
    }
  };

// Get popular therapists
exports.getPopularTherapists = async (req, res) => {
  try {
    const popularTherapists = await Therapist.find({ isPopular: true }).sort({ rating: -1 });
    res.status(200).json(popularTherapists);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get available therapists
exports.getAvailableTherapists = async (req, res) => {
  try {
    const availableTherapists = await Therapist.find({ isAvailable: true }).sort({ rating: -1 });
    res.status(200).json(availableTherapists);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get therapist by ID
exports.getTherapistById = async (req, res) => {
  try {
    const therapist = await Therapist.findById(req.params.id);
    
    if (!therapist) {
      return res.status(404).json({ message: 'Therapist not found' });
    }
    
    res.status(200).json(therapist);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Search therapists by name or specialty
exports.searchTherapists = async (req, res) => {
  try {
    const keyword = req.query.keyword 
      ? {
          $or: [
            { name: { $regex: req.query.keyword, $options: 'i' } },
            { specialty: { $regex: req.query.keyword, $options: 'i' } }
          ]
        } 
      : {};
    
    const therapists = await Therapist.find({ ...keyword });
    res.status(200).json(therapists);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Create new therapist (for admin use)
exports.createTherapist = async (req, res) => {
  try {
    const therapist = new Therapist(req.body);
    const savedTherapist = await therapist.save();
    res.status(201).json(savedTherapist);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};