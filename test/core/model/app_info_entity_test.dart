import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/app_info_entity.dart';
import 'package:hiddify/core/model/environment.dart';

void main() {
  test('uses branded user agent prefix', () {
    const entity = AppInfoEntity(
      name: 'POKROV VPN',
      version: '2.5.7',
      buildNumber: '20507',
      release: Release.general,
      operatingSystem: 'windows',
      operatingSystemVersion: '11',
      environment: Environment.prod,
    );

    expect(entity.userAgent, startsWith('POKROVVPN/2.5.7'));
    expect(entity.userAgent, isNot(contains('HiddifyNext')));
  });
}
