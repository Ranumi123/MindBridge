// Middleware for filtering toxic words

// Import or define toxic words list - matches the frontend list
const toxicWords = [
    'stupid', 'idiot', 'dumb', 'fool', 'moron', 'jerk', 'hate', 'loser', 'trash', 
    'garbage', 'worthless', 'damn', 'hell', 'crap', 'wtf', 'shut up', 'screw you', 
    'go to hell', 'fuck', 'shit', 'asshole', 'bitch', 'bastard', 'dick', 'retard', 
    'slut', 'whore', 'cunt', 'piss', 'bollocks', 'bloody', 'bugger', 'rubbish', 
    'wanker', 'douchebag', 'motherfucker', 'bullshit', 'ass', 'butt', 'hoe', 'thot', 
    'jackass', 'stfu', 'fck', 'f*ck', 's*it', 'a**hole', 'b*tch', 'b*stard', 'd*ck', 
    'r*tard', 'sl*t', 'wh*re', 'c*nt', 'p*ss', 'b*llocks', 'noob', 'sucker', 'suck', 
    'kill yourself', 'kys', 'die'
  ];
  
  /**
   * Check if a message contains toxic words
   * @param {string} message - The message to check
   * @returns {Object} Object containing containsToxicWord boolean and toxicWord string if found
   */
  function containsToxicWord(message) {
    if (!message) return { containsToxicWord: false };
    
    const lowercaseMessage = message.toLowerCase();
    
    for (const word of toxicWords) {
      // Check if the message contains the toxic word as a whole word
      const wordPattern = new RegExp('\\b' + word.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + '\\b', 'i');
      
      if (wordPattern.test(lowercaseMessage)) {
        return {
          containsToxicWord: true,
          toxicWord: word,
        };
      }
    }
    
    return {
      containsToxicWord: false,
      toxicWord: '',
    };
  }
  
  /**
   * Censor toxic words in a message
   * @param {string} message - The message to censor
   * @returns {string} The censored message
   */
  function censorToxicWords(message) {
    if (!message) return '';
    
    let censoredMessage = message;
    
    for (const word of toxicWords) {
      const wordPattern = new RegExp('\\b' + word.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + '\\b', 'i');
      
      if (wordPattern.test(censoredMessage.toLowerCase())) {
        // Replace the toxic word with asterisks, preserving the original length
        const replacement = '*'.repeat(word.length);
        censoredMessage = censoredMessage.replace(
          new RegExp(wordPattern, 'gi'),
          replacement
        );
      }
    }
    
    return censoredMessage;
  }
  
  /**
   * Middleware to check for toxic words in message content
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next function
   */
  function toxicFilter(req, res, next) {
    const message = req.body.message;
    
    if (!message) {
      return next();
    }
    
    const toxicCheck = containsToxicWord(message);
    
    if (toxicCheck.containsToxicWord) {
      return res.status(400).json({
        error: 'Your message contains inappropriate language',
        toxic: true,
        toxicWord: toxicCheck.toxicWord
      });
    }
    
    next();
  }
  
  /**
   * Middleware to censor toxic words without blocking the message
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next function
   */
  function toxicFilterCensor(req, res, next) {
    const message = req.body.message;
    
    if (!message) {
      return next();
    }
    
    // Censor toxic words and update the request
    req.body.message = censorToxicWords(message);
    req.body.isCensored = req.body.message !== message;
    
    next();
  }
  
  module.exports = {
    toxicFilter,
    toxicFilterCensor,
    containsToxicWord,
    censorToxicWords,
    toxicWords
  };