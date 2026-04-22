import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/optional_range.dart';
import 'package:hiddify/features/log/model/log_level.dart';
import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/singbox/model/singbox_config_option.dart';
import 'package:hiddify/singbox/model/singbox_rule.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('consumer routing defaults', () {
    test('defaults to all-except-RU routing with split DNS semantics',
        () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => preferences),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sharedPreferencesProvider.future);

      final config = container.read(ConfigOptions.singboxConfigOptions);

      expect(
          container.read(ConfigOptions.routingMode), RoutingMode.allExceptRu);
      expect(config.remoteDnsAddress, 'https://1.1.1.1/dns-query');
      expect(config.directDnsAddress, 'local');
      expect(config.enableClashApi, isFalse);
      expect(config.allowConnectionFromLan, isFalse);
      expect(
        buildRoutingRules(
          routingMode: RoutingMode.allExceptRu,
          region: null,
        ),
        const <SingboxRule>[
          SingboxRule(ip: 'geoip:private', outbound: RuleOutbound.bypass),
          SingboxRule(
            domains: 'domain:.ru',
            ip: 'geoip:ru',
            outbound: RuleOutbound.bypass,
          ),
          SingboxRule(
            domains: 'domain:.рф',
            outbound: RuleOutbound.bypass,
          ),
          SingboxRule(
            domains: 'domain:.su',
            outbound: RuleOutbound.bypass,
          ),
        ],
      );
    });

    test('keeps blocked-only internal and uses consumer-facing labels',
        () async {
      expect(
        consumerRoutingChoices(selected: RoutingMode.blockedOnly),
        equals(const [RoutingMode.allExceptRu, RoutingMode.global]),
      );

      final t = await AppLocale.en.build();
      expect(presentConsumerRoutingMode(RoutingMode.global, t), 'Full tunnel');
      expect(
        presentConsumerRoutingMode(RoutingMode.blockedOnly, t),
        'All except RU',
      );
    });

    test('applies release local-surface lockdown for Android builds', () {
      final config = SingboxConfigOption(
        region: 'other',
        balancerStrategy: BalancerStrategy.roundRobin,
        blockAds: false,
        useXrayCoreWhenPossible: false,
        executeConfigAsIs: false,
        logLevel: LogLevel.warn,
        resolveDestination: false,
        ipv6Mode: IPv6Mode.disable,
        remoteDnsAddress: 'https://1.1.1.1/dns-query',
        remoteDnsDomainStrategy: DomainStrategy.auto,
        directDnsAddress: 'local',
        directDnsDomainStrategy: DomainStrategy.auto,
        mixedPort: 12334,
        tproxyPort: 12335,
        directPort: 12337,
        redirectPort: 12336,
        tunImplementation: TunImplementation.gvisor,
        mtu: 9000,
        strictRoute: true,
        connectionTestUrl: 'http://cp.cloudflare.com',
        urlTestInterval: const Duration(minutes: 10),
        enableClashApi: true,
        clashApiPort: 16756,
        enableTun: true,
        setSystemProxy: false,
        bypassLan: false,
        allowConnectionFromLan: true,
        enableFakeDns: false,
        independentDnsCache: true,
        rules: const <SingboxRule>[],
        tlsTricks: const SingboxTlsTricks(
          enableFragment: false,
          fragmentSize: OptionalRange(min: 10, max: 30),
          fragmentSleep: OptionalRange(min: 2, max: 8),
          mixedSniCase: false,
          enablePadding: false,
          paddingSize: OptionalRange(min: 1, max: 1500),
        ),
        warp: const SingboxWarpOption(
          enable: false,
          mode: WarpDetourMode.warpOverProxy,
          wireguardConfig: '',
          licenseKey: '',
          accountId: '',
          accessToken: '',
          cleanIp: 'auto',
          cleanPort: 0,
          noise: OptionalRange(min: 1, max: 3),
          noiseSize: OptionalRange(min: 10, max: 30),
          noiseDelay: OptionalRange(min: 10, max: 30),
          noiseMode: 'm4',
        ),
        warp2: const SingboxWarpOption(
          enable: false,
          mode: WarpDetourMode.warpOverProxy,
          wireguardConfig: '',
          licenseKey: '',
          accountId: '',
          accessToken: '',
          cleanIp: 'auto',
          cleanPort: 0,
          noise: OptionalRange(min: 1, max: 3),
          noiseSize: OptionalRange(min: 10, max: 30),
          noiseDelay: OptionalRange(min: 10, max: 30),
          noiseMode: 'm4',
        ),
      );

      final locked = applyReleaseLocalSurfacePolicy(
        config,
        isAndroid: true,
        isReleaseMode: true,
      );

      expect(locked.enableClashApi, isFalse);
      expect(locked.allowConnectionFromLan, isFalse);
      expect(locked.mixedPort, 0);
      expect(locked.tproxyPort, 0);
      expect(locked.redirectPort, 0);
      expect(locked.directPort, 0);
    });
  });
}
