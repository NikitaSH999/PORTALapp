import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SupportPage extends HookConsumerWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(portalExperienceProvider);
    final config = ref.watch(portalPublicConfigProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const NestedAppBar(title: Text('Support')),
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
                              'Write from the app',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(8),
                            const Text(
                              'Describe the issue here, then continue in Telegram or email with device context already prepared.',
                            ),
                            const Gap(16),
                            const TextField(
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'What is going wrong?',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const Gap(16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: () => launchPortalLink(
                                    context,
                                    config.supportTelegramUrl,
                                  ),
                                  icon: const Icon(Icons.telegram),
                                  label: const Text('Open Telegram'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => launchPortalLink(
                                    context,
                                    'mailto:${config.contactEmail}',
                                  ),
                                  icon: const Icon(Icons.mail_outline),
                                  label: const Text('Email support'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => copyPortalText(
                                    context,
                                    'account=${portal.session.accountId};device=${portal.session.deviceName};plan=${portal.subscription.currentPlanCode}',
                                    success: 'Diagnostics copied.',
                                  ),
                                  icon: const Icon(Icons.health_and_safety_outlined),
                                  label: const Text('Send diagnostics'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      PortalSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device context',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(10),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.smartphone_rounded),
                              title: Text(portal.session.deviceName),
                              subtitle: Text('Account ${portal.session.accountId}'),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      ...portal.supportThreads.map(
                        (thread) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PortalSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        thread.subject,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Chip(label: Text(thread.status.toUpperCase())),
                                  ],
                                ),
                                const Gap(8),
                                ...thread.messages.take(2).map(
                                      (message) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(message.body),
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
