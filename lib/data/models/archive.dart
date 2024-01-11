import 'package:isar/isar.dart';

part 'archive.g.dart';

@collection
class Archive {
  Id id = Isar.autoIncrement;
  String? name;
  int? tableNumber;
  int total = 0;
  bool isDineIn = false;
  DateTime? orderedAt;
  DateTime? paidAt;
  List<ArchiveMenu> items = <ArchiveMenu>[];
}

@embedded
class ArchiveMenu {
  String name = '';
  int price = 0;
}
