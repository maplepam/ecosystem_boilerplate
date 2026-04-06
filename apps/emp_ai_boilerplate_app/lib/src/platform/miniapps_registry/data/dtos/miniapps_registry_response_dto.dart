import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';

/// Wire format for **your** BFF / config service.
///
/// **REPLACE** field names or nesting to match your real API contract; update
/// [tryParse] accordingly.
final class MiniappsRegistryResponseDto {
  const MiniappsRegistryResponseDto({required this.enabledMiniappIds});

  /// Expected JSON key — rename in production if your API differs.
  static const String kEnabledMiniappIdsKey = 'enabled_miniapp_ids';

  final List<String> enabledMiniappIds;

  /// Returns `null` if the body does not match the expected contract.
  static MiniappsRegistryResponseDto? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) {
      return null;
    }
    final Object? raw = json[kEnabledMiniappIdsKey];
    if (raw is! List<dynamic>) {
      return null;
    }
    final List<String> ids = raw
        .map((dynamic e) => e?.toString().trim() ?? '')
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    return MiniappsRegistryResponseDto(enabledMiniappIds: ids);
  }

  MiniappsRemoteRegistrySnapshot toSnapshot() {
    if (enabledMiniappIds.isEmpty) {
      return const MiniappsRemoteRegistrySnapshot();
    }
    return MiniappsRemoteRegistrySnapshot(
      enabledIds: enabledMiniappIds.toSet(),
    );
  }
}
