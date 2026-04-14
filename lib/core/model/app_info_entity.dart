import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/model/environment.dart';

part 'app_info_entity.freezed.dart';

@freezed
class AppInfoEntity with _$AppInfoEntity {
  const AppInfoEntity._();

  const factory AppInfoEntity({
    required String name,
    required String version,
    required String buildNumber,
    required Release release,
    required String operatingSystem,
    required String operatingSystemVersion,
    required Environment environment,
  }) = _AppInfoEntity;

  String get userAgent =>
      "POKROVVPN/$version ($operatingSystem; ${release.key})";

  String get presentVersion {
    final normalizedVersion = version.trim();
    if (normalizedVersion.isEmpty) return '';

    final publicSemver = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(
      normalizedVersion,
    );
    if (publicSemver != null) {
      return '${publicSemver.group(1)}-beta';
    }

    if (normalizedVersion.contains('-beta')) {
      return normalizedVersion.split('+').first;
    }

    return environment == Environment.prod
        ? normalizedVersion
        : "$normalizedVersion ${environment.name}";
  }

  /// formats app info for sharing
  String format() => '''
$name v$presentVersion ($buildNumber) [${environment.name}]
${release.name} release
$operatingSystem [$operatingSystemVersion]''';
}
