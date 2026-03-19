import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocationsPage extends HookConsumerWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const NestedAppBar(title: Text('Locations')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: PortalAsyncBody(
                value: experience,
                builder: (context, portal) {
                  final primary = _primaryLocation(portal);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PortalSectionCard(
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-select',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    primary?.title ?? 'Auto-select',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    'Best server right now',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Use'),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      ...portal.devices.map(
                        (location) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PortalSectionCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: location.isActive
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    location.isActive
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: location.isActive
                                        ? Theme.of(context).colorScheme.onPrimaryContainer
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location.title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(location.subtitle),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: location.isActive
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  ),
                                  child: Text(
                                    location.isActive ? 'Selected' : 'Available',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DeviceRecord? _primaryLocation(PortalExperience experience) {
  for (final device in experience.devices) {
    if (device.isActive) return device;
  }
  return experience.devices.isEmpty ? null : experience.devices.first;
}
