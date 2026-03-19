import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';

void main() {
  group('PortalPublicConfig.fromMap', () {
    test('uses branded defaults when no overrides are provided', () {
      final config = PortalPublicConfig.fromMap(const {});

      expect(config.brandName, equals('PORTAL VPN'));
      expect(config.apiBaseUrl, equals('https://kiwunaka.space'));
      expect(config.webappUrl, equals('https://portal-privacy.online/webapp'));
      expect(config.checkoutUrl, equals('https://portal-privacy.online/checkout'));
      expect(config.botUrl, equals('https://t.me/portal_service_bot'));
      expect(config.supportTelegramUrl, equals('https://t.me/portal_privacy_helpbot'));
      expect(config.contactEmail, equals('support@portal-privacy.online'));
      expect(config.hasRemoteSessionAuth, isFalse);
      expect(config.isDemoMode, isTrue);
    });

    test('normalizes overrides and turns off demo mode when auth is provided', () {
      final config = PortalPublicConfig.fromMap(const {
        'PORTAL_BRAND_NAME': 'Portal One',
        'PORTAL_API_BASE_URL': 'https://api.example.test/',
        'PORTAL_WEBAPP_URL': 'https://portal.example.test/webapp/',
        'PORTAL_CHECKOUT_URL': 'https://pay.example.test/checkout/',
        'PORTAL_BOT_URL': '@portal_one_bot',
        'PORTAL_SUPPORT_TG_URL': 'portal_helpdesk',
        'PORTAL_ANDROID_APK_URL': 'https://cdn.example.test/android.apk',
        'PORTAL_WINDOWS_EXE_URL': 'https://cdn.example.test/windows.exe',
        'PORTAL_DOCS_URL': 'https://docs.example.test/install',
        'PORTAL_WEB_SESSION_TOKEN': 'session-token',
      });

      expect(config.brandName, equals('Portal One'));
      expect(config.apiBaseUrl, equals('https://api.example.test'));
      expect(config.webappUrl, equals('https://portal.example.test/webapp'));
      expect(config.checkoutUrl, equals('https://pay.example.test/checkout'));
      expect(config.botUrl, equals('https://t.me/portal_one_bot'));
      expect(config.supportTelegramUrl, equals('https://t.me/portal_helpdesk'));
      expect(config.androidApkUrl, equals('https://cdn.example.test/android.apk'));
      expect(config.windowsExeUrl, equals('https://cdn.example.test/windows.exe'));
      expect(config.docsUrl, equals('https://docs.example.test/install'));
      expect(config.hasRemoteSessionAuth, isTrue);
      expect(config.isDemoMode, isFalse);
    });
  });
}
