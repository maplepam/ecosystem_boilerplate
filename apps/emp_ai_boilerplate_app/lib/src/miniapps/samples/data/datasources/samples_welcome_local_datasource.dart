/// Local persistence for the welcome string (sample cache boundary).
abstract interface class SamplesWelcomeLocalDataSource {
  Future<String?> readWelcome();

  Future<void> writeWelcome(String value);

  Future<void> clear();
}
