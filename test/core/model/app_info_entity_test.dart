import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';

void main() {
  test('userAgent keeps a neutral first-party identity', () {
    const info = AppInfoEntity(
      name: 'POKROV VPN',
      version: '2.0.0',
      buildNumber: '200',
      release: Release.general,
      operatingSystem: 'android',
      operatingSystemVersion: '15',
      environment: Environment.prod,
    );

    expect(info.userAgent, 'POKROVVPN/2.0.0 (android; general)');
    expect(info.userAgent.toLowerCase(), isNot(contains('clash')));
    expect(info.userAgent.toLowerCase(), isNot(contains('v2ray')));
    expect(info.userAgent.toLowerCase(), isNot(contains('sing-box')));
    expect(info.userAgent.toLowerCase(), isNot(contains('v2rayng')));
  });
}
