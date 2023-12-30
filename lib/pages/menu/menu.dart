import 'package:chrysant/data/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../constants.dart';
import '../../logic/manage/category.dart';
import '../../logic/manage/menu.dart';
import 'addMenu.dart';
import 'manageCategories.dart';

class MenuPage extends HookConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryOverlayIsVisible = useState(false);
    final addMenuDialogIsVisible = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              categoryOverlayIsVisible.value = !categoryOverlayIsVisible.value;
            },
            child: const Text(
              "Manage Categories",
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Center(
            child: MenuContents(),
          ),
          Positioned(
            right: 0,
            child: AnimatedContainer(
              height: categoryOverlayIsVisible.value ? 60.h : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: const CategoryOverlay(),
            ),
          ),
        ],
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

    return DefaultTabController(
      length: categoryProvider.value?.length ?? 0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: categoryProvider.value?.map((e) {
                        return Tab(
                          text: e.category,
                        );
                      }).toList() ??
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
                              constraints: BoxConstraints(maxHeight: 80.h),
                              child: const addMenuDialog(),
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
                children: categoryProvider.value?.map((e) {
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
                                              name: e.name,
                                              price: e.price,
                                              description: e.description,
                                              category: e.category.value!,
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
                    }).toList() ??
                    [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final String name;
  final int price;
  final String? description;
  final Category category;

  const MenuTile(
      {super.key,
      required this.name,
      required this.price,
      required this.description,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: 30.w,
      child: Card(
          elevation: 2,
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
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
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
