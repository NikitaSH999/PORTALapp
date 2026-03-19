import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PortalSectionCard extends StatelessWidget {
  const PortalSectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(
          theme.brightness == Brightness.dark ? 0.35 : 0.92,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label, style: theme.textTheme.labelMedium),
                if (caption != null && caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      caption!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PortalAsyncBody extends StatelessWidget {
  const PortalAsyncBody({
    required this.value,
    required this.builder,
    super.key,
    this.loadingLabel = 'Loading service data...',
    this.errorLabel = 'Portal service is not available right now.',
  });

  final AsyncValue<PortalExperience> value;
  final Widget Function(BuildContext context, PortalExperience experience) builder;
  final String loadingLabel;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (experience) => builder(context, experience),
      error: (error, _) => PortalSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      loading: () => PortalSectionCard(
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(loadingLabel)),
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
  final fixed = value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return '$fixed GB';
}

Future<void> launchPortalLink(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || rawUrl.trim().isEmpty) return;
  final launched = await launchUrl(uri);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the link.')),
    );
  }
}

Future<void> copyPortalText(
  BuildContext context,
  String value, {
  String success = 'Copied to clipboard.',
}) async {
  if (value.trim().isEmpty) return;
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success)),
    );
  }
}
