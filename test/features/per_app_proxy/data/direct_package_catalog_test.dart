import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/per_app_proxy/data/direct_package_catalog.dart';
import 'package:hiddify/features/per_app_proxy/model/app_package_info.dart';

void main() {
  test('resolves direct presets from the installed Android packages', () {
    final resolved = resolveDirectPackagePresets(
      installedPackages: const [
        AppPackageInfo(
          packageName: 'ru.sberbankmobile',
          name: 'Sber',
          icon: null,
        ),
        AppPackageInfo(
          packageName: 'ru.yoomoney',
          name: 'YooMoney',
          icon: null,
        ),
      ],
    );

    expect(resolved.map((preset) => preset.id), ['banks', 'payments']);
    expect(resolved.first.packageNames, ['ru.sberbankmobile']);
  });

  test('applies preset packages without duplicating existing selections', () {
    expect(
      applyDirectPackagePreset(
        currentSelection: const ['ru.sberbankmobile'],
        presetPackages: const ['ru.sberbankmobile', 'ru.yoomoney'],
      ),
      ['ru.sberbankmobile', 'ru.yoomoney'],
    );
  });
}
