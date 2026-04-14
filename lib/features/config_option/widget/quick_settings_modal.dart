import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/config_option/overview/config_options_page.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hiddify/utils/platform_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuickSettingsModal extends HookConsumerWidget {
  const QuickSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final isRussian = t.$meta.locale.languageCode == 'ru';
    final serviceMode = ref.watch(ConfigOptions.serviceMode);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (PlatformUtils.isDesktop)
            ListTile(
              leading: const Icon(FluentIcons.shield_task_24_regular),
              title: const Text('Device optimization'),
              subtitle: Text(
                _desktopOptimizationMessage(
                  serviceMode: serviceMode,
                  isRussian: isRussian,
                ),
              ),
            ),
          ListTile(
            title: const Text('Routing preset'),
            subtitle: Text(
              presentConsumerRoutingMode(
                ref.watch(ConfigOptions.routingMode),
                t,
              ),
            ),
            trailing: const Icon(FluentIcons.chevron_right_24_regular),
            onTap: () => const ConfigOptionsRoute().go(context),
          ),
          ListTile(
            title: Text(isRussian
                ? 'РћС‚РєСЂС‹С‚СЊ РїРѕРґРґРµСЂР¶РєСѓ'
                : 'Open support'),
            subtitle: Text(
              isRussian
                  ? 'РћС‚РєСЂРѕРµРј РїРѕРґРґРµСЂР¶РєСѓ СЃ СѓР¶Рµ РїРѕРґРіРѕС‚РѕРІР»РµРЅРЅС‹Рј РєРѕРЅС‚РµРєСЃС‚РѕРј СѓСЃС‚СЂРѕР№СЃС‚РІР°.'
                  : 'Jump into support with your device context already prepared.',
            ),
            trailing: const Icon(FluentIcons.chat_24_regular),
            onTap: () => const SupportRoute().go(context),
          ),
          const Gap(8),
          ListTile(
            title: const Text('Advanced and recovery tools'),
            subtitle: Text(
              isRussian
                  ? 'РћС‚РєСЂРѕР№С‚Рµ РёС… С‚РѕР»СЊРєРѕ РєРѕРіРґР° РЅСѓР¶РЅС‹ РґРёР°РіРЅРѕСЃС‚РёРєР° РёР»Рё РїРѕРјРѕС‰СЊ СЃ РІРѕСЃСЃС‚Р°РЅРѕРІР»РµРЅРёРµРј.'
                  : 'Open these only when recovery or support needs extra steps.',
            ),
            trailing: const Icon(FluentIcons.chevron_right_24_regular),
            onTap: () => const ConfigOptionsRoute().go(context),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

String _desktopOptimizationMessage({
  required ServiceMode serviceMode,
  required bool isRussian,
}) {
  if (serviceMode != ServiceMode.tun) {
    return isRussian
        ? 'РџРѕР»РЅР°СЏ РѕРїС‚РёРјРёР·Р°С†РёСЏ СѓСЃС‚СЂРѕР№СЃС‚РІР° РѕСЃС‚Р°РµС‚СЃСЏ РІ СЃРєСЂС‹С‚С‹С… РёРЅСЃС‚СЂСѓРјРµРЅС‚Р°С… СЃРѕРІРјРµСЃС‚РёРјРѕСЃС‚Рё. РћР±С‹С‡РЅС‹Р№ СЃС†РµРЅР°СЂРёР№ РІРµРґРµС‚ С‡РµСЂРµР· РїРѕРґРґРµСЂР¶РєСѓ.'
        : 'Full-device optimization stays behind compatibility tools. Support will guide you there only when needed.';
  }

  return isRussian
      ? 'РџРµСЂРµР·Р°РїСѓСЃС‚РёС‚Рµ POKROV РѕС‚ РёРјРµРЅРё Р°РґРјРёРЅРёСЃС‚СЂР°С‚РѕСЂР°, РїСЂРµР¶РґРµ С‡РµРј РѕРїС‚РёРјРёР·РёСЂРѕРІР°С‚СЊ РІСЃРµ СѓСЃС‚СЂРѕР№СЃС‚РІРѕ.'
      : 'Restart POKROV as Administrator before optimizing the whole device.';
}
