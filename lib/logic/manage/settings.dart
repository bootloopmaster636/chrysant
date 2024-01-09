import 'package:chrysant/data/models/settings.dart';
import 'package:chrysant/data/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@riverpod
class SettingsManager extends _$SettingsManager {
  Future<Settings> _fetchSettings() async {
    final SettingsService service = SettingsService();
    final Settings settings = Settings(
      theme: await service.getThemeMode(),
      currency: await service.getCurrency(),
      name: await service.getName(),
      placeName: await service.getPlaceName(),
      placeAddress: await service.getPlaceAddress(),
    );
    return settings;
  }

  @override
  FutureOr<Settings> build() async {
    return _fetchSettings();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final SettingsService service = SettingsService();
      await service.setThemeMode(themeMode);
      return _fetchSettings();
    });
  }

  Future<void> setCurrency(String currency) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final SettingsService service = SettingsService();
      await service.setCurrency(currency);
      return _fetchSettings();
    });
  }

  Future<void> setName(String name) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final SettingsService service = SettingsService();
      await service.setName(name);
      return _fetchSettings();
    });
  }

  Future<void> setPlaceName(String placeName) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final SettingsService service = SettingsService();
      await service.setPlaceName(placeName);
      return _fetchSettings();
    });
  }

  Future<void> setPlaceAddress(String placeAddress) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final SettingsService service = SettingsService();
      await service.setPlaceAddress(placeAddress);
      return _fetchSettings();
    });
  }
}
