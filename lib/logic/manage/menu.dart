import 'dart:io';

import 'package:chrysant/data/services/menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<void> modifyMenu(
      {Id? id,
      XFile? image,
      required String name,
      String? description,
      required int price,
      required String category}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      //save image
      File newFile = File("");
      if (image?.path == "") {
        image = null;
      } else {
        final path = await getApplicationDocumentsDirectory();
        Logger().i("Saving menu image in ${path.path}/${image?.name}");
        await image?.saveTo('${path.path}/${image?.name}');
        newFile = File('${path.path}/${image?.name}');
      }

      //save data
      final service = MenuService();
      await service.modifyMenu(
          id: id,
          imagePath: newFile.path,
          name: name,
          price: price,
          category: category,
          description: description);
      return await _fetchMenus();
    });
  }

  Future<void> deleteCurrentImage(Menu menu) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      File oldFile = File(menu.imagePath);
      await oldFile.delete();

      await modifyMenu(
          name: menu.name,
          price: menu.price,
          category: menu.category,
          description: menu.description,
          id: menu.id,
          image: XFile(""));
      return await _fetchMenus();
    });
  }

  Future<void> deleteMenu(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = MenuService();
      await service.deleteMenu(id);
      return await _fetchMenus();
    });
  }
}
