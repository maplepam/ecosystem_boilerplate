import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/announcements_api_paths.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/announcements_list_request_body.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/dtos/announcement_dto.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';

/// Emapta **announcement-bl** V2: `POST /announcement/published/list` and
/// `POST /announcement/published/detail` (same as `announcement_module` datasources).
final class AnnouncementsRemoteDataSourceHttp
    implements AnnouncementsRemoteDataSource {
  AnnouncementsRemoteDataSourceHttp(
    this._dio, {
    required String baseUrl,
  }) : _baseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  final Dio _dio;
  final String _baseUrl;

  String _url(String path) {
    final String p = path.startsWith('/') ? path : '/$path';
    return '$_baseUrl$p';
  }

  @override
  Future<List<AnnouncementDto>> fetchPublishedListPage(
    AnnouncementsListPageQuery query,
  ) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      _url(AnnouncementsApiPaths.publishedList),
      data: announcementsPublishedListBody(query),
    );
    final Map<String, dynamic> map = _requireEnvelopeMap(response.data);
    _ensureStatusOk(map);
    final List<Map<String, dynamic>> rows = _extractListRows(map);
    return rows
        .map(AnnouncementDto.fromEmaptaPublishedItem)
        .toList(growable: false);
  }

  @override
  Future<AnnouncementDto?> fetchPublishedDetail(
    String announcementId,
    EmployeeAssignmentAnnouncementWire recipientWire,
  ) async {
    if (announcementId.isEmpty) {
      return null;
    }
    final Response<dynamic> response = await _dio.post<dynamic>(
      _url(AnnouncementsApiPaths.publishedDetail),
      data: announcementsPublishedDetailBody(
        announcementId,
        recipientWire,
      ),
    );
    final Map<String, dynamic> map = _requireEnvelopeMap(response.data);
    _ensureStatusOk(map);
    final Object? data = map['data'];
    if (data is! Map) {
      return null;
    }
    return AnnouncementDto.fromEmaptaPublishedItem(
      Map<String, dynamic>.from(data),
    );
  }
}

Map<String, dynamic> _requireEnvelopeMap(dynamic raw) {
  final Object? decoded = _decodeIfNeeded(raw);
  if (decoded is Map) {
    return Map<String, dynamic>.from(decoded);
  }
  throw FormatException(
    'Announcements API: expected JSON object, got ${decoded.runtimeType}',
  );
}

Object? _decodeIfNeeded(dynamic raw) {
  if (raw is String) {
    return jsonDecode(raw);
  }
  return raw;
}

void _ensureStatusOk(Map<String, dynamic> map) {
  final Object? sc = map['status_code'];
  if (sc is int && (sc == 200 || sc == 201)) {
    return;
  }
  throw FormatException('Announcements API: bad status_code ($sc)');
}

List<Map<String, dynamic>> _extractListRows(Map<String, dynamic> envelope) {
  final Object? data = envelope['data'];
  if (data is! Map) {
    return <Map<String, dynamic>>[];
  }
  final Map<String, dynamic> dataMap = Map<String, dynamic>.from(data);
  final Object? list = dataMap['data'];
  if (list is! List<dynamic>) {
    return <Map<String, dynamic>>[];
  }
  return list
      .map(
        (dynamic e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
      )
      .toList(growable: false);
}
