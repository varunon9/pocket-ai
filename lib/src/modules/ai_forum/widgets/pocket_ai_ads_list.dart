import 'package:flutter/material.dart';
import 'package:pocket_ai/src/modules/ai_forum/models/pocket_ai_ad.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PocketAiAdsList extends StatelessWidget {
  final List<PocketAiAd> pocketAiAds;

  const PocketAiAdsList({super.key, required this.pocketAiAds});

  @override
  Widget build(BuildContext context) {
    if (pocketAiAds.isEmpty) {
      return Container();
    }

    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
          itemCount: pocketAiAds.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            PocketAiAd item = pocketAiAds[index];
            Color contentColor =
                getColorFromHex(item.contentColor, CustomColors.darkText);
            return GestureDetector(
              onTap: () {
                logEvent(EventNames.pocketAiAdsClicked,
                    {EventParams.id: item.id ?? ''});
                if (item.navlink != null && item.navlink != '') {
                  launchUrlString(item.navlink!);
                }
              },
              child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: getColorFromHex(
                          item.backgroundColor, CustomColors.lightText)),
                  width: MediaQuery.of(context).size.width -
                      12 * 2 -
                      (pocketAiAds.length == 1 ? 0 : 24),
                  child: Row(
                    children: [
                      Image.network(item.squareIconUrl ?? ''),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.only(left: 12, right: 12),
                        child: Column(
                          children: [
                            Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: CustomText(
                                  item.title ?? '',
                                  style: TextStyle(
                                      color: contentColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                )),
                            Text(
                              item.description ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: contentColor),
                            )
                          ],
                        ),
                      )),
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 32,
                        color: contentColor,
                      )
                    ],
                  )),
            );
          }),
    );
  }
}
