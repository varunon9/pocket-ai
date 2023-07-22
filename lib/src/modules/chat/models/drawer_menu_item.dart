import 'package:flutter/material.dart';

enum DrawerMenuItemsIds {
  aiForum,
  contentGenerator,
  todosManager,
  help,
  settings,
  rateApp,
  shareApp
}

class DrawerMenuItem {
  final String name;
  final DrawerMenuItemsIds id;
  final String? eventName;
  final IconData iconData;

  DrawerMenuItem(
      {required this.name,
      required this.id,
      this.eventName,
      required this.iconData});
}
