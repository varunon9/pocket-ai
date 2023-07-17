import 'package:path/path.dart';
import 'package:pocket_ai/src/db/db_names.dart';
import 'package:pocket_ai/src/modules/chat/models/chat_message.dart';
import 'package:sqflite/sqflite.dart';

class ChatWithBotProvider {
  Database? db;

  Future open() async {
    String path = join(await getDatabasesPath(), DbNames.databaseChatWithBot);
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table ${DbNames.tableChatMessages} ( 
  ${DbNames.tableChatMessagesColId} integer primary key autoincrement, 
  ${DbNames.tableChatMessagesColRole} text not null,
  ${DbNames.tableChatMessagesColContent} text not null)
''');
    });
  }

  Future insertChat(ChatMessage chatMessage) async {
    if (db != null) {
      Map<String, dynamic> json = chatMessage.toJson();
      await db!.insert(DbNames.tableChatMessages, {
        DbNames.tableChatMessagesColRole: json['role'],
        DbNames.tableChatMessagesColContent: json['content'],
      });
    }
  }

  Future<List<ChatMessage>> getChats() async {
    List<ChatMessage> chatMessages = [];
    if (db != null) {
      final List<Map<String, dynamic>> maps =
          await db!.query(DbNames.tableChatMessages);
      for (var chatMessage in maps) {
        chatMessages.add(ChatMessage.fromJson(chatMessage));
      }
    }
    return chatMessages;
  }

  Future deleteChatMessages() async {
    if (db != null) {
      await db!.rawDelete("DELETE FROM ${DbNames.tableChatMessages}");
    }
  }

  Future close() async => db?.close();
}
