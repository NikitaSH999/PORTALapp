import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsOverviewPage extends HookConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const NestedAppBar(
            title: Text('Advanced'),
          ),
          SliverList.list(
            children: const [
              SettingsSection('General'),
              GeneralSettingTiles(),
              PlatformSettingsTiles(),
              SettingsDivider(),
              SettingsSection('Advanced'),
              AdvancedSettingTiles(),
              Gap(16),
            ],
          ),
        ],
      ),
    );
  }
}
