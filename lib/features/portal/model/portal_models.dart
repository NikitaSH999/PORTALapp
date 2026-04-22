import 'dart:convert';

import 'package:hiddify/features/portal/config/portal_public_config.dart';

class SessionSummary {
  const SessionSummary({
    required this.tgId,
    required this.accountId,
    required this.deviceName,
    required this.username,
    required this.isAuthorized,
    this.linkedTelegramId = 0,
    this.linkedTelegramUsername = '',
  });

  final int tgId;
  final String accountId;
  final String deviceName;
  final String username;
  final bool isAuthorized;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
}

class TelegramLinkSession {
  const TelegramLinkSession({
    required this.linked,
    required this.linkedTelegramId,
    required this.linkedTelegramUsername,
    required this.startCode,
    required this.botUrl,
    required this.channelUrl,
  });

  final bool linked;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
  final String startCode;
  final String botUrl;
  final String channelUrl;
}

class TelegramBonusClaimResult {
  const TelegramBonusClaimResult({
    required this.ok,
    required this.alreadyClaimed,
    required this.premiumDays,
    required this.linkedTelegramId,
    required this.linkedTelegramUsername,
  });

  final bool ok;
  final bool alreadyClaimed;
  final int premiumDays;
  final int linkedTelegramId;
  final String linkedTelegramUsername;
}

class PortalStartTrialRequest {
  const PortalStartTrialRequest({
    required this.installId,
    required this.deviceName,
    required this.platform,
    required this.operatingSystemVersion,
    required this.appVersion,
    required this.localeTag,
    required this.timeZone,
  });

  final String installId;
  final String deviceName;
  final String platform;
  final String operatingSystemVersion;
  final String appVersion;
  final String localeTag;
  final String timeZone;

  Map<String, dynamic> toJson() {
    return {
      'install_id': installId,
      'device_name': deviceName,
      'platform': platform,
      'os_version': operatingSystemVersion,
      'app_version': appVersion,
      'locale': localeTag,
      'time_zone': timeZone,
    };
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.isActive,
    required this.currentPlanLabel,
    required this.statusHeadline,
    required this.statusBody,
    required this.expiresAt,
    required this.usedGb,
    required this.totalGb,
    required this.remainingGb,
    required this.activeSessions,
    required this.deviceLimit,
    required this.connectionKey,
    required this.healthyNodes,
    required this.totalNodes,
  });

  final bool isActive;
  final String currentPlanLabel;
  final String statusHeadline;
  final String statusBody;
  final DateTime? expiresAt;
  final double usedGb;
  final double totalGb;
  final double remainingGb;
  final int activeSessions;
  final int deviceLimit;
  final String connectionKey;
  final int healthyNodes;
  final int totalNodes;

  String get connectionPointsLabel {
    if (totalNodes <= 0) return '--';
    return '$healthyNodes/$totalNodes';
  }
}

class PlanQuote {
  const PlanQuote({
    required this.code,
    required this.label,
    required this.amountRub,
    required this.amountStars,
    required this.days,
    required this.deviceLimit,
    required this.nodePolicy,
    required this.badge,
  });

  final String code;
  final String label;
  final int amountRub;
  final int amountStars;
  final int days;
  final int deviceLimit;
  final String nodePolicy;
  final String badge;
}

class SubscriptionState {
  const SubscriptionState({
    required this.currentPlanCode,
    required this.currentPlanLabel,
    required this.isTrialLike,
    required this.checkoutEnabled,
    required this.checkoutUrl,
    required this.payViaBotUrl,
    required this.plans,
  });

  final String currentPlanCode;
  final String currentPlanLabel;
  final bool isTrialLike;
  final bool checkoutEnabled;
  final String checkoutUrl;
  final String payViaBotUrl;
  final List<PlanQuote> plans;
}

class CheckoutSession {
  const CheckoutSession({
    required this.planCode,
    required this.amountRub,
    required this.paymentUrl,
    required this.provider,
    required this.status,
  });

  final String planCode;
  final int amountRub;
  final String paymentUrl;
  final String provider;
  final String status;
}

