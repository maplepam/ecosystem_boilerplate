/// Remote (or local) I/O boundary — no domain entities here.
abstract interface class SamplesRemoteDataSource {
  Future<String> fetchWelcomeMessage();
}

final class SamplesRemoteDataSourceImpl implements SamplesRemoteDataSource {
  const SamplesRemoteDataSourceImpl();

  @override
  Future<String> fetchWelcomeMessage() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'Clean architecture: UI → Notifier / cached_query → Repository → '
        'DataSource.';
  }
}
