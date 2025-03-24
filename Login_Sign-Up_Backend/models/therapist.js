const mongoose = require('mongoose');

const therapistSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  specialty: {
    type: String,
    required: true,
    trim: true
  },
  rating: {
    type: Number,
    default: 0
  },
  totalReviews: {
    type: Number,
    default: 0
  },
  description: {
    type: String,
    required: true
  },
  experience: {
    type: Number,
    required: true
  },
  clientsHelped: {
    type: Number,
    default: 0
  },
  imageUrl: {
    type: String,
    default: ""
  },
  isPopular: {
    type: Boolean,
    default: false
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  calComUserId: {
    type: String,
    required: true
  },
  calComEventTypeId: {
    type: String,
    required: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Therapist', therapistSchema);