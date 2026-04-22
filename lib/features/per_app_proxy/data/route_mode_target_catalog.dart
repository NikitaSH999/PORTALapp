import 'dart:io';

import 'package:hiddify/features/per_app_proxy/data/windows_executable_catalog.dart';
import 'package:hiddify/features/per_app_proxy/model/app_package_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:installed_apps/index.dart';

abstract interface class RouteModeTargetCatalog {
  Future<List<AppPackageInfo>> loadTargets();
}

class DeviceRouteModeTargetCatalog implements RouteModeTargetCatalog {
  const DeviceRouteModeTargetCatalog();

  @override
  Future<List<AppPackageInfo>> loadTargets() async {
    if (Platform.isWindows) {
      return discoverWindowsExecutables();
    }

    final installedApps = await InstalledApps.getInstalledApps(false, true);
    final targets = installedApps
        .map(
          (app) => AppPackageInfo(
            packageName: app.packageName,
            name: app.name,
            icon: app.icon,
          ),
        )
        .toList(growable: false)
      ..sort((left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()));

    return targets;
  }
}

final routeModeTargetCatalogProvider = Provider<RouteModeTargetCatalog>(
  (ref) => const DeviceRouteModeTargetCatalog(),
);

final routeModeTargetsProvider = FutureProvider<List<AppPackageInfo>>(
  (ref) => ref.watch(routeModeTargetCatalogProvider).loadTargets(),
);
