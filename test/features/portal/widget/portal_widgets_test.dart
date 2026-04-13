import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';

void main() {
  test('builds checkout url with selected plan', () {
    expect(
      buildPortalCheckoutUrl(
        'https://pay.pokrov.space/checkout',
        planCode: 'pro_30',
      ),
      equals('https://pay.pokrov.space/checkout?plan=pro_30'),
    );
  });

  test('preserves existing query params when building checkout url', () {
    expect(
      buildPortalCheckoutUrl(
        'https://pay.pokrov.space/checkout?source=app',
        planCode: 'pro_30',
      ),
      equals('https://pay.pokrov.space/checkout?source=app&plan=pro_30'),
    );
  });

  test('builds support email body with prepared account context', () {
    final uri = buildPortalSupportEmailUri(
      contactEmail: 'support@pokrov.space',
      accountId: 'acc_1',
      deviceName: 'Android phone',
      planCode: 'trial_5_days',
      appLabel: 'POKROV VPN',
    );

    expect(uri.toString(), contains('mailto:support@pokrov.space'));
    expect(
        uri.queryParameters['subject'], equals('POKROV VPN support request'));
    expect(
      uri.queryParameters['body'],
      contains('Account: acc_1'),
    );
    expect(
      uri.queryParameters['body'],
      contains('Device: Android phone'),
    );
    expect(
      uri.queryParameters['body'],
      contains('Plan: trial_5_days'),
    );
  });
}
