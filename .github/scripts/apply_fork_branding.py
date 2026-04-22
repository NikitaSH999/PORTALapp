#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse


def _read_env(name: str, default: str = "") -> str:
    return (os.getenv(name) or default).strip()


def _slugify(value: str) -> str:
    out = re.sub(r"[^a-zA-Z0-9]+", "", value)
    return out or "PortalApp"


def _default_windows_exe_stem(brand_name: str) -> str:
    return _slugify(brand_name).upper()


def _windows_protocol_activation(uri_scheme: str) -> str:
    return ", ".join([uri_scheme, "pokrovvpn"])


def _replace(text: str, pattern: str, repl: str, *, count: int = 1) -> str:
    updated, applied = re.subn(pattern, repl, text, count=count, flags=re.MULTILINE)
    if applied == 0:
        raise RuntimeError(f"pattern not found: {pattern}")
    return updated


def _set_yaml_scalar(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf"^(?P<prefix>\s*{re.escape(key)}:\s*).*$", flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f"{match.group('prefix')}{value}"

    updated, applied = pattern.subn(repl, text, count=1)
    if applied == 0:
        raise RuntimeError(f"pattern not found: {key}:")
    return updated


def _set_or_append_yaml_scalar(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf"^(?P<prefix>\s*{re.escape(key)}:\s*).*$", flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f"{match.group('prefix')}{value}"

    updated, applied = pattern.subn(repl, text, count=1)
    if applied:
        return updated
    suffix = "" if text.endswith("\n") else "\n"
    return f"{text}{suffix}{key}: {value}\n"


def _set_rc_value(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^(?P<prefix>\s*VALUE "{re.escape(key)}",\s*).*$', flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f'{match.group("prefix")}"{value}" "\\0"'

    updated, applied = pattern.subn(repl, text, count=1)
    if applied == 0:
        raise RuntimeError(f'pattern not found: VALUE "{key}",')
    return updated


def _repo_urls(repo_url: str) -> tuple[str, str, str]:
    parsed = urlparse(repo_url)
    host = parsed.netloc.lower()
    path = parsed.path.strip("/")
    if host != "github.com" or "/" not in path:
        base = repo_url.rstrip("/")
        return (
            repo_url,
            f"{base}/releases",
            f"{base}/releases/latest/download/appcast.xml",
        )
    owner, repo = path.split("/", 1)
    api = f"https://api.github.com/repos/{owner}/{repo}/releases"
    appcast = f"https://github.com/{owner}/{repo}/releases/latest/download/appcast.xml"
    return repo_url, api, appcast


def _rewrite_constants(
    text: str,
    *,
    brand_name: str,
    repo_url: str,
    releases_api_url: str,
    latest_release_url: str,
    appcast_url: str,
    telegram_channel_url: str,
    privacy_policy_url: str,
    terms_url: str,
) -> str:
    replacements = {
        "appName": brand_name,
        "githubUrl": repo_url,
        "licenseUrl": f"{repo_url}?tab=License-1-ov-file#readme",
        "githubReleasesApiUrl": releases_api_url,
        "githubLatestReleaseUrl": latest_release_url,
        "appCastUrl": appcast_url,
        "telegramChannelUrl": telegram_channel_url,
        "privacyPolicyUrl": privacy_policy_url,
        "termsAndConditionsUrl": terms_url,
    }
    updated = text
    for key, value in replacements.items():
        updated = _replace(
            updated,
            rf'static const {re.escape(key)} = ".*?";',
            f'static const {key} = "{value}";',
        )
    return updated


def _insert_android_schemes(text: str, schemes: list[str]) -> str:
    marker = '<data android:scheme="'
    if marker not in text:
        raise RuntimeError("android deep-link scheme block not found")
    first_index = text.index(marker)
    indent_match = re.search(r"(?m)^(\s*)<data android:scheme=", text[first_index:])
    indent = indent_match.group(1) if indent_match else "                "
    additions = []
    for scheme in schemes:
        needle = f'<data android:scheme="{scheme}" />'
        if needle not in text:
            additions.append(f"{indent}{needle}")
    if not additions:
        return text
    return f"{text[:first_index]}{'\n'.join(additions)}\n{text[first_index:]}"


def _rewrite_android_manifest(text: str, brand_name: str, uri_scheme: str) -> str:
    updated = _replace(
        text,
        r'android:label="[^"]+"',
        f'android:label="{brand_name}"',
    )
    return _insert_android_schemes(updated, [uri_scheme, "pokrovvpn"])


def _rewrite_windows_exe_config(
    text: str,
    *,
    publisher_name: str,
    publisher_url: str,
    display_name: str,
    exe_name: str,
    output_base_file_name: str,
    install_dir_name: str,
) -> str:
    updated = _set_yaml_scalar(text, "publisher", publisher_name)
    updated = _set_yaml_scalar(updated, "publisher_url", publisher_url)
    updated = _set_yaml_scalar(updated, "display_name", display_name)
    updated = _set_yaml_scalar(updated, "install_dir_name", install_dir_name)
    updated = _set_or_append_yaml_scalar(updated, "executable_name", exe_name)
    updated = _set_or_append_yaml_scalar(updated, "output_base_file_name", output_base_file_name)
    return updated


def _patch_file(path: Path, transform) -> None:
    original = path.read_text(encoding="utf-8")
    updated = transform(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8", newline="\n")
        print(f"[updated] {path}")
    else:
        print(f"[unchanged] {path}")


def main() -> int:
    app_root = Path(__file__).resolve().parents[2]

    brand_name = _read_env("FORK_BRAND_NAME", "POKROV")
    repo_url = _read_env("FORK_REPO_URL")
    if not repo_url:
        gh_repo = _read_env("GITHUB_REPOSITORY")
        if not gh_repo:
            raise RuntimeError("FORK_REPO_URL or GITHUB_REPOSITORY must be set")
        repo_url = f"https://github.com/{gh_repo}"

    android_app_id = _read_env("FORK_ANDROID_APPLICATION_ID", "space.pokrov.vpn")
    android_namespace = _read_env("FORK_ANDROID_NAMESPACE", "com.hiddify.hiddify")
    android_test_namespace = _read_env("FORK_ANDROID_TEST_NAMESPACE", "test.com.hiddify.hiddify")
    uri_scheme = _read_env("FORK_URI_SCHEME", "pokrov")

    windows_identity_name = _read_env("FORK_WINDOWS_IDENTITY_NAME", "Pokrov.Vpn")
    windows_publisher_name = _read_env("FORK_WINDOWS_PUBLISHER_NAME", brand_name)
    windows_publisher_url = _read_env("FORK_WINDOWS_PUBLISHER_URL", "https://pokrov.space/")
    windows_install_dir = _read_env("FORK_WINDOWS_INSTALL_DIR", brand_name)
    exe_stem = _read_env("FORK_WINDOWS_EXE_STEM", _default_windows_exe_stem(brand_name))
    windows_output_base_file_name = _read_env(
        "FORK_WINDOWS_OUTPUT_BASE_FILE_NAME",
        "pokrov-windows-setup-x64",
    )
    copyright_line = _read_env(
        "FORK_COPYRIGHT",
        f"Copyright (C) {windows_publisher_name}. All rights reserved.",
    )
    telegram_channel_url = _read_env("FORK_TELEGRAM_CHANNEL_URL", "https://t.me/pokrov_vpn")
    privacy_policy_url = _read_env("FORK_PRIVACY_POLICY_URL", "https://pokrov.space/privacy-policy/")
    terms_url = _read_env("FORK_TERMS_URL", "https://pokrov.space/terms/")

    repo_url, releases_api_url, appcast_url = _repo_urls(repo_url)
    latest_release_url = f"{repo_url.rstrip('/')}/releases/latest"
    exe_name = f"{exe_stem}.exe"
    internal_name = _slugify(exe_stem).lower()
    mutex_name = f"{_slugify(exe_stem)}Mutex"
    protocol_activation = _windows_protocol_activation(uri_scheme)

    _patch_file(
        app_root / "lib/core/model/constants.dart",
        lambda text: _rewrite_constants(
            text,
            brand_name=brand_name,
            repo_url=repo_url,
            releases_api_url=releases_api_url,
            latest_release_url=latest_release_url,
            appcast_url=appcast_url,
            telegram_channel_url=telegram_channel_url,
            privacy_policy_url=privacy_policy_url,
            terms_url=terms_url,
        ),
    )
    _patch_file(
        app_root / "android/app/build.gradle",
        lambda text: _replace(
            _replace(
                _replace(
                    text,
                    r"namespace\s+'[^']+'",
                    f"namespace '{android_namespace}'",
                ),
                r'testNamespace\s+"[^"]+"',
                f'testNamespace "{android_test_namespace}"',
            ),
            r'applicationId\s+"[^"]+"',
            f'applicationId "{android_app_id}"',
        ),
    )
    _patch_file(
        app_root / "android/app/src/main/AndroidManifest.xml",
        lambda text: _rewrite_android_manifest(text, brand_name, uri_scheme),
    )
    _patch_file(
        app_root / "windows/CMakeLists.txt",
        lambda text: _replace(
            _replace(
                text,
                r"^project\([^)]+\)$",
                f"project({internal_name} LANGUAGES CXX)",
            ),
            r'set\(BINARY_NAME\s+"[^"]+"\)',
            f'set(BINARY_NAME "{exe_stem}")',
        ),
    )
    _patch_file(
        app_root / "windows/runner/main.cpp",
        lambda text: _replace(
            _replace(
                _replace(
                    _replace(
                        text,
                        r'CreateMutex\(NULL,\s*TRUE,\s*L"[^"]+"\)',
                        f'CreateMutex(NULL, TRUE, L"{mutex_name}")',
                    ),
                    r'FindWindowA\(NULL,\s*"[^"]+"\)',
                    f'FindWindowA(NULL, "{brand_name}")',
                ),
                r'window\.SendAppLinkToInstance\(L"[^"]+"\)',
                f'window.SendAppLinkToInstance(L"{brand_name}")',
            ),
            r'window\.Create\(L"[^"]+",\s*origin,\s*size\)',
            f'window.Create(L"{brand_name}", origin, size)',
        ),
    )
    _patch_file(
        app_root / "windows/packaging/msix/make_config.yaml",
        lambda text: _set_yaml_scalar(
            _set_yaml_scalar(
                _set_yaml_scalar(
                    _set_yaml_scalar(
                        _set_yaml_scalar(
                            text,
                            "display_name",
                            brand_name,
                        ),
                        "publisher_display_name",
                        windows_publisher_name,
                    ),
                    "identity_name",
                    windows_identity_name,
                ),
                "protocol_activation",
                protocol_activation,
            ),
            "execution_alias",
            internal_name,
        ),
    )
    _patch_file(
        app_root / "windows/packaging/exe/make_config.yaml",
        lambda text: _rewrite_windows_exe_config(
            text,
            publisher_name=windows_publisher_name,
            publisher_url=windows_publisher_url,
            display_name=brand_name,
            exe_name=exe_name,
            output_base_file_name=windows_output_base_file_name,
            install_dir_name=f'"{{autopf64}}\\\\{windows_install_dir}"',
        ),
    )
    _patch_file(
        app_root / "windows/runner/Runner.rc",
        lambda text: _set_rc_value(
            _set_rc_value(
                _set_rc_value(
                    _set_rc_value(
                        _set_rc_value(
                            _set_rc_value(
                                text,
                                "CompanyName",
                                windows_publisher_name,
                            ),
                            "FileDescription",
                            brand_name,
                        ),
                        "InternalName",
                        internal_name,
                    ),
                    "LegalCopyright",
                    copyright_line,
                ),
                "OriginalFilename",
                exe_name,
            ),
            "ProductName",
            brand_name,
        ),
    )
    _patch_file(
        app_root / "windows/packaging/exe/inno_setup.sas",
        lambda text: _replace(
            text,
            r"Exec\('taskkill', '/F /IM [^']+'",
            f"Exec('taskkill', '/F /IM {exe_name}'",
        ),
    )
    print("[done] fork branding overrides applied")
    return 0


if __name__ == "__main__":
    sys.exit(main())
