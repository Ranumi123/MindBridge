const { ObjectId } = require('mongodb');
const { getDB } = require('../db');
const calComApi = require('../integrations/calendarConfig');

// Get available time slots for a therapist
exports.getAvailableSlots = async (req, res) => {
  try {
    console.log('Getting available time slots for therapist');
    const { therapistId, date } = req.query;
    
    if (!therapistId || !date) {
      return res.status(400).json({ message: 'Therapist ID and date are required' });
    }
    
    // Validate ObjectId format
    if (!ObjectId.isValid(therapistId)) {
      return res.status(400).json({ message: 'Invalid therapist ID format' });
    }
    
    // Get database connection and find therapist
    const db = getDB();
    const therapist = await db.collection('therapists').findOne({ _id: new ObjectId(therapistId) });
    
    if (!therapist) {
      return res.status(404).json({ message: 'Therapist not found' });
    }
    
    // Use Cal.com API to get available slots
    try {
      const availableSlots = await calComApi.getAvailableTimeSlots(
        therapist.calComUserId || 'default_cal_user_id',
        therapist.calComEventTypeId || 'default_cal_event_type_id',
        date
      );
      
      console.log(`Found ${availableSlots.length} available slots for therapist ${therapist.name}`);
      res.status(200).json(availableSlots);
    } catch (calError) {
      console.error('Cal.com API error:', calError);
      // Fall back to generated slots if Cal.com fails
      const generatedSlots = generateDefaultTimeSlots(date);
      res.status(200).json(generatedSlots);
    }
  } catch (error) {
    console.error('Error getting available slots:', error);
    res.status(400).json({ message: error.message });
  }
};

// Create new appointment
exports.createAppointment = async (req, res) => {
  try {
    console.log('Creating new appointment');
    const { therapistId, userId, startTime, endTime, name, email, notes } = req.body;
    
    if (!therapistId || !userId || !startTime || !endTime || !name || !email) {
      return res.status(400).json({ message: 'Missing required fields' });
    }
    
    // Validate ObjectId format
    if (!ObjectId.isValid(therapistId)) {
      return res.status(400).json({ message: 'Invalid therapist ID format' });
    }
    
    // Get database connection and find therapist
    const db = getDB();
    const therapist = await db.collection('therapists').findOne({ _id: new ObjectId(therapistId) });
    
    if (!therapist) {
      return res.status(404).json({ message: 'Therapist not found' });
    }
    
    // Calculate duration in minutes
    const start = new Date(startTime);
    const end = new Date(endTime);
    const durationMinutes = Math.round((end - start) / (1000 * 60));
    
    // Check if calComEventTypeId exists
    if (!therapist.calComEventTypeId) {
      console.warn(`Therapist ${therapist.name} does not have a calComEventTypeId`);
    }
    
    // Book appointment with Cal.com with improved error handling
    let calComBookingId;
    try {
      console.log('Booking Cal.com appointment with data:', {
        calComEventTypeId: therapist.calComEventTypeId || 'default_cal_event_type_id',
        name: name || 'Guest User',
        email: email || 'guest@example.com',
        startTime: startTime,
        endTime: endTime,
        timeZone: req.body.timeZone || 'UTC'
      });
      
      const calComBooking = await calComApi.createBooking(
        therapist.calComEventTypeId || 'default_cal_event_type_id', 
        {
          name: name || 'Guest User',
          email: email || 'guest@example.com',
          startTime: startTime,
          endTime: endTime,
          notes: notes || '',
          guests: [],
          timeZone: req.body.timeZone || 'UTC'
        }
      );
      calComBookingId = calComBooking.id;
      console.log('Successfully created Cal.com booking with ID:', calComBookingId);
    } catch (calError) {
      console.error('Cal.com booking error details:', {
        message: calError.message,
        response: calError.response?.data,
        stack: calError.stack
      });
      // Generate a mock booking ID if Cal.com fails
      calComBookingId = `mock_booking_${Date.now()}`;
      console.log('Using mock booking ID due to Cal.com error:', calComBookingId);
    }
    
    // Create appointment in our database
    const appointment = {
      user: userId,
      therapist: {
        _id: therapist._id,
        name: therapist.name || 'Unknown Therapist',
        specialty: therapist.specialty || 'General',
        imageUrl: therapist.imageUrl || ''
      },
      calComBookingId,
      appointmentTime: start,
      duration: durationMinutes,
      status: 'scheduled',
      notes: notes || '',
      createdAt: new Date()
    };
    
    const result = await db.collection('appointments').insertOne(appointment);
    const savedAppointment = {
      ...appointment,
      _id: result.insertedId
    };
    
    console.log(`Created appointment for ${name} with ${therapist.name}`);
    res.status(201).json(savedAppointment);
  } catch (error) {
    console.error('Error creating appointment:', error);
    res.status(400).json({ message: error.message });
  }
};

