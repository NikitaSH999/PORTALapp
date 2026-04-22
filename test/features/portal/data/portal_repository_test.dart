import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_api_client.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';

class _FakePortalApiClient implements PortalApiClient {
  _FakePortalApiClient(
    this.responses, {
    this.onPost,
  });

  final Map<String, Map<String, dynamic>> responses;
  final Future<Map<String, dynamic>> Function(
    String path,
    Map<String, dynamic> body,
  )? onPost;

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    final response = responses[path];
    if (response == null) {
      throw StateError('No fake response registered for $path');
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (onPost != null) {
      return onPost!(path, body);
    }
    return getJson(path);
  }
}

class _ThrowingPortalApiClient implements PortalApiClient {
  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    throw StateError('network unavailable');
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    throw StateError('network unavailable');
  }
}

class _MemoryPortalSessionStore implements PortalSessionStore {
  _MemoryPortalSessionStore({
    this.installId = 'install-123',
    this.sessionToken = '',
  });

  final String installId;
  String sessionToken;

  @override
  Future<void> clearSession() async {
    sessionToken = '';
  }

  @override
  Future<String> ensureInstallId() async => installId;

  @override
  bool get hasSessionAuth => sessionToken.isNotEmpty;

  @override
  String readInstallIdSync() => installId;

  @override
  String readSessionTokenSync() => sessionToken;

  @override
  Future<void> saveSessionToken(String value) async {
    sessionToken = value;
  }
}

