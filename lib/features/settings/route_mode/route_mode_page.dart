import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/per_app_proxy/data/direct_package_catalog.dart';
import 'package:hiddify/features/per_app_proxy/data/route_mode_target_catalog.dart';
import 'package:hiddify/features/per_app_proxy/model/app_package_info.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RouteModePage extends HookConsumerWidget {
  const RouteModePage({
    super.key,
    this.requiredSetup = false,
  });

  final bool requiredSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed =
        ref.watch(routeModeChoiceCompletedProvider).valueOrNull ?? false;
    final currentMode = ref.watch(consumerRouteModeProvider);
    final currentSelection = ref.watch(consumerSelectedAppsProvider);
    final targetsAsync = ref.watch(routeModeTargetsProvider);

    final selectedMode = useState<ConsumerRouteMode?>(null);
    final draftSelection = useState<Set<String>>(<String>{});
    final hasLocalEdits = useState(false);
    final isSaving = useState(false);

    useEffect(() {
      if (hasLocalEdits.value || isSaving.value) {
        return null;
      }

      selectedMode.value =
          completed ? currentMode : ConsumerRouteMode.allTraffic;
      draftSelection.value = currentSelection.toSet();
      return null;
    }, [
      completed,
      currentMode,
      Object.hashAll(currentSelection),
      hasLocalEdits.value,
      isSaving.value,
    ]);

    Future<void> saveAllTraffic() async {
      if (isSaving.value) return;
      isSaving.value = true;
      await ref.read(routeModePreferencesProvider).chooseAllTraffic();
      isSaving.value = false;
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    }

    Future<void> saveSelectedApps() async {
      if (isSaving.value || draftSelection.value.isEmpty) return;
      isSaving.value = true;
      await ref.read(routeModePreferencesProvider).chooseSelectedApps(
            draftSelection.value.toList(growable: false),
          );
      isSaving.value = false;
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    }

    void toggleSelection(String target) {
      hasLocalEdits.value = true;
      final nextSelection = draftSelection.value.toSet();
      if (!nextSelection.add(target)) {
        nextSelection.remove(target);
      }
      draftSelection.value = nextSelection;
    }

    final targets = targetsAsync.valueOrNull ?? const <AppPackageInfo>[];
    final hasExecutableTargets = Platform.isWindows ||
        targets.any((target) => isWindowsExecutableTarget(target.packageName));
    final presets = hasExecutableTargets
        ? const <ResolvedDirectPackagePreset>[]
        : resolveDirectPackagePresets(installedPackages: targets);

    return PopScope(
      canPop: !requiredSetup || completed,
      child: Scaffold(
        appBar: AppBar(title: const Text('Route mode')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Choose how POKROV routes traffic on this device.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(16),
            RadioListTile<ConsumerRouteMode>(
              value: ConsumerRouteMode.allTraffic,
              groupValue: selectedMode.value,
              title: const Text('Optimize everything on this device'),
              subtitle: const Text(
                  'Use the consumer-safe route preset for all traffic on this device.'),
              onChanged: (_) {
                hasLocalEdits.value = true;
                selectedMode.value = ConsumerRouteMode.allTraffic;
              },
            ),
            RadioListTile<ConsumerRouteMode>(
              value: ConsumerRouteMode.selectedApps,
              groupValue: selectedMode.value,
              title: const Text('Only selected apps'),
              subtitle: Text(
                hasExecutableTargets
                    ? 'Send only the .exe files you choose through POKROV.'
                    : 'Choose the apps that should use POKROV. Everything else stays direct.',
              ),
              onChanged: (_) {
                hasLocalEdits.value = true;
                selectedMode.value = ConsumerRouteMode.selectedApps;
              },
            ),
            if (selectedMode.value == ConsumerRouteMode.selectedApps) ...[
              const Gap(8),
              if (hasExecutableTargets)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () async {
                      final executable = await _showExecutableDialog(context);
                      if (executable == null) return;
                      hasLocalEdits.value = true;
                      draftSelection.value = normalizeRouteTargets(
                        [...draftSelection.value, executable],
                        caseInsensitive: true,
                      ).toSet();
                    },
                    child: const Text('Add .exe file'),
                  ),
                ),
              if (presets.isNotEmpty) ...[
                const Gap(12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final preset in presets)
                      FilterChip(
                        label: Text(preset.title),
                        selected: preset.isApplied(draftSelection.value),
                        onSelected: (_) {
                          hasLocalEdits.value = true;
                          draftSelection.value = applyDirectPackagePreset(
                            currentSelection: draftSelection.value,
                            presetPackages: preset.packageNames,
                          ).toSet();
                        },
                      ),
                  ],
                ),
              ],
              const Gap(12),
              targetsAsync.when(
                data: (value) {
                  final visibleTargets = value.toList(growable: false)
                    ..sort(
                      (left, right) => left.name
                          .toLowerCase()
                          .compareTo(right.name.toLowerCase()),
                    );
                  return Column(
                    children: [
                      for (final target in visibleTargets)
                        CheckboxListTile(
                          value:
                              draftSelection.value.contains(target.packageName),
                          title: Text(target.name),
                          subtitle: Text(target.packageName),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => toggleSelection(target.packageName),
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                      'Unable to load apps for route selection right now.'),
                ),
              ),
              const Gap(8),
              Text('Selected items: ${draftSelection.value.length}'),
            ],
            const Gap(24),
            FilledButton(
              onPressed: isSaving.value
                  ? null
                  : selectedMode.value == ConsumerRouteMode.selectedApps
                      ? (draftSelection.value.isEmpty ? null : saveSelectedApps)
                      : selectedMode.value == ConsumerRouteMode.allTraffic
                          ? saveAllTraffic
                          : null,
              child: Text(
                selectedMode.value == ConsumerRouteMode.selectedApps
                    ? 'Use only selected apps'
                    : 'Optimize everything on this device',
              ),
            ),
            if (!requiredSetup) ...[
              const Gap(12),
              OutlinedButton(
                onPressed: isSaving.value
                    ? null
                    : () => Navigator.of(context).maybePop(),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> _showExecutableDialog(BuildContext context) async {
  final controller = TextEditingController();
  String? errorText;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add .exe file'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: r'C:\Program Files\Telegram Desktop\Telegram.exe',
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final candidate = controller.text.trim();
                  if (!isWindowsExecutableTarget(candidate)) {
                    setState(() {
                      errorText = 'Enter a valid .exe path.';
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(candidate);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
