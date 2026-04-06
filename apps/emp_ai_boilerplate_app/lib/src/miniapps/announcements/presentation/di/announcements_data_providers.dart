import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_profile_id_notifier.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_read_local_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_read_local_datasource_impl.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_remote_datasource_http.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/repositories/announcement_media_repository_impl.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/repositories/announcements_repository_impl.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/repositories/announcement_media_repository.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/repositories/announcements_repository.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_flavor_providers.dart';
import 'package:emp_ai_boilerplate_app/src/network/boilerplate_api_client.dart';
import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full **announcement-bl** base URL (no trailing slash). Non-empty
/// `ANNOUNCEMENT_SERVICE_BASE_URL` overrides flavor defaults.
final announcementsServiceBaseUrlProvider = Provider<String>(
  (ref) {
    const String override = String.fromEnvironment(
      'ANNOUNCEMENT_SERVICE_BASE_URL',
      defaultValue: '',
    );
    final String trimmed = override.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return ref
        .watch(boilerplateFlavorEndpointsProvider)
        .announcementServiceBaseUrl;
  },
);

/// Resolved **recipient wire** for announcement-bl V2 POST bodies (emapta
/// `AnnouncementRecipient` list). Empty fields until
/// [employeeAssignmentAnnouncementWireProvider] completes.
final announcementsRecipientWireProvider =
    Provider<EmployeeAssignmentAnnouncementWire>(
  (Ref ref) {
    return ref.watch(employeeAssignmentAnnouncementWireProvider).valueOrNull ??
        const EmployeeAssignmentAnnouncementWire.empty();
  },
);

/// Remote: **POST** to emapta V2 paths on [announcementsServiceBaseUrlProvider]
/// via host [Dio] (auth / interceptors).
final announcementsRemoteDataSourceProvider =
    Provider<AnnouncementsRemoteDataSource>(
  (ref) => AnnouncementsRemoteDataSourceHttp(
    ref.watch(boilerplateDioProvider),
    baseUrl: ref.watch(announcementsServiceBaseUrlProvider),
  ),
);

final announcementsReadLocalDataSourceProvider =
    Provider<AnnouncementsReadLocalDataSource>(
  (ref) => AnnouncementsReadLocalDataSourceImpl(
    ref.watch(sharedPreferencesProvider),
  ),
);

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepositoryImpl(
    ref.watch(announcementsRemoteDataSourceProvider),
    ref.watch(announcementsReadLocalDataSourceProvider),
  ),
);

/// Resolves `thumbnail_id` / `content_image_id` via emapta
/// `POST {announcement-bl}/media/assets/files`.
final announcementMediaRepositoryProvider =
    Provider<AnnouncementMediaRepository>(
  (ref) => AnnouncementMediaRepositoryImpl(
    ref.watch(boilerplateDioProvider),
    announcementServiceBaseUrl: ref.watch(announcementsServiceBaseUrlProvider),
  ),
);
