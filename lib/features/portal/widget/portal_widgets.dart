import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/core/widget/premium_surfaces.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/portal_copy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum PortalSectionTone {
  neutral,
  accent,
  muted,
}

class PortalSectionCard extends StatelessWidget {
  const PortalSectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.tone = PortalSectionTone.neutral,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final PortalSectionTone tone;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      padding: padding,
      accent: accent,
      style: switch (tone) {
        PortalSectionTone.neutral => PremiumPanelStyle.neutral,
        PortalSectionTone.accent => PremiumPanelStyle.accent,
        PortalSectionTone.muted => PremiumPanelStyle.muted,
      },
      child: child,
    );
  }
}

class PortalMetricTile extends StatelessWidget {
  const PortalMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PortalSectionCard(
      tone: PortalSectionTone.muted,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumIconOrb(icon: icon, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(label, style: theme.textTheme.labelLarge),
                if (caption != null && caption!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PortalStatusBadge extends StatelessWidget {
  const PortalStatusBadge({
    required this.label,
    super.key,
    this.icon,
    this.accent,
  });

  final String label;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return PremiumBadge(
      label: label,
      icon: icon,
      accent: accent,
    );
  }
}

class PortalListRow extends StatelessWidget {
  const PortalListRow({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );

    if (onTap == null) return row;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: row,
      ),
    );
  }
}

class PortalAsyncBody extends StatelessWidget {
  const PortalAsyncBody({
    required this.value,
    required this.builder,
    super.key,
    this.loadingLabel,
    this.errorLabel,
  });

  final AsyncValue<PortalExperience> value;
  final Widget Function(BuildContext context, PortalExperience experience)
      builder;
  final String? loadingLabel;
  final String? errorLabel;

  @override
  Widget build(BuildContext context) {
    final copy = PortalCopy.of(context);
    final resolvedLoading = loadingLabel ?? copy.loadingServiceData;
    final resolvedError = errorLabel ?? copy.serviceUnavailable;

    return value.when(
      data: (experience) => builder(context, experience),
      error: (error, _) => PortalSectionCard(
        tone: PortalSectionTone.muted,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PremiumSectionHeader(
              eyebrow: copy.isRussian ? 'Статус сервиса' : 'Service status',
              title: resolvedError,
              subtitle: '$error',
            ),
          ],
        ),
      ),
      loading: () => PortalSectionCard(
        tone: PortalSectionTone.muted,
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                resolvedLoading,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatPortalDate(DateTime? value) {
  if (value == null) return '--';
  final safe = value.toLocal();
  final month = safe.month.toString().padLeft(2, '0');
  final day = safe.day.toString().padLeft(2, '0');
  return '$day.$month.${safe.year}';
}

String formatPortalTraffic(double value) {
  if (value <= 0) return '0 GB';
  final fixed =
      value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return '$fixed GB';
}

String buildPortalCheckoutUrl(String rawUrl, {String? planCode}) {
  final safeRawUrl = rawUrl.trim();
  if (safeRawUrl.isEmpty) return '';
  final uri = Uri.tryParse(safeRawUrl);
  if (uri == null) return safeRawUrl;
  final normalizedPlan = planCode?.trim() ?? '';
  if (normalizedPlan.isEmpty) return uri.toString();
  final query = Map<String, String>.from(uri.queryParameters);
  query['plan'] = normalizedPlan;
  return uri.replace(queryParameters: query).toString();
}

String buildPortalDiagnosticsText({
  required String accountId,
  required String deviceName,
  required String planCode,
}) {
  return 'Account: $accountId\nDevice: $deviceName\nPlan: $planCode';
}

Uri buildPortalSupportEmailUri({
  required String contactEmail,
  required String accountId,
  required String deviceName,
  required String planCode,
  required String appLabel,
}) {
  return Uri(
    scheme: 'mailto',
    path: contactEmail.trim(),
    queryParameters: {
      'subject': '$appLabel support request',
      'body': [
        'Describe what is going wrong:',
        '',
        buildPortalDiagnosticsText(
          accountId: accountId,
          deviceName: deviceName,
          planCode: planCode,
        ),
      ].join('\n'),
    },
  );
}

Future<void> launchPortalLink(
  BuildContext context,
  String rawUrl, {
  String? failureMessage,
}) async {
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || rawUrl.trim().isEmpty) return;
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    final copy = PortalCopy.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failureMessage ?? copy.linkOpenFailed)),
    );
  }
}

Future<void> copyPortalText(
  BuildContext context,
  String value, {
  String? success,
}) async {
  if (value.trim().isEmpty) return;
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    final copy = PortalCopy.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ?? copy.copied)),
    );
  }
}
