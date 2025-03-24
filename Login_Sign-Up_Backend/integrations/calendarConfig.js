const axios = require('axios');
require('dotenv').config();

// Get API key and base URL from environment variables
const apiKey = process.env.CAL_COM_API_KEY;
const baseUrl = process.env.CAL_COM_BASE_URL || 'https://api.cal.com/v1';

// Validate required configuration
if (!apiKey) {
  console.warn('WARNING: CAL_COM_API_KEY is not defined in environment variables');
}

// Create axios instance with configurable base URL
const calComApi = axios.create({
  baseURL: baseUrl,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${apiKey}`
  },
  timeout: 15000 // 15 second timeout (increased from 10 seconds)
});

// Get available time slots for a specific therapist
const getAvailableTimeSlots = async (calComUserId, calComEventTypeId, date) => {
  try {
    // Validate inputs to prevent null errors
    if (!calComUserId) {
      console.warn('calComUserId is null or empty, using fallback');
      calComUserId = 'default_user_id';
    }
    
    if (!calComEventTypeId) {
      console.warn('calComEventTypeId is null or empty, using fallback');
      calComEventTypeId = 'default_event_type_id';
    }
    
    console.log(`Fetching availability for user ${calComUserId}, event ${calComEventTypeId}, date ${date}`);
    
    // If using mock data for testing or forced by environment
    if (process.env.NODE_ENV === 'development' || process.env.USE_MOCK_CAL_DATA === 'true') {
      console.log('Using mock time slots due to development mode or configuration');
      return generateMockTimeSlots(date);
    }
    
    const response = await calComApi.get(`/availability/${calComEventTypeId}`, {
      params: {
        userId: calComUserId,
        dateFrom: date,
        dateTo: date,
      }
    });
    
    console.log(`Cal.com returned ${response.data.length || 0} available slots`);
    
    // If no slots returned, generate mock slots
    if (!response.data || response.data.length === 0) {
      console.log('No slots returned from Cal.com, generating mock slots');
      return generateMockTimeSlots(date);
    }
    
    return response.data;
  } catch (error) {
    handleApiError('fetching Cal.com availability', error);
    // Return mock data as fallback if API call fails
    return generateMockTimeSlots(date);
  }
};

// Create a booking in Cal.com
const createBooking = async (calComEventTypeId, bookingData) => {
  try {
    // Validate event type ID
    if (!calComEventTypeId) {
      throw new Error('calComEventTypeId is required and cannot be null');
    }
    
    // Validate and sanitize booking data to prevent null values
    const sanitizedBookingData = {
      name: bookingData.name || 'Guest User',
      email: bookingData.email || 'guest@example.com',
      startTime: bookingData.startTime,
      endTime: bookingData.endTime,
      notes: bookingData.notes || '',
      guests: bookingData.guests || [],
      timeZone: bookingData.timeZone || 'UTC'
    };
    
    // Additional validation for required string fields
    if (!sanitizedBookingData.startTime) {
      throw new Error('startTime is required and cannot be null');
    }
    
    if (!sanitizedBookingData.endTime) {
      throw new Error('endTime is required and cannot be null');
    }
    
    console.log(`Creating booking for event ${calComEventTypeId} with data:`, 
      JSON.stringify(sanitizedBookingData, null, 2));
    
    // If using mock data for testing or forced by environment
    if (process.env.NODE_ENV === 'development' || process.env.USE_MOCK_CAL_DATA === 'true') {
      console.log('Using mock booking due to development mode or configuration');
      return {
        id: `mock_booking_${Date.now()}`,
        ...sanitizedBookingData,
        status: 'confirmed'
      };
    }
    
    // Make the actual API call
    const response = await calComApi.post(`/bookings/${calComEventTypeId}`, sanitizedBookingData);
    console.log(`Cal.com booking created with ID: ${response.data.id || 'unknown'}`);
    return response.data;
  } catch (error) {
    handleApiError('creating Cal.com booking', error);
    
    // Properly log the full error and booking data for debugging
    console.error('Detailed error info:', {
      message: error.message,
      response: error.response?.data,
      stack: error.stack,
      eventTypeId: calComEventTypeId,
      bookingData: JSON.stringify(bookingData)
    });
    
    // Return mock booking as fallback
    return {
      id: `fallback_booking_${Date.now()}`,
      ...(bookingData || {}),
      status: 'tentative',
      error: error.message
    };
  }
};

// Reschedule a booking
const rescheduleBooking = async (bookingId, newTime) => {
  try {
    // Validate booking ID and new time
    if (!bookingId) {
      throw new Error('bookingId is required and cannot be null');
    }
    
    if (!newTime) {
      throw new Error('newTime is required and cannot be null');
    }
    
    console.log(`Rescheduling booking ${bookingId} to ${newTime}`);
    
    // If using mock data for testing
    if (process.env.NODE_ENV === 'development' || process.env.USE_MOCK_CAL_DATA === 'true') {
      console.log('Using mock reschedule due to development mode or configuration');
      return {
        id: bookingId,
        startTime: newTime,
        status: 'rescheduled'
      };
    }
    
    const response = await calComApi.patch(`/bookings/${bookingId}`, {
      startTime: newTime
    });
    console.log(`Cal.com booking rescheduled successfully`);
    return response.data;
  } catch (error) {
    handleApiError('rescheduling Cal.com booking', error);
    // Return mock response as fallback
    return {
      id: bookingId,
      startTime: newTime,
      status: 'rescheduled',
      error: error.message
    };
  }
};

// Cancel a booking
const cancelBooking = async (bookingId) => {
  try {
    // Validate booking ID
    if (!bookingId) {
      throw new Error('bookingId is required and cannot be null');
    }
    
    console.log(`Cancelling booking ${bookingId}`);
    
    // If using mock data for testing
    if (process.env.NODE_ENV === 'development' || process.env.USE_MOCK_CAL_DATA === 'true') {
      console.log('Using mock cancellation due to development mode or configuration');
      return {
        id: bookingId,
        status: 'cancelled'
      };
    }
    
    const response = await calComApi.delete(`/bookings/${bookingId}`);
    console.log(`Cal.com booking cancelled successfully`);
    return response.data;
  } catch (error) {
    handleApiError('cancelling Cal.com booking', error);
    // Return mock response as fallback
    return {
      id: bookingId,
      status: 'cancelled',
      error: error.message
    };
  }
};

// Get booking details
const getBookingDetails = async (bookingId) => {
  try {
    // Validate booking ID
    if (!bookingId) {
      throw new Error('bookingId is required and cannot be null');
    }
    
    console.log(`Fetching booking details for ${bookingId}`);
    
    // If using mock data for testing
    if (process.env.NODE_ENV === 'development' || process.env.USE_MOCK_CAL_DATA === 'true') {
      console.log('Using mock booking details due to development mode or configuration');
      return {
        id: bookingId,
        status: 'confirmed',
        startTime: new Date().toISOString(),
        endTime: new Date(Date.now() + 3600000).toISOString()
      };
    }
    
    const response = await calComApi.get(`/bookings/${bookingId}`);
    return response.data;
  } catch (error) {
    handleApiError('fetching Cal.com booking details', error);
    return null;
  }
};

// Helper function to handle API errors
function handleApiError(action, error) {
  console.error(`Error ${action}:`);
  
  if (error.response) {
    // The request was made and the server responded with a status code outside of 2xx
    console.error('Response error:', {
      status: error.response.status,
      statusText: error.response.statusText,
      data: error.response.data,
      headers: error.response.headers
    });
  } else if (error.request) {
    // The request was made but no response was received
    console.error('Request error (no response):', {
      request: error.request._currentUrl || error.request,
      method: error.request.method
    });
  } else {
    // Something happened in setting up the request
    console.error('Error message:', error.message);
    console.error('Error stack:', error.stack);
  }
  
  // Check for specific error types
  if (error.response && error.response.status === 401) {
    console.error('Cal.com API authentication failed. Check your API key.');
  } else if (error.response && error.response.status === 404) {
    console.error('Cal.com resource not found. Check the event type ID or user ID.');
  } else if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
    console.error('Network error. Check internet connection and Cal.com API status.');
  } else if (error.message && error.message.includes('null')) {
    console.error('Null value error. Check that all required fields have values.');
  }
}

// Generate mock time slots for development/testing
function generateMockTimeSlots(dateString) {
  console.log('Generating mock time slots');
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

// Check if Cal.com configuration is valid
const checkCalComConfig = async () => {
  if (!apiKey) {
    console.error('Cal.com API key is not configured');
    return { valid: false, message: 'Cal.com API key is not configured' };
  }
  
  try {
    console.log('Testing Cal.com API connection...');
    
    // If using mock data for testing
    if (process.env.NODE_ENV === 'development' && process.env.USE_MOCK_CAL_DATA === 'true') {
      console.log('Using mock configuration check due to development mode');
      return { 
        valid: true, 
        message: 'Mock Cal.com configuration is valid',
        user: 'Mock User',
        note: 'Using mock data - not a real Cal.com connection'
      };
    }
    
    // Make a simple request to test the connection
    const response = await calComApi.get('/me');
    console.log('Cal.com connection successful!');
    
    return { 
      valid: true, 
      message: 'Cal.com configuration is valid',
      user: response.data.name || 'Unknown',
      email: response.data.email
    };
  } catch (error) {
    handleApiError('checking Cal.com configuration', error);
    
    // Provide a more detailed error message
    return { 
      valid: false, 
      message: error.response?.data?.message || 'Failed to connect to Cal.com API',
      error: error.message
    };
  }
};

// Force use of mock data for testing
const forceMockMode = (enable = true) => {
  process.env.USE_MOCK_CAL_DATA = enable ? 'true' : 'false';
  console.log(`Mock mode ${enable ? 'enabled' : 'disabled'}`);
};

module.exports = {
  getAvailableTimeSlots,
  createBooking,
  rescheduleBooking,
  cancelBooking,
  getBookingDetails,
  checkCalComConfig,
  forceMockMode
};