// Get appointment by ID
exports.getAppointmentById = async (req, res) => {
  try {
    console.log(`Getting appointment with ID: ${req.params.id}`);
    
    // Validate ObjectId format
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid appointment ID format' });
    }
    
    // Get database connection
    const db = getDB();
    const appointment = await db.collection('appointments').findOne({ _id: new ObjectId(req.params.id) });
    
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    
    console.log(`Found appointment for ${appointment.therapist.name}`);
    res.status(200).json(appointment);
  } catch (error) {
    console.error('Error getting appointment:', error);
    res.status(400).json({ message: error.message });
  }
};

// Get user's appointments
exports.getUserAppointments = async (req, res) => {
  try {
    console.log(`Getting appointments for user: ${req.params.userId}`);
    
    // Get database connection
    const db = getDB();
    const appointments = await db.collection('appointments')
      .find({ 'user': req.params.userId })
      .sort({ appointmentTime: 1 })
      .toArray();
    
    console.log(`Found ${appointments.length} appointments for user ${req.params.userId}`);
    res.status(200).json(appointments);
  } catch (error) {
    console.error('Error getting user appointments:', error);
    res.status(400).json({ message: error.message });
  }
};

// Cancel appointment
exports.cancelAppointment = async (req, res) => {
  try {
    console.log(`Cancelling appointment with ID: ${req.params.id}`);
    
    // Validate ObjectId format
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid appointment ID format' });
    }
    
    // Get database connection
    const db = getDB();
    const appointment = await db.collection('appointments').findOne({ _id: new ObjectId(req.params.id) });
    
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    
    // Cancel in Cal.com
    try {
      await calComApi.cancelBooking(appointment.calComBookingId);
      console.log('Appointment cancelled in Cal.com');
    } catch (calError) {
      console.error('Cal.com cancellation error:', calError);
      // Continue even if Cal.com fails
    }
    
    // Update in our database
    const result = await db.collection('appointments').updateOne(
      { _id: new ObjectId(req.params.id) },
      { 
        $set: { 
          status: 'cancelled',
          updatedAt: new Date()
        } 
      }
    );
    
    if (result.modifiedCount === 0) {
      return res.status(400).json({ message: 'Failed to update appointment status' });
    }
    
    console.log(`Appointment ${req.params.id} cancelled successfully`);
    res.status(200).json({ message: 'Appointment cancelled successfully' });
  } catch (error) {
    console.error('Error cancelling appointment:', error);
    res.status(400).json({ message: error.message });
  }
};

// Reschedule appointment
exports.rescheduleAppointment = async (req, res) => {
  try {
    console.log(`Rescheduling appointment with ID: ${req.params.id}`);
    const { id } = req.params;
    const { newStartTime, newEndTime } = req.body;
    
    if (!newStartTime || !newEndTime) {
      return res.status(400).json({ message: 'New start time and end time are required' });
    }
    
    // Validate ObjectId format
    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid appointment ID format' });
    }
    
    // Get database connection
    const db = getDB();
    const appointment = await db.collection('appointments').findOne({ _id: new ObjectId(id) });
    
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    
    // Calculate new duration in minutes
    const start = new Date(newStartTime);
    const end = new Date(newEndTime);
    const durationMinutes = Math.round((end - start) / (1000 * 60));
    
    // Reschedule in Cal.com
    try {
      await calComApi.rescheduleBooking(appointment.calComBookingId, newStartTime);
      console.log('Appointment rescheduled in Cal.com');
    } catch (calError) {
      console.error('Cal.com rescheduling error:', calError);
      // Continue even if Cal.com fails
    }
    
    // Update in our database
    const result = await db.collection('appointments').updateOne(
      { _id: new ObjectId(id) },
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
      return res.status(400).json({ message: 'Failed to update appointment' });
    }
    
    // Get the updated appointment
    const updatedAppointment = await db.collection('appointments').findOne({ _id: new ObjectId(id) });
    
    console.log(`Appointment ${id} rescheduled to ${start}`);
    res.status(200).json(updatedAppointment);
  } catch (error) {
    console.error('Error rescheduling appointment:', error);
    res.status(400).json({ message: error.message });
  }
};

// Helper function to generate default time slots if Cal.com API fails
function generateDefaultTimeSlots(dateString) {
  console.log('Generating default time slots');
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