class DeviceRecord {
  const DeviceRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.platform,
    required this.isActive,
  });

  final String id;
  final String title;
  final String subtitle;
  final String platform;
  final bool isActive;
}

class LocationRecord {
  const LocationRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.regionLabel,
    required this.isActive,
  });

  final String id;
  final String title;
  final String subtitle;
  final String regionLabel;
  final bool isActive;
}

class UsageStats {
  const UsageStats({
    required this.usedGb,
    required this.totalGb,
    required this.remainingGb,
    required this.activeSessions,
    required this.deviceLimit,
    required this.healthyNodes,
    required this.totalNodes,
  });

  final double usedGb;
  final double totalGb;
  final double remainingGb;
  final int activeSessions;
  final int deviceLimit;
  final int healthyNodes;
  final int totalNodes;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.body,
    required this.senderRole,
    required this.createdAt,
  });

  final int id;
  final String body;
  final String senderRole;
  final DateTime? createdAt;
}

class SupportThread {
  const SupportThread({
    required this.id,
    required this.subject,
    required this.status,
    required this.messages,
  });

  final int id;
  final String subject;
  final String status;
  final List<SupportMessage> messages;
}

class DownloadTarget {
  const DownloadTarget({
    required this.platformLabel,
    required this.primaryUrl,
    required this.mirrorUrl,
    required this.docsUrl,
  });

  final String platformLabel;
  final String primaryUrl;
  final String mirrorUrl;
  final String docsUrl;
}

class PortalManagedManifest {
  const PortalManagedManifest({
    this.url = '',
    this.transportKind = '',
    this.engineHint = '',
    this.profileRevision = '',
  });

  final String url;
  final String transportKind;
  final String engineHint;
  final String profileRevision;

  bool get isConfigured => url.trim().isNotEmpty;
}

class PortalManagedProfile {
  const PortalManagedProfile({
    this.version = '',
    this.profileRevision = '',
    this.transportProfile = '',
    this.transportKind = '',
    this.engineHint = '',
    this.configFormat = '',
    this.configPayload,
    this.fallbackOrder = const [],
    this.supportContext = const PortalConnectionSupportContext(),
    this.subscriptionUrl = '',
    this.smartConnect = const {},
  });

  final String version;
  final String profileRevision;
  final String transportProfile;
  final String transportKind;
  final String engineHint;
  final String configFormat;
  final Object? configPayload;
  final List<String> fallbackOrder;
  final PortalConnectionSupportContext supportContext;
  final String subscriptionUrl;
  final Map<String, dynamic> smartConnect;

  factory PortalManagedProfile.fromJson(Map<String, dynamic> json) {
    return PortalManagedProfile(
      version: _readString(json['version']),
      profileRevision: _readString(json['profile_revision']),
      transportProfile: _readString(json['transport_profile']),
      transportKind: _readString(json['transport_kind']),
      engineHint: _readString(json['engine_hint']),
      configFormat: _readString(json['config_format']),
      configPayload: json['config_payload'],
      fallbackOrder: _readStringList(json['fallback_order']),
      supportContext: PortalConnectionSupportContext(
        transport: _readString(_readMap(json['support_context'])['transport']),
        routingMode:
            _readString(_readMap(json['support_context'])['routing_mode']),
        ipVersionPreference: _readString(
          _readMap(json['support_context'])['ip_version_preference'],
        ),
      ),
      subscriptionUrl: _readString(json['subscription_url']),
      smartConnect: _readMap(json['smart_connect']),
    );
  }

  String? importContent() {
    final payload = configPayload;
    if (payload == null) return null;
    if (payload is String) {
      final normalized = payload.trim();
      return normalized.isEmpty ? null : normalized;
    }
    if (payload is Map || payload is List) {
      return jsonEncode(payload);
    }
    final normalized = payload.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  bool get hasImportablePayload {
    final value = importContent();
    return value != null && value.trim().isNotEmpty;
  }
}

class PortalRoutePolicyInput {
  const PortalRoutePolicyInput({
    required this.mode,
    required this.selectedApps,
    this.requiresElevatedPrivileges,
  });

