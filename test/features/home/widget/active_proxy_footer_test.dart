import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/proxy/active/active_proxy_footer.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/proxy/model/ip_info_entity.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hiddify/features/stats/model/stats_entity.dart';
import 'package:hiddify/features/stats/notifier/stats_notifier.dart';
import 'package:hiddify/singbox/model/singbox_proxy_type.dart';

import '../../../test_helpers/premium_test_app.dart';

class _TestActiveProxyNotifier extends ActiveProxyNotifier {
  @override
  Stream<ProxyItemEntity> build() async* {
    yield const ProxyItemEntity(
      tag: 'nl-amsterdam',
      type: ProxyType.urltest,
      urlTestDelay: 42,
      selectedTag: 'Netherlands',
    );
  }
}

class _TestIpInfoNotifier extends IpInfoNotifier {
  @override
  Future<IpInfo> build() async => const IpInfo(
        ip: '203.0.113.1',
        countryCode: 'NL',
      );
}

class _TestStatsNotifier extends StatsNotifier {
  @override
  Stream<StatsEntity> build() async* {
    yield const StatsEntity(
      uplink: 128,
      downlink: 256,
      uplinkTotal: 1024,
      downlinkTotal: 2048,
    );
  }
}

void main() {
  testWidgets(
      'stacks footer stats under the location summary on compact widths',
      (tester) async {
    await tester.pumpWidget(
      buildPremiumTestApp(
        surfaceSize: const Size(320, 640),
        overrides: [
          activeProxyNotifierProvider
              .overrideWith(_TestActiveProxyNotifier.new),
          ipInfoNotifierProvider.overrideWith(_TestIpInfoNotifier.new),
          statsNotifierProvider.overrideWith(_TestStatsNotifier.new),
        ],
        child: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: ActiveProxyFooter(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final locationLabel = find.text('Netherlands');
    final speedIcon = find.byIcon(FluentIcons.arrow_download_20_regular);

    expect(locationLabel, findsOneWidget);
    expect(speedIcon, findsOneWidget);
    expect(
      tester.getTopLeft(speedIcon).dy,
      greaterThan(tester.getBottomLeft(locationLabel).dy),
    );
  });
}
