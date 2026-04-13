import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/theme/app_theme.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget buildPremiumTestApp({
  required Widget child,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  Size? surfaceSize,
}) {
  final theme = AppTheme(AppThemeMode.light, '');

  return ProviderScope(
    overrides: [
      translationsProvider.overrideWithValue(AppLocale.en.build()),
      ...overrides,
    ],
    child: MediaQuery(
      data: MediaQueryData(size: surfaceSize ?? const Size(430, 932)),
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ru')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: theme.lightTheme(null),
        darkTheme: theme.darkTheme(null),
        home: child,
      ),
    ),
  );
}
