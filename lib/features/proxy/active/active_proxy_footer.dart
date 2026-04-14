import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/widget/animated_visibility.dart';
import 'package:hiddify/core/widget/shimmer_skeleton.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/proxy/model/ip_info_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_failure.dart';
import 'package:hiddify/features/stats/notifier/stats_notifier.dart';
import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActiveProxyFooter extends HookConsumerWidget {
  const ActiveProxyFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final ipInfo = ref.watch(ipInfoNotifierProvider);

    return AnimatedVisibility(
      axis: Axis.vertical,
      visible: activeProxy is AsyncData,
      child: switch (activeProxy) {
        AsyncData(value: final proxy) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 520;
                final summary = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoProp(
                      icon: FluentIcons.arrow_routing_20_regular,
                      text: proxy.selectedName.isNotNullOrBlank
                          ? proxy.selectedName!
                          : proxy.name,
                      semanticLabel: t.proxies.activeProxySemanticLabel,
                    ),
                    const Gap(8),
                    _PrivacyStatus(ipInfo: ipInfo),
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summary,
                      const Gap(12),
                      const _StatsColumn(),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: summary),
                    const Gap(12),
                    const _StatsColumn(),
                  ],
                );
              },
            ),
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _PrivacyStatus extends StatelessWidget {
  const _PrivacyStatus({required this.ipInfo});

  final AsyncValue<IpInfo> ipInfo;

  @override
  Widget build(BuildContext context) {
    return switch (ipInfo) {
      AsyncData(value: final info) => _InfoProp(
          icon: FluentIcons.shield_20_regular,
          text: _hiddenAddressLabel(info.countryCode),
        ),
      AsyncError(error: final UnknownIp _) => const _InfoProp(
          icon: FluentIcons.shield_20_regular,
          text: 'Connection details hidden',
        ),
      AsyncError() => const _InfoProp(
          icon: FluentIcons.shield_error_20_regular,
          text: 'Visibility check unavailable',
        ),
      _ => const Row(
          children: [
            Icon(FluentIcons.shield_20_regular),
            Gap(8),
            Flexible(
              child: ShimmerSkeleton(
                height: 16,
                widthFactor: 1,
              ),
            ),
          ],
        ),
    };
  }

  String _hiddenAddressLabel(String countryCode) {
    final normalizedCode = countryCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) return 'Connection details hidden';
    return 'Connection details hidden ($normalizedCode)';
  }
}

class _StatsColumn extends HookConsumerWidget {
  const _StatsColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final stats = ref.watch(statsNotifierProvider).value;

    return Directionality(
      textDirection: TextDirection.values[
          (Directionality.of(context).index + 1) % TextDirection.values.length],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoProp(
            icon: FluentIcons.arrow_bidirectional_up_down_20_regular,
            text: (stats?.downlinkTotal ?? 0).size(),
            semanticLabel: t.stats.totalTransferred,
          ),
          const Gap(8),
          _InfoProp(
            icon: FluentIcons.arrow_download_20_regular,
            text: (stats?.downlink ?? 0).speed(),
            semanticLabel: t.stats.speed,
          ),
        ],
      ),
    );
  }
}

class _InfoProp extends StatelessWidget {
  const _InfoProp({
    required this.icon,
    required this.text,
    this.semanticLabel,
  });

  final IconData icon;
  final String text;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Row(
        children: [
          Icon(icon),
          const Gap(8),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontFamily: FontFamily.emoji),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
