import 'package:flutter/material.dart';
import 'package:pocket_ai/src/globals.dart';
import 'package:pocket_ai/src/modules/chat/models/drawer_menu_item.dart';
import 'package:pocket_ai/src/modules/settings/screens/settings_screen.dart';
import 'package:pocket_ai/src/utils/analytics.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_colors.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final void Function(DrawerMenuItemsIds) onItemTapped;

  final List<DrawerMenuItem> menuItems = [
    DrawerMenuItem(
        name: 'AI Forum',
        id: DrawerMenuItemsIds.aiForum,
        eventName: EventNames.navDrawerAiForumClicked,
        iconData: Icons.people),
    DrawerMenuItem(
        name: 'Content Generator',
        id: DrawerMenuItemsIds.contentGenerator,
        eventName: EventNames.navDrawerContentGeneratorClicked,
        iconData: Icons.edit),
    DrawerMenuItem(
        name: 'Todos Manager',
        id: DrawerMenuItemsIds.todosManager,
        eventName: EventNames.navDrawerTodosManagerClicked,
        iconData: Icons.task),
    DrawerMenuItem(
        name: 'Help',
        id: DrawerMenuItemsIds.help,
        eventName: EventNames.navDrawerHelpClicked,
        iconData: Icons.help),
    DrawerMenuItem(
        name: 'Settings',
        id: DrawerMenuItemsIds.settings,
        eventName: EventNames.navDrawerSettingsClicked,
        iconData: Icons.settings),
    DrawerMenuItem(
        name: 'Rate App',
        id: DrawerMenuItemsIds.rateApp,
        eventName: EventNames.navDrawerRateAppClicked,
        iconData: Icons.rate_review),
    DrawerMenuItem(
        name: 'Share App',
        id: DrawerMenuItemsIds.shareApp,
        eventName: EventNames.navDrawerShareAppClicked,
        iconData: Icons.share)
  ];

  CustomNavigationDrawer({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: CustomColors.secondary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        shape: BoxShape.circle),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.white,
                    )),
                Row(
                  children: [
                    Expanded(
                        child: CustomText(
                      Globals.appSettings.aiForumUsername ??
                          Globals.deviceId ??
                          '',
                      size: CustomTextSize.small,
                      style: const TextStyle(color: Colors.white),
                    )),
                    IconButton(
                        onPressed: () {
                          navigateToScreen(context, SettingsScreen.routeName);
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ))
                  ],
                )
              ],
            ),
          ),
          ...menuItems.map((item) {
            return ListTile(
              leading: Icon(item.iconData),
              title: Text(item.name),
              onTap: () {
                if (item.eventName != null) {
                  logEvent(item.eventName!, {});
                }
                onItemTapped(item.id);
              },
            );
          })
        ],
      ),
    );
  }
}
