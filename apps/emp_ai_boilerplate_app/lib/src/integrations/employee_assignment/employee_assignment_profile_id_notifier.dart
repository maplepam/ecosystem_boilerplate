import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emp_ai_auth/features/auth/shared/auth_providers.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_flavor_providers.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_detail_response.dart';
import 'package:emp_ai_boilerplate_app/src/network/boilerplate_api_client.dart';
import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full **leave-management** base URL (no trailing slash). Non-empty
/// `LEAVE_MANAGEMENT_BASE_URL` overrides flavor defaults (same pattern as
/// announcement service).
final leaveManagementBaseUrlProvider = Provider<String>(
  (Ref ref) {
    const String override = String.fromEnvironment(
      'LEAVE_MANAGEMENT_BASE_URL',
      defaultValue: '',
    );
    final String trimmed = override.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return ref.watch(boilerplateFlavorEndpointsProvider).leaveManagementBaseUrl;
  },
);

String _wirePrefsKey(String sub) => 'boilerplate_employee_assignment_wire_v2_$sub';

String _legacyProfilePrefsKey(String sub) =>
    'boilerplate_employee_assignment_profile_v1_$sub';

/// Resolves emapta leave-management `GET …/employee-assignment/detail/{sub}`
/// into [EmployeeAssignmentAnnouncementWire] for announcement-bl V2
/// `recipient_value` / `recipient_type` payloads (see emapta
/// `EmpFetchAnnouncementsParams` + `AnnouncementRecipient`).
///
/// Cached per Keycloak `sub` until [clearPersistedRecipientCache] +
/// invalidation.
final employeeAssignmentAnnouncementWireProvider =
    AsyncNotifierProvider<
        EmployeeAssignmentAnnouncementWireNotifier,
        EmployeeAssignmentAnnouncementWire>(
  EmployeeAssignmentAnnouncementWireNotifier.new,
);

final class EmployeeAssignmentAnnouncementWireNotifier
    extends AsyncNotifier<EmployeeAssignmentAnnouncementWire> {
  Future<void> _persistWire(
    SharedPreferences prefs,
    String sub,
    EmployeeAssignmentAnnouncementWire wire,
  ) async {
    await prefs.setString(_wirePrefsKey(sub), jsonEncode(wire.toJson()));
    await prefs.remove(_legacyProfilePrefsKey(sub));
  }

  EmployeeAssignmentAnnouncementWire? _readCache(
    SharedPreferences prefs,
    String sub,
    String fallbackUsername,
  ) {
    final EmployeeAssignmentAnnouncementWire? fromV2 =
        EmployeeAssignmentAnnouncementWire.tryDecodePrefs(
      prefs.getString(_wirePrefsKey(sub)),
    );
    if (fromV2 != null) {
      return EmployeeAssignmentAnnouncementWire(
        companyId: fromV2.companyId,
        employeeAssignmentId: fromV2.employeeAssignmentId,
        profileId: fromV2.profileId,
        fallbackUsername: fromV2.fallbackUsername.isNotEmpty
            ? fromV2.fallbackUsername
            : fallbackUsername,
      );
    }
    final String? v1 = prefs.getString(_legacyProfilePrefsKey(sub))?.trim();
    if (v1 != null && v1.isNotEmpty) {
      return EmployeeAssignmentAnnouncementWire(
        profileId: v1,
        fallbackUsername: fallbackUsername,
      );
    }
    return null;
  }

  /// Removes persisted assignment data for the current Keycloak `sub` only.
  ///
  /// Callers must **`ref.invalidate(employeeAssignmentAnnouncementWireProvider)`**
  /// afterward so the UI re-enters [AsyncLoading] and listeners rebuild.
  Future<void> clearPersistedRecipientCache() async {
    var identity = ref.read(authNotifierProvider.notifier).identity;
    identity ??= await ref.read(authNotifierProvider.notifier).fetchStoredIdentity();
    final String? sub = identity?.sub?.trim();
    if (sub != null && sub.isNotEmpty) {
      final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove(_wirePrefsKey(sub));
      await prefs.remove(_legacyProfilePrefsKey(sub));
    }
  }

  @override
  Future<EmployeeAssignmentAnnouncementWire> build() async {
    // Rebuild only when signed-in flag flips, not on every auth snapshot refresh
    // (roles/permissions), to avoid duplicate LM + announcement list calls.
    final bool authed = ref.watch(
      boilerplateAuthSnapshotProvider.select(
        (AuthSnapshot s) => s.isAuthenticated,
      ),
    );
    if (!authed) {
      return const EmployeeAssignmentAnnouncementWire.empty();
    }

    var identity = ref.read(authNotifierProvider.notifier).identity;
    identity ??= await ref.read(authNotifierProvider.notifier).fetchStoredIdentity();
    final String? sub = identity?.sub?.trim();
    final String fallbackUsername = identity?.preferredUsername?.trim() ?? '';

    if (sub == null || sub.isEmpty) {
      return EmployeeAssignmentAnnouncementWire(
        fallbackUsername: fallbackUsername,
      );
    }

    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    final EmployeeAssignmentAnnouncementWire? cached =
        _readCache(prefs, sub, fallbackUsername);
    if (cached != null) {
      return cached;
    }

    final String base = ref.read(leaveManagementBaseUrlProvider).trim();
    if (base.isEmpty) {
      final EmployeeAssignmentAnnouncementWire wire =
          EmployeeAssignmentAnnouncementWire(
        fallbackUsername: fallbackUsername,
      );
      if (fallbackUsername.isNotEmpty) {
        await _persistWire(prefs, sub, wire);
      }
      return wire;
    }

    try {
      final Dio dio = ref.read(boilerplateDioProvider);
      final Response<Object?> res = await dio.get<Object?>(
        '$base/lm/v1/employee-assignment/detail/$sub',
      );
      final EmployeeAssignmentDetailResponse parsed =
          EmployeeAssignmentDetailResponse.fromDynamic(res.data);
      if (parsed.statusCode == 200) {
        final List<EmployeeAssignmentDetailItem>? items = parsed.data?.items;
        final EmployeeAssignmentDetailItem? first =
            (items != null && items.isNotEmpty) ? items.first : null;
        final String profileId = first?.profileId?.trim() ?? '';
        final String companyId = first?.resolvedCompanyClientRecipientId ?? '';
        final String employeeAssignmentId =
            first?.employeeAssignmentId?.trim() ?? '';
        if (profileId.isNotEmpty ||
            companyId.isNotEmpty ||
            employeeAssignmentId.isNotEmpty) {
          final EmployeeAssignmentAnnouncementWire wire =
              EmployeeAssignmentAnnouncementWire(
            companyId: companyId,
            employeeAssignmentId: employeeAssignmentId,
            profileId: profileId,
            fallbackUsername: fallbackUsername,
          );
          await _persistWire(prefs, sub, wire);
          return wire;
        }
      }
    } on Object {
      // Fall through to username-only wire.
    }

    final EmployeeAssignmentAnnouncementWire wire =
        EmployeeAssignmentAnnouncementWire(
      fallbackUsername: fallbackUsername,
    );
    if (fallbackUsername.isNotEmpty) {
      await _persistWire(prefs, sub, wire);
    }
    return wire;
  }
}
