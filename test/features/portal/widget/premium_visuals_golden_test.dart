import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';
import 'package:hiddify/features/portal/widget/quick_connect_panel.dart';

import '../../../test_helpers/portal_experience_fixture.dart';
import '../../../test_helpers/premium_test_app.dart';

void main() {
  testWidgets('quick connect panel premium layout stays stable',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildPremiumTestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: PortalQuickConnectPanel(
                experience: buildPortalExperienceFixture(),
                onOpenLocations: () {},
                onOpenTelegramReward: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/quick_connect_panel_premium.png'),
    );
  });

  testWidgets('empty home premium onboarding card stays stable',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildPremiumTestApp(
        child: const Scaffold(
          body: CustomScrollView(
            slivers: [
              EmptyProfilesHomeBody(),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/empty_home_premium.png'),
    );
  });
}
