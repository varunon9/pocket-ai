import 'package:flutter/material.dart';

enum CustomTextSize { large, medium, regular, small, tiny }

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextSize size;
  final TextStyle? style;
  final TextAlign? textAlign;

  const CustomText(this.text,
      {this.size = CustomTextSize.regular,
      this.style,
      Key? key,
      this.textAlign})
      : super(key: key);

  TextStyle getStyle() {
    switch (size) {
      case CustomTextSize.large:
        {
          return const TextStyle(fontSize: 20);
        }
      case CustomTextSize.medium:
        {
          return const TextStyle(fontSize: 17.5);
        }
      case CustomTextSize.regular:
        {
          return const TextStyle(fontSize: 15);
        }
      case CustomTextSize.small:
        {
          return const TextStyle(fontSize: 12);
        }
      case CustomTextSize.tiny:
        {
          return const TextStyle(fontSize: 8);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, style: getStyle().merge(style), textAlign: textAlign);
  }
}
