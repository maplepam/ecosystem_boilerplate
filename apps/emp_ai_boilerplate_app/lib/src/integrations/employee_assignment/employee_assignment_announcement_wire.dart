import 'dart:convert';

import 'package:meta/meta.dart';

/// Leave-management + identity fields needed to build announcement-bl V2
/// `recipients` the same way as emapta `home_network_notifier` /
/// `EmpFetchAnnouncementsParams.toJsonV2`.
@immutable
final class EmployeeAssignmentAnnouncementWire {
  const EmployeeAssignmentAnnouncementWire({
    this.companyId = '',
    this.employeeAssignmentId = '',
    this.profileId = '',
    this.fallbackUsername = '',
  });

  const EmployeeAssignmentAnnouncementWire.empty() : this();

  final String companyId;
  final String employeeAssignmentId;
  final String profileId;
  final String fallbackUsername;

  /// Prefer `employee_assignment_id` for `recipient_type: talent`, then
  /// `profile_id`, then Keycloak `preferred_username` (emapta parity).
  String get talentRecipientValue {
    final String a = employeeAssignmentId.trim();
    if (a.isNotEmpty) {
      return a;
    }
    final String p = profileId.trim();
    if (p.isNotEmpty) {
      return p;
    }
    return fallbackUsername.trim();
  }

  /// Stable segment for CachedQuery keys (avoids refetch on unrelated auth
  /// snapshot updates).
  String get cacheSegment =>
      '${companyId.trim()}|${employeeAssignmentId.trim()}|'
      '${profileId.trim()}|${fallbackUsername.trim()}';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'company_id': companyId,
        'employee_assignment_id': employeeAssignmentId,
        'profile_id': profileId,
        'fallback_username': fallbackUsername,
      };

  factory EmployeeAssignmentAnnouncementWire.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmployeeAssignmentAnnouncementWire(
      companyId: (json['company_id'] as String?)?.trim() ?? '',
      employeeAssignmentId:
          (json['employee_assignment_id'] as String?)?.trim() ?? '',
      profileId: (json['profile_id'] as String?)?.trim() ?? '',
      fallbackUsername: (json['fallback_username'] as String?)?.trim() ?? '',
    );
  }

  static EmployeeAssignmentAnnouncementWire? tryDecodePrefs(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return EmployeeAssignmentAnnouncementWire.fromJson(decoded);
      }
    } on Object {
      return null;
    }
    return null;
  }
}
