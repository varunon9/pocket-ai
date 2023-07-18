import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ai/src/modules/ai_forum/models/ai_forum_message.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';

class AiForumMessageBubble extends StatelessWidget {
  final AiForumMessage message;
  final Widget child;
  final bool messageFromSelf;

  const AiForumMessageBubble(
      {super.key,
      required this.message,
      required this.child,
      required this.messageFromSelf});

  @override
  Widget build(BuildContext context) {
    return (Bubble(
        nip: messageFromSelf ? BubbleNip.rightTop : BubbleNip.leftTop,
        margin: const BubbleEdges.only(top: 12, left: 8, right: 16, bottom: 4),
        color: messageFromSelf ? CustomColors.lightText : Colors.white,
        alignment: messageFromSelf ? Alignment.topRight : Alignment.topLeft,
        child: child));
  }
}
