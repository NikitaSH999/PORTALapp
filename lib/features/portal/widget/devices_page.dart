import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DevicesPage extends HookConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const NestedAppBar(title: Text('Devices')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: PortalAsyncBody(
                value: experience,
                builder: (context, portal) {
                  final freeSlots =
                      (portal.usage.deviceLimit - portal.usage.activeSessions)
                          .clamp(0, portal.usage.deviceLimit);
                  final currentDevice = _currentDevice(portal);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PortalSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current device',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Gap(8),
                            Text(
                              currentDevice?.title ?? portal.session.deviceName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Gap(4),
                            Text(
                              currentDevice?.subtitle.isNotEmpty == true
                                  ? currentDevice!.subtitle
                                  : 'This device is linked to your PORTAL VPN access.',
                            ),
                            const Gap(16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.link_rounded,
                                    label: 'Active sessions',
                                    value: portal.usage.activeSessions.toString(),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.devices_other_rounded,
                                    label: 'Available slots',
                                    value: freeSlots.toString(),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.cloud_done_outlined,
                                    label: 'Healthy nodes',
                                    value: portal.dashboard.connectionPointsLabel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      ...portal.devices.map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PortalSectionCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: device.title == portal.session.deviceName
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : null,
                                  child: Icon(
                                    device.isActive
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      Text(device.subtitle),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(device.platform),
                                    if (device.title == portal.session.deviceName)
                                      Text(
                                        'This device',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      PortalSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App downloads',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(12),
                            ...portal.downloads.map(
                              (target) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(target.platformLabel),
                                subtitle: Text(
                                  target.primaryUrl.isNotEmpty
                                      ? target.primaryUrl
                                      : 'No primary link configured yet',
                                ),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    if (target.primaryUrl.isNotEmpty)
                                      OutlinedButton(
                                        onPressed: () => launchPortalLink(
                                          context,
                                          target.primaryUrl,
                                        ),
                                        child: const Text('Primary'),
                                      ),
                                    if (target.mirrorUrl.isNotEmpty)
                                      OutlinedButton(
                                        onPressed: () => launchPortalLink(
                                          context,
                                          target.mirrorUrl,
                                        ),
                                        child: const Text('Mirror'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

DeviceRecord? _currentDevice(PortalExperience portal) {
  for (final device in portal.devices) {
    if (device.title == portal.session.deviceName) return device;
  }
  return portal.devices.isEmpty ? null : portal.devices.first;
}
