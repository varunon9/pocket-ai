import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class CustomDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const CustomDropdownButton(
      {Key? key,
      required this.value,
      required this.items,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (DropdownButton(
        isExpanded: true,
        value: value,
        style: const TextStyle(color: Colors.white),
        dropdownColor: CustomColors.secondary,
        icon: const Icon(Icons.keyboard_arrow_down),
        underline: const SizedBox(),
        iconEnabledColor: Colors.white,
        items: items
            .map((item) =>
                DropdownMenuItem(value: item, child: CustomText(item)))
            .toList(),
        onChanged: onChanged));
  }
}
