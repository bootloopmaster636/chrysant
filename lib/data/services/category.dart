import 'dart:io';

import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/data/models/order.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class CategoryService {
  CategoryService() {
    db = openDB();
  }
  late Future<Isar> db;

  Future<Isar> openDB() async {
    final Directory dir = await getApplicationSupportDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        <CollectionSchema>[CategorySchema, MenuSchema, OrderSchema],
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final Isar isar = await db;
      final IsarCollection<Category> categories = isar.categorys;
      return categories.where().findAll();
    } catch (e) {
      Logger().e(e.toString());
      return <Category>[];
    }
  }

  Future<void> addCategory(String newCategory) async {
    try {
      final Isar isar = await db;
      final Category category = Category()..category = newCategory;
      await isar.writeTxn(() => isar.categorys.put(category));
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> deleteCategory(Id id) async {
    try {
      final Isar isar = await db;
      await isar.writeTxn(() => isar.categorys.delete(id));
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
