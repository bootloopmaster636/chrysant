import 'dart:io';

import 'package:chrysant/constants.dart';
import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/logic/manage/category.dart';
import 'package:chrysant/logic/manage/menu.dart';
import 'package:chrysant/pages/components/image_preview.dart';
import 'package:chrysant/pages/menu/manage_categories.dart';
import 'package:chrysant/pages/menu/modify_menu.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MenuPage extends HookConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
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
    final AsyncValue<List<Menu>> menuProvider = ref.watch(menusProvider);
    final AsyncValue<List<Category>> categoryProvider =
        ref.watch(categoriesProvider);

    // for adding additional tab to manage categories
    // append the map of tab and content with these
    final Iterable<Tab> addCategoryTabIterable = Iterable<Tab>.generate(
      1,
      (int index) => const Tab(
        child: Row(
          children: <Widget>[
            Icon(Icons.category_outlined),
            Gap(8),
            Text('Categories'),
          ],
        ),
      ),
    );
    final Iterable<Widget> addCategoryContentIterable =
        Iterable<Widget>.generate(1, (int index) => const CategoryCard());

    return categoryProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: (categoryProvider.value?.length ?? 0) + 1,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TabBar(
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          tabs: categoryProvider.value
                                  ?.map((Category e) {
                                    return Tab(
                                      text: e.category,
                                    );
                                  })
                                  .followedBy(addCategoryTabIterable)
                                  .toList() ??
                              <Widget>[],
                        ),
                      ),
                      const Gap(32),
                      FilledButton(
                        onPressed: categoryProvider.value!.isNotEmpty
                            ? () {
                                showModalBottomSheet(
                                  useSafeArea: true,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxHeight: 80.h),
                                        child: const ModifyMenuDialog(
                                          mode: 'Add',
                                        ),
                                      ),
                                    );
                                  },
                                  context: context,
                                );
                              }
                            : null,
                        child: const Row(
                          children: <Widget>[
                            Icon(Icons.add),
                            Text('Add Menu'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TabBarView(
                      children: categoryProvider.value
                              ?.map((Category e) {
                                return menuProvider.when(
                                  data: (List<Menu> menus) {
                                    final List<Menu> filteredMenus = menus
                                        .where(
                                          (Menu element) =>
                                              element.category == e.category,
                                        )
                                        .toList();
                                    return filteredMenus.isNotEmpty
                                        ? SingleChildScrollView(
                                            child: Wrap(
                                              children: filteredMenus
                                                  .map(
                                                    (Menu e) => MenuTile(
                                                      id: e.id,
                                                      imagePath: e.imagePath,
                                                      name: e.name,
                                                      price: e.price,
                                                      description:
                                                          e.description,
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          )
                                        : const Center(
                                            child: Text(
                                              'No menu available on this category\nPlease add one from the add menu button above...',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error:
                                      (Object error, StackTrace stackTrace) =>
                                          const Center(
                                    child: Text('Error'),
                                  ),
                                );
                              })
                              .followedBy(addCategoryContentIterable)
                              .toList() ??
                          <Widget>[],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class MenuTile extends ConsumerWidget {
  const MenuTile({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.description,
    super.key,
  });
  final Id id;
  final String imagePath;
  final String name;
  final int price;
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 140,
      width: Device.screenType == ScreenType.mobile ? 100.w : 30.w,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                clipBehavior: Clip.antiAlias,
                child: imagePath != ''
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ImagePreview(
                                file: File(imagePath),
                                menuName: name,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: name,
                          child: Image.file(File(imagePath), fit: BoxFit.cover),
                        ),
                      )
                    : const Icon(Icons.no_photography_outlined),
              ),
              const Gap(16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description!.isNotEmpty)
                    Text(
                      description!,
                      style: const TextStyle(fontSize: 16),
                    )
                  else
                    const SizedBox(),
                  Text(
                    '$currency $price',
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
                    children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            useSafeArea: true,
                            enableDrag: true,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 80.h),
                                  child: ModifyMenuDialog(
                                    mode: 'Edit',
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
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Menu'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'The following menu will be deleted',
                                    ),
                                    Text(
                                      'Name: $name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Price: $currency $price',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(8),
                                    const Text(
                                      'Do you want to delete this menu?',
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      ref
                                          .read(menusProvider.notifier)
                                          .deleteMenu(id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
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
        ),
      ),
    );
  }
}
