// config/mood-config.js
module.exports = {
    // Supported mood types
    moodTypes: ["Happy", "Sad", "Calm", "Angry", "Relaxed"],
    
    // Mapping of mood names to values
    moodValues: {
      "Happy": 3,
      "Sad": 1,
      "Calm": 2,
      "Angry": 4,
      "Relaxed": 5
    },
    
    // Default API settings
    api: {
      defaultPageSize: 10,
      maxPageSize: 50,
      moodHistoryDays: 30  // Number of days to keep mood history
    }
  };