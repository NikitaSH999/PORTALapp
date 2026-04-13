import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/per_app_proxy/data/direct_package_catalog.dart';
import 'package:hiddify/features/per_app_proxy/model/installed_package_info.dart';

void main() {
  test('catalog presets only surface categories that match installed apps', () {
    final installedPackages = [
      const InstalledPackageInfo(
        packageName: 'ru.sberbankmobile',
        name: 'SberBank',
        isSystemApp: false,
      ),
      const InstalledPackageInfo(
        packageName: 'ru.ozon.app.android',
        name: 'Ozon',
        isSystemApp: false,
      ),
      const InstalledPackageInfo(
        packageName: 'org.telegram.messenger',
        name: 'Telegram',
        isSystemApp: false,
      ),
    ];

    final presets = resolveDirectPackagePresets(
      installedPackages: installedPackages,
    );

    expect(presets.map((preset) => preset.id), ['banks', 'marketplaces']);
    expect(
      presets.first.packageNames,
      ['ru.sberbankmobile'],
    );
    expect(
      presets.last.packageNames,
      ['ru.ozon.app.android'],
    );
  });

  test('applying a preset preserves manual picks and appends only missing apps',
      () {
    final selection = applyDirectPackagePreset(
      currentSelection: const [
        'org.telegram.messenger',
        'ru.sberbankmobile',
      ],
      presetPackages: const [
        'ru.sberbankmobile',
        'ru.vtb24.mobilebanking.android',
      ],
    );

    expect(
      selection,
      [
        'org.telegram.messenger',
        'ru.sberbankmobile',
        'ru.vtb24.mobilebanking.android',
      ],
    );
  });
}
