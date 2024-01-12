import 'package:chrysant/data/models/archive.dart';
import 'package:chrysant/data/services/archive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'archive.g.dart';

@riverpod
class ArchiveManager extends _$ArchiveManager {
  Future<List<Archive>> _fetchArchives() async {
    final ArchiveService service = ArchiveService();
    return service.getAllArchive();
  }

  @override
  Future<List<Archive>> build() {
    return _fetchArchives();
  }

  Future<void> addArchive(Archive archive) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final ArchiveService service = ArchiveService();
      await service.addArchive(archive);
      return _fetchArchives();
    });
  }

  Future<void> deleteAllArchive() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final ArchiveService service = ArchiveService();
      await service.deleteAllArchive();
      return _fetchArchives();
    });
  }
}