void main() {
  group('PortalRepositoryImpl', () {
    test('getExperience maps account, support, download and route-policy data',
        () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient({
          '/api/auth/session': {
            'ok': true,
            'user': {
              'id': 1001,
              'account_id': '1001',
              'username': 'alice',
              'device_name': 'Windows PC',
              'is_authorized': true,
              'client_policy': {
                'routing_mode_default': 'all_except_ru',
                'support_context': {
                  'routing_mode': 'all_except_ru',
                },
                'support_recovery_order': ['app', 'web', 'telegram'],
              },
            },
          },
          '/api/dashboard': {
            'current_plan_code': 'paid_unlimited',
            'is_active': true,
            'expiry_at': '2026-05-01T00:00:00Z',
            'used_gb': 18,
            'total_gb': 100,
            'remaining_gb': 82,
            'active_sessions': 2,
            'device_limit': 5,
            'subscription_url': 'https://connect.pokrov.space/sub/abc',
            'client_policy': {
              'dns_policy': 'ru_direct_split',
              'package_catalog_version': '2026.04.15.catalog',
              'ruleset_version': '2026.04.15.rules',
              'support_context': {
                'ip_version_preference': 'ipv4_only',
              },
            },
          },
          '/api/user/1001': {
            'tg_id': 1001,
            'username': 'alice',
            'subscription_url': 'https://connect.pokrov.space/sub/abc',
            'devices': [
              {
                'id': 'device_1',
                'name': 'Windows PC',
                'platform': 'Windows',
                'is_active': true,
                'last_seen_at': '2026-04-15T08:00:00Z',
              },
            ],
            'nodes': [
              {
                'code': 'nl',
                'name': 'Netherlands',
                'enabled': true,
              },
            ],
            'actions': {
              'pay_via_bot': 'https://t.me/pokrov_vpnbot?start=pay',
            },
            'client_policy': {
              'transport_profile': 'grpc_443_primary',
              'transport_kind': 'grpc',
              'engine_hint': 'singbox',
              'profile_revision': 'rev-7',
              'route_mode_default': 'all_traffic',
              'route_mode_choices': ['all_traffic', 'selected_apps'],
              'route_mode_requires_elevation': true,
              'route_mode': 'selected_apps',
              'selected_apps': ['chrome.exe', 'telegram.exe'],
              'requires_elevated_privileges': true,
              'route_policy': {
                'mode': 'selected_apps',
                'selected_apps': ['chrome.exe', 'telegram.exe'],
                'requires_elevated_privileges': true,
              },
              'support_context': {
                'transport': 'grpc_443_primary',
              },
            },
          },
          '/api/public/plans': {
            'widget_enabled': true,
            'plans': [
              {
                'code': '1_month',
                'label': '1 Month',
                'amount_rub': 249,
                'amount_stars': 249,
                'days': 30,
                'device_limit': 5,
                'node_policy': 'paid_pool',
                'badge': 'Popular',
                'is_active': true,
              },
            ],
          },
          '/api/tickets?limit=6': {
            'tickets': [
              {
                'id': 91,
                'status': 'open',
                'subject': 'Need help',
                'messages': [
                  {
                    'id': 900,
                    'sender_role': 'user',
                    'body': 'Hello',
                    'created_at': '2026-04-15T10:00:00Z',
                  },
                ],
              },
            ],
          },
          '/api/client/apps': {
            'android': {
              'apk_url': 'https://downloads.example.test/android.apk',
              'mirror_url': 'https://mirror.example.test/android.apk',
            },
            'windows': {
              'exe_url': 'https://downloads.example.test/windows.exe',
              'mirror_url': 'https://mirror.example.test/windows.exe',
            },
            'docs_url': 'https://docs.example.test/install',
          },
          '/api/nodes/status': {
            'nodes': [
              {
                'code': 'nl',
                'country': 'Netherlands',
                'enabled': true,
                'is_healthy': true,
              },
              {
                'code': 'pl',
                'country': 'Poland',
                'enabled': false,
                'is_healthy': false,
              },
            ],
          },
        }),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: _MemoryPortalSessionStore(sessionToken: 'runtime-token'),
      );

      final experience = await repository.getExperience();

      expect(experience.isDemo, isFalse);
      expect(experience.session.username, equals('alice'));
      expect(experience.dashboard.connectionPointsLabel, equals('1/2'));
      expect(experience.subscription.plans, hasLength(1));
      expect(experience.devices.single.platform, equals('Windows'));
      expect(experience.locations.single.title, equals('Netherlands'));
      expect(experience.supportThreads.single.messages, hasLength(1));
      expect(
        experience.downloads.map((item) => item.platformLabel),
        containsAll(<String>['Android', 'Windows']),
      );
      expect(experience.connectionPolicy.transportProfile, 'grpc_443_primary');
      expect(experience.connectionPolicy.transportKind, 'grpc');
      expect(experience.connectionPolicy.engineHint, 'singbox');
      expect(experience.connectionPolicy.profileRevision, 'rev-7');
      expect(experience.connectionPolicy.dnsPolicy, 'ru_direct_split');
      expect(
        experience.connectionPolicy.packageCatalogVersion,
        '2026.04.15.catalog',
      );
      expect(
        experience.connectionPolicy.rulesetVersion,
        '2026.04.15.rules',
      );
      expect(
        experience.connectionPolicy.routeModeDefault,
        'all_traffic',
      );
      expect(
        experience.connectionPolicy.routeModeChoices,
        equals(<String>['all_traffic', 'selected_apps']),
      );
      expect(
        experience.connectionPolicy.routeModeRequiresElevation,
        isTrue,
      );
      expect(
        experience.connectionPolicy.routePolicy.mode,
        'selected_apps',
      );
      expect(
        experience.connectionPolicy.routePolicy.selectedApps,
        equals(<String>['chrome.exe', 'telegram.exe']),
      );
      expect(
        experience.connectionPolicy.routePolicy.requiresElevatedPrivileges,
        isTrue,
      );
      expect(
        experience.connectionPolicy.supportRecoveryOrder,
        equals(<String>['app', 'web', 'telegram']),
      );
    });

    test('startTrial supports current top-level payload and keeps provisioning',
        () async {
      final sessionStore = _MemoryPortalSessionStore();
      Map<String, dynamic>? capturedBody;

      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          {
            '/api/dashboard': {
              'current_plan_code': 'trial_premium',
              'is_active': true,
              'expiry_at': '2026-04-20T00:00:00Z',
              'used_gb': 0,
              'total_gb': 15,
              'remaining_gb': 15,
              'active_sessions': 0,
              'device_limit': 1,
              'subscription_url': 'https://connect.pokrov.space/sub/trial',
            },
            '/api/user/1001': {
              'tg_id': 1001,
              'username': 'guest-1001',
              'device_name': 'Android device',
              'devices': [
                {
                  'id': 'device_1',
                  'name': 'Android device',
                  'platform': 'Android',
                  'is_active': true,
                },
              ],
              'client_policy': {
                'transport_profile': 'grpc_443_primary',
                'transport_kind': 'grpc',
                'engine_hint': 'singbox',
                'profile_revision': 'rev-11',
                'routing_mode_default': 'all_except_ru',
                'dns_policy': 'ru_direct_split',
                'route_mode_default': 'all_traffic',
                'route_mode_choices': ['all_traffic', 'selected_apps'],
                'route_mode': 'selected_apps',
                'selected_apps': ['org.telegram.messenger'],
                'requires_elevated_privileges': false,
                'route_policy': {
                  'mode': 'selected_apps',
                  'selected_apps': ['org.telegram.messenger'],
                  'requires_elevated_privileges': false,
                },
                'support_context': {
                  'transport': 'grpc_443_primary',
                  'routing_mode': 'all_except_ru',
                  'ip_version_preference': 'ipv4_only',
                },
                'support_recovery_order': ['app', 'web', 'telegram'],
              },
            },
            '/api/public/plans': const {
              'widget_enabled': true,
              'plans': [],
            },
            '/api/tickets?limit=6': const {
              'tickets': [],
            },
            '/api/client/apps': const {
              'android': {
                'apk_url': 'https://downloads.example.test/android.apk',
              },
            },
            '/api/nodes/status': const {
              'nodes': [
                {
                  'code': 'nl',
                  'country': 'Netherlands',
                  'is_healthy': true,
                },
              ],
            },
          },
          onPost: (path, body) async {
            capturedBody = body;
            return {
              'ok': true,
              'created': true,
              'session_token': 'runtime-session-123',
              'account_id': '1001',
              'subscription_url': 'https://connect.pokrov.space/sub/trial',
              'session': {
                'account_id': '1001',
                'session_token': 'runtime-session-123',
                'subscription_url': 'https://connect.pokrov.space/sub/trial',
              },
              'client_policy': {
                'routing_mode_default': 'all_except_ru',
                'transport_profile': 'grpc_443_primary',
                'transport_kind': 'grpc',
                'engine_hint': 'singbox',
                'profile_revision': 'rev-11',
                'dns_policy': 'ru_direct_split',
                'route_mode_default': 'all_traffic',
                'route_mode_choices': ['all_traffic', 'selected_apps'],
                'route_mode': 'selected_apps',
                'selected_apps': ['org.telegram.messenger'],
                'requires_elevated_privileges': false,
                'route_policy': {
                  'mode': 'selected_apps',
                  'selected_apps': ['org.telegram.messenger'],
                  'requires_elevated_privileges': false,
                },
                'support_context': {
                  'transport': 'grpc_443_primary',
                  'routing_mode': 'all_except_ru',
                  'ip_version_preference': 'ipv4_only',
                },
                'support_recovery_order': ['app', 'web', 'telegram'],
              },
              'access': {
                'sub_type': 'trial_premium',
                'current_plan_code': 'trial_premium',
                'is_active': true,
                'subscription_url': 'https://connect.pokrov.space/sub/trial',
                'expiry_at': '2026-04-20T00:00:00Z',
              },
              'provisioning': {
                'status': 'ready',
                'subscription_url': 'https://connect.pokrov.space/sub/trial',
                'managed_manifest': {
                  'url': '/api/client/profile/managed',
                  'transport_kind': 'grpc',
                  'engine_hint': 'singbox',
                  'profile_revision': 'rev-11',
                },
              },
            };
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: sessionStore,
      );

      final experience = await repository.startTrial(
        const PortalStartTrialRequest(
          installId: 'install-123',
          deviceName: 'Android device',
          platform: 'android',
          operatingSystemVersion: '14',
          appVersion: '1.0.0',
          localeTag: 'ru',
          timeZone: 'MSK',
        ),
      );

      expect(sessionStore.readSessionTokenSync(), 'runtime-session-123');
      expect(experience.isDemo, isFalse);
      expect(
        experience.importPayload.managedManifest.url,
        '/api/client/profile/managed',
      );
      expect(
        experience.connectionPolicy.routePolicy.mode,
        'selected_apps',
      );
      expect(
        experience.connectionPolicy.routePolicy.selectedApps,
        equals(<String>['org.telegram.messenger']),
      );
      expect(capturedBody, isNotNull);
      expect(capturedBody!['install_id'], equals('install-123'));
      expect(capturedBody!.containsKey('trial_days'), isFalse);
      expect(capturedBody!['locale'], equals('ru'));
    });

    test('fetchManagedProfile returns structured json payload', () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient({
          '/api/client/profile/managed': {
            'version': 'rollout-v1',
            'profile_revision': 'rev-7',
            'transport_profile': 'grpc_443_primary',
            'transport_kind': 'grpc',
            'engine_hint': 'singbox',
            'config_format': 'singbox-json',
            'config_payload': {
              'outbounds': [
                {'tag': 'selector'},
              ],
            },
            'fallback_order': ['subscription_url'],
            'support_context': {
              'transport': 'grpc_443_primary',
              'routing_mode': 'all_except_ru',
              'ip_version_preference': 'ipv4_only',
            },
            'subscription_url': 'https://connect.pokrov.space/sub/abc',
            'smart_connect': {
              'shortlist_revision': 'short-1',
            },
          },
        }),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: _MemoryPortalSessionStore(sessionToken: 'runtime-token'),
      );

      final managedProfile = await repository.fetchManagedProfile(
        const PortalManagedManifest(url: '/api/client/profile/managed'),
      );

      expect(managedProfile.profileRevision, equals('rev-7'));
      expect(managedProfile.transportProfile, equals('grpc_443_primary'));
      expect(managedProfile.importContent(), isNotNull);
      expect(
        jsonDecode(managedProfile.importContent()!),
        isA<Map<String, dynamic>>(),
      );
      expect(managedProfile.smartConnect['shortlist_revision'], 'short-1');
    });

    test('saveRoutePolicy returns backend-normalized route state', () async {
      final repository = PortalRepositoryImpl(
        apiClient: _FakePortalApiClient(
          const {},
          onPost: (path, body) async {
            expect(path, '/api/client/route-policy');
            expect(body['route_mode'], 'selected_apps');
            return {
              'ok': true,
              'route_mode': 'selected_apps',
              'selected_apps': ['telegram.exe'],
              'requires_elevated_privileges': true,
              'route_policy': {
                'mode': 'selected_apps',
                'selected_apps': ['telegram.exe'],
                'requires_elevated_privileges': true,
              },
            };
          },
        ),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: _MemoryPortalSessionStore(sessionToken: 'runtime-token'),
      );

      final routePolicy = await repository.saveRoutePolicy(
        const PortalRoutePolicyInput(
          mode: 'selected_apps',
          selectedApps: ['telegram.exe'],
          requiresElevatedPrivileges: true,
        ),
      );

      expect(routePolicy.mode, equals('selected_apps'));
      expect(routePolicy.selectedApps, equals(<String>['telegram.exe']));
      expect(routePolicy.requiresElevatedPrivileges, isTrue);
    });

    test('falls back to demo experience when portal is unavailable', () async {
      final repository = PortalRepositoryImpl(
        apiClient: _ThrowingPortalApiClient(),
        config: PortalPublicConfig.fromMap(const {}),
        sessionStore: _MemoryPortalSessionStore(),
      );

      final experience = await repository.getExperience();

      expect(experience.isDemo, isTrue);
      expect(experience.session.isAuthorized, isFalse);
      expect(experience.subscription.plans, isNotEmpty);
    });
  });
}
