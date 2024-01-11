import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/data/services/utils.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

class ArchiveService {
  ArchiveService() {
    db = openDB();
  }

  late Future<Isar> db;

  Future<List<Archive>> getAllArchive() async {
    try {
      final Isar isar = await db;
      final IsarCollection<Archive> archives = isar.archives;
      return archives.where().findAll();
    } catch (e) {
      return <Archive>[];
    }
  }

  Future<List<Archive>> getAllArchiveOnDate(DateTime date) async {
    try {
      final Isar isar = await db;
      final IsarCollection<Archive> archives = isar.archives;

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

  Future<void> addArchive(Archive archive) async {
    try {
      final Isar isar = await db;
      await isar.writeTxn(() => isar.archives.put(archive));
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> deleteAllArchive() async {
    try {
      final Isar isar = await db;
      await isar.writeTxn(() => isar.archives.where().deleteAll());
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
