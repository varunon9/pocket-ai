import 'package:flutter/material.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';

class TodoCardItem extends StatelessWidget {
  final Widget child;
  const TodoCardItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border.fromBorderSide(
            BorderSide(width: 0.5, color: CustomColors.lightText),
          ),
          gradient: LinearGradient(colors: [
            getColorFromHex('#B68648', Colors.white),
            getColorFromHex('#FBF3A3', Colors.white)
          ])),
      child: child,
    );
  }
}
