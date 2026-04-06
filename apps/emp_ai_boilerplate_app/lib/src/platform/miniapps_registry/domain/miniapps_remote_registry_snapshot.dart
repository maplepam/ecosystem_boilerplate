import 'package:meta/meta.dart';

/// Server-driven allow-list of [MiniApp.id] values (optional before feature flags).
///
/// - [enabledIds] == `null` → no remote restriction (full local catalog, then flags).
/// - [enabledIds] non-empty → only those ids are candidates for flag filtering.
@immutable
final class MiniappsRemoteRegistrySnapshot {
  const MiniappsRemoteRegistrySnapshot({this.enabledIds});

  /// When null, remote registry imposes no restriction.
  final Set<String>? enabledIds;
}
