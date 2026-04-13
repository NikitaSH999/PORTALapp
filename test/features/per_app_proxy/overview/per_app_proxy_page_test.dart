import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/per_app_proxy_data_providers.dart';
import 'package:hiddify/features/per_app_proxy/data/per_app_proxy_repository.dart';
import 'package:hiddify/features/per_app_proxy/model/installed_package_info.dart';
import 'package:hiddify/features/per_app_proxy/overview/per_app_proxy_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/premium_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'per_app_proxy_mode': 'exclude',
      'per_app_proxy_exclude_list': ['org.telegram.messenger'],
    });
  });

  testWidgets('adds a curated preset without dropping manual selections', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      buildPremiumTestApp(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => preferences),
          perAppProxyRepositoryProvider.overrideWith(
            (ref) => _FakePerAppProxyRepository(
              packages: const [
                InstalledPackageInfo(
                  packageName: 'ru.sberbankmobile',
                  name: 'SberBank',
                  isSystemApp: false,
                ),
                InstalledPackageInfo(
                  packageName: 'ru.vtb24.mobilebanking.android',
                  name: 'VTB',
                  isSystemApp: false,
                ),
                InstalledPackageInfo(
                  packageName: 'ru.ozon.app.android',
                  name: 'Ozon',
                  isSystemApp: false,
                ),
                InstalledPackageInfo(
                  packageName: 'org.telegram.messenger',
                  name: 'Telegram',
                  isSystemApp: false,
                ),
              ],
            ),
          ),
        ],
        child: const PerAppProxyPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick direct picks'), findsOneWidget);
    expect(find.byKey(const Key('direct-preset-banks')), findsOneWidget);
    expect(find.byKey(const Key('direct-preset-marketplaces')), findsOneWidget);
    expect(find.byKey(const Key('direct-preset-telecom')), findsNothing);

    await tester.tap(find.byKey(const Key('direct-preset-banks')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(PerAppProxyPage)),
    );

    expect(
      container.read(perAppProxyListProvider),
      containsAll(<String>[
        'org.telegram.messenger',
        'ru.sberbankmobile',
        'ru.vtb24.mobilebanking.android',
      ]),
    );
  });
}

class _FakePerAppProxyRepository implements PerAppProxyRepository {
  _FakePerAppProxyRepository({required List<InstalledPackageInfo> packages})
      : _packages = packages;

  final List<InstalledPackageInfo> _packages;

  @override
  TaskEither<String, List<InstalledPackageInfo>> getInstalledPackages() {
    return TaskEither(() async => right(_packages));
  }

  @override
  TaskEither<String, Uint8List> getPackageIcon(String packageName) {
    return TaskEither(() async => right(base64Decode(_transparentPngBase64)));
  }
}

const _transparentPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+KDvN4AAAAABJRU5ErkJggg==';
