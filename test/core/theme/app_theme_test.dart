import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/theme/app_theme.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';

void main() {
  test('light theme uses branded premium shell styling', () {
    final theme = AppTheme(AppThemeMode.light, '').lightTheme(null);

    expect(theme.scaffoldBackgroundColor, const Color(0xFFF4F7FB));
    expect(theme.navigationBarTheme.height, 78);
    expect(theme.navigationRailTheme.backgroundColor, Colors.transparent);
    expect(theme.cardTheme.margin, EdgeInsets.zero);
    expect(theme.textTheme.displaySmall?.fontWeight, FontWeight.w700);
  });

  test('dark theme keeps deep premium contrast without true black', () {
    final theme = AppTheme(AppThemeMode.dark, '').darkTheme(null);

    expect(theme.scaffoldBackgroundColor, const Color(0xFF0B1020));
    expect(theme.colorScheme.primary, const Color(0xFF7CFFF3));
    expect(theme.navigationBarTheme.backgroundColor, const Color(0xCC0F172A));
  });
}
