
class ChatProps {
  final String conversationId;
  final List<dynamic> users;
  final String otherUserNickname;
  final String peerPhoto;

  ChatProps({
    required this.conversationId,
    required this.users,
    required this.otherUserNickname,
    required this.peerPhoto,
  });
}
