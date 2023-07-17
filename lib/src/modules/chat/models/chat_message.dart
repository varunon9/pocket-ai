enum ChatRole { system, user, assistant }

class ChatMessage {
  final String content;
  final ChatRole role;

  ChatMessage({required this.content, required this.role});

  factory ChatMessage.fromJson(Map<String, dynamic> jsonData) {
    return ChatMessage(
      content: jsonData['content'] as String,
      role: ChatRole.values
          .firstWhere((e) => e.toString().contains(jsonData['role'])),
    );
  }

  dynamic toJson() =>
      {'content': content, 'role': role.toString().split('.').last};

  @override
  String toString() {
    return toJson().toString();
  }
}
