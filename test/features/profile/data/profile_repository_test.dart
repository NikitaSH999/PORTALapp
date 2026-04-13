import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/profile/data/profile_data_source.dart';
import 'package:hiddify/features/profile/data/profile_path_resolver.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';
import 'package:hiddify/features/profile/model/profile_failure.dart';
import 'package:hiddify/singbox/service/singbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fetch keeps subscription downloads on the app default user agent',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final workingDirectory = await Directory.systemTemp.createTemp(
      'profile-repository-test-',
    );
    addTearDown(() => workingDirectory.delete(recursive: true));

    final httpClient = _RecordingHttpClient();
    final repository = _TestProfileRepository(
      profileDataSource: _UnusedProfileDataSource(),
      profilePathResolver: ProfilePathResolver(workingDirectory),
      singbox: _UnusedSingboxService(),
      configOptionRepository: ConfigOptionRepository(
        preferences: preferences,
        getConfigOptions: () async => throw UnimplementedError(),
      ),
      httpClient: httpClient,
    );
    await repository.profilePathResolver.directory.create(recursive: true);

    final result = await repository
        .fetch(
          'https://example.com/subscription.txt',
          'profile',
        )
        .run();

    expect(result.fold((_) => false, (_) => true), isTrue);
    expect(httpClient.lastUserAgent, isNull);
  });
}

class _TestProfileRepository extends ProfileRepositoryImpl {
  _TestProfileRepository({
    required super.profileDataSource,
    required super.profilePathResolver,
    required super.singbox,
    required super.configOptionRepository,
    required super.httpClient,
  });

  @override
  TaskEither<ProfileFailure, Unit> validateConfig(
    String path,
    String tempPath,
    bool debug,
  ) {
    return TaskEither.right(unit);
  }
}

class _RecordingHttpClient extends DioHttpClient {
  _RecordingHttpClient()
      : super(
          timeout: Duration.zero,
          userAgent: 'POKROVVPN/2.0.0 (android; general)',
          debug: false,
        );

  String? lastUserAgent;

  @override
  Future<Response> download(
    String url,
    String path, {
    CancelToken? cancelToken,
    String? userAgent,
    ({String username, String password})? credentials,
    bool proxyOnly = false,
  }) async {
    lastUserAgent = userAgent;
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString('');

    return Response(
      requestOptions: RequestOptions(path: url),
      headers: Headers.fromMap({
        'profile-title': ['base64:VGVzdCBQcm9maWxl'],
        'profile-update-interval': ['1'],
        'subscription-userinfo': ['upload=0;download=0;total=1;expire=1'],
        'profile-web-page-url': ['https://example.com'],
        'support-url': ['https://example.com/support'],
      }),
    );
  }
}

class _UnusedProfileDataSource implements ProfileDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedSingboxService implements SingboxService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
