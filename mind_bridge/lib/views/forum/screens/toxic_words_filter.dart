class ToxicWordsFilter {
  // List of toxic words to filter
  static final List<String> toxicWords = [
    'stupid',
    'idiot',
    'dumb',
    'fool',
    'moron',
    'jerk',
    'hate',
    'loser',
    'trash',
    'garbage',
    'worthless',
    'damn',
    'hell',
    'crap',
    'wtf',
    'shut up',
    'screw you',
    'go to hell',
    'fuck',
    'shit',
    'asshole',
    'bitch',
    'bastard',
    'dick',
    'retard',
    'slut',
    'whore',
    'cunt',
    'piss',
    'bollocks',
    'bloody',
    'bugger',
    'rubbish',
    'wanker',
    'douchebag',
    'motherfucker',
    'bullshit',
    'ass',
    'butt',
    'hoe',
    'thot',
    'jackass',
    'stfu',
    'fck',
    'f*ck',
    's*it',
    'a**hole',
    'b*tch',
    'b*stard',
    'd*ck',
    'r*tard',
    'sl*t',
    'wh*re',
    'c*nt',
    'p*ss',
    'b*llocks',
    'noob',
    'sucker',
    'suck',
    'kill yourself',
    'kys',
    'die',
    // Add more toxic words as needed
  ];

  /// Checks if a message contains any toxic words
  /// Returns a map with 'containsToxicWord' boolean and 'toxicWord' string if found
  static Map<String, dynamic> containsToxicWord(String message) {
    final lowercaseMessage = message.toLowerCase();
    
    for (final word in toxicWords) {
      // Check if the message contains the toxic word as a whole word
      // This helps avoid flagging words that contain toxic words as substrings
      final RegExp wordPattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      
      if (wordPattern.hasMatch(lowercaseMessage)) {
        return {
          'containsToxicWord': true,
          'toxicWord': word,
        };
      }
    }
    
    return {
      'containsToxicWord': false,
      'toxicWord': '',
    };
  }
  
  /// Censors toxic words in a message by replacing them with asterisks
  /// Returns the censored message
  static String censorToxicWords(String message) {
    String censoredMessage = message;
    
    for (final word in toxicWords) {
      final RegExp wordPattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      
      if (wordPattern.hasMatch(censoredMessage.toLowerCase())) {
        // Replace the toxic word with asterisks, preserving the original length
        final replacement = '*' * word.length;
        censoredMessage = censoredMessage.replaceAllMapped(
          RegExp(wordPattern.pattern, caseSensitive: false),
          (match) => replacement
        );
      }
    }
    
    return censoredMessage;
  }
}