import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/data/services/utils.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

class MenuService {
  MenuService() {
    db = openDB();
  }
  late Future<Isar> db;

  Future<List<Menu>> getAllMenu() async {
    try {
      final Isar isar = await db;
      final IsarCollection<Menu> menu = isar.menus;
      return menu.where().findAll();
    } catch (e) {
      Logger().e(e.toString());
      return <Menu>[];
    }
  }

  Future<Menu> getMenuById(Id id) async {
    try {
      final Isar isar = await db;
      final IsarCollection<Menu> menu = isar.menus;
      return menu.where().idEqualTo(id).findFirstSync()!;
    } catch (e) {
      Logger().e(e.toString());
      return Menu();
    }
  }

  Future<void> modifyMenu({
    required String name,
    required int price,
    required String category,
    Id? id,
    String? description,
    String imagePath = '',
  }) async {
    try {
      final Isar isar = await db;
      final Menu newMenu = Menu()
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
      final Isar isar = await db;
      await isar.writeTxn(() => isar.menus.delete(id));
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
