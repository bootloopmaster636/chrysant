import 'dart:io';

import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/data/models/order.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

Future<Isar> openDB() async {
  final Directory dir = await getApplicationSupportDirectory();
  if (Isar.instanceNames.isEmpty) {
    return Isar.open(
      <CollectionSchema>[
        CategorySchema,
        MenuSchema,
        OrderSchema,
        ArchiveSchema,
      ],
      directory: dir.path,
    );
  }

  return Future.value(Isar.getInstance());
}
