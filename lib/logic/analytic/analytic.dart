import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/data/services/archive.dart';
import 'package:chrysant/logic/analytic/archiveFilterer.dart';
import 'package:isar/isar.dart';

Future<int> countArchivesOnDate(DateTime date) async {
  final List<Archive> archiveList = await getAllArchiveOnDate(date);
  return archiveList.length;
}

Future<List<(String, int)>> getMenuPopularity(
  DateTime rangeMin,
  DateTime rangeMax,
) async {
  try {
    final IsarCollection<Archive>? archives =
        await ArchiveService().getArchiveCollection();

    if (archives == null) {
      throw Exception('Archive collection is not found');
    }

    final List<Archive> archiveOnDateBetween =
        await getAllArchiveBetweenDate(rangeMin, rangeMax);
    List<(String, int)> counted = <(String, int)>[];

    // TODO(bootloopmaster636): need to refactor this sometime because it's inefficient
    for (final Archive archive in archiveOnDateBetween) {
      for (final ArchiveMenu menu in archive.items) {
        // if this counter list doesn't have this menu, add it to the list
        // else just increment its counter
        if (counted
            .where(((String, int) element) => element.$1 == menu.name)
            .isEmpty) {
          counted.add((menu.name, menu.quantity));
        } else {
          counted = counted.map(((String, int) element) {
            if (element.$1 == menu.name) {
              return (element.$1, element.$2 + menu.quantity);
            } else {
              return element;
            }
          }).toList();
        }
      }
    }

    return counted;
  } catch (e) {
    throw Exception('Something went wrong in counting menu popularity');
  }
}
