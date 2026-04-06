/// How this Flutter entrypoint is hosted.
enum AppHostMode {
  /// Full shell: tab/sidebar + deep links across modules.
  superApp,

  /// Mini-app opened as its own app (own `MaterialApp` / `runApp`).
  standaloneMiniApp,

  /// Mini-app embedded under a segment of the super-app router tree.
  embeddedMiniApp,
}
