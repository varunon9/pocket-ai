import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';

class BotOrUserMessageBubble extends StatelessWidget {
  final bool fromBot;
  final Widget child;

  const BotOrUserMessageBubble(
      {super.key, required this.fromBot, required this.child});

  @override
  Widget build(BuildContext context) {
    return (Bubble(
        nip: fromBot ? BubbleNip.leftTop : BubbleNip.rightTop,
        margin: const BubbleEdges.only(top: 16, left: 8, right: 16),
        color: fromBot ? Colors.white : CustomColors.lightText,
        alignment: fromBot ? Alignment.topLeft : Alignment.topRight,
        child: child));
  }
}
