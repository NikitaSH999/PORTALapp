import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/settings/route_mode/route_mode_page.dart';

class RouteModeSetupGateCard extends StatelessWidget {
  const RouteModeSetupGateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PortalSectionCard(
      tone: PortalSectionTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumSectionHeader(
            eyebrow: 'Route mode',
            title: 'How should this device be optimized?',
            subtitle:
                'Choose between Optimize everything on this device and Only selected apps before the first optimized session.',
          ),
          const Gap(14),
          FilledButton(
            onPressed: () => showRouteModePage(context, requiredSetup: true),
            child: const Text('Set up route mode'),
          ),
        ],
      ),
    );
  }
}
