import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/portal/widget/quick_connect_panel.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/features/proxy/active/active_proxy_footer.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final portalExperience = ref.watch(portalExperienceProvider);

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(
            slivers: [
              NestedAppBar(
                title: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: Constants.appName),
                      TextSpan(text: " "),
                      WidgetSpan(
                        child: AppVersionLabel(),
                        alignment: PlaceholderAlignment.middle,
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => const AddProfileRoute().push(context),
                    icon: const Icon(FluentIcons.add_circle_24_filled),
                    tooltip: t.profile.add.buttonText,
                  ),
                ],
              ),
              switch (activeProfile) {
                AsyncData(value: final profile?) => MultiSliver(
                    children: [
                      ProfileTile(profile: profile, isMain: true),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: PortalAsyncBody(
                            value: portalExperience,
                            loadingLabel: 'Loading subscription and service data...',
                            builder: (context, experience) => _HomeOverviewCard(
                              experience: experience,
                            ),
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ConnectionButton(),
                                    Gap(12),
                                    ActiveProxyDelayIndicator(),
                                  ],
                                ),
                              ),
                              if (MediaQuery.sizeOf(context).width < 840) const ActiveProxyFooter(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                AsyncData() => switch (hasAnyProfile) {
                    AsyncData(value: true) => const EmptyActiveProfileHomeBody(),
                    _ => const EmptyProfilesHomeBody(),
                  },
                AsyncError(:final error) => SliverErrorBodyPlaceholder(t.presentShortError(error)),
                _ => const SliverToBoxAdapter(),
              },
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeOverviewCard extends StatelessWidget {
  const _HomeOverviewCard({required this.experience});

  final PortalExperience experience;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PortalQuickConnectPanel(
          experience: experience,
          onOpenLocations: () => const ProxiesRoute().go(context),
          onOpenTelegramReward: () => launchPortalLink(
            context,
            Constants.telegramChannelUrl,
          ),
        ),
        const Gap(14),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickActionButton(
                icon: FluentIcons.globe_24_regular,
                label: 'Locations',
                onPressed: () => const ProxiesRoute().go(context),
              ),
              _QuickActionButton(
                icon: FluentIcons.phone_desktop_24_regular,
                label: 'Devices',
                onPressed: () => const ConfigOptionsRoute().go(context),
              ),
              _QuickActionButton(
                icon: FluentIcons.chat_24_regular,
                label: 'Support',
                onPressed: () => const LogsOverviewRoute().go(context),
              ),
              _QuickActionButton(
                icon: FluentIcons.person_24_regular,
                label: 'Profile',
                onPressed: () => const AboutRoute().go(context),
              ),
            ],
          ),
        ),
        if (experience.dashboard.connectionKey.isNotEmpty) ...[
          const Gap(14),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => copyPortalText(
                context,
                experience.dashboard.connectionKey,
                success: 'Subscription link copied.',
              ),
              icon: const Icon(FluentIcons.key_24_regular),
              label: const Text('Copy subscription link'),
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
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
