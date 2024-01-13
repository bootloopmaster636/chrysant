import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/data/services/archive.dart';
import 'package:isar/isar.dart';

Future<List<Archive>> getAllArchiveOnDate(DateTime date) async {
  try {
    final IsarCollection<Archive>? archives =
        await ArchiveService().getArchiveCollection();

    if (archives == null) {
      throw Exception('Archive collection is not found');
    }

    final DateTime dateLowerBound = DateTime(
      date.year,
      date.month,
      date.day,
    ); // it automatically set to 00:00:00 o'clock
    final DateTime dateUpperBound =
        DateTime(date.year, date.month, date.day, 23, 59, 59);
    return archives
        .filter()
        .paidAtBetween(dateLowerBound, dateUpperBound)
        .findAll();
  } catch (e) {
    return <Archive>[];
  }
}

Future<List<Archive>> getAllArchiveBetweenDate(
    DateTime rangeMin, DateTime rangeMax) async {
  try {
    final IsarCollection<Archive>? archives =
        await ArchiveService().getArchiveCollection();

    if (archives == null) {
      throw Exception('Archive collection is not found');
    }

    return archives.filter().paidAtBetween(rangeMin, rangeMax).findAll();
  } catch (e) {
    return <Archive>[];
  }
}

Future<List<Archive>> getAllArchiveContainingMenu(String menuName) async {
  try {
    final IsarCollection<Archive>? archives =
        await ArchiveService().getArchiveCollection();

    if (archives == null) {
      throw Exception('Archive collection is not found');
    }

    final List<Archive> archiveThatContainsThisMenu = await archives
        .filter()
        .itemsElement(
          (QueryBuilder<ArchiveMenu, ArchiveMenu, QFilterCondition> query) =>
              query.nameContains(menuName),
        )
        .findAll();
    return archiveThatContainsThisMenu;
  } catch (e) {
    return <Archive>[];
  }
}
