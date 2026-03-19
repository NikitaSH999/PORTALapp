import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureInstallId generates and reuses a persisted install id', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPrefsPortalSessionStore(preferences: preferences);

    final first = await store.ensureInstallId();
    final second = await store.ensureInstallId();

    expect(first, isNotEmpty);
    expect(second, equals(first));
    expect(store.readInstallIdSync(), equals(first));
    expect(store.hasSessionAuth, isFalse);
  });

  test('saveSessionToken persists runtime auth for future requests', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPrefsPortalSessionStore(preferences: preferences);

    await store.saveSessionToken('portal-session-token');

    expect(store.readSessionTokenSync(), equals('portal-session-token'));
    expect(store.hasSessionAuth, isTrue);

    await store.clearSession();

    expect(store.readSessionTokenSync(), isEmpty);
    expect(store.hasSessionAuth, isFalse);
  });
}
