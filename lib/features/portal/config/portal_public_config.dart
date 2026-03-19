class PortalPublicConfig {
  const PortalPublicConfig({
    required this.brandName,
    required this.apiBaseUrl,
    required this.webappUrl,
    required this.checkoutUrl,
    required this.botUrl,
    required this.helpbotUrl,
    required this.supportTelegramUrl,
    required this.contactEmail,
    required this.enterpriseEmail,
    required this.contactFormUrl,
    required this.newsChannelUrl,
    required this.androidPlayUrl,
    required this.androidApkUrl,
    required this.androidMirrorUrl,
    required this.windowsExeUrl,
    required this.windowsMirrorUrl,
    required this.docsUrl,
    required this.webSessionToken,
    required this.telegramInitData,
  });

  final String brandName;
  final String apiBaseUrl;
  final String webappUrl;
  final String checkoutUrl;
  final String botUrl;
  final String helpbotUrl;
  final String supportTelegramUrl;
  final String contactEmail;
  final String enterpriseEmail;
  final String contactFormUrl;
  final String newsChannelUrl;
  final String androidPlayUrl;
  final String androidApkUrl;
  final String androidMirrorUrl;
  final String windowsExeUrl;
  final String windowsMirrorUrl;
  final String docsUrl;
  final String webSessionToken;
  final String telegramInitData;

  bool get hasRemoteSessionAuth =>
      webSessionToken.isNotEmpty || telegramInitData.isNotEmpty;

  bool get isDemoMode => !hasRemoteSessionAuth;

  static PortalPublicConfig environment() {
    return fromMap({
      'PORTAL_BRAND_NAME': const String.fromEnvironment('PORTAL_BRAND_NAME'),
      'PORTAL_API_BASE_URL': const String.fromEnvironment('PORTAL_API_BASE_URL'),
      'PORTAL_WEBAPP_URL': const String.fromEnvironment('PORTAL_WEBAPP_URL'),
      'PORTAL_CHECKOUT_URL': const String.fromEnvironment('PORTAL_CHECKOUT_URL'),
      'PORTAL_BOT_URL': const String.fromEnvironment('PORTAL_BOT_URL'),
      'PORTAL_HELPBOT_URL': const String.fromEnvironment('PORTAL_HELPBOT_URL'),
      'PORTAL_SUPPORT_TG_URL': const String.fromEnvironment('PORTAL_SUPPORT_TG_URL'),
      'PORTAL_CONTACT_EMAIL': const String.fromEnvironment('PORTAL_CONTACT_EMAIL'),
      'PORTAL_ENTERPRISE_EMAIL': const String.fromEnvironment('PORTAL_ENTERPRISE_EMAIL'),
      'PORTAL_CONTACT_FORM_URL': const String.fromEnvironment('PORTAL_CONTACT_FORM_URL'),
      'PORTAL_NEWS_CHANNEL_URL': const String.fromEnvironment('PORTAL_NEWS_CHANNEL_URL'),
      'PORTAL_ANDROID_PLAY_URL': const String.fromEnvironment('PORTAL_ANDROID_PLAY_URL'),
      'PORTAL_ANDROID_APK_URL': const String.fromEnvironment('PORTAL_ANDROID_APK_URL'),
      'PORTAL_ANDROID_MIRROR_URL': const String.fromEnvironment('PORTAL_ANDROID_MIRROR_URL'),
      'PORTAL_WINDOWS_EXE_URL': const String.fromEnvironment('PORTAL_WINDOWS_EXE_URL'),
      'PORTAL_WINDOWS_MIRROR_URL': const String.fromEnvironment('PORTAL_WINDOWS_MIRROR_URL'),
      'PORTAL_DOCS_URL': const String.fromEnvironment('PORTAL_DOCS_URL'),
      'PORTAL_WEB_SESSION_TOKEN': const String.fromEnvironment('PORTAL_WEB_SESSION_TOKEN'),
      'PORTAL_TELEGRAM_INIT_DATA': const String.fromEnvironment('PORTAL_TELEGRAM_INIT_DATA'),
    });
  }

  static PortalPublicConfig fromMap(Map<String, String> raw) {
    final apiBaseUrl = _cleanUrl(
      raw['PORTAL_API_BASE_URL'],
      fallback: 'https://kiwunaka.space',
    );
    final webBase = _cleanUrl(
      raw['PORTAL_WEBAPP_URL'],
      fallback: 'https://portal-privacy.online/webapp',
    );
    final checkoutUrl = _normalizeCheckoutUrl(
      raw['PORTAL_CHECKOUT_URL'],
      fallbackHost: 'https://portal-privacy.online',
    );
    final helpbotUrl = _normalizeTelegramUrl(
      raw['PORTAL_HELPBOT_URL'] ?? raw['PORTAL_SUPPORT_TG_URL'],
      fallback: 'https://t.me/portal_privacy_helpbot',
    );

    return PortalPublicConfig(
      brandName: _trim(raw['PORTAL_BRAND_NAME'], fallback: 'PORTAL VPN'),
      apiBaseUrl: apiBaseUrl,
      webappUrl: webBase,
      checkoutUrl: checkoutUrl,
      botUrl: _normalizeTelegramUrl(
        raw['PORTAL_BOT_URL'],
        fallback: 'https://t.me/portal_service_bot',
      ),
      helpbotUrl: helpbotUrl,
      supportTelegramUrl: helpbotUrl,
      contactEmail: _trim(
        raw['PORTAL_CONTACT_EMAIL'],
        fallback: 'support@portal-privacy.online',
      ),
      enterpriseEmail: _trim(
        raw['PORTAL_ENTERPRISE_EMAIL'],
        fallback: 'enterprise@portal-privacy.online',
      ),
      contactFormUrl: _normalizeTelegramUrl(
        raw['PORTAL_CONTACT_FORM_URL'],
        fallback: helpbotUrl,
      ),
      newsChannelUrl: _normalizeTelegramUrl(
        raw['PORTAL_NEWS_CHANNEL_URL'],
        fallback: 'https://t.me/portal_privacy',
      ),
      androidPlayUrl: _trim(raw['PORTAL_ANDROID_PLAY_URL']),
      androidApkUrl: _trim(raw['PORTAL_ANDROID_APK_URL']),
      androidMirrorUrl: _trim(raw['PORTAL_ANDROID_MIRROR_URL']),
      windowsExeUrl: _trim(raw['PORTAL_WINDOWS_EXE_URL']),
      windowsMirrorUrl: _trim(raw['PORTAL_WINDOWS_MIRROR_URL']),
      docsUrl: _trim(raw['PORTAL_DOCS_URL']),
      webSessionToken: _trim(raw['PORTAL_WEB_SESSION_TOKEN']),
      telegramInitData: _trim(raw['PORTAL_TELEGRAM_INIT_DATA']),
    );
  }
}

String _trim(String? value, {String fallback = ''}) {
  return (value ?? fallback).trim();
}

String _cleanUrl(String? value, {String fallback = ''}) {
  final normalized = _trim(value, fallback: fallback);
  if (normalized.isEmpty) return normalized;
  return normalized.replaceFirst(RegExp(r'/+$'), '');
}

String _normalizeTelegramUrl(String? raw, {required String fallback}) {
  final value = _cleanUrl(raw, fallback: fallback);
  if (value.isEmpty) return fallback;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  return 'https://t.me/${value.replaceFirst(RegExp(r'^@+'), '')}';
}

String _normalizeCheckoutUrl(String? raw, {required String fallbackHost}) {
  final value = _cleanUrl(raw);
  if (value.isNotEmpty) return value;
  return '${_cleanUrl(fallbackHost)}/checkout';
}
