import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';
import '../models/menu.dart';

class MenuService {
  late Future<Isar> db;

  MenuService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationSupportDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [MenuSchema, CategorySchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<List<Menu>> getAllMenu() async {
    try {
      final isar = await db;
      final menu = isar.menus;
      return menu.where().findAll();
    } catch (e) {
      Logger().e(e.toString());
      return [];
    }
  }

  Future<void> addMenu(
      {required String name,
      String? description,
      required int price,
      required Category category}) async {
    try {
      final isar = await db;
      final newMenu = Menu()
        ..name = name
        ..description = description
        ..price = price
        ..category.value = category;

      isar.writeTxnSync(() {
        isar.menus.putSync(newMenu);
      });
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> editMenu(
      {required String newName,
      String? newDescription,
      required int newPrice,
      required Category newCategory,
      required Id id}) async {
    try {
      final isar = await db;
      final menu = Menu()
        ..name = newName
        ..description = newDescription
        ..price = newPrice
        ..category.value = newCategory
        ..id = id;

      isar.writeTxnSync(() {
        isar.menus.putSync(menu);
      });
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> deleteMenu(Id id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() => isar.menus.delete(id));
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
