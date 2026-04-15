import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/connection/data/connection_repository.dart';
import 'package:path/path.dart' as p;

void main() {
  test('creates the runtime data folders needed by the desktop core', () async {
    final root = await Directory(
      p.join(
        Directory.systemTemp.path,
        'pokrov-connection-runtime-test-${DateTime.now().microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);
    addTearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    final dirs = (
      baseDir: Directory(p.join(root.path, 'base')),
      workingDir: Directory(p.join(root.path, 'working')),
      tempDir: Directory(p.join(root.path, 'temp')),
    );

    await ensureConnectionRuntimeDirectories(dirs);

    expect(await dirs.baseDir.exists(), isTrue);
    expect(await dirs.workingDir.exists(), isTrue);
    expect(await dirs.tempDir.exists(), isTrue);
    expect(await Directory(p.join(dirs.baseDir.path, 'data')).exists(), isTrue);
    expect(
      await Directory(p.join(dirs.workingDir.path, 'data')).exists(),
      isTrue,
    );
    expect(
      await Directory(p.join(dirs.workingDir.path, 'configs')).exists(),
      isTrue,
    );
  });
}
