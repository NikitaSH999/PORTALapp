import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_repository.dart';
import 'package:hiddify/features/portal/model/portal_models.dart';
import 'package:hiddify/features/portal/widget/support_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('shows in-app support composer and device context', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portalExperienceProvider.overrideWith((ref) async => _experience()),
          portalPublicConfigProvider.overrideWithValue(
            PortalPublicConfig.fromMap(const {}),
          ),
        ],
        child: const MaterialApp(home: SupportPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Write from the app'), findsOneWidget);
    expect(find.text('Android device'), findsOneWidget);
    expect(find.text('Send diagnostics'), findsOneWidget);
    expect(find.text('Billing issue'), findsOneWidget);
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
    devices: [],
    usage: UsageStats(
      usedGb: 1,
      totalGb: 15,
      remainingGb: 14,
      activeSessions: 1,
      deviceLimit: 5,
      healthyNodes: 2,
      totalNodes: 2,
    ),
    supportThreads: [
      SupportThread(
        id: 1,
        subject: 'Billing issue',
        status: 'open',
        messages: [
          SupportMessage(
            id: 1,
            body: 'Need help with my renewal.',
            senderRole: 'user',
            createdAt: null,
          ),
        ],
      ),
    ],
    downloads: [],
    importPayload: ImportPayload(
      subscriptionUrl: 'https://portal.example.test/sub/trial',
      smartUrl: 'https://portal.example.test/sub/trial?format=smart',
      plainUrl: 'https://portal.example.test/sub/trial?format=plain',
      qrValue: 'https://portal.example.test/sub/trial',
    ),
  );
}
