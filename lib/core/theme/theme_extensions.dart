import 'package:flutter/material.dart';

class PremiumThemeTokens extends ThemeExtension<PremiumThemeTokens> {
  const PremiumThemeTokens({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.backgroundBase,
    required this.shellSurface,
    required this.shellSurfaceStrong,
    required this.shellSurfaceMuted,
    required this.navSurface,
    required this.navSelected,
    required this.outlineSoft,
    required this.glowMint,
    required this.glowBlue,
    required this.glowPink,
    required this.shadowColor,
    required this.textMuted,
  });

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color backgroundBase;
  final Color shellSurface;
  final Color shellSurfaceStrong;
  final Color shellSurfaceMuted;
  final Color navSurface;
  final Color navSelected;
  final Color outlineSoft;
  final Color glowMint;
  final Color glowBlue;
  final Color glowPink;
  final Color shadowColor;
  final Color textMuted;

  static const light = PremiumThemeTokens(
    backgroundTop: Color(0xFFFFFFFF),
    backgroundBottom: Color(0xFFEAF4FF),
    backgroundBase: Color(0xFFF4F7FB),
    shellSurface: Color(0xF7FFFFFF),
    shellSurfaceStrong: Color(0xFFFFFFFF),
    shellSurfaceMuted: Color(0xFFF0F5FF),
    navSurface: Color(0xEBFFFFFF),
    navSelected: Color(0xFF0F172A),
    outlineSoft: Color(0x1F0F172A),
    glowMint: Color(0xFF9FFFF3),
    glowBlue: Color(0xFF8FC9FF),
    glowPink: Color(0xFFFFC2E3),
    shadowColor: Color(0x160F172A),
    textMuted: Color(0xFF5A657A),
  );

  static const dark = PremiumThemeTokens(
    backgroundTop: Color(0xFF11182E),
    backgroundBottom: Color(0xFF060A14),
    backgroundBase: Color(0xFF0B1020),
    shellSurface: Color(0xE61A2339),
    shellSurfaceStrong: Color(0xFF111A2E),
    shellSurfaceMuted: Color(0xFF162036),
    navSurface: Color(0xCC0F172A),
    navSelected: Color(0xFF7CFFF3),
    outlineSoft: Color(0x2DFFFFFF),
    glowMint: Color(0xFF7CFFF3),
    glowBlue: Color(0xFF7EB8FF),
    glowPink: Color(0xFFFF8FD5),
    shadowColor: Color(0x80010715),
    textMuted: Color(0xFFB8C5E0),
  );

