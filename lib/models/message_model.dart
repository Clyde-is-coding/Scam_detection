class ScannedMessage {
  final String id;
  final String sender;
  final String body;
  final DateTime date;
  final bool isScam;
  final double confidence;

  ScannedMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.date,
    required this.isScam,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'date': date.toIso8601String(),
      'isScam': isScam,
      'confidence': confidence,
    };
  }

  factory ScannedMessage.fromJson(Map<String, dynamic> json) {
    return ScannedMessage(
      id: json['id'],
      sender: json['sender'],
      body: json['body'],
      date: DateTime.parse(json['date']),
      isScam: json['isScam'],
      confidence: json['confidence'].toDouble(),
    );
  }
}

