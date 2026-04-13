import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';
import 'package:hiddify/features/portal/data/portal_trial_activator.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/profile/data/profile_repository.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';

class _FakePortalRepository implements PortalRepository {
  _FakePortalRepository(this.experience);

  final PortalExperience experience;
  PortalStartTrialRequest? capturedRequest;

  @override
  Future<PortalExperience> getExperience() async => experience;

  @override
  Future<PortalExperience> startTrial(PortalStartTrialRequest request) async {
    capturedRequest = request;
    return experience;
  }

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
  Future<TelegramLinkSession> requestTelegramLink() async {
    return const TelegramLinkSession(
      linked: false,
      linkedTelegramId: 0,
      linkedTelegramUsername: '',
      startCode: 'app-test',
      botUrl: 'https://t.me/portal_service_bot?start=app-test',
      channelUrl: 'https://t.me/portal_privacy',
    );
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
  bool? importedAsActive;

  @override
  Future<ProfileEntity?> getByName(String name) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  addByUrl(
    String url, {
    bool markAsActive = false,
    cancelToken,
  }) {
    importedUrl = url;
    importedAsActive = markAsActive;
    return TaskEither.right(unit);
  }
}

void main() {
  test(
      'activateTrial builds app-first request and silently imports subscription',
      () async {
    final repository = _FakePortalRepository(
      PortalExperience(
        isDemo: false,
        session: const SessionSummary(
          tgId: 0,
          accountId: 'acc_1001',
          deviceName: 'Android device',
          username: 'guest-acc_1001',
          isAuthorized: true,
        ),
        dashboard: const DashboardSummary(
          isActive: true,
          currentPlanLabel: 'Trial',
          statusHeadline: 'Ready to connect',
          statusBody: 'Trial is active on this device.',
          expiresAt: null,
          usedGb: 0,
          totalGb: 15,
          remainingGb: 15,
          activeSessions: 0,
          deviceLimit: 1,
          connectionKey: 'https://portal.example.test/sub/trial',
          healthyNodes: 1,
          totalNodes: 1,
        ),
        subscription: const SubscriptionState(
          currentPlanCode: 'trial_5_days',
          currentPlanLabel: 'Trial',
          isTrialLike: true,
          checkoutEnabled: true,
          checkoutUrl: 'https://portal.example.test/checkout',
          payViaBotUrl: 'https://t.me/portal_service_bot',
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
        importPayload: const ImportPayload(
          subscriptionUrl: 'https://portal.example.test/sub/trial',
          smartUrl: 'https://portal.example.test/sub/trial?format=smart',
          plainUrl: 'https://portal.example.test/sub/trial?format=plain',
          qrValue: 'https://portal.example.test/sub/trial',
        ),
      ),
    );
    final profileRepository = _FakeProfileRepository();
    final activator = PortalTrialActivator(
      portalRepository: repository,
      sessionStore: _MemoryPortalSessionStore(),
      loadProfileRepository: () async => profileRepository,
      appInfo: AppInfoEntity(
        name: 'POKROV VPN',
        version: '1.0.0',
        buildNumber: '100',
        release: Release.general,
        operatingSystem: 'android',
        operatingSystemVersion: '14',
        environment: Environment.prod,
      ),
    );

    final experience = await activator.activateTrial(
      locale: const Locale('ru'),
    );

    expect(experience.importPayload.subscriptionUrl, contains('/sub/trial'));
    expect(profileRepository.importedUrl,
        equals('https://portal.example.test/sub/trial'));
    expect(profileRepository.importedAsActive, isTrue);
    expect(repository.capturedRequest, isNotNull);
    expect(repository.capturedRequest!.installId, equals('install-123'));
    expect(repository.capturedRequest!.deviceName, equals('Android device'));
    expect(repository.capturedRequest!.localeTag, equals('ru'));
  });
}
