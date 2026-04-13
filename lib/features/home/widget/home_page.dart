import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/widget/pokrov_logo.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/portal/widget/quick_connect_panel.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/features/proxy/active/active_proxy_footer.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final portalExperience = ref.watch(portalExperienceProvider);
    final copy = PortalCopy.of(context);

    return Scaffold(
      body: PremiumPageBackground(
        child: CustomScrollView(
          slivers: [
            NestedAppBar(
              title: const _HomeTitle(),
              actions: [
                IconButton(
                  onPressed: () => const AddProfileRoute().push(context),
                  icon: const Icon(FluentIcons.add_circle_24_filled),
                  tooltip: t.profile.add.buttonText,
                ),
              ],
            ),
            switch (activeProfile) {
              AsyncData(value: final profile?) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: PortalAsyncBody(
                      value: portalExperience,
                      loadingLabel: copy.loadingAccessDeck,
                      builder: (context, experience) => _HomeContent(
                        profile: profile,
                        experience: experience,
                      ),
                    ),
                  ),
                ),
              AsyncData() => switch (hasAnyProfile) {
                  AsyncData(value: true) => const EmptyActiveProfileHomeBody(),
                  _ => const EmptyProfilesHomeBody(),
                },
              AsyncError(:final error) =>
                SliverErrorBodyPlaceholder(t.presentShortError(error)),
              _ => const SliverToBoxAdapter(),
            },
          ],
        ),
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        PokrovLogo(width: 30, height: 30),
        Gap(10),
        Text(Constants.appName),
        Gap(8),
        AppVersionLabel(),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.profile,
    required this.experience,
  });

  final ProfileEntity profile;
  final PortalExperience experience;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;
        final heroLeft = _ConnectionStage(
          profile: profile,
          experience: experience,
        );
        final heroRight = PortalQuickConnectPanel(
          experience: experience,
          onOpenLocations: () => const ProxiesRoute().go(context),
          onOpenTelegramReward: () => launchPortalLink(
            context,
            Constants.telegramChannelUrl,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: heroLeft),
                  const Gap(16),
                  Expanded(flex: 5, child: heroRight),
                ],
              )
            else ...[
              heroLeft,
              const Gap(16),
              heroRight,
            ],
            const Gap(16),
            _QuickActions(experience: experience),
          ],
        );
      },
    );
  }
}

class _ConnectionStage extends StatelessWidget {
  const _ConnectionStage({
    required this.profile,
    required this.experience,
  });

  final ProfileEntity profile;
  final PortalExperience experience;

  @override
  Widget build(BuildContext context) {
    final copy = PortalCopy.of(context);
    final currentPlan = copy.localizeServerText(
      experience.subscription.currentPlanLabel,
    );

    return PortalSectionCard(
      tone: PortalSectionTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PortalStatusBadge(
                label: currentPlan,
                icon: FluentIcons.shield_checkmark_24_regular,
              ),
              PortalStatusBadge(
                label: copy.homeConsoleBadge,
                icon: FluentIcons.sparkle_24_regular,
              ),
            ],
          ),
          const Gap(16),
          PremiumSectionHeader(
            eyebrow: copy.secureOnTapEyebrow,
            title: copy.homeStageTitle(isActive: experience.dashboard.isActive),
            subtitle: copy.homeStageBody(
              isActive: experience.dashboard.isActive,
            ),
          ),
          const Gap(18),
          _ProfileSpotlight(profile: profile),
          const Gap(18),
          const Center(child: ConnectionButton()),
          const Gap(16),
          const Center(child: ActiveProxyDelayIndicator()),
          const Gap(12),
          const ActiveProxyFooter(),
        ],
      ),
    );
  }
}

class _ProfileSpotlight extends StatelessWidget {
  const _ProfileSpotlight({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final copy = PortalCopy.of(context);
    final subtitle = switch (profile) {
      RemoteProfileEntity(:final subInfo?) => _subscriptionSummary(
          context,
          subInfo,
        ),
      RemoteProfileEntity() => copy.remoteProfileReady,
      LocalProfileEntity() => copy.localProfileReady,
    };

    return PortalSectionCard(
      tone: PortalSectionTone.muted,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PremiumIconOrb(
            icon: FluentIcons.person_circle_24_regular,
            size: 48,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.activeProfileLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Gap(4),
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => const ProfilesOverviewRoute().go(context),
            child: Text(copy.switchAction),
          ),
        ],
      ),
    );
  }

  String _subscriptionSummary(BuildContext context, SubscriptionInfo subInfo) {
    final copy = PortalCopy.of(context);
    final remainingDays = subInfo.remaining.inDays;
    final remainingTraffic = subInfo.total > 10 * 1099511627776
        ? copy.unlimitedTraffic
        : copy.trafficLeft(subInfo.consumption.sizeOf(subInfo.total));

    if (subInfo.isExpired) {
      return copy.subscriptionExpired;
    }
    return '$remainingTraffic • ${copy.daysRemaining(remainingDays)}';
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.experience});

  final PortalExperience experience;

  @override
  Widget build(BuildContext context) {
    final copy = PortalCopy.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: FluentIcons.globe_24_regular,
              label: copy.quickActionLocations,
              onPressed: () => const ProxiesRoute().go(context),
            ),
            _QuickActionButton(
              icon: FluentIcons.phone_desktop_24_regular,
              label: copy.quickActionDevices,
              onPressed: () => const ConfigOptionsRoute().go(context),
            ),
            _QuickActionButton(
              icon: FluentIcons.person_24_regular,
              label: copy.quickActionProfile,
              onPressed: () => const AboutRoute().go(context),
            ),
            _QuickActionButton(
              icon: FluentIcons.chat_24_regular,
              label: copy.quickActionSupport,
              onPressed: () => const LogsOverviewRoute().go(context),
            ),
          ],
        ),
        if (experience.dashboard.connectionKey.isNotEmpty) ...[
          const Gap(14),
          PortalSectionCard(
            tone: PortalSectionTone.muted,
            padding: const EdgeInsets.all(18),
            child: PortalListRow(
              title: copy.subscriptionLinkTitle,
              subtitle: experience.dashboard.connectionKey,
              leading: const PremiumIconOrb(
                icon: FluentIcons.key_24_regular,
                size: 42,
              ),
              trailing: OutlinedButton(
                onPressed: () => copyPortalText(
                  context,
                  experience.dashboard.connectionKey,
                  success: copy.subscriptionLinkCopied,
                ),
                child: Text(copy.copyAction),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.about.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
