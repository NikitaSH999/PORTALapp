import 'package:flutter/widgets.dart';

class PortalCopy {
  PortalCopy._(this.isRussian);

  final bool isRussian;

  static PortalCopy of(BuildContext context) {
    return PortalCopy._(
      Localizations.localeOf(context).languageCode.toLowerCase().startsWith(
            'ru',
          ),
    );
  }

  static final RegExp _daysPattern =
      RegExp(r'^(\d+)\s+days?$', caseSensitive: false);
  static final RegExp _monthsPattern =
      RegExp(r'^(\d+)\s+months?$', caseSensitive: false);

  String get shellVpn => 'VPN';
  String get shellLocations => isRussian ? 'Локации' : 'Locations';
  String get shellDevices => isRussian ? 'Устройства' : 'Devices';
  String get shellProfile => isRussian ? 'Профиль' : 'Profile';
  String get shellSupport => isRussian ? 'Поддержка' : 'Support';
  String get shellTagline =>
      isRussian ? 'Спокойная защита на каждый день' : 'Calm privacy every day';
  String get shellBadge => 'Pearl glass';

  String get loadingServiceData =>
      isRussian ? 'Загружаем данные сервиса...' : 'Loading service data...';
  String get loadingAccessDeck => isRussian
      ? 'Загружаем доступ, устройства и маршруты...'
      : 'Loading access, devices and routes...';
  String get serviceUnavailable => isRussian
      ? 'Сейчас не получается загрузить данные POKROV VPN.'
      : 'POKROV VPN data is not available right now.';
  String get copied =>
      isRussian ? 'Скопировано в буфер обмена.' : 'Copied to clipboard.';
  String get linkOpenFailed =>
      isRussian ? 'Не удалось открыть ссылку.' : 'Could not open the link.';

  String get homeConsoleBadge => isRussian ? 'Домашний центр' : 'Home console';
  String get secureOnTapEyebrow =>
      isRussian ? 'Защита в одно касание' : 'Secure in one tap';
  String homeStageTitle({required bool isActive}) => isRussian
      ? (isActive ? 'Подключение готово' : 'Защита ждёт запуска')
      : (isActive ? 'Connection is ready' : 'Protection is standing by');
  String homeStageBody({required bool isActive}) => isRussian
      ? (isActive
          ? 'Подключайтесь, переключайте локации и управляйте доступом, не выходя из приложения.'
          : 'Сначала активируйте доступ или подключите профиль, чтобы открыть полный сценарий POKROV VPN.')
      : (isActive
          ? 'Connect, switch locations, and manage access without leaving the app.'
          : 'Activate access or connect a profile first to unlock the full POKROV VPN flow.');
  String get activeProfileLabel =>
      isRussian ? 'Активный профиль' : 'Active profile';
  String get switchAction => isRussian ? 'Сменить' : 'Switch';
  String get subscriptionExpired =>
      isRussian ? 'Подписка завершена' : 'Subscription expired';
  String get remoteProfileReady =>
      isRussian ? 'Удалённый профиль готов' : 'Remote profile ready';
  String get localProfileReady =>
      isRussian ? 'Локальный профиль готов' : 'Local profile ready';
  String get unlimitedTraffic =>
      isRussian ? 'Безлимитный трафик' : 'Unlimited traffic';
  String trafficLeft(String value) =>
      isRussian ? 'Осталось $value' : '$value left';
  String daysRemaining(int value) =>
      isRussian ? '$value дн. осталось' : '$value days remaining';
  String get quickActionLocations => shellLocations;
  String get quickActionDevices => shellDevices;
  String get quickActionProfile => shellProfile;
  String get quickActionSupport => shellSupport;
  String get subscriptionLinkTitle =>
      isRussian ? 'Ссылка подключения' : 'Subscription link';
  String get copyAction => isRussian ? 'Скопировать' : 'Copy';
  String get subscriptionLinkCopied => isRussian
      ? 'Ссылка подключения скопирована.'
      : 'Subscription link copied.';

  String get quickConnectBadge =>
      isRussian ? 'Быстрое подключение' : 'Quick connect';
  String get routeDeckBadge => isRussian ? 'Маршрут и защита' : 'Route deck';
  String nodesReady(String value) {
    if (value == '--') {
      return isRussian ? 'Узлы просыпаются' : 'Nodes waking up';
    }
    return isRussian ? '$value узлов готово' : '$value nodes ready';
  }

