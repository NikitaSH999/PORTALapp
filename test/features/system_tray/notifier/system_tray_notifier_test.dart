import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/system_tray/notifier/system_tray_notifier.dart';

void main() {
  test('keeps tray actions focused on open, connect, support, and quit', () {
    final t = AppLocale.en.build();

    final entries = buildDesktopTrayMenuEntries(
      translations: t,
      connection: const Disconnected(),
    );

    expect(
      entries.map((entry) => entry.label),
      [
        'Open POKROV',
        t.tray.status.connect,
        'Support',
        t.tray.quit,
      ],
    );
    expect(
      entries.any((entry) => entry.label.contains('Proxy')),
      isFalse,
    );
    expect(
      entries.any((entry) => entry.label.contains('System')),
      isFalse,
    );
  });

  test('keeps the tray tooltip brand-first and free of latency details', () {
    final t = AppLocale.en.build();

    final tooltip = buildDesktopTrayTooltip(
      appName: 'POKROV',
      translations: t,
      connection: const Connected(),
      latencyMs: 42,
    );

    expect(tooltip, 'POKROV - ${const Connected().present(t)}');
    expect(tooltip.contains('ms'), isFalse);
  });
}
