import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';

class PortalQuickConnectPanel extends StatelessWidget {
  const PortalQuickConnectPanel({
    required this.experience,
    required this.onOpenLocations,
    required this.onOpenTelegramReward,
    super.key,
  });

  final PortalExperience experience;
  final VoidCallback onOpenLocations;
  final VoidCallback onOpenTelegramReward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = _primaryLocation(experience);

    return PortalSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick connect',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          Text(
            experience.subscription.isTrialLike ? 'Trial active' : 'Subscription active',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          Text(
            experience.dashboard.statusBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-select',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        location?.title ?? 'Auto-select',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Best server right now',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onOpenLocations,
                  child: const Text('Locations'),
                ),
              ],
            ),
          ),
          const Gap(16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PortalMetricTile(
                label: 'Remaining',
                value: formatPortalTraffic(experience.usage.remainingGb),
                caption: 'Available on this device',
                icon: Icons.shield_outlined,
              ),
              PortalMetricTile(
                label: 'Expires',
                value: formatPortalDate(experience.dashboard.expiresAt),
                caption: 'Trial or paid access window',
                icon: Icons.event_available_rounded,
              ),
            ],
          ),
          const Gap(16),
          OutlinedButton.icon(
            onPressed: onOpenTelegramReward,
            icon: const Icon(Icons.card_giftcard_rounded),
            label: const Text('+10 days for Telegram'),
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
