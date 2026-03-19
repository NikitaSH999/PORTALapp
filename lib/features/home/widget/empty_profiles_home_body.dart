import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/portal/data/portal_trial_activator.dart';
import 'package:hiddify/features/portal/widget/portal_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyProfilesHomeBody extends HookConsumerWidget {
  const EmptyProfilesHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final trialActivation = ref.watch(portalTrialActivationControllerProvider);
    final isRussian = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

    ref.listen<AsyncValue<void>>(
      portalTrialActivationControllerProvider,
      (previous, next) {
        final wasLoading = previous?.isLoading ?? false;
        if (!wasLoading || next.isLoading) return;

        final messenger = ScaffoldMessenger.of(context);
        next.whenOrNull(
          data: (_) => messenger.showSnackBar(
            SnackBar(
              content: Text(
                isRussian
                    ? 'Триал активирован, подключение готово.'
                    : 'Trial activated. Your connection is ready.',
              ),
            ),
          ),
          error: (error, _) => messenger.showSnackBar(
            SnackBar(
              content: Text(
                isRussian
                    ? 'Не удалось активировать триал: $error'
                    : 'Could not activate the trial: $error',
              ),
            ),
          ),
        );
      },
    );

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: PortalSectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRussian ? 'PORTAL VPN' : 'PORTAL VPN',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(8),
                  Text(
                    isRussian
                        ? 'Попробуйте VPN бесплатно 5 дней'
                        : 'Try the VPN free for 5 days',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Gap(12),
                  Text(
                    isRussian
                        ? 'Нажмите одну кнопку, чтобы активировать рабочий триал на этом устройстве. Telegram не нужен для старта.'
                        : 'Activate a real trial on this device with one tap. Telegram is optional.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Gap(10),
                  Text(
                    isRussian
                        ? '+10 дней можно получить позже за подписку на Telegram-канал.'
                        : '+10 extra days are available later after joining the Telegram channel.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Gap(20),
                  FilledButton.icon(
                    onPressed: trialActivation.isLoading
                        ? null
                        : () => ref
                            .read(portalTrialActivationControllerProvider.notifier)
                            .activateTrial(locale: Localizations.localeOf(context)),
                    icon: trialActivation.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Icon(FluentIcons.flash_24_regular),
                    label: Text(
                      isRussian ? 'Попробовать бесплатно' : 'Try free',
                    ),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: () => const AddProfileRoute().push(context),
                    icon: const Icon(FluentIcons.add_24_regular),
                    label: Text(
                      isRussian
                          ? 'Добавить ключ или подписку вручную'
                          : t.profile.add.buttonText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyActiveProfileHomeBody extends HookConsumerWidget {
  const EmptyActiveProfileHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(t.home.noActiveProfileMsg),
          const Gap(16),
          OutlinedButton(
            onPressed: () => const ProfilesOverviewRoute().push(context),
            child: Text(t.profile.overviewPageTitle),
          ),
        ],
      ),
    );
  }
}
