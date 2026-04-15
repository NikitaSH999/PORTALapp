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
import 'package:hiddify/features/home/widget/route_mode_setup_gate.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/portal/widget/quick_connect_panel.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/features/proxy/active/active_proxy_footer.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';
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
              _ => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: PortalSectionCard(
                          tone: PortalSectionTone.muted,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  copy.loadingAccessDeck,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const PokrovLogo(width: 30, height: 30),
        Text(
          Constants.appName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const AppVersionLabel(),
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
        final isWide = constraints.maxWidth >= 940;
        final sectionGap = constraints.maxWidth < 560 ? 12.0 : 16.0;
        final heroLeft = _ConnectionStage(
          profile: profile,
          experience: experience,
        );
        final heroRight = PortalQuickConnectPanel(
          experience: experience,
          onOpenLocations: () => const LocationsRoute().go(context),
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
                  Gap(sectionGap),
                  Expanded(flex: 5, child: heroRight),
                ],
              )
            else ...[
              heroLeft,
              Gap(sectionGap),
              heroRight,
            ],
            Gap(sectionGap),
            _QuickActions(experience: experience),
          ],
        );
      },
    );
  }
}

class _ConnectionStage extends ConsumerWidget {
  const _ConnectionStage({
    required this.profile,
    required this.experience,
  });

  final ProfileEntity profile;
  final PortalExperience experience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final currentPlan = copy.localizeServerText(
      experience.subscription.currentPlanLabel,
    );
    final routeModeCompleted = ref.watch(routeModeChoiceCompletedProvider);

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
          if (routeModeCompleted.valueOrNull == false) ...[
            const RouteModeSetupGateCard(),
          ] else ...[
            const Center(child: ConnectionButton()),
            const Gap(16),
            const Center(child: ActiveProxyDelayIndicator()),
            const Gap(12),
            const ActiveProxyFooter(),
          ],
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;
          final summary = Row(
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = TextButton(
            onPressed: () => const ProfilesOverviewRoute().go(context),
            child: Text(copy.switchAction),
          );

          if (!isCompact) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: summary),
                action,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              summary,
              const Gap(12),
              action,
            ],
          );
        },
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
    final actions = [
      _QuickActionSpec(
        icon: FluentIcons.globe_24_regular,
        label: copy.quickActionLocations,
        onPressed: () => const LocationsRoute().go(context),
      ),
      _QuickActionSpec(
        icon: FluentIcons.phone_desktop_24_regular,
        label: copy.quickActionDevices,
        onPressed: () => const DevicesRoute().go(context),
      ),
      _QuickActionSpec(
        icon: FluentIcons.person_24_regular,
        label: copy.quickActionProfile,
        onPressed: () => const ProfileRoute().go(context),
      ),
      _QuickActionSpec(
        icon: FluentIcons.chat_24_regular,
        label: copy.quickActionSupport,
        onPressed: () => const SupportRoute().go(context),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                _QuickActionButton(
                  icon: actions[index].icon,
                  label: actions[index].label,
                  onPressed: actions[index].onPressed,
                  expand: true,
                ),
                if (index < actions.length - 1) const Gap(12),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final action in actions)
              _QuickActionButton(
                icon: action.icon,
                label: action.label,
                onPressed: action.onPressed,
              ),
          ],
        );
      },
    );
  }
}

class _QuickActionSpec {
  const _QuickActionSpec({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);
    final version =
        ref.watch(appInfoProvider).valueOrNull?.presentVersion ?? '';
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
