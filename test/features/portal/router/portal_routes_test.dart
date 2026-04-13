import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/router/routes.dart';

void main() {
  test('portal routes use canonical names and preserve legacy aliases', () {
    expect(const HomeRoute().location, equals('/'));
    expect(const SubscriptionRoute().location, equals('/subscription'));
    expect(const LocationsRoute().location, equals('/locations'));
    expect(const DevicesRoute().location, equals('/devices'));
    expect(const DevicesRoute(section: 'warp').location,
        equals('/devices?section=warp'));
    expect(const SupportRoute().location, equals('/support'));
    expect(const ProfileRoute().location, equals('/profile'));

    expect(const ProxiesRoute().location, equals('/locations'));
    expect(const ConfigOptionsRoute(section: 'warp').location,
        equals('/devices?section=warp'));
    expect(const LogsOverviewRoute().location, equals('/support'));
    expect(const AboutRoute().location, equals('/profile'));
  });
}
