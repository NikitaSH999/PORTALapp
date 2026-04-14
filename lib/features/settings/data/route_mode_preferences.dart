import 'dart:io';

import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _routeModeChoiceCompletedKey = 'portal.route_mode_choice_completed';
const _perAppProxyModeKey = 'per_app_proxy_mode';
const _perAppProxyIncludeListKey = 'per_app_proxy_include_list';

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
    final key = caseInsensitive ? value.toLowerCase() : value;
    if (!seen.add(key)) continue;
    normalized.add(value);
  }

  return normalized;
}

bool isWindowsExecutableTarget(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  return trimmed.toLowerCase().endsWith('.exe');
}

final routeModePreferencesProvider = Provider<RouteModePreferences>(
  (ref) => RouteModePreferences(ref),
);

final routeModeChoiceCompletedProvider = FutureProvider<bool>(
  (ref) async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return preferences.getBool(_routeModeChoiceCompletedKey) ?? false;
  },
);

final consumerRouteModeProvider = Provider<ConsumerRouteMode>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider).valueOrNull;
  final rawMode = preferences?.getString(_perAppProxyModeKey)?.trim();
  return rawMode == PerAppProxyMode.include.name
      ? ConsumerRouteMode.selectedApps
      : ConsumerRouteMode.allTraffic;
});

final consumerSelectedAppsProvider = Provider<List<String>>(
  (ref) {
    final preferences = ref.watch(sharedPreferencesProvider).valueOrNull;
    final selected = preferences?.getStringList(_perAppProxyIncludeListKey);
    return selected ?? const <String>[];
  },
);

final consumerRouteSelectionCountProvider = Provider<int>(
  (ref) => ref.watch(consumerSelectedAppsProvider).length,
);

class RouteModePreferences {
  RouteModePreferences(this.ref);

  final Ref ref;

  Future<void> chooseAllTraffic() async {
    await ref.read(Preferences.perAppProxyMode.notifier).update(
          PerAppProxyMode.off,
        );
    await _markCompleted();
    await _syncRoutePolicy(
      routeMode: 'all_traffic',
      selectedApps: const <String>[],
    );
  }

  Future<void> chooseSelectedApps(List<String> packageNames) async {
    final normalized = normalizeRouteTargets(
      packageNames,
      caseInsensitive: Platform.isWindows,
    )..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    if (normalized.isEmpty) return;

    await ref.read(Preferences.perAppProxyMode.notifier).update(
          PerAppProxyMode.include,
        );
    await ref.read(perAppProxyListProvider.notifier).update(normalized);
    await _markCompleted();
    await _syncRoutePolicy(
      routeMode: 'selected_apps',
      selectedApps: normalized,
    );
  }

  Future<void> _markCompleted() async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    await preferences.setBool(_routeModeChoiceCompletedKey, true);
    ref.invalidate(routeModeChoiceCompletedProvider);
  }

  Future<void> _syncRoutePolicy({
    required String routeMode,
    required List<String> selectedApps,
  }) async {
    try {
      await ref
          .read(portalApiClientProvider)
          .postJson('/api/client/route-policy', {
        'route_mode': routeMode,
        'selected_apps': selectedApps,
      });
    } catch (_) {
      // Keep onboarding resilient when the policy endpoint is unavailable.
    }
  }
}