  String heroStatusTitle({required bool trialLike}) => trialLike
      ? (isRussian ? 'Триал уже активен' : 'Trial is live')
      : (isRussian ? 'Подписка уже активна' : 'Subscription is live');
  String get autoRouteTitle =>
      isRussian ? 'Автомаршрут готов' : 'Auto route ready';
  String get bestPathNow =>
      isRussian ? 'Лучший маршрут сейчас' : 'Best path right now';
  String get chooseRouteAction =>
      isRussian ? 'Выбрать маршрут' : 'Choose route';
  String get protectedUntil => isRussian ? 'Защита до' : 'Protected until';
  String get protectedUntilCaption =>
      isRussian ? 'Триал или платный доступ' : 'Trial or paid access window';
  String get remainingTraffic => isRussian ? 'Осталось трафика' : 'Remaining';
  String get remainingTrafficCaption =>
      isRussian ? 'Доступно на этом устройстве' : 'Available on this device';
  String get liveDevices => isRussian ? 'Живые устройства' : 'Live devices';
  String get liveDevicesCaption => isRussian
      ? 'Сессии, использующие ваш план прямо сейчас'
      : 'Sessions using your plan right now';
  String get bonusDaysAction =>
      isRussian ? '+10 бонусных дней' : '+10 bonus days';
  String get browseLocationsAction =>
      isRussian ? 'Открыть локации' : 'Browse locations';

  String get locationsTitle => shellLocations;
  String get routingEyebrow => isRussian ? 'Маршрутизация' : 'Routing';
  String get autoSelectTitle => isRussian ? 'Автовыбор' : 'Auto-select';
  String get bestServerNow =>
      isRussian ? 'Лучший сервер прямо сейчас' : 'Best server right now';
  String get activeRoute => isRussian ? 'Активный маршрут' : 'Active route';
  String get recommended => isRussian ? 'Рекомендуется' : 'Recommended';
  String get selected => isRussian ? 'Выбрано' : 'Selected';
  String get available => isRussian ? 'Доступно' : 'Available';
  String get bestAvailable =>
      isRussian ? 'Лучший доступный узел' : 'Best available';
  String get locationsGateTitle => isRussian
      ? 'Локации откроются после активации'
      : 'Locations unlock after activation';
  String get locationsGateBody => isRussian
      ? 'Сначала запустите 5-дневный триал на этом устройстве. После активации приложение получит реальный ключ и покажет живые точки доступа.'
      : 'Start the 5-day trial on this device first. After activation the app receives a real connection key and shows live access points.';
  String get openVpnAction => isRussian ? 'Вернуться в VPN' : 'Return to VPN';
  String get locationsSyncTitle =>
      isRussian ? 'Локации синхронизируются' : 'Locations are syncing';
  String get locationsSyncBody => isRussian
      ? 'Профиль уже активен, но список узлов ещё обновляется. Пока можно пользоваться автомаршрутом.'
      : 'Your profile is active, but the node list is still syncing. Auto-route will keep working in the meantime.';

  String get devicesTitle => shellDevices;
  String get deviceOverviewEyebrow =>
      isRussian ? 'Обзор устройства' : 'Device overview';
  String get currentDeviceTitle =>
      isRussian ? 'Текущее устройство' : 'Current device';
  String get currentDeviceSubtitle => isRussian
      ? 'Живая сессия и лимит вашего плана.'
      : 'Your live device session and plan capacity.';
  String get currentDeviceFallback => isRussian
      ? 'Это устройство уже связано с доступом POKROV VPN.'
      : 'This device is linked to your POKROV VPN access.';
  String get activeSessions =>
      isRussian ? 'Активные сессии' : 'Active sessions';
  String get availableSlots =>
      isRussian ? 'Свободные слоты' : 'Available slots';
  String get healthyNodes => isRussian ? 'Здоровые узлы' : 'Healthy nodes';
  String get thisDevice => isRussian ? 'Это устройство' : 'This device';
  String get appDownloadsEyebrow => isRussian ? 'Приложения' : 'Apps';
  String get appDownloadsTitle =>
      isRussian ? 'Скачать приложения' : 'App downloads';
  String get appDownloadsSubtitle => isRussian
      ? 'Прямые установщики и зеркала для ваших устройств.'
      : 'Direct installers and fallback links for your devices.';
  String get primaryAction => isRussian ? 'Основная' : 'Primary';
  String get mirrorAction => isRussian ? 'Зеркало' : 'Mirror';
  String get noPrimaryLinkYet => isRussian
      ? 'Основная ссылка пока не настроена'
      : 'No primary link configured yet';

