import 'dart:io';

import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/data/services/menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'menu.g.dart';

@riverpod
class Menus extends _$Menus {
  Future<List<Menu>> _fetchMenus() async {
    final MenuService service = MenuService();
    return await service.getAllMenu();
  }

  @override
  FutureOr<List<Menu>> build() async {
    return _fetchMenus();
  }

  Future<void> modifyMenu(
      {required String name, required int price, required String category, Id? id,
      XFile? image,
      String? description,}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      //save image
      File newFile = File('');
      if (image?.path == '') {
        image = null;
      } else {
        final Directory path = await getApplicationDocumentsDirectory();
        Logger().i('Saving menu image in ${path.path}/${image?.name}');
        await image?.saveTo('${path.path}/${image?.name}');
        newFile = File('${path.path}/${image?.name}');
      }

      //save data
      final MenuService service = MenuService();
      await service.modifyMenu(
          id: id,
          imagePath: newFile.path,
          name: name,
          price: price,
          category: category,
          description: description,);
      return await _fetchMenus();
    });
  }

  Future<void> deleteCurrentImage(Menu menu) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final File oldFile = File(menu.imagePath);
      await oldFile.delete();

      await modifyMenu(
          name: menu.name,
          price: menu.price,
          category: menu.category,
          description: menu.description,
          id: menu.id,
          image: XFile(''),);
      return await _fetchMenus();
    });
  }

  Future<void> deleteMenu(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final MenuService service = MenuService();
      await service.deleteMenu(id);
      return await _fetchMenus();
    });
  }
}
