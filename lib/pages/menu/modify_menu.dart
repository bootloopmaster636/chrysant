import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Form(
                  key: formKey.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: "Menu Price",
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
                                  name: nameCtl.text,
                                  description: descriptionCtl.text,
                                  price: int.parse(priceCtl.text),
                                  category: categoryCtl.value!);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}