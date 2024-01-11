import 'package:chrysant/pages/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'logic/manage/settings.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Chrysant',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.cyan,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
        useMaterial3: true,
      ),
      themeMode:
          ref.watch(settingsManagerProvider).value?.theme ?? ThemeMode.system,
      home: ResponsiveSizer(
        builder: (
          BuildContext context,
          Orientation orientation,
          ScreenType screenType,
        ) {
          return const AppLayout();
        },
      ),
    );
  }
}
