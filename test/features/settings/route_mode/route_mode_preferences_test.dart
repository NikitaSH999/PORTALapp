import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/db/db.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/selected_data_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/app_proxy_data_source.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_backup.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/per_app_proxy/model/pkg_flag.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('normalizes Windows executable targets case-insensitively', () {
    expect(
      normalizeRouteTargets(
        [
          r'  C:\Program Files\Telegram Desktop\Telegram.exe  ',
          r'c:\program files\telegram desktop\telegram.exe',
          r'C:\Program Files\Spotify\Spotify.exe',
          '',
          '   ',
        ],
        caseInsensitive: true,
      ),
      [
        r'C:\Program Files\Telegram Desktop\Telegram.exe',
        r'C:\Program Files\Spotify\Spotify.exe',
      ],
    );
  });

  test('persists selected apps and posts the normalized route policy',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final fakeDataSource = _FakeAppProxyDataSource();
    final fakeSyncClient = _RecordingRoutePolicySyncClient();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => preferences),
        appProxyDataSourceProvider.overrideWith((ref) => fakeDataSource),
        routePolicySyncClientProvider.overrideWithValue(fakeSyncClient),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);

    await container.read(routeModePreferencesProvider).chooseSelectedApps([
      r'  C:\Program Files\Telegram Desktop\Telegram.exe  ',
      r'c:\program files\telegram desktop\telegram.exe',
      r'C:\Program Files\Spotify\Spotify.exe',
    ]);

    expect(
        container.read(Preferences.perAppProxyMode), PerAppProxyMode.include);
    expect(
      container.read(Preferences.includeApps),
      [
        r'C:\Program Files\Spotify\Spotify.exe',
        r'C:\Program Files\Telegram Desktop\Telegram.exe',
      ],
    );
    expect(preferences.getBool('portal.route_mode_choice_completed'), isTrue);
    expect(
      fakeDataSource.lastImportedBackup?.include.selected,
      [
        r'C:\Program Files\Spotify\Spotify.exe',
        r'C:\Program Files\Telegram Desktop\Telegram.exe',
      ],
    );
    expect(
      fakeSyncClient.calls,
      [
        const _RoutePolicyCall(
          routeMode: 'selected_apps',
          selectedApps: [
            r'C:\Program Files\Spotify\Spotify.exe',
            r'C:\Program Files\Telegram Desktop\Telegram.exe',
          ],
        ),
      ],
    );
  });

  test('switches back to all traffic without clearing saved split-tunnel picks',
      () async {
    SharedPreferences.setMockInitialValues({
      'per_app_proxy_mode': PerAppProxyMode.include.name,
      'per_app_proxy_include_list':
          r'C:\Program Files\Telegram Desktop\Telegram.exe',
    });
    final preferences = await SharedPreferences.getInstance();
    final fakeDataSource = _FakeAppProxyDataSource();
    final fakeSyncClient = _RecordingRoutePolicySyncClient();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => preferences),
        appProxyDataSourceProvider.overrideWith((ref) => fakeDataSource),
        routePolicySyncClientProvider.overrideWithValue(fakeSyncClient),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);

    await container.read(routeModePreferencesProvider).chooseAllTraffic();

    expect(container.read(Preferences.perAppProxyMode), PerAppProxyMode.off);
    expect(
      container.read(Preferences.includeApps),
      [r'C:\Program Files\Telegram Desktop\Telegram.exe'],
    );
    expect(
      fakeSyncClient.calls,
      [
        const _RoutePolicyCall(routeMode: 'all_traffic', selectedApps: []),
      ],
    );
  });
}

class _FakeAppProxyDataSource implements AppProxyDataSource {
  PerAppProxyBackup? lastImportedBackup;

  @override
  Future<void> applyAutoSelection({
    required Set<String> autoList,
    required AppProxyMode mode,
  }) async {}

  @override
  Future<int> clearAll({required AppProxyMode mode}) async => 0;

  @override
  Future<void> clearAutoSelected({required AppProxyMode mode}) async {}

  @override
  Future<List<String>> getPkgsByFlag({
    required PkgFlag flag,
    required AppProxyMode mode,
  }) async =>
      const [];

  @override
  Future<void> importPkgs({required PerAppProxyBackup backup}) async {
    lastImportedBackup = backup;
  }

  @override
  Future<void> revertForceDeselection({required AppProxyMode mode}) async {}

  @override
  Future<void> updatePkg({
    required String pkg,
    required AppProxyMode mode,
  }) async {}

  @override
  Stream<List<String>> watchActivePackages({
    required Set<String> phonePkgs,
    required AppProxyMode mode,
  }) =>
      const Stream.empty();

  @override
  Stream<List<AppProxyEntry>> watchAll({required AppProxyMode mode}) =>
      const Stream.empty();

  @override
  Stream<List<AppProxyEntry>> watchFilterForDisplay({
    required Set<String> phonePkgs,
    required AppProxyMode mode,
  }) =>
      const Stream.empty();
}

class _RecordingRoutePolicySyncClient implements RoutePolicySyncClient {
  final calls = <_RoutePolicyCall>[];

  @override
  Future<void> sync({
    required String routeMode,
    required List<String> selectedApps,
  }) async {
    calls.add(
      _RoutePolicyCall(
        routeMode: routeMode,
        selectedApps: List<String>.from(selectedApps),
      ),
    );
  }
}

class _RoutePolicyCall {
  const _RoutePolicyCall({
    required this.routeMode,
    required this.selectedApps,
  });

  final String routeMode;
  final List<String> selectedApps;

  @override
  bool operator ==(Object other) {
    return other is _RoutePolicyCall &&
        other.routeMode == routeMode &&
        _sameList(other.selectedApps, selectedApps);
  }

  @override
  int get hashCode => Object.hash(routeMode, Object.hashAll(selectedApps));

  static bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
