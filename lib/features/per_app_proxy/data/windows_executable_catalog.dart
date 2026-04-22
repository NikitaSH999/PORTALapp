import 'dart:io';

import 'package:hiddify/features/per_app_proxy/model/app_package_info.dart';
import 'package:path/path.dart' as p;

const _maxExecutableSuggestions = 120;
const _maxDirectoryDepth = 4;

const Map<String, String> _preferredExecutableNames = {
  'telegram.exe': 'Telegram',
  'discord.exe': 'Discord',
  'chrome.exe': 'Google Chrome',
  'msedge.exe': 'Microsoft Edge',
  'firefox.exe': 'Mozilla Firefox',
  'opera.exe': 'Opera',
  'browser.exe': 'Yandex Browser',
  'whatsapp.exe': 'WhatsApp',
  'slack.exe': 'Slack',
  'teams.exe': 'Microsoft Teams',
  'zoom.exe': 'Zoom',
  'code.exe': 'Visual Studio Code',
  'cursor.exe': 'Cursor',
  'steam.exe': 'Steam',
  'spotify.exe': 'Spotify',
  'obs64.exe': 'OBS Studio',
  'vlc.exe': 'VLC',
  'notepad++.exe': 'Notepad++',
  'postman.exe': 'Postman',
  'docker desktop.exe': 'Docker Desktop',
  'idea64.exe': 'IntelliJ IDEA',
  'pycharm64.exe': 'PyCharm',
  'webstorm64.exe': 'WebStorm',
  'clion64.exe': 'CLion',
  'rider64.exe': 'Rider',
  'android studio.exe': 'Android Studio',
  'signal.exe': 'Signal',
  'element.exe': 'Element',
  'skype.exe': 'Skype',
  'onedrive.exe': 'OneDrive',
};

const Set<String> _ignoredExecutableNames = {
  'uninstall.exe',
  'unins000.exe',
  'setup.exe',
  'update.exe',
  'updater.exe',
  'install.exe',
  'crashpad_handler.exe',
  'squirrel.exe',
  'notification_helper.exe',
  'pwahelper.exe',
  'elevate.exe',
  'helper.exe',
};

const Set<String> _genericDirectoryNames = {
  'current',
  'app',
  'application',
  'bin',
  'program',
  'programs',
};

Future<List<AppPackageInfo>> discoverWindowsExecutables() async {
  final suggestions = <String, _ScoredExecutable>{};

  for (final root in _candidateRoots()) {
    if (suggestions.length >= _maxExecutableSuggestions) {
      break;
    }
    await _scanDirectory(
      root,
      depth: 0,
      suggestions: suggestions,
    );
  }

  final sorted = suggestions.values.toList(growable: false)
    ..sort((left, right) {
      final scoreOrder = right.score.compareTo(left.score);
      if (scoreOrder != 0) return scoreOrder;
      return left.info.name.toLowerCase().compareTo(right.info.name.toLowerCase());
    });

  return [
    for (final item in sorted.take(_maxExecutableSuggestions)) item.info,
  ];
}

List<Directory> _candidateRoots() {
  final env = Platform.environment;
  final roots = <String>{
    if (env['LOCALAPPDATA'] case final localAppData? when localAppData.isNotEmpty)
      p.join(localAppData, 'Programs'),
    if (env['LOCALAPPDATA'] case final localAppData? when localAppData.isNotEmpty)
      localAppData,
    if (env['PROGRAMFILES'] case final programFiles? when programFiles.isNotEmpty)
      programFiles,
    if (env['PROGRAMFILES(X86)'] case final programFilesX86? when programFilesX86.isNotEmpty)
      programFilesX86,
    if (env['ProgramW6432'] case final programW6432? when programW6432.isNotEmpty)
      programW6432,
  };

  return [
    for (final root in roots)
      if (root.isNotEmpty && Directory(root).existsSync()) Directory(root),
  ];
}

