import 'package:flutter/material.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ContentImage extends StatefulWidget {
  final String content;

  const ContentImage({super.key, required this.content});

  @override
  State<StatefulWidget> createState() => _ContentImage();
}

class _ContentImage extends State<ContentImage> {
  WidgetsToImageController widgetsToImageController =
      WidgetsToImageController();

  void onSharePressed() async {
    logEvent(EventNames.shareGeneratedContentClicked, {});
    try {
      var imageBytes = await widgetsToImageController.capture();
      if (imageBytes != null) {
        Share.shareXFiles([XFile.fromData(imageBytes, mimeType: 'image/png')],
            text: 'Pocket AI: Generate and share content');
      }
    } catch (error) {
      logGenericError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Row(
      children: [
        Expanded(
            child: WidgetsToImage(
          controller: widgetsToImageController,
          child: Container(
            margin: const EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: CustomColors.secondary,
              gradient: LinearGradient(colors: [
                getColorFromHex('#B68648', Colors.white),
                getColorFromHex('#FBF3A3', Colors.white)
              ]),
              /*image: const DecorationImage(
                    image: AssetImage('assets/images/content-background.jpeg'),
                    fit: BoxFit.cover)*/
            ),
            child: Column(
              children: [
                Center(
                    child: CustomText(
                  widget.content,
                  style: const TextStyle(
                      color: CustomColors.darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ))
              ],
            ),
          ),
        )),
        IconButton(
            onPressed: onSharePressed,
            icon: const Icon(
              Icons.share,
              color: CustomColors.primaryDark,
            ))
      ],
    ));
  }
}
