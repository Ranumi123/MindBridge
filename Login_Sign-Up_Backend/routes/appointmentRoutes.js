const express = require('express');
const { ObjectId } = require('mongodb'); // Add this import
const router = express.Router();
const { getDB } = require('../db'); // Add this import

// GET available time slots for a therapist
router.get('/available-slots', async (req, res) => {
  console.log('GET /api/appointments/available-slots request received');
  
  const { therapistId, date } = req.query;
  
  if (!therapistId || !date) {
    return res.status(400).json({ message: 'Both therapistId and date are required' });
  }
  
  // Validate ObjectId format
  if (!ObjectId.isValid(therapistId)) {
    return res.status(400).json({ message: 'Invalid therapist ID format' });
  }
  
  try {
    // First check if the therapist exists
    const db = getDB();
    const therapist = await db.collection('therapists').findOne({ _id: new ObjectId(therapistId) });
    
    if (!therapist) {
      return res.status(404).json({ message: 'Therapist not found' });
    }
    
    // Generate available time slots for the requested date
    const timeSlots = generateTimeSlots(date);
    
    console.log(`Generated ${timeSlots.length} time slots for therapist ${therapist.name} on ${date}`);
    res.json(timeSlots);
  } catch (error) {
    console.error('Error getting available slots:', error);
    res.status(500).json({ message: error.message });
  }
});

// POST create new appointment
router.post('/', async (req, res) => {
  console.log('POST /api/appointments request received');
  
  const { therapistId, userId, startTime, endTime, name, email, notes } = req.body;
  
  if (!therapistId || !userId || !startTime || !endTime || !name || !email) {
    return res.status(400).json({ message: 'Missing required fields' });
  }
  
  // Validate therapist ID
  if (!ObjectId.isValid(therapistId)) {
    return res.status(400).json({ message: 'Invalid therapist ID format' });
  }
  
  try {
    const db = getDB();
    
    // Check if therapist exists
    const therapist = await db.collection('therapists').findOne({ _id: new ObjectId(therapistId) });
    if (!therapist) {
      return res.status(404).json({ message: 'Therapist not found' });
    }
    
    // Calculate duration in minutes
    const start = new Date(startTime);
    const end = new Date(endTime);
    const durationMinutes = Math.round((end - start) / (1000 * 60));
    
    // Create new appointment
    const newAppointment = {
      userId,
      therapist: {
        _id: therapist._id,
        name: therapist.name,
        specialty: therapist.specialty,
        imageUrl: therapist.imageUrl
      },
      appointmentTime: start,
      duration: durationMinutes,
      status: 'scheduled',
      notes: notes || '',
      calComBookingId: `mock_booking_${Date.now()}`, // Mock ID for now
      createdAt: new Date()
    };
    
    const result = await db.collection('appointments').insertOne(newAppointment);
    
    console.log(`Created appointment for ${name} with ${therapist.name} at ${start}`);
    res.status(201).json({
      ...newAppointment,
      _id: result.insertedId
    });
  } catch (error) {
    console.error('Error creating appointment:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET appointment by ID
router.get('/:id', async (req, res) => {
  console.log(`GET /api/appointments/${req.params.id} request received`);
  
  if (!ObjectId.isValid(req.params.id)) {
    return res.status(400).json({ message: 'Invalid appointment ID format' });
  }
  
  try {
    const db = getDB();
    const appointment = await db.collection('appointments').findOne({ _id: new ObjectId(req.params.id) });
    
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    
    console.log(`Found appointment for ${appointment.therapist.name}`);
    res.json(appointment);
  } catch (error) {
    console.error('Error fetching appointment:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET user's appointments
router.get('/user/:userId', async (req, res) => {
  console.log(`GET /api/appointments/user/${req.params.userId} request received`);
  
  try {
    const db = getDB();
    const appointments = await db.collection('appointments')
      .find({ userId: req.params.userId })
      .sort({ appointmentTime: 1 })
      .toArray();
    
    console.log(`Found ${appointments.length} appointments for user ${req.params.userId}`);
    res.json(appointments);
  } catch (error) {
    console.error('Error fetching user appointments:', error);
    res.status(500).json({ message: error.message });
  }
});

// PUT cancel appointment
router.put('/cancel/:id', async (req, res) => {
  console.log(`PUT /api/appointments/cancel/${req.params.id} request received`);
  
  if (!ObjectId.isValid(req.params.id)) {
    return res.status(400).json({ message: 'Invalid appointment ID format' });
  }
  
  try {
    const db = getDB();
    
    // Find the appointment first
    const appointment = await db.collection('appointments').findOne({ _id: new ObjectId(req.params.id) });
    
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    
    // Update the appointment status
    const result = await db.collection('appointments').updateOne(
      { _id: new ObjectId(req.params.id) },
      { $set: { status: 'cancelled', updatedAt: new Date() } }
    );
    
    if (result.modifiedCount === 0) {
      return res.status(400).json({ message: 'Failed to cancel appointment' });
    }
    
    console.log(`Cancelled appointment ${req.params.id}`);
    res.json({ message: 'Appointment cancelled successfully' });
  } catch (error) {
    console.error('Error cancelling appointment:', error);
    res.status(500).json({ message: error.message });
  }
});

// PUT reschedule appointment
router.put('/reschedule/:id', async (req, res) => {
  console.log(`PUT /api/appointments/reschedule/${req.params.id} request received`);
  
  const { newStartTime, newEndTime } = req.body;
  
  if (!newStartTime || !newEndTime) {
    return res.status(400).json({ message: 'New start time and end time are required' });
  }
  
  if (!ObjectId.isValid(req.params.id)) {
    return res.status(400).json({ message: 'Invalid appointment ID format' });
  }
  
  try {
    const db = getDB();
    
    // Find the appointment first
    const appointment = await db.collection('appointments').findOne({ _id: new ObjectId(req.params.id) });
    
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    
    // Calculate new duration
    const start = new Date(newStartTime);
    const end = new Date(newEndTime);
    const durationMinutes = Math.round((end - start) / (1000 * 60));
    
    // Update the appointment
    const result = await db.collection('appointments').updateOne(
      { _id: new ObjectId(req.params.id) },
      { 
        $set: { 
          appointmentTime: start,
          duration: durationMinutes,
          status: 'rescheduled',
          updatedAt: new Date()
        } 
      }
    );
    
    if (result.modifiedCount === 0) {
      return res.status(400).json({ message: 'Failed to reschedule appointment' });
    }
    
    // Get the updated appointment
    const updatedAppointment = await db.collection('appointments').findOne({ _id: new ObjectId(req.params.id) });
    
    console.log(`Rescheduled appointment ${req.params.id} to ${start}`);
    res.json(updatedAppointment);
  } catch (error) {
    console.error('Error rescheduling appointment:', error);
    res.status(500).json({ message: error.message });
  }
});

// Helper function to generate time slots
function generateTimeSlots(dateString) {
  const date = new Date(dateString);
  const timeSlots = [];
  
  // Generate slots from 9 AM to 5 PM with 1-hour intervals
  for (let hour = 9; hour < 17; hour++) {
    const startTime = new Date(date);
    startTime.setHours(hour, 0, 0, 0);
    
    const endTime = new Date(date);
    endTime.setHours(hour + 1, 0, 0, 0);
    
    timeSlots.push({
      startTime: startTime.toISOString(),
      endTime: endTime.toISOString()
    });
  }
  
  return timeSlots;
}

module.exports = router;