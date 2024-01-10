import 'package:chrysant/constants.dart';
import 'package:chrysant/logic/manage/settings.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:url_launcher/url_launcher.dart';

final List<String> themeOptions = <String>[
  'System',
  'Light',
  'Dark',
];

final Uri _repoLink =
    Uri.parse('https://github.com/bootloopmaster636/chrysant');

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        heightFactor: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SettingsThemeMode(),
                SettingsTypeString(
                  title: 'Name',
                  subtitle: 'Set your name',
                  hintText: 'Your name',
                  valueGetter:
                      ref.read(settingsManagerProvider).value?.name ?? '',
                  valueSetter: (String value) {
                    ref.read(settingsManagerProvider.notifier).setName(value);
                  },
                ),
                SettingsTypeString(
                  title: 'Currency',
                  subtitle: 'Type your currency symbol here',
                  hintText: 'Currency symbol',
                  valueGetter:
                      ref.read(settingsManagerProvider).value?.currency ?? '',
                  valueSetter: (String value) {
                    ref
                        .read(settingsManagerProvider.notifier)
                        .setCurrency(value);
                  },
                ),
                SettingsTypeString(
                  title: 'Place Name',
                  subtitle: 'What is this place called?',
                  hintText: 'Enter place name',
                  valueGetter:
                      ref.read(settingsManagerProvider).value?.placeName ?? '',
                  valueSetter: (String value) {
                    ref
                        .read(settingsManagerProvider.notifier)
                        .setPlaceName(value);
                  },
                ),
                SettingsTypeString(
                  title: 'Place Address',
                  subtitle: 'Where is this place located?',
                  hintText: 'Enter place address',
                  valueGetter:
                      ref.read(settingsManagerProvider).value?.placeAddress ??
                          '',
                  valueSetter: (String value) {
                    ref
                        .read(settingsManagerProvider.notifier)
                        .setPlaceName(value);
                  },
                ),
                const Gap(16),
                const About(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsThemeMode extends HookConsumerWidget {
  const SettingsThemeMode({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> selectedTheme = useState(
      ref.read(settingsManagerProvider).value?.theme == ThemeMode.dark
          ? 'Dark'
          : ref.read(settingsManagerProvider).value?.theme == ThemeMode.light
              ? 'Light'
              : 'System', // Default to system,
    );

    return SizedBox(
      height: 72,
      child: Card(
        child: ListTile(
          title: const Text('Application Theme'),
          subtitle: const Text('Set application theme mode'),
          trailing: DropdownButton2(
            items: themeOptions
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            value: themeOptions.firstWhere(
              (String element) => element == selectedTheme.value,
            ),
            onChanged: (String? value) {
              ref.read(settingsManagerProvider.notifier).setThemeMode(value!);
              selectedTheme.value = value;
            },
          ),
        ),
      ),
    );
  }
}

class SettingsTypeString extends HookConsumerWidget {
  const SettingsTypeString({
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.valueGetter,
    required this.valueSetter,
    super.key,
  });

  final String title;
  final String subtitle;
  final String hintText;
  final String valueGetter;
  final void Function(String) valueSetter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController inputCtl =
        useTextEditingController(text: valueGetter);
    return SizedBox(
      height: 72,
      child: Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: FractionallySizedBox(
            widthFactor: 0.4,
            child: TextField(
              controller: inputCtl,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hintText,
              ),
              onChanged: valueSetter,
            ),
          ),
        ),
      ),
    );
  }
}

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const Text(
            'Chrysant',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text(
            'A simple app to manage your restaurant',
            style: TextStyle(fontSize: 16),
          ),
          const Gap(8),
          const Text('version $version'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Proudly made with '),
              FlutterLogo(
                size: 64,
                style: FlutterLogoStyle.horizontal,
                textColor: Theme.of(context).colorScheme.inverseSurface,
              ),
            ],
          ),
          Column(
            children: <Widget>[
              const Text('This project is open source, made available on '),
              TextButton(
                onPressed: () async {
                  if (!await canLaunchUrl(_repoLink)) {
                    MotionToast.error(
                      title: const Text('Error'),
                      description: Text('Could not launch $_repoLink'),
                    );
                    throw Exception('Could not launch $_repoLink');
                  }
                  if (!await launchUrl(_repoLink)) {
                    throw Exception('Could not launch $_repoLink');
                  }
                },
                child: const Text('GitHub'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
