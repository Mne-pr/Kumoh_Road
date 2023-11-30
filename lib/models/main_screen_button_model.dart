import 'package:flutter/material.dart';

class MainScreenButtonModel {
  IconData icon;
  String title;
  Color color;
  String url;
  Function onTap;

  MainScreenButtonModel({
    required this.icon,
    required this.title,
    required this.color,
    required this.url,
    required this.onTap,
  });
}
