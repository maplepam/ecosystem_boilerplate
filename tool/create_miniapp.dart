// Scaffolds a new mini-app folder + appends miniapps_registry.yaml.
// Usage (from ecosystem_boilerplate): dart run tool/create_miniapp.dart my_feature

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/create_miniapp.dart <snake_case_name>\n'
      'Example: dart run tool/create_miniapp.dart rewards',
    );
    exit(64);
  }

  final String snake = args.first.toLowerCase().replaceAll('-', '_');
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(snake)) {
    stderr.writeln('Name must be snake_case alphanumeric + underscore.');
    exit(1);
  }

  final String pascal = _toPascalCase(snake);
  final String root = Directory.current.path;
  final String appLib = p.join(
    root,
    'apps/emp_ai_boilerplate_app/lib/src/miniapps',
    snake,
  );

  await Directory(p.join(appLib, 'domain/entities')).create(recursive: true);
  await Directory(p.join(appLib, 'domain/repositories')).create(recursive: true);
  await Directory(p.join(appLib, 'data/datasources')).create(recursive: true);
  await Directory(p.join(appLib, 'data/repositories')).create(recursive: true);
  await Directory(p.join(appLib, 'presentation/providers')).create(
    recursive: true,
  );

  final String miniAppClass = '${pascal}MiniApp';
  final String screenClass = '${pascal}HomeScreen';
  await File(p.join(appLib, 'domain/entities/${snake}_entity.dart')).writeAsString('''
/// Domain entity — no Flutter imports.
final class ${pascal}Entity {
  const ${pascal}Entity(this.title);

  final String title;
}
''');

  await File(
    p.join(appLib, 'domain/repositories/${snake}_repository.dart'),
  ).writeAsString('''
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/domain/entities/${snake}_entity.dart';

abstract interface class ${pascal}Repository {
  Future<${pascal}Entity> load();
}
''');

  await File(
    p.join(appLib, 'data/datasources/${snake}_remote_datasource.dart'),
  ).writeAsString('''
abstract interface class ${pascal}RemoteDataSource {
  Future<String> fetchTitle();
}

final class ${pascal}RemoteDataSourceImpl implements ${pascal}RemoteDataSource {
  const ${pascal}RemoteDataSourceImpl();

  @override
  Future<String> fetchTitle() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return 'Hello from $snake';
  }
}
''');

  await File(
    p.join(appLib, 'data/repositories/${snake}_repository_impl.dart'),
  ).writeAsString('''
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/data/datasources/${snake}_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/domain/entities/${snake}_entity.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/domain/repositories/${snake}_repository.dart';

final class ${pascal}RepositoryImpl implements ${pascal}Repository {
  const ${pascal}RepositoryImpl(this._remote);

  final ${pascal}RemoteDataSource _remote;

  @override
  Future<${pascal}Entity> load() async {
    final String title = await _remote.fetchTitle();
    return ${pascal}Entity(title);
  }
}
''');

  await File(
    p.join(appLib, 'presentation/providers/${snake}_providers.dart'),
  ).writeAsString('''
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/data/datasources/${snake}_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/data/repositories/${snake}_repository_impl.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/domain/repositories/${snake}_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ${snake}RemoteDataSourceProvider = Provider<${pascal}RemoteDataSource>(
  (ref) => const ${pascal}RemoteDataSourceImpl(),
);

final ${snake}RepositoryProvider = Provider<${pascal}Repository>(
  (ref) => ${pascal}RepositoryImpl(ref.watch(${snake}RemoteDataSourceProvider)),
);
''');

  await File(
    p.join(appLib, 'presentation/providers/${snake}_home_notifier.dart'),
  ).writeAsString('''
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/domain/entities/${snake}_entity.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/presentation/providers/${snake}_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ${pascal}HomeNotifier extends AsyncNotifier<${pascal}Entity> {
  @override
  Future<${pascal}Entity> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<${pascal}Entity> _load() async {
    return ref.read(${snake}RepositoryProvider).load();
  }
}

final ${snake}HomeNotifierProvider =
    AsyncNotifierProvider<${pascal}HomeNotifier, ${pascal}Entity>(
  ${pascal}HomeNotifier.new,
);
''');

  await File(p.join(appLib, 'presentation/${snake}_home_screen.dart')).writeAsString('''
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/domain/entities/${snake}_entity.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/presentation/providers/${snake}_home_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class $screenClass extends ConsumerWidget {
  const $screenClass({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(${snake}HomeNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: Center(
        child: async.when(
          data: (${pascal}Entity e) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.title),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Hub'),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text(err.toString()),
        ),
      ),
    );
  }
}
''');

  await File(p.join(appLib, '${snake}_miniapp.dart')).writeAsString('''
import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/$snake/presentation/${snake}_home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final class $miniAppClass extends MiniApp with MiniAppAlwaysOn {
  $miniAppClass();

  @override
  String get id => '$snake';

  @override
  String get displayName => '$pascal';

  @override
  String get entryLocation => '/$snake/home';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) =>
              const $screenClass(),
        ),
      ];
}
''');

  await _appendRegistry(root, snake, miniAppClass);

  stdout.writeln('Created $appLib');
  stdout.writeln('Run: melos run generate:miniapps');
}

String _toPascalCase(String snake) {
  return snake.split('_').map((String s) {
    if (s.isEmpty) {
      return '';
    }
    return s[0].toUpperCase() + s.substring(1);
  }).join();
}

Future<void> _appendRegistry(String root, String snake, String symbol) async {
  final File reg = File(p.join(root, 'miniapps_registry.yaml'));
  final String text = await reg.readAsString();
  final dynamic doc = loadYaml(text);
  if (doc is! YamlMap || doc['entries'] is! YamlList) {
    stderr.writeln('Could not parse miniapps_registry.yaml');
    exit(1);
  }

  final String import =
      'package:emp_ai_boilerplate_app/src/miniapps/$snake/${snake}_miniapp.dart';
  if (text.contains(import)) {
    stdout.writeln('Registry already lists $import — skipped append.');
    return;
  }

  await reg.writeAsString(
    '${text.trimRight()}\n  - import: $import\n    symbol: $symbol\n',
  );
}