  String get profileTitle => shellProfile;
  String get accountEyebrow => isRussian ? 'Аккаунт' : 'Account';
  String get accountTitle =>
      isRussian ? 'Аккаунт POKROV VPN' : 'POKROV VPN account';
  String get accountSubtitle => isRussian
      ? 'Доступ, трафик и продление для этого устройства.'
      : 'Your device-linked access, traffic and renewal context.';
  String get remainingTrafficMetric =>
      isRussian ? 'Остаток трафика' : 'Remaining traffic';
  String get planMetric => isRussian ? 'План' : 'Plan';
  String get appAccount => isRussian ? 'Аккаунт приложения' : 'App account';
  String get deviceTrial => isRussian ? 'Триал устройства' : 'Device trial';
  String accountDetails(String accountId, String deviceName) => isRussian
      ? 'ID аккаунта: $accountId\nУстройство: $deviceName'
      : 'Account ID: $accountId\nDevice: $deviceName';
  String get rewardsEyebrow => isRussian ? 'Бонус' : 'Rewards';
  String get rewardsTitle =>
      isRussian ? '+10 дней через Telegram' : '+10 bonus days with Telegram';
  String get rewardsSubtitle => isRussian
      ? 'Привяжите Telegram, подпишитесь на @pokrov_vpn и активируйте бонус.'
      : 'Link Telegram, join @pokrov_vpn, then claim 10 extra days.';
  String get telegramStatus =>
      isRussian ? 'Статус Telegram' : 'Telegram status';
  String telegramLinked(String label) =>
      isRussian ? 'Telegram привязан: $label' : 'Telegram linked: $label';
  String get telegramNotLinked =>
      isRussian ? 'Telegram пока не привязан' : 'Not linked yet';
  String get linkTelegramAction =>
      isRussian ? 'Привязать Telegram' : 'Link Telegram';
  String get openingAction => isRussian ? 'Открываем...' : 'Opening...';
  String get checkingAction => isRussian ? 'Проверяем...' : 'Checking...';
  String get checkBonusAction => isRussian ? 'Проверить бонус' : 'Check bonus';
  String get openChannelAction => isRussian ? 'Открыть канал' : 'Open channel';
  String telegramAlreadyLinked(String username) => isRussian
      ? 'Telegram уже привязан${username.isNotEmpty ? ' как @$username' : ''}.'
      : 'Telegram is already linked${username.isNotEmpty ? ' as @$username' : ''}.';
  String get telegramLinkHint => isRussian
      ? 'Откройте бота, привяжите Telegram и вернитесь за бонусом.'
      : 'Open the bot to link Telegram, then come back and tap Check bonus.';
  String bonusApplied(int days) => isRussian
      ? 'Бонус активирован: +$days дней к доступу.'
      : 'Bonus applied: +$days days added to your access.';
  String get bonusAlreadyActive => isRussian
      ? 'Бонус Telegram уже активирован для этого аккаунта.'
      : 'The Telegram bonus is already active for this account.';
  String get recoveryEyebrow => isRussian ? 'Восстановление' : 'Recovery';
  String get recoveryTitle =>
      isRussian ? 'Восстановление подключения' : 'Connection recovery';
  String get recoverySubtitle => isRussian
      ? 'Держите главную ссылку подключения под рукой. Ручные инструменты остаются в расширенных настройках.'
      : 'Keep your primary connection link handy. Manual recovery stays in Advanced settings.';
  String get primaryConnectionLink =>
      isRussian ? 'Главная ссылка подключения' : 'Primary connection link';
  String get noConnectionLinkYet => isRussian
      ? 'Пока нет активной ссылки подписки'
      : 'No active subscription link yet';
  String get manualRecovery =>
      isRussian ? 'Ручное восстановление' : 'Manual recovery';
  String get manualRecoverySubtitle => isRussian
      ? 'Ручной импорт и аварийные инструменты остаются в расширенных настройках.'
      : 'Plain import and advanced recovery tools stay in Advanced settings.';
  String get downloadsEyebrow => isRussian ? 'Загрузки' : 'Downloads';
  String get downloadsTitle =>
      isRussian ? 'Приложения и документы' : 'Apps and documents';
  String get downloadsSubtitle => isRussian
      ? 'Установщики и документы для Android, Windows и сценариев восстановления.'
      : 'Installers and docs for Android, Windows and recovery flows.';
  String get advancedEyebrow => isRussian ? 'Расширенные' : 'Advanced';
  String get advancedTitle => isRussian ? 'Расширенные настройки' : 'Advanced';
  String get advancedSubtitle => isRussian
      ? 'Сетевые тонкости остаются здесь и не мешают основному VPN-сценарию.'
      : 'Advanced networking tools stay here, away from the main VPN flow.';
  String get openAdvancedSettings =>
      isRussian ? 'Открыть расширенные настройки' : 'Open advanced settings';

