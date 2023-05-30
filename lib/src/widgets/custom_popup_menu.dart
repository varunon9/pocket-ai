import 'package:flutter/material.dart';
import 'package:pocket_ai/src/modules/faqs/screens/faqs_screen.dart';
import 'package:pocket_ai/src/modules/settings/screens/settings_screen.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';

class CustomPopupMenu extends StatelessWidget {
  const CustomPopupMenu({super.key});

  void handlePopupMenuClick(BuildContext context, int item) {
    switch (item) {
      case 0:
        logEvent(EventNames.helpIconClicked, {});
        navigateToScreen(context, FaqsScreen.routeName);
        break;
      case 1:
        logEvent(EventNames.settingsIconClicked, {});
        navigateToScreen(context, SettingsScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return (PopupMenuButton<int>(
      onSelected: (item) => handlePopupMenuClick(context, item),
      itemBuilder: (context) => [
        const PopupMenuItem<int>(value: 0, child: Text('Help')),
        const PopupMenuItem<int>(value: 1, child: Text('Settings')),
      ],
    ));
  }
}
