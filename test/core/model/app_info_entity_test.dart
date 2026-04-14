import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';

void main() {
  test('userAgent keeps a neutral first-party identity', () {
    const info = AppInfoEntity(
      name: 'POKROV',
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

  test('presentVersion keeps the public beta label without a dev suffix', () {
    const info = AppInfoEntity(
      name: 'POKROV',
      version: '0.9.0-beta',
      buildNumber: '20508',
      release: Release.general,
      operatingSystem: 'windows',
      operatingSystemVersion: '10',
      environment: Environment.dev,
    );

    expect(info.presentVersion, '0.9.0-beta');
  });

  test('presentVersion normalizes inherited build labels to a beta line', () {
    const info = AppInfoEntity(
      name: 'POKROV',
      version: '2.5.7 dev',
      buildNumber: '20508',
      release: Release.general,
      operatingSystem: 'windows',
      operatingSystemVersion: '11',
      environment: Environment.dev,
    );

    expect(info.presentVersion, '2.5.7-beta');
  });
}
