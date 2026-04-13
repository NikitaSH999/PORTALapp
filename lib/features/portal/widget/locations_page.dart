import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocationsPage extends HookConsumerWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            NestedAppBar(title: Text(copy.locationsTitle)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverToBoxAdapter(
                child: PortalAsyncBody(
                  value: experience,
                  builder: (context, portal) {
                    if (!portal.hasProvisionedAccess) {
                      return _LocationsLockedState(copy: copy);
                    }

                    if (portal.locations.isEmpty) {
                      return _LocationsSyncState(copy: copy);
                    }

                    final primary = _primaryLocation(portal);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PortalSectionCard(
                          tone: PortalSectionTone.accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PremiumSectionHeader(
                                eyebrow: copy.routingEyebrow,
                                title: copy.autoSelectTitle,
                                subtitle: copy.bestServerNow,
                              ),
                              const Gap(16),
                              PortalListRow(
                                title: primary != null
                                    ? copy.localizeServerText(primary.title)
                                    : copy.bestAvailable,
                                subtitle: primary != null
                                    ? copy.localizeServerText(primary.subtitle)
                                    : copy.bestServerNow,
                                leading: const PremiumIconOrb(
                                  icon: Icons.auto_awesome_rounded,
                                  size: 48,
                                ),
                                trailing: PortalStatusBadge(
                                  label: primary?.isActive == true
                                      ? copy.activeRoute
                                      : copy.recommended,
                                  icon: primary?.isActive == true
                                      ? Icons.check_rounded
                                      : Icons.auto_awesome_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        ...portal.locations.map(
                          (location) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PortalSectionCard(
                              tone: location.isActive
                                  ? PortalSectionTone.accent
                                  : PortalSectionTone.neutral,
                              child: PortalListRow(
                                title: copy.localizeServerText(location.title),
                                subtitle: copy.localizeServerText(
                                  location.subtitle,
                                ),
                                leading: PremiumIconOrb(
                                  icon: location.isActive
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  size: 46,
                                  accent: location.isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                trailing: PortalStatusBadge(
                                  label: location.isActive
                                      ? copy.selected
                                      : copy.available,
                                  icon: location.isActive
                                      ? Icons.check_rounded
                                      : Icons.place_outlined,
                                ),
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
      ),
    );
  }
}

class _LocationsLockedState extends StatelessWidget {
  const _LocationsLockedState({required this.copy});

  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    return PortalSectionCard(
      tone: PortalSectionTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(
            eyebrow: copy.routingEyebrow,
            title: copy.locationsGateTitle,
            subtitle: copy.locationsGateBody,
          ),
          const Gap(18),
          FilledButton.icon(
            onPressed: () => const HomeRoute().go(context),
            icon: const Icon(Icons.shield_rounded),
            label: Text(copy.openVpnAction),
          ),
        ],
      ),
    );
  }
}

class _LocationsSyncState extends StatelessWidget {
  const _LocationsSyncState({required this.copy});

  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    return PortalSectionCard(
      tone: PortalSectionTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumSectionHeader(
            eyebrow: copy.routingEyebrow,
            title: copy.locationsSyncTitle,
            subtitle: copy.locationsSyncBody,
          ),
          const Gap(18),
          OutlinedButton.icon(
            onPressed: () => const HomeRoute().go(context),
            icon: const Icon(Icons.shield_outlined),
            label: Text(copy.openVpnAction),
          ),
        ],
      ),
    );
  }
}

LocationRecord? _primaryLocation(PortalExperience experience) {
  for (final location in experience.locations) {
    if (location.isActive) return location;
  }
  return experience.locations.isEmpty ? null : experience.locations.first;
}
