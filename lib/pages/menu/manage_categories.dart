import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/logic/manage/category.dart';
import 'package:chrysant/logic/manage/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryCard extends HookConsumerWidget {
  const CategoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> showAddCategory = useState(false);
    final AsyncValue<List<Category>> categoryProvider = ref.watch(categoriesProvider);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text(
                  'Manage Categories',
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
                        : const Icon(Icons.add),),
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
              data: (List<Category> categories) {
                if (categories.isNotEmpty) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CategoryTile(category: categories[index]);
                      },
                    ),
                  );
                }
                return const NoCategoryNotif();
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (Object error, StackTrace stackTrace) => const Center(
                child: Text('Error'),
              ),
            ),
          ],
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
          textAlign: TextAlign.center,),
    );
  }
}

class CategoryTile extends ConsumerWidget {

  const CategoryTile({required this.category, super.key});
  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? categoryMenuCount = getMenuCountOnCategory(category, ref);
    return ListTile(
      title: Text('${category.category} ($categoryMenuCount item(s))'),
      trailing: SizedBox(
        width: 200,
        child: OutlinedButton(
          onPressed: () {
            if (categoryMenuCount == 0) {
              ref.read(categoriesProvider.notifier).deleteCategory(category.id);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Category ${category.category} still has menu(s) in it! Please empty this category first',),
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,),
              const Gap(8),
              const Text('Delete Category'),
            ],
          ),
        ),
      ),
    );
  }

  int? getMenuCountOnCategory(Category category, WidgetRef ref) {
    final AsyncValue<List<Menu>> menuProvider = ref.watch(menusProvider);
    final Iterable<Menu>? menu = menuProvider.value
        ?.where((Menu element) => element.category == category.category);
    return menu?.length;
  }
}

class AddCategory extends HookConsumerWidget {
  const AddCategory({required this.showAddCategory, super.key});
  final ValueNotifier<bool> showAddCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController categoryCtl = useTextEditingController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 260,
          child: TextField(
            controller: categoryCtl,
            decoration: const InputDecoration(
              labelText: 'New Category Name',
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
          icon: const Icon(Icons.save_outlined),
        ),
      ],
    );
  }
}
