import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

enum PremiumPanelStyle {
  neutral,
  accent,
  muted,
}

class PremiumPageBackground extends StatelessWidget {
  const PremiumPageBackground({
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.premium;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.backgroundTop,
            tokens.backgroundBottom,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _PremiumGlow(
            alignment: const Alignment(-1.15, -0.92),
            color: tokens.glowBlue.withOpacity(
              Theme.of(context).brightness == Brightness.light ? 0.18 : 0.22,
            ),
            size: 280,
          ),
          _PremiumGlow(
            alignment: const Alignment(1.1, -0.72),
            color: tokens.glowPink.withOpacity(
              Theme.of(context).brightness == Brightness.light ? 0.16 : 0.2,
            ),
            size: 260,
          ),
          _PremiumGlow(
            alignment: const Alignment(0.9, 0.92),
            color: tokens.glowMint.withOpacity(
              Theme.of(context).brightness == Brightness.light ? 0.14 : 0.18,
            ),
            size: 320,
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class PremiumPanel extends StatelessWidget {
  const PremiumPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.style = PremiumPanelStyle.neutral,
    this.accent,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final PremiumPanelStyle style;
  final Color? accent;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.premium;
    final scheme = Theme.of(context).colorScheme;
    final surface = switch (style) {
      PremiumPanelStyle.neutral => tokens.shellSurface,
      PremiumPanelStyle.accent => tokens.shellSurfaceStrong,
      PremiumPanelStyle.muted => tokens.shellSurfaceMuted,
    };
    final accentColor = accent ??
        switch (style) {
          PremiumPanelStyle.neutral => tokens.glowBlue,
          PremiumPanelStyle.accent => scheme.primary,
          PremiumPanelStyle.muted => tokens.glowPink,
        };

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: tokens.outlineSoft,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surface,
            Color.alphaBlend(
              accentColor.withOpacity(
                Theme.of(context).brightness == Brightness.light ? 0.08 : 0.12,
              ),
              surface,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor,
            blurRadius: 28,
            spreadRadius: -12,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
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
    final tokens = context.premium;
    final scheme = Theme.of(context).colorScheme;
    final highlight = accent ?? scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: highlight.withOpacity(
          Theme.of(context).brightness == Brightness.light ? 0.09 : 0.16,
        ),
        border: Border.all(color: tokens.outlineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: highlight),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class PremiumSectionHeader extends StatelessWidget {
  const PremiumSectionHeader({
    required this.eyebrow,
    required this.title,
    super.key,
    this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.premium.textMuted,
                ),
          ),
        ],
      ],
    );
  }
}

class PremiumMetricPill extends StatelessWidget {
  const PremiumMetricPill({
    required this.label,
    required this.value,
    super.key,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      style: PremiumPanelStyle.muted,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.premium.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PremiumIconOrb extends StatelessWidget {
  const PremiumIconOrb({
    required this.icon,
    super.key,
    this.size = 44,
    this.accent,
  });

  final IconData icon;
  final double size;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: context.premium.outlineSoft),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.45, color: color),
    );
  }
}

class _PremiumGlow extends StatelessWidget {
  const _PremiumGlow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Transform.rotate(
          angle: math.pi / 12,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: size * 0.28,
                  spreadRadius: size * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
