import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('analytics stay disabled by default until the user opts in', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        environmentProvider.overrideWithValue(Environment.prod),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);

    final enabled = await container.read(analyticsControllerProvider.future);

    expect(enabled, isFalse);
  });

  test('analytics honor an explicit stored opt-in', () async {
    SharedPreferences.setMockInitialValues({
      enableAnalyticsPrefKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        environmentProvider.overrideWithValue(Environment.prod),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      ],
    );
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);

    final enabled = await container.read(analyticsControllerProvider.future);

    expect(enabled, isTrue);
  });
}
