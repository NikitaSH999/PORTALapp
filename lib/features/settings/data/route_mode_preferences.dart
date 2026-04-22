import 'dart:io';

import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/data/selected_data_provider.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_backup.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/per_app_proxy/model/pkg_flag.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const routeModeChoiceCompletedKey = 'portal.route_mode_choice_completed';

enum ConsumerRouteMode {
  allTraffic,
  selectedApps,
}

List<String> normalizeRouteTargets(
  Iterable<String> values, {
  bool caseInsensitive = false,
}) {
  final seen = <String>{};
  final normalized = <String>[];

  for (final rawValue in values) {
    final value = rawValue.trim();
    if (value.isEmpty) continue;
    final dedupeKey = caseInsensitive ? value.toLowerCase() : value;
    if (!seen.add(dedupeKey)) continue;
    normalized.add(value);
  }

  return normalized;
}

bool isWindowsExecutableTarget(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  return trimmed.toLowerCase().endsWith('.exe');
}

bool shouldTreatRouteTargetsCaseInsensitively(Iterable<String> values) {
  return Platform.isWindows || values.any(isWindowsExecutableTarget);
}

abstract interface class RoutePolicySyncClient {
  Future<void> sync({
    required String routeMode,
    required List<String> selectedApps,
  });
}

class PortalRoutePolicySyncClient implements RoutePolicySyncClient {
  const PortalRoutePolicySyncClient(this._ref);

  final Ref _ref;

  @override
  Future<void> sync({
    required String routeMode,
    required List<String> selectedApps,
  }) async {
    await _ref
        .read(portalApiClientProvider)
        .postJson('/api/client/route-policy', {
      'route_mode': routeMode,
      'selected_apps': selectedApps,
    });
  }
}

final routePolicySyncClientProvider = Provider<RoutePolicySyncClient>(
  (ref) => PortalRoutePolicySyncClient(ref),
);

final routeModePreferencesProvider = Provider<RouteModePreferences>(
  (ref) => RouteModePreferences(ref),
);

final routeModeChoiceCompletedProvider = FutureProvider<bool>(
  (ref) async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return preferences.getBool(routeModeChoiceCompletedKey) ?? false;
  },
);

final consumerRouteModeProvider = Provider<ConsumerRouteMode>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider).valueOrNull;
  final rawMode = preferences?.getString('per_app_proxy_mode')?.trim();
  return rawMode == PerAppProxyMode.include.name
      ? ConsumerRouteMode.selectedApps
      : ConsumerRouteMode.allTraffic;
});

final consumerSelectedAppsProvider = Provider<List<String>>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider).valueOrNull;
  final rawValue = preferences?.getString('per_app_proxy_include_list');
  if (rawValue == null || rawValue.isEmpty) {
    return const <String>[];
  }

  return normalizeRouteTargets(
    rawValue.split(';'),
    caseInsensitive:
        shouldTreatRouteTargetsCaseInsensitively(rawValue.split(';')),
  );
});

final consumerRouteSelectionCountProvider = Provider<int>(
  (ref) => ref.watch(consumerSelectedAppsProvider).length,
);

class RouteModePreferences {
  const RouteModePreferences(this.ref);

  final Ref ref;

  Future<void> chooseAllTraffic() async {
    await ref
        .read(Preferences.perAppProxyMode.notifier)
        .update(PerAppProxyMode.off);
    await _markCompleted();
    await _syncRoutePolicy(
      routeMode: 'all_traffic',
      selectedApps: const <String>[],
    );
  }

  Future<void> chooseSelectedApps(List<String> packageNames) async {
    final caseInsensitive =
        shouldTreatRouteTargetsCaseInsensitively(packageNames);
    final normalized = normalizeRouteTargets(
      packageNames,
      caseInsensitive: caseInsensitive,
    )..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    if (normalized.isEmpty) return;

    await ref
        .read(Preferences.perAppProxyMode.notifier)
        .update(PerAppProxyMode.include);
    await ref.read(Preferences.includeApps.notifier).update(normalized);
    await _persistIncludeSelection(normalized);
    await _markCompleted();
    await _syncRoutePolicy(
      routeMode: 'selected_apps',
      selectedApps: normalized,
    );
  }

  Future<void> _persistIncludeSelection(List<String> selection) async {
    final dataSource = ref.read(appProxyDataSourceProvider);
    final includeDeselected = await dataSource.getPkgsByFlag(
      flag: PkgFlag.forceDeselection,
      mode: AppProxyMode.include,
    );
    final excludeSelected = await dataSource.getPkgsByFlag(
      flag: PkgFlag.userSelection,
      mode: AppProxyMode.exclude,
    );
    final excludeDeselected = await dataSource.getPkgsByFlag(
      flag: PkgFlag.forceDeselection,
      mode: AppProxyMode.exclude,
    );

    final includeDeselectedSet = includeDeselected.toSet()
      ..removeAll(selection);

    await dataSource.importPkgs(
      backup: PerAppProxyBackup(
        include: PerAppProxyBackupMode(
          selected: selection,
          deselected: includeDeselectedSet.toList(growable: false),
        ),
        exclude: PerAppProxyBackupMode(
          selected: excludeSelected,
          deselected: excludeDeselected,
        ),
      ),
    );
  }

  Future<void> _markCompleted() async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setBool(routeModeChoiceCompletedKey, true);
    ref.invalidate(routeModeChoiceCompletedProvider);
  }

  Future<void> _syncRoutePolicy({
    required String routeMode,
    required List<String> selectedApps,
  }) async {
    try {
      await ref.read(routePolicySyncClientProvider).sync(
            routeMode: routeMode,
            selectedApps: selectedApps,
          );
    } catch (_) {
      // Keep onboarding resilient if the portal route-policy endpoint is unavailable.
    }
  }
}
