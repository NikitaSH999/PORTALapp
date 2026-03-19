import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/model/constants.dart';

void main() {
  group('Constants', () {
    test('uses the final product name', () {
      expect(Constants.appName, 'PORTAL VPN');
    });

    test('uses branded support links', () {
      expect(Constants.telegramChannelUrl, contains('portal'));
      expect(Constants.privacyPolicyUrl, contains('portalvpn'));
      expect(Constants.termsAndConditionsUrl, contains('portalvpn'));
    });
  });
}
