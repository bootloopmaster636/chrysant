import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';

class CategoryService {
  late Future<Isar> db;

  CategoryService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationSupportDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [CategorySchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final isar = await db;
      final categories = isar.categorys;
      return categories.where().findAll();
    } catch (e) {
      Logger().e(e.toString());
      return [];
    }
  }

  Future<void> addCategory(String newCategory) async {
    try {
      final isar = await db;
      var category = Category()..category = newCategory;
      await isar.writeTxn(() => isar.categorys.put(category));
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> deleteCategory(Id id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() => isar.categorys.delete(id));
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
