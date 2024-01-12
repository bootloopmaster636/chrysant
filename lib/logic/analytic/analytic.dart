import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/logic/analytic/archiveFilterer.dart';

Future<int> countArchivesOnDate(DateTime date) async {
  final List<Archive> archiveList = await getAllArchiveOnDate(date);
  return archiveList.length;
}
