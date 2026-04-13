import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/core/widget/pokrov_logo.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hiddify/features/stats/widget/side_bar_stats_overview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract interface class RootScaffold {
  static final stateKey = GlobalKey<ScaffoldState>();

  static bool canShowDrawer(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 760;
}

class AdaptiveRootScaffold extends HookConsumerWidget {
  const AdaptiveRootScaffold(this.navigator, {super.key});

  final Widget navigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = PortalCopy.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 760;
    final isExpanded = width >= 920;
    final showStats = width >= 1320;
    final selectedIndex = getCurrentIndex(context);

    final destinations = <_ShellDestination>[
      _ShellDestination(
        label: copy.shellVpn,
        icon: FluentIcons.power_20_regular,
        selectedIcon: FluentIcons.power_20_filled,
      ),
      _ShellDestination(
        label: copy.shellLocations,
        icon: FluentIcons.globe_20_regular,
        selectedIcon: FluentIcons.globe_20_filled,
      ),
      _ShellDestination(
        label: copy.shellDevices,
        icon: FluentIcons.phone_laptop_20_regular,
        selectedIcon: FluentIcons.phone_laptop_20_filled,
      ),
      _ShellDestination(
        label: copy.shellProfile,
        icon: FluentIcons.person_20_regular,
        selectedIcon: FluentIcons.person_20_filled,
      ),
      _ShellDestination(
        label: copy.shellSupport,
        icon: FluentIcons.headset_20_regular,
        selectedIcon: FluentIcons.headset_20_filled,
      ),
    ];

    return Scaffold(
      key: RootScaffold.stateKey,
      backgroundColor: Colors.transparent,
      drawer: isCompact
          ? Drawer(
              width: (width * 0.9).clamp(1, 360),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _NavigationSidebar(
                    selectedIndex: selectedIndex,
                    destinations: destinations,
                    expanded: true,
                    showStats: false,
                    copy: copy,
                    onSelectedIndexChange: (index) {
                      RootScaffold.stateKey.currentState?.closeDrawer();
                      switchTab(index, context);
                    },
                  ),
                ),
              ),
            )
          : null,
      body: PremiumPageBackground(
        padding: EdgeInsets.only(bottom: isCompact ? 88 : 0),
        child: SafeArea(
          bottom: !isCompact,
          child: isCompact
              ? navigator
              : Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      child: _NavigationSidebar(
                        selectedIndex: selectedIndex,
                        destinations: destinations,
                        expanded: isExpanded,
                        showStats: showStats,
                        copy: copy,
                        onSelectedIndexChange: (index) =>
                            switchTab(index, context),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _NavigatorViewport(child: navigator),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: isCompact
          ? _BottomDock(
              selectedIndex: selectedIndex,
              destinations: destinations,
              copy: copy,
              onSelectedIndexChange: (index) => switchTab(index, context),
            )
          : null,
    );
  }
}

class _NavigatorViewport extends StatelessWidget {
  const _NavigatorViewport({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      padding: EdgeInsets.zero,
      style: PremiumPanelStyle.neutral,
      borderRadius: BorderRadius.circular(34),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withOpacity(
                Theme.of(context).brightness == Brightness.light ? 0.9 : 0.78,
              ),
          child: child,
        ),
      ),
    );
  }
}

class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.expanded,
    required this.showStats,
    required this.copy,
    required this.onSelectedIndexChange,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final bool expanded;
  final bool showStats;
  final PortalCopy copy;
  final ValueChanged<int> onSelectedIndexChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? 286 : 104,
      child: PremiumPanel(
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(34),
        child: Column(
          crossAxisAlignment:
              expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
              child: expanded
                  ? _BrandHeader(copy: copy)
                  : const PokrovLogo(width: 34, height: 34),
            ),
            ...List.generate(
              destinations.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SidebarDestinationButton(
                  destination: destinations[index],
                  selected: index == selectedIndex,
                  expanded: expanded,
                  onTap: () => onSelectedIndexChange(index),
                ),
              ),
            ),
            if (expanded) ...[
              const Spacer(),
              PremiumBadge(
                label: copy.shellBadge,
                icon: FluentIcons.sparkle_24_regular,
              ),
              if (showStats) ...[
                const SizedBox(height: 16),
                const Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SideBarStatsOverview(),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.copy});

  final PortalCopy copy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PokrovLogo(width: 34, height: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Constants.appName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                copy.shellTagline,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarDestinationButton extends StatelessWidget {
  const _SidebarDestinationButton({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 14 : 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: selected
                ? theme.colorScheme.primary.withOpacity(
                    theme.brightness == Brightness.light ? 0.12 : 0.18,
                  )
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment:
                expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: selected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.selectedIndex,
    required this.destinations,
    required this.copy,
    required this.onSelectedIndexChange,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final PortalCopy copy;
  final ValueChanged<int> onSelectedIndexChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: PremiumPanel(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        borderRadius: BorderRadius.circular(28),
        child: Row(
          children: List.generate(destinations.length, (index) {
            final destination = destinations[index];
            final selected = index == selectedIndex;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelectedIndexChange(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: selected
                        ? theme.colorScheme.primary.withOpacity(
                            theme.brightness == Brightness.light ? 0.12 : 0.18,
                          )
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? destination.selectedIcon : destination.icon,
                        size: 20,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        destination.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
