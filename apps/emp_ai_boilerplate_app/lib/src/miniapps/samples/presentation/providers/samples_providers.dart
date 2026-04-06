import 'package:emp_ai_boilerplate_app/src/config/boilerplate_experimental_flags.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_remote_datasource_http.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_welcome_local_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_welcome_local_datasource_impl.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/repositories/samples_repository_impl.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/repositories/samples_repository.dart';
import 'package:emp_ai_boilerplate_app/src/network/boilerplate_api_client.dart';
import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final samplesRemoteDataSourceProvider = Provider<SamplesRemoteDataSource>(
  (ref) => kSamplesUseHttpRemoteDemo
      ? SamplesRemoteDataSourceHttp(ref.watch(boilerplateDioProvider))
      : const SamplesRemoteDataSourceImpl(),
);

final samplesWelcomeLocalDataSourceProvider =
    Provider<SamplesWelcomeLocalDataSource>(
  (ref) => SamplesWelcomeLocalDataSourceImpl(
    ref.watch(sharedPreferencesProvider),
  ),
);

final samplesRepositoryProvider = Provider<SamplesRepository>(
  (ref) => SamplesRepositoryImpl(
    ref.watch(samplesRemoteDataSourceProvider),
    ref.watch(samplesWelcomeLocalDataSourceProvider),
  ),
);
