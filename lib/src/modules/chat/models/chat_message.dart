enum ChatRole { system, user, assistant }

class ChatMessage {
  final String content;
  final ChatRole role;

  ChatMessage({required this.content, required this.role});

  dynamic toJson() =>
      {'content': content, 'role': role.toString().split('.').last};

  @override
  String toString() {
    return toJson().toString();
  }
}
