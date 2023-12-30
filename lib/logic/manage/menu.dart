import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/services/menu.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/menu.dart';

part 'menu.g.dart';

@riverpod
class Menus extends _$Menus {
  Future<List<Menu>> _fetchMenus() async {
    final service = MenuService();
    return await service.getAllMenu();
  }

  @override
  FutureOr<List<Menu>> build() async {
    return _fetchMenus();
  }

  Future<void> addMenu(
      {required String name,
      String? description,
      required int price,
      required Category category}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = MenuService();
      await service.addMenu(
          name: name,
          price: price,
          category: category,
          description: description);
      return await _fetchMenus();
    });
  }

  Future editMenu(
      {required String name,
      String? description,
      required int price,
      required Category category,
      required Id id}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = MenuService();
      await service.editMenu(
          newName: name,
          newPrice: price,
          newCategory: category,
          newDescription: description,
          id: id);
      return await _fetchMenus();
    });
  }

  Future<void> deleteCategory(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = MenuService();
      await service.deleteMenu(id);
      return await _fetchMenus();
    });
  }
}
