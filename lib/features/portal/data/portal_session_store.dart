import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final portalSessionStoreProvider = Provider<PortalSessionStore>(
  (ref) => SharedPrefsPortalSessionStore(
    preferences: ref.watch(sharedPreferencesProvider).requireValue,
  ),
);

abstract interface class PortalSessionStore {
  Future<String> ensureInstallId();

  String readInstallIdSync();

  String readSessionTokenSync();

  bool get hasSessionAuth;

  Future<void> saveSessionToken(String value);

  Future<void> clearSession();
}

class SharedPrefsPortalSessionStore implements PortalSessionStore {
  SharedPrefsPortalSessionStore({
    required this.preferences,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  static const _installIdKey = 'portal.install_id';
  static const _sessionTokenKey = 'portal.session_token';

  final SharedPreferences preferences;
  final Uuid _uuid;

  @override
  Future<String> ensureInstallId() async {
    final existing = readInstallIdSync();
    if (existing.isNotEmpty) return existing;
    final generated = _uuid.v4();
    await preferences.setString(_installIdKey, generated);
    return generated;
  }

  @override
  String readInstallIdSync() =>
      preferences.getString(_installIdKey)?.trim() ?? '';

  @override
  String readSessionTokenSync() =>
      preferences.getString(_sessionTokenKey)?.trim() ?? '';

  @override
  bool get hasSessionAuth => readSessionTokenSync().isNotEmpty;

  @override
  Future<void> saveSessionToken(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    await preferences.setString(_sessionTokenKey, normalized);
  }

  @override
  Future<void> clearSession() => preferences.remove(_sessionTokenKey);
}
