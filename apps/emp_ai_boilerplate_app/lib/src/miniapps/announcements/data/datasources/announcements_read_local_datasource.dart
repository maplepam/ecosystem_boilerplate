abstract class AnnouncementsReadLocalDataSource {
  Future<Set<String>> readIds();

  Future<void> addReadId(String id);
}
