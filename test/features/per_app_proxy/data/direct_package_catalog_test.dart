import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/per_app_proxy/data/direct_package_catalog.dart';

void main() {
  test('catalog exposes canonical public version and categories', () {
    expect(packageCatalogVersion, isNotEmpty);
    expect(
      directPackageCatalog.map((item) => item.id),
      containsAll(<String>[
        'banks',
        'payments',
        'marketplaces',
        'telecom',
        'gov_media',
      ]),
    );
  });

  test('catalog keeps high-signal RU apps available for one-tap direct presets',
      () {
    final packages =
        directPackageCatalog.expand((item) => item.packageNames).toSet();

    expect(packages, contains('ru.sberbankmobile'));
    expect(packages, contains('ru.vtb24.mobilebanking.android'));
    expect(packages, contains('ru.ozon.app.android'));
    expect(packages, contains('ru.onlinesberbankmobile'));
    expect(packages, contains('ru.yandex.market'));
  });
}
