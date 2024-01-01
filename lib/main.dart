import 'package:chrysant/pages/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chrysant',
        theme: ThemeData(
          colorSchemeSeed: Colors.red,
          useMaterial3: true,
        ),
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const ScrollBehaviorModif(),
            child: child!,
          );
        },
        home: ResponsiveSizer(
          builder: (context, orientation, screenType) {
            return const AppLayout();
          },
        ));
  }
}

class ScrollBehaviorModif extends ScrollBehavior {
  const ScrollBehaviorModif();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}
