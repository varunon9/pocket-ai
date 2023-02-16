import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final void Function(String) onChanged;
  final TextInputType textInputType;
  final String? initialValue;
  final TextEditingController? controller;
  final bool autofocus;
  final bool? enabled;
  final int? minLines;
  final int? maxLines;
  final Color fillColor;
  final Widget? prefixIcon;

  const CustomTextFormField(
      {super.key,
      required this.hintText,
      required this.onChanged,
      this.textInputType = TextInputType.text,
      this.initialValue,
      this.controller,
      this.enabled,
      this.autofocus = false,
      this.minLines,
      this.maxLines,
      this.fillColor = CustomColors.secondary,
      this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return (TextFormField(
      keyboardType: textInputType,
      onChanged: onChanged,
      initialValue: initialValue,
      controller: controller,
      autofocus: autofocus,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.all(12),
          hintText: hintText,
          hintStyle: const TextStyle(color: CustomColors.lightText),
          isDense: true,
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(12)))),
      style: const TextStyle(color: Colors.white),
    ));
  }
}
