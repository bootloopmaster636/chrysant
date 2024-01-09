import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  ///////////////////////////////////////////////
  //////// GET SETTINGS ////////////////////////
  /////////////////////////////////////////////
  Future<ThemeMode> getThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawTheme = prefs.getString('themeMode');
    if (rawTheme == null) {
      //create default theme if not already set in sharedprefs
      await prefs.setString('themeMode', 'System');
      return ThemeMode.system;
    }

    if (rawTheme == 'System') {
      return ThemeMode.system;
    } else if (rawTheme == 'Dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  Future<String> getCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currency = prefs.getString('currency');
    if (currency == null) {
      //create default currency if not already set in sharedprefs
      await prefs.setString('currency', 'Rp.');
      return 'Rp.';
    }
    return currency;
  }

  Future<String> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('name');
    if (name == null) {
      //create default name if not already set in sharedprefs
      await prefs.setString('name', 'User');
      return 'User';
    }
    return name;
  }

  Future<String> getPlaceName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? placeName = prefs.getString('placeName');
    if (placeName == null) {
      //create default placeName if not already set in sharedprefs
      await prefs.setString('placeName', 'Restaurant');
      return 'Restaurant';
    }
    return placeName;
  }

  Future<String> getPlaceAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? placeAddress = prefs.getString('placeAddress');
    if (placeAddress == null) {
      //create default placeAddress if not already set in sharedprefs
      await prefs.setString('placeAddress', 'Earth');
      return 'Earth';
    }
    return placeAddress;
  }

  ///////////////////////////////////////////////
  //////// SET SETTINGS ////////////////////////
  /////////////////////////////////////////////

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (themeMode == ThemeMode.system) {
      await prefs.setString('themeMode', 'System');
    } else if (themeMode == ThemeMode.dark) {
      await prefs.setString('themeMode', 'Dark');
    } else {
      await prefs.setString('themeMode', 'Light');
    }
  }

  Future<void> setCurrency(String currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  Future<void> setName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }

  Future<void> setPlaceName(String placeName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('placeName', placeName);
  }

  Future<void> setPlaceAddress(String placeAddress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('placeAddress', placeAddress);
  }

  Future<void> reset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
