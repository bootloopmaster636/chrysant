import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';

import '../../constants.dart';
import '../../logic/manage/category.dart';
import '../../logic/manage/menu.dart';

class ModifyMenuDialog extends HookConsumerWidget {
  final String mode;
  final Id? id;

  const ModifyMenuDialog({super.key, required this.mode, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenu = mode == "Edit"
        ? ref.watch(menusProvider).value?.firstWhere(
              (element) => element.id == id,
            )
        : null;
    final categoryProvider = ref.watch(categoriesProvider);
    final formKey = useState(GlobalKey<FormState>());
    final imageCtl = useState(XFile(selectedMenu?.imagePath ?? ""));
    final nameCtl = useTextEditingController(text: selectedMenu?.name ?? "");
    final descriptionCtl =
        useTextEditingController(text: selectedMenu?.description ?? "");
    final priceCtl =
        useTextEditingController(text: selectedMenu?.price.toString() ?? "");
    final categoryCtl = useState(ref.read(categoriesProvider).value?.first);

    return Scaffold(
      appBar: AppBar(
        title: Text("$mode Menu"),
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
                children: [
                  Center(
                    child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageCtl.value.path == ""
                            ? const NoImageNotif()
                            : Image.file(
                                File(imageCtl.value.path),
                                fit: BoxFit.contain,
                              )),
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (imageCtl.value.path != "") {
                            ref
                                .read(menusProvider.notifier)
                                .deleteCurrentImage(selectedMenu!);
                          }
                          imageCtl.value = image ?? XFile("");
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                        ),
                        child: const Text("Choose from gallery"),
                      ),
                      const Gap(8),
                      OutlinedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (imageCtl.value.path != "") {
                            ref
                                .read(menusProvider.notifier)
                                .deleteCurrentImage(selectedMenu!);
                          }
                          imageCtl.value = image ?? XFile("");
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          foregroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        child: const Text("Take a picture"),
                      ),
                      if (imageCtl.value.path != "")
                        Row(
                          children: [
                            const Gap(8),
                            IconButton(
                              onPressed: () {
                                if (imageCtl.value.path != "") {
                                  ref
                                      .read(menusProvider.notifier)
                                      .deleteCurrentImage(selectedMenu!);
                                }
                                imageCtl.value = XFile("");
                              },
                              icon: Icon(
                                Icons.delete_outlined,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  TextFormField(
                    controller: nameCtl,
                    decoration: const InputDecoration(
                      labelText: "Menu Name",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter menu name";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionCtl,
                    decoration: const InputDecoration(
                      labelText: "Menu Description (optional)",
                    ),
                  ),
                  TextFormField(
                    controller: priceCtl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Menu Price ($currency)",
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.parse(value) <= 0) {
                        return "Please enter valid menu price";
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  const Text(
                    "Menu Category",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 12),
                  ),
                  DropdownButton2(
                    items: categoryProvider.value!
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.category),
                            ))
                        .toList(),
                    value: categoryCtl.value,
                    onChanged: (value) {
                      categoryCtl.value = value;
                    },
                    hint: const Text("Select Category"),
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
                              category: categoryCtl.value?.category ?? "");
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save"),
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

class NoImageNotif extends StatelessWidget {
  const NoImageNotif({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.no_photography_outlined),
        Text("No Image added..."),
      ],
    );
  }
}
