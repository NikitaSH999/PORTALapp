from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path


def _load_module():
    module_path = Path(__file__).resolve().parents[1] / "apply_fork_branding.py"
    spec = importlib.util.spec_from_file_location("apply_fork_branding", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load module from {module_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ApplyForkBrandingTests(unittest.TestCase):
    def test_default_windows_exe_stem_uses_public_pokrov_name(self) -> None:
        module = _load_module()

        self.assertEqual(module._default_windows_exe_stem("POKROV"), "POKROV")

    def test_windows_protocol_activation_keeps_only_public_and_compatibility_schemes(self) -> None:
        module = _load_module()

        self.assertEqual(
            module._windows_protocol_activation("pokrov"),
            "pokrov, pokrovvpn",
        )

    def test_rewrites_upstream_constants_urls_and_brand(self) -> None:
        module = _load_module()
        source = """
abstract class Constants {
  static const appName = "Hiddify";
  static const githubUrl = "https://github.com/hiddify/hiddify-next";
  static const licenseUrl = "https://github.com/hiddify/hiddify-next?tab=License-1-ov-file#readme";
  static const githubReleasesApiUrl = "https://api.github.com/repos/hiddify/hiddify-next/releases";
  static const githubLatestReleaseUrl = "https://github.com/hiddify/hiddify-app/releases/latest";
  static const appCastUrl = "https://raw.githubusercontent.com/hiddify/hiddify-next/main/appcast.xml";
  static const telegramChannelUrl = "https://t.me/hiddify";
  static const privacyPolicyUrl = "https://hiddify.com/privacy-policy/";
  static const termsAndConditionsUrl = "https://hiddify.com/terms/";
}
""".strip()

        rewritten = module._rewrite_constants(
            source,
            brand_name="POKROV",
            repo_url="https://github.com/example/pokrov-app",
            releases_api_url="https://api.github.com/repos/example/pokrov-app/releases",
            latest_release_url="https://github.com/example/pokrov-app/releases/latest",
            appcast_url="https://github.com/example/pokrov-app/releases/latest/download/appcast.xml",
            telegram_channel_url="https://t.me/pokrov_vpn",
            privacy_policy_url="https://pokrov.space/privacy-policy/",
            terms_url="https://pokrov.space/terms/",
        )

        self.assertIn('static const appName = "POKROV";', rewritten)
        self.assertIn(
            'static const githubUrl = "https://github.com/example/pokrov-app";',
            rewritten,
        )
        self.assertIn(
            'static const githubLatestReleaseUrl = "https://github.com/example/pokrov-app/releases/latest";',
            rewritten,
        )
        self.assertIn(
            'static const appCastUrl = "https://github.com/example/pokrov-app/releases/latest/download/appcast.xml";',
            rewritten,
        )
        self.assertIn('static const telegramChannelUrl = "https://t.me/pokrov_vpn";', rewritten)
        self.assertIn(
            'static const privacyPolicyUrl = "https://pokrov.space/privacy-policy/";',
            rewritten,
        )

    def test_rewrites_upstream_manifest_with_pokrov_schemes(self) -> None:
        module = _load_module()
        manifest = """
<application android:label="Hiddify">
    <activity>
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="hiddify" />
            <data android:scheme="v2ray" />
        </intent-filter>
    </activity>
</application>
""".strip()

        rewritten = module._rewrite_android_manifest(manifest, "POKROV", "pokrov")

        self.assertIn('android:label="POKROV"', rewritten)
        self.assertIn('<data android:scheme="pokrov" />', rewritten)
        self.assertIn('<data android:scheme="pokrovvpn" />', rewritten)
        self.assertIn('<data android:scheme="hiddify" />', rewritten)

    def test_rewrites_windows_exe_config_with_canonical_artifact_name(self) -> None:
        module = _load_module()
        config = """
publisher: Hiddify
publisher_url: https://github.com/hiddify/hiddify-app
display_name: Hiddify
create_desktop_icon: true
install_dir_name: "{autopf64}\\\\Hiddify"
setup_icon_file: windows\\runner\\resources\\app_icon.ico
script_template: inno_setup.sas
""".strip()

        rewritten = module._rewrite_windows_exe_config(
            config,
            publisher_name="POKROV",
            publisher_url="https://pokrov.space/",
            display_name="POKROV",
            exe_name="POKROV.exe",
            output_base_file_name="pokrov-windows-setup-x64",
            install_dir_name='"{autopf64}\\\\POKROV"',
        )

        self.assertIn("publisher: POKROV", rewritten)
        self.assertIn("publisher_url: https://pokrov.space/", rewritten)
        self.assertIn("display_name: POKROV", rewritten)
        self.assertIn("executable_name: POKROV.exe", rewritten)
        self.assertIn('output_base_file_name: pokrov-windows-setup-x64', rewritten)
        self.assertIn('install_dir_name: "{autopf64}\\\\POKROV"', rewritten)


if __name__ == "__main__":
    unittest.main()