  final String mode;
  final List<String> selectedApps;
  final bool? requiresElevatedPrivileges;

  Map<String, dynamic> toJson() {
    return {
      'route_mode': mode,
      'selected_apps': selectedApps,
      if (requiresElevatedPrivileges != null)
        'requires_elevated_privileges': requiresElevatedPrivileges,
    };
  }
}

class PortalRoutePolicyState {
  const PortalRoutePolicyState({
    this.mode = '',
    this.selectedApps = const [],
    this.requiresElevatedPrivileges = false,
  });

  final String mode;
  final List<String> selectedApps;
  final bool requiresElevatedPrivileges;
}

class PortalConnectionSupportContext {
  const PortalConnectionSupportContext({
    this.transport = '',
    this.routingMode = '',
    this.ipVersionPreference = '',
  });

  final String transport;
  final String routingMode;
  final String ipVersionPreference;
}

class PortalConnectionPolicy {
  const PortalConnectionPolicy({
    this.routingModeDefault = '',
    this.transportProfile = '',
    this.transportKind = '',
    this.engineHint = '',
    this.profileRevision = '',
    this.dnsPolicy = '',
    this.packageCatalogVersion = '',
    this.rulesetVersion = '',
    this.routeModeDefault = '',
    this.routeModeChoices = const [],
    this.routeModeRequiresElevation,
    this.routePolicy = const PortalRoutePolicyState(),
    this.supportRecoveryOrder = const [],
    this.supportContext = const PortalConnectionSupportContext(),
  });

  final String routingModeDefault;
  final String transportProfile;
  final String transportKind;
  final String engineHint;
  final String profileRevision;
  final String dnsPolicy;
  final String packageCatalogVersion;
  final String rulesetVersion;
  final String routeModeDefault;
  final List<String> routeModeChoices;
  final bool? routeModeRequiresElevation;
  final PortalRoutePolicyState routePolicy;
  final List<String> supportRecoveryOrder;
  final PortalConnectionSupportContext supportContext;
}

class ImportPayload {
  const ImportPayload({
    required this.subscriptionUrl,
    required this.smartUrl,
    required this.plainUrl,
    required this.qrValue,
    this.managedManifest = const PortalManagedManifest(),
  });

  final String subscriptionUrl;
  final String smartUrl;
  final String plainUrl;
  final String qrValue;
  final PortalManagedManifest managedManifest;
}

class PortalExperience {
  const PortalExperience({
    required this.isDemo,
    required this.session,
    required this.dashboard,
    required this.subscription,
    required this.checkout,
    this.devices = const [],
    this.locations = const [],
    required this.usage,
    required this.supportThreads,
    required this.downloads,
    required this.importPayload,
    this.connectionPolicy = const PortalConnectionPolicy(),
  });

  final bool isDemo;
  final SessionSummary session;
  final DashboardSummary dashboard;
  final SubscriptionState subscription;
  final CheckoutSession? checkout;
  final List<DeviceRecord> devices;
  final List<LocationRecord> locations;
  final UsageStats usage;
  final List<SupportThread> supportThreads;
  final List<DownloadTarget> downloads;
  final ImportPayload importPayload;
  final PortalConnectionPolicy connectionPolicy;

  bool get hasProvisionedAccess =>
      session.isAuthorized || importPayload.subscriptionUrl.trim().isNotEmpty;

  PortalExperience copyWith({
    bool? isDemo,
    SessionSummary? session,
    DashboardSummary? dashboard,
    SubscriptionState? subscription,
    CheckoutSession? checkout,
    List<DeviceRecord>? devices,
    List<LocationRecord>? locations,
    UsageStats? usage,
    List<SupportThread>? supportThreads,
    List<DownloadTarget>? downloads,
    ImportPayload? importPayload,
    PortalConnectionPolicy? connectionPolicy,
  }) {
    return PortalExperience(
      isDemo: isDemo ?? this.isDemo,
      session: session ?? this.session,
      dashboard: dashboard ?? this.dashboard,
      subscription: subscription ?? this.subscription,
      checkout: checkout ?? this.checkout,
      devices: devices ?? this.devices,
      locations: locations ?? this.locations,
      usage: usage ?? this.usage,
      supportThreads: supportThreads ?? this.supportThreads,
      downloads: downloads ?? this.downloads,
      importPayload: importPayload ?? this.importPayload,
      connectionPolicy: connectionPolicy ?? this.connectionPolicy,
    );
  }

