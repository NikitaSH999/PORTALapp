import 'package:hiddify/singbox/model/singbox_config_option.dart';

enum ClientPlatform {
  android,
  windows,
}

enum ClientBuildMode {
  debug,
  release,
}

enum LocalSurfaceFinding {
  clashApiEnabled,
  lanAccessEnabled,
  mixedPortEnabled,
  tproxyPortEnabled,
  localDnsPortEnabled,
  nativeCommandServerUnverified,
}

class ClientLocalSurfaceReleaseGateResult {
  const ClientLocalSurfaceReleaseGateResult(this.findings);

  final List<LocalSurfaceFinding> findings;

  bool get isBlocked => findings.isNotEmpty;
}

abstract class ClientLocalSurfaceReleaseGate {
  static ClientLocalSurfaceReleaseGateResult evaluate({
    required SingboxConfigOption config,
    required ClientPlatform platform,
    required ClientBuildMode buildMode,
    required bool nativeCommandServerAuditPassed,
  }) {
    if (buildMode != ClientBuildMode.release) {
      return const ClientLocalSurfaceReleaseGateResult([]);
    }

    final findings = <LocalSurfaceFinding>[];
    if (config.enableClashApi) {
      findings.add(LocalSurfaceFinding.clashApiEnabled);
    }
    if (config.allowConnectionFromLan) {
      findings.add(LocalSurfaceFinding.lanAccessEnabled);
    }
    if (config.mixedPort > 0) {
      findings.add(LocalSurfaceFinding.mixedPortEnabled);
    }
    if (config.tproxyPort > 0) {
      findings.add(LocalSurfaceFinding.tproxyPortEnabled);
    }
    if (config.localDnsPort > 0) {
      findings.add(LocalSurfaceFinding.localDnsPortEnabled);
    }
    if (platform == ClientPlatform.android && !nativeCommandServerAuditPassed) {
      findings.add(LocalSurfaceFinding.nativeCommandServerUnverified);
    }

    return ClientLocalSurfaceReleaseGateResult(findings);
  }
}
