import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.darkBackground,
      ),
      body: Container(
          color: CustomColors.darkBackground,
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Column(children: [])),
    );
  }
}
