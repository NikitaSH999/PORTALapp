import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('top-level spine points at hiddify-core and keeps portal release defines', () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    final dependencies = await File('dependencies.properties').readAsString();
    final makefile = await File('Makefile').readAsString();
    final gitmodules = await File('.gitmodules').readAsString();
    final analysisOptions = await File('analysis_options.yaml').readAsString();

    expect(pubspec, contains('flutter: ^3.38.5'));
    expect(pubspec, contains('hiddify-core/bin/desktop.h'));
    expect(pubspec, isNot(contains('libcore/bin/libcore.h')));

    expect(dependencies, contains('core.version=4.1.0'));
    expect(dependencies, isNot(contains('core.version=3.1.8')));

    expect(makefile, contains('BINDIR=hiddify-core'));
    expect(makefile, contains('DESKTOP_OUT=hiddify-core'));
    expect(makefile, contains('make -C hiddify-core -f Makefile'));
    expect(makefile, isNot(contains('make -C libcore -f Makefile')));
    expect(makefile, contains('PORTAL_RELEASE_REPOSITORY_URL'));
    expect(makefile, contains('PORTAL_RELEASES_API_URL'));
    expect(makefile, contains('PORTAL_RELEASES_LATEST_URL'));
    expect(makefile, contains('PORTAL_RELEASES_APPCAST_URL'));
    expect(makefile, contains('PORTAL_WARP_DEFAULTS_URL'));

    expect(gitmodules, contains('[submodule "hiddify-core"]'));
    expect(gitmodules, contains('path = hiddify-core'));
    expect(gitmodules, contains('url = https://github.com/hiddify/hiddify-core'));
    expect(gitmodules, isNot(contains('ssh://git@github.com/hiddify/hiddify-core')));

    expect(analysisOptions, contains('"hiddify-core/**"'));
    expect(analysisOptions, isNot(contains('"libcore/**"')));
  });
}
