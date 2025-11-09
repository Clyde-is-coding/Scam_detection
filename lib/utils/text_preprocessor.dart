class TextPreprocessor {
  static String preprocess(String text) {
    // Convert to lowercase
    text = text.toLowerCase();
    
    // Remove URLs
    text = text.replaceAll(RegExp(r'http[s]?://[^\s]+'), '');
    
    // Remove phone numbers
    text = text.replaceAll(RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), '');
    
    // Remove special characters but keep spaces
    text = text.replaceAll(RegExp(r'[^\w\s]'), '');
    
    // Remove extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return text;
  }

  static List<List<double>> textToTensor(String text) {
    // This is a simplified version - actual implementation depends on your model
    // You might need to use tokenization, word embeddings, etc.
    
    // For demo purposes, create a simple feature vector
    // In production, you'd use proper tokenization and embedding
    final words = text.split(' ');
    final features = List<double>.filled(100, 0.0); // Adjust size based on your model
    
    // Simple hash-based feature extraction
    for (int i = 0; i < words.length && i < 100; i++) {
      features[i] = words[i].hashCode.toDouble() / 1000000.0;
    }
    
    return [features];
  }

  static List<String> extractKeywords(String text) {
    final lowerText = text.toLowerCase();
    final keywords = <String>[];
    
    final scamKeywords = [
      'urgent', 'click', 'verify', 'suspended', 'expired',
      'prize', 'winner', 'congratulations', 'claim', 'limited',
      'update', 'payment', 'identity', 'locked', 'activity',
      'action', 'free', 'money', 'lottery',
    ];
    
    for (var keyword in scamKeywords) {
      if (lowerText.contains(keyword)) {
        keywords.add(keyword);
      }
    }
    
    return keywords;
  }
}

