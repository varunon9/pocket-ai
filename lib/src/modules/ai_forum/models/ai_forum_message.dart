class AiForumMessage {
  final String? content;
  final String? deviceId;
  final String? username;
  final DateTime? time;

  AiForumMessage(
      {required this.content,
      required this.deviceId,
      this.username,
      this.time});

  factory AiForumMessage.fromJson(Map<String, dynamic> jsonData) {
    return AiForumMessage(
        content: jsonData['content'] as String?,
        deviceId: jsonData['deviceId'] as String?,
        username: jsonData['username'] as String?,
        time: jsonData['time']?.toDate() as DateTime?);
  }

  dynamic toJson() => {
        'content': content,
        'deviceId': deviceId,
        'username': username,
        time: time
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
