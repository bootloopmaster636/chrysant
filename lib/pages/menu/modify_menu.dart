import 'dart:io';

import 'package:chrysant/constants.dart';
import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/logic/manage/category.dart';
import 'package:chrysant/logic/manage/menu.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

class ModifyMenuDialog extends HookConsumerWidget {

  const ModifyMenuDialog({required this.mode, super.key, this.id});
  final String mode;
  final Id? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Menu? selectedMenu = mode == 'Edit'
        ? ref.watch(menusProvider).value?.firstWhere(
              (Menu element) => element.id == id,
            )
        : null;
    final AsyncValue<List<Category>> categoryProvider = ref.watch(categoriesProvider);
    final ValueNotifier<GlobalKey<FormState>> formKey = useState(GlobalKey<FormState>());
    final ValueNotifier<XFile> imageCtl = useState(XFile(selectedMenu?.imagePath ?? ''));
    final TextEditingController nameCtl = useTextEditingController(text: selectedMenu?.name ?? '');
    final TextEditingController descriptionCtl =
        useTextEditingController(text: selectedMenu?.description ?? '');
    final TextEditingController priceCtl =
        useTextEditingController(text: selectedMenu?.price.toString() ?? '');
    final ValueNotifier<Category?> categoryCtl = useState(ref.read(categoriesProvider).value?.first);

    return Scaffold(
      appBar: AppBar(
        title: Text('$mode Menu'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: formKey.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageCtl.value.path == ''
                            ? const NoImageNotif()
                            : Image.file(
                                File(imageCtl.value.path),
                                fit: BoxFit.contain,
                              ),),
                  ),
                  const Gap(8),
                  ImageSelector(imageCtl: imageCtl, selectedMenu: selectedMenu),
                  TextFormField(
                    controller: nameCtl,
                    decoration: const InputDecoration(
                      labelText: 'Menu Name',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter menu name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionCtl,
                    decoration: const InputDecoration(
                      labelText: 'Menu Description (optional)',
                    ),
                  ),
                  TextFormField(
                    controller: priceCtl,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Menu Price ($currency)',
                    ),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.parse(value) <= 0) {
                        return 'Please enter valid menu price';
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  const Text(
                    'Menu Category',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12),
                  ),
                  DropdownButton2(
                    items: categoryProvider.value!
                        .map((Category e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.category),
                            ),)
                        .toList(),
                    value: categoryCtl.value,
                    onChanged: (Category? value) {
                      categoryCtl.value = value;
                    },
                    hint: const Text('Select Category'),
                    isExpanded: true,
                  ),
                  const Gap(16),
                  Center(
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.value.currentState!.validate()) {
                          ref.read(menusProvider.notifier).modifyMenu(
                              id: selectedMenu?.id,
                              image: imageCtl.value,
                              name: nameCtl.text,
                              description: descriptionCtl.text,
                              price: int.parse(priceCtl.text),
                              category: categoryCtl.value?.category ?? '',);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageSelector extends ConsumerWidget {
  const ImageSelector({
    required this.imageCtl, required this.selectedMenu, super.key,
  });

  final ValueNotifier<XFile> imageCtl;
  final Menu? selectedMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FilledButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (selectedMenu?.imagePath != '' && selectedMenu != null) {
              await ref
                  .read(menusProvider.notifier)
                  .deleteCurrentImage(selectedMenu!);
            }
            imageCtl.value = image ?? XFile('');
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
          child: const Text('Choose from gallery'),
        ),
        const Gap(8),
        OutlinedButton(
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image =
                await picker.pickImage(source: ImageSource.camera);
            if (selectedMenu?.imagePath != '' && selectedMenu != null) {
              Logger().d('Deleting image on ${selectedMenu?.imagePath}');
              await ref
                  .read(menusProvider.notifier)
                  .deleteCurrentImage(selectedMenu!);
            }
            imageCtl.value = image ?? XFile('');
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
            foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text('Take a picture'),
        ),
        if (imageCtl.value.path != '' || selectedMenu?.imagePath != null)
          Row(
            children: <Widget>[
              const Gap(8),
              IconButton(
                onPressed: () {
                  if (selectedMenu?.imagePath != '' && selectedMenu != null) {
                    ref
                        .read(menusProvider.notifier)
                        .deleteCurrentImage(selectedMenu!);
                  }
                  imageCtl.value = XFile('');
                },
                icon: Icon(
                  Icons.delete_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class NoImageNotif extends StatelessWidget {
  const NoImageNotif({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.no_photography_outlined),
        Text('No Image added...'),
      ],
    );
  }
}
