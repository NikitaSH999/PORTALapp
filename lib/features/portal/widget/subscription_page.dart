import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubscriptionPage extends HookConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const NestedAppBar(title: Text('Subscription')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: PortalAsyncBody(
                value: experience,
                builder: (context, portal) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PortalSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              portal.subscription.currentPlanLabel,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Gap(8),
                            Text(
                              portal.subscription.isTrialLike
                                  ? 'Upgrade without leaving the app shell.'
                                  : 'Manage renewal, payment and access from one place.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Gap(16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.event_available_rounded,
                                    label: 'Expires',
                                    value: formatPortalDate(portal.dashboard.expiresAt),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.devices_rounded,
                                    label: 'Device limit',
                                    value: portal.dashboard.deviceLimit.toString(),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: portal.subscription.checkoutEnabled
                                      ? () => launchPortalLink(
                                            context,
                                            portal.subscription.checkoutUrl,
                                          )
                                      : null,
                                  icon: const Icon(Icons.shopping_bag_outlined),
                                  label: const Text('Open checkout'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => launchPortalLink(
                                    context,
                                    portal.subscription.payViaBotUrl,
                                  ),
                                  icon: const Icon(Icons.telegram),
                                  label: const Text('Pay via Telegram'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      ...portal.subscription.plans.map(
                        (plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PortalSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plan.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if (plan.badge.isNotEmpty)
                                      Chip(label: Text(plan.badge)),
                                  ],
                                ),
                                const Gap(6),
                                Text(
                                  '${plan.amountRub} RUB / ${plan.days} days / ${plan.deviceLimit} devices',
                                ),
                                const Gap(12),
                                FilledButton(
                                  onPressed: () => launchPortalLink(
                                    context,
                                    '${portal.subscription.checkoutUrl}?plan=${plan.code}',
                                  ),
                                  child: Text('Choose ${plan.label}'),
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
