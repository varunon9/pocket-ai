import 'package:flutter/material.dart';

enum HeadingType { h1, h2, h3, h4 }

class Heading extends StatelessWidget {
  final String text;
  final HeadingType type;
  final TextStyle? style;
  final TextAlign? textAlign;

  const Heading(this.text,
      {required this.type, this.style, Key? key, this.textAlign})
      : super(key: key);

  TextStyle getStyle() {
    switch (type) {
      case HeadingType.h1:
        {
          return const TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
        }
      case HeadingType.h2:
        {
          return const TextStyle(fontSize: 32);
        }
      case HeadingType.h3:
        {
          return const TextStyle(fontSize: 24);
        }
      case HeadingType.h4:
        {
          return const TextStyle(fontSize: 20);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: textAlign, style: getStyle().merge(style));
  }
}
