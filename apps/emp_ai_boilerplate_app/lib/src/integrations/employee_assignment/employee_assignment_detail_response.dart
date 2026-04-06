import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Envelope for emapta leave-management
/// `GET {leaveManagement}/lm/v1/employee-assignment/detail/{sub}`.
@immutable
final class EmployeeAssignmentDetailResponse {
  const EmployeeAssignmentDetailResponse({
    required this.statusCode,
    this.data,
  });

  factory EmployeeAssignmentDetailResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignmentDetailResponse(
      statusCode: (json['status_code'] as num?)?.toInt() ?? 0,
      data: json['data'] == null
          ? null
          : EmployeeAssignmentDetailData.fromJson(
              json['data'] as Map<String, dynamic>,
            ),
    );
  }

  /// Parses [raw] when the HTTP client returns a JSON string body.
  factory EmployeeAssignmentDetailResponse.fromDynamic(Object? raw) {
    if (raw == null) {
      return const EmployeeAssignmentDetailResponse(statusCode: 0);
    }
    if (raw is String) {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const EmployeeAssignmentDetailResponse(statusCode: 0);
      }
      return EmployeeAssignmentDetailResponse.fromJson(decoded);
    }
    if (raw is Map<String, dynamic>) {
      return EmployeeAssignmentDetailResponse.fromJson(raw);
    }
    return const EmployeeAssignmentDetailResponse(statusCode: 0);
  }

  final int statusCode;
  final EmployeeAssignmentDetailData? data;

  /// First item’s `profile_id`, matching emapta `FetchEmployeeAssignmentByIdResponse.fetchProfileId`.
  String get profileIdFromFirstItem {
    final List<EmployeeAssignmentDetailItem>? items = data?.items;
    if (items == null || items.isEmpty) {
      return '';
    }
    return items.first.profileId?.trim() ?? '';
  }
}

@immutable
final class EmployeeAssignmentDetailData {
  const EmployeeAssignmentDetailData({this.items});

  factory EmployeeAssignmentDetailData.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignmentDetailData(
      items: json['items'] == null
          ? const <EmployeeAssignmentDetailItem>[]
          : List<EmployeeAssignmentDetailItem>.from(
              (json['items'] as List<dynamic>).map(
                (dynamic x) => EmployeeAssignmentDetailItem.fromJson(
                  x as Map<String, dynamic>,
                ),
              ),
            ),
    );
  }

  final List<EmployeeAssignmentDetailItem>? items;
}

@immutable
final class EmployeeAssignmentDetailItem {
  const EmployeeAssignmentDetailItem({
    this.profileId,
    this.companyId,
    this.companyHcmReferenceId,
    this.employeeAssignmentId,
  });

  factory EmployeeAssignmentDetailItem.fromJson(Map<String, dynamic> json) {
    return EmployeeAssignmentDetailItem(
      profileId: _readStringField(json, const <String>['profile_id', 'profileId']),
      companyId: _readStringField(json, const <String>['company_id', 'companyId']),
      companyHcmReferenceId: _readStringField(
        json,
        const <String>['company_hcm_reference_id', 'companyHcmReferenceId'],
      ),
      employeeAssignmentId: _readStringField(
        json,
        const <String>['employee_assignment_id', 'employeeAssignmentId'],
      ),
    );
  }

  final String? profileId;
  final String? companyId;
  final String? companyHcmReferenceId;
  final String? employeeAssignmentId;

  /// UUID for announcement-bl `recipient_type: client` (specific company).
  String get resolvedCompanyClientRecipientId {
    final String a = companyId?.trim() ?? '';
    if (a.isNotEmpty) {
      return a;
    }
    final String b = companyHcmReferenceId?.trim() ?? '';
    if (b.isNotEmpty) {
      return b;
    }
    return '';
  }
}

String? _readStringField(Map<String, dynamic> json, List<String> keys) {
  for (final String k in keys) {
    final Object? v = json[k];
    if (v == null) {
      continue;
    }
    final String s = v is String ? v : v.toString();
    final String t = s.trim();
    if (t.isNotEmpty && t != 'null') {
      return t;
    }
  }
  return null;
}