  factory PortalExperience.demo(PortalPublicConfig config) {
    const demoPlan = PlanQuote(
      code: '1_month',
      label: '1 Month',
      amountRub: 249,
      amountStars: 249,
      days: 30,
      deviceLimit: 5,
      nodePolicy: 'paid_pool',
      badge: 'Popular',
    );

    return PortalExperience(
      isDemo: true,
      session: const SessionSummary(
        tgId: 0,
        accountId: 'guest',
        deviceName: 'Current device',
        username: 'guest',
        isAuthorized: false,
      ),
      dashboard: const DashboardSummary(
        isActive: false,
        currentPlanLabel: 'Trial',
        statusHeadline: 'Your service hub is ready',
        statusBody:
            'Connect a profile, then unlock subscription, locations, devices, support and downloads without leaving the app.',
        expiresAt: null,
        usedGb: 0,
        totalGb: 30,
        remainingGb: 30,
        activeSessions: 0,
        deviceLimit: 1,
        connectionKey: '',
        healthyNodes: 0,
        totalNodes: 0,
      ),
      subscription: SubscriptionState(
        currentPlanCode: 'trial',
        currentPlanLabel: 'Trial',
        isTrialLike: true,
        checkoutEnabled: true,
        checkoutUrl: config.checkoutUrl,
        payViaBotUrl: config.botUrl,
        plans: const [
          demoPlan,
          PlanQuote(
            code: '12_months',
            label: '12 Months',
            amountRub: 1644,
            amountStars: 1644,
            days: 365,
            deviceLimit: 5,
            nodePolicy: 'paid_pool',
            badge: '-45%',
          ),
        ],
      ),
      checkout: CheckoutSession(
        planCode: demoPlan.code,
        amountRub: demoPlan.amountRub,
        paymentUrl: config.checkoutUrl,
        provider: 'portal',
        status: 'demo',
      ),
      devices: const [
        DeviceRecord(
          id: 'device-demo',
          title: 'Current device',
          subtitle: 'Available after activation',
          platform: 'Device',
          isActive: true,
        ),
      ],
      usage: const UsageStats(
        usedGb: 0,
        totalGb: 30,
        remainingGb: 30,
        activeSessions: 0,
        deviceLimit: 1,
        healthyNodes: 0,
        totalNodes: 0,
      ),
      supportThreads: const [
        SupportThread(
          id: 1,
          subject: 'Welcome to POKROV',
          status: 'demo',
          messages: [
            SupportMessage(
              id: 1,
              body:
                  'Support and account data will appear here after trial activation.',
              senderRole: 'system',
              createdAt: null,
            ),
          ],
        ),
      ],
      downloads: [
        DownloadTarget(
          platformLabel: 'Android',
          primaryUrl: config.androidApkUrl,
          mirrorUrl: config.androidMirrorUrl,
          docsUrl: config.docsUrl,
        ),
        DownloadTarget(
          platformLabel: 'Windows',
          primaryUrl: config.windowsExeUrl,
          mirrorUrl: config.windowsMirrorUrl,
          docsUrl: config.docsUrl,
        ),
      ],
      importPayload: const ImportPayload(
        subscriptionUrl: '',
        smartUrl: '',
        plainUrl: '',
        qrValue: '',
      ),
    );
  }
}

String _readString(Object? value, {String fallback = ''}) {
  final normalized = value == null ? fallback : value.toString().trim();
  return normalized.isEmpty ? fallback : normalized;
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => _readString(item))
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return const {};
}
