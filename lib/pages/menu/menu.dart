import 'package:chrysant/data/models/category.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../constants.dart';
import '../../logic/manage/category.dart';
import '../../logic/manage/menu.dart';
import 'manageCategories.dart';
import 'modifyMenu.dart';

class MenuPage extends HookConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: const Center(
        child: MenuContents(),
      ),
    );
  }
}

class MenuContents extends HookConsumerWidget {
  const MenuContents({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuProvider = ref.watch(menusProvider);
    final categoryProvider = ref.watch(categoriesProvider);

    // for adding additional tab to manage categories
    // append the map of tab and content with these
    final addCategoryTabIterable = Iterable<Tab>.generate(
      1,
      (index) => const Tab(
        child: Row(
          children: [
            Icon(Icons.category_outlined),
            Gap(8),
            Text("Categories"),
          ],
        ),
      ),
    );
    final addCategoryContentIterable =
        Iterable<Widget>.generate(1, (index) => const CategoryOverlay());

    return categoryProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: (categoryProvider.value?.length ?? 0) + 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        tabs: categoryProvider.value
                                ?.map((e) {
                                  return Tab(
                                    text: e.category,
                                  );
                                })
                                .followedBy(addCategoryTabIterable)
                                .toList() ??
                            [],
                      ),
                      const Spacer(),
                      FilledButton(
                          onPressed: () {
                            showModalBottomSheet(
                              useSafeArea: true,
                              enableDrag: true,
                              isScrollControlled: true,
                              builder: (context) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: 80.h),
                                    child: const modifyMenuDialog(
                                      mode: "Add",
                                    ),
                                  ),
                                );
                              },
                              context: context,
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.add),
                              Text("Add Menu"),
                            ],
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabBarView(
                      children: categoryProvider.value
                              ?.map((e) {
                                return menuProvider.when(
                                  data: (menus) {
                                    final filteredMenus = menus
                                        .where((element) =>
                                            element.category.value?.id == e.id)
                                        .toList();
                                    return filteredMenus.isNotEmpty
                                        ? SingleChildScrollView(
                                            child: Wrap(
                                              children: filteredMenus
                                                  .map((e) => MenuTile(
                                                        id: e.id,
                                                        name: e.name,
                                                        price: e.price,
                                                        description:
                                                            e.description,
                                                        category:
                                                            e.category.value!,
                                                      ))
                                                  .toList(),
                                            ),
                                          )
                                        : const Center(
                                            child: Text(
                                              "No menu available on this category\nPlease add one from the add menu button above...",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (error, stackTrace) => const Center(
                                    child: Text("Error"),
                                  ),
                                );
                              })
                              .followedBy(addCategoryContentIterable)
                              .toList() ??
                          [],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class MenuTile extends ConsumerWidget {
  final Id id;
  final String name;
  final int price;
  final String? description;
  final Category category;

  const MenuTile(
      {super.key,
      required this.id,
      required this.name,
      required this.price,
      required this.description,
      required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 140,
      width: 30.w,
      child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    description!.isNotEmpty
                        ? Text(
                            description!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : const SizedBox(),
                    Text(
                      "$currency $price",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 60,
                  child: Card(
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              useSafeArea: true,
                              enableDrag: true,
                              isScrollControlled: true,
                              builder: (context) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: 80.h),
                                    child: modifyMenuDialog(
                                      mode: "Edit",
                                      id: id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Delete Menu"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                          "The following menu will be deleted"),
                                      Text(
                                        "Name: $name",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Price: $currency $price",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Gap(8),
                                      const Text(
                                          "Do you want to delete this menu?")
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel")),
                                    FilledButton(
                                        onPressed: () {
                                          ref
                                              .read(menusProvider.notifier)
                                              .deleteMenu(id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Delete"))
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
