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

  Future<Menu> getMenuById(Id id) async {
    try {
      final isar = await db;
      final menu = isar.menus;
      return menu.where().idEqualTo(id).findFirstSync()!;
    } catch (e) {
      Logger().e(e.toString());
      return Menu();
    }
  }

  Future<void> modifyMenu(
      {Id? id,
      required String name,
      String? description,
      String imagePath = "",
      required int price,
      required String category}) async {
    try {
      final isar = await db;
      final newMenu = Menu()
        ..name = name
        ..description = description
        ..imagePath = imagePath
        ..price = price
        ..category = category;

      if (id != null) {
        newMenu.id = id;
      }

      isar.writeTxnSync(() {
        isar.menus.putSync(newMenu);
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
