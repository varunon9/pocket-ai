import 'package:flutter/material.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final bool fullWidth;
  final String? loadingText;

  const CustomElevatedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.isLoading = false,
      this.fullWidth = false,
      this.loadingText});

  Widget renderButton() {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ))),
        child: isLoading
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
                loadingText != null
                    ? Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: CustomText(
                          loadingText!,
                          size: CustomTextSize.medium,
                          style: const TextStyle(color: CustomColors.darkText),
                        ),
                      )
                    : Container()
              ])
            : CustomText(text,
                size: CustomTextSize.medium,
                style: const TextStyle(color: CustomColors.darkText)));
  }

  @override
  Widget build(BuildContext context) {
    return (fullWidth
        ? SizedBox(height: 40, width: double.infinity, child: renderButton())
        : renderButton());
  }
}