Future<void> _scanDirectory(
  Directory directory, {
  required int depth,
  required Map<String, _ScoredExecutable> suggestions,
}) async {
  if (depth > _maxDirectoryDepth || suggestions.length >= _maxExecutableSuggestions) {
    return;
  }

  List<FileSystemEntity> entities;
  try {
    entities = await directory.list(followLinks: false).toList();
  } on FileSystemException {
    return;
  }

  for (final entity in entities) {
    if (suggestions.length >= _maxExecutableSuggestions) {
      return;
    }

    if (entity is File) {
      final suggestion = _buildSuggestion(entity.path, depth: depth);
      if (suggestion == null) continue;
      suggestions.putIfAbsent(
        suggestion.info.packageName.toLowerCase(),
        () => suggestion,
      );
      continue;
    }

    if (entity is! Directory) continue;
    if (_shouldSkipDirectory(entity.path, depth: depth)) continue;

    await _scanDirectory(
      entity,
      depth: depth + 1,
      suggestions: suggestions,
    );
  }
}

bool _shouldSkipDirectory(String path, {required int depth}) {
  final normalizedPath = path.toLowerCase();
  final name = p.basename(normalizedPath);

  if (name.startsWith('.')) return true;
  if (normalizedPath.contains(r'\windowsapps')) return true;
  if (normalizedPath.contains(r'\microsoft\edgeupdate')) return true;
  if (normalizedPath.contains(r'\windows kits')) return true;
  if (normalizedPath.contains(r'\microsoft visual studio')) return depth > 2;
  if (normalizedPath.contains(r'\common files')) return true;
  if (normalizedPath.contains(r'\package cache')) return true;

  return false;
}

_ScoredExecutable? _buildSuggestion(
  String executablePath, {
  required int depth,
}) {
  final filename = p.basename(executablePath).toLowerCase();
  if (!filename.endsWith('.exe')) return null;
  if (_ignoredExecutableNames.contains(filename)) return null;

  final normalizedPath = p.normalize(executablePath);
  final lowerPath = normalizedPath.toLowerCase();
  if (lowerPath.contains(r'\uninstall') || lowerPath.contains(r'\installer')) {
    return null;
  }

  final score = _scoreExecutable(
    fileName: filename,
    fullPath: lowerPath,
    depth: depth,
  );
  if (score <= 0) return null;

  return _ScoredExecutable(
    score: score,
    info: AppPackageInfo(
      packageName: normalizedPath,
      name: _displayNameForExecutable(filename, normalizedPath),
      icon: null,
    ),
  );
}

int _scoreExecutable({
  required String fileName,
  required String fullPath,
  required int depth,
}) {
  var score = 20 - depth * 2;

  if (_preferredExecutableNames.containsKey(fileName)) {
    score += 120;
  }

  if (fullPath.contains(r'\program files')) {
    score += 24;
  }
  if (fullPath.contains(r'\appdata\local\programs')) {
    score += 20;
  }
  if (fullPath.contains(r'\desktop')) {
    score -= 10;
  }
  if (fullPath.contains(r'\temp')) {
    score -= 20;
  }
  if (fullPath.contains(r'\crash') || fullPath.contains(r'\helper')) {
    score -= 16;
  }

  return score;
}

String _displayNameForExecutable(String fileName, String executablePath) {
  final preferred = _preferredExecutableNames[fileName];
  if (preferred != null) return preferred;

  final basename = p.basenameWithoutExtension(executablePath);
  if (!_genericDirectoryNames.contains(basename.toLowerCase())) {
    return _titleCase(basename);
  }

  final parentName = p.basename(p.dirname(executablePath));
  if (parentName.isNotEmpty && !_genericDirectoryNames.contains(parentName.toLowerCase())) {
    return _titleCase(parentName);
  }

  return _titleCase(basename);
}

String _titleCase(String value) {
  final cleaned = value
      .replaceAll(RegExp('[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.isEmpty) return value;

  return cleaned
      .split(' ')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class _ScoredExecutable {
  const _ScoredExecutable({
    required this.score,
    required this.info,
  });

  final int score;
  final AppPackageInfo info;
}
