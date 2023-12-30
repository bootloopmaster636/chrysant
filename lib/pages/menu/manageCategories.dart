import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../logic/manage/category.dart';

class CategoryOverlay extends HookConsumerWidget {
  const CategoryOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAddCategory = useState(false);
    final categoryProvider = ref.watch(categoriesProvider);

    return SizedBox(
      width: 40.w,
      height: 60.h,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Manage Categories",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.start,
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        showAddCategory.value = !showAddCategory.value;
                      },
                      icon: showAddCategory.value
                          ? const Icon(Icons.remove)
                          : const Icon(Icons.add)),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: showAddCategory.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(),
                secondChild: AddCategory(showAddCategory: showAddCategory),
                sizeCurve: Curves.easeOutCubic,
              ),
              const Divider(),
              categoryProvider.when(
                data: (categories) {
                  if (categories.isNotEmpty) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryTile(
                            name: categories[index].category,
                            id: categories[index].id,
                          );
                        },
                      ),
                    );
                  }
                  return const NoCategoryNotif();
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => const Center(
                  child: Text("Error"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoCategoryNotif extends StatelessWidget {
  const NoCategoryNotif({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
          "You haven't added any category yet... Add one by pressing + button above!",
          textAlign: TextAlign.center),
    );
  }
}

class CategoryTile extends ConsumerWidget {
  final String name;
  final Id id;

  const CategoryTile({super.key, required this.name, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(name),
      trailing: IconButton(
        onPressed: () {
          ref.read(categoriesProvider.notifier).deleteCategory(id);
        },
        icon: Icon(Icons.delete_outline,
            color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class AddCategory extends HookConsumerWidget {
  final ValueNotifier<bool> showAddCategory;
  const AddCategory({super.key, required this.showAddCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryCtl = useTextEditingController();

    return Row(
      children: [
        SizedBox(
          width: 20.w,
          child: TextField(
            controller: categoryCtl,
            decoration: const InputDecoration(
              labelText: "New Category Name",
            ),
          ),
        ),
        const Gap(16),
        IconButton(
          onPressed: () {
            ref.read(categoriesProvider.notifier).addCategory(categoryCtl.text);
            categoryCtl.clear();
            showAddCategory.value = false;
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
