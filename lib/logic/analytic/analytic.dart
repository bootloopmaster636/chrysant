import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/data/services/archive.dart';
import 'package:chrysant/logic/analytic/archiveFilterer.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

Future<int> countArchivesOnDate(DateTime date) async {
  final List<Archive> archiveList = await getAllArchiveOnDate(date);
  return archiveList.length;
}

Future<(String, int)> getMenuPopularity(String menuName) async {
  try {
    final IsarCollection<Archive>? archives =
        await ArchiveService().getArchiveCollection();

    if (archives == null) {
      throw Exception('Archive collection is not found');
    }

    final List<Archive> filteredArchive =
        await getAllArchiveContainingMenu(menuName);

    // move this computationally intensive task to different isolate
    final Map arguments = Map();
    arguments['filteredArchive'] = filteredArchive;
    arguments['menuName'] = menuName;
    final int quantityCount = await compute(computeMenuCount, arguments);

    return (menuName, quantityCount);
  } catch (e) {
    return (e.toString(), 0);
  }
}

int computeMenuCount(Map arguments) {
  final List<Archive> filteredArchive =
      arguments['filteredArchive'] as List<Archive>;
  final String menuName = arguments['menuName'] as String;
  int quantityCount = 0;

  for (final Archive element in filteredArchive) {
    for (final ArchiveMenu element in element.items) {
      if (element.name == menuName) quantityCount += element.quantity;
    }
  }
  return quantityCount;
}
