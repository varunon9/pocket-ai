import 'package:flutter/material.dart';

class ScrollViewWithHeight extends StatelessWidget {
  final Widget child;

  const ScrollViewWithHeight({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: constraints.copyWith(
              minHeight: constraints.maxHeight, maxHeight: double.infinity),
          child: child,
        ),
      );
    });
  }
}
