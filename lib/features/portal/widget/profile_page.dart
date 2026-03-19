import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experience = ref.watch(portalExperienceProvider);
    final config = ref.watch(portalPublicConfigProvider);
    final isLinkingTelegram = useState(false);
    final isClaimingBonus = useState(false);
    final bonusStatus = useState<String?>(null);

    Future<void> handleTelegramLink() async {
      if (isLinkingTelegram.value) return;
      isLinkingTelegram.value = true;
      try {
        final link = await ref.read(portalRepositoryProvider).requestTelegramLink();
        if (!context.mounted) return;
        bonusStatus.value = link.linked
            ? 'Telegram уже привязан${link.linkedTelegramUsername.isNotEmpty ? ' как @${link.linkedTelegramUsername}' : ''}.'
            : 'Откроем @portal_service_bot для привязки, затем вернитесь и нажмите Check bonus.';
        final destination = link.botUrl.isNotEmpty ? link.botUrl : config.botUrl;
        await launchPortalLink(context, destination);
      } catch (error) {
        if (!context.mounted) return;
        bonusStatus.value = _portalErrorMessage(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_portalErrorMessage(error))),
        );
      } finally {
        isLinkingTelegram.value = false;
      }
    }

    Future<void> handleBonusClaim() async {
      if (isClaimingBonus.value) return;
      isClaimingBonus.value = true;
      try {
        final result = await ref.read(portalRepositoryProvider).claimTelegramBonus();
        ref.invalidate(portalExperienceProvider);
        if (!context.mounted) return;
        final successMessage = result.alreadyClaimed
            ? 'Бонус уже был активирован для этого аккаунта.'
            : 'Бонус применён: +${result.premiumDays} дней к подписке.';
        bonusStatus.value = successMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      } catch (error) {
        if (!context.mounted) return;
        final message = _portalErrorMessage(error);
        bonusStatus.value = message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        isClaimingBonus.value = false;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const NestedAppBar(title: Text('Profile')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: PortalAsyncBody(
                value: experience,
                builder: (context, portal) {
                  final linkedTelegramLabel = portal.session.linkedTelegramUsername.isNotEmpty
                      ? '@${portal.session.linkedTelegramUsername}'
                      : (portal.session.linkedTelegramId > 0
                          ? 'ID ${portal.session.linkedTelegramId}'
                          : 'Not linked yet');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PortalSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PORTAL VPN account',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Gap(8),
                            Text(
                              portal.session.isAuthorized
                                  ? '@${portal.session.username}'
                                  : 'Guest mode',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Gap(8),
                            Text(
                              'Account ID: ${portal.session.accountId}\nDevice: ${portal.session.deviceName}',
                            ),
                            const Gap(16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.data_usage_rounded,
                                    label: 'Remaining traffic',
                                    value: formatPortalTraffic(
                                      portal.usage.remainingGb,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  child: PortalMetricTile(
                                    icon: Icons.verified_user_outlined,
                                    label: 'Plan',
                                    value: portal.subscription.currentPlanLabel,
                                  ),
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
                              '+10 days for Telegram',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(6),
                            Text(
                              portal.session.linkedTelegramId > 0
                                  ? 'Telegram linked: $linkedTelegramLabel'
                                  : 'Link Telegram through @portal_service_bot, then verify channel membership to unlock 10 extra days.',
                            ),
                            const Gap(12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton(
                                  onPressed:
                                      isLinkingTelegram.value ? null : handleTelegramLink,
                                  child: Text(
                                    isLinkingTelegram.value
                                        ? 'Opening...'
                                        : 'Link Telegram',
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed:
                                      isClaimingBonus.value ? null : handleBonusClaim,
                                  child: Text(
                                    isClaimingBonus.value
                                        ? 'Checking...'
                                        : 'Check bonus',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => launchPortalLink(
                                    context,
                                    config.newsChannelUrl,
                                  ),
                                  child: const Text('Open channel'),
                                ),
                              ],
                            ),
                            if ((bonusStatus.value ?? '').isNotEmpty) ...[
                              const Gap(12),
                              Text(
                                bonusStatus.value!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(16),
                      PortalSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manual setup',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Smart subscription link'),
                              subtitle: Text(
                                portal.importPayload.smartUrl.isEmpty
                                    ? 'No active subscription link yet'
                                    : portal.importPayload.smartUrl,
                              ),
                              trailing: IconButton(
                                onPressed: portal.importPayload.smartUrl.isEmpty
                                    ? null
                                    : () => copyPortalText(
                                          context,
                                          portal.importPayload.smartUrl,
                                        ),
                                icon: const Icon(Icons.copy_rounded),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Plain subscription link'),
                              subtitle: Text(
                                portal.importPayload.plainUrl.isEmpty
                                    ? 'No plain link yet'
                                    : portal.importPayload.plainUrl,
                              ),
                              trailing: IconButton(
                                onPressed: portal.importPayload.plainUrl.isEmpty
                                    ? null
                                    : () => copyPortalText(
                                          context,
                                          portal.importPayload.plainUrl,
                                        ),
                                icon: const Icon(Icons.copy_rounded),
                              ),
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
                              'Downloads and legal',
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
                                      : target.docsUrl,
                                ),
                                onTap: () => launchPortalLink(
                                  context,
                                  target.primaryUrl.isNotEmpty
                                      ? target.primaryUrl
                                      : target.docsUrl,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      PortalSectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Advanced',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const Gap(6),
                                  const Text(
                                    'Technical settings stay available here, but they no longer get in the way of the main VPN flow.',
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            FilledButton(
                              onPressed: () => const SettingsRoute().push(context),
                              child: const Text('Open Advanced'),
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

String _portalErrorMessage(Object error) {
  final raw = error.toString();
  final detailIndex = raw.indexOf('"detail":"');
  if (detailIndex >= 0) {
    final detailStart = detailIndex + 10;
    final detailEnd = raw.indexOf('"', detailStart);
    if (detailEnd > detailStart) {
      return raw.substring(detailStart, detailEnd);
    }
  }
  return 'Не удалось завершить действие. Попробуйте ещё раз.';
}
