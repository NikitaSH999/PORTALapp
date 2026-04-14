import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/settings/data/route_mode_preferences.dart';

void main() {
  test('normalizes route targets for Windows executable entries', () {
    expect(
      normalizeRouteTargets(
        [
          r'  C:\Program Files\Telegram Desktop\Telegram.exe  ',
          r'c:\program files\telegram desktop\telegram.exe',
          '',
          '   ',
          r'C:\Program Files\Spotify\Spotify.exe',
        ],
        caseInsensitive: true,
      ),
      [
        r'C:\Program Files\Telegram Desktop\Telegram.exe',
        r'C:\Program Files\Spotify\Spotify.exe',
      ],
    );
  });
}
