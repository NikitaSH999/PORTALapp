import 'dart:collection';

import 'package:hiddify/features/per_app_proxy/model/app_package_info.dart';

const packageCatalogVersion = '2026.04.13';

class DirectPackageCatalogEntry {
  const DirectPackageCatalogEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.packageNames,
  });

  final String id;
  final String title;
  final String description;
  final List<String> packageNames;
}

class ResolvedDirectPackagePreset {
  const ResolvedDirectPackagePreset({
    required this.id,
    required this.title,
    required this.description,
    required this.apps,
  });

  final String id;
  final String title;
  final String description;
  final List<AppPackageInfo> apps;

  List<String> get packageNames =>
      apps.map((package) => package.packageName).toList(growable: false);

  bool isApplied(Iterable<String> selection) {
    final selectedPackages = selection.toSet();
    return packageNames.every(selectedPackages.contains);
  }
}

const directPackageCatalog = <DirectPackageCatalogEntry>[
  DirectPackageCatalogEntry(
    id: 'banks',
    title: 'Banks',
    description: 'Common banking apps that often work better direct.',
    packageNames: [
      'ru.sberbankmobile',
      'ru.onlinesberbankmobile',
      'ru.vtb24.mobilebanking.android',
      'ru.alfabank.mobile.android',
      'ru.raiffeisen.rmobile',
      'ru.tinkoff.mb',
    ],
  ),
  DirectPackageCatalogEntry(
    id: 'payments',
    title: 'Payments',
    description: 'Wallets and payment tools that can be sensitive to VPN hops.',
    packageNames: [
      'ru.mirpay.android',
      'ru.yoomoney',
      'ru.qiwi.wallet',
      'com.samsung.android.spay',
      'com.yandex.pay',
    ],
  ),
  DirectPackageCatalogEntry(
    id: 'marketplaces',
    title: 'Marketplaces',
    description: 'Shopping and delivery apps that benefit from fast local paths.',
    packageNames: [
      'ru.ozon.app.android',
      'com.wildberries.ru',
      'ru.yandex.market',
      'com.avito.android',
      'ru.sbermarket.mobile',
    ],
  ),
  DirectPackageCatalogEntry(
    id: 'telecom',
    title: 'Telecom',
    description: 'Carrier apps used for top-ups, SIM control, and support.',
    packageNames: [
      'ru.beeline.services',
      'ru.mts',
      'ru.megafon.mlk',
      'ru.tele2.mobile',
    ],
  ),
  DirectPackageCatalogEntry(
    id: 'gov_media',
    title: 'Gov & media',
    description: 'Public services and local media apps worth keeping easy to reach.',
    packageNames: [
      'ru.gosuslugi.android',
      'ru.gosuslugi.pos',
      'com.vkontakte.android',
      'ru.rutube.app',
      'ru.smi2',
    ],
  ),
];

List<ResolvedDirectPackagePreset> resolveDirectPackagePresets({
  required Iterable<AppPackageInfo> installedPackages,
}) {
  final installedByPackageName = {
    for (final package in installedPackages) package.packageName: package,
  };

  return [
    for (final entry in directPackageCatalog)
      if (entry.packageNames.where(installedByPackageName.containsKey).isNotEmpty)
        ResolvedDirectPackagePreset(
          id: entry.id,
          title: entry.title,
          description: entry.description,
          apps: [
            for (final packageName in entry.packageNames)
              if (installedByPackageName[packageName] case final package?)
                package,
          ],
        ),
  ];
}

List<String> applyDirectPackagePreset({
  required Iterable<String> currentSelection,
  required Iterable<String> presetPackages,
}) {
  final selection = LinkedHashSet<String>.of(currentSelection)
    ..addAll(presetPackages);
  return selection.toList(growable: false);
}
