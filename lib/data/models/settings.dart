import 'package:flutter/material.dart';

class Settings {
  Settings({
    required this.theme,
    required this.currency,
    this.name,
    this.placeName,
    this.placeAddress,
  });
  ThemeMode theme = ThemeMode.system;
  String? name;
  String? placeName;
  String? placeAddress;
  String currency = '';
}
