import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/db/db.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/app_proxy_data_source.dart';
import 'package:hiddify/features/per_app_proxy/data/route_mode_target_catalog.dart';
import 'package:hiddify/features/per_app_proxy/data/selected_data_provider.dart';
import 'package:hiddify/features/per_app_proxy/model/app_package_info.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_backup.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/per_app_proxy/model/pkg_flag.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
import 'package:hiddify/features/settings/route_mode/route_mode_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'lets Windows users pick selected executables from the route-mode page',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
          routeModeTargetCatalogProvider.overrideWithValue(
            _FakeRouteModeTargetCatalog(
              const [
                AppPackageInfo(
                  packageName:
                      r'C:\Program Files\Telegram Desktop\Telegram.exe',
                  name: 'Telegram',
                  icon: null,
                ),
              ],
            ),
          ),
          appProxyDataSourceProvider.overrideWith(
            (ref) => _FakeAppProxyDataSource(),
          ),
          routePolicySyncClientProvider.overrideWithValue(
            const _NoopRoutePolicySyncClient(),
          ),
        ],
        child: const MaterialApp(
          home: RouteModePage(requiredSetup: true),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Optimize everything on this device'), findsWidgets);
    expect(find.text('Only selected apps'), findsOneWidget);

    await tester.tap(find.text('Only selected apps').first);
    await tester.pumpAndSettle();

    expect(find.text('Add .exe file'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(FilledButton, 'Use only selected apps'));
    await tester.pumpAndSettle();

    expect(preferences.getString('per_app_proxy_mode'),
        PerAppProxyMode.include.name);
    expect(
      preferences.getString('per_app_proxy_include_list'),
      r'C:\Program Files\Telegram Desktop\Telegram.exe',
    );
    expect(preferences.getBool('portal.route_mode_choice_completed'), isTrue);
  });
}

class _FakeRouteModeTargetCatalog implements RouteModeTargetCatalog {
  const _FakeRouteModeTargetCatalog(this.targets);

  final List<AppPackageInfo> targets;

  @override
  Future<List<AppPackageInfo>> loadTargets() async => targets;
}

class _NoopRoutePolicySyncClient implements RoutePolicySyncClient {
  const _NoopRoutePolicySyncClient();

  @override
  Future<void> sync({
    required String routeMode,
    required List<String> selectedApps,
  }) async {}
}

class _FakeAppProxyDataSource implements AppProxyDataSource {
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
  Future<void> importPkgs({required PerAppProxyBackup backup}) async {}

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
