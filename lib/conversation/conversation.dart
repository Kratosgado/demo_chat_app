import 'package:demo_chat_app/chat_page/chat_message.dart' show Message;

class Conversation {
  final String conversationId;
  final List<dynamic> users;
  final List<Message> messages;

  Conversation({
    required this.conversationId,
    required this.users,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> users = json['users'];
    final List<dynamic> messageJsonList = json['messages'];

    final List<Message> messages = messageJsonList.map((messageJson) {
      return Message.fromJson(messageJson['id'], messageJson);
    }).toList();

    return Conversation(
      conversationId: json['conversationId'],
      users: users,
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> messageJsonList = messages.map((message) {
      return message.toJson();
    }).toList();

    return {
      'conversationId': conversationId,
      'users': users,
      'messages': messageJsonList,
    };
  }
}
