import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/services/category.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category.g.dart';

@riverpod
class Categories extends _$Categories {
  Future<List<Category>> _fetchCategory() async {
    final CategoryService service = CategoryService();
    return await service.getAllCategories();
  }

  @override
  FutureOr<List<Category>> build() async {
    return _fetchCategory();
  }

  Future<void> addCategory(String newCategory) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final CategoryService service = CategoryService();
      await service.addCategory(newCategory);
      return await _fetchCategory();
    });
  }

  Future<void> deleteCategory(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final CategoryService service = CategoryService();
      await service.deleteCategory(id);
      return await _fetchCategory();
    });
  }
}
