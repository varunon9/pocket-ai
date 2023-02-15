import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onPress;

  const LinkText({Key? key, required this.text, required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Center(
          child: CustomText(text,
              size: CustomTextSize.medium,
              style: const TextStyle(
                  color: Colors.white, decoration: TextDecoration.underline))),
    );
  }
}
