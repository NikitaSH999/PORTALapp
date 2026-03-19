import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/devices_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows consumer device overview with current device name', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith((ref) async => _experience()),
        ],
        child: const MaterialApp(home: DevicesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Current device'), findsOneWidget);
    expect(find.text('Android device'), findsWidgets);
    expect(find.text('Available slots'), findsOneWidget);
    expect(find.text('MacBook Pro'), findsOneWidget);
  });
}

PortalExperience _experience() {
  return const PortalExperience(
    isDemo: false,
    session: SessionSummary(
      tgId: 0,
      accountId: 'acc_1',
      deviceName: 'Android device',
      username: 'guest-acc_1',
      isAuthorized: true,
    ),
    dashboard: DashboardSummary(
      isActive: true,
      currentPlanLabel: 'Trial',
      statusHeadline: 'Ready to connect',
      statusBody: 'Your trial is active.',
      expiresAt: null,
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      connectionKey: 'https://portal.example.test/sub/trial',
      healthyNodes: 2,
      totalNodes: 2,
    ),
    subscription: SubscriptionState(
      currentPlanCode: 'trial_5_days',
      currentPlanLabel: 'Trial',
      isTrialLike: true,
      checkoutEnabled: true,
      checkoutUrl: 'https://portal.example.test/checkout',
      payViaBotUrl: 'https://t.me/portal_service_bot',
      plans: [],
    ),
    checkout: null,
    devices: [
      DeviceRecord(
        id: 'device_1',
        title: 'Android device',
        subtitle: 'Last active just now',
        platform: 'Android',
        isActive: true,
      ),
      DeviceRecord(
        id: 'device_2',
        title: 'MacBook Pro',
        subtitle: 'Last active 10 minutes ago',
        platform: 'Windows',
        isActive: false,
      ),
    ],
    usage: UsageStats(
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      healthyNodes: 2,
      totalNodes: 2,
    ),
    supportThreads: [],
    downloads: [],
    importPayload: ImportPayload(
      subscriptionUrl: 'https://portal.example.test/sub/trial',
      smartUrl: 'https://portal.example.test/sub/trial?format=smart',
      plainUrl: 'https://portal.example.test/sub/trial?format=plain',
      qrValue: 'https://portal.example.test/sub/trial',
    ),
  );
}