  @override
  PremiumThemeTokens copyWith({
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? backgroundBase,
    Color? shellSurface,
    Color? shellSurfaceStrong,
    Color? shellSurfaceMuted,
    Color? navSurface,
    Color? navSelected,
    Color? outlineSoft,
    Color? glowMint,
    Color? glowBlue,
    Color? glowPink,
    Color? shadowColor,
    Color? textMuted,
  }) {
    return PremiumThemeTokens(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      backgroundBase: backgroundBase ?? this.backgroundBase,
      shellSurface: shellSurface ?? this.shellSurface,
      shellSurfaceStrong: shellSurfaceStrong ?? this.shellSurfaceStrong,
      shellSurfaceMuted: shellSurfaceMuted ?? this.shellSurfaceMuted,
      navSurface: navSurface ?? this.navSurface,
      navSelected: navSelected ?? this.navSelected,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      glowMint: glowMint ?? this.glowMint,
      glowBlue: glowBlue ?? this.glowBlue,
      glowPink: glowPink ?? this.glowPink,
      shadowColor: shadowColor ?? this.shadowColor,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  PremiumThemeTokens lerp(
    covariant ThemeExtension<PremiumThemeTokens>? other,
    double t,
  ) {
    if (other is! PremiumThemeTokens) {
      return this;
    }

    return PremiumThemeTokens(
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom:
          Color.lerp(backgroundBottom, other.backgroundBottom, t)!,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      shellSurface: Color.lerp(shellSurface, other.shellSurface, t)!,
      shellSurfaceStrong:
          Color.lerp(shellSurfaceStrong, other.shellSurfaceStrong, t)!,
      shellSurfaceMuted:
          Color.lerp(shellSurfaceMuted, other.shellSurfaceMuted, t)!,
      navSurface: Color.lerp(navSurface, other.navSurface, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      glowMint: Color.lerp(glowMint, other.glowMint, t)!,
      glowBlue: Color.lerp(glowBlue, other.glowBlue, t)!,
      glowPink: Color.lerp(glowPink, other.glowPink, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

class ConnectionButtonTheme extends ThemeExtension<ConnectionButtonTheme> {
  const ConnectionButtonTheme({
    required this.idleColor,
    required this.connectedColor,
    required this.reconnectColor,
    required this.idleGlow,
    required this.connectedGlow,
    required this.ringColor,
    required this.labelMuted,
  });

  final Color idleColor;
  final Color connectedColor;
  final Color reconnectColor;
  final Color idleGlow;
  final Color connectedGlow;
  final Color ringColor;
  final Color labelMuted;

  static const light = ConnectionButtonTheme(
    idleColor: Color(0xFF3CA8FF),
    connectedColor: Color(0xFF0B9D84),
    reconnectColor: Color(0xFFFF8A70),
    idleGlow: Color(0x663CA8FF),
    connectedGlow: Color(0x665AF5D4),
    ringColor: Color(0x330F172A),
    labelMuted: Color(0xFF667085),
  );

  static const dark = ConnectionButtonTheme(
    idleColor: Color(0xFF7EB8FF),
    connectedColor: Color(0xFF7CFFF3),
    reconnectColor: Color(0xFFFFA892),
    idleGlow: Color(0x667EB8FF),
    connectedGlow: Color(0x667CFFF3),
    ringColor: Color(0x33FFFFFF),
    labelMuted: Color(0xFFB8C5E0),
  );

  @override
  ConnectionButtonTheme copyWith({
    Color? idleColor,
    Color? connectedColor,
    Color? reconnectColor,
    Color? idleGlow,
    Color? connectedGlow,
    Color? ringColor,
    Color? labelMuted,
  }) {
    return ConnectionButtonTheme(
      idleColor: idleColor ?? this.idleColor,
      connectedColor: connectedColor ?? this.connectedColor,
      reconnectColor: reconnectColor ?? this.reconnectColor,
      idleGlow: idleGlow ?? this.idleGlow,
      connectedGlow: connectedGlow ?? this.connectedGlow,
      ringColor: ringColor ?? this.ringColor,
      labelMuted: labelMuted ?? this.labelMuted,
    );
  }

  @override
  ConnectionButtonTheme lerp(
    covariant ThemeExtension<ConnectionButtonTheme>? other,
    double t,
  ) {
    if (other is! ConnectionButtonTheme) {
      return this;
    }

    return ConnectionButtonTheme(
      idleColor: Color.lerp(idleColor, other.idleColor, t)!,
      connectedColor: Color.lerp(connectedColor, other.connectedColor, t)!,
      reconnectColor: Color.lerp(reconnectColor, other.reconnectColor, t)!,
      idleGlow: Color.lerp(idleGlow, other.idleGlow, t)!,
      connectedGlow: Color.lerp(connectedGlow, other.connectedGlow, t)!,
      ringColor: Color.lerp(ringColor, other.ringColor, t)!,
      labelMuted: Color.lerp(labelMuted, other.labelMuted, t)!,
    );
  }
}

extension PremiumThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  PremiumThemeTokens get premium =>
      theme.extension<PremiumThemeTokens>() ??
      (theme.brightness == Brightness.dark
          ? PremiumThemeTokens.dark
          : PremiumThemeTokens.light);
  ConnectionButtonTheme get connectionButtonTheme =>
      theme.extension<ConnectionButtonTheme>() ??
      (theme.brightness == Brightness.dark
          ? ConnectionButtonTheme.dark
          : ConnectionButtonTheme.light);
}

extension PremiumThemeDataX on ThemeData {
  PremiumThemeTokens get premium =>
      extension<PremiumThemeTokens>() ??
      (brightness == Brightness.dark
          ? PremiumThemeTokens.dark
          : PremiumThemeTokens.light);
  ConnectionButtonTheme get connectionButtonTheme =>
      extension<ConnectionButtonTheme>() ??
      (brightness == Brightness.dark
          ? ConnectionButtonTheme.dark
          : ConnectionButtonTheme.light);
}
