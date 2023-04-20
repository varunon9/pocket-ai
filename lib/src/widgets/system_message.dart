import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class SystemMessage extends StatelessWidget {
  final String content;
  const SystemMessage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return (Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0, left: 16, right: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: CustomColors.secondary,
      ),
      child: CustomText(
        content,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    ));
  }
}
