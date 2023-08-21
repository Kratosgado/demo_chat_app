class ChatMessage {
  final String text;
  final DateTime timestamp;
  final String senderUid;
  final String? imageUrl; // Optional property for image URL
  final String? emoji; // Optional property for emoji

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.senderUid,
    this.imageUrl,
    this.emoji,
  });
}
