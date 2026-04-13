import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubscriptionPage extends HookConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final experience = ref.watch(portalExperienceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            NestedAppBar(title: Text(copy.subscriptionTitle)),
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
                          tone: PortalSectionTone.accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                copy.localizeServerText(
                                  portal.subscription.currentPlanLabel,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const Gap(8),
                              Text(
                                portal.subscription.isTrialLike
                                    ? copy.subscriptionSubtitleTrial
                                    : copy.subscriptionSubtitlePaid,
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
                                      label: copy.expiresMetric,
                                      value: formatPortalDate(
                                        portal.dashboard.expiresAt,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: PortalMetricTile(
                                      icon: Icons.devices_rounded,
                                      label: copy.deviceLimitMetric,
                                      value: portal.dashboard.deviceLimit
                                          .toString(),
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
                                    onPressed: portal
                                            .subscription.checkoutEnabled
                                        ? () => launchPortalLink(
                                              context,
                                              buildPortalCheckoutUrl(
                                                portal.subscription.checkoutUrl,
                                              ),
                                            )
                                        : null,
                                    icon: const Icon(
                                      Icons.shopping_bag_outlined,
                                    ),
                                    label: Text(copy.openSecureCheckout),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => launchPortalLink(
                                      context,
                                      portal.subscription.payViaBotUrl,
                                    ),
                                    icon: const Icon(Icons.telegram),
                                    label: Text(copy.continueInTelegram),
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
                                          copy.localizeServerText(plan.label),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      if (plan.badge.isNotEmpty)
                                        Chip(
                                          label: Text(
                                            copy.localizeServerText(plan.badge),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Gap(6),
                                  Text(
                                    copy.planSummary(
                                      amountRub: plan.amountRub,
                                      days: plan.days,
                                      deviceLimit: plan.deviceLimit,
                                    ),
                                  ),
                                  const Gap(12),
                                  FilledButton(
                                    onPressed: () => launchPortalLink(
                                      context,
                                      buildPortalCheckoutUrl(
                                        portal.subscription.checkoutUrl,
                                        planCode: plan.code,
                                      ),
                                    ),
                                    child: Text(
                                      copy.choosePlan(
                                        copy.localizeServerText(plan.label),
                                      ),
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
      ),
    );
  }
}