  String get supportTitle => shellSupport;
  String get needHelpEyebrow => isRussian ? 'Нужна помощь?' : 'Need help?';
  String get getHelpFast =>
      isRussian ? 'Помощь за пару шагов' : 'Get help fast';
  String get supportSubtitle => isRussian
      ? 'Открывайте поддержку уже с подготовленным аккаунтом и данными устройства.'
      : 'Open support with your account and device context already prepared.';
  String get preparedContext =>
      isRussian ? 'Подготовленный контекст' : 'Prepared context';
  String get openTelegramSupport =>
      isRussian ? 'Открыть поддержку в Telegram' : 'Open Telegram support';
  String get emailSupport => isRussian ? 'Написать на почту' : 'Email support';
  String get copyDiagnostics =>
      isRussian ? 'Скопировать диагностику' : 'Copy diagnostics';
  String get diagnosticsCopied =>
      isRussian ? 'Диагностика скопирована.' : 'Diagnostics copied.';
  String get deviceContext =>
      isRussian ? 'Контекст устройства' : 'Device context';
  String deviceContextDetails(String deviceName, String accountId) => isRussian
      ? '$deviceName\nАккаунт $accountId'
      : '$deviceName\nAccount $accountId';

  String get subscriptionTitle => isRussian ? 'Подписка' : 'Subscription';
  String get subscriptionSubtitleTrial => isRussian
      ? 'Продлите доступ из приложения, а оплату безопасно завершите в браузере.'
      : 'Upgrade from the app and finish payment securely in your browser.';
  String get subscriptionSubtitlePaid => isRussian
      ? 'Управляйте продлением, оплатой и доступом из одного места.'
      : 'Manage renewal, payment and access from one place.';
  String get expiresMetric => isRussian ? 'Истекает' : 'Expires';
  String get deviceLimitMetric =>
      isRussian ? 'Лимит устройств' : 'Device limit';
  String get openSecureCheckout =>
      isRussian ? 'Открыть безопасную оплату' : 'Open secure checkout';
  String get continueInTelegram =>
      isRussian ? 'Продолжить в Telegram' : 'Continue in Telegram';
  String choosePlan(String label) =>
      isRussian ? 'Выбрать $label' : 'Choose $label';
  String planSummary({
    required int amountRub,
    required int days,
    required int deviceLimit,
  }) {
    if (!isRussian) {
      return '$amountRub RUB / $days days / $deviceLimit devices';
    }
    return '$amountRub ₽ • ${daysLabel(days)} • ${deviceLabel(deviceLimit)}';
  }

  String get trialReadyToast => isRussian
      ? 'Триал активирован, подключение готово.'
      : 'Trial activated. Your connection is ready.';
  String trialError(Object error) => isRussian
      ? 'Не удалось активировать триал: $error'
      : 'Could not activate the trial: $error';
  String get emptyStateTitle => isRussian
      ? 'Пять дней защиты без настройки'
      : 'Zero setup. Five days on us.';
  String get emptyStateBody => isRussian
      ? 'Один тап запускает рабочий триал прямо на этом устройстве. Telegram не нужен для старта.'
      : 'One tap activates a real trial on this device. Telegram bonus can wait until later.';
  String get emptyStateBonusTitle => isRussian
      ? 'Бонус Telegram можно подключить позже'
      : 'Telegram bonus can wait';
  String get emptyStateBonusBody => isRussian
      ? '+10 дней активируются после подписки на канал, когда вам это будет удобно.'
      : '+10 extra days are available after joining the Telegram channel, whenever you are ready.';
  String get emptyStatePrimaryAction =>
      isRussian ? 'Запустить триал на 5 дней' : 'Start 5-day trial';
  String get emptyStateSecondaryAction => isRussian
      ? 'Добавить ключ или подписку вручную'
      : 'Add key or subscription manually';
  String get profilesEyebrow => isRussian ? 'Профили' : 'Profiles';
  String get chooseActiveProfileTitle => isRussian
      ? 'Сначала выберите активный профиль'
      : 'Choose an active profile first';
  String get trialPlatformsBadge => 'Android + Windows';

