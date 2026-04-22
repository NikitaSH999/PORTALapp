import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/data/portal_trial_activator.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/model/profile_failure.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';

class _FakePortalRepository implements PortalRepository {
  _FakePortalRepository(
    this.experience, {
    this.managedProfile = const PortalManagedProfile(),
    this.throwOnManagedProfile = false,
  });

  final PortalExperience experience;
  final PortalManagedProfile managedProfile;
  final bool throwOnManagedProfile;
  PortalStartTrialRequest? capturedRequest;
  PortalManagedManifest? capturedManagedManifest;

  @override
  Future<TelegramBonusClaimResult> claimTelegramBonus() async {
    return const TelegramBonusClaimResult(
      ok: true,
      alreadyClaimed: false,
      premiumDays: 10,
      linkedTelegramId: 0,
      linkedTelegramUsername: '',
    );
  }

  @override
  Future<PortalManagedProfile> fetchManagedProfile(
    PortalManagedManifest manifest,
  ) async {
    capturedManagedManifest = manifest;
    if (throwOnManagedProfile) {
      throw StateError('managed profile unavailable');
    }
    return managedProfile;
  }

  @override
  Future<PortalExperience> getExperience() async => experience;

  @override
  Future<TelegramLinkSession> requestTelegramLink() async {
    return const TelegramLinkSession(
      linked: false,
      linkedTelegramId: 0,
      linkedTelegramUsername: '',
      startCode: 'app-test',
      botUrl: 'https://t.me/pokrov_vpnbot?start=app-test',
      channelUrl: 'https://t.me/pokrov_vpn',
    );
  }

  @override
  Future<PortalRoutePolicyState> saveRoutePolicy(
    PortalRoutePolicyInput input,
  ) async {
    return PortalRoutePolicyState(
      mode: input.mode,
      selectedApps: input.selectedApps,
      requiresElevatedPrivileges: input.requiresElevatedPrivileges ?? false,
    );
  }

  @override
  Future<PortalExperience> startTrial(PortalStartTrialRequest request) async {
    capturedRequest = request;
    return experience;
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

class _FakeProfileRepository implements ProfileRepository {
  String? importedUrl;
  String? importedContent;

  @override
  TaskEither<ProfileFailure, Unit> addLocal(
    String content, {
    UserOverride? userOverride,
  }) {
    importedContent = content;
    return TaskEither.right(unit);
  }

  @override
  TaskEither<ProfileFailure, Unit> upsertRemote(
    String url, {
    UserOverride? userOverride,
    CancelToken? cancelToken,
  }) {
    importedUrl = url;
    return TaskEither.right(unit);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PortalExperience _buildExperience({
  required PortalManagedManifest managedManifest,
  required String subscriptionUrl,
}) {
  return PortalExperience(
    isDemo: false,
    session: const SessionSummary(
      tgId: 0,
      accountId: 'acc_1001',
      deviceName: 'Android device',
      username: 'guest-acc_1001',
      isAuthorized: true,
    ),
    dashboard: DashboardSummary(
      isActive: true,
      currentPlanLabel: 'Trial',
      statusHeadline: 'Ready to connect',
      statusBody: 'Trial is active on this device.',
      expiresAt: DateTime(2026, 4, 20),
      usedGb: 0,
      totalGb: 15,
      remainingGb: 15,
      activeSessions: 0,
      deviceLimit: 1,
      connectionKey: subscriptionUrl,
      healthyNodes: 1,
      totalNodes: 1,
    ),
    subscription: const SubscriptionState(
      currentPlanCode: 'trial_5_days',
      currentPlanLabel: 'Trial',
      isTrialLike: true,
      checkoutEnabled: true,
      checkoutUrl: 'https://pay.pokrov.space/checkout/',
      payViaBotUrl: 'https://t.me/pokrov_vpnbot',
      plans: [],
    ),
    checkout: null,
    devices: const [],
    usage: const UsageStats(
      usedGb: 0,
      totalGb: 15,
      remainingGb: 15,
      activeSessions: 0,
      deviceLimit: 1,
      healthyNodes: 1,
      totalNodes: 1,
    ),
    supportThreads: const [],
    downloads: const [],
    importPayload: ImportPayload(
      subscriptionUrl: subscriptionUrl,
      smartUrl: '$subscriptionUrl?format=smart',
      plainUrl: '$subscriptionUrl?format=plain',
      qrValue: subscriptionUrl,
      managedManifest: managedManifest,
    ),
  );
}

void main() {
  test(
      'activateTrial prefers managed json payload and imports it as local config',
      () async {
    final repository = _FakePortalRepository(
      _buildExperience(
        managedManifest: const PortalManagedManifest(
          url: '/api/client/profile/managed',
          transportKind: 'grpc',
          engineHint: 'singbox',
          profileRevision: 'rev-11',
        ),
        subscriptionUrl: 'https://connect.pokrov.space/sub/trial',
      ),
      managedProfile: const PortalManagedProfile(
        configFormat: 'singbox-json',
        configPayload: {
          'outbounds': [
            {'tag': 'selector'},
          ],
        },
      ),
    );
    final profileRepository = _FakeProfileRepository();
    final activator = PortalTrialActivator(
      portalRepository: repository,
      sessionStore: _MemoryPortalSessionStore(),
      loadProfileRepository: () async => profileRepository,
      appInfo: AppInfoEntity(
        name: 'POKROV',
        version: '1.0.0',
        buildNumber: '100',
        release: Release.general,
        operatingSystem: 'android',
        operatingSystemVersion: '14',
        environment: Environment.prod,
      ),
    );

    await activator.activateTrial(locale: const Locale('ru'));

    expect(repository.capturedRequest, isNotNull);
    expect(repository.capturedRequest!.installId, equals('install-123'));
    expect(repository.capturedRequest!.localeTag, equals('ru'));
    expect(repository.capturedManagedManifest, isNotNull);
    expect(profileRepository.importedUrl, isNull);
    expect(profileRepository.importedContent, isNotNull);
    expect(
      jsonDecode(profileRepository.importedContent!),
      isA<Map<String, dynamic>>(),
    );
  });

  test(
      'activateTrial falls back to remote subscription when managed profile fetch fails',
      () async {
    final repository = _FakePortalRepository(
      _buildExperience(
        managedManifest: const PortalManagedManifest(
          url: '/api/client/profile/managed',
        ),
        subscriptionUrl: 'https://connect.pokrov.space/sub/trial',
      ),
      throwOnManagedProfile: true,
    );
    final profileRepository = _FakeProfileRepository();
    final activator = PortalTrialActivator(
      portalRepository: repository,
      sessionStore: _MemoryPortalSessionStore(),
      loadProfileRepository: () async => profileRepository,
      appInfo: AppInfoEntity(
        name: 'POKROV',
        version: '1.0.0',
        buildNumber: '100',
        release: Release.general,
        operatingSystem: 'android',
        operatingSystemVersion: '14',
        environment: Environment.prod,
      ),
    );

    await activator.activateTrial(locale: const Locale('en'));

    expect(repository.capturedManagedManifest, isNotNull);
    expect(
      profileRepository.importedUrl,
      equals('https://connect.pokrov.space/sub/trial'),
    );
    expect(profileRepository.importedContent, isNull);
  });
}
