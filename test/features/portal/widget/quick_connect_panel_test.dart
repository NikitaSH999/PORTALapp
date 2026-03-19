import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/quick_connect_panel.dart';

void main() {
  testWidgets('shows quick connect summary for an active trial', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PortalQuickConnectPanel(
            experience: _experience(),
            onOpenLocations: () {},
            onOpenTelegramReward: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick connect'), findsOneWidget);
    expect(find.text('Auto-select'), findsOneWidget);
    expect(find.text('Netherlands'), findsOneWidget);
    expect(find.text('Trial active'), findsOneWidget);
    expect(find.text('+10 days for Telegram'), findsOneWidget);
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
      activeSessions: 0,
      deviceLimit: 1,
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
        id: 'nl',
        title: 'Netherlands',
        subtitle: 'Amsterdam',
        platform: 'Location',
        isActive: true,
      ),
      DeviceRecord(
        id: 'de',
        title: 'Germany',
        subtitle: 'Frankfurt',
        platform: 'Location',
        isActive: false,
      ),
    ],
    usage: UsageStats(
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 0,
      deviceLimit: 1,
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