  String supportStatus(String raw) {
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'open':
        return isRussian ? 'Открыто' : 'OPEN';
      case 'closed':
        return isRussian ? 'Закрыто' : 'CLOSED';
      case 'pending':
        return isRussian ? 'В работе' : 'PENDING';
      case 'demo':
        return isRussian ? 'Демо' : 'DEMO';
      default:
        return isRussian
            ? localizeServerText(raw).toUpperCase()
            : raw.toUpperCase();
    }
  }

  String localizeServerText(String raw) {
    final value = raw.trim();
    if (!isRussian || value.isEmpty) return value;

    final dayMatch = _daysPattern.firstMatch(value);
    if (dayMatch != null) {
      final days = int.tryParse(dayMatch.group(1) ?? '') ?? 0;
      return daysLabel(days);
    }

    final monthMatch = _monthsPattern.firstMatch(value);
    if (monthMatch != null) {
      final months = int.tryParse(monthMatch.group(1) ?? '') ?? 0;
      return monthsLabel(months);
    }

    switch (value.toLowerCase()) {
      case 'trial':
        return 'Триал';
      case 'popular':
        return 'Популярно';
      case 'current device':
        return 'Текущее устройство';
      case 'device':
        return 'Устройство';
      case 'ready to connect':
        return 'Готово к подключению';
      case 'your trial is active.':
      case 'your trial is active':
        return 'Триал уже активен.';
      case 'your service hub is ready':
        return 'Центр сервиса готов';
      case 'connect a profile, then unlock subscription, locations, devices, support and downloads without leaving the app.':
        return 'Подключите профиль, а затем откройте подписку, локации, устройства, поддержку и загрузки, не выходя из приложения.';
      case 'support and account data will appear here after trial activation.':
        return 'Данные поддержки и аккаунта появятся здесь после активации триала.';
      case 'welcome to pokrov vpn':
        return 'Добро пожаловать в POKROV VPN';
      case 'available after activation':
        return 'Доступно после активации';
      case 'primary access point':
        return 'Основная точка доступа';
      case 'secondary access point':
        return 'Резервная точка доступа';
      case 'billing issue':
        return 'Вопрос по оплате';
      case 'need help with my renewal.':
        return 'Нужна помощь с продлением.';
      case 'netherlands':
        return 'Нидерланды';
      case 'germany':
        return 'Германия';
      case 'poland':
        return 'Польша';
      case 'france':
        return 'Франция';
      case 'sweden':
        return 'Швеция';
      case 'norway':
        return 'Норвегия';
      case 'finland':
        return 'Финляндия';
      case 'singapore':
        return 'Сингапур';
      case 'japan':
        return 'Япония';
      case 'turkey':
        return 'Турция';
      case 'united states':
        return 'США';
      case 'united kingdom':
        return 'Великобритания';
      case 'romania':
        return 'Румыния';
      case 'estonia':
        return 'Эстония';
      case 'latvia':
        return 'Латвия';
      case 'lithuania':
        return 'Литва';
      case 'amsterdam':
        return 'Амстердам';
      case 'frankfurt':
        return 'Франкфурт';
    }

    return value;
  }

  String daysLabel(int days) {
    if (!isRussian) return '$days days';
    return '$days ${_plural(days, one: 'день', few: 'дня', many: 'дней')}';
  }

  String deviceLabel(int count) {
    if (!isRussian) return '$count devices';
    return '$count ${_plural(count, one: 'устройство', few: 'устройства', many: 'устройств')}';
  }

  String monthsLabel(int months) {
    if (!isRussian) return '$months months';
    return '$months ${_plural(months, one: 'месяц', few: 'месяца', many: 'месяцев')}';
  }

  String _plural(
    int value, {
    required String one,
    required String few,
    required String many,
  }) {
    final mod10 = value % 10;
    final mod100 = value % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }
}
