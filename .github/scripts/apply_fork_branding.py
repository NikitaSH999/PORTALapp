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


def _replace(text: str, pattern: str, repl: str, *, count: int = 1) -> str:
    result, n = re.subn(pattern, repl, text, count=count, flags=re.MULTILINE)
    if n == 0:
        raise RuntimeError(f"pattern not found: {pattern}")
    return result


def _set_yaml_scalar(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf"^(?P<prefix>\s*{re.escape(key)}:\s*).*$", flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f"{match.group('prefix')}{value}"

    out, n = pattern.subn(repl, text, count=1)
    if n == 0:
        raise RuntimeError(f"pattern not found: {key}:")
    return out


def _set_rc_value(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^(?P<prefix>\s*VALUE "{re.escape(key)}",\s*).*$', flags=re.MULTILINE)

    def repl(match: re.Match[str]) -> str:
        return f'{match.group("prefix")}"{value}" "\\0"'

    out, n = pattern.subn(repl, text, count=1)
    if n == 0:
        raise RuntimeError(f'pattern not found: VALUE "{key}",')
    return out


def _repo_urls(repo_url: str) -> tuple[str, str, str]:
    parsed = urlparse(repo_url)
    host = parsed.netloc.lower()
    path = parsed.path.strip("/")
    if host != "github.com" or "/" not in path:
        return (
            repo_url,
            "https://api.github.com/repos/hiddify/hiddify-next/releases",
            "https://raw.githubusercontent.com/hiddify/hiddify-next/main/appcast.xml",
        )
    owner, repo = path.split("/", 1)
    owner = owner.strip()
    repo = repo.strip()
    api = f"https://api.github.com/repos/{owner}/{repo}/releases"
    appcast = f"https://raw.githubusercontent.com/{owner}/{repo}/main/appcast.xml"
    return repo_url, api, appcast


def _patch_file(path: Path, fn) -> None:
    original = path.read_text(encoding="utf-8")
    updated = fn(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8", newline="\n")
        print(f"[updated] {path}")
    else:
        print(f"[unchanged] {path}")


def _rewrite_android_manifest(text: str, brand_name: str, uri_scheme: str) -> str:
    out = _replace(
        text,
        r'android:label="[^"]+"',
        f'android:label="{brand_name}"',
    )
    out = _replace(
        out,
        r'(<data android:scheme=")[^"]+(" />\s*[\r\n]+\s*<data android:host="install-sub" />)',
        rf"\g<1>{uri_scheme}\2",
    )
    out = _replace(
        out,
        r'(<data android:scheme=")[^"]+(" />\s*[\r\n]+\s*<data android:host="import" />)',
        rf"\g<1>{uri_scheme}\2",
    )
    return out


def main() -> int:
    app_root = Path(__file__).resolve().parents[2]

    brand_name = _read_env("FORK_BRAND_NAME", "PORTALapp")
    repo_url = _read_env("FORK_REPO_URL", "")
    if not repo_url:
        gh_repo = _read_env("GITHUB_REPOSITORY", "")
        repo_url = f"https://github.com/{gh_repo}" if gh_repo else "https://github.com/NikitaSH999/PORTALapp"

    android_app_id = _read_env("FORK_ANDROID_APPLICATION_ID", "com.kiwunaka.portalapp")
    android_namespace = _read_env("FORK_ANDROID_NAMESPACE", "com.hiddify.hiddify")
    android_test_namespace = _read_env(
        "FORK_ANDROID_TEST_NAMESPACE",
        f"test.{android_namespace}",
    )
    uri_scheme = _read_env("FORK_URI_SCHEME", "")

    windows_identity_name = _read_env("FORK_WINDOWS_IDENTITY_NAME", "Kiwunaka.PortalApp")
    windows_publisher_name = _read_env("FORK_WINDOWS_PUBLISHER_NAME", brand_name)
    windows_install_dir = _read_env("FORK_WINDOWS_INSTALL_DIR", _slugify(brand_name))
    exe_stem = _read_env("FORK_WINDOWS_EXE_STEM", _slugify(brand_name))
    if not uri_scheme:
        uri_scheme = _slugify(exe_stem).lower()
    exe_name = f"{exe_stem}.exe"
    copyright_line = _read_env(
        "FORK_COPYRIGHT",
        f"Copyright (C) {windows_publisher_name}. All rights reserved.",
    )

    repo_url, releases_api_url, appcast_url = _repo_urls(repo_url)
    latest_release_url = f"{repo_url.rstrip('/')}/releases/latest"
    internal_name = _slugify(exe_stem).lower()
    mutex_name = f"{_slugify(exe_stem)}Mutex"

    print("[branding]")
    print(f"  brand_name={brand_name}")
    print(f"  repo_url={repo_url}")
    print(f"  android_app_id={android_app_id}")
    print(f"  android_namespace={android_namespace}")
    print(f"  windows_identity_name={windows_identity_name}")
    print(f"  windows_exe={exe_name}")
    print(f"  uri_scheme={uri_scheme}")

    _patch_file(
        app_root / "lib/core/model/constants.dart",
        lambda t: _replace(
            _replace(
                _replace(
                    _replace(
                        _replace(t, r'static const appName = ".*?";', f'static const appName = "{brand_name}";'),
                        r'static const githubUrl = ".*?";',
                        f'static const githubUrl = "{repo_url}";',
                    ),
                    r'static const githubReleasesApiUrl =\s*"[^"]+";',
                    f'static const githubReleasesApiUrl =\n      "{releases_api_url}";',
                ),
                r'static const githubLatestReleaseUrl =\s*"[^"]+";',
                f'static const githubLatestReleaseUrl =\n      "{latest_release_url}";',
            ),
            r'static const appCastUrl =\s*"[^"]+";',
            f'static const appCastUrl =\n      "{appcast_url}";',
        ),
    )

    _patch_file(
        app_root / "android/app/build.gradle",
        lambda t: _replace(
            _replace(
                _replace(
                    t,
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
        lambda t: _rewrite_android_manifest(t, brand_name, uri_scheme),
    )

    _patch_file(
        app_root / "windows/CMakeLists.txt",
        lambda t: _replace(
            _replace(
                t,
                r"^project\([^)]+\)$",
                f"project({internal_name} LANGUAGES CXX)",
            ),
            r'set\(BINARY_NAME\s+"[^"]+"\)',
            f'set(BINARY_NAME "{exe_stem}")',
        ),
    )

    _patch_file(
        app_root / "windows/runner/main.cpp",
        lambda t: _replace(
            _replace(
                _replace(
                    _replace(
                        t,
                        r'CreateMutex\(NULL,\s*TRUE,\s*L"[^"]+"\)',
                        f'CreateMutex(NULL, TRUE, L"{mutex_name}")',
                    ),
                    r'FindWindowA\(NULL,\s*"[^"]+"\)',
                    f'FindWindowA(NULL, "{exe_stem}")',
                ),
                r'window\.SendAppLinkToInstance\(L"[^"]+"\)',
                f'window.SendAppLinkToInstance(L"{exe_stem}")',
            ),
            r'window\.Create\(L"[^"]+",\s*origin,\s*size\)',
            f'window.Create(L"{exe_stem}", origin, size)',
        ),
    )

    _patch_file(
        app_root / "windows/packaging/msix/make_config.yaml",
        lambda t: _set_yaml_scalar(
            _set_yaml_scalar(
                _set_yaml_scalar(
                    _set_yaml_scalar(
                        _set_yaml_scalar(
                            t,
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
                uri_scheme,
            ),
            "execution_alias",
            internal_name,
        ),
    )

    _patch_file(
        app_root / "windows/packaging/exe/make_config.yaml",
        lambda t: _set_yaml_scalar(
            _set_yaml_scalar(
                _set_yaml_scalar(
                    _set_yaml_scalar(
                        _set_yaml_scalar(
                            _set_yaml_scalar(
                                t,
                                "publisher",
                                windows_publisher_name,
                            ),
                            "publisher_url",
                            repo_url,
                        ),
                        "display_name",
                        brand_name,
                    ),
                    "executable_name",
                    exe_name,
                ),
                "output_base_file_name",
                exe_name,
            ),
            "install_dir_name",
            f'"{{autopf64}}\\\\{windows_install_dir}"',
        ),
    )

    _patch_file(
        app_root / "windows/runner/Runner.rc",
        lambda t: _set_rc_value(
            _set_rc_value(
                _set_rc_value(
                    _set_rc_value(
                        _set_rc_value(
                            _set_rc_value(
                                t,
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
            internal_name,
        ),
    )

    _patch_file(
        app_root / "windows/packaging/exe/inno_setup.sas",
        lambda t: _replace(
            t,
            r"Exec\('taskkill', '/F /IM [^']+'",
            f"Exec('taskkill', '/F /IM {internal_name}.exe'",
        ),
    )

    print("[done] branding overrides applied")
    return 0


if __name__ == "__main__":
    sys.exit(main())
