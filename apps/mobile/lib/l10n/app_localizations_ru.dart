// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get accountSignupTitle => 'Создайте аккаунт';

  @override
  String get accountSignupLede => 'Для начала у вас будет своё рабочее пространство.';

  @override
  String accountSignupInviteLede(String workspace) {
    return 'Создайте аккаунт, чтобы присоединиться к $workspace.';
  }

  @override
  String get accountSignupClosed => 'Регистрация на этом сервере — по приглашениям. Попросите ссылку у владельца рабочего пространства.';

  @override
  String get accountFirstUser => 'Это первый аккаунт: он станет администратором платформы.';

  @override
  String get accountEmail => 'Почта';

  @override
  String get accountDisplayName => 'Ваше имя';

  @override
  String get accountUsername => 'Имя пользователя';

  @override
  String get accountUsernameHelp => 'Необязательно; если пусто, берётся из почты.';

  @override
  String get accountPassword => 'Пароль';

  @override
  String get accountPasswordHelp => 'Не меньше 12 символов.';

  @override
  String get accountPasswordAgain => 'Повторите пароль';

  @override
  String get accountPasswordsDiffer => 'Пароли не совпадают.';

  @override
  String get accountWorkspaceName => 'Название пространства';

  @override
  String get accountWorkspaceNameHelp => 'Ваше первое пространство, например название проекта. Его можно переименовать.';

  @override
  String get accountCreate => 'Создать аккаунт';

  @override
  String get accountCreating => 'Создание…';

  @override
  String get accountHaveAccount => 'Уже есть аккаунт?';

  @override
  String get accountSignIn => 'Войти';

  @override
  String get accountNoAccount => 'Ещё нет аккаунта?';

  @override
  String get accountSignUp => 'Создать';

  @override
  String get accountForgot => 'Забыли пароль?';

  @override
  String get accountForgotTitle => 'Сброс пароля';

  @override
  String get accountForgotLede => 'Мы отправим ссылку, чтобы задать новый пароль.';

  @override
  String get accountForgotSend => 'Отправить ссылку';

  @override
  String get accountForgotSent => 'Если эта почта принадлежит аккаунту, ссылка уже в пути. Она действует час.';

  @override
  String get accountResetTitle => 'Новый пароль';

  @override
  String get accountResetSave => 'Сохранить пароль';

  @override
  String get accountResetDone => 'Пароль изменён. Все сеансы завершены.';

  @override
  String get accountVerifyTitle => 'Подтверждение почты';

  @override
  String get accountVerifying => 'Подтверждаем…';

  @override
  String get accountVerified => 'Почта подтверждена.';

  @override
  String get accountVerifyFailed => 'Ссылка недействительна или устарела.';

  @override
  String get accountContinue => 'Продолжить';

  @override
  String accountInviteTitle(String workspace) {
    return 'Присоединиться к $workspace';
  }

  @override
  String accountInviteBy(String name) {
    return 'Вас пригласил(а) $name.';
  }

  @override
  String accountInviteFor(String email) {
    return 'Приглашение для $email.';
  }

  @override
  String get accountInviteJoin => 'Присоединиться';

  @override
  String get accountInviteJoining => 'Присоединяемся…';

  @override
  String get accountInviteInvalid => 'Ссылка-приглашение недействительна или устарела. Попросите новую.';

  @override
  String get accountInviteSignInFirst => 'Войдите или создайте аккаунт, чтобы присоединиться.';

  @override
  String get accountWorkspacesTitle => 'Ваши рабочие пространства';

  @override
  String get accountWorkspacesLede => 'Рабочее пространство — это один проект: его репозитории, тикеты, участники и настройки.';

  @override
  String get accountNoWorkspaces =>
      'Вы пока не состоите ни в одном пространстве. Создайте своё или откройте присланную вам ссылку-приглашение.';

  @override
  String get accountOpen => 'Открыть';

  @override
  String get accountCreateWorkspace => 'Создать рабочее пространство';

  @override
  String get accountCreateWorkspaceSub => 'Вы станете его владельцем.';

  @override
  String get accountWorkspaceSlug => 'Адрес';

  @override
  String get accountWorkspaceSlugHelp => 'Используется в ссылках; если пусто, берётся из названия.';

  @override
  String get accountCreateWs => 'Создать пространство';

  @override
  String get accountProfileTitle => 'Профиль';

  @override
  String get accountProfile => 'Ваш профиль';

  @override
  String get accountProfileSub => 'Как вас видят участники ваших пространств.';

  @override
  String get accountSaveProfile => 'Сохранить';

  @override
  String get accountProfileSaved => 'Профиль сохранён';

  @override
  String get accountEmailUnverified => 'Ещё не подтверждена';

  @override
  String get accountEmailVerified => 'Подтверждена';

  @override
  String get accountResend => 'Отправить ссылку снова';

  @override
  String get accountResent => 'Ссылка для подтверждения отправлена';

  @override
  String get accountPasswordTitle => 'Пароль';

  @override
  String get accountPasswordSub => 'После смены остальные сеансы завершатся.';

  @override
  String get accountCurrentPassword => 'Текущий пароль';

  @override
  String get accountNewPassword => 'Новый пароль';

  @override
  String get accountChangePassword => 'Сменить пароль';

  @override
  String get accountPasswordChanged => 'Пароль изменён';

  @override
  String get accountTotpTitle => 'Двухфакторный вход';

  @override
  String get accountTotpSub => 'Код из приложения-аутентификатора при каждом входе.';

  @override
  String get accountTotpOn => 'Включён';

  @override
  String get accountTotpOff => 'Выключен';

  @override
  String get accountTotpSetup => 'Включить';

  @override
  String get accountTotpScan =>
      'Добавьте аккаунт в приложение-аутентификатор по секрету (или откройте ссылку на телефоне), затем введите код из приложения.';

  @override
  String get accountTotpSecret => 'Секрет';

  @override
  String get accountTotpLink => 'Ссылка для настройки';

  @override
  String get accountTotpCode => 'Код';

  @override
  String get accountTotpConfirm => 'Подтвердить';

  @override
  String get accountTotpEnabled => 'Двухфакторный вход включён';

  @override
  String get accountTotpDisable => 'Выключить';

  @override
  String get accountTotpDisabled => 'Двухфакторный вход выключен';

  @override
  String get accountMyClaude => 'Ваш аккаунт Claude';

  @override
  String get accountMyClaudeSub => 'Запуски ваших тикетов используют его в пространствах с режимом «у каждого свой».';

  @override
  String get accountClaudeSaved => 'Аккаунт Claude подключён';

  @override
  String get accountClaudeRemoved => 'Аккаунт Claude отключён';

  @override
  String get accountAdmin => 'Администратор платформы';

  @override
  String get accountAdminConsole => 'Открыть консоль оператора';

  @override
  String get accountReturnTitle => 'Оплата';

  @override
  String get accountReturnLede =>
      'Спасибо. Кредиты появятся в разделе «Оплата», как только платёжная система подтвердит платёж (обычно в течение минуты).';

  @override
  String get accountReturnBack => 'Вернуться к оплате';

  @override
  String get accountLastOpened => 'Открывали последним';

  @override
  String accountMemberCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n участника',
      many: '$n участников',
      few: '$n участника',
      one: '$n участник',
    );
    return '$_temp0';
  }

  @override
  String accountSlotCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n параллельного запуска',
      many: '$n параллельных запусков',
      few: '$n параллельных запуска',
      one: '$n параллельный запуск',
    );
    return '$_temp0';
  }

  @override
  String get accountSuspended => 'Приостановлено';

  @override
  String get accountNoWorkspacesTitle => 'Пока нет рабочих пространств';

  @override
  String get accountCreateFirst => 'Создайте первое рабочее пространство';

  @override
  String get accountInviteGoogle => 'Войдите через Google, чтобы присоединиться. Впервые здесь? Аккаунт создастся сразу.';

  @override
  String get accountTotpRequiredAdmin => 'Для аккаунтов администраторов двухфакторный вход обязателен, поэтому он остаётся включённым.';

  @override
  String get accountGoHome => 'Назад к обзору';

  @override
  String accountBackToDashboard(String name) {
    return 'Назад к обзору пространства $name';
  }

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get analyticsLede =>
      'Насколько хорошо agnts работает на вас со временем: пропускная способность, качество, куда уходит время и сколько это стоит вашему тарифу.';

  @override
  String get analyticsPeriod => 'Период';

  @override
  String analyticsDays(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n дня', many: '$n дней', few: '$n дня', one: '$n день');
    return '$_temp0';
  }

  @override
  String get analyticsExportCsv => 'Экспорт CSV';

  @override
  String get analyticsLoading => 'Загрузка аналитики…';

  @override
  String get analyticsError => 'Не удалось загрузить аналитику. Попробуйте ещё раз.';

  @override
  String get analyticsEmptyTitle => 'За этот период пока нет данных';

  @override
  String get analyticsEmpty =>
      'Графики заполнятся, когда agnts начнёт брать тикеты и запускать работу. Добавьте метку задаче в Jira или создайте задачу, чтобы начать.';

  @override
  String get analyticsKpiPushed => 'Отправлено тикетов';

  @override
  String analyticsKpiPushedNote(String n) {
    return 'из $n взятых';
  }

  @override
  String get analyticsKpiSuccess => 'Доля успеха';

  @override
  String get analyticsKpiSuccessNote => 'Отправлено из взятых';

  @override
  String get analyticsKpiFirstTry => 'Одобрено с первого раза';

  @override
  String get analyticsKpiFirstTryNote => 'Без запроса изменений';

  @override
  String get analyticsKpiAgnts => 'Время agnts на тикет';

  @override
  String get analyticsKpiAgntsNote => 'Анализ, разработка и тесты';

  @override
  String get analyticsKpiWait => 'Ожидание вас';

  @override
  String get analyticsKpiWaitNote => 'В среднем на тикет';

  @override
  String get analyticsKpiTurns => 'Среднее число шагов';

  @override
  String get analyticsKpiTurnsNote => 'На тикет';

  @override
  String analyticsCompared(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n днями', many: '$n днями', few: '$n днями', one: '$n днём');
    return 'Изменения сравниваются с предыдущими $_temp0. Зелёный — лучше.';
  }

  @override
  String get analyticsThroughput => 'Пропускная способность';

  @override
  String get analyticsThroughputSub => 'Взятые тикеты и их итог по дням';

  @override
  String get analyticsPushed => 'Отправлено';

  @override
  String get analyticsRejected => 'Отклонено';

  @override
  String get analyticsStopped => 'Остановлено';

  @override
  String get analyticsOutcomes => 'Итоги';

  @override
  String get analyticsOutcomesSub => 'Чем закончились тикеты';

  @override
  String get analyticsFirstTry => 'Одобрено с первого раза';

  @override
  String get analyticsAfterChanges => 'Одобрено после изменений';

  @override
  String get analyticsDonutSub => 'отправлено';

  @override
  String get analyticsSpeed => 'Скорость';

  @override
  String get analyticsSpeedSub => 'Среднее время на тикет: работа agnts и ожидание вас';

  @override
  String get analyticsAgntsWorking => 'agnts работает';

  @override
  String get analyticsWaitingOnYou => 'Ожидание вас';

  @override
  String get analyticsSteps => 'Куда уходит время';

  @override
  String get analyticsStepsSub => 'В среднем на тикет, по шагам';

  @override
  String get analyticsTurns => 'Шагов на тикет';

  @override
  String get analyticsTurnsSub => 'Меньше шагов — agnts быстрее разбирается и тратит меньше лимита';

  @override
  String get analyticsAvgTurns => 'Среднее число шагов';

  @override
  String get analyticsStops => 'Почему запуски останавливаются';

  @override
  String analyticsStopsSub(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n остановленного запуска за период',
      many: '$n остановленных запусков за период',
      few: '$n остановленных запуска за период',
      one: '$n остановленный запуск за период',
    );
    return '$_temp0';
  }

  @override
  String get analyticsStopTests => 'Тесты продолжали падать';

  @override
  String get analyticsStopLimit => 'Закончился лимит тарифа';

  @override
  String get analyticsStopYou => 'Остановлено вами';

  @override
  String get analyticsStopTurns => 'Достигнут лимит шагов';

  @override
  String get analyticsStopOther => 'Другие ошибки';

  @override
  String get analyticsModels => 'Модели';

  @override
  String get analyticsModelsSub => 'Запуски по моделям и их результаты';

  @override
  String get analyticsChangeModels => 'Изменить модели';

  @override
  String get analyticsColModel => 'Модель';

  @override
  String get analyticsColRuns => 'Запуски';

  @override
  String get analyticsColShare => 'Доля';

  @override
  String get analyticsColReview => 'Дошли до ревью';

  @override
  String get analyticsColTurns => 'Среднее число шагов';

  @override
  String get analyticsNoRuns => 'За этот период запусков нет.';

  @override
  String get analyticsUsage => 'Лимиты тарифа';

  @override
  String get analyticsUsageSub => 'Пиковое использование сессии по дням';

  @override
  String get analyticsSession => 'Сессия';

  @override
  String get analyticsAvgPeak => 'Средний пик';

  @override
  String get analyticsDaysAbove => 'Дней выше 80%';

  @override
  String get analyticsNoUsage => 'За этот период нет данных о лимитах.';

  @override
  String get analyticsSpend => 'Расход токенов';

  @override
  String get analyticsSpendSub => 'Токены, которые Claude потратил за день, на вход и выход';

  @override
  String get analyticsSpendTokens => 'Токены на вход и выход';

  @override
  String get analyticsSpendCost => 'По ценам API';

  @override
  String get analyticsSpendStages => 'Расход по этапам';

  @override
  String get analyticsSpendStagesSub => 'Куда ушли токены, самые дорогие сверху';

  @override
  String get analyticsNoSpend => 'За этот период запусков Claude нет.';

  @override
  String get analyticsRepos => 'По репозиториям';

  @override
  String get analyticsReposSub => 'Где agnts работает лучше всего, а где ему трудно';

  @override
  String get analyticsColRepo => 'Репозиторий';

  @override
  String get analyticsColSource => 'Источник';

  @override
  String get analyticsColTickets => 'Тикеты';

  @override
  String get analyticsColSuccess => 'Доля успеха';

  @override
  String get analyticsColAgnts => 'Время agnts';

  @override
  String get analyticsColClaudeMd => 'CLAUDE.md';

  @override
  String get analyticsSrcJira => 'Jira';

  @override
  String get analyticsSrcTask => 'Задача';

  @override
  String get analyticsMdFound => 'Есть';

  @override
  String get analyticsMdMissing => 'Нет';

  @override
  String get analyticsMdUnknown => 'Неизвестно';

  @override
  String get analyticsNoRepos => 'За этот период ни в одном репозитории не было тикетов.';

  @override
  String get analyticsHours => 'Активность по часам';

  @override
  String analyticsHoursSub(String hour) {
    return 'Когда работает agnts, сумма за период. Самый загруженный час: $hour:00';
  }

  @override
  String get analyticsEvents => 'События';

  @override
  String get analyticsInsights => 'Выводы';

  @override
  String get analyticsInsightsSub => 'Что подсказывают цифры';

  @override
  String get analyticsNoInsights => 'Пока недостаточно данных для выводов.';

  @override
  String analyticsInsightClaudeMd(String gain, String repos) {
    return 'Репозитории с CLAUDE.md завершают работу за $gain% меньше шагов. Добавить его в $repos — самый быстрый выигрыш.';
  }

  @override
  String analyticsInsightWaiting(String share, String review) {
    return '$share% всего времени тикета уходит на ожидание вас. Ревью ждут в среднем около $review мин.';
  }

  @override
  String analyticsInsightStopsTests(String n) {
    return 'Чаще всего запуски ($n) останавливаются из-за падающих тестов. Чёткие критерии приёмки в тикетах помогают agnts понять, когда работа готова.';
  }

  @override
  String analyticsInsightStopsLimit(String n) {
    return 'Чаще всего запуски ($n) останавливает лимит тарифа. Меньше одновременных запусков или Haiku для сводок экономят лимит.';
  }

  @override
  String analyticsInsightNight(String pct) {
    return '$pct% работы agnts приходится на время с 22:00 до 07:00, пока вы не в сети.';
  }

  @override
  String analyticsMinutes(String n) {
    return '$n мин';
  }

  @override
  String analyticsHoursMinutes(String h, String m) {
    return '$h ч $m мин';
  }

  @override
  String get analyticsSrcPlane => 'Plane';

  @override
  String get analyticsQuality => 'Качество агента';

  @override
  String get analyticsQualitySub =>
      'Тикеты сгруппированы по версии промптов их первого запуска кодирования. Сравнивайте версии, чтобы понять, помогло ли изменение агента.';

  @override
  String get analyticsNoQuality => 'За этот период не было запусков кодирования.';

  @override
  String get analyticsColVersion => 'Версия промптов';

  @override
  String get analyticsVersionUnknown => 'до учёта';

  @override
  String get analyticsColFirstPass => 'С первого раза';

  @override
  String get analyticsColFirstPassHint => 'Завершённые тикеты, принятые без запроса изменений от человека';

  @override
  String get analyticsColRounds => 'Раундов правок';

  @override
  String get analyticsColRoundsHint => 'Среднее число запросов изменений от человека на тикет, дошедший до ревью';

  @override
  String get analyticsColFixes => 'Исправлений проверок';

  @override
  String get analyticsColFixesHint => 'Сколько раз в среднем упавшие проверки возвращались Claude';

  @override
  String get analyticsColSerious => 'Серьёзные замечания';

  @override
  String get analyticsColSeriousHint => 'Доля тикетов, где ревью agnts нашло блокирующую или серьёзную проблему';

  @override
  String get analyticsColFootprint => 'Точность плана';

  @override
  String get analyticsColFootprintHint => 'Доля изменённых файлов, которые анализ предсказал';

  @override
  String get analyticsColRedFlags => 'Тревожные признаки';

  @override
  String get analyticsColRedFlagsHint => 'Пропущенные тесты, удалённые проверки, заглушённые линтеры и подобное в диффах';

  @override
  String get analyticsColSelfFixes => 'Самоисправления';

  @override
  String get analyticsColSelfFixesHint => 'Сколько раз ревью agnts возвращало замечания кодеру до просмотра человеком';

  @override
  String get analyticsTabOverview => 'Обзор';

  @override
  String get analyticsTabDelivery => 'Доставка';

  @override
  String get analyticsTabQuality => 'Качество';

  @override
  String get analyticsTabLearning => 'Обучение';

  @override
  String get analyticsTabCost => 'Стоимость';

  @override
  String get analyticsTabRepos => 'Репозитории';

  @override
  String analyticsDaysHours(String d, String h) {
    return '$d д $h ч';
  }

  @override
  String get analyticsKpiMerged => 'Влито пул-реквестов';

  @override
  String analyticsKpiMergedNote(String n) {
    return '$n закрыто без слияния';
  }

  @override
  String get analyticsKpiCostPerTicket => 'Стоимость тикета';

  @override
  String get analyticsKpiCostPerTicketNote => 'По ценам API, все этапы';

  @override
  String analyticsInsightMergeRate(String pct, String closed) {
    return 'Влито только $pct% пул-реквестов agnts; $closed закрыто без слияния. Причины смотрите во вкладке «Доставка».';
  }

  @override
  String analyticsInsightSlowAnswers(String hours) {
    return 'Тикеты ждут ваших ответов на вопросы agnts около $hours ч. Отвечать быстрее — самый простой способ ускорить доставку.';
  }

  @override
  String analyticsInsightFollowUpsNoise(String pct) {
    return 'Принято только $pct% предложенных доработок. Большинство из них отклоняется.';
  }

  @override
  String analyticsInsightFlakyJob(String job, String repo, String n) {
    return '$job в $repo проходил при перезапуске $n раз — похоже, тест нестабилен. Исправив или отключив его, вы сэкономите время CI.';
  }

  @override
  String get analyticsPrMerged => 'Влиты';

  @override
  String get analyticsPrClosed => 'Закрыты без слияния';

  @override
  String get analyticsPrOpened => 'Открыто';

  @override
  String get analyticsPrOpen => 'Ещё открыты';

  @override
  String get analyticsCyclePushed => 'Взят → отправлен';

  @override
  String get analyticsCycleMerged => 'Взят → влит';

  @override
  String get analyticsSplitAnswers => 'Ожидание ответов';

  @override
  String get analyticsSplitReview => 'Ожидание ревью';

  @override
  String get analyticsSplitQueue => 'В очереди или на паузе';

  @override
  String get analyticsKpiMergeRate => 'Доля слияний';

  @override
  String analyticsKpiMergeRateNote(String merged, String closed) {
    return '$merged влито, $closed закрыто';
  }

  @override
  String get analyticsKpiTimeToMerge => 'Время до слияния';

  @override
  String get analyticsKpiTimeToMergeNote => 'От пул-реквеста до слияния';

  @override
  String get analyticsKpiCyclePushed => 'Взят → отправлен';

  @override
  String get analyticsKpiCyclePushedNote => 'Часть работы agnts';

  @override
  String get analyticsKpiCycleMerged => 'Взят → влит';

  @override
  String get analyticsKpiCycleMergedNote => 'Реальное время доставки';

  @override
  String get analyticsKpiAnswer => 'Время ответа';

  @override
  String get analyticsKpiAnswerNote => 'Пока вы отвечаете на вопросы agnts';

  @override
  String get analyticsTypicalNote => 'Время — типичное значение (медиана): половина тикетов была быстрее, половина — медленнее.';

  @override
  String get analyticsPrOutcomes => 'Судьба пул-реквестов';

  @override
  String get analyticsPrOutcomesSub => 'Пул-реквесты agnts, открытые за период, и что с ними стало; слияния и закрытия по дням';

  @override
  String analyticsMergeSpread(String p50, String p90) {
    return 'Обычно пул-реквест вливают за $p50; самый медленный из десяти — за $p90 и дольше.';
  }

  @override
  String get analyticsStale => 'Открыты больше недели';

  @override
  String get analyticsStaleSub => 'Пул-реквесты, которые ещё никто не влил и не закрыл';

  @override
  String get analyticsNoStale => 'Нет пул-реквестов, открытых дольше недели.';

  @override
  String analyticsOpenDays(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'открыт $n дня',
      many: 'открыт $n дней',
      few: 'открыт $n дня',
      one: 'открыт $n день',
    );
    return '$_temp0';
  }

  @override
  String get analyticsOpenPr => 'Открыть пул-реквест';

  @override
  String get analyticsCycle => 'Время цикла';

  @override
  String get analyticsCycleSub => 'Типичное время от взятия тикета до отправки и до слияния, по дням';

  @override
  String analyticsCycleSpread(String pushed, String pushed90, String merged, String merged90) {
    return 'Отправка обычно за $pushed (самый медленный из десяти — $pushed90); слияние за $merged ($merged90).';
  }

  @override
  String get analyticsQuestions => 'Вопросы';

  @override
  String get analyticsQuestionsSub => 'Что agnts спрашивал до начала кода и как быстро получал ответы';

  @override
  String get analyticsQuestionsAsked => 'Задано вопросов';

  @override
  String get analyticsQuestionsShare => 'Тикетов с вопросами';

  @override
  String get analyticsAnswerTypical => 'Типичное время ответа';

  @override
  String get analyticsAnswerSlow => 'Самый медленный из десяти';

  @override
  String get analyticsUnanswered => 'Ждут ответа сейчас';

  @override
  String get analyticsSlowest => 'Самые долгие тикеты';

  @override
  String get analyticsSlowestSub => 'Тикеты, дольше всего шедшие от взятия до отправки за период, и куда ушло их время';

  @override
  String get analyticsNoSlowest => 'За период не отправлено ни одного тикета.';

  @override
  String get analyticsKpiCiSeen => 'Падения CI';

  @override
  String analyticsKpiCiSeenNote(String n) {
    return '$n новых за период';
  }

  @override
  String get analyticsKpiCiAuto => 'Исправлено agnts';

  @override
  String analyticsKpiCiAutoNote(String auto, String fixed) {
    return '$auto из $fixed исправленных';
  }

  @override
  String get analyticsKpiCiFix => 'Время исправления';

  @override
  String get analyticsKpiCiFixNote => 'От первого падения до влитого исправления';

  @override
  String get analyticsKpiCiFlaky => 'Нестабильные падения';

  @override
  String get analyticsKpiCiFlakyNote => 'Прошли при перезапуске';

  @override
  String get analyticsKpiCiOwn => 'Свои PR исправлены';

  @override
  String get analyticsKpiCiOwnNote => 'Красные проверки в PR agnts исправлены до ревью';

  @override
  String get analyticsCiUnknown => 'Не классифицировано';

  @override
  String get analyticsCiNew => 'Новые падения';

  @override
  String get analyticsCiFixed => 'Исправлены';

  @override
  String get analyticsCiTitle => 'Состояние CI';

  @override
  String analyticsCiSub(String n) {
    return 'Новые и исправленные падения CI по дням. Требуют внимания сейчас: $n.';
  }

  @override
  String get analyticsCiOffSub =>
      'Наблюдение за CI не настроено. Включите его для репозитория, и agnts будет разбирать красные сборки и исправлять те, что вызваны кодом.';

  @override
  String get analyticsCiSetUp => 'Настроить наблюдение за CI';

  @override
  String get analyticsCiOpen => 'Открыть CI';

  @override
  String get analyticsCiClasses => 'Падения по причинам';

  @override
  String get analyticsCiClassesSub => 'К чему разбор отнёс каждое падение';

  @override
  String get analyticsCiNone => 'За период падений CI не было.';

  @override
  String get analyticsCiFlakiest => 'Самые нестабильные задачи';

  @override
  String get analyticsCiFlakiestSub => 'Задачи, которые чаще всего падали и проходили при перезапуске';

  @override
  String get analyticsCiNoFlaky => 'За период нестабильных задач не было.';

  @override
  String get analyticsColJob => 'Задача';

  @override
  String get analyticsColFailure => 'Падение';

  @override
  String get analyticsColFlaky => 'Прошли при перезапуске';

  @override
  String get analyticsColFailures => 'Падений';

  @override
  String get analyticsKpiLessons => 'Уроки';

  @override
  String analyticsKpiLessonsNote(String n) {
    return 'Изучено: $n';
  }

  @override
  String get analyticsKpiRulesLearned => 'Выученные правила';

  @override
  String analyticsKpiRulesLearnedNote(String n) {
    return 'Используются, из $n предложенных по тикетам';
  }

  @override
  String get analyticsKpiRulesManual => 'Написанные правила';

  @override
  String get analyticsKpiRulesManualNote => 'Добавлены людьми';

  @override
  String get analyticsKpiReflections => 'Разборы';

  @override
  String analyticsKpiReflectionsNote(String n) {
    return 'По изменённым и отклонённым тикетам; предложено правил: $n';
  }

  @override
  String get analyticsKpiFollowUps => 'Принятые доработки';

  @override
  String analyticsKpiFollowUpsNote(String n) {
    return 'Предложено за период: $n';
  }

  @override
  String get analyticsKpiReviewerNotes => 'Замечания ревьюеров';

  @override
  String get analyticsKpiReviewerNotesNote => 'Повторные ревью, отклонённые находки и заметки';

  @override
  String get analyticsLearningNote =>
      'Как agnts учится на ваших отзывах: если со временем замечаний меньше, а принятых правил больше — обучение работает.';

  @override
  String get analyticsFollowUps => 'Доработки по типам';

  @override
  String get analyticsFollowUpsSub => 'Тикеты-доработки, предложенные agnts за период, и ваши решения';

  @override
  String get analyticsNoFollowUps => 'За период доработок не предлагалось.';

  @override
  String get analyticsColType => 'Тип';

  @override
  String get analyticsColSuggested => 'Предложено';

  @override
  String get analyticsColAccepted => 'Принято';

  @override
  String get analyticsColDismissed => 'Отклонено';

  @override
  String get analyticsColOpen => 'Открыто';

  @override
  String get analyticsColAcceptRate => 'Доля принятых';

  @override
  String get analyticsFollowUpSources => 'Откуда доработки';

  @override
  String get analyticsFollowUpSourcesSub => 'Предложенные доработки по этапу, на котором их нашли';

  @override
  String get analyticsLessons => 'Уроки по темам';

  @override
  String analyticsLessonsSub(String n) {
    return 'Уроки, написанные за период; изучено: $n';
  }

  @override
  String get analyticsOpenLearn => 'Открыть «Обучение»';

  @override
  String get analyticsNoLessons => 'За период уроков нет.';

  @override
  String get analyticsReviewers => 'Ревьюеры';

  @override
  String get analyticsReviewersSub => 'Кто чаще всего даёт agnts отзывы на ревью кода';

  @override
  String get analyticsOpenRules => 'Открыть «Правила»';

  @override
  String get analyticsNoReviewers => 'За период замечаний ревьюеров нет.';

  @override
  String get analyticsColReviewer => 'Ревьюер';

  @override
  String get analyticsColRereview => 'Повторные ревью';

  @override
  String get analyticsColRereviewHint => 'Сколько раз ревьюер просил agnts посмотреть снова';

  @override
  String get analyticsColDismissedNotes => 'Отклонено';

  @override
  String get analyticsColDismissedNotesHint => 'Находки ревью agnts, которые ревьюер отклонил';

  @override
  String get analyticsColManual => 'Заметки';

  @override
  String get analyticsColManualHint => 'Заметки, написанные ревьюером вручную';

  @override
  String get analyticsColRepos => 'Репозитории';

  @override
  String get analyticsKpiCostNote => 'Все вызовы Claude за период';

  @override
  String analyticsKpiDaysAboveNote(String n) {
    return 'Дней выше 80% лимита сессии: $n';
  }

  @override
  String get analyticsColCost => 'Стоимость';

  @override
  String get analyticsColMergeRate => 'Доля слияний';

  @override
  String get analyticsColMergeRateHint => 'Влитые пул-реквесты среди влитых или закрытых за период';

  @override
  String get analyticsColQuestions => 'Вопросов на тикет';

  @override
  String get analyticsColQuestionsHint =>
      'Вопросы agnts на один проанализированный тикет. Много вопросов — признак отсутствия CLAUDE.md или правил.';

  @override
  String get analyticsColCi => 'Падения CI';

  @override
  String get analyticsColCiHint => 'Группы падений CI за период';

  @override
  String get analyticsTabAssistant => 'Ассистент';

  @override
  String get appName => 'agnts';

  @override
  String get appTagline => 'Ваш агент, который не спит';

  @override
  String get authTitle => 'Вход';

  @override
  String get authLede => 'Войдите по почте или имени пользователя и паролю.';

  @override
  String get authUsername => 'Почта или имя пользователя';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authCode => 'Код аутентификатора';

  @override
  String get authCodeHint => '6 цифр из приложения-аутентификатора';

  @override
  String get authSubmit => 'Войти';

  @override
  String get authSubmitting => 'Вход…';

  @override
  String get authSignOut => 'Выйти';

  @override
  String get authSignOutTitle => 'Выйти из аккаунта?';

  @override
  String get authSignOutBody => 'Чтобы войти снова, понадобятся пароль и код из приложения-аутентификатора.';

  @override
  String get authWrongCredentials => 'Неверное имя пользователя, пароль или код.';

  @override
  String authRateLimited(num seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds секунды',
      many: '$seconds секунд',
      few: '$seconds секунды',
      one: '$seconds секунду',
    );
    return 'Слишком много попыток. Повторите через $_temp0.';
  }

  @override
  String get authCodeLede => 'Введите код из приложения-аутентификатора.';

  @override
  String get authBack => 'Другой аккаунт';

  @override
  String get authOr => 'или';

  @override
  String get authGoogleRedirecting => 'Выполняем вход…';

  @override
  String get authGoogleUnavailable => 'Не удалось загрузить вход через Google. Проверьте соединение или блокировщик рекламы.';

  @override
  String get authGoogleFailed => 'Вход через Google не удался. Попробуйте ещё раз.';

  @override
  String get authGoogleClosed =>
      'На этом сервере регистрация только по приглашению: попросите у владельца пространства ссылку-приглашение.';

  @override
  String get authGoogleRateLimited => 'Слишком много попыток. Подождите минуту и попробуйте снова.';

  @override
  String get authGoogleError => 'Не удалось войти через Google. Попробуйте чуть позже.';

  @override
  String get authUseGoogle => 'Пароли здесь только для администраторов. Войдите через Google.';

  @override
  String get authAdminsLede => 'Администраторы входят по паролю. Все остальные — через Google.';

  @override
  String get authGoogleInvite =>
      'Ссылка-приглашение недействительна, уже использована, истекла или предназначена для другого аккаунта Google.';

  @override
  String get authGoogleAdmin => 'Это аккаунт администратора: администраторы входят по логину и паролю.';

  @override
  String get authSetupLede =>
      'Администраторы входят с двухфакторной защитой. Отсканируйте код в приложении-аутентификаторе (Google Authenticator, 1Password, Authy) и введите 6-значный код из него.';

  @override
  String get authSignOutBodyGoogle => 'Вы сможете снова войти в любой момент через Google.';

  @override
  String get billingTitle => 'Оплата';

  @override
  String get billingSelfHosted =>
      'Этот сервер развёрнут самостоятельно: платить не нужно. Число одновременных запусков задаётся ниже, лимит участников — администратором.';

  @override
  String get billingPlan => 'Тариф';

  @override
  String billingPlanSub(String members) {
    return 'Базовый тариф включает 1 параллельный запуск и $members участников.';
  }

  @override
  String billingMonthly(String amount) {
    return '$amount в месяц';
  }

  @override
  String billingPaidUntil(String date) {
    return 'Оплачено до $date';
  }

  @override
  String billingTrialUntil(String date) {
    return 'Бесплатный период до $date';
  }

  @override
  String get billingSlots => 'Параллельные запуски';

  @override
  String billingSlotsHelp(String price) {
    return 'Каждый дополнительный одновременный запуск стоит $price в месяц. При добавлении остаток месяца списывается из кредитов.';
  }

  @override
  String billingSlotsHelpSelfHosted(String max) {
    return 'Сколько запусков у рабочего пространства одновременно; на этом сервере бесплатно. До $max; предел задаёт AGNTS_MAX_SLOTS на сервере.';
  }

  @override
  String get billingSlotsSave => 'Изменить';

  @override
  String billingSlotsSaved(String n) {
    return 'Параллельных запусков: $n';
  }

  @override
  String get billingMembers => 'Участники';

  @override
  String billingMembersHelp(String included, String price) {
    return 'Включено: $included; каждый следующий стоит $price в месяц.';
  }

  @override
  String get billingCredits => 'Кредиты';

  @override
  String get billingCreditsSub =>
      'Запуски на API-ключе agnts (резервный вариант) тратят кредиты: 1 кредит — это \$0,01 стоимости API Anthropic. Ежемесячный тариф тоже оплачивается из них.';

  @override
  String get billingBalance => 'Баланс';

  @override
  String billingCreditPrice(String price) {
    return '1 кредит = $price';
  }

  @override
  String get billingBuy => 'Купить кредиты';

  @override
  String get billingAmount => 'Сумма (сум)';

  @override
  String billingYouGet(String n) {
    return '≈ $n кредитов';
  }

  @override
  String billingPayWith(String provider) {
    return 'Оплатить через $provider';
  }

  @override
  String get billingPaymentsOff => 'Оплата на этом сервере ещё не настроена; попросите администратора начислить кредиты.';

  @override
  String get billingHistory => 'История';

  @override
  String get billingNoHistory => 'Пока ничего.';

  @override
  String get billingReason_purchase => 'Покупка';

  @override
  String get billingReason_run => 'Списание';

  @override
  String get billingReason_refund => 'Возврат';

  @override
  String get billingReason_grant => 'Начисление';

  @override
  String get briefTitle => 'Описание репозитория';

  @override
  String get briefSub =>
      'Как устроен этот код: архитектура, рецепты типичных изменений, файлы-образцы, соглашения и подводные камни. Каждый запуск по тикетам этого репозитория читает его, чтобы agnts делал всё так, как принято в вашей команде.';

  @override
  String get briefSurvey => 'Изучить';

  @override
  String get briefUpdate => 'Обновить';

  @override
  String get briefEdit => 'Изменить';

  @override
  String get briefWrite => 'Написать самому';

  @override
  String get briefSave => 'Сохранить описание';

  @override
  String get briefCancel => 'Отмена';

  @override
  String get briefEditHint =>
      'Markdown. Сохранённый текст сразу начнут читать запуски; оставьте пустым, чтобы запуски не получали описание.';

  @override
  String get briefNone => 'Описания пока нет. Запустите изучение, чтобы Claude написал черновик, или напишите его сами.';

  @override
  String get briefSurveying => 'Claude изучает репозиторий. Черновик появится здесь для вашего одобрения.';

  @override
  String briefFailed(String error) {
    return 'Последнее изучение не удалось: $error';
  }

  @override
  String briefApproved(String time) {
    return 'Одобрено $time';
  }

  @override
  String briefAtCommit(String sha) {
    return 'на коммите $sha';
  }

  @override
  String briefMerges(String n, String of) {
    return '$n из $of слияний до следующего обновления';
  }

  @override
  String get briefDraftTitle => 'Черновик после изучения';

  @override
  String briefDraftSub(String time) {
    return 'Написан $time. Запуски получат его только после вашего одобрения.';
  }

  @override
  String get briefApprove => 'Одобрить';

  @override
  String get briefDiscard => 'Удалить черновик';

  @override
  String get briefDiscardBody => 'Черновик будет удалён; одобренное описание останется как есть.';

  @override
  String get briefStatus_pending => 'Изучение в очереди';

  @override
  String get briefStatus_surveying => 'Изучение…';

  @override
  String get briefDone_survey => 'Изучение поставлено в очередь';

  @override
  String get briefDone_approve => 'Описание одобрено: новые запуски его читают';

  @override
  String get briefDone_discard => 'Черновик удалён';

  @override
  String get briefDone_save => 'Описание сохранено';

  @override
  String get ciTitle => 'CI';

  @override
  String get ciLede =>
      'Падающие пайплайны на отслеживаемых ветках, сгруппированные по джобу и ошибке. agnts один раз перезапускает новые падения, а настоящие исправляет.';

  @override
  String get ciBack => 'CI';

  @override
  String get ciRepo => 'Репозиторий';

  @override
  String get ciAllRepos => 'Все репозитории';

  @override
  String get ciFilterLabel => 'Статус';

  @override
  String get ciFilter_red => 'Красные';

  @override
  String get ciFilter_flaky => 'Нестабильные';

  @override
  String get ciFilter_infra => 'Инфраструктура';

  @override
  String get ciFilter_fixed => 'Исправленные';

  @override
  String get ciFilter_muted => 'Скрытые';

  @override
  String get ciFilter_all => 'Все';

  @override
  String get ciStatus_triage => 'Новое';

  @override
  String get ciStatus_open => 'Падает';

  @override
  String get ciStatus_fixing => 'Исправляется';

  @override
  String get ciStatus_fixed => 'Фикс влит';

  @override
  String get ciStatus_resolved => 'Снова зелёное';

  @override
  String get ciStatus_flaky => 'Нестабильное';

  @override
  String get ciStatus_infra => 'Инфраструктура';

  @override
  String get ciStatus_muted => 'Скрыто';

  @override
  String get ciStatus_regression => 'Регрессия';

  @override
  String get ciStatusHelp_triage => 'Новое падение, ждёт перезапуска для подтверждения';

  @override
  String get ciStatusHelp_open => 'Подтверждено, тикет над ним не работает';

  @override
  String get ciStatusHelp_fixing => 'Над ним работает тикет';

  @override
  String get ciStatusHelp_fixed => 'Исправление влито, ждём зелёного запуска';

  @override
  String get ciStatusHelp_resolved => 'Ветка снова зелёная';

  @override
  String get ciStatusHelp_flaky => 'Прошло при перезапуске';

  @override
  String get ciStatusHelp_infra => 'Упал раннер или сеть, а не код';

  @override
  String get ciStatusHelp_muted => 'Игнорируется, пока не вернёте';

  @override
  String get ciStatusHelp_regression => 'Снова упало после влития исправления';

  @override
  String get ciClass_code => 'Код';

  @override
  String get ciClass_test => 'Тест';

  @override
  String get ciClass_config => 'Конфигурация';

  @override
  String get ciClass_dependency => 'Зависимость';

  @override
  String get ciClass_infra => 'Инфраструктура';

  @override
  String get ciClass_flaky => 'Нестабильное';

  @override
  String get ciClass_report => 'Отчёт';

  @override
  String get ciColStatus => 'Статус';

  @override
  String get ciColFailure => 'Падение';

  @override
  String get ciColCount => 'Падало';

  @override
  String get ciColLastSeen => 'Последний раз';

  @override
  String get ciColTicket => 'Тикет';

  @override
  String get ciColTime => 'Время';

  @override
  String get ciColCommit => 'Коммит';

  @override
  String get ciColJob => 'Джоб';

  @override
  String ciTimes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раза', many: '$n раз', few: '$n раза', one: '$n раз');
    return '$_temp0';
  }

  @override
  String get ciFix => 'Исправить';

  @override
  String ciFixStarted(String key) {
    return 'Открыт тикет $key';
  }

  @override
  String get ciMute => 'Скрыть';

  @override
  String get ciUnmute => 'Вернуть';

  @override
  String get ciMuted => 'Скрыто: теперь agnts игнорирует это падение';

  @override
  String get ciUnmuted => 'Возвращено';

  @override
  String get ciRerun => 'Перезапустить';

  @override
  String get ciRerunStarted => 'Перезапуск начат';

  @override
  String get ciCommentOnly => 'Только комментарий';

  @override
  String get ciEmptyRed => 'Ничего не горит красным. Все отслеживаемые ветки проходят.';

  @override
  String get ciEmptyFilter => 'Здесь падений нет.';

  @override
  String get ciHowTitle => 'Как начать отслеживать';

  @override
  String get ciHowWatch =>
      'Откройте репозиторий, перейдите на вкладку CI и включите отслеживание. Ветка по умолчанию отслеживается всегда; добавьте другие, например release/*.';

  @override
  String get ciHowWebhook =>
      'Чтобы узнавать о падениях за секунды, добавьте вебхук git-хостинга на события workflow_run (GitHub) или Pipeline events (GitLab). Без него agnts проверяет каждые 5 минут.';

  @override
  String get ciNotFound => 'Это падение CI не найдено.';

  @override
  String ciOpenTicket(String key) {
    return 'Открыть $key';
  }

  @override
  String ciPrNote(String n) {
    return 'Это падение в чужом пул-реквесте #$n. agnts никогда не открывает тикет и не пушит туда; при включённых комментариях он оставляет один комментарий с диагнозом.';
  }

  @override
  String ciRegressionNote(String sha) {
    return 'Снова упало на коммите, который содержит исправление $sha. Исходный тикет получит предложение о доработке.';
  }

  @override
  String get ciLogTitle => 'Лог';

  @override
  String get ciLogSub => 'Очищенный фрагмент последнего упавшего запуска';

  @override
  String get ciLogAnnotations => 'Аннотации';

  @override
  String get ciLogFirstError => 'Первая ошибка';

  @override
  String get ciLogEnd => 'Конец лога';

  @override
  String get ciLogTail => 'Последние строки';

  @override
  String get ciNoLog => 'Для этого падения лог не сохранён.';

  @override
  String get ciOccurrences => 'Упавшие запуски';

  @override
  String get ciOccurrencesSub => 'Последние 20 запусков с этим падением';

  @override
  String get ciNoOccurrences => 'Запусков не записано.';

  @override
  String get ciPassedOnRerun => 'Прошло при перезапуске';

  @override
  String get ciOpenRun => 'Открыть запуск';

  @override
  String get ciFacts => 'Подробности';

  @override
  String get ciCount => 'Падало';

  @override
  String get ciFlakyCount => 'Прошло при перезапуске';

  @override
  String get ciFirstSeen => 'Впервые';

  @override
  String get ciLastSeen => 'Последний раз';

  @override
  String get ciFirstSha => 'Первый упавший коммит';

  @override
  String get ciLastSha => 'Последний коммит';

  @override
  String get ciFixedSha => 'Коммит исправления';

  @override
  String get ciFixedAt => 'Исправление влито';

  @override
  String get ciTicket => 'Тикет';

  @override
  String get ciBranch => 'Ветка';

  @override
  String get ciWatchTitle => 'Отслеживание CI';

  @override
  String get ciWatchSub => 'agnts читает пайплайны этого репозитория и исправляет то, что падает';

  @override
  String get ciWatchEnabled => 'Отслеживать CI';

  @override
  String get ciWatchEnabledHelp => 'По умолчанию выключено. Падения на отслеживаемых ветках группируются и исправляются.';

  @override
  String get ciBranches => 'Дополнительные ветки';

  @override
  String ciBranchesHelp(String branch) {
    return 'Шаблоны, по одному на строку. Ветка по умолчанию ($branch) отслеживается всегда.';
  }

  @override
  String get ciIgnore => 'Игнорируемые воркфлоу и джобы';

  @override
  String get ciIgnoreHelp =>
      'Шаблоны, по одному на строку, сверяются с именами воркфлоу и джобов. Если пусто — *deploy*, *release* и *publish*.';

  @override
  String get ciPrs => 'Чужие пул-реквесты';

  @override
  String get ciPrsHelp =>
      'agnts никогда не пушит в ветку коллеги. При включённых комментариях он оставляет в пул-реквесте один комментарий с диагнозом.';

  @override
  String get ciPrs_off => 'Игнорировать';

  @override
  String get ciPrs_comment => 'Комментировать';

  @override
  String get ciAutoFix => 'Исправлять автоматически';

  @override
  String get ciAutoFixRepoHelp => 'Открывать тикет на каждое подтверждённое падение или ждать кнопки «Исправить»';

  @override
  String get ciAutoFix_inherit => 'Как в пространстве';

  @override
  String get ciAutoFix_on => 'Вкл.';

  @override
  String get ciAutoFix_off => 'Выкл.';

  @override
  String get ciSave => 'Сохранить';

  @override
  String get ciWatchSaved => 'Отслеживание CI сохранено';

  @override
  String get ciFailuresTitle => 'Падения';

  @override
  String get ciFailuresSub => 'Падающие джобы этого репозитория, сначала новые';

  @override
  String get ciFlakyTitle => 'Нестабильные тесты';

  @override
  String get ciFlakySub => 'Падения, которые прошли при перезапуске';

  @override
  String get ciFlakyEmpty => 'Нестабильных тестов не найдено.';

  @override
  String get ciCardTitle => 'Падение CI';

  @override
  String get ciFailingRuns => 'Упавших запусков';

  @override
  String get ciLastRun => 'Последний упавший запуск';

  @override
  String get ciStillFailing => 'Всё ещё падает';

  @override
  String get ciWaitingGreen => 'Исправление влито, ждём зелёного запуска';

  @override
  String get ciGreenAgain => 'Снова зелёное';

  @override
  String get ciOpenFailure => 'Открыть падение';

  @override
  String get ciSettingsTitle => 'CI';

  @override
  String get ciSettingsSub => 'Что делает agnts, когда отслеживаемый пайплайн краснеет. Отслеживание включается для каждого репозитория.';

  @override
  String get ciAutoFixHelp => 'Открывать тикет на каждое подтверждённое падение. Если выключено, падения ждут кнопки «Исправить».';

  @override
  String get ciMaxAutoPerDay => 'Автоматических тикетов в день';

  @override
  String get ciMaxAutoPerDayHelp => 'Сверх лимита падения ждут кнопки «Исправить». Доработки собственных пул-реквестов agnts не считаются.';

  @override
  String ciPerDay(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n в день',
      many: '$n в день',
      few: '$n в день',
      one: '$n в день',
      zero: 'Ни одного',
    );
    return '$_temp0';
  }

  @override
  String get ciRetryFlaky => 'Перезапускать новые падения один раз';

  @override
  String get ciRetryFlakyHelp =>
      'Джобы нового падения запускаются ещё раз, прежде чем agnts в него поверит. Если проходят — падение помечается нестабильным.';

  @override
  String get ciFeedbackRounds => 'Доработки пул-реквестов agnts';

  @override
  String get ciFeedbackRoundsHelp => 'Сколько раз красная проверка возвращает собственный пул-реквест agnts в работу. 0 — выключено.';

  @override
  String get ciInfraPatterns => 'Шаблоны инфраструктуры';

  @override
  String get ciInfraPatternsHelp =>
      'Регулярные выражения, по одному на строку. Совпавший лог считается падением инфраструктуры: показывается и учитывается, но тикет не открывается. Добавляются к встроенным.';

  @override
  String get commitBack => 'Назад к коммитам';

  @override
  String commitBackTo(String repo) {
    return 'Назад к $repo';
  }

  @override
  String commitAuthoredAgo(String name, String time) {
    return '$name закоммитил(а) $time';
  }

  @override
  String commitFilesN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n файла', many: '$n файлов', few: '$n файла', one: '$n файл');
    return '$_temp0';
  }

  @override
  String get commitAuthor => 'Автор';

  @override
  String get commitAuthored => 'Создан';

  @override
  String get commitCommitter => 'Закоммитил(а)';

  @override
  String get commitCommitted => 'Закоммичен';

  @override
  String commitParents(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Родители', one: 'Родитель');
    return '$_temp0';
  }

  @override
  String get commitPulls => 'Pull request’ы';

  @override
  String get commitPullsSub => 'Pull request’ы (merge request’ы в GitLab), в которых есть этот коммит.';

  @override
  String get commitNoPulls => 'Этого коммита нет ни в одном pull request’е.';

  @override
  String get commitMessage => 'Сообщение';

  @override
  String get commitPipelinesSub => 'CI-запуски на этом коммите, новые сверху.';

  @override
  String get commitNoPipelines => 'На этом коммите не было CI-запусков.';

  @override
  String get commitChanges => 'Изменения';

  @override
  String commitChangesSub(num n, String add, String del) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Изменено $n файла',
      many: 'Изменено $n файлов',
      few: 'Изменено $n файла',
      one: 'Изменён $n файл',
    );
    return '$_temp0: +$add, −$del.';
  }

  @override
  String get commitNoFiles => 'Этот коммит не меняет файлов.';

  @override
  String commitFilesCapped(String n) {
    return 'Коммит меняет больше файлов, чем можно показать здесь. Показаны первые $n; остальные — на git-хостинге.';
  }

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonError => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String commonSignedInAs(String username) {
    return 'Вы вошли как $username';
  }

  @override
  String commonVersion(String version) {
    return 'Версия $version';
  }

  @override
  String dashboardGreetNight(String name) {
    return 'Доброй ночи, $name';
  }

  @override
  String dashboardGreetMorning(String name) {
    return 'Доброе утро, $name';
  }

  @override
  String dashboardGreetAfternoon(String name) {
    return 'Добрый день, $name';
  }

  @override
  String dashboardGreetEvening(String name) {
    return 'Добрый вечер, $name';
  }

  @override
  String dashboardLede(String date) {
    return '$date. Вот что делает agnts и что ждёт вас.';
  }

  @override
  String get dashboardOpenAnalytics => 'Открыть аналитику';

  @override
  String get dashboardNeedsYou => 'Ждёт вас';

  @override
  String dashboardNeedsNote(String answers, String reviews, String stopped) {
    return 'ответов: $answers, ревью: $reviews, остановлено: $stopped';
  }

  @override
  String get dashboardRunningNow => 'Сейчас в работе';

  @override
  String dashboardRunningNote(String n) {
    return 'одновременно: $n';
  }

  @override
  String get dashboardPushedWeek => 'Отправлено за неделю';

  @override
  String dashboardPushedNote(String n) {
    return 'на прошлой неделе: $n';
  }

  @override
  String get dashboardPlanSession => 'Сессия тарифа';

  @override
  String get dashboardWaitingTitle => 'Ожидание вас';

  @override
  String get dashboardWaitingSub => 'Сначала самые старые. Каждая минута здесь — минута, когда agnts не может работать.';

  @override
  String get dashboardOpenInbox => 'Открыть входящие';

  @override
  String get dashboardNothingWaiting => 'Сейчас ничего не ждёт вас. agnts покажет здесь тикеты, когда понадобятся ответы или ревью.';

  @override
  String get dashboardColTicket => 'Тикет';

  @override
  String get dashboardColStatus => 'Статус';

  @override
  String get dashboardColWaiting => 'Ждёт';

  @override
  String get dashboardActAnswer => 'Ответить';

  @override
  String get dashboardActReview => 'Ревью';

  @override
  String get dashboardActRetry => 'Повторить';

  @override
  String get dashboardActResume => 'Продолжить';

  @override
  String get dashboardUsageTitle => 'Лимиты тарифа';

  @override
  String dashboardUpdated(String time) {
    return 'Обновлено $time';
  }

  @override
  String get dashboardNotUpdated => 'Данных пока нет';

  @override
  String get dashboardSession => 'Текущая сессия';

  @override
  String get dashboardWeek => 'Эта неделя';

  @override
  String get dashboardPaused => 'Новые запуски на паузе до сброса лимита.';

  @override
  String get dashboardLiveTitle => 'Активные запуски';

  @override
  String get dashboardLiveSub => 'Тикеты в контейнерах прямо сейчас';

  @override
  String get dashboardNoRuns => 'Сейчас запусков нет.';

  @override
  String dashboardTurns(String n, String max) {
    return '$n / $max шагов';
  }

  @override
  String get dashboardPipelineTitle => 'Конвейер';

  @override
  String get dashboardPipelineSub => 'Открытые тикеты по шагам';

  @override
  String get dashboardPipeQueue => 'В очереди';

  @override
  String get dashboardPipeAnalyze => 'Анализ';

  @override
  String get dashboardPipeAnswers => 'Ваши ответы';

  @override
  String get dashboardPipeCoding => 'Разработка';

  @override
  String get dashboardPipeReview => 'Ваше ревью';

  @override
  String get dashboardPipeStopped => 'Остановлено';

  @override
  String get dashboardTodayTitle => 'Сегодня по часам';

  @override
  String get dashboardTodaySub => 'События за сегодня. agnts работает, даже когда вы спите.';

  @override
  String get dashboardTodayAria => 'События сегодня по часам';

  @override
  String get dashboardLegendAgnts => 'agnts работает';

  @override
  String get dashboardLegendYou => 'Ваши действия';

  @override
  String get dashboardLegendProblems => 'Предупреждения и ошибки';

  @override
  String get dashboardWeekTitle => 'Эта неделя';

  @override
  String get dashboardWeekSub => 'По сравнению с прошлой неделей';

  @override
  String get dashboardPicked => 'Взято тикетов';

  @override
  String get dashboardFirstTry => 'Одобрено с первого раза';

  @override
  String get dashboardAvgTurns => 'Среднее число шагов';

  @override
  String get dashboardAvgWait => 'Ожидание вас, в среднем';

  @override
  String get dashboardStoppedRuns => 'Остановленные запуски';

  @override
  String get dashboardReposTitle => 'Репозитории';

  @override
  String get dashboardReposSub => 'Открытая работа и последний тикет в каждом';

  @override
  String get dashboardAllRepos => 'Все репозитории';

  @override
  String get dashboardColRepo => 'Репозиторий';

  @override
  String get dashboardColOpen => 'Открыто';

  @override
  String get dashboardColLatest => 'Последний тикет';

  @override
  String get dashboardColClaudeMd => 'CLAUDE.md';

  @override
  String get dashboardFound => 'Есть';

  @override
  String get dashboardMissing => 'Нет';

  @override
  String get dashboardUnknown => 'Неизвестно';

  @override
  String get dashboardNoRepos => 'Нет репозиториев с открытой работой.';

  @override
  String get dashboardRecentTitle => 'Последние события';

  @override
  String get dashboardLogs => 'Логи';

  @override
  String get dashboardNoActivity => 'Пока ничего не произошло.';

  @override
  String get designApproach => 'Подход';

  @override
  String get designFit => 'Соответствие коду';

  @override
  String designAlternatives(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Рассмотрено $n альтернативы',
      many: 'Рассмотрено $n альтернатив',
      few: 'Рассмотрены $n альтернативы',
      one: 'Рассмотрена $n альтернатива',
    );
    return '$_temp0';
  }

  @override
  String get designWhyNot => 'Почему нет';

  @override
  String get designOutOfScope => 'Вне рамок задачи';

  @override
  String get designShipping => 'Выкатка';

  @override
  String get designShip_migrations => 'Миграции';

  @override
  String get designShip_compatibility => 'Совместимость';

  @override
  String get designShip_rollout => 'Порядок выкатки';

  @override
  String get designShip_rollback => 'Откат';

  @override
  String get designDeviations => 'Отступления от плана';

  @override
  String get draftsTitle => 'Комментарии ревью';

  @override
  String draftsSub(String host) {
    return 'Комментарии agnts остаются здесь, пока вы их не примете. На $host публикуются только принятые, одним ревью; остальные никогда не покидают agnts.';
  }

  @override
  String get draftsLockedSub => 'Ревью завершено или пул-реквест закрыт: эти комментарии можно только читать.';

  @override
  String get draftsChip => 'Черновик';

  @override
  String get draftsSummary => 'Итог';

  @override
  String get draftsSomeone => 'Кто-то';

  @override
  String get draftsEdited => 'изменён';

  @override
  String get draftsState_draft => 'Черновик';

  @override
  String get draftsState_accepted => 'Принят';

  @override
  String get draftsState_publishing => 'Публикуется';

  @override
  String get draftsState_dismissed => 'Отклонён';

  @override
  String get draftsState_published => 'Опубликован';

  @override
  String get draftsState_outdated => 'Устарел';

  @override
  String get draftsKind_summary => 'итог';

  @override
  String get draftsKind_finding => 'замечание';

  @override
  String get draftsKind_comment => 'комментарий';

  @override
  String get draftsAccept => 'Принять';

  @override
  String get draftsUndo => 'Отменить';

  @override
  String get draftsDismiss => 'Отклонить';

  @override
  String get draftsReopen => 'Вернуть в черновики';

  @override
  String get draftsReasonLabel => 'Почему? (необязательно: agnts учится, что вы считаете шумом)';

  @override
  String get draftsReasonHint => 'например, в этом сервисе мы не ограничиваем кэши';

  @override
  String draftsDismissedBecause(String reason) {
    return 'Отклонён: $reason';
  }

  @override
  String get draftsOutdatedHint => 'Новое ревью agnts этого больше не находит.';

  @override
  String draftsFailed(String error) {
    return 'Не удалось опубликовать: $error';
  }

  @override
  String get draftsDeleteTitle => 'Удалить ваш комментарий?';

  @override
  String get draftsDeleteConfirm => 'Он не был опубликован; он удаляется из agnts.';

  @override
  String draftsNAccepted(String n) {
    return 'принято: $n';
  }

  @override
  String draftsNDraft(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n черновика',
      many: '$n черновиков',
      few: '$n черновика',
      one: '$n черновик',
    );
    return '$_temp0';
  }

  @override
  String draftsNDismissed(String n) {
    return 'отклонено: $n';
  }

  @override
  String draftsNPublished(String n) {
    return 'опубликовано: $n';
  }

  @override
  String draftsNOutdated(String n) {
    return 'устарело: $n';
  }

  @override
  String get draftsAcceptMajor => 'Принять major и выше';

  @override
  String get draftsAcceptAll => 'Принять все';

  @override
  String draftsPublishBtn(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Опубликовать $n', zero: 'Опубликовать');
    return '$_temp0 на $host';
  }

  @override
  String draftsPublishTitle(String host) {
    return 'Публикация на $host';
  }

  @override
  String draftsPublishSub(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Эти $n комментария будут опубликованы',
      many: 'Эти $n комментариев будут опубликованы',
      few: 'Эти $n комментария будут опубликованы',
      one: 'Этот комментарий будет опубликован',
    );
    return '$_temp0 в пул-реквесте одним ревью от имени пользователя токена $host. Комментарии не на изменённых строках попадут в текст ревью.';
  }

  @override
  String draftsPublishedToast(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Опубликовано $n комментария',
      many: 'Опубликовано $n комментариев',
      few: 'Опубликовано $n комментария',
      one: 'Опубликован $n комментарий',
    );
    return '$_temp0 на $host';
  }

  @override
  String draftsHeadMoved(String from, String to, String host) {
    return 'После ревью agnts появились новые коммиты ($from, сейчас $to): комментарии попадут на версию, которую проверял agnts, и $host может показать их как устаревшие. Чтобы они были на новых строках, сначала запустите ревью заново.';
  }

  @override
  String draftsShowClosed(String n) {
    return 'Показать отклонённые, устаревшие и опубликованные ($n)';
  }

  @override
  String draftsDraftsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n черновика',
      many: '$n черновиков',
      few: '$n черновика',
      one: '$n черновик',
    );
    return '$_temp0';
  }

  @override
  String get draftsNotOnDiff => 'Комментарии agnts не на показанных строках (другая версия или вне диффа):';

  @override
  String get draftsAddToReview => 'Добавить в ревью';

  @override
  String get draftsAddedToast => 'Добавлено в ревью: будет опубликовано вместе с принятыми комментариями';

  @override
  String get draftsOnDiff => 'Посмотреть их в диффе';

  @override
  String get draftsReviewWithBtn => 'Ревью с agnts';

  @override
  String get draftsReviewAgainBtn => 'Новое ревью с agnts';

  @override
  String draftsReviewTitle(String number) {
    return 'Ревью #$number с agnts';
  }

  @override
  String get draftsReviewSub =>
      'agnts проверит пул-реквест за вас. Его комментарии остаются черновиками в agnts, пока вы их не примете; в пул-реквест попадают только принятые. Завершение ревью никогда его не мёржит.';

  @override
  String get draftsReviewBtn => 'Начать ревью';

  @override
  String get draftsFocusLabel => 'На что обратить особое внимание? (необязательно)';

  @override
  String get draftsFocusHint => 'например, миграция и логика повторов';

  @override
  String get draftsDeepLabel => 'Глубокое ревью (проходы по безопасности, ошибкам, тестам и типам)';

  @override
  String get draftsDeep_default => 'Настройка воркспейса';

  @override
  String get draftsDeep_always => 'Вкл.';

  @override
  String get draftsDeep_off => 'Выкл.';

  @override
  String draftsStartedToast(String key) {
    return 'agnts проверяет его в $key';
  }

  @override
  String draftsReviewingNow(String key) {
    return 'agnts проверяет этот пул-реквест ($key). Когда закончит, его комментарии появятся здесь как черновики.';
  }

  @override
  String get draftsFinishBtn => 'Завершить ревью';

  @override
  String draftsFinishConfirm(String number) {
    return 'Завершить ревью #$number? Неопубликованные комментарии останутся в agnts. Пул-реквест остаётся как есть: agnts его не мёржит.';
  }

  @override
  String draftsReadySub(String host) {
    return 'Просмотрите комментарии agnts, опубликуйте на $host те, с которыми согласны, и завершите ревью. Или запросите новое ревью с заметкой, или отклоните его.';
  }

  @override
  String get draftsFinishedTitle => 'Ревью завершено';

  @override
  String draftsFinishedSub(String number) {
    return 'Ревью #$number завершено. Пул-реквест оставлен как есть.';
  }

  @override
  String get feedbackTitle => 'Отправить отзыв';

  @override
  String get feedbackLede => 'Расскажите команде agnts, что работает, что нет и чего вы ждёте дальше.';

  @override
  String get feedbackTitleLabel => 'Заголовок';

  @override
  String get feedbackTitlePlaceholder => 'В нескольких словах';

  @override
  String get feedbackDescLabel => 'Описание';

  @override
  String get feedbackDescPlaceholder => 'Что произошло, чего вы ожидали, или ваша идея';

  @override
  String get feedbackSend => 'Отправить';

  @override
  String get feedbackSent => 'Спасибо! Ваш отзыв отправлен.';

  @override
  String get feedbackAdminTitle => 'Отзывы';

  @override
  String get feedbackAdminLede =>
      'Что люди отправили из своих аккаунтов и запросы коннекторов с сайта, сначала новые. Отметьте каждый как готовый, когда разберётесь.';

  @override
  String get feedbackF_new => 'Новые';

  @override
  String get feedbackF_done => 'Выполненные';

  @override
  String get feedbackF_all => 'Все';

  @override
  String get feedbackS_new => 'Новый';

  @override
  String get feedbackS_done => 'Выполнен';

  @override
  String get feedbackSearch => 'Поиск по отзывам, людям и пространствам';

  @override
  String get feedbackNone => 'Отзывов нет.';

  @override
  String get feedbackNoneNew => 'Новых отзывов нет. Отлично!';

  @override
  String feedbackFrom(String workspace) {
    return 'из $workspace';
  }

  @override
  String get feedbackAccountGone => 'аккаунт удалён';

  @override
  String get feedbackMarkDone => 'Отметить выполненным';

  @override
  String get feedbackReopen => 'Открыть снова';

  @override
  String get feedbackMarkedDone => 'Отмечен выполненным';

  @override
  String get feedbackReopened => 'Снова отмечен как новый';

  @override
  String get feedbackKind => 'Тип';

  @override
  String get feedbackK_any => 'Всё';

  @override
  String get feedbackK_feedback => 'Отзывы';

  @override
  String get feedbackK_connector => 'Запросы коннекторов';

  @override
  String get feedbackConnectorBadge => 'Запрос коннектора';

  @override
  String get feedbackFromSite => 'с сайта';

  @override
  String get filesTitle => 'Вложения';

  @override
  String get filesAttach => 'Прикрепить файлы';

  @override
  String get filesAddPhoto => 'Фото';

  @override
  String get filesCamera => 'Камера';

  @override
  String get filesAddFile => 'Файл';

  @override
  String get filesHint => 'Картинки, PDF, логи или текст, до 10 МБ каждый. Claude прочитает их все.';

  @override
  String filesUploading(String name) {
    return 'Загрузка $name…';
  }

  @override
  String filesRemove(String name) {
    return 'Убрать $name';
  }

  @override
  String filesOpen(String name) {
    return 'Открыть $name';
  }

  @override
  String filesTooLarge(String name) {
    return '$name больше 10 МБ';
  }

  @override
  String filesTooMany(String n) {
    return 'Не больше $n файлов';
  }

  @override
  String filesFailed(String name) {
    return 'Не удалось загрузить $name';
  }

  @override
  String get filesWait => 'Дождитесь окончания загрузки';

  @override
  String get filesFromTask => 'К задаче';

  @override
  String get filesFromRetry => 'К повтору';

  @override
  String get filesFromFeedback => 'К запрошенным изменениям';

  @override
  String get followUpsTitle => 'Последующие тикеты';

  @override
  String get followUpsSub =>
      'Что, по мнению agnts, ещё нужно, чтобы довести этот тикет до конца. Выберите нужные и запустите их сразу или оставьте на удержании, пока не запустите каждый.';

  @override
  String get followUpsMode => 'Предложения последующих тикетов';

  @override
  String get followUpsModeInherit => 'Как в настройках';

  @override
  String get followUpsModeOn => 'Вкл.';

  @override
  String get followUpsModeOff => 'Выкл.';

  @override
  String get followUpsModeHint =>
      'Если включено, запуски agnts предлагают тикеты, которые ещё нужны этому. Каждый промпт становится немного длиннее.';

  @override
  String get followUpsOffEmpty =>
      'Предложения выключены для этого тикета. Включите их, и следующий запуск предложит, что ещё нужно для его завершения.';

  @override
  String get followUpsOnEmpty => 'Пока ничего не предложено. Большинству тикетов продолжение не нужно.';

  @override
  String get followUpsType_prerequisite => 'Предусловие';

  @override
  String get followUpsType_split => 'Выделить отдельно';

  @override
  String get followUpsType_unfinished => 'Не сделано';

  @override
  String get followUpsType_gap => 'Пробел';

  @override
  String get followUpsSource_analyze => 'из анализа';

  @override
  String get followUpsSource_work => 'из работы';

  @override
  String get followUpsSource_review => 'из код-ревью';

  @override
  String get followUpsSource_manual => 'из замечания ревью';

  @override
  String followUpsPick(String title) {
    return 'Создать «$title»';
  }

  @override
  String get followUpsEditTitle => 'Название тикета';

  @override
  String get followUpsServes => 'Зачем';

  @override
  String get followUpsAfter => 'После';

  @override
  String get followUpsDetails => 'Подробнее';

  @override
  String get followUpsWaitsForDone => 'Опирается на работу этого тикета: создать можно, когда он будет завершён.';

  @override
  String get followUpsTarget => 'Создать как';

  @override
  String get followUpsTargetLocal => 'Локальная задача';

  @override
  String get followUpsTargetJira => 'Задача в Jira';

  @override
  String get followUpsJiraOff => 'Подключите Jira, чтобы создавать задачи там';

  @override
  String followUpsCreate(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Создать $count тикета',
      many: 'Создать $count тикетов',
      few: 'Создать $count тикета',
      one: 'Создать $count тикет',
      zero: 'Создать тикеты',
    );
    return '$_temp0';
  }

  @override
  String followUpsCreateStart(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Создать и запустить $count тикета',
      many: 'Создать и запустить $count тикетов',
      few: 'Создать и запустить $count тикета',
      one: 'Создать и запустить $count тикет',
      zero: 'Создать и запустить',
    );
    return '$_temp0';
  }

  @override
  String get followUpsCreateHeld => 'Создать на удержании';

  @override
  String get followUpsQueuedHint =>
      'Запущенные тикеты сразу встают в очередь; тикет, который ждёт другой, начнёт писать код после его слияния. Удержанные ждут, пока вы их не запустите.';

  @override
  String get followUpsDismiss => 'Отклонить';

  @override
  String followUpsDismissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отклонённого предложения',
      many: '$count отклонённых предложений',
      few: '$count отклонённых предложения',
      one: '$count отклонённое предложение',
    );
    return '$_temp0';
  }

  @override
  String get followUpsChildren => 'Создано из этого тикета';

  @override
  String get followUpsFollowUpOf => 'Продолжение';

  @override
  String followUpsCreatedNotice(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Создано $count тикета',
      many: 'Создано $count тикетов',
      few: 'Создано $count тикета',
      one: 'Создан $count тикет',
    );
    return '$_temp0, они в очереди до запуска.';
  }

  @override
  String followUpsStartedNotice(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Создано $count тикета',
      many: 'Создано $count тикетов',
      few: 'Создано $count тикета',
      one: 'Создан $count тикет',
    );
    return '$_temp0, они встали в очередь на запуск.';
  }

  @override
  String followUpsFailedItem(String title, String error) {
    return '$title: $error';
  }

  @override
  String get followUpsFromFinding => 'В последующий тикет';

  @override
  String get followUpsFromFindingDone => 'Предложено как продолжение';

  @override
  String get followUpsFromFindingHint => 'Для работы вне этого изменения: предложить отдельным тикетом вместо возврата на доработку';

  @override
  String followUpsOpenBadge(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предложения',
      many: '$count предложений',
      few: '$count предложения',
      one: '$count предложение',
    );
    return '$_temp0';
  }

  @override
  String get followUpsSettingLabel => 'Предлагать последующие тикеты';

  @override
  String get followUpsSettingHelp =>
      'Запуски анализа, работы и ревью предлагают тикеты, которые ещё нужны для завершения тикета: предусловия, части для выделения, несделанное, пробелы из отчёта. Какие создать, решаете вы. По умолчанию выключено, так как каждый промпт становится немного длиннее; тикет может включить это для себя.';

  @override
  String get followUpsNotifyLabel => 'Предложены последующие тикеты';

  @override
  String get followUpsJiraIssueType => 'Тип задач для продолжений';

  @override
  String get followUpsJiraIssueTypeHelp =>
      'Тип задач Jira, которые agnts создаёт, когда вы создаёте продолжение в Jira. По умолчанию: Task.';

  @override
  String get followUpsTargetPlane => 'Задача в Plane';

  @override
  String get followUpsPlaneOff => 'Подключите Plane и привяжите репозиторий к проекту Plane, чтобы создавать там задачи';

  @override
  String get formSave => 'Сохранить изменения';

  @override
  String get formSaving => 'Сохранение…';

  @override
  String get formDiscard => 'Отменить';

  @override
  String get formCancel => 'Отмена';

  @override
  String get formUnsaved => 'У вас есть несохранённые изменения';

  @override
  String get formClose => 'Закрыть';

  @override
  String get formAdd => 'Добавить';

  @override
  String formRemove(String name) {
    return 'Удалить $name';
  }

  @override
  String get formAddCommand => 'Добавить команду';

  @override
  String get formDecrease => 'Уменьшить';

  @override
  String get formIncrease => 'Увеличить';

  @override
  String get formCopy => 'Копировать';

  @override
  String get formCopied => 'Скопировано';

  @override
  String get formSaved => 'Сохранено';

  @override
  String get formSearch => 'Поиск';

  @override
  String get formNoMatch => 'Ничего не найдено';

  @override
  String groupsView(String n) {
    return 'Группы ($n)';
  }

  @override
  String get groupsSub =>
      'Репозитории, которые меняются вместе. Тикет из группы работает во всех них и открывает pull request в каждом, который меняет.';

  @override
  String get groupsNone => 'Групп пока нет. Группа позволяет одному тикету менять несколько репозиториев, например API и веб-приложение.';

  @override
  String get groupsAdd => 'Новая группа';

  @override
  String get groupsDrawerSub => 'Репозитории, которые меняются вместе, по порядку: первый — основной репозиторий тикетов группы.';

  @override
  String get groupsName => 'Название';

  @override
  String get groupsNamePh => 'Магазин';

  @override
  String get groupsDescription => 'Описание';

  @override
  String get groupsMembers => 'Репозитории';

  @override
  String get groupsMembersHelp =>
      'Порядок важен: первый — основной репозиторий. Роль подсказывает agnts, что это за репозиторий, например backend или web.';

  @override
  String get groupsMembersNeeded => 'Добавьте хотя бы один репозиторий.';

  @override
  String get groupsNoMembers => 'Репозиториев пока нет.';

  @override
  String get groupsAddMember => 'Добавить репозиторий…';

  @override
  String get groupsNoMoreRepos => 'Все активные репозитории уже в группе';

  @override
  String get groupsRolePh => 'Роль, например backend';

  @override
  String groupsRoleOf(String name) {
    return 'Роль $name';
  }

  @override
  String groupsMoveUp(String name) {
    return 'Поднять $name';
  }

  @override
  String groupsMoveDown(String name) {
    return 'Опустить $name';
  }

  @override
  String get groupsPrimary => 'основной';

  @override
  String get groupsArchived => 'в архиве';

  @override
  String groupsPrefixHelp(String prefix) {
    return 'Префикс ключа задач из группы, например $prefix-12. Пусто — префикс первого репозитория.';
  }

  @override
  String get groupsInstructions => 'Инструкции';

  @override
  String get groupsInstructionsPh =>
      'Веб-приложение обращается к API через src/api; меняйте оба вместе и держите спецификацию OpenAPI в актуальном состоянии.';

  @override
  String get groupsInstructionsHelp => 'Как репозитории связаны между собой, в Markdown. Добавляется в каждый промпт тикетов группы.';

  @override
  String get groupsWarningsTitle => 'Сохранено, но есть предупреждения:';

  @override
  String groupsWarningsBadge(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предупреждения',
      many: '$count предупреждений',
      few: '$count предупреждения',
      one: '$count предупреждение',
    );
    return '$_temp0';
  }

  @override
  String groupsSaved(String name) {
    return 'Группа $name сохранена';
  }

  @override
  String get groupsDelete => 'Удалить';

  @override
  String groupsDeleteConfirm(String name) {
    return 'Удалить группу $name? Её тикеты сохранят свои репозитории.';
  }

  @override
  String groupsDeleted(String name) {
    return 'Группа $name удалена';
  }

  @override
  String get groupsColGroup => 'Группа';

  @override
  String get groupsColMembers => 'Репозитории';

  @override
  String get groupsColPrefix => 'Префикс';

  @override
  String groupsInGroups(String names) {
    return 'В группах: $names';
  }

  @override
  String get groupsInLabel => 'Группы:';

  @override
  String get groupsPickerGroups => 'Группы репозиториев';

  @override
  String get groupsChosen => 'Выбранные репозитории';

  @override
  String groupsFromGroup(String name) {
    return 'Из группы $name';
  }

  @override
  String get groupsMakePrimary => 'Сделать основным репозиторием';

  @override
  String groupsMore(String count) {
    return '+$count';
  }

  @override
  String get groupsAllGroups => 'Все группы';

  @override
  String get groupsFilterLabel => 'Группа';

  @override
  String get groupsKvRepos => 'Репозитории';

  @override
  String get groupsKvGroup => 'Группа';

  @override
  String groupsTicketRepos(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count репозитория',
      many: '$count репозиториев',
      few: '$count репозитория',
      one: '$count репозиторий',
    );
    return '$_temp0';
  }

  @override
  String get groupsPartlyMerged => 'Влит частично';

  @override
  String groupsPr(String number) {
    return 'PR #$number';
  }

  @override
  String groupsOpenPrIn(String repo, String number) {
    return 'Открыть $repo #$number';
  }

  @override
  String groupsFiles(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String groupsFilesIn(String repo, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$repo · $_temp0';
  }

  @override
  String groupsPushError(String error) {
    return 'Не удалось отправить: $error';
  }

  @override
  String groupsRetryHint(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Повтор отправит $count репозитория, где была ошибка; остальные останутся как есть.',
      many: 'Повтор отправит $count репозиториев, где была ошибка; остальные останутся как есть.',
      few: 'Повтор отправит $count репозитория, где была ошибка; остальные останутся как есть.',
      one: 'Повтор отправит $count репозиторий, где была ошибка; остальные останутся как есть.',
    );
    return '$_temp0';
  }

  @override
  String get groupsState_pending => 'Не отправлен';

  @override
  String get groupsState_unchanged => 'Без изменений';

  @override
  String get groupsState_pushed => 'Отправлен';

  @override
  String get groupsState_merged => 'Влит';

  @override
  String get groupsState_dropped => 'Закрыт';

  @override
  String get groupsMaxTicketRepos => 'Максимум репозиториев в тикете';

  @override
  String get groupsMaxTicketReposHelp => 'Сколько репозиториев может быть у одного тикета и у одной группы репозиториев.';

  @override
  String get harnessRepoTab => 'Защита';

  @override
  String get harnessRepoTitle => 'Защита';

  @override
  String get harnessRepoSub => 'Насколько строго agnts-guard проверяет работу Claude в этом репозитории — во время работы и после.';

  @override
  String get harnessRepoSave => 'Сохранить защиту';

  @override
  String get harnessRepoSaved => 'Защита сохранена';

  @override
  String get harnessRepoAgentTitle => 'Файлы инструкций для агентов';

  @override
  String get harnessRepoAgentSub =>
      'agnts проверяет CLAUDE.md, AGENTS.md, .claude/ и .mcp.json на текст, который пытается управлять агентом. Хуки и MCP-серверы этого репозитория agnts никогда не запускает.';

  @override
  String harnessRepoAgentScanned(String time) {
    return 'Проверено $time';
  }

  @override
  String get harnessRepoAgentNotScanned => 'Ещё не проверено: следующий запуск в этом репозитории проверит файлы.';

  @override
  String get harnessRepoAgentNothing => 'Ничего не найдено.';

  @override
  String harnessRepoAgentWarn(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n строки могут',
      many: '$n строк могут',
      few: '$n строки могут',
      one: '$n строка может',
    );
    return '$_temp0 пытаться управлять агентом. Запуски читают эти файлы как данные, а не как инструкции; прочитайте их, прежде чем им доверять.';
  }

  @override
  String get harnessRepoAgentInfo => 'Настройки, которые agnts игнорирует';

  @override
  String get harnessRepoKind_hidden_unicode => 'Скрытые символы';

  @override
  String get harnessRepoKind_agent_instruction => 'Указание агенту';

  @override
  String get harnessRepoKind_exfiltration => 'Отправка данных наружу';

  @override
  String get harnessRepoKind_encoded_blob => 'Закодированный текст';

  @override
  String get harnessRepoKind_hooks => 'Хуки Claude Code';

  @override
  String get harnessRepoKind_mcp_server => 'MCP-серверы';

  @override
  String get harnessRepoProfile => 'Профиль защиты';

  @override
  String get harnessRepoProfileHelp => 'Насколько строги проверки во время работы в этом репозитории.';

  @override
  String get harnessRepoProfile_ => 'Как в пространстве';

  @override
  String get harnessRepoProfile_minimal => 'Минимальный';

  @override
  String get harnessRepoProfile_standard => 'Обычный';

  @override
  String get harnessRepoProfile_strict => 'Строгий';

  @override
  String get harnessRepoProfileHelp_ => 'Как в настройках рабочего пространства.';

  @override
  String get harnessRepoProfileHelp_minimal => 'Блокируются только секреты и обязательные правила; перед завершением проверяется сборка.';

  @override
  String get harnessRepoProfileHelp_standard =>
      'Также блокируются пропущенные тесты, отключённые линтеры и правки конфигурации проверок; перед завершением должны пройти сборка и линтер.';

  @override
  String get harnessRepoProfileHelp_strict =>
      'Также блокируются проглоченные ошибки и удалённые проверки в тестах, перед завершением запускаются тесты, и агент может спросить факты перед правкой файла.';

  @override
  String get harnessRepoSecretAllow => 'Где разрешены примеры ключей';

  @override
  String get harnessRepoSecretAllowHelp => 'Шаблоны путей, где ожидаются ненастоящие ключи, кроме testdata/, fixtures/ и *.example.';

  @override
  String get harnessRepoChecksTitle => 'Проверки каждого файла';

  @override
  String get harnessRepoChecksSub =>
      'Быстрые форматтеры и линтеры, которые agnts-guard запускает на каждом изменённом Claude файле, чтобы проблемы исправлялись сразу.';

  @override
  String get harnessRepoChecksOff => 'Отключить проверки файлов';

  @override
  String get harnessRepoChecksOffHelp => 'Claude не проверяется после каждой правки; проверки после запуска остаются.';

  @override
  String get harnessRepoOwnChecks => 'Свои проверки';

  @override
  String get harnessRepoOwnChecksHelp => 'Заменить проверки, которые agnts выводит из инструментов, своим списком.';

  @override
  String get harnessRepoDerivedTitle => 'Выведены из инструментов';

  @override
  String get harnessRepoDerivedNone => 'agnts не знает проверок файлов для инструментов этого репозитория.';

  @override
  String get harnessRepoCheckName => 'Название';

  @override
  String get harnessRepoCheckGlobs => 'Файлы (шаблоны через запятую)';

  @override
  String get harnessRepoCheckCmd => 'Команда';

  @override
  String harnessRepoCheckCmdHelp(String file, String dir) {
    return '\'$file\' — изменённый файл, \'$dir\' — его папка, оба относительно репозитория.';
  }

  @override
  String get harnessRepoCheckEvery => 'Не чаще чем раз в (секунд)';

  @override
  String get harnessRepoAddCheck => 'Добавить проверку';

  @override
  String harnessRepoRemoveCheck(String name) {
    return 'Удалить $name';
  }

  @override
  String get harnessRepoCoverageTitle => 'Покрытие изменённых строк';

  @override
  String get harnessRepoCoverageSub =>
      'Когда проверки прошли, agnts ещё раз запускает тесты с покрытием и показывает, какие добавленные строки не выполнил ни один тест.';

  @override
  String get harnessRepoCoverage => 'Измерять покрытие';

  @override
  String get harnessRepoCoverageHelp => 'Дополнительный запуск тестов после проверок; запуск из-за него не падает.';

  @override
  String get harnessRepoThreshold => 'Порог';

  @override
  String get harnessRepoThresholdHelp => 'Ниже порога код-ревью получает замечание о покрытии. 0 отключает замечание.';

  @override
  String get harnessRepoCoverageCmd => 'Команда покрытия';

  @override
  String get harnessRepoCoverageCmdHelp => 'Оставьте пустым, чтобы использовать команду, которую выводит agnts.';

  @override
  String get harnessRepoCoverageReport => 'Файл отчёта';

  @override
  String get harnessRepoCoverageReportHelp => 'Профиль покрытия Go или lcov, в репозитории или в /agnts/out/.';

  @override
  String get harnessRepoCoverageNoDerived => 'agnts не знает команды покрытия для этих инструментов: укажите её.';

  @override
  String get harnessRepoAcceptance => 'Проверять приёмку в приложении';

  @override
  String get harnessRepoAcceptanceHelp =>
      'После превью agnts проверяет критерии приёмки тикета в запущенном приложении и показывает результат со скриншотами.';

  @override
  String get harnessRepoAcceptanceNoPreview => 'Нужна команда превью: укажите её при редактировании репозитория.';

  @override
  String get harnessRepoStarterTitle => 'Стартовые правила';

  @override
  String get harnessRepoStarterSub =>
      'Конкретные проверяемые соглашения для языков этого репозитория. Они добавляются как предложения: ничего не применяется, пока вы их не примете.';

  @override
  String get harnessRepoStarterNone => 'Для инструментов этого репозитория нет стартового набора.';

  @override
  String harnessRepoStarterRules(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n правила',
      many: '$n правил',
      few: '$n правила',
      one: '$n правило',
    );
    return '$_temp0';
  }

  @override
  String harnessRepoStarterOffer(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n правила',
      many: '$n правил',
      few: '$n правила',
      one: '$n правило',
    );
    return 'Предложить $_temp0';
  }

  @override
  String get harnessRepoStarterOffered => 'Уже предложены';

  @override
  String harnessRepoStarterAdded(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Предложено $n правила',
      many: 'Предложено $n правил',
      few: 'Предложено $n правила',
      one: 'Предложено $n правило',
      zero: 'Нечего предложить',
    );
    return '$_temp0';
  }

  @override
  String get harnessRepoStarterOpenRules => 'Открыть предложения';

  @override
  String get harnessRulesDelivery => 'Как запуски получают правило';

  @override
  String get harnessRulesDelivery_prompt => 'В каждом промпте';

  @override
  String get harnessRulesDelivery_skill => 'Навык';

  @override
  String get harnessRulesDeliveryHelp_prompt => 'В каждом промпте, всегда на виду.';

  @override
  String get harnessRulesDeliveryHelp_skill =>
      'Навык, который Claude загружает, когда его описание подходит к работе: промпты остаются короткими, когда правил много. Важные правила держите в каждом промпте.';

  @override
  String get harnessRulesEnforce => 'Обязательное';

  @override
  String get harnessRulesEnforceHelp => 'agnts-guard проверяет правило во время работы Claude, а не только просит его соблюдать.';

  @override
  String get harnessRulesOn => 'Проверять';

  @override
  String get harnessRulesOn_file => 'Правки файлов';

  @override
  String get harnessRulesOn_bash => 'Команды';

  @override
  String get harnessRulesOn_diff => 'Готовое изменение';

  @override
  String get harnessRulesOnHelp_file => 'Правки файлов ниже; с шаблоном — только добавленные строки, которые ему соответствуют.';

  @override
  String get harnessRulesOnHelp_bash => 'Команды оболочки, которые запускает Claude и которые подходят под шаблон.';

  @override
  String get harnessRulesOnHelp_diff => 'Готовое изменение, проверяется на сервере после запуска.';

  @override
  String get harnessRulesPaths => 'Файлы (шаблоны)';

  @override
  String get harnessRulesPathsPlaceholder => 'server/migrations/*.sql';

  @override
  String get harnessRulesPattern => 'Шаблон (регулярное выражение RE2)';

  @override
  String get harnessRulesAction => 'При совпадении';

  @override
  String get harnessRulesAction_block => 'Блокировать';

  @override
  String get harnessRulesAction_warn => 'Предупреждать';

  @override
  String get harnessRulesMessage => 'Сообщение для Claude';

  @override
  String get harnessRulesMessagePlaceholder => 'Добавьте новую миграцию.';

  @override
  String get harnessRulesTry => 'Проверить на истории';

  @override
  String get harnessRulesTrying => 'Проверяю…';

  @override
  String harnessRulesTryChecked(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Проверено $n изменения',
      many: 'Проверено $n изменений',
      few: 'Проверено $n изменения',
      one: 'Проверено $n изменение',
    );
    return '$_temp0 от agnts.';
  }

  @override
  String get harnessRulesTryNone => 'Ни одно из них не совпало бы.';

  @override
  String harnessRulesTryHits(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n тикетах',
      many: '$n тикетах',
      few: '$n тикетах',
      one: '$n тикете',
    );
    return 'Совпало бы в $_temp0:';
  }

  @override
  String get harnessRulesBadgeBlock => 'Обязательное: блокирует';

  @override
  String get harnessRulesBadgeWarn => 'Обязательное: предупреждает';

  @override
  String get harnessRulesBadgeSkill => 'Навык';

  @override
  String get harnessRulesBadgeTip => 'Совет';

  @override
  String get harnessRulesSource_reflect => 'Из отзыва';

  @override
  String get harnessRulesSource_run => 'Из запуска';

  @override
  String get harnessRulesSource_promoted => 'Замечено в нескольких репозиториях';

  @override
  String harnessRulesSourceStarter(String name) {
    return 'Стартовое: $name';
  }

  @override
  String harnessRulesConfidence(String n) {
    return 'Уверенность $n%';
  }

  @override
  String harnessRulesSeen(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Замечено $n раза',
      many: 'Замечено $n раз',
      few: 'Замечено $n раза',
      one: 'Замечено $n раз',
    );
    return '$_temp0';
  }

  @override
  String harnessRulesWatching(String n) {
    return 'Наблюдение ($n)';
  }

  @override
  String get harnessRulesWatchingHelp =>
      'Уроки, которые agnts заметил раз или два. Они станут предложениями, когда он увидит их снова; до тех пор они не попадают ни в один тикет.';

  @override
  String get harnessSettingsTitle => 'Ограничители';

  @override
  String get harnessSettingsSub =>
      'agnts-guard проверяет работу Claude внутри каждого запуска, по ходу дела; проверки agnts после запуска по-прежнему действуют.';

  @override
  String get harnessSettingsProfile => 'Профиль ограничителей';

  @override
  String get harnessSettingsProfile_minimal => 'Минимальный';

  @override
  String get harnessSettingsProfile_standard => 'Стандартный';

  @override
  String get harnessSettingsProfile_strict => 'Строгий';

  @override
  String get harnessSettingsProfileHelp_minimal =>
      'Блокирует секреты и файлы .env, применяет правила команды с шаблоном и требует успешной сборки, прежде чем Claude закончит.';

  @override
  String get harnessSettingsProfileHelp_standard =>
      'Всё из минимального, а также: блокирует пропущенные и удалённые тесты, отключённые линтеры и изменения конфигурации проверок; линтер в стоп-проверке; быстрые проверки каждого изменённого файла.';

  @override
  String get harnessSettingsProfileHelp_strict =>
      'Всё из стандартного, а также: тесты в стоп-проверке, блокировка проглоченных ошибок и удалённых проверок, проверка фактов перед первыми правками.';

  @override
  String get harnessSettingsFactCheck => 'Доля проверки фактов';

  @override
  String get harnessSettingsFactCheckHelp =>
      'Доля задач со строгим профилем, где запуск должен назвать, кто использует файл, прежде чем менять его, и как откатить разрушительные команды. Сравните группы в аналитике.';

  @override
  String get harnessSettingsStalls => 'Если запуск застрял';

  @override
  String get harnessSettingsStallsHelp =>
      'Одна и та же команда снова и снова падает, нет правок много вызовов подряд или один файл читается раз за разом.';

  @override
  String get harnessSettingsStalls_off => 'Игнорировать';

  @override
  String get harnessSettingsStalls_log => 'Отметить';

  @override
  String get harnessSettingsStalls_act => 'Вмешаться';

  @override
  String get harnessSettingsProveFixes => 'Доказывать исправления';

  @override
  String get harnessSettingsProveFixesHelp =>
      'Исправлению бага нужен тест, который падает до изменения и проходит после; agnts запускает его оба раза и показывает результат.';

  @override
  String get harnessSettingsDeepReview => 'Глубокое ревью';

  @override
  String get harnessSettingsDeepReviewHelp =>
      'Специализированные проходы в код-ревью (безопасность, тихие ошибки, тесты, типы). Авто: только большая или сложная работа; стоит больше токенов.';

  @override
  String get harnessSettingsDeep_off => 'Выкл';

  @override
  String get harnessSettingsDeep_auto => 'Авто';

  @override
  String get harnessSettingsDeep_always => 'Всегда';

  @override
  String get harnessSettingsLearnFromRuns => 'Учиться на запусках';

  @override
  String get harnessSettingsLearnFromRunsHelp =>
      'После запуска с упавшими проверками или застреванием agnts может предложить совет для репозитория. Советы наблюдаются, пока не повторятся.';

  @override
  String get harnessSettingsMethodSkills => 'Навыки-методики';

  @override
  String get harnessSettingsMethodSkillsHelp =>
      'Запуски кодинга получают навыки-методики agnts: добавлять ещё один элемент так, как это уже сделано в репозитории, следовать окружающему стилю, переиспользовать перед тем как писать, безопасно менять схему базы данных. Claude загружает навык, только когда он подходит; сравнивайте в Аналитике.';

  @override
  String get harnessSettingsSecondOpinion => 'Второе мнение';

  @override
  String get harnessSettingsSecondOpinionHelp =>
      'Другая модель читает выбранный подход сложных задач и говорит, согласна ли она. Пусто — выключено.';

  @override
  String get harnessSettingsSecondOpinionHint => 'например, opus или codex:gpt-5-codex';

  @override
  String get harnessSettingsAdvanced => 'Дополнительно: хуки ограничителей';

  @override
  String get harnessSettingsAdvancedHelp => 'Отключайте отдельные хуки; остальное решает профиль.';

  @override
  String get harnessSettingsHook_pre_secret => 'отклонять секреты и файлы .env';

  @override
  String get harnessSettingsHook_pre_redflags => 'отклонять пропуск тестов, отключение линтеров, ослабление проверок';

  @override
  String get harnessSettingsHook_pre_rules => 'применять правила команды с шаблоном';

  @override
  String get harnessSettingsHook_pre_fact_check => 'спрашивать факты перед первой правкой файла';

  @override
  String get harnessSettingsHook_pre_destructive => 'спрашивать план отката перед разрушительными командами';

  @override
  String get harnessSettingsHook_post_edit_check => 'проверять каждый изменённый файл (форматтер, линтер)';

  @override
  String get harnessSettingsHook_stop_gate => 'сборка и линтер должны пройти, прежде чем Claude закончит';

  @override
  String get harnessSettingsHook_session_progress => 'возвращать план после сжатия контекста';

  @override
  String get harnessSettingsCodex => 'Код в Codex';

  @override
  String get harnessSettingsCodexHelp =>
      'Имя модели Codex запускает написание кода в Codex CLI вместо Claude; пусто — Claude. Нужны интеграция OpenAI и api.openai.com в разрешённых хостах (Настройки → Превью).';

  @override
  String get harnessSettingsCodexConnect => 'Интеграция OpenAI';

  @override
  String get harnessSettingsQualityTitle => 'Ограничители по версиям промптов';

  @override
  String get harnessSettingsQualitySub => 'Что сделали agnts-guard и проверки для задач каждой версии промптов.';

  @override
  String get harnessSettingsColBlocks => 'Заблокировано';

  @override
  String get harnessSettingsColBlocksHint => 'Действия, которые agnts-guard отклонил в запусках с кодом';

  @override
  String get harnessSettingsColStopSaves => 'Спасения стоп-проверкой';

  @override
  String get harnessSettingsColStopSavesHint =>
      'Задачи, где стоп-проверка вернула упавшие проверки, после чего проверки agnts прошли с первого раза';

  @override
  String get harnessSettingsColStalls => 'Застревания';

  @override
  String get harnessSettingsColStallsHint => 'Сколько раз запуски выглядели застрявшими';

  @override
  String get harnessSettingsColProven => 'Доказанные исправления';

  @override
  String get harnessSettingsColProvenHint =>
      'Исправления багов, тест которых падал до изменения и прошёл после, из тех, где было доказательство';

  @override
  String get harnessSettingsColAdopted => 'Принятые замечания';

  @override
  String get harnessSettingsColAdoptedHint => 'Замечания ревью, которые люди включили в свой отзыв';

  @override
  String get harnessSettingsColTokens => 'Токенов на задачу';

  @override
  String get harnessSettingsColTokensHint => 'Среднее число токенов готовой задачи, все этапы';

  @override
  String get harnessSettingsColFactCheck => 'Проверка фактов, с первого раза';

  @override
  String get harnessSettingsColFactCheckHint =>
      'Доля задач группы проверки фактов, принятых с первого раза, рядом с долей всех готовых задач';

  @override
  String get harnessSettingsSkillsTitle => 'Навыки-методики';

  @override
  String get harnessSettingsSkillsSub =>
      'Тикеты, запуски кодинга которых получили каждый навык, включая повторы, рядом с тикетами без навыков. Чтобы сравнить, повторите одни и те же тикеты с выключенной и включённой настройкой.';

  @override
  String get harnessSettingsSkillNone => 'нет (база)';

  @override
  String get harnessSettingsColSkill => 'Навык';

  @override
  String get harnessSettingsColSkillTickets => 'Тикеты';

  @override
  String get harnessSettingsColSkillTicketsHint => 'Тикеты с запуском кодинга, получившим навык';

  @override
  String get harnessSettingsColLoaded => 'Загружен';

  @override
  String get harnessSettingsColLoadedHint => 'Доля этих тикетов, где Claude загрузил навык';

  @override
  String get harnessSettingsColSkillFirstTry => 'С первого раза';

  @override
  String get harnessSettingsColSkillFirstTryHint => 'Готово без просьб человека об изменениях, от готовых тикетов';

  @override
  String get harnessSettingsColLoadedFirstTry => 'С первого раза, загружен';

  @override
  String get harnessSettingsColLoadedFirstTryHint => 'Доля готовых с первого раза среди тикетов, где Claude загрузил навык';

  @override
  String get harnessSettingsColTargeted => 'Целевые замечания';

  @override
  String get harnessSettingsColTargetedHint =>
      'Замечания ревью на тикет тех видов, на которые нацелены навыки: архитектура, сопровождаемость и любые по файлам миграций';

  @override
  String harnessSettingsXOfY(String x, String y) {
    return '$x из $y';
  }

  @override
  String harnessSettingsVsAll(String n) {
    return 'против $n%';
  }

  @override
  String get harnessTicketFlag_secret => 'Возможный секрет';

  @override
  String get harnessTicketFlag_env_file => 'Добавлен файл .env';

  @override
  String get harnessTicketFlag_debug_leftover => 'Оставлен отладочный вывод';

  @override
  String get harnessTicketFlag_check_config => 'Изменена настройка проверок';

  @override
  String get harnessTicketFlag_rule_violation => 'Нарушено правило команды';

  @override
  String get harnessTicketSecretsTitle => 'В изменении может быть настоящий секрет';

  @override
  String harnessTicketSecretsBody(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n строки', many: '$n строк', few: '$n строки', one: '$n строку');
    return 'agnts отметил $_temp0 как возможный секрет или файл .env. Проверьте их в тревожных признаках на вкладке «Ревью»: agnts не отправит изменение, пока вы не подтвердите, что это не настоящие учётные данные.';
  }

  @override
  String get harnessTicketSecretsConfirm => 'Я проверил: это не настоящие учётные данные';

  @override
  String get harnessTicketSecretsDone => 'Подтверждено: отмеченные строки — не настоящие учётные данные.';

  @override
  String get harnessTicketSecretsNeeded => 'Сначала подтвердите, что строки, отмеченные как секреты, — не настоящие учётные данные.';

  @override
  String get harnessTicketProofTitle => 'Доказательство исправления';

  @override
  String get harnessTicketProof_proven => 'Доказано';

  @override
  String get harnessTicketProof_not_reproduced => 'Не воспроизведено';

  @override
  String get harnessTicketProof_still_failing => 'Всё ещё падает';

  @override
  String get harnessTicketProof_inconclusive => 'Неясно';

  @override
  String get harnessTicketProof_no_test => 'Нет теста';

  @override
  String get harnessTicketProof_error => 'Не проверено';

  @override
  String get harnessTicketProofHelp_proven => 'Воспроизводящий тест падает на коде до изменения и проходит после него.';

  @override
  String get harnessTicketProofHelp_not_reproduced => 'Тест проходит и до изменения, значит, он не показывает ошибку.';

  @override
  String get harnessTicketProofHelp_still_failing => 'Тест всё ещё падает с изменением.';

  @override
  String get harnessTicketProofHelp_inconclusive =>
      'Тест не удалось запустить на коде до изменения; возможно, ему нужно то, что добавляет исправление.';

  @override
  String get harnessTicketProofHelp_no_test => 'Ни один автотест не воспроизводит ошибку.';

  @override
  String get harnessTicketProofHelp_error => 'agnts не смог проверить исправление.';

  @override
  String harnessTicketProofBase(String sha) {
    return 'Начато с $sha';
  }

  @override
  String harnessTicketProofBefore(String code) {
    return 'До изменения (код выхода $code)';
  }

  @override
  String harnessTicketProofAfter(String code) {
    return 'После изменения (код выхода $code)';
  }

  @override
  String get harnessTicketCoverageTitle => 'Покрытие изменённых строк';

  @override
  String harnessTicketCoveragePct(String pct, String covered, String total) {
    return 'Тесты выполнили $pct% изменённых строк ($covered из $total)';
  }

  @override
  String harnessTicketCoverageBelow(String n) {
    return 'Ниже порога репозитория в $n%';
  }

  @override
  String get harnessTicketCoverageNone => 'Ни одна изменённая строка не относится к коду, который измеряет отчёт о покрытии.';

  @override
  String harnessTicketCoverageLines(String ranges) {
    return 'Не выполнены: строки $ranges';
  }

  @override
  String harnessTicketCoverageError(String error) {
    return 'Не удалось измерить покрытие: $error';
  }

  @override
  String harnessTicketConfidence(String n) {
    return 'Уверенность $n%';
  }

  @override
  String get harnessTicketPass_security => 'Проверка безопасности';

  @override
  String get harnessTicketPass_failures => 'Проверка ошибок';

  @override
  String get harnessTicketPass_tests => 'Проверка тестов';

  @override
  String get harnessTicketPass_types => 'Проверка типов';

  @override
  String get harnessTicketAdopted => 'В вашем отзыве';

  @override
  String get harnessTicketDeep => 'Глубокое ревью';

  @override
  String harnessTicketDropped(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n замечания',
      many: '$n замечаний',
      few: '$n замечания',
      one: '$n замечание',
    );
    return 'Не показано $_temp0 (низкая уверенность или повторы)';
  }

  @override
  String get harnessTicketDefect => 'Исправление ошибки';

  @override
  String get harnessTicketAcceptanceTitle => 'Критерии приёмки';

  @override
  String get harnessTicketCheck_ui => 'В приложении';

  @override
  String get harnessTicketCheck_api => 'API';

  @override
  String get harnessTicketCheck_test => 'Тест';

  @override
  String get harnessTicketCheck_manual => 'Вручную';

  @override
  String get harnessTicketSecondTitle => 'Второе мнение';

  @override
  String harnessTicketSecondBy(String model) {
    return 'От $model';
  }

  @override
  String get harnessTicketSecondAgrees => 'Согласен';

  @override
  String get harnessTicketSecondConcerns => 'Есть сомнения';

  @override
  String get harnessTicketSecondAlternative => 'Сделал бы иначе';

  @override
  String harnessTicketSecondError(String error) {
    return 'Нет второго мнения: $error';
  }

  @override
  String get harnessTicketAccTitle => 'Проверка приёмки';

  @override
  String get harnessTicketAcc_ok => 'Всё выполнено';

  @override
  String get harnessTicketAcc_partial => 'Проверено частично';

  @override
  String get harnessTicketAcc_failed => 'Не выполнено';

  @override
  String get harnessTicketVerdict_pass => 'Выполнено';

  @override
  String get harnessTicketVerdict_fail => 'Не выполнено';

  @override
  String get harnessTicketVerdict_unknown => 'Не проверено';

  @override
  String get harnessTicketAccSteps => 'Шаги';

  @override
  String get harnessTicketAccShot => 'Скриншот';

  @override
  String get implementTitle => 'Следующий шаг';

  @override
  String get implementSubPlan =>
      'Пусть agnts выполнит план: задача на код, связанная с этой, с планом в качестве задания. Дифф вы проверяете как обычно.';

  @override
  String get implementSubBug =>
      'Пусть agnts внесёт предложенное исправление: задача на код, связанная с этой, с разбором в качестве задания. Дифф вы проверяете как обычно.';

  @override
  String get implementImplement => 'Выполнить план';

  @override
  String get implementFix => 'Исправить баг';

  @override
  String get implementPickRepo => 'Репозиторий для изменений';

  @override
  String get implementQueue => 'Оставить задачу в очереди, не запускать';

  @override
  String get implementDoneBy => 'Выполняется в';

  @override
  String get implementImplements => 'Выполняет';

  @override
  String get integrationsAssignedOnly => 'Только задачи, назначенные мне';

  @override
  String integrationsAssignedOnlyHelp(String email) {
    return 'agnts берёт задачу с меткой, только если она назначена на аккаунт, которым agnts подключён к Jira ($email). Выключите, чтобы брать все задачи с меткой.';
  }

  @override
  String get integrationsTitle => 'Интеграции';

  @override
  String get integrationsLede =>
      'Сервисы, с которыми работает agnts. Токены хранятся на вашем сервере в зашифрованном виде и используются только для действий, указанных на каждой странице.';

  @override
  String get integrationsName_jira => 'Jira';

  @override
  String get integrationsName_github => 'GitHub';

  @override
  String get integrationsName_claude => 'Claude';

  @override
  String get integrationsDesc_jira => 'Брать тикеты с меткой agnts и поддерживать их статус в актуальном состоянии.';

  @override
  String get integrationsDesc_github => 'Клонировать код, отправлять ветки и открывать пул-реквесты.';

  @override
  String get integrationsDesc_claude => 'Ваша подписка Claude, на которой работает Claude Code.';

  @override
  String get integrationsConnected => 'Подключено';

  @override
  String get integrationsNotConnected => 'Не подключено';

  @override
  String get integrationsConnect => 'Подключить';

  @override
  String get integrationsManage => 'Управлять';

  @override
  String get integrationsTest => 'Проверить подключение';

  @override
  String get integrationsDisconnect => 'Отключить';

  @override
  String integrationsDisconnectConfirm(String name) {
    return 'Отключить $name? agnts забудет токен и перестанет его использовать.';
  }

  @override
  String integrationsDisconnected(String name) {
    return '$name отключён';
  }

  @override
  String get integrationsAccount => 'Аккаунт';

  @override
  String get integrationsToken => 'Токен';

  @override
  String get integrationsLastChecked => 'Последняя проверка';

  @override
  String get integrationsLastError => 'Последняя ошибка';

  @override
  String get integrationsNever => 'Никогда';

  @override
  String get integrationsComing => 'Скоро';

  @override
  String get integrationsComingSub => 'Запланированные интеграции';

  @override
  String get integrationsBack => 'Назад к интеграциям';

  @override
  String integrationsConnectedAs(String account, String time) {
    return 'Подключено как $account. Последняя проверка: $time.';
  }

  @override
  String get integrationsNotYet => 'Ещё не подключено.';

  @override
  String integrationsConnectTitle(String name) {
    return 'Подключить $name';
  }

  @override
  String get integrationsConnectSub_jira => 'Используйте API-токен из аккаунта Atlassian.';

  @override
  String get integrationsTokenOpen_jira => 'Открыть API-токены Atlassian';

  @override
  String get integrationsTokenStep1_jira =>
      'Войдите в аккаунт Atlassian, от имени которого будет работать agnts, и откройте Account settings → Security → API tokens (или используйте кнопку ниже).';

  @override
  String get integrationsTokenStep2_jira =>
      'Нажмите Create API token (не вариант со scopes), задайте имя (например, agnts) и срок действия.';

  @override
  String get integrationsTokenStep3_jira => 'Скопируйте токен и вставьте ниже. Atlassian показывает его только один раз.';

  @override
  String get integrationsTokenStep4_jira =>
      'В поле «Сайт» укажите адрес Jira (https://your-team.atlassian.net), а в «Email аккаунта» — email этого же аккаунта. У него должен быть доступ к проектам Jira, с которыми работает agnts.';

  @override
  String get integrationsConnectSub_github => 'Создайте fine-grained токен доступа с правами ниже и вставьте его сюда.';

  @override
  String get integrationsTokenHow => 'Как получить токен';

  @override
  String get integrationsTokenCommand => 'Команда';

  @override
  String get integrationsTokenOpen_github => 'Открыть страницу токенов GitHub';

  @override
  String get integrationsTokenStep1_github =>
      'На GitHub откройте Settings → Developer settings → Personal access tokens → Fine-grained tokens и нажмите Generate new token (или используйте кнопку ниже).';

  @override
  String get integrationsTokenStep2_github =>
      'Задайте имя (например, agnts) и срок действия, в Resource owner выберите аккаунт или организацию, которой принадлежат репозитории, а в Repository access — репозитории, с которыми будет работать agnts.';

  @override
  String get integrationsTokenStep3_github =>
      'В Repository permissions установите для Contents и Pull requests значение Read and write, а для Workflows — Read and write, если agnts может менять файлы CI в .github/workflows. Для вкладки «Пайплайны» также установите Actions — Read (Read and write для кнопки «Развернуть») и Deployments — Read. Metadata (чтение) добавляется автоматически.';

  @override
  String get integrationsTokenStep4_github =>
      'Нажмите Generate token, скопируйте токен (начинается с github_pat_) и вставьте ниже. GitHub показывает его только один раз. Для организации токен, возможно, должен сначала одобрить владелец.';

  @override
  String get integrationsConnectSub_claude =>
      'Выполните `claude setup-token` на машине, где вы вошли в свой тариф Claude, и вставьте токен.';

  @override
  String get integrationsTokenStep1_claude =>
      'Нужна подписка Claude Pro или Max. На любом компьютере установите Claude Code: npm install -g @anthropic-ai/claude-code';

  @override
  String get integrationsTokenStep2_claude => 'Запустите claude в терминале и войдите в свой аккаунт Claude.';

  @override
  String get integrationsTokenStep3_claude =>
      'Выполните команду ниже. Она откроет браузер для подтверждения доступа и выведет долгоживущий токен.';

  @override
  String get integrationsTokenStep4_claude =>
      'Скопируйте токен (начинается с sk-ant-) и вставьте ниже. Он действует около года, а запуски расходуют лимиты вашей подписки.';

  @override
  String get integrationsSite => 'Сайт';

  @override
  String get integrationsSiteHelp => 'Например https://your-team.atlassian.net';

  @override
  String get integrationsEmail => 'Email аккаунта';

  @override
  String get integrationsApiToken => 'API-токен';

  @override
  String get integrationsApiTokenHelp => 'id.atlassian.com → Security → API tokens';

  @override
  String get integrationsAccessToken => 'Токен доступа';

  @override
  String get integrationsTokenHelp => 'Хранится на вашем сервере в зашифрованном виде. agnts больше его не покажет.';

  @override
  String get integrationsScopes => 'Нужные права';

  @override
  String get integrationsPermContents => 'Чтение и запись. Клонировать код и отправлять ветки.';

  @override
  String get integrationsPermPulls => 'Чтение и запись. Открывать пул-реквесты.';

  @override
  String get integrationsPermWorkflows =>
      'Чтение и запись. Отправлять изменения в .github/workflows (файлы CI); без него такие пуши отклоняются.';

  @override
  String get integrationsPermMetadata => 'Чтение. Список репозиториев и веток.';

  @override
  String get integrationsPermActions => 'Чтение — для вкладки «Пайплайны» и окружений; чтение и запись — для кнопки «Развернуть».';

  @override
  String get integrationsPermDeployments => 'Чтение. Показывает, что развёрнуто в каждом окружении.';

  @override
  String get integrationsRequired => 'Обязательно';

  @override
  String get integrationsRecommended => 'Рекомендуется';

  @override
  String get integrationsConnecting => 'Проверка токена…';

  @override
  String integrationsConnectedToast(String name) {
    return '$name подключён';
  }

  @override
  String integrationsTestOk(String name) {
    return '$name: подключение работает';
  }

  @override
  String integrationsTestFail(String name, String error) {
    return '$name: $error';
  }

  @override
  String get integrationsWebhookTitle => 'Настройте вебхук Jira';

  @override
  String get integrationsWebhookSteps => 'В Jira откройте Settings → System → WebHooks → Create и укажите:';

  @override
  String get integrationsWebhookUrl => 'URL';

  @override
  String get integrationsWebhookSecret => 'Секрет';

  @override
  String get integrationsWebhookOnce => 'Этот секрет показывается только один раз. Вставьте его в Jira сейчас.';

  @override
  String get integrationsEvents => 'События';

  @override
  String get integrationsEventsValue => 'Issue created, Issue updated';

  @override
  String get integrationsConnection => 'Подключение';

  @override
  String get integrationsPickup => 'Правила выбора';

  @override
  String get integrationsPickupSub => 'Какие тикеты берёт agnts';

  @override
  String get integrationsLabel => 'Метка';

  @override
  String get integrationsLabelHelp => 'Добавьте эту метку тикету, чтобы передать его agnts';

  @override
  String get integrationsQuery => 'Запрос, который выполняет agnts';

  @override
  String get integrationsLabelsTitle => 'Как размечать тикеты';

  @override
  String get integrationsLabelsSub => 'Добавьте одну из этих меток незавершённой задаче в Jira. Регистр не важен.';

  @override
  String get integrationsLabelsRepo =>
      'Задача попадает в репозиторий, привязанный к её проекту (Репозитории → проект Jira). Чтобы отправить её в другой, добавьте метку repo: с именем репозитория в agnts, например repo:web. Без репозитория запускаются только планы, анализ и поиск причин ошибок.';

  @override
  String get integrationsLabelsMany => 'Если меток вида несколько, выбирается первая по этому списку.';

  @override
  String get integrationsLabelsLater =>
      'Метка вида, добавленная до начала работы, меняет вид тикета. Если убрать все метки agnts, обновления из Jira перестанут приходить.';

  @override
  String get integrationsPlaneLabelsSub => 'Добавьте одну из этих меток открытой задаче. Регистр не важен.';

  @override
  String get integrationsPlaneLabelsCreate => 'Метки в Plane принадлежат проекту: сначала создайте нужные в каждом привязанном проекте.';

  @override
  String get integrationsPlaneLabelsRepo =>
      'Привяжите проект к репозиторию по идентификатору (WEB в WEB-123): Репозитории → проект Plane. Синхронизация читает только привязанные проекты, а коду и тестам нужен репозиторий. Чтобы отправить одну задачу в другой репозиторий, добавьте метку repo: с именем репозитория в agnts, например repo:web.';

  @override
  String get integrationsPlaneLabelsLater =>
      'Метка вида, добавленная до начала работы, меняет вид тикета. Если убрать все метки agnts, обновления из Plane перестанут приходить.';

  @override
  String get integrationsStatuses => 'Обновления статуса';

  @override
  String get integrationsStatusesSub => 'Как agnts двигает тикеты на доске. Оставьте пустым, чтобы не менять статус.';

  @override
  String get integrationsMapStarted => 'Когда agnts начинает';

  @override
  String get integrationsMapReview => 'Когда изменения отправлены';

  @override
  String get integrationsMapRejected => 'Когда вы отклоняете изменения';

  @override
  String get integrationsKeepStatus => 'Не менять статус';

  @override
  String get integrationsComments => 'Комментарии';

  @override
  String get integrationsCommentsSub => 'Что agnts пишет в тикете';

  @override
  String get integrationsCQuestions => 'Вопросы agnts';

  @override
  String get integrationsCQuestionsHelp => 'Чтобы коллеги видели, что было неясно';

  @override
  String get integrationsCPlan => 'План перед разработкой';

  @override
  String get integrationsCPr => 'Ссылка на пул-реквест';

  @override
  String get integrationsCSummary => 'Описание изменений';

  @override
  String get integrationsCStatus => 'Паузы из-за лимита тарифа';

  @override
  String get integrationsSync => 'Синхронизация';

  @override
  String get integrationsSyncNow => 'Синхронизировать';

  @override
  String integrationsSynced(String found, String created, String updated, String waiting) {
    return 'Открытых задач для вас: $found, новых: $created, обновлено: $updated, изменились после начала работы: $waiting';
  }

  @override
  String get integrationsSyncHelp =>
      'Jira сразу отправляет новые тикеты на вебхук; agnts также проверяет каждый час на случай пропущенной доставки.';

  @override
  String get integrationsWebhook => 'Вебхук';

  @override
  String integrationsSaved(String name) {
    return 'Настройки $name сохранены';
  }

  @override
  String get integrationsSecretsHelp =>
      'agnts читает только тикеты, подходящие под запрос, и пишет только те изменения статуса и комментарии, которые вы здесь включили.';

  @override
  String get integrationsGithubHelp =>
      'Используйте токен аккаунта, который может отправлять в ваши репозитории. Автор коммитов — имя и email из настроек.';

  @override
  String get integrationsClaudeHelp => 'Токен действует около года. Обновите его через `claude setup-token` до истечения срока.';

  @override
  String get integrationsName_telegram => 'Telegram';

  @override
  String get integrationsDesc_telegram =>
      'Сообщения, когда нужно ваше участие. Отвечайте на вопросы, одобряйте или запрашивайте изменения прямо в чате.';

  @override
  String get integrationsConnectSub_telegram =>
      'Создайте бота через @BotFather, вставьте его токен и укажите ваш chat id. agnts сам зарегистрирует вебхук.';

  @override
  String get integrationsTokenOpen_telegram => 'Открыть @BotFather';

  @override
  String get integrationsChatIdFind => 'Узнать мой chat id';

  @override
  String get integrationsTokenStep1_telegram =>
      'В Telegram откройте @BotFather (кнопка ниже), отправьте /newbot и задайте имя и username, оканчивающийся на bot.';

  @override
  String get integrationsTokenStep2_telegram =>
      'BotFather пришлёт токен бота (вида 123456789:AA…). Вставьте его в поле «Токен доступа» ниже.';

  @override
  String get integrationsTokenStep3_telegram => 'Откройте нового бота в Telegram и нажмите Start, чтобы у него было ваше сообщение.';

  @override
  String get integrationsTokenStep4_telegram =>
      'Нажмите «Узнать мой chat id» (кнопка появится после вставки токена). На открывшейся странице найдите \"chat\" и скопируйте число после \"id\" в поле chat id. Если сообщений нет, напишите боту ещё раз и обновите страницу.';

  @override
  String get integrationsChatId => 'Ваш chat id';

  @override
  String get integrationsChatIdHelp => 'Чат, которому разрешено пользоваться ботом. Действовать может только он.';

  @override
  String get integrationsTelegramHelp => 'Одобрение и отклонение требуют подтверждения, которое действует 10 минут.';

  @override
  String integrationsTelegramHttps(String url) {
    return 'Telegram отправляет обновления только на публичный HTTPS-адрес, а этот agnts работает на $url, поэтому подключение здесь не получится. Подключите Telegram на развёртывании с HTTPS, где AGNTS_PUBLIC_URL — адрес https://.';
  }

  @override
  String get integrationsName_gitlab => 'GitLab';

  @override
  String get integrationsDesc_gitlab => 'Клонирует код, отправляет ветки и открывает merge request на gitlab.com или вашем GitLab.';

  @override
  String get integrationsConnectSub_gitlab => 'Создайте персональный токен с правами ниже и вставьте его сюда.';

  @override
  String get integrationsTokenOpen_gitlab => 'Открыть страницу токенов GitLab';

  @override
  String get integrationsTokenStep1_gitlab =>
      'Сначала укажите адрес сервера ниже. Затем в GitLab откройте аватар → Edit profile → Access tokens → Add new token (или используйте кнопку ниже).';

  @override
  String get integrationsTokenStep2_gitlab =>
      'Задайте имя (например, agnts) и срок действия. Используйте аккаунт с правом пуша в ваши проекты.';

  @override
  String get integrationsTokenStep3_gitlab => 'Отметьте области api, read_repository и write_repository.';

  @override
  String get integrationsTokenStep4_gitlab =>
      'Нажмите Create token, скопируйте токен (начинается с glpat-) и вставьте ниже. GitLab показывает его только один раз.';

  @override
  String get integrationsGitlabUrl => 'Адрес инстанса';

  @override
  String get integrationsGitlabUrlHelp => 'https://gitlab.com или ваш сервер GitLab.';

  @override
  String get integrationsGlApi => 'Полный доступ к API. Открывать merge request и читать пайплайны.';

  @override
  String get integrationsGlRead => 'Клонировать код.';

  @override
  String get integrationsGlWrite => 'Отправлять ветки.';

  @override
  String get integrationsGitlabHelp =>
      'Используйте токен аккаунта с правом пуша в ваши проекты. Контейнеры запусков его не видят; пуш выполняется на сервере после вашего одобрения.';

  @override
  String get integrationsMapMerged => 'Когда пул-реквест смёржен';

  @override
  String get integrationsGitWebhookSteps_github =>
      'В репозитории (или организации) откройте Settings → Webhooks → Add webhook. Content type application/json, вставьте URL и секрет ниже.';

  @override
  String get integrationsGitWebhookSteps_gitlab =>
      'В проекте откройте Settings → Webhooks. Вставьте URL, а секрет ниже — в поле Secret token.';

  @override
  String get integrationsGitEvents_github => 'Pull requests, Workflow runs';

  @override
  String get integrationsGitEvents_gitlab => 'Merge request events, Pipeline events';

  @override
  String get integrationsGitWebhookWhy =>
      'Когда пул- или merge request смёржен, agnts отмечает тикет и переводит задачу Jira или Plane в статус, выбранный на странице трекера. События пайплайнов обновляют страницу репозитория.';

  @override
  String get integrationsName_plane => 'Plane';

  @override
  String get integrationsDesc_plane => 'Берёт задачи с меткой agnts из Plane Cloud или вашего собственного Plane и обновляет их состояние.';

  @override
  String get integrationsConnectSub_plane =>
      'Используйте персональный токен доступа Plane. Работает с Plane Cloud и с Plane на своём сервере.';

  @override
  String get integrationsTokenOpen_plane => 'Открыть документацию API Plane';

  @override
  String get integrationsTokenStep1_plane =>
      'Войдите в Plane под пользователем, от имени которого будет действовать agnts (комментарии появятся под этим именем), и откройте Profile settings → Personal access tokens.';

  @override
  String get integrationsTokenStep2_plane =>
      'Нажмите Add personal access token, задайте имя (например, agnts) и срок действия, затем скопируйте токен. Plane покажет его только один раз.';

  @override
  String get integrationsTokenStep3_plane =>
      'В поле «Адрес API» оставьте https://api.plane.so для Plane Cloud или укажите адрес вашего Plane, если он на своём сервере.';

  @override
  String get integrationsTokenStep4_plane =>
      'В поле «Рабочее пространство» укажите slug из адреса Plane: acme в app.plane.so/acme/projects.';

  @override
  String get integrationsPlaneBaseUrl => 'Адрес API';

  @override
  String get integrationsPlaneBaseUrlHelp => 'https://api.plane.so для Plane Cloud или адрес вашего Plane';

  @override
  String get integrationsPlaneWorkspace => 'Рабочее пространство';

  @override
  String get integrationsPlaneWorkspaceHelp => 'Slug из адреса Plane, например acme';

  @override
  String get integrationsApiKey => 'Ключ API';

  @override
  String get integrationsApiKeyHelp => 'Profile settings → Personal access tokens';

  @override
  String get integrationsPlaneWebhookTitle => 'Настройте вебхук Plane';

  @override
  String get integrationsPlaneWebhookSteps =>
      'В Plane откройте Workspace settings → Webhooks → Add webhook, укажите адрес ниже и отметьте события задач (issues). Plane один раз покажет секрет — вставьте его сюда.';

  @override
  String get integrationsPlaneEventsValue => 'Задачи (issues)';

  @override
  String get integrationsPlaneSecret => 'Секрет из Plane';

  @override
  String get integrationsPlaneSecretHelp => 'Plane показывает его один раз при создании вебхука';

  @override
  String get integrationsPlaneSecretSave => 'Сохранить секрет';

  @override
  String get integrationsPlaneSecretReplace => 'Заменить секрет';

  @override
  String get integrationsPlaneSecretSaved => 'Секрет вебхука сохранён: доставки из Plane теперь принимаются';

  @override
  String get integrationsPlaneSecretSet => 'Секрет сохранён. Доставки принимаются.';

  @override
  String get integrationsPlaneSecretMissing =>
      'Секрета пока нет: agnts отклоняет доставки, пока вы не вставите секрет из Plane, и задачи подхватывает только ежечасная синхронизация.';

  @override
  String integrationsPlaneQueryText(String labels) {
    return 'Открытые задачи в проектах Plane, привязанных к репозиториям, с одной из меток: $labels';
  }

  @override
  String get integrationsPlaneNoProjects =>
      'Ни один репозиторий ещё не привязан к проекту Plane. Укажите идентификатор проекта (WEB в WEB-123) в настройках репозитория.';

  @override
  String get integrationsPlaneStatusesSub =>
      'Как agnts переводит задачи. «По умолчанию» — первое состояние подходящей группы; «на ревью» — только в выбранное вами состояние.';

  @override
  String integrationsPlaneStateDefault(String group) {
    return 'По умолчанию: первое состояние $group';
  }

  @override
  String get integrationsPlaneStateNone => 'Не менять';

  @override
  String integrationsPlaneStatesError(String error) {
    return 'Не удалось получить состояния из Plane: $error';
  }

  @override
  String get integrationsPlaneSyncHelp =>
      'Plane сразу отправляет изменения на вебхук; agnts также проверяет раз в час на случай пропущенной доставки.';

  @override
  String get integrationsPlaneHelp =>
      'agnts читает только задачи со своими метками в привязанных проектах и пишет только те смены состояний и комментарии, которые вы включили здесь. Plane разрешает 60 запросов API в минуту на ключ; agnts держится в пределах 50.';

  @override
  String integrationsPlaneSynced(String found, String created) {
    return '$found открытых задач, $created новых';
  }

  @override
  String get integrationsName_openai => 'OpenAI';

  @override
  String get integrationsDesc_openai =>
      'Ключ OpenAI API для запусков в Codex CLI, втором инструменте agnts для кода. Чтобы использовать его, выберите модель codex: в настройках.';

  @override
  String get integrationsConnectSub_openai =>
      'Вставьте ключ OpenAI API. agnts проверит его, сохранит в зашифрованном виде и будет передавать только запускам на Codex.';

  @override
  String get integrationsTokenOpen_openai => 'Открыть API-ключи';

  @override
  String get integrationsTokenStep1_openai => 'Откройте страницу API-ключей платформы OpenAI (кнопка ниже) и войдите.';

  @override
  String get integrationsTokenStep2_openai => 'Создайте новый секретный ключ, лучше в проекте с лимитом расходов.';

  @override
  String get integrationsTokenStep3_openai => 'Скопируйте ключ (он начинается с sk-) и вставьте его в поле «Ключ API» ниже.';

  @override
  String get integrationsTokenStep4_openai =>
      'В «Настройки → Превью» добавьте api.openai.com в разрешённые хосты, чтобы запуски Codex могли обращаться к OpenAI.';

  @override
  String get integrationsOpenaiKeyHelp => 'Хранится в зашифрованном виде на вашем сервере. Его получают только запуски на Codex.';

  @override
  String get integrationsOpenaiHelp =>
      'В запусках Codex нет хуков agnts-guard: проверки agnts после запуска (красные флаги, сборка, линтер, тесты, ревью) работают как обычно. Запускам также нужен api.openai.com в разрешённых хостах.';

  @override
  String get kindTitle => 'Тип';

  @override
  String get kindAuto => 'Авто';

  @override
  String get kindAutoHint => 'agnts сам определит тип, когда прочитает тикет';

  @override
  String get kindCode => 'Код';

  @override
  String get kindCodeHint => 'Внести изменение в код. Нужен репозиторий; итог — pull request.';

  @override
  String get kindTest => 'Тесты';

  @override
  String get kindTestHint => 'Написать или исправить автотесты. Нужен репозиторий; итог — pull request.';

  @override
  String get kindPlan => 'План';

  @override
  String get kindPlanHint => 'Написать план реализации. Код не меняется; итог — отчёт.';

  @override
  String get kindAnalysis => 'Анализ';

  @override
  String get kindAnalysisHint => 'Исследовать вопрос и описать выводы. Код не меняется.';

  @override
  String get kindBug => 'Разбор бага';

  @override
  String get kindBugHint => 'Найти причину бага и предложить исправление. Код не меняется.';

  @override
  String get kindPickerHint => 'Что сделает agnts. Выбранный тип не меняется; при «Авто» agnts решит сам, когда прочитает тикет.';

  @override
  String kindSwitchTo(String kind) {
    return 'Сменить на «$kind»';
  }

  @override
  String get kindReview => 'Ревью PR';

  @override
  String get kindReviewHint => 'Проверить пул-реквест, который открыл кто-то другой. Приходит из GitHub или GitLab.';

  @override
  String get kindSwaggertest => 'Тест Swagger';

  @override
  String get kindSwaggertestHint =>
      'Проверить HTTP API по его спецификации Swagger/OpenAPI. Репозиторий не обязателен; результат — таблица проверок и отчёт.';

  @override
  String get learnTitle => 'Обучение';

  @override
  String get learnLede =>
      'Когда изменение от agnts делает то, чего в этом коде раньше не было, agnts объясняет это здесь: что это, зачем понадобилось, где смотреть, и короткий тест.';

  @override
  String learnViewNew(String n) {
    return 'Новые ($n)';
  }

  @override
  String get learnViewLearned => 'Изученные';

  @override
  String learnViewAll(String n) {
    return 'Все ($n)';
  }

  @override
  String get learnViewLabel => 'Показать';

  @override
  String get learnAllRepos => 'Все репозитории';

  @override
  String get learnRepoLabel => 'Репозиторий';

  @override
  String get learnNone =>
      'Уроков пока нет. Когда agnts отправит изменение, которое делает что-то новое для репозитория, урок появится здесь.';

  @override
  String get learnNoneNew => 'Всё изучено: каждый урок отмечен.';

  @override
  String get learnNoMatch => 'Нет уроков по этому запросу.';

  @override
  String learnFromTicket(String key) {
    return 'Из $key';
  }

  @override
  String learnQuizCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n вопроса',
      many: '$n вопросов',
      few: '$n вопроса',
      one: '$n вопрос',
    );
    return '$_temp0';
  }

  @override
  String get learnNewBadge => 'Новый';

  @override
  String get learnLearned => 'Изучено';

  @override
  String get learnMarkLearned => 'Отметить как изученное';

  @override
  String get learnMarkUnlearned => 'Снять отметку';

  @override
  String get learnMarkedLearned => 'Отмечено как изученное';

  @override
  String get learnBack => 'К урокам';

  @override
  String get learnNotFound => 'Такого урока нет.';

  @override
  String get learnWhatTitle => 'Что это';

  @override
  String get learnWhyTitle => 'Зачем это понадобилось';

  @override
  String get learnWhereTitle => 'Где смотреть';

  @override
  String learnWhereSub(String repo, String key) {
    return 'Файлы в $repo на момент $key.';
  }

  @override
  String get learnQuizTitle => 'Проверьте себя';

  @override
  String get learnQuizSub => 'Выберите ответ, чтобы узнать, верен ли он.';

  @override
  String get learnCorrect => 'Верно.';

  @override
  String get learnWrong => 'Не совсем.';

  @override
  String learnScore(String right, String total) {
    return 'Верно: $right из $total';
  }

  @override
  String get learnRetry => 'Пройти ещё раз';

  @override
  String get learnReadingTitle => 'Что почитать';

  @override
  String get learnReadingNote => 'Ссылки предложил Claude. Проверьте их, прежде чем на них полагаться.';

  @override
  String get learnCategory_pattern => 'Паттерн';

  @override
  String get learnCategory_architecture => 'Архитектура';

  @override
  String get learnCategory_algorithm => 'Алгоритм';

  @override
  String get learnCategory_library => 'Библиотека';

  @override
  String get learnCategory_language => 'Язык';

  @override
  String get learnCategory_testing => 'Тестирование';

  @override
  String get learnCategory_security => 'Безопасность';

  @override
  String get learnCategory_performance => 'Производительность';

  @override
  String get learnCategory_tooling => 'Инструменты';

  @override
  String get learnCategory_other => 'Другое';

  @override
  String get learnLevel_beginner => 'Начальный';

  @override
  String get learnLevel_intermediate => 'Средний';

  @override
  String get learnLevel_advanced => 'Продвинутый';

  @override
  String get learnTicketTitle => 'Что нового в этом изменении';

  @override
  String get learnTicketSub => 'Приёмы, которые это изменение впервые принесло в репозиторий.';

  @override
  String get learnTicketPending => 'agnts изучает это изменение: нет ли в нём того, чего в репозитории ещё не было.';

  @override
  String get learnTicketNone => 'Ничего нового: изменение использует только уже знакомые репозиторию приёмы.';

  @override
  String get learnTicketFailed => 'agnts не смог разобрать это изменение. Причина — в логе.';

  @override
  String get learnTicketIdle => 'agnts ещё не искал уроков в этом изменении.';

  @override
  String get learnLearnNow => 'Найти новое';

  @override
  String get learnLearnAgain => 'Посмотреть ещё раз';

  @override
  String get learnQueued => 'В очереди: agnts поищет в этом изменении что-то новое.';

  @override
  String get learnQueueTitle => 'Очередь обучения';

  @override
  String get learnQueueSub => 'Отправленные тикеты, в которых agnts ищет новые приёмы — по одному, когда тикетам не нужен исполнитель.';

  @override
  String get learnStatus_running => 'Изучается';

  @override
  String get learnStatus_pending => 'В очереди';

  @override
  String get learnStatus_failed => 'Ошибка';

  @override
  String get learnStatus_none => 'Ещё не изучен';

  @override
  String learnQueuePosition(String n) {
    return '№$n в очереди';
  }

  @override
  String get learnQueueBtn => 'Изучить';

  @override
  String get learnRetryBtn => 'Повторить';

  @override
  String learnQueueAll(String n) {
    return 'Изучить все ($n)';
  }

  @override
  String learnQueuedAll(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n тикета в очереди',
      many: '$n тикетов в очереди',
      few: '$n тикета в очереди',
      one: '$n тикет в очереди',
    );
    return '$_temp0';
  }

  @override
  String learnReadTime(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n минуты чтения',
      many: '$n минут чтения',
      few: '$n минуты чтения',
      one: '$n минута чтения',
    );
    return '$_temp0';
  }

  @override
  String get learnQueueLede =>
      'Отправленные тикеты, в которых agnts ищет приёмы, которых в коде раньше не было. Поставьте в очередь любой завершённый тикет или повторите неудачный.';

  @override
  String get learnQueueEmpty => 'Сейчас изучать нечего: все отправленные тикеты прочитаны.';

  @override
  String get logsTitle => 'Логи';

  @override
  String get logsLede =>
      'Каждый шаг agnts записывается в момент выполнения. Здесь видно, куда уходит время и почему запуски останавливаются.';

  @override
  String get logsLive => 'В эфире';

  @override
  String get logsExportJson => 'Экспорт JSON';

  @override
  String get logsExportCsv => 'Экспорт CSV';

  @override
  String get logsRunsStarted => 'Запусков начато';

  @override
  String get logsRunsNote => 'Сессии разработки, включая повторы';

  @override
  String get logsReached => 'Дошли до ревью';

  @override
  String logsReachedNote(String n, String total) {
    return '$n из $total запусков прошли тесты';
  }

  @override
  String get logsAvgTurns => 'Среднее число шагов';

  @override
  String get logsAvgTurnsNote => 'На тикет';

  @override
  String get logsStops => 'Остановки и паузы';

  @override
  String logsStopsNote(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'всего $n события с ошибкой',
      many: 'всего $n событий с ошибкой',
      few: 'всего $n события с ошибкой',
      one: 'всего $n событие с ошибкой',
    );
    return '$_temp0';
  }

  @override
  String get logsPeriod => 'Последние 30 дней';

  @override
  String get logsWhereTime => 'Куда уходит время';

  @override
  String get logsWhereTimeSub => 'Среднее время на каждом шаге по всем тикетам и задачам';

  @override
  String get logsNoData => 'Нет данных';

  @override
  String get logsLegendAgnts => 'agnts работает';

  @override
  String get logsLegendYou => 'Ожидание вас';

  @override
  String get logsEventsTitle => 'События';

  @override
  String logsEventsSub(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Показано $n события',
      many: 'Показано $n событий',
      few: 'Показано $n события',
      one: 'Показано $n событие',
    );
    return '$_temp0, сначала новые. Нажмите на строку, чтобы увидеть данные.';
  }

  @override
  String get logsTabAll => 'Все';

  @override
  String get logsTabState => 'Смена статусов';

  @override
  String get logsTabTool => 'Вызовы инструментов';

  @override
  String get logsTabCommand => 'Команды';

  @override
  String get logsTabUser => 'Ваши действия';

  @override
  String get logsTabLimit => 'Лимиты тарифа';

  @override
  String get logsTabProblems => 'Предупреждения и ошибки';

  @override
  String get logsKeyFilter => 'Ключ тикета, например PAY-214';

  @override
  String get logsKeyFilterLabel => 'Фильтр по ключу тикета';

  @override
  String get logsErrorsOnly => 'Только ошибки';

  @override
  String get logsClear => 'Сбросить фильтры';

  @override
  String get logsColTime => 'Время';

  @override
  String get logsColTicket => 'Тикет';

  @override
  String get logsColStep => 'Шаг';

  @override
  String get logsColType => 'Тип';

  @override
  String get logsColEvent => 'Событие';

  @override
  String get logsColDuration => 'Длительность';

  @override
  String get logsNoEvents => 'Нет событий по этим фильтрам.';

  @override
  String get logsNoDetail => 'Для этого события нет дополнительных данных.';

  @override
  String get logsShowMore => 'Показать ещё';

  @override
  String get logsTypeState => 'Статус';

  @override
  String get logsTypeTool => 'Инструмент';

  @override
  String get logsTypeCommand => 'Команда';

  @override
  String get logsTypeYou => 'Вы';

  @override
  String get logsTypeLimit => 'Лимит';

  @override
  String get logsTypeError => 'Ошибка';

  @override
  String get logsTypeEvent => 'Событие';

  @override
  String get maccountPasswordInstead => 'Войти с паролем';

  @override
  String get maccountGoogleInstead => 'Продолжить через Google';

  @override
  String get maccountSetupLede =>
      'Админы входят с двумя факторами. Добавьте аккаунт в приложение-аутентификатор по секрету ниже (или откройте ссылку настройки на этом телефоне), затем введите 6-значный код из него.';

  @override
  String get maccountTotpOpen => 'Открыть в аутентификаторе';

  @override
  String get maccountLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get maccountCurrent => 'Текущее';

  @override
  String get maccountHaveInvite => 'Есть приглашение?';

  @override
  String get maccountInviteHint => 'Вставьте ссылку-приглашение';

  @override
  String get maccountInviteOpen => 'Открыть приглашение';

  @override
  String maccountJoined(String date) {
    return 'С $date';
  }

  @override
  String get maccountPaying => 'Завершите оплату в браузере. Кредиты появятся здесь, как только платёжная система подтвердит платёж.';

  @override
  String maccountChars(String n, String max) {
    return '$n / $max';
  }

  @override
  String manalyticsTickets(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n тикета', many: '$n тикетов', few: '$n тикета', one: '$n тикет');
    return '$_temp0';
  }

  @override
  String manalyticsTurns(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n шага', many: '$n шагов', few: '$n шага', one: '$n шаг');
    return '$_temp0';
  }

  @override
  String manalyticsShareOfRuns(String n) {
    return '$n% запусков';
  }

  @override
  String manalyticsReachedReview(String n) {
    return '$n% дошли до ревью';
  }

  @override
  String get manalyticsAbout => 'Об аналитике';

  @override
  String manalyticsStopped(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n остановленного запуска за период',
      many: '$n остановленных запусков за период',
      few: '$n остановленных запуска за период',
      one: '$n остановленный запуск за период',
    );
    return '$_temp0';
  }

  @override
  String manalyticsDays(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n дня', many: '$n дней', few: '$n дня', one: '$n день');
    return '$_temp0';
  }

  @override
  String manalyticsCompared(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n днями', many: '$n днями', few: '$n днями', one: '$n днём');
    return 'Изменения сравниваются с предыдущими $_temp0. Зелёный — лучше.';
  }

  @override
  String get massistantTitle => 'Ассистент';

  @override
  String get massistantFab => 'Спросить ассистента';

  @override
  String get massistantMoreRow => 'Ассистент';

  @override
  String get massistantMoreRowSub => 'Вопросы о рабочем пространстве';

  @override
  String get massistantPlaceholder => 'Спросите о задачах, CI, расходах…';

  @override
  String get massistantSend => 'Отправить';

  @override
  String massistantCount(String n) {
    return '$n / 1000';
  }

  @override
  String get massistantNewConversation => 'Новый разговор';

  @override
  String get massistantHistory => 'Разговоры';

  @override
  String get massistantHistoryEmpty => 'Разговоров пока нет.';

  @override
  String get massistantDelete => 'Удалить';

  @override
  String get massistantDeleted => 'Разговор удалён';

  @override
  String get massistantEmptyTitle => 'Спросите agnts о работе';

  @override
  String get massistantEmptyText =>
      'Ассистент отвечает по вашим задачам, CI и расходам и даёт ссылки на то, о чём говорит. Он ничего не запускает, не одобряет и не отклоняет.';

  @override
  String get massistantPrivate => 'Ваши разговоры видите только вы. Они хранятся 30 дней.';

  @override
  String get massistantSuggestWaiting => 'Что ждёт меня?';

  @override
  String get massistantSuggestCi => 'Почему CI красный?';

  @override
  String get massistantSuggestSpend => 'Сколько мы потратили на этой неделе?';

  @override
  String get massistantSuggestDone => 'Что agnts закончил на этой неделе?';

  @override
  String massistantThinking(String seconds) {
    return 'Думаю… $seconds с';
  }

  @override
  String massistantReading(String what) {
    return 'Читаю $what';
  }

  @override
  String get massistantFileInbox => 'входящие';

  @override
  String get massistantFileTickets => 'задачи';

  @override
  String massistantFileTicket(String key) {
    return '$key';
  }

  @override
  String get massistantFileCi => 'сбои CI';

  @override
  String get massistantFileUsage => 'лимиты плана';

  @override
  String get massistantFileAnalytics => 'аналитику';

  @override
  String get massistantFileRepos => 'репозитории';

  @override
  String get massistantFileLessons => 'уроки';

  @override
  String get massistantFileConversation => 'разговор';

  @override
  String get massistantFileQuestion => 'ваш вопрос';

  @override
  String get massistantFileOther => 'рабочее пространство';

  @override
  String get massistantFailed => 'Нет ответа';

  @override
  String get massistantAskAgain => 'Спросить ещё раз';

  @override
  String massistantLinkCi(String id) {
    return 'CI #$id';
  }

  @override
  String massistantLinkLesson(String id) {
    return 'Урок #$id';
  }

  @override
  String massistantTook(String seconds) {
    return '$seconds с';
  }

  @override
  String get massistantHelpful => 'Полезно';

  @override
  String get massistantNotHelpful => 'Не помогло';

  @override
  String get massistantRateTitle => 'Как вам ответ?';

  @override
  String get massistantRateComment => 'Что было не так или чего не хватило? (необязательно)';

  @override
  String get massistantRateShare => 'Сохранить данные этого вопроса, чтобы agnts проверял на нём ответы получше';

  @override
  String get massistantRateNote => 'Оценку, комментарий, вопрос и ответ увидит владелец рабочего пространства.';

  @override
  String get massistantRateSend => 'Отправить';

  @override
  String get massistantRateClear => 'Убрать оценку';

  @override
  String get massistantRated => 'Спасибо за оценку';

  @override
  String get massistantStatsTitle => 'Ассистент';

  @override
  String get massistantStatsQuestions => 'Вопросы';

  @override
  String get massistantStatsAnswered => 'Отвечено';

  @override
  String get massistantStatsMedian => 'Медианное время';

  @override
  String get massistantStatsHelpful => 'Полезно';

  @override
  String get massistantStatsTokens => 'Токены';

  @override
  String massistantStatsPeople(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'спросили $n человека',
      many: 'спросили $n человек',
      few: 'спросили $n человека',
      one: 'спросил $n человек',
    );
    return '$_temp0';
  }

  @override
  String get massistantStatsVersions => 'По версиям промптов';

  @override
  String massistantStatsVersionRow(String answered, String failed, String up, String down, String median) {
    return '$answered отвечено · $failed сбоев · $up 👍 $down 👎 · $median';
  }

  @override
  String get massistantStatsNone => 'За этот период вопросов не было.';

  @override
  String get massistantStatsRated => 'Оценённые ответы';

  @override
  String get massistantRatedEmpty => 'Оценённых ответов пока нет.';

  @override
  String get massistantRatedShared => 'Сохранён для проверки промптов';

  @override
  String massistantStatsParts(String start, String snapshot, String claude) {
    return 'Контейнер $start · данные $snapshot · Claude $claude';
  }

  @override
  String massistantStatsWarm(String n, String total) {
    return '$n из $total — в уже запущенном контейнере';
  }

  @override
  String get massistantStatsSeeRated => 'Оценённые ответы';

  @override
  String get massistantDeleteTitle => 'Удалить этот разговор?';

  @override
  String get massistantDeleteText => 'Его вопросы и ответы будут удалены навсегда.';

  @override
  String get massistantSendHint => 'Enter — отправить, Shift+Enter — новая строка';

  @override
  String get massistantConversationsLede => 'Ваши вопросы и ответы ассистента. Их видите только вы; они хранятся 30 дней.';

  @override
  String get massistantOpenChat => 'Открыть чат';

  @override
  String get mciTitle => 'Сбои CI';

  @override
  String get mciLede => 'Отслеживаемые ветки, которые покраснели: одна строка на ошибку.';

  @override
  String get mciFilterRed => 'Красные';

  @override
  String get mciFilterFlaky => 'Нестабильные';

  @override
  String get mciFilterAll => 'Все';

  @override
  String get mciEmptyRed => 'Ни одна отслеживаемая ветка не красная.';

  @override
  String get mciEmpty => 'Здесь нет сбоев CI.';

  @override
  String get mciStatus_triage => 'Проверка';

  @override
  String get mciStatus_open => 'Красная';

  @override
  String get mciStatus_fixing => 'Исправляется';

  @override
  String get mciStatus_fixed => 'Исправлено';

  @override
  String get mciStatus_resolved => 'Снова зелёная';

  @override
  String get mciStatus_flaky => 'Нестабильный';

  @override
  String get mciStatus_infra => 'Инфраструктура';

  @override
  String get mciStatus_muted => 'Заглушено';

  @override
  String get mciStatus_regression => 'Вернулся';

  @override
  String mciLastSeen(String when) {
    return 'последний $when';
  }

  @override
  String get mciFactFirstCommit => 'Первый упавший коммит';

  @override
  String get mciFactCount => 'Падал';

  @override
  String mciTimes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раза', many: '$n раз', few: '$n раза', one: '$n раз');
    return '$_temp0';
  }

  @override
  String get mciFactLastSeen => 'Последний раз';

  @override
  String get mciFactFlaky => 'Прошёл при перезапуске';

  @override
  String get mciJob => 'Задача';

  @override
  String get mciBranch => 'Ветка';

  @override
  String get mciFirstError => 'Первая ошибка';

  @override
  String get mciLogTail => 'Конец лога';

  @override
  String get mciLogNote => 'Из лога задачи, секреты удалены.';

  @override
  String get mciNoSample => 'Для этого сбоя фрагмент лога не сохранён.';

  @override
  String get mciRuns => 'Упавшие запуски';

  @override
  String mciRunsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n упавшего запуска',
      many: '$n упавших запусков',
      few: '$n упавших запуска',
      one: '$n упавший запуск',
    );
    return '$_temp0';
  }

  @override
  String get mciRunFlaky => 'прошёл при перезапуске';

  @override
  String get mciTicket => 'Тикет';

  @override
  String mciForeignPr(String n) {
    return 'Этот сбой в чужом пул-реквесте (#$n): там agnts только оставляет комментарии.';
  }

  @override
  String get mciFix => 'Исправить';

  @override
  String get mciFixConfirm =>
      'agnts откроет тикет, чтобы исправить этот сбой. Вы проверите исправление до того, как что-либо будет отправлено.';

  @override
  String get mciMute => 'Заглушить';

  @override
  String get mciUnmute => 'Включить';

  @override
  String get mciMutedDone => 'Заглушено: agnts не трогает этот сбой, пока вы его не включите.';

  @override
  String get mciUnmutedDone => 'Снова включено.';

  @override
  String get mciRerun => 'Перезапустить';

  @override
  String get mciRerunDone => 'Перезапуск начат.';

  @override
  String get mciCardTitle => 'Сбой CI';

  @override
  String get mciCardOpen => 'Открыть сбой CI';

  @override
  String mciCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'CI вернул пул-реквест $n раза',
      many: 'CI вернул пул-реквест $n раз',
      few: 'CI вернул пул-реквест $n раза',
      one: 'CI вернул пул-реквест $n раз',
    );
    return '$_temp0';
  }

  @override
  String get mciSourceCi => 'CI';

  @override
  String get mciNotify => 'Отслеживаемая ветка покраснела';

  @override
  String get mcpTitle => 'Чат Claude (MCP)';

  @override
  String get mcpSub => 'Управляйте agnts из Claude в браузере, на компьютере и телефоне';

  @override
  String get mcpUrl => 'URL коннектора';

  @override
  String get mcpConnections => 'Подключённые приложения Claude';

  @override
  String get mcpStaticToken => 'Статический токен';

  @override
  String get mcpSet => 'Задан';

  @override
  String get mcpNotSet => 'Не задан';

  @override
  String get mcpHowTo =>
      'В Claude откройте «Настройки» → «Коннекторы» → «Добавить свой коннектор» и вставьте URL. Claude откроет эту страницу для подтверждения. В чате любое изменение (ответы, одобрение, отклонение, новые задачи) сначала готовится и выполняется только после вашего подтверждения. Для Claude Code или Claude Desktop можно использовать статический токен в заголовке Authorization: Bearer.';

  @override
  String get mcpNewToken => 'Новый токен';

  @override
  String get mcpShownOnce => 'Скопируйте сейчас: он показывается один раз. Предыдущий токен больше не работает.';

  @override
  String get mcpCreate => 'Создать статический токен';

  @override
  String get mcpRotate => 'Заменить статический токен';

  @override
  String get mcpRevoke => 'Отключить все';

  @override
  String get mcpRevokeConfirm => 'Отключить все приложения Claude и удалить статический токен?';

  @override
  String get mcpRevoked => 'Все подключения Claude удалены';

  @override
  String get mcpConsentTitle => 'Подключить Claude к agnts';

  @override
  String mcpConsentAsk(String client, String user) {
    return '$client хочет работать с agnts от имени $user.';
  }

  @override
  String get mcpConsentWhat =>
      'Он сможет читать тикеты, логи, лимиты и репозитории и готовить действия. Ничего не изменится, пока вы не подтвердите каждое действие в чате. Деплои, настройки и интеграции ему недоступны.';

  @override
  String mcpConsentRedirect(String host) {
    return 'Вы вернётесь на $host.';
  }

  @override
  String get mcpAllow => 'Разрешить';

  @override
  String get mcpDeny => 'Отклонить';

  @override
  String get mcpPickWorkspace => 'Рабочее пространство';

  @override
  String get mcpPickWorkspaceHelp => 'Claude действует в этом пространстве от вашего имени.';

  @override
  String get mdetailApprove => 'Одобрить';

  @override
  String get mdetailWorking => 'agnts работает. Вы получите уведомление, когда он будет ждать вас.';

  @override
  String get mdetailCopyPr => 'Скопировать ссылку на пул-реквест';

  @override
  String get mdetailCopied => 'Ссылка скопирована';

  @override
  String get mdetailFactTime => 'Время';

  @override
  String get mgroupsGroups => 'Группы';

  @override
  String get mgroupsRepos => 'Репозитории';

  @override
  String get mgroupsPickHint => 'Выберите один или несколько. Первый будет основным.';

  @override
  String get mgroupsInTask => 'В этой задаче';

  @override
  String mgroupsFromGroup(String name) {
    return 'Вся группа $name';
  }

  @override
  String mgroupsFromGroupEdited(String name) {
    return 'Из группы $name, изменено';
  }

  @override
  String get mgroupsPrimary => 'основной';

  @override
  String mgroupsRemove(String name) {
    return 'Убрать $name';
  }

  @override
  String get mgroupsNoMembers => 'В этой группе нет активных репозиториев.';

  @override
  String mgroupsGroup(String name) {
    return 'Группа $name';
  }

  @override
  String get mgroupsPartlyMerged => 'Влито частично';

  @override
  String get mgroupsArchived => 'в архиве';

  @override
  String mgroupsPushError(String error) {
    return 'Не удалось отправить: $error';
  }

  @override
  String mgroupsFiles(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n файла', many: '$n файлов', few: '$n файла', one: '$n файл');
    return '$_temp0';
  }

  @override
  String mgroupsCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n исправления CI',
      many: '$n исправлений CI',
      few: '$n исправления CI',
      one: '$n исправление CI',
    );
    return '$_temp0';
  }

  @override
  String get mgroupsStatePending => 'Ожидает';

  @override
  String get mgroupsStateUnchanged => 'Без изменений';

  @override
  String get mgroupsStatePushed => 'Отправлено';

  @override
  String get mgroupsStateMerged => 'Влито';

  @override
  String get mgroupsStateDropped => 'Закрыто';

  @override
  String mhomeRunningNote(String parallel, String queued) {
    return 'Одновременно: $parallel, в очереди: $queued';
  }

  @override
  String mhomeWaiting(String time) {
    return 'Ждёт $time';
  }

  @override
  String get mhomeActAnswers => 'Ответьте на вопросы agnts';

  @override
  String get mhomeActReview => 'Проверьте изменения';

  @override
  String get mhomeActStopped => 'Остановлено. Подскажите agnts, что попробовать';

  @override
  String get mhomeActResume => 'Возобновите, когда будете готовы';

  @override
  String get mhomeActStart => 'Ждёт в очереди. Нажмите, чтобы запустить';

  @override
  String get mhomeLiveFallback => 'Работает…';

  @override
  String get mhomeSearchEmpty => 'По вашему запросу тикетов нет.';

  @override
  String minsightsSaved(String name) {
    return '$name сохранён';
  }

  @override
  String get minsightsEditTask => 'Изменить задачу';

  @override
  String get minsightsEditTaskSub => 'Изменить можно только задачу, которая ещё не началась.';

  @override
  String get minsightsSave => 'Сохранить';

  @override
  String get minsightsTaskSaved => 'Задача сохранена';

  @override
  String minsightsTaskDeleted(String key) {
    return 'Задача $key удалена';
  }

  @override
  String get minsightsTaskActions => 'Действия с задачей';

  @override
  String get mmanageFillAll => 'Заполните обязательные поля.';

  @override
  String mmoreAgo(String time) {
    return '$time назад';
  }

  @override
  String get mmoreJustNow => 'только что';

  @override
  String get mmoreLangPhone => 'Язык телефона';

  @override
  String mmoreSignedInTo(String server) {
    return 'Вход на $server';
  }

  @override
  String get mmorePipelineRuns => 'Запуски пайплайнов';

  @override
  String get mmoreLoginLede => 'Войдите на свой сервер agnts, чтобы отвечать на вопросы, проверять изменения и следить за запусками.';

  @override
  String get mobileServer => 'Адрес сервера';

  @override
  String get mobileServerHint => 'https://agnts.example.com';

  @override
  String get mobileServerInvalid => 'Введите https-адрес вашего сервера agnts.';

  @override
  String get mobileHome => 'Главная';

  @override
  String get mobileActivity => 'Активность';

  @override
  String get mobileMore => 'Ещё';

  @override
  String mobileGreeting(String name) {
    return 'Привет, $name';
  }

  @override
  String get mobileNeedsYou => 'Ждёт вас';

  @override
  String get mobileRunningNow => 'Работает сейчас';

  @override
  String get mobileInQueue => 'В очереди';

  @override
  String get mobileNothingWaiting => 'Ничего не ждёт вашего ответа.';

  @override
  String get mobileNoRuns => 'Сейчас ничего не запущено.';

  @override
  String get mobileLiveRuns => 'Текущие запуски';

  @override
  String mobileTurnsOf(String turns, String max) {
    return '$turns из $max ходов';
  }

  @override
  String mobileWaitingFor(String time) {
    return 'ждёт $time';
  }

  @override
  String get mobileUsage => 'Лимиты тарифа';

  @override
  String get mobileSession => 'Текущая сессия';

  @override
  String get mobileWeek => 'Эта неделя';

  @override
  String get mobileRefresh => 'Обновить';

  @override
  String get mobilePaused => 'Новые запуски на паузе до сброса лимита.';

  @override
  String get mobileAppearance => 'Оформление';

  @override
  String get mobileTheme => 'Тема';

  @override
  String get mobileThemeSystem => 'Системная';

  @override
  String get mobileThemeLight => 'День';

  @override
  String get mobileThemeDark => 'Ночь';

  @override
  String get mobileLanguage => 'Язык';

  @override
  String get mobileDefaultModels => 'Модели по умолчанию';

  @override
  String get mobilePush => 'Push-уведомления';

  @override
  String get mobilePushOn => 'Отправлять на этот телефон';

  @override
  String get mobilePushNeeds => 'Когда нужно ваше участие';

  @override
  String get mobilePushStopped => 'Когда запуск остановился';

  @override
  String get mobilePushDone => 'Когда изменения отправлены';

  @override
  String get mobilePushUnavailable => 'Push не настроен на сервере.';

  @override
  String get mobileIntegrations => 'Интеграции';

  @override
  String get mobileRepositories => 'Репозитории';

  @override
  String get mobileConnected => 'Подключено';

  @override
  String get mobileNotConnected => 'Не подключено';

  @override
  String get mobileSaved => 'Сохранено';

  @override
  String get mobileSignOut => 'Выйти';

  @override
  String get mobileNewTask => 'Новая задача';

  @override
  String get mobileTaskTitle => 'Название';

  @override
  String get mobileTaskDescription => 'Что нужно сделать';

  @override
  String get mobileTaskRepo => 'Репозиторий';

  @override
  String get mobileTaskPriority => 'Приоритет';

  @override
  String get mobilePriorityLow => 'Низкий';

  @override
  String get mobilePriorityMedium => 'Средний';

  @override
  String get mobilePriorityHigh => 'Высокий';

  @override
  String get mobileAfterApprove => 'После одобрения';

  @override
  String get mobileAfterMain => 'Отправить в main';

  @override
  String get mobileAfterPr => 'Открыть пул-реквест';

  @override
  String get mobileStart => 'Как начать';

  @override
  String get mobileStartAsk => 'Сначала задать вопросы';

  @override
  String get mobileStartCode => 'Сразу писать код';

  @override
  String get mobileStartQueue => 'Оставить в очереди';

  @override
  String get mobileCreate => 'Создать';

  @override
  String get mobileNoSideRepos => 'Сначала добавьте репозиторий своего проекта в админке.';

  @override
  String get mobileNoTasks => 'Задач пока нет.';

  @override
  String get mobileNoEvents => 'Пока ничего нет.';

  @override
  String get mobileFilterAll => 'Все';

  @override
  String get mobileFilterProblems => 'Проблемы';

  @override
  String get mobileFilterYou => 'Ваши действия';

  @override
  String get mobileAnswer => 'Ответить';

  @override
  String get mobileReview => 'Ревью';

  @override
  String get mobileConfirm => 'Подтвердить';

  @override
  String get mobileCancel => 'Отмена';

  @override
  String get mobileRetry => 'Повторить';

  @override
  String get mobileStop => 'Остановить';

  @override
  String get mobileOffline => 'Нет связи с сервером. Потяните, чтобы повторить.';

  @override
  String get mobileOpenInBrowser => 'Открыть в браузере';

  @override
  String mobileVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get mobileBranches => 'Ветки';

  @override
  String get mobileCommits => 'Коммиты';

  @override
  String get mobilePipelines => 'Пайплайны';

  @override
  String get mobileDeploy => 'Задеплоить';

  @override
  String mobileDeployConfirm(String stage) {
    return 'Запустить $stage? Это деплой в рабочее окружение.';
  }

  @override
  String get mobileDeployStarted => 'Деплой запущен';

  @override
  String mobileAheadBehind(String ahead, String behind) {
    return '↑$ahead ↓$behind';
  }

  @override
  String get mobileCiOk => 'Пройдено';

  @override
  String get mobileCiFail => 'Упало';

  @override
  String get mobileCiRun => 'Выполняется';

  @override
  String get mobileCiWaiting => 'Ожидает';

  @override
  String get mobileCiManual => 'Ждёт вас';

  @override
  String get mobileCiNone => 'Нет пайплайна';

  @override
  String get mobileGitHostError => 'Git-хостинг вернул ошибку. Проверьте интеграцию.';

  @override
  String get mobileLastDays => 'Последние 7 дней';

  @override
  String get mobilePushed => 'Отправлено';

  @override
  String get mobileFirstTry => 'С первого раза';

  @override
  String get mobileWaitingAvg => 'Ожидание вас';

  @override
  String mobileMinutes(String n) {
    return '$n мин';
  }

  @override
  String get mobileAdminAppOnly => 'Это аккаунт администратора. Откройте его в приложении agnts admin.';

  @override
  String get mobileGoogleContinue => 'Продолжить с Google';

  @override
  String get mobileGoogleOff => 'Вход через Google на этом сервере выключен.';

  @override
  String get mobileGoogleSetup => 'Вход через Google не настроен в этой сборке приложения.';

  @override
  String get mpreviewTitle => 'Превью agnts';

  @override
  String get mpreviewSub => 'Скриншоты приложения с этим изменением. Совет рядом с вашей проверкой: он никогда не блокирует одобрение.';

  @override
  String get mpreviewPending => 'В очереди: agnts запустит приложение и сделает скриншоты, как только освободится исполнитель.';

  @override
  String get mpreviewRunning => 'agnts запускает приложение и делает скриншоты…';

  @override
  String get mpreviewFailed => 'Превью не удалось. Проверьте приложение сами или запустите снова.';

  @override
  String get mpreviewAppFailed => 'Приложение не запустилось, поэтому скриншотов нет. Конец его лога:';

  @override
  String mpreviewStale(String n) {
    return 'Это скриншоты ревизии $n; с тех пор работа изменилась.';
  }

  @override
  String get mpreviewRun => 'Сделать скриншоты';

  @override
  String get mpreviewRunAgain => 'Запустить снова';

  @override
  String get mpreviewCompare => 'Сравнить с основной веткой';

  @override
  String get mpreviewCompareHelp => 'Также делает те же скриншоты без этого изменения.';

  @override
  String get mpreviewStatus_ok => 'Готово';

  @override
  String get mpreviewStatus_partial => 'Частично';

  @override
  String get mpreviewStatus_failed => 'Не запустилось';

  @override
  String mpreviewModel(String model) {
    return 'Проверил $model';
  }

  @override
  String mpreviewIssues(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count проблемы',
      many: '$count проблем',
      few: '$count проблемы',
      one: '$count проблема',
      zero: 'Проблем нет',
    );
    return '$_temp0';
  }

  @override
  String get mpreviewNoIssues => 'agnts не заметил визуальных проблем.';

  @override
  String get mpreviewSev_high => 'Высокая';

  @override
  String get mpreviewSev_medium => 'Средняя';

  @override
  String get mpreviewSev_low => 'Низкая';

  @override
  String get mpreviewShowShot => 'Показать скриншот';

  @override
  String get mpreviewDesktop => 'Компьютер';

  @override
  String get mpreviewPhone => 'Телефон';

  @override
  String get mpreviewBefore => 'До';

  @override
  String get mpreviewAfter => 'После';

  @override
  String get mpreviewNoShots => 'Для этой ширины скриншотов нет.';

  @override
  String mpreviewConsoleErrors(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ошибки в консоли',
      many: '$count ошибок в консоли',
      few: '$count ошибки в консоли',
      one: '$count ошибка в консоли',
    );
    return '$_temp0';
  }

  @override
  String get mpreviewLoadFailed => 'Не удалось загрузить скриншот.';

  @override
  String get mpreviewAddToFeedback => 'Добавить в отзыв';

  @override
  String get mpreviewAdded => 'В отзыве';

  @override
  String get mpreviewAttached => 'Скриншоты, которые уйдут с отзывом';

  @override
  String mpreviewAttachLimit(String max) {
    return 'С отзывом можно отправить не больше $max скриншотов.';
  }

  @override
  String get mpreviewRemove => 'Убрать';

  @override
  String get mpreviewSettingsModel => 'Превью';

  @override
  String get mpreviewSettingsModelHelp => 'Смотрит скриншоты запущенного приложения';

  @override
  String get mpreviewNotify => 'Скриншоты превью готовы';

  @override
  String get mpullsPlaceholder => 'Markdown';

  @override
  String get mpullsLineHint => 'Нажмите на строку, чтобы прокомментировать её.';

  @override
  String mpullsCopyLink(String host) {
    return 'Открыть в $host';
  }

  @override
  String get mqualityNewTest => 'Новый Swagger-тест';

  @override
  String get mqualityStarterFor => 'Стартовые правила для';

  @override
  String get mqualityStarterPick => 'Выберите репозиторий, чтобы увидеть стартовые наборы для его языков.';

  @override
  String get mqualitySearchRules => 'Поиск правил';

  @override
  String mqualityRequestTitle(String id) {
    return 'Запрос $id';
  }

  @override
  String mqualitySpecFile(String name) {
    return 'Файл спецификации: $name';
  }

  @override
  String get mqualityDeployHook => 'Хук деплоя';

  @override
  String get mqualityTokenSaved => 'Токен сохранён';

  @override
  String get mqualitySuiteDeleted => 'Набор удалён';

  @override
  String mqualityHourAt(String hour) {
    return '$hour:00 UTC';
  }

  @override
  String get mqualityReviewTickets => 'Пул-реквесты';

  @override
  String get mqualityAddReviewer => 'Добавить ревьюера';

  @override
  String get mqualityEndpointsTicked => 'Эндпоинты';

  @override
  String get mqualityShowCases => 'Показать случаи';

  @override
  String get mqualityHideCases => 'Скрыть случаи';

  @override
  String mrepodetailCopyLink(String host) {
    return 'Открыть в $host';
  }

  @override
  String get mrepodetailOnePerLine => 'По одному на строку.';

  @override
  String mrepodetailLinesCapped(String n) {
    return 'Здесь показаны только первые $n строк.';
  }

  @override
  String get mtasksActAnswers => 'Ответьте на вопросы agnts';

  @override
  String get mtasksActReview => 'Проверьте изменения';

  @override
  String get mtasksActFailed => 'Остановлено. Подскажите agnts, что попробовать';

  @override
  String get mtasksActResume => 'Продолжите, когда будете готовы';

  @override
  String get mtasksActAnalyze => 'Нажмите, чтобы начать анализ';

  @override
  String get mtasksActHeld => 'Ждёт в очереди. Нажмите, чтобы запустить';

  @override
  String get mtasksYesterday => 'Вчера';

  @override
  String get mwsNone =>
      'Вы пока не состоите ни в одном рабочем пространстве. Создайте его или примите приглашение в веб-админке, затем потяните вниз, чтобы обновить.';

  @override
  String mwsSwitched(String name) {
    return 'Открыто: $name';
  }

  @override
  String mwsMembers(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n участника',
      many: '$n участников',
      few: '$n участника',
      one: '$n участник',
    );
    return '$_temp0';
  }

  @override
  String get mwsSuspended => 'Приостановлено';

  @override
  String get navOverview => 'Обзор';

  @override
  String get navDashboard => 'Дашборд';

  @override
  String get navAnalytics => 'Аналитика';

  @override
  String get navTickets => 'Тикеты';

  @override
  String get navNeeds => 'Ждёт вас';

  @override
  String get navRunning => 'Выполняется';

  @override
  String get navQueue => 'В очереди';

  @override
  String get navDone => 'Завершённые';

  @override
  String get navAll => 'Все тикеты';

  @override
  String get navSideProjects => 'Свои проекты';

  @override
  String get navTasks => 'Задачи';

  @override
  String get navMonitor => 'Мониторинг';

  @override
  String get navLogs => 'Логи';

  @override
  String get navUsage => 'Лимиты тарифа';

  @override
  String get navSetup => 'Настройка';

  @override
  String get navIntegrations => 'Интеграции';

  @override
  String get navRepos => 'Репозитории';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navSearch => 'Поиск тикетов и задач';

  @override
  String get navSyncJira => 'Синхронизировать Jira';

  @override
  String navSynced(String found, String created, String updated, String waiting) {
    return 'Jira синхронизирована: открыто $found, новых $created, обновлено $updated, ждут вашего решения $waiting';
  }

  @override
  String get navSession => 'Текущая сессия';

  @override
  String get navWeek => 'Эта неделя';

  @override
  String get navDayMode => 'Включить дневной режим';

  @override
  String get navNightMode => 'Включить ночной режим';

  @override
  String get navCollapseSidebar => 'Свернуть боковую панель';

  @override
  String get navExpandSidebar => 'Развернуть боковую панель';

  @override
  String get navLanguage => 'Язык';

  @override
  String get navGuide => 'Как устроена страница';

  @override
  String get navClose => 'Закрыть';

  @override
  String get navMain => 'Главное меню';

  @override
  String get navLive => 'В эфире';

  @override
  String get navOffline => 'Переподключение…';

  @override
  String navResetsIn(String time) {
    return 'Сброс через $time';
  }

  @override
  String get navResettingNow => 'Сбрасывается сейчас';

  @override
  String get navUsageUnknown => 'Лимиты неизвестны';

  @override
  String get navBack => 'Назад';

  @override
  String get navLedeNeeds => 'Тикеты, которые ждут ваших ответов или ревью, а также остановленные запуски.';

  @override
  String get navLedeRunning => 'Тикеты, над которыми agnts работает прямо сейчас.';

  @override
  String get navLedeQueue => 'Тикеты с меткой agnts, которые ещё не проанализированы.';

  @override
  String get navLedeDone => 'Отправленные или отклонённые тикеты.';

  @override
  String get navLedeAll => 'Все тикеты, которые agnts взял из Jira и Plane.';

  @override
  String get navKnowledge => 'Знания';

  @override
  String get navLearn => 'Обучение';

  @override
  String get navLearnQueue => 'Очередь обучения';

  @override
  String get navRules => 'Правила';

  @override
  String get navSyncPlane => 'Синхронизировать Plane';

  @override
  String navSyncedPlane(String found, String created) {
    return 'Plane синхронизирован: открыто $found, новых $created';
  }

  @override
  String get navWorkspace => 'Пространство';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navPlatform => 'Кабинет администратора';

  @override
  String get navPeople => 'Люди';

  @override
  String get navAccount => 'Аккаунт';

  @override
  String get navReviews => 'Ревью PR';

  @override
  String get navCi => 'CI';

  @override
  String get navAiAssistant => 'AI-ассистент';

  @override
  String get navAssistantChat => 'Чат';

  @override
  String get navAssistantConversations => 'Разговоры';

  @override
  String get networkTitle => 'Частные сети';

  @override
  String get networkSub =>
      'Доступ к GitLab, Jira или реестрам пакетов внутри ваших сетей. Соединение идёт через сеть, чей маршрут подходит к нему точнее всего.';

  @override
  String get networkUnavailable =>
      'На этом сервере частные сети не настроены: администратор запускает сервис gateway и задаёт AGNTS_GATEWAY.';

  @override
  String get networkStatus_up => 'Подключено';

  @override
  String get networkStatus_connecting => 'Подключение';

  @override
  String get networkStatus_error => 'Ошибка';

  @override
  String get networkStatus_gateway_down => 'Шлюз недоступен';

  @override
  String get networkStatus_disabled => 'Выключено';

  @override
  String get networkHandshake => 'Последнее рукопожатие';

  @override
  String get networkHeartbeat => 'Последний сигнал';

  @override
  String get networkWebhooksRelay => 'Пересылает agnts-link';

  @override
  String networkWebhooksPolling(String n) {
    return 'Без вебхуков: трекеры за этой сетью читаются каждые $n мин';
  }

  @override
  String get networkKind => 'Подключение';

  @override
  String get networkKindConnector => 'agnts-link (рекомендуется)';

  @override
  String get networkKindHelp_connector =>
      'Небольшой агент, который вы запускаете в своей сети. Он сам подключается к agnts: без учётных данных VPN, без входящих правил файрвола, и пересылает вебхуки.';

  @override
  String get networkKindHelp_wireguard =>
      'agnts подключается к вашему пиру WireGuard как клиент. Пир должен принимать UDP с этого сервера.';

  @override
  String get networkKindHelp_openvpn =>
      'agnts запускает ваш клиентский конфиг OpenVPN в изолированном контейнере. Сертификаты должны быть встроены; вход с MFA не поддерживается.';

  @override
  String get networkEnabled => 'Включено';

  @override
  String get networkConfigWg => 'Конфиг WireGuard';

  @override
  String get networkConfigOvpn => 'Конфиг OpenVPN (.ovpn)';

  @override
  String networkSavedConfig(String summary) {
    return 'Сохранён: $summary. Оставьте пустым, чтобы не менять.';
  }

  @override
  String get networkConfigWgHelp =>
      'Файл, который вы дали бы wg-quick. Добавьте строку DNS, чтобы обращаться к хостам по имени. Ключи шифруются и больше не показываются.';

  @override
  String get networkConfigOvpnHelp =>
      'Клиентский конфиг со встроенными блоками ca, cert и key. Скрипты (up, down, plugin…) не принимаются.';

  @override
  String get networkUsername => 'Имя пользователя';

  @override
  String get networkPassword => 'Пароль';

  @override
  String get networkPasswordKeep => 'Сохранён: оставьте пустым';

  @override
  String get networkRoutes => 'Маршруты';

  @override
  String get networkRoutesHelp =>
      'Хосты (gitlab.corp.local), домены (.corp.local) или частные диапазоны (10.20.0.0/16), которые идут через эту сеть, с портами (80 и 443, если пусто). У другой сети может быть более узкий маршрут внутри этих (10.30.0.0/16 внутри 10.0.0.0/8): побеждает более точный. Две сети не могут указывать один и тот же маршрут.';

  @override
  String get networkRouteTarget => 'Хост, домен или диапазон';

  @override
  String get networkRoutePorts => 'Порты';

  @override
  String get networkRemoveRoute => 'Удалить маршрут';

  @override
  String get networkAddRoute => 'Добавить маршрут';

  @override
  String get networkBlastRadius =>
      'Код, который agnts запускает по вашим задачам, может обращаться ко всем хостам из этого списка. Указывайте конкретные хосты, а не целые диапазоны.';

  @override
  String get networkCa => 'Корпоративный CA';

  @override
  String networkCaSaved(String subjects, String date) {
    return 'Доверенные: $subjects (до $date).';
  }

  @override
  String get networkCaRemove => 'Удалить';

  @override
  String get networkCaHelp => 'PEM-сертификаты вашего внутреннего CA. agnts и его запуски доверяют им вместе с публичными корневыми.';

  @override
  String networkSaved(String name) {
    return '$name: сохранено';
  }

  @override
  String get networkRemove => 'Удалить';

  @override
  String get networkRemoved => 'Частная сеть удалена';

  @override
  String networkRemoveConfirm(String name) {
    return 'Удалить $name? agnts перестанет достигать хостов из её маршрутов.';
  }

  @override
  String get networkLinkTitle => 'Запустите agnts-link';

  @override
  String get networkLinkHelp =>
      'Запустите это на машине внутри сети, которая видит хосты выше. AGNTS_LINK_ALLOW — ваш собственный предел: agnts-link не подключается ни к чему другому. У каждой сети свой токен, поэтому одна машина может запускать несколько линков.';

  @override
  String get networkToken => 'Токен';

  @override
  String get networkTokenOnce => 'Скопируйте сейчас: он показывается один раз.';

  @override
  String get networkLinkHooks =>
      'Вебхуки: укажите в GitLab и Jira адрес http://ХОСТ-AGNTS-LINK:8080 с тем же путём /webhooks/…, что на странице интеграций.';

  @override
  String get networkRotate => 'Заменить токен';

  @override
  String get networkRotateConfirm => 'Создать новый токен? Запущенный agnts-link отключится, пока вы не перезапустите его с новым.';

  @override
  String get networkTest => 'Проверить подключение';

  @override
  String get networkTestRun => 'Проверить';

  @override
  String get networkTesting => 'Проверяем…';

  @override
  String networkTestOk(String name, String via, String ip, String ms) {
    return 'Подключено через $name ($via) к $ip за $ms мс.';
  }

  @override
  String networkTlsOk(String subject, String issuer) {
    return 'Сертификат в порядке: $subject, выдан $issuer.';
  }

  @override
  String networkTlsBad(String error) {
    return 'Сертификату нет доверия: $error';
  }

  @override
  String get networkActivity => 'Активность';

  @override
  String networkActivityCounts(String n, String refused) {
    return '$n подключений, $refused отклонено или с ошибкой';
  }

  @override
  String get networkActivityShow => 'Показать подключения';

  @override
  String get networkActivityHide => 'Скрыть подключения';

  @override
  String get networkRefused => 'отклонено';

  @override
  String networkSecondsAgo(String n) {
    return '$n с назад';
  }

  @override
  String networkMinutesAgo(String n) {
    return '$n мин назад';
  }

  @override
  String networkHoursAgo(String n) {
    return '$n ч назад';
  }

  @override
  String get networkReconnect => 'Переподключить';

  @override
  String get networkReconnectHelp =>
      'Перезапустить туннель: новый клиент OpenVPN, новое рукопожатие WireGuard или повторное подключение agnts-link';

  @override
  String get networkReconnecting => 'Переподключаем: туннель перезапустится в течение 15 секунд';

  @override
  String get networkAdd => 'Добавить сеть';

  @override
  String get networkAddTitle => 'Новая частная сеть';

  @override
  String get networkAddSubmit => 'Добавить сеть';

  @override
  String get networkEditorSub => 'Туннель в одну из ваших сетей и хосты, которые идут через него';

  @override
  String get networkEdit => 'Изменить';

  @override
  String get networkDone => 'Готово';

  @override
  String get networkName => 'Название';

  @override
  String get networkNamePlaceholder => 'Клиент А, Офис, Дата-центр';

  @override
  String get networkNameHelp => 'Уникально в рабочем пространстве: компания, офис или дата-центр, куда ведёт сеть.';

  @override
  String get networkEmpty => 'Частных сетей пока нет. Добавьте сеть, чтобы достучаться до хостов, доступных только внутри неё.';

  @override
  String networkLimit(String n) {
    return 'В рабочем пространстве не больше $n частных сетей';
  }

  @override
  String networkCaShort(String subjects) {
    return 'Доверяет $subjects';
  }

  @override
  String get networkTestHelp => 'Введите host:port. agnts выберет сеть, к которой ведут маршруты, подключится и проверит сертификат.';

  @override
  String get networkTestThrough => 'Через';

  @override
  String get networkTestAuto => 'Сеть, которую выбирают маршруты';

  @override
  String get networkActivityAll => 'Все сети';

  @override
  String get networkActivityNetwork => 'Сеть';

  @override
  String get networkActivityTime => 'Время';

  @override
  String get networkActivityTarget => 'Адрес';

  @override
  String get networkActivitySource => 'Тикет или источник';

  @override
  String get networkGone => 'удалена';

  @override
  String get networkDisconnect => 'Отключить';

  @override
  String get networkDisconnectHelp =>
      'Остановить туннель. Запуски ничего не достигнут через него, пока вы не подключите снова; конфиг сохраняется';

  @override
  String networkDisconnectConfirm(String name) {
    return 'Отключить $name? Запуски и трекеры, доступные через неё, перестанут работать, пока вы снова её не подключите. Конфиг сохраняется.';
  }

  @override
  String get networkDisconnected => 'Отключено';

  @override
  String get networkConnect => 'Подключить';

  @override
  String get networkConnectHelp => 'Снова запустить туннель с сохранённым конфигом';

  @override
  String get networkConnecting => 'Подключение: туннель запустится в течение 15 секунд';

  @override
  String get platformTitle => 'Кабинет администратора';

  @override
  String get platformLede =>
      'Все рабочие пространства, запуски и пользователи сервера. О пространствах видны только метаданные: их тикеты принадлежат участникам.';

  @override
  String get platformCapacity => 'Сервер';

  @override
  String get platformReserved => 'Зарезервировано памяти';

  @override
  String get platformBudgetNone => 'без ограничения';

  @override
  String get platformRuns => 'Запуски';

  @override
  String get platformDisk => 'Свободно на диске';

  @override
  String get platformFull => 'Заполнен: запуски ждут сервер';

  @override
  String get platformRunning => 'Выполняются сейчас';

  @override
  String get platformNoRuns => 'Ничего не выполняется.';

  @override
  String get platformQueue => 'Очередь сервера';

  @override
  String get platformNoQueue => 'Ни один запуск не ждёт сервер.';

  @override
  String get platformWorkspace => 'Пространство';

  @override
  String get platformTicket => 'Тикет';

  @override
  String get platformStage => 'Этап';

  @override
  String get platformStarted => 'Начат';

  @override
  String get platformWorkspaces => 'Рабочие пространства';

  @override
  String get platformOwner => 'Владелец';

  @override
  String get platformPlan => 'Тариф';

  @override
  String get platformSlots => 'Слоты';

  @override
  String get platformMembers => 'Участники';

  @override
  String get platformMemberLimit => 'Лимит участников';

  @override
  String get platformCredits => 'Кредиты';

  @override
  String get platformState => 'Состояние';

  @override
  String get platformActive => 'Активно';

  @override
  String get platformSuspended => 'Приостановлено';

  @override
  String get platformDeleted => 'Удалено';

  @override
  String get platformEdit => 'Изменить';

  @override
  String get platformSuspend => 'Приостановить';

  @override
  String get platformResume => 'Возобновить';

  @override
  String get platformGrant => 'Начислить кредиты';

  @override
  String get platformGrantAmount => 'Кредиты (отрицательное число — списание)';

  @override
  String get platformGrantNote => 'Комментарий';

  @override
  String platformGrantDone(String n, String name) {
    return '$name: начислено $n кредитов';
  }

  @override
  String get platformSaved => 'Сохранено';

  @override
  String get platformUsers => 'Пользователи';

  @override
  String get platformUser => 'Пользователь';

  @override
  String get platformEmail => 'Почта';

  @override
  String get platformAdmin => 'Админ';

  @override
  String get platformMakeAdmin => 'Сделать админом';

  @override
  String get platformRemoveAdmin => 'Снять роль админа';

  @override
  String get platformJoined => 'Зарегистрирован';

  @override
  String get platformNoLimit => 'без лимита';

  @override
  String get platformForbidden => 'Консоль оператора доступна только администраторам.';

  @override
  String get platformCabinetBadge => 'Кабинет администратора';

  @override
  String get platformNavDashboard => 'Обзор';

  @override
  String get platformAdmins => 'Администраторы';

  @override
  String get platformNavMine => 'Моя работа';

  @override
  String get platformBackToWorkspace => 'В моё пространство';

  @override
  String get platformDashLede => 'Все пользователи платформы, её рост и то, что сейчас выполняет сервер.';

  @override
  String platformNewThisWeek(String n) {
    return '$n новых за неделю';
  }

  @override
  String platformViaGoogle(String n) {
    return '$n через Google';
  }

  @override
  String get platformActiveUsers => 'Активны за неделю';

  @override
  String get platformActiveNote => 'Входили за последние 7 дней';

  @override
  String platformTeams(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n с командой',
      many: '$n с командой',
      few: '$n с командой',
      one: '$n с командой',
    );
    return '$_temp0';
  }

  @override
  String platformRunsNow(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n запуска сейчас',
      many: '$n запусков сейчас',
      few: '$n запуска сейчас',
      one: '$n запуск сейчас',
    );
    return '$_temp0';
  }

  @override
  String get platformGrowthTitle => 'Регистрации';

  @override
  String platformGrowthSub(String n) {
    return 'Новые аккаунты и пространства по дням за последние $n дней';
  }

  @override
  String get platformLegendUsers => 'Аккаунты';

  @override
  String get platformLegendWorkspaces => 'Пространства';

  @override
  String get platformRecentTitle => 'Новые аккаунты';

  @override
  String get platformSeeAll => 'Все';

  @override
  String get platformNoUsers => 'Пользователи не найдены.';

  @override
  String get platformWsLede =>
      'Все рабочие пространства и их участники. Видны только метаданные: задачи и код принадлежат участникам пространства.';

  @override
  String get platformF_all => 'Все';

  @override
  String get platformF_active => 'Активные';

  @override
  String get platformF_suspended => 'Приостановлены';

  @override
  String get platformF_deleted => 'Удалены';

  @override
  String get platformSearchWs => 'Поиск по пространствам и владельцам';

  @override
  String get platformNoWorkspaces => 'Пространства не найдены.';

  @override
  String get platformCreated => 'Создано';

  @override
  String get platformNoMembers => 'Нет участников.';

  @override
  String platformSuspendTitle(String name) {
    return 'Приостановить $name?';
  }

  @override
  String get platformSuspendBody =>
      'Новые запуски перестанут начинаться, а участники увидят, что пространство приостановлено. Возобновить можно в любой момент.';

  @override
  String get platformUsersLede =>
      'Все, кто зарегистрировался через Google: их пространства и когда они заходили. Аккаунты администраторов — на странице «Администраторы».';

  @override
  String get platformU_all => 'Все';

  @override
  String get platformU_active => 'Активные';

  @override
  String get platformU_new => 'Новые за неделю';

  @override
  String get platformU_google => 'Google';

  @override
  String get platformU_admins => 'Администраторы';

  @override
  String get platformSearchUsers => 'Поиск по имени, email или пространству';

  @override
  String get platformSignIn => 'Вход';

  @override
  String get platformLastSeen => 'Последний вход';

  @override
  String get platformPassword => 'Пароль';

  @override
  String get platformUnverified => 'не подтверждён';

  @override
  String get platformYou => 'Вы';

  @override
  String platformMakeAdminTitle(String name) {
    return 'Сделать $name администратором?';
  }

  @override
  String get platformMakeAdminBody =>
      'Администраторы открывают этот кабинет: видят всех пользователей и пространства, меняют тарифы и кредиты, приостанавливают пространства и управляют другими администраторами.';

  @override
  String platformRemoveAdminTitle(String name) {
    return 'Снять с $name роль администратора?';
  }

  @override
  String get platformRemoveAdminBody => 'Аккаунт и пространства сохранятся, но доступа к кабинету администратора не будет.';

  @override
  String platformAdminAdded(String name) {
    return 'Администратор $name создан';
  }

  @override
  String platformAdminRemoved(String name) {
    return 'Администратор $name удалён';
  }

  @override
  String get platformAdminsLede =>
      'Операторы платформы. Каждый — отдельный аккаунт, не пользователь: администратор не видит задачи пространств.';

  @override
  String platformAdminsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n администратора',
      many: '$n администраторов',
      few: '$n администратора',
      one: '$n администратор',
    );
    return '$_temp0';
  }

  @override
  String get platformAddAdmin => 'Добавить администратора';

  @override
  String get platformAddAdminSub =>
      'Администратор — отдельный аккаунт: входит по паролю, открывает этот кабинет и не состоит в пространствах. Пользователя нельзя сделать администратором.';

  @override
  String get platformFindUser => 'Найти человека';

  @override
  String get platformNoMatch => 'Никого не найдено, или это уже администратор.';

  @override
  String platformLastSeenAgo(String when) {
    return 'последний вход $when';
  }

  @override
  String get platformAdminName => 'Имя';

  @override
  String get platformAdminUsername => 'Логин';

  @override
  String platformAdminPasswordHint(String n) {
    return 'Не менее $n символов. Двухфакторный вход можно включить в профиле.';
  }

  @override
  String get platformCreateAdmin => 'Создать администратора';

  @override
  String get platformDeleteAdmin => 'Удалить';

  @override
  String platformDeleteAdminTitle(String name) {
    return 'Удалить аккаунт администратора $name?';
  }

  @override
  String get platformDeleteAdminBody => 'Он больше не сможет войти. Это действие нельзя отменить.';

  @override
  String get previewTab => 'Превью';

  @override
  String get previewTitle => 'Скриншоты приложения';

  @override
  String get previewSub => 'agnts запустил приложение с этим изменением и сделал скриншоты. Это совет: одобрение он никогда не блокирует.';

  @override
  String get previewPending => 'В очереди: agnts сделает скриншоты, как только освободится исполнитель.';

  @override
  String get previewRunning => 'agnts запускает приложение и делает скриншоты…';

  @override
  String get previewFailed => 'Превью не удалось. Посмотрите журнал запуска или запустите снова.';

  @override
  String previewStale(String n) {
    return 'Это скриншоты ревизии $n; с тех пор изменение ушло вперёд.';
  }

  @override
  String get previewNone => 'Скриншотов пока нет.';

  @override
  String get previewStatus_ok => 'Снято';

  @override
  String get previewStatus_partial => 'Снято частично';

  @override
  String get previewStatus_failed => 'Приложение не запустилось';

  @override
  String previewModel(num n, String model) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n скриншота',
      many: '$n скриншотов',
      few: '$n скриншота',
      one: '$n скриншот',
      zero: 'Скриншотов нет',
    );
    return '$_temp0 от $model';
  }

  @override
  String get previewWithBase => 'со снимками основной ветки для сравнения';

  @override
  String get previewSev_high => 'Высокая';

  @override
  String get previewSev_medium => 'Средняя';

  @override
  String get previewSev_low => 'Низкая';

  @override
  String get previewNoIssues => 'agnts не увидел визуальных проблем.';

  @override
  String get previewViewport => 'Размер экрана';

  @override
  String get previewVp_all => 'Все';

  @override
  String get previewVp_desktop => 'Компьютер';

  @override
  String get previewVp_phone => 'Телефон';

  @override
  String get previewMode => 'Показать';

  @override
  String get previewMode_after => 'После';

  @override
  String get previewMode_before => 'До';

  @override
  String get previewMode_side => 'Рядом';

  @override
  String get previewMode_slider => 'Ползунок';

  @override
  String get previewSlider => 'Потяните, чтобы сравнить до и после';

  @override
  String previewConsoleErrors(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ошибки в консоли',
      many: '$count ошибок в консоли',
      few: '$count ошибки в консоли',
      one: '$count ошибка в консоли',
    );
    return '$_temp0';
  }

  @override
  String get previewNoBefore => 'Скриншота «до» нет: страница новая или не открылась на основной ветке.';

  @override
  String get previewAddToFeedback => 'Добавить в отзыв';

  @override
  String get previewAdded => 'В отзыве';

  @override
  String get previewCompare => 'Сравнить с основной веткой';

  @override
  String get previewRun => 'Сделать скриншоты';

  @override
  String get previewRunAgain => 'Сделать скриншоты снова';

  @override
  String previewTooMany(String n) {
    return 'К отзыву можно приложить не больше $n скриншотов.';
  }

  @override
  String get previewAttached => 'Скриншоты к отзыву';

  @override
  String previewDetach(String name) {
    return 'Убрать $name';
  }

  @override
  String get previewRepoTitle => 'Превью';

  @override
  String get previewRepoHelp =>
      'Как agnts запускает приложение, чтобы снять скриншоты изменений интерфейса до вашей проверки. Оставьте команду пустой, чтобы выключить превью.';

  @override
  String get previewRepoCommand => 'Команда запуска';

  @override
  String get previewRepoCommandHelp =>
      'Выполняется в /workspace в контейнере запуска: установка, сборка и запуск dev-сервера. Он должен слушать порт ниже.';

  @override
  String get previewRepoPort => 'Порт';

  @override
  String get previewRepoReady => 'Путь проверки готовности';

  @override
  String get previewRepoUiPaths => 'Файлы интерфейса';

  @override
  String get previewRepoUiPathsHelp =>
      'По одному glob-шаблону на строку, от корня репозитория. Изменение, затронувшее такой файл, получает скриншоты. Пусто: любое изменение.';

  @override
  String get previewRepoRoutes => 'Снимать всегда';

  @override
  String get previewRepoRoutesHelp => 'Маршруты для каждого превью, по одному на строку, помимо тех, что agnts выберет по диффу.';

  @override
  String get previewRepoLogin => 'Вход';

  @override
  String get previewRepoLoginPh => 'Войти как demo@acme.test; пароль в PREVIEW_PASSWORD.';

  @override
  String get previewRepoLoginHelp => 'Подскажите agnts, как пройти вход, если он есть. Секреты называйте по имени переменной.';

  @override
  String get previewRepoEnv => 'Переменные окружения';

  @override
  String previewRepoEnvSet(String names) {
    return 'Заданы: $names. Значения никогда не показываются.';
  }

  @override
  String get previewRepoEnvReplace => 'Заменить';

  @override
  String get previewRepoEnvClear => 'Очистить';

  @override
  String get previewRepoEnvCleared => 'Переменные окружения будут удалены при сохранении.';

  @override
  String get previewRepoEnvHelp =>
      'Строки KEY=value для приложения, например адрес staging API. Хранятся зашифрованными и больше не показываются. Используйте только тестовые учётные данные: их видят приложение и agnts. Добавьте хосты, к которым обращается приложение, в Настройки → Превью → Разрешённые хосты.';

  @override
  String get previewSettingsTitle => 'Превью';

  @override
  String get previewSettingsSub => 'Скриншоты изменений интерфейса для репозиториев с командой превью.';

  @override
  String get previewAutoPreview => 'Снимать каждое изменение интерфейса';

  @override
  String get previewAutoPreviewHelp =>
      'Пока изменение ждёт вас, agnts запускает приложение, открывает затронутые страницы и показывает скриншоты рядом с диффом. Одобрение это никогда не блокирует.';

  @override
  String get previewVisualCheck => 'Давать запускам кода смотреть на приложение';

  @override
  String get previewVisualCheckHelp =>
      'Claude может запустить приложение, посмотреть на изменённые страницы перед завершением и исправить то, что выглядит сломанным. Это стоит нескольких ходов.';

  @override
  String get previewModel_ => 'Модель превью';

  @override
  String get previewModelHelp => 'Выбирает страницы и оценивает скриншоты.';

  @override
  String get previewEgress => 'Разрешённые хосты';

  @override
  String get previewEgressHelp =>
      'Хосты, доступные контейнерам запуска помимо встроенного списка (Claude, git-хостинги, реестры пакетов), например staging API, к которому приложение обращается в превью. .example.com разрешает поддомены.';

  @override
  String get previewNotify => 'Когда скриншоты превью готовы';

  @override
  String get previewNotifyPhotos => 'Отправлять скриншоты телефона в Telegram';

  @override
  String get previewNotifyPhotosHelp => 'К сообщению в Telegram прикладывается до четырёх скриншотов.';

  @override
  String get pullsTab => 'Пул-реквесты';

  @override
  String get pullsTitle => 'Пул-реквесты';

  @override
  String get pullsSub => 'На git-хостинге, сначала недавно обновлённые. Откройте, чтобы прочитать комментарии и ответить на них.';

  @override
  String get pullsBack => 'Назад к репозиторию';

  @override
  String get pullsState_open => 'Открытые';

  @override
  String get pullsState_merged => 'Слитые';

  @override
  String get pullsState_closed => 'Закрытые';

  @override
  String get pullsState_all => 'Все';

  @override
  String get pullsNone => 'Пул-реквестов нет.';

  @override
  String get pullsEnd => 'Это все.';

  @override
  String pullsUpdated(String time) {
    return 'обновлён $time';
  }

  @override
  String get pullsDraft => 'Черновик';

  @override
  String pullsOwnTicket(String key) {
    return 'Изменение agnts · $key';
  }

  @override
  String pullsReviewTicket(String key) {
    return 'Ревью · $key';
  }

  @override
  String get pullsConversation => 'Обсуждение';

  @override
  String get pullsFiles => 'Файлы';

  @override
  String pullsUnresolvedN(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n нерешённой ветки',
      many: '$n нерешённых веток',
      few: '$n нерешённые ветки',
      one: '$n нерешённая ветка',
    );
    return '$_temp0';
  }

  @override
  String pullsShowResolved(String n) {
    return 'Показать решённые ($n)';
  }

  @override
  String get pullsNoComments => 'Комментариев пока нет.';

  @override
  String get pullsNoFiles => 'Пул-реквест не меняет файлов.';

  @override
  String get pullsNoPatch => 'Нечего показать (бинарный файл или слишком большой дифф).';

  @override
  String pullsFilesError(String error) {
    return 'Не удалось прочитать изменённые файлы: $error';
  }

  @override
  String get pullsEarlierVersion => 'Написано к более ранней версии файла:';

  @override
  String pullsThreadsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ветки', many: '$n веток', few: '$n ветки', one: '$n ветка');
    return '$_temp0';
  }

  @override
  String pullsCommentOnLine(String line) {
    return 'Комментарий к строке $line';
  }

  @override
  String get pullsAddComment => 'Добавить комментарий';

  @override
  String get pullsComment => 'Комментировать';

  @override
  String get pullsCommentLabel => 'Комментарий';

  @override
  String get pullsPlaceholder => 'Markdown. Ctrl+Enter — отправить.';

  @override
  String get pullsWrite => 'Текст';

  @override
  String get pullsPreview => 'Просмотр';

  @override
  String get pullsReply => 'Ответить';

  @override
  String get pullsEdit => 'Изменить';

  @override
  String get pullsSave => 'Сохранить';

  @override
  String get pullsEdited => 'изменён';

  @override
  String get pullsDelete => 'Удалить';

  @override
  String get pullsDeleteTitle => 'Удалить комментарий?';

  @override
  String get pullsDeleteConfirm => 'Он удалится на git-хостинге для всех. Это нельзя отменить.';

  @override
  String get pullsDeleted => 'Комментарий удалён';

  @override
  String get pullsResolve => 'Решено';

  @override
  String get pullsUnresolve => 'Открыть снова';

  @override
  String get pullsResolved => 'Решено';

  @override
  String get pullsOutdated => 'Устарело';

  @override
  String get pullsSent => 'Отправлено agnts';

  @override
  String get pullsAnswered => 'agnts ответил';

  @override
  String get pullsVerdict_APPROVED => 'Одобрено';

  @override
  String get pullsVerdict_CHANGES_REQUESTED => 'Нужны изменения';

  @override
  String get pullsVerdict_COMMENTED => 'Комментарий';

  @override
  String get pullsVerdict_DISMISSED => 'Отклонено';

  @override
  String pullsPostsAs(String login, String host) {
    return 'От имени @$login на $host';
  }

  @override
  String pullsPostsAsToken(String host) {
    return 'От имени владельца токена $host';
  }

  @override
  String pullsTicketTitle(String number, String host) {
    return 'Комментарии к #$number ($host)';
  }

  @override
  String get pullsTicketSubOwn => 'Комментарии ревьюеров к пул-реквесту agnts. Ответьте здесь или верните их agnts.';

  @override
  String get pullsTicketSubReview => 'Обсуждение пул-реквеста на git-хостинге.';

  @override
  String pullsTicketSubIn(String repo) {
    return 'В $repo.';
  }

  @override
  String get pullsOpenWithDiff => 'Открыть с диффом';

  @override
  String pullsAddressBtn(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Учесть $n комментария',
      many: 'Учесть $n комментариев',
      few: 'Учесть $n комментария',
      one: 'Учесть $n комментарий',
    );
    return '$_temp0';
  }

  @override
  String pullsAddressConfirm(String key, num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'этими $n ветками ревью',
      many: 'этими $n ветками ревью',
      few: 'этими $n ветками ревью',
      one: 'этой веткой ревью',
    );
    return 'agnts вернётся к $key с $_temp0: исправит код или ответит на каждую. Исправление, как обычно, ждёт вашего одобрения; после пуша agnts ответит в каждой ветке.';
  }

  @override
  String pullsAddressed(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ветки возвращено',
      many: '$n веток возвращено',
      few: '$n ветки возвращены',
      one: '$n ветка возвращена',
    );
    return '$_temp0 agnts';
  }

  @override
  String pullsAddressLater(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n нового комментария',
      many: '$n новых комментариев',
      few: '$n новых комментария',
      one: '$n новый комментарий',
    );
    return '$_temp0 ревью: их можно вернуть agnts, пока тикет ждёт вашего ревью или когда он готов и его пул-реквест открыт.';
  }

  @override
  String pullsPostTitle(String number) {
    return 'Опубликовать ревью в #$number';
  }

  @override
  String pullsPostSub(String host) {
    return 'Одно ревью на $host от имени владельца токена. Находки на строках диффа станут комментариями к ним.';
  }

  @override
  String pullsPostBtn(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Опубликовать с $n комментария к строкам',
      many: 'Опубликовать с $n комментариями к строкам',
      few: 'Опубликовать с $n комментариями к строкам',
      one: 'Опубликовать с $n комментарием к строке',
      zero: 'Опубликовать',
    );
    return '$_temp0';
  }

  @override
  String get pullsPostSummary => 'Итог (вердикт и все находки)';

  @override
  String get pullsPostFindings => 'На своих строках:';

  @override
  String get pullsSummaryOnly => 'только в итоге: строки нет в диффе';

  @override
  String get pullsRequestChanges => 'Запросить изменения';

  @override
  String get pullsNoRequestChanges => 'В GitLab здесь нет запроса изменений: комментарии публикуются, одобрения остаются как есть.';

  @override
  String get pullsSettingsTitle => 'Комментарии к пул-реквестам';

  @override
  String get pullsSet_attribution => 'Указывать автора';

  @override
  String get pullsSet_attributionHelp =>
      'Комментарии из agnts уходят от имени владельца токена git-хостинга; под каждым будет «via agnts · <вы>».';

  @override
  String get pullsSet_learnFromComments => 'Учиться на ваших комментариях';

  @override
  String get pullsSet_learnFromCommentsHelp =>
      'То, что вы пишете в чужих пул-реквестах на git-хостинге, становится заметками о том, как вы делаете ревью.';

  @override
  String get pullsSet_resolveFixed => 'Закрывать исправленные ветки';

  @override
  String get pullsSet_resolveFixedHelp => 'Когда agnts запушил исправление и ответил в ветке ревьюера, он помечает её решённой.';

  @override
  String get pullsSet_autoAddress => 'Учитывать запрос изменений';

  @override
  String get pullsSet_autoAddressHelp =>
      'Когда ревьюер запрашивает изменения в пул-реквесте agnts, его нерешённые ветки сами возвращаются в тикет. Исправление всё равно ждёт вашего одобрения.';

  @override
  String get pullsCommentHint => 'Наведите на строку и нажмите кнопку комментария, чтобы прокомментировать её.';

  @override
  String queueHeader(String running, String slots) {
    return 'Выполняется $running/$slots';
  }

  @override
  String queueQueued(num n) {
    return '$n в очереди';
  }

  @override
  String queueWaitingServer(String n) {
    return '$n ждут сервер';
  }

  @override
  String get queueBadge_blocked => 'Ждёт · связи';

  @override
  String get queueBadge_slots => 'В очереди · слоты';

  @override
  String get queueBadge_server => 'В очереди · сервер';

  @override
  String get queueBadge_claude => 'Пауза · Claude';

  @override
  String get queueTitle_blocked => 'Ждёт связанные тикеты';

  @override
  String get queueTitle_slots => 'Ждёт свободный слот';

  @override
  String get queueTitle_server => 'В очереди сервера';

  @override
  String get queueTitle_claude => 'Ждёт Claude';

  @override
  String queuePosition(String position) {
    return '#$position в очереди сервера';
  }

  @override
  String queueOthers(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Впереди $n тикета других пространств.',
      many: 'Впереди $n тикетов других пространств.',
      few: 'Впереди $n тикета других пространств.',
      one: 'Впереди $n тикет другого пространства.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String queueEstimate(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes минуты',
      many: '$minutes минут',
      few: '$minutes минуты',
      one: '$minutes минуту',
    );
    return 'Начнётся примерно через $_temp0.';
  }

  @override
  String queueServerFull(String runs, String reserved, String budget) {
    return 'Сервер загружен ($runs запусков, занято $reserved из $budget).';
  }

  @override
  String queueSlotsHint(String running, String slots) {
    return 'Занято $running из $slots слотов. Тикет начнётся, когда один освободится.';
  }

  @override
  String get queueAddSlot => 'Добавить слот';

  @override
  String get queueClaudeHint => 'Подключите аккаунт или включите кредиты в настройках пространства → Claude.';

  @override
  String get queueMember => 'Участник';

  @override
  String get queueTakeOver => 'Взять себе';

  @override
  String get queueTakenOver => 'Тикет ваш: в режиме «у каждого свой» он выполняется на вашем аккаунте Claude.';

  @override
  String queueCreatedBy(String name) {
    return 'Создал(а) $name';
  }

  @override
  String queueBy(String name) {
    return '$name';
  }

  @override
  String redFlagsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n тревожного признака',
      many: '$n тревожных признаков',
      few: '$n тревожных признака',
      one: '$n тревожный признак',
    );
    return '$_temp0';
  }

  @override
  String get redFlagsSub =>
      'Сканирование изменения agnts нашло эти строки. Часто они означают, что проверки прошли «не тем путём»; ревью agnts проверяет каждую.';

  @override
  String get redFlagsKind_skipped_test => 'Пропущенный или выделенный тест';

  @override
  String get redFlagsKind_removed_assertion => 'Удалены проверки';

  @override
  String get redFlagsKind_deleted_test => 'Удалён файл тестов';

  @override
  String get redFlagsKind_silenced_lint => 'Линтер заглушён';

  @override
  String get redFlagsKind_swallowed_error => 'Ошибка проглочена';

  @override
  String get redFlagsKind_todo => 'Оставлен TODO';

  @override
  String get redFlagsKind_new_dependency => 'Новая зависимость';

  @override
  String get relationsTab => 'Порядок';

  @override
  String get relationsTitle => 'Порядок и конфликты';

  @override
  String get relationsSub =>
      'agnts пишет код для нескольких тикетов сразу и сливает их по одному. Тикет ждёт, пока тикеты, от которых он зависит, будут слиты, а два тикета, меняющие один и тот же код, никогда не пишутся одновременно.';

  @override
  String get relationsWaitingTitle => 'Ждёт другие тикеты';

  @override
  String get relationsWaitingSub => 'Работа над кодом начнётся сама, как только они будут слиты или отклонены.';

  @override
  String get relationsWaitingBadge => 'Ждёт';

  @override
  String get relationsWaitsFor => 'Ждёт';

  @override
  String get relationsWaitedBy => 'Задерживает';

  @override
  String get relationsConflicts => 'Не одновременно';

  @override
  String get relationsProposedTitle => 'Предложено agnts';

  @override
  String get relationsProposedSub => 'agnts в них не уверен. Принятые управляют очередью; отклонённые больше не предлагаются.';

  @override
  String get relationsActiveTitle => 'Действуют';

  @override
  String get relationsEmpty => 'Связей нет. Тикет запустится, как только освободится слот.';

  @override
  String get relationsAccept => 'Принять';

  @override
  String get relationsDismiss => 'Отклонить';

  @override
  String get relationsRemove => 'Запустить всё равно';

  @override
  String relationsRemoveConfirm(String key, String other) {
    return '$key и $other больше не будут ждать друг друга. Продолжить?';
  }

  @override
  String relationsConfidence(String pct) {
    return 'уверенность $pct%';
  }

  @override
  String get relationsLanded => 'слит';

  @override
  String get relationsSource_jira => 'Связь в Jira';

  @override
  String get relationsSource_user => 'Добавлено вами';

  @override
  String get relationsSource_agnts => 'agnts';

  @override
  String get relationsSource_rule => 'Предсказанное пересечение';

  @override
  String get relationsSource_git => 'Найдено в диффах';

  @override
  String relationsBasis_files(String files) {
    return 'Оба меняют $files';
  }

  @override
  String get relationsBasis_migrations => 'Оба добавляют миграцию базы данных';

  @override
  String get relationsBasis_lockfile => 'Оба меняют lock-файлы зависимостей';

  @override
  String get relationsBasis_codegen => 'Оба меняют спецификацию API или сгенерированный код';

  @override
  String get relationsBasis_i18n => 'Оба меняют файлы переводов';

  @override
  String relationsBasis_diff(String files) {
    return 'Готовые изменения затрагивают одни и те же строки в $files';
  }

  @override
  String get relationsConfirmed => 'Подтверждено диффами';

  @override
  String relationsDismissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отклонено',
      many: '$count отклонено',
      few: '$count отклонены',
      one: '$count отклонена',
    );
    return '$_temp0';
  }

  @override
  String get relationsAddTitle => 'Добавить связь';

  @override
  String get relationsAddType => 'Связь';

  @override
  String get relationsAddOther => 'Ключ тикета';

  @override
  String get relationsAddOtherPh => 'PAY-12';

  @override
  String get relationsAdd => 'Добавить';

  @override
  String get relationsAddHint =>
      'Ждёт: этот тикет начнёт работу над кодом, когда другой будет слит. Не одновременно: тот, что начнёт вторым, ждёт, пока первый не будет слит.';

  @override
  String get relationsAdded => 'Связь добавлена';

  @override
  String get relationsFootprintTitle => 'Предсказанный след';

  @override
  String get relationsFootprintSub =>
      'Что, по оценке анализа, изменит этот тикет. agnts сравнивает следы, чтобы разводить пересекающиеся тикеты.';

  @override
  String get relationsFootprintFiles => 'Файлы';

  @override
  String get relationsFootprintProvides => 'Добавляет';

  @override
  String get relationsFootprintConsumes => 'Нужно';

  @override
  String get relationsFootprintMigrations => 'Добавляет миграцию базы данных';

  @override
  String get relationsMarkMerged => 'Отметить слитым';

  @override
  String get relationsMarkMergedHint => 'Нет вебхука о слиянии? Отметьте pull request слитым, чтобы ожидающие его тикеты могли начать.';

  @override
  String get relationsSource_plane => 'Связь в Plane';

  @override
  String get replayTitle => 'Повторить с текущим agnts';

  @override
  String get replaySub =>
      'Повторить этот тикет с коммита, с которого он начинался, с текущими промптами, описанием и правилами, и сравнить результат с тем, что вы одобрили. Повтор никогда не отправляется.';

  @override
  String get replayStart => 'Повторить';

  @override
  String replayConfirm(String key) {
    return 'agnts создаст новую задачу, которая заново выполнит $key с того места, где он начинался. Она расходует ваш план Claude, как любой тикет.';
  }

  @override
  String replayCreated(String key) {
    return 'Повтор $key в очереди';
  }

  @override
  String get replayBanner => 'Это повтор для оценки agnts: он никогда не отправляется. Сравните его с';

  @override
  String get replayEvalTitle => 'Оценка повторов';

  @override
  String get replayEvalSub =>
      'Завершённые тикеты, повторённые новой версией agnts, в сравнении с одобренным вами изменением. Запустите повтор кнопкой «Повторить» на завершённом тикете или `agnts eval replay KEY`.';

  @override
  String get replayNone => 'Повторов пока нет.';

  @override
  String get replayRecent => 'Последние повторы';

  @override
  String get replayColReplays => 'Повторы';

  @override
  String get replayColChecks => 'Проверки';

  @override
  String get replayColLooksGood => 'Ревью OK';

  @override
  String get replayColOverlap => 'Те же файлы';

  @override
  String get replayColOverlapHint => 'Насколько изменённые файлы повтора совпадают с одобренным изменением (индекс Жаккара)';

  @override
  String get replayColRecall => 'Покрытие';

  @override
  String get replayColRecallHint => 'Доля файлов одобренного изменения, которые повтор тоже изменил';

  @override
  String get replayColTurns => 'Ходы (оригинал)';

  @override
  String get replayColCost => 'Стоимость (оригинал)';

  @override
  String get replayColReplay => 'Повтор';

  @override
  String get replayColOf => 'Чего';

  @override
  String get replayColState => 'Состояние';

  @override
  String get replayColReview => 'Ревью';

  @override
  String get replayPass => 'прошли';

  @override
  String get replayFail => 'упали';

  @override
  String get replayVerdict_looks_good => 'всё хорошо';

  @override
  String get replayVerdict_has_concerns => 'есть сомнения';

  @override
  String get replayVerdict_needs_changes => 'нужны правки';

  @override
  String get repoBack => 'Назад к репозиториям';

  @override
  String get repoNotFound => 'Репозиторий не найден.';

  @override
  String get repoEdit => 'Изменить настройки';

  @override
  String get repoBranches => 'Ветки';

  @override
  String get repoCommits => 'Коммиты';

  @override
  String get repoPipelines => 'Пайплайны';

  @override
  String get repoMembers => 'Участники';

  @override
  String get repoMembersSub_github => 'Соавторы на GitHub. При одобрении ревью на них можно назначить пул-реквест.';

  @override
  String get repoMembersSub_gitlab =>
      'Участники проекта в GitLab, включая участников групп. При одобрении ревью на них можно назначить merge request.';

  @override
  String get repoMembersSearch => 'Поиск участников';

  @override
  String get repoMembersNone => 'Участники не найдены. Возможно, токену не разрешено их получать.';

  @override
  String repoBranchesSub(String branch) {
    return 'agnts работает в отдельной ветке для каждого тикета и никогда не коммитит в $branch.';
  }

  @override
  String repoArchivedBanner(String time) {
    return 'Перемещён в архив $time. agnts не берёт новые тикеты и задачи для этого репозитория, пока вы его не восстановите.';
  }

  @override
  String get repoSrcLabel => 'Где';

  @override
  String get repoSrcOrigin => 'Origin';

  @override
  String get repoSrcLocal => 'Локальные';

  @override
  String repoSrcLocalN(String n) {
    return 'Локальные ($n)';
  }

  @override
  String repoLocalSub(String branch) {
    return 'Ветки в собственных клонах agnts на вашем сервере. agnts сначала коммитит сюда и отправляет только после вашего одобрения; в $branch он никогда не коммитит.';
  }

  @override
  String get repoColPush => 'В origin';

  @override
  String get repoPush_local => 'Не отправлена';

  @override
  String get repoPush_pushed => 'Отправлена';

  @override
  String repoPush_unpushed(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n коммита не отправлены',
      many: '$n коммитов не отправлены',
      few: '$n коммита не отправлены',
      one: '$n коммит не отправлен',
    );
    return '$_temp0';
  }

  @override
  String get repoPush_differs => 'Origin изменился';

  @override
  String get repoPush_local_help => 'Есть только на сервере. agnts отправит её, когда вы одобрите ревью.';

  @override
  String get repoPush_pushed_help => 'В origin тот же коммит.';

  @override
  String get repoPush_unpushed_help => 'В origin есть ветка, но без последних коммитов.';

  @override
  String get repoPush_differs_help => 'Кто-то отправил в эту ветку коммиты, которых нет в копии agnts.';

  @override
  String get repoLocalNone => 'Локальных веток пока нет. agnts создаёт ветку, когда начинает работу над тикетом.';

  @override
  String get repoCommitsSub => 'Последние коммиты в основной ветке, новые сверху.';

  @override
  String get repoLoadMore => 'Загрузить ещё';

  @override
  String get repoMoreError => 'Не удалось загрузить ещё.';

  @override
  String repoCommitsEnd(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Показаны все $n коммита',
      many: 'Показаны все $n коммитов',
      few: 'Показаны все $n коммита',
      one: 'Показан $n коммит',
    );
    return '$_temp0';
  }

  @override
  String get repoPipelinesSub => 'Сборки, тесты и деплои на git-хостинге.';

  @override
  String repoPipelinesEnd(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Показаны все $n запуска',
      many: 'Показаны все $n запусков',
      few: 'Показаны все $n запуска',
      one: 'Показан $n запуск',
    );
    return '$_temp0';
  }

  @override
  String get repoFilterAll => 'Все';

  @override
  String get repoFilterOthers => 'Остальные';

  @override
  String get repoColBranch => 'Ветка';

  @override
  String get repoColCommit => 'Последний коммит';

  @override
  String get repoColAuthor => 'Автор';

  @override
  String get repoColAheadBehind => 'Впереди / позади';

  @override
  String get repoColChecks => 'Проверки';

  @override
  String get repoColUpdated => 'Обновлено';

  @override
  String get repoDefault => 'По умолчанию';

  @override
  String get repoNone => 'Пока ничего нет.';

  @override
  String get repoCi_ok => 'Прошло';

  @override
  String get repoCi_fail => 'Упало';

  @override
  String get repoCi_run => 'Выполняется';

  @override
  String get repoCi_pending => 'Ждёт';

  @override
  String get repoCi_manual => 'Ждёт вас';

  @override
  String get repoCi_skip => 'Пропущено';

  @override
  String get repoCi_canceled => 'Отменено';

  @override
  String get repoCi_none => 'Нет пайплайна';

  @override
  String get repoKpiBranches => 'Ветки';

  @override
  String repoKpiBranchesNote(String n) {
    return '$n от agnts';
  }

  @override
  String get repoKpiCommits => 'Коммитов за неделю';

  @override
  String repoKpiCommitsNote(String n) {
    return '$n написано agnts';
  }

  @override
  String get repoKpiPipelines => 'Успешных пайплайнов';

  @override
  String repoKpiPipelinesNote(String n) {
    return 'Последние $n завершённых запусков';
  }

  @override
  String get repoKpiProd => 'Продакшн';

  @override
  String repoDeployedAgo(String time) {
    return 'Развёрнуто $time';
  }

  @override
  String get repoNotDeployed => 'Ещё не развёрнуто';

  @override
  String get repoDeployed => 'Развёрнуто';

  @override
  String get repoEmpty => 'Пусто';

  @override
  String get repoCommit => 'Коммит';

  @override
  String get repoOpen => 'Открыть';

  @override
  String get repoNoEnvironments => 'На git-хостинге нет окружений для деплоя.';

  @override
  String get repoDeployHelp =>
      'agnts ждёт проверок, прежде чем тикет попадёт к вам на ревью. Деплой всегда решаете вы, и из чата Claude он недоступен.';

  @override
  String repoDeployBranch(String branch) {
    return 'Развернуть $branch';
  }

  @override
  String get repoDeploy => 'Развернуть';

  @override
  String repoDeployConfirm(String stage, String sha) {
    return 'Запустить $stage для $sha?';
  }

  @override
  String repoDeployWorkflowConfirm(String workflow, String branch) {
    return 'Запустить $workflow на $branch?';
  }

  @override
  String get repoDeployStarted => 'Деплой запущен';

  @override
  String get repoStage => 'Этап';

  @override
  String get repoStatus => 'Статус';

  @override
  String get repoDuration => 'Длительность';

  @override
  String get repoOpenRun => 'Открыть на git-хостинге';

  @override
  String get repoBrief => 'Описание';

  @override
  String get repoCi => 'CI';

  @override
  String get repoCode => 'Код';

  @override
  String get repoCodeSub => 'Файлы репозитория в выбранной ветке, прочитанные с git-хостинга.';

  @override
  String get repoCodeBranch => 'Ветка';

  @override
  String get repoCodePath => 'Путь';

  @override
  String get repoCodeRoot => 'Корень';

  @override
  String repoCodeLines(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n строки', many: '$n строк', few: '$n строки', one: '$n строка');
    return '$_temp0';
  }

  @override
  String get repoCodeView => 'Вид';

  @override
  String get repoCodePreview => 'Просмотр';

  @override
  String get repoCodeSource => 'Код';

  @override
  String get repoCodeBinary => 'Это двоичный файл, его нельзя показать здесь.';

  @override
  String get repoCodeTooLarge => 'Файл больше 1 МБ, он слишком большой, чтобы показать его здесь. Откройте его на git-хостинге.';

  @override
  String get repoCodeEmptyFile => 'Файл пуст.';

  @override
  String get repoCodeEmpty => 'В этой ветке пока нет файлов.';

  @override
  String get repoCodeSubmodule => 'Подмодуль';

  @override
  String get repoCodeSymlink => 'Ссылка';

  @override
  String repoCodeCapped(String n) {
    return 'Показаны только первые $n элементов этой папки.';
  }

  @override
  String get reposTitle => 'Репозитории';

  @override
  String get reposLede =>
      'Код, с которым может работать agnts. Каждый запуск клонирует репозиторий в новый контейнер на вашем сервере и выполняет эти проверки, прежде чем что-то попадёт к вам на ревью.';

  @override
  String get reposAdd => 'Добавить репозиторий';

  @override
  String get reposViewLabel => 'Показать';

  @override
  String reposViewActive(String n) {
    return 'Активные ($n)';
  }

  @override
  String reposViewArchived(String n) {
    return 'Архив ($n)';
  }

  @override
  String get reposArchivedSub =>
      'Архивные репозитории сохраняют историю, но не получают новых тикетов и задач. Восстановите репозиторий, чтобы снова с ним работать.';

  @override
  String get reposArchive => 'В архив';

  @override
  String get reposRestore => 'Восстановить';

  @override
  String reposArchived(String name) {
    return '$name перемещён в архив';
  }

  @override
  String reposRestored(String name) {
    return '$name восстановлен';
  }

  @override
  String reposArchiveConfirm(String name) {
    return 'Переместить $name в архив? Тикеты и история сохранятся, но agnts перестанет брать для него новые тикеты Jira и задачи. Уже начатая работа будет завершена. Восстановить можно в любой момент.';
  }

  @override
  String get reposNoArchived => 'В архиве нет репозиториев.';

  @override
  String get reposImport => 'Импорт из GitHub/GitLab';

  @override
  String get reposImportTitle => 'Импорт репозитория';

  @override
  String get reposImportSub => 'Репозитории, доступные вашему токену GitHub или GitLab. Выберите один и задайте проверки.';

  @override
  String get reposImportFrom => 'Источник';

  @override
  String get reposImportSearch => 'Поиск репозиториев';

  @override
  String get reposImportLoading => 'Загрузка репозиториев…';

  @override
  String get reposImportEmpty => 'Токену не доступен ни один репозиторий. Проверьте, к каким репозиториям выдан доступ.';

  @override
  String get reposImportNone => 'Сначала подключите GitHub или GitLab.';

  @override
  String get reposImportConnect => 'Открыть интеграции';

  @override
  String get reposImportPrivate => 'Приватный';

  @override
  String reposImportUpdated(String time) {
    return 'обновлён $time';
  }

  @override
  String get reposImportAdded => 'Добавлен';

  @override
  String get reposImportPick => 'Добавить';

  @override
  String reposMissingHelp(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count репозитория',
      many: 'У $count репозиториев',
      few: 'У $count репозиториев',
      one: 'У $count репозитория',
    );
    return '$_temp0 нет CLAUDE.md. agnts всё равно работает, но тратит больше шагов, чтобы разобраться. Добавьте файл со структурой проекта, соглашениями и командами тестов.';
  }

  @override
  String get reposColRepo => 'Репозиторий';

  @override
  String get reposColSource => 'Источник';

  @override
  String get reposColBranch => 'Ветка';

  @override
  String get reposColTest => 'Команда тестов';

  @override
  String get reposColClaude => 'CLAUDE.md';

  @override
  String get reposColOpen => 'Открыто';

  @override
  String reposJira(String project) {
    return 'Jira $project';
  }

  @override
  String get reposSide => 'Свой проект';

  @override
  String get reposFound => 'Найден';

  @override
  String get reposMissing => 'Нет';

  @override
  String get reposUnknown => 'Не проверен';

  @override
  String get reposNoMatch => 'Нет репозиториев по вашему запросу.';

  @override
  String get reposNone => 'Репозиториев пока нет. Добавьте первый, чтобы agnts мог в нём работать.';

  @override
  String get reposDrawerSub => 'Принимает задачи своего проекта, а после привязки к проекту — и тикеты Jira или задачи Plane';

  @override
  String get reposName => 'Название';

  @override
  String get reposCloneUrl => 'URL для клонирования';

  @override
  String get reposCloneHelp =>
      'https-адрес на github.com или в подключённом GitLab. agnts клонирует и отправляет код с токеном этого хостинга.';

  @override
  String get reposJiraProject => 'Ключ проекта Jira';

  @override
  String get reposJiraHelp => 'Необязательно. Тикеты из этого проекта Jira с меткой agnts выполняются здесь.';

  @override
  String get reposTaskPrefix => 'Префикс ключа задач';

  @override
  String reposTaskPrefixHelp(String prefix) {
    return 'Задачи своего проекта нумеруются как $prefix-1, $prefix-2. Должен отличаться от ключа проекта Jira и проекта Plane.';
  }

  @override
  String get reposBranch => 'Основная ветка';

  @override
  String get reposBranchHelp => 'Рабочие ветки создаются от неё.';

  @override
  String get reposBranchTemplate => 'Формат имени ветки';

  @override
  String reposBranchTemplateHelp(String key, String number, String fallback) {
    return 'Как agnts называет ветку для каждой задачи. Должен содержать $key или $number. Оставьте пустым для $fallback.';
  }

  @override
  String reposBranchTemplateExample(String example) {
    return 'Пример: $example';
  }

  @override
  String get reposCommitTemplate => 'Формат сообщения коммита';

  @override
  String get reposCommitTemplateHelp => 'Как agnts пишет сообщения коммитов. Пустой scope убирает скобки. Оставьте пустым для KEY: Title.';

  @override
  String reposCommitTemplateExample(String example) {
    return 'Пример: $example';
  }

  @override
  String get reposPlaceholders => 'Подстановки';

  @override
  String get reposPhPrefix => 'Префикс веток репозитория, по умолчанию agnts/.';

  @override
  String get reposPhType => 'Вид работы: feature для кода, bugfix для бага, test, swagger-test.';

  @override
  String get reposPhKey => 'Ключ задачи в agnts: VIS-42 или ключ задачи из Jira или Plane.';

  @override
  String get reposPhNumber => 'Номер тикета задачи, например AMANAT-2288. Если пуст, используется ключ.';

  @override
  String get reposPhSlug => 'Название задачи строчными буквами через дефис, до 40 символов.';

  @override
  String get reposPhUser => 'Имя пользователя, на кого назначена задача, или её автора.';

  @override
  String get reposPhCommitType =>
      'Тип изменения, который выбирает агент: feat, fix, chore, refactor, docs, test... Иначе берётся по виду задачи.';

  @override
  String get reposPhScope => 'Область, которую изменил агент, например deps или auth. Может быть пустой.';

  @override
  String get reposPhSubject => 'Краткое описание изменения от агента в одну строку. Иначе берётся название задачи.';

  @override
  String get reposPhTitle => 'Название задачи как есть.';

  @override
  String get reposBuild => 'Команда сборки';

  @override
  String get reposLint => 'Команда линтера';

  @override
  String get reposTest => 'Команда тестов';

  @override
  String get reposTestHelp => 'Должна пройти, прежде чем тикет попадёт к вам на ревью.';

  @override
  String get reposInstructions => 'Дополнительные инструкции';

  @override
  String get reposInstructionsHelp => 'Добавляются в каждый запрос для этого репозитория, в дополнение к CLAUDE.md.';

  @override
  String get reposClaudeFound => 'Найден в корне репозитория';

  @override
  String get reposClaudeMissing => 'Нет. agnts всё равно работает, но CLAUDE.md экономит шаги.';

  @override
  String get reposClaudeUnknown => 'Проверяется после сохранения';

  @override
  String get reposSaved => 'Репозиторий сохранён';

  @override
  String get reposEdit => 'Изменить';

  @override
  String get reposDeployWorkflow => 'Workflow деплоя';

  @override
  String get reposDeployWorkflowHelp =>
      'Файл workflow GitHub Actions с workflow_dispatch, например deploy.yml. Кнопка «Деплой» на странице репозитория запускает его.';

  @override
  String get reposColStack => 'Тулчейны';

  @override
  String get reposToolchains => 'Тулчейны';

  @override
  String get reposToolchainsHelp =>
      'Языки и инструменты сборки, которые ставятся в каждый запуск — один раз на версию — и сохраняются для следующих запусков.';

  @override
  String get reposToolchainsAuto =>
      'Определены по репозиторию (go.mod, .nvmrc, .python-version, mise.toml, …) и обновляются, когда эти файлы меняются.';

  @override
  String get reposToolchainsManual => 'Заданы вручную: автоопределение их не меняет.';

  @override
  String get reposToolchainsBackToAuto => 'Определять автоматически';

  @override
  String reposToolchainFrom(String source) {
    return 'из $source';
  }

  @override
  String reposToolchainRemove(String tool) {
    return 'Убрать $tool';
  }

  @override
  String get reposToolchainAdd => 'Добавить';

  @override
  String get reposToolchainPh => 'инструмент@версия, например python@3.12';

  @override
  String get reposToolchainBad => 'Укажите как инструмент@версия, например node@20 или rust@stable.';

  @override
  String get reposToolchainsNone => 'Пока нет: они определятся после сохранения, или нажмите «Определить».';

  @override
  String get reposDetect => 'Определить';

  @override
  String get reposDetectDeep => 'Спросить Claude';

  @override
  String get reposDetectDeepHelp =>
      'Claude прочитает README и файлы CI, если сканирование не нашло команд. Занимает около минуты и расходует ваш план Claude.';

  @override
  String get reposDetecting => 'Читаю репозиторий…';

  @override
  String reposDetectDone(String list) {
    return 'Найдено: $list.';
  }

  @override
  String get reposDetectNothing => 'Известных файлов сборки не найдено. Добавьте тулчейны и команды вручную или спросите Claude.';

  @override
  String get reposDetectFilled => 'Пустые команды проверок заполнены — проверьте их перед сохранением.';

  @override
  String get reposDetectByClaude => 'Claude дополнил то, что не нашло сканирование.';

  @override
  String get reposDetectNeedsUrl => 'Сначала укажите URL для клонирования.';

  @override
  String get reposCmdAuto => 'определится после сохранения';

  @override
  String get reposNotes => 'Замечания автоопределения';

  @override
  String get reposAdvanced => 'Дополнительно';

  @override
  String get reposRunnerImage => 'Образ запуска';

  @override
  String get reposRunnerImageHelp =>
      'Необязательно. Образ, собранный на сервере FROM agnts-runner, — для системных библиотек или SDK, которые тулчейны не дают (Android, Flutter). Пусто — образ по умолчанию.';

  @override
  String get reposMemory => 'Память';

  @override
  String get reposMemoryHelp =>
      'Необязательно, для тяжёлых сборок (JVM, Rust, .NET). По умолчанию — значение сервера; сервер ограничивает максимум (AGNTS_RUN_MEMORY_MAX_MB, по умолчанию 8 ГБ).';

  @override
  String get reposMemoryDefault => 'По умолчанию';

  @override
  String get reposBuildEnv => 'Окружение сборки';

  @override
  String get reposBuildEnvHelp =>
      'Строки KEY=value для каждого запуска, например токены приватных реестров пакетов (NPM_TOKEN, PIP_INDEX_URL). Хранятся зашифрованными и больше не показываются. Claude может прочитать их во время работы, поэтому используйте токены только для чтения.';

  @override
  String reposBuildEnvSet(String names) {
    return 'Задано: $names';
  }

  @override
  String get reposBuildEnvReplace => 'Заменить';

  @override
  String get reposBuildEnvClear => 'Очистить';

  @override
  String get reposBuildEnvCleared => 'Очистится при сохранении.';

  @override
  String reposPlane(String project) {
    return 'Plane $project';
  }

  @override
  String get reposPlaneProject => 'Проект Plane';

  @override
  String get reposPlaneHelp =>
      'Необязательно. Идентификатор проекта (WEB в WEB-123). Задачи этого проекта Plane с меткой agnts выполняются здесь.';

  @override
  String get reposSearch => 'Поиск по имени, стеку, проекту или группе';

  @override
  String get reviewTitle => 'Код-ревью agnts';

  @override
  String get reviewReportTitle => 'Ревью отчёта от agnts';

  @override
  String get reviewSub => 'Второе мнение, пока вы проверяете. Оно никогда не блокирует одобрение: решаете вы.';

  @override
  String get reviewPending => 'В очереди: agnts проверит это, как только освободится исполнитель. Пока можно проверить самому.';

  @override
  String get reviewRunning => 'agnts проверяет…';

  @override
  String get reviewFailed => 'Ревью не удалось. Проверьте сами или запустите снова.';

  @override
  String get reviewNone => 'agnts это не проверял.';

  @override
  String reviewStale(String n) {
    return 'Это ревью ревизии $n; с тех пор работа изменилась.';
  }

  @override
  String get reviewRun => 'Проверить с agnts';

  @override
  String get reviewRunAgain => 'Проверить снова';

  @override
  String get reviewVerdict_looks_good => 'Всё хорошо';

  @override
  String get reviewVerdict_has_concerns => 'Есть замечания';

  @override
  String get reviewVerdict_needs_changes => 'Нужны изменения';

  @override
  String get reviewSev_blocker => 'Блокер';

  @override
  String get reviewSev_major => 'Серьёзно';

  @override
  String get reviewSev_minor => 'Незначительно';

  @override
  String get reviewSev_nit => 'Мелочь';

  @override
  String get reviewCat_correctness => 'Корректность';

  @override
  String get reviewCat_security => 'Безопасность';

  @override
  String get reviewCat_performance => 'Производительность';

  @override
  String get reviewCat_tests => 'Тесты';

  @override
  String get reviewCat_rules => 'Правила команды';

  @override
  String get reviewCat_maintainability => 'Сопровождаемость';

  @override
  String get reviewCat_accuracy => 'Точность';

  @override
  String get reviewCat_completeness => 'Полнота';

  @override
  String get reviewCat_other => 'Другое';

  @override
  String reviewFindings(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count замечания',
      many: '$count замечаний',
      few: '$count замечания',
      one: '$count замечание',
      zero: 'Замечаний нет',
    );
    return '$_temp0';
  }

  @override
  String get reviewNoFindings => 'agnts не нашёл проблем.';

  @override
  String get reviewStrengths => 'Сделано хорошо';

  @override
  String get reviewSuggestion => 'Предложение';

  @override
  String get reviewAddToFeedback => 'Добавить в отзыв';

  @override
  String get reviewAdded => 'В отзыве';

  @override
  String get reviewAddAll => 'Добавить всё в отзыв';

  @override
  String get reviewShowInDiff => 'Показать в диффе';

  @override
  String reviewModel(String model, String reason) {
    return 'Проверил $model: $reason';
  }

  @override
  String get reviewCat_architecture => 'Архитектура';

  @override
  String get reviewCat_scope => 'Рамки задачи';

  @override
  String get reviewsTitle => 'Ревью пул-реквестов';

  @override
  String get reviewsLede =>
      'agnts проверяет пул-реквесты, назначенные вам в GitHub и GitLab. Если ревью в порядке, слейте отсюда, или отклоните его и проверьте сами на git-хостинге.';

  @override
  String get reviewsSync => 'Синхронизировать';

  @override
  String get reviewsSyncing => 'Синхронизация…';

  @override
  String reviewsSynced(String open, String repos, String created, String rereview, String closed) {
    return '$open ждут вас в $repos репозиториях · $created новых · $rereview проверены заново · $closed завершены';
  }

  @override
  String get reviewsSyncErrors => 'Не удалось прочитать:';

  @override
  String get reviewsSettingsTitle => 'Как agnts их берёт';

  @override
  String get reviewsEnabled => 'Проверять автоматически';

  @override
  String get reviewsEnabledHelp =>
      'Каждые 5 минут смотреть git-хостинг и проверять новые пул-реквесты. Когда выключено, только по кнопке «Синхронизировать».';

  @override
  String get reviewsReviewRequested => 'И запросы на ревью';

  @override
  String get reviewsReviewRequestedHelp => 'Брать также пул-реквесты, где у вас запрошено ревью, а не только назначенные вам.';

  @override
  String get reviewsSkipDrafts => 'Пропускать черновики';

  @override
  String get reviewsSkipDraftsHelp => 'Не трогать черновики, пока они не готовы.';

  @override
  String get reviewsRereview => 'Проверять новые коммиты';

  @override
  String get reviewsRereviewHelp => 'Проверять заново, если автор запушил, пока ревью ждёт вас.';

  @override
  String get reviewsMergeMethod => 'Способ слияния';

  @override
  String get reviewsMergeMethodHelp => 'Как agnts сливает принятый вами пул-реквест.';

  @override
  String get reviewsMerge_merge => 'Merge-коммит';

  @override
  String get reviewsMerge_squash => 'Squash';

  @override
  String get reviewsMerge_rebase => 'Rebase';

  @override
  String get reviewsWaiting => 'Ждут вас';

  @override
  String get reviewsInProgress => 'В работе';

  @override
  String get reviewsFinished => 'Завершены';

  @override
  String get reviewsEmpty => 'Здесь пусто.';

  @override
  String get reviewsEmptyAll => 'Пул-реквестов для ревью пока нет. Назначьте себе один в GitHub или GitLab и нажмите «Синхронизировать».';

  @override
  String get reviewsWhy_assigned => 'назначен';

  @override
  String get reviewsWhy_review_requested => 'запрошено ревью';

  @override
  String get reviewsWhy_manual => 'запрошено в agnts';

  @override
  String reviewsBy(String author) {
    return 'от @$author';
  }

  @override
  String get reviewsHowTitle => 'Как вы проверяете';

  @override
  String get reviewsHowSub =>
      'Заметки, которые вы оставляете, прося проверить заново или отклоняя ревью, при следующем ревью вносятся в ваш профиль. Все следующие ревью его читают.';

  @override
  String get reviewsNoReviewers =>
      'agnts пока ничего не знает о том, как вы проверяете. Оставьте заметку, когда просите проверить заново, или добавьте её ниже.';

  @override
  String get reviewsProfile => 'Профиль';

  @override
  String get reviewsProfileHint => 'Markdown: что для вас важно, что считается шумом, как вы оцениваете серьёзность.';

  @override
  String reviewsFolded(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n заметки учтены',
      many: '$n заметок учтено',
      few: '$n заметки учтены',
      one: '$n заметка учтена',
    );
    return '$_temp0';
  }

  @override
  String get reviewsPending => 'Ещё не учтены';

  @override
  String get reviewsSaveProfile => 'Сохранить профиль';

  @override
  String get reviewsProfileSaved => 'Профиль сохранён';

  @override
  String get reviewsAddNote => 'Добавить заметку';

  @override
  String get reviewsNotePlaceholder => 'Например: замечания по именованию для меня шум; всегда проверяй, что миграции можно откатить.';

  @override
  String get reviewsNoteAdded => 'Заметка добавлена';

  @override
  String get reviewsDeleteNote => 'Удалить заметку';

  @override
  String get reviewsNoteKind_rereview => 'повторное ревью';

  @override
  String get reviewsNoteKind_dismissed => 'отклонено';

  @override
  String get reviewsNoteKind_manual => 'написана здесь';

  @override
  String get reviewsLogin => 'Имя на git-хостинге';

  @override
  String reviewsPr(String number) {
    return 'Пул-реквест #$number';
  }

  @override
  String reviewsReviewed(String sha) {
    return 'Последний коммит $sha';
  }

  @override
  String reviewsNewCommits(String sha) {
    return 'Новые коммиты после ревью agnts ($sha): он проверит их снова';
  }

  @override
  String reviewsPostBtn(String host) {
    return 'Опубликовать ревью в $host';
  }

  @override
  String reviewsPostConfirm(String number, String host) {
    return 'Опубликовать ревью agnts для #$number в $host комментарием? Оно публикуется от вашего аккаунта $host, и его увидят все участники pull request.';
  }

  @override
  String reviewsPostedToast(String host) {
    return 'Ревью опубликовано в $host';
  }

  @override
  String reviewsPosted(String host, String when) {
    return 'Ревью agnts этого коммита опубликовано в $host · $when';
  }

  @override
  String get reviewsQueuedSub => 'agnts загрузит и проверит его.';

  @override
  String get reviewsFetchingTitle => 'Загружаем пул-реквест';

  @override
  String get reviewsReviewingTitle => 'Проверяем пул-реквест';

  @override
  String get reviewsReviewingSub => 'agnts читает изменения. Его ревью появится здесь.';

  @override
  String get reviewsReadyTitle => 'Ревью agnts готово';

  @override
  String reviewsReadySub(String host) {
    return 'Слейте отсюда, попросите проверить заново с заметкой или отклоните и проверьте сами на $host.';
  }

  @override
  String get reviewsNoteLabel => 'Проверить заново с заметкой';

  @override
  String get reviewsNoteHint => 'Скажите agnts, в чём он ошибся или что упустил. Заметка также учит его тому, как вы проверяете.';

  @override
  String get reviewsMergeBtn => 'Слить пул-реквест';

  @override
  String reviewsMergeConfirm(String number, String host, String method) {
    return 'agnts сольёт #$number на $host ($method) на проверенном коммите.';
  }

  @override
  String get reviewsRereviewBtn => 'Проверить заново';

  @override
  String reviewsDismissBtn(String host) {
    return 'Отклонить, проверю сам на $host';
  }

  @override
  String get reviewsDismissReason => 'Почему (необязательно)';

  @override
  String get reviewsDismissReasonHint => 'Необязательно. Это тоже учит agnts тому, как вы проверяете.';

  @override
  String reviewsDismissConfirm(String number, String host) {
    return 'agnts перестанет проверять #$number. Пул-реквест останется открытым на $host.';
  }

  @override
  String get reviewsMergingTitle => 'Сливаем пул-реквест';

  @override
  String get reviewsMergedTitle => 'Слит';

  @override
  String reviewsMergedSub(String number) {
    return '#$number слит.';
  }

  @override
  String get reviewsDismissedTitle => 'Ревью отклонено';

  @override
  String reviewsDismissedSub(String host) {
    return 'Пул-реквест ваш на $host.';
  }

  @override
  String reviewsOpenOn(String host) {
    return 'Открыть на $host';
  }

  @override
  String get reviewsReviewTitle => 'Ревью пул-реквеста от agnts';

  @override
  String get rulesTitle => 'Правила';

  @override
  String get rulesLede =>
      'Инструкции, которым agnts следует в каждом тикете: глобальные правила для всех репозиториев и правила для одного репозитория. Claude проверяет каждое правило и задаёт вопросы обо всём неясном, прежде чем оно начнёт действовать.';

  @override
  String get rulesAdd => 'Добавить правило';

  @override
  String get rulesAddSubmit => 'Добавить и проверить';

  @override
  String get rulesDrawerSub =>
      'Пишите так, как объясняли бы новому коллеге. Claude проверит правило, прежде чем ему будет следовать какой-либо тикет.';

  @override
  String get rulesRuleTitle => 'Название';

  @override
  String get rulesTitlePlaceholder => 'Тесты для новых эндпоинтов';

  @override
  String get rulesScope => 'Где действует';

  @override
  String get rulesScopeHelp => 'Глобальные правила действуют во всех репозиториях. Если правила расходятся, побеждает правило репозитория.';

  @override
  String get rulesGlobal => 'Глобальное';

  @override
  String get rulesGlobalHint => 'Все репозитории';

  @override
  String get rulesBody => 'Правило';

  @override
  String get rulesBodyPlaceholder => 'Для каждого нового HTTP-эндпоинта пишется интеграционный тест рядом с обработчиком.';

  @override
  String get rulesBodyHelp => 'Скажите, что делать, где и как поступать, если правилу нельзя следовать.';

  @override
  String get rulesEnabled => 'Включено';

  @override
  String rulesEnabledFor(String title) {
    return 'Правило $title включено';
  }

  @override
  String get rulesRereviewHelp =>
      'Вы изменили текст правила, поэтому Claude проверит его снова. Пока проверка не закончится, тикеты его не получают.';

  @override
  String get rulesSaved => 'Правило сохранено';

  @override
  String get rulesSavedReview => 'Правило сохранено; Claude проверяет его';

  @override
  String get rulesScopeLabel => 'Показать правила для';

  @override
  String rulesScopeAll(String n) {
    return 'Все правила ($n)';
  }

  @override
  String rulesScopeGlobal(String n) {
    return 'Глобальные ($n)';
  }

  @override
  String get rulesNone =>
      'Правил пока нет. Добавьте правило, чтобы рассказать agnts, как работает ваша команда: тесты, именование, логирование, что нельзя трогать.';

  @override
  String get rulesNoMatch => 'Нет подходящих правил.';

  @override
  String rulesWaitingHelp(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n правила ждут ваших ответов. Пока ответов нет, они не применяются к тикетам.',
      many: '$n правил ждут ваших ответов. Пока ответов нет, они не применяются к тикетам.',
      few: '$n правила ждут ваших ответов. Пока ответов нет, они не применяются к тикетам.',
      one: '$n правило ждёт ваших ответов. Пока ответов нет, оно не применяется к тикетам.',
    );
    return '$_temp0';
  }

  @override
  String get rulesStatus_pending => 'В очереди на проверку';

  @override
  String get rulesStatus_analyzing => 'Проверяется';

  @override
  String get rulesStatus_questions => 'Нужны ответы';

  @override
  String get rulesStatus_ready => 'Действует';

  @override
  String get rulesStatus_failed => 'Проверка не удалась';

  @override
  String get rulesOff => 'Выключено';

  @override
  String get rulesEdit => 'Изменить';

  @override
  String get rulesDelete => 'Удалить';

  @override
  String rulesDeleteBody(String title) {
    return 'Удалить правило «$title»? Тикеты, начатые после этого, больше не будут ему следовать.';
  }

  @override
  String get rulesPending => 'Ждёт свободного исполнителя. Claude проверяет правила до начала следующего тикета.';

  @override
  String get rulesAnalyzing => 'Claude читает правило и ищет в нём неясности и противоречия.';

  @override
  String rulesQuestionsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n вопроса, прежде чем правило начнёт действовать',
      many: '$n вопросов, прежде чем правило начнёт действовать',
      few: '$n вопроса, прежде чем правило начнёт действовать',
      one: '$n вопрос, прежде чем правило начнёт действовать',
    );
    return '$_temp0';
  }

  @override
  String get rulesQuestionsSub => 'Claude нашёл неясность. Ваши ответы станут частью правила.';

  @override
  String get rulesYourAnswer => 'Ваш ответ';

  @override
  String get rulesAddDetails => 'Добавьте детали (необязательно)';

  @override
  String rulesAnswerFor(String n) {
    return 'Ответ на вопрос $n';
  }

  @override
  String rulesDetailsFor(String n) {
    return 'Детали к вопросу $n';
  }

  @override
  String get rulesSendAnswers => 'Отправить ответы';

  @override
  String rulesQuestionsLeft(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Осталось $n вопроса',
      many: 'Осталось $n вопросов',
      few: 'Осталось $n вопроса',
      one: 'Остался $n вопрос',
    );
    return '$_temp0';
  }

  @override
  String get rulesAllAnswered => 'На все вопросы есть ответы';

  @override
  String get rulesAccept => 'Использовать как есть';

  @override
  String get rulesAcceptTitle => 'Использовать правило как есть?';

  @override
  String get rulesAcceptBody =>
      'Тикеты получат правило в вашей формулировке вместе с уже данными ответами. Открытые вопросы будут отброшены.';

  @override
  String rulesFailed(String error) {
    return 'Claude не смог проверить правило: $error';
  }

  @override
  String get rulesReviewAgain => 'Проверить снова';

  @override
  String get rulesInterpretation => 'Как agnts его понимает';

  @override
  String get rulesClarified => 'Что получают тикеты';

  @override
  String get rulesAsWritten => 'Используется как написано.';

  @override
  String rulesAnswersTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n вопроса с ответами',
      many: '$n вопросов с ответами',
      few: '$n вопроса с ответами',
      one: '$n вопрос с ответом',
    );
    return '$_temp0';
  }

  @override
  String rulesReviewedAgo(String ago) {
    return 'Проверено $ago';
  }

  @override
  String rulesAddedAgo(String ago) {
    return 'Добавлено $ago';
  }

  @override
  String get rulesAnswered => 'Ответы отправлены; Claude снова проверяет правило';

  @override
  String get rulesAccepted => 'Правило действует как написано';

  @override
  String get rulesQueued => 'Поставлено в очередь на проверку';

  @override
  String get rulesDeleted => 'Правило удалено';

  @override
  String get rulesTurnedOn => 'Правило включено';

  @override
  String get rulesTurnedOff => 'Правило выключено';

  @override
  String get rulesStatus_suggested => 'Предложено';

  @override
  String get rulesSuggestedFrom => 'agnts предлагает это правило по вашим замечаниям к';

  @override
  String get rulesSuggestedHint => 'Тикеты не следуют правилу, пока вы его не примете. Измените его, чтобы принять со своими правками.';

  @override
  String rulesSuggestedHelp(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'agnts предлагает $n правила по вашим замечаниям.',
      many: 'agnts предлагает $n правил по вашим замечаниям.',
      few: 'agnts предлагает $n правила по вашим замечаниям.',
      one: 'agnts предлагает $n правило по вашим замечаниям.',
    );
    return '$_temp0';
  }

  @override
  String get rulesAdopt => 'Принять';

  @override
  String get rulesAdoptAsWritten => 'Принять как есть';

  @override
  String get rulesDismiss => 'Отклонить';

  @override
  String rulesDismissBody(String title) {
    return 'agnts уберёт «$title» и больше не предложит его.';
  }

  @override
  String get rulesDismissed => 'Предложение отклонено';

  @override
  String get rulesKind => 'Тип';

  @override
  String get rulesKindRule => 'Правило';

  @override
  String get rulesKindContext => 'Бизнес-контекст';

  @override
  String get rulesKindRuleHelp => 'Инструкция, которой agnts следует в каждом тикете.';

  @override
  String get rulesKindContextHelp =>
      'Знания о продукте: что значат термины, какие инварианты должен соблюдать код, кто чем пользуется. Каждый запуск читает это перед началом.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLede => 'Как agnts подключается к вашим инструментам и как ведёт себя во время запусков.';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsAppearanceSub => 'Сохраняется в этом браузере и применяется сразу';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeHelp => '«Системная» следует дневному или ночному режиму устройства';

  @override
  String get settingsSystem => 'Системная';

  @override
  String get settingsDay => 'Дневная';

  @override
  String get settingsNight => 'Ночная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsIntegrations => 'Интеграции';

  @override
  String get settingsIntegrationsSub => 'Откуда приходят тикеты и куда отправляется код';

  @override
  String get settingsManageAll => 'Управлять';

  @override
  String get settingsManage => 'Управлять';

  @override
  String get settingsConnect => 'Подключить';

  @override
  String get settingsConnected => 'Подключено';

  @override
  String get settingsNotConnected => 'Не подключено';

  @override
  String get settingsClaude => 'Claude Code';

  @override
  String get settingsClaudeSub => 'Движок, который пишет код';

  @override
  String get settingsModels => 'Модели по этапам';

  @override
  String get settingsModelsHelp => 'Выберите модель для каждого шага. Haiku расходует меньше всего лимита тарифа, Opus — больше всего.';

  @override
  String get settingsStageAnalyze => 'Чтение тикета и вопросы';

  @override
  String get settingsStageAnalyzeHelp => 'Только чтение. Один раз на тикет.';

  @override
  String get settingsStageCoding => 'Разработка';

  @override
  String get settingsStageCodingHelp => 'Основной запуск. Расходует большую часть лимита.';

  @override
  String get settingsStageRetry => 'Повторы и запрошенные изменения';

  @override
  String get settingsStageRetryHelp => 'После упавших тестов, вашего отзыва или остановленного запуска.';

  @override
  String get settingsStageHelper => 'Обновление лимитов и короткие тексты';

  @override
  String get settingsStageHelperHelp => 'Небольшие задачи, например обновление лимитов в простое.';

  @override
  String get settingsStageLearn => 'Уроки по готовой работе';

  @override
  String get settingsStageLearnHelp => 'Читает каждое отправленное изменение и пишет уроки о том, что ново для репозитория.';

  @override
  String get settingsStageReview => 'Код-ревью';

  @override
  String get settingsStageReviewHelp =>
      'Проверяет каждый результат, пока его проверяете вы. «Авто» берёт Opus для сложных тикетов и Sonnet для остальных.';

  @override
  String get settingsModelAuto => 'Авто';

  @override
  String get settingsMaxTurns => 'Лимит шагов на запуск';

  @override
  String get settingsMaxTurnsHelp => 'Запуск останавливается и сообщает, когда достигает лимита';

  @override
  String get settingsTimeout => 'Тайм-аут запуска';

  @override
  String settingsMinutes(String n) {
    return '$n мин';
  }

  @override
  String get settingsAllow => 'Разрешённые команды';

  @override
  String get settingsAllowHelp => 'Claude Code может выполнять их без запроса';

  @override
  String get settingsDeny => 'Запрещённые команды';

  @override
  String get settingsDenyHelp => 'Всегда запрещены, даже если тикет их требует. Отправку кода выполняет agnts, а не Claude Code.';

  @override
  String get settingsCommits => 'Коммиты и PR';

  @override
  String get settingsCommitsSub => 'От чьего имени коммиты и как открываются пул-реквесты';

  @override
  String get settingsAuthorName => 'Имя автора';

  @override
  String get settingsAuthorNameHelp => 'Коммиты делаются от вашего имени';

  @override
  String get settingsAuthorEmail => 'Email автора';

  @override
  String get settingsAuthorEmailHelp => 'Должен совпадать с вашим аккаунтом GitHub, чтобы коммиты отображались как ваши';

  @override
  String get settingsCoAuthor => 'Добавлять строку Co-authored-by: agnts';

  @override
  String get settingsCoAuthorHelp => 'Коллеги видят, какие коммиты написал agnts';

  @override
  String get settingsPrTitle => 'Заголовок пул-реквеста';

  @override
  String settingsPrTitleHelp(String key, String title) {
    return '\'$key\' и \'$title\' заменяются ключом и названием тикета';
  }

  @override
  String get settingsDraft => 'Открывать как черновик';

  @override
  String get settingsRuns => 'Запуски';

  @override
  String get settingsRunsSub => 'Значения по умолчанию для всех тикетов и задач';

  @override
  String get settingsAskFirst => 'Задавать вопросы перед разработкой';

  @override
  String get settingsAskFirstHelp => 'По умолчанию для новых тикетов Jira. Для задач выбирается при создании.';

  @override
  String get settingsAutoResume => 'Продолжать приостановленные запуски после сброса лимита';

  @override
  String get settingsAutoLearn => 'Учиться на каждом отправленном изменении';

  @override
  String get settingsAutoLearnHelp =>
      'После отправки agnts ищет приёмы, которых в репозитории раньше не было, и пишет уроки в разделе «Обучение». Тратит лимит, только когда нет ожидающих тикетов.';

  @override
  String get settingsAutoReview => 'Проверять каждый результат';

  @override
  String get settingsAutoReviewHelp =>
      'Пока изменение или отчёт ждут вас, agnts проверяет их и показывает замечания рядом. Одобрение это никогда не блокирует.';

  @override
  String get settingsPauseAbove => 'Не начинать новые запуски выше';

  @override
  String get settingsPauseAboveHelp => 'Использование сессии. Уже идущие запуски продолжаются.';

  @override
  String get settingsParallel => 'Запусков одновременно';

  @override
  String get settingsParallelHelp => 'Больше запусков — быстрее результат, но лимит тарифа тратится быстрее';

  @override
  String get settingsNotify => 'Уведомления';

  @override
  String get settingsNotifySub => 'Push на телефон и сообщения в Telegram';

  @override
  String get settingsPush => 'Push-уведомления';

  @override
  String get settingsPushHelp => 'В приложение agnts на телефоне';

  @override
  String get settingsTelegram => 'Сообщения в Telegram';

  @override
  String get settingsTelegramHelp => 'Отправляются только после подключения Telegram на странице интеграций';

  @override
  String get settingsNeedsYou => 'Когда что-то ждёт вас';

  @override
  String get settingsNeedsYouHelp => 'Вопросы, на которые нужно ответить, или изменения на ревью';

  @override
  String get settingsStopped => 'Когда запуск останавливается или ставится на паузу';

  @override
  String get settingsDone => 'Когда изменения отправлены';

  @override
  String get settingsLessons => 'Когда agnts находит что-то новое для изучения';

  @override
  String get settingsReviewDone => 'Когда код-ревью agnts завершено';

  @override
  String get settingsSecretsHelp =>
      'Токены Jira, GitHub и Claude хранятся на вашем сервере в зашифрованном виде. Эта страница их никогда не показывает.';

  @override
  String get settingsSaved => 'Настройки сохранены';

  @override
  String settingsParallelSlots(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n запуска',
      many: '$n запусков',
      few: '$n запуска',
      one: '$n запуск',
    );
    return '$_temp0 одновременно';
  }

  @override
  String get settingsParallelSlotsHelp => 'Слоты пространства. Меняются в разделе «Пространство → Оплата».';

  @override
  String get settingsClaudeMoved => 'Claude теперь подключается для каждого пространства отдельно.';

  @override
  String get settingsClaudeOpen => 'Пространство → Claude';

  @override
  String get settingsSelfReview => 'Сначала исправлять замечания ревью';

  @override
  String get settingsSelfReviewHelp =>
      'Если собственное ревью agnts находит блокирующую или серьёзную проблему, agnts один раз возвращает её кодеру до вашего ревью. Нужно включённое ревью кода выше.';

  @override
  String get settingsAutoBrief => 'Изучать репозитории';

  @override
  String get settingsAutoBriefHelp =>
      'Составлять описание репозитория (архитектура, рецепты, соглашения) при анализе первого тикета и обновлять его после каждых 10 слияний. Агент получает описание только после вашего одобрения.';

  @override
  String get settingsReflect => 'Учиться на ваших замечаниях';

  @override
  String get settingsReflectHelp =>
      'Когда вы просите изменения или отклоняете работу с причиной, agnts ищет за этим общее правило и предлагает его на странице «Правила». Ничего не применяется, пока вы его не примете.';

  @override
  String get settingsCiRed => 'Когда отслеживаемая ветка краснеет';

  @override
  String get spendTitle => 'Расход токенов';

  @override
  String spendSub(String tokens, String cost) {
    return '$tokens токенов на вход и выход · около $cost по ценам API';
  }

  @override
  String get spendEmpty => 'Пока ничего не записано. Расход появится после первого запуска Claude по этому тикету.';

  @override
  String get spendInput => 'Вход';

  @override
  String get spendOutput => 'Выход';

  @override
  String spendCache(String read, String write) {
    return 'Кэш: прочитано $read, записано $write';
  }

  @override
  String spendCalls(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n запуска',
      many: '$n запусков',
      few: '$n запуска',
      one: '$n запуск',
    );
    return '$_temp0';
  }

  @override
  String get spendPartial => 'Запуск был прерван, его стоимость неизвестна';

  @override
  String get spendCostNote =>
      'Стоимость — оценка Claude Code для той же работы по ценам API. На подписке Claude её не списывают; она показывает относительный вес каждого этапа.';

  @override
  String spendTokens(String n) {
    return '$n токенов';
  }

  @override
  String get spendColTokens => 'Токены';

  @override
  String get spendStageAnalyze => 'Анализ';

  @override
  String get spendStageCoding => 'Код';

  @override
  String get spendStageWriting => 'Написание';

  @override
  String get spendStageRetry => 'Исправления и правки';

  @override
  String get spendStageReview => 'Код-ревью';

  @override
  String get spendStagePreview => 'Превью';

  @override
  String get spendStageLearn => 'Уроки';

  @override
  String get spendStageHelper => 'Помощник';

  @override
  String get spendTopTitle => 'Тикеты по расходу';

  @override
  String spendTopSub(String tokens, String cost) {
    return '$tokens токенов на вход и выход · около $cost по ценам API';
  }

  @override
  String get spendTopSubEmpty => 'Какие тикеты расходуют подписку больше всего';

  @override
  String get spendTopEmpty => 'За этот период запусков Claude не записано.';

  @override
  String get spendTopNote =>
      'Порядок — по оценке стоимости от Claude Code, которая правильно учитывает кэш. Доля — от оценки стоимости за период. Учитывается только расход внутри периода.';

  @override
  String get spendColStage => 'Самый дорогой этап';

  @override
  String get spendColCost => 'Оценка';

  @override
  String get spendColShare => 'Доля';

  @override
  String get stateNew => 'В очереди';

  @override
  String get stateAnalyzing => 'Читает код';

  @override
  String get stateWaiting_for_answers => 'Нужны ваши ответы';

  @override
  String get stateCoding => 'Разработка';

  @override
  String get stateTesting => 'Идут тесты';

  @override
  String get stateWaiting_for_review => 'Готово к ревью';

  @override
  String get statePushing => 'Отправка';

  @override
  String get stateDone => 'Отправлено';

  @override
  String get stateRejected => 'Отклонено';

  @override
  String get stateFailed => 'Остановлено';

  @override
  String get stateRate_limited => 'Пауза: лимит тарифа';

  @override
  String get stateReportCoding => 'Пишет отчёт';

  @override
  String get stateReportPushing => 'Сдаёт';

  @override
  String get stateReportDone => 'Готово';

  @override
  String get stateReviewAnalyzing => 'Загрузка';

  @override
  String get stateReviewCoding => 'Проверка';

  @override
  String get stateReviewWaiting_for_review => 'Ревью готово';

  @override
  String get stateReviewPushing => 'Слияние';

  @override
  String get stateReviewDone => 'Слит';

  @override
  String get stateReviewRejected => 'Отклонено';

  @override
  String get swaggerFormSub =>
      'Проверить HTTP API по его спецификации Swagger/OpenAPI: agnts составит проверки, отправит настоящие запросы и вынесет вердикт по каждой с доказательствами.';

  @override
  String get swaggerSpec => 'Спецификация';

  @override
  String get swaggerSpecUrl => 'Адрес спецификации или страницы документации';

  @override
  String get swaggerSpecUrlPh => 'https://staging.example.com/swagger/index.html';

  @override
  String get swaggerSpecRead => 'Прочитать';

  @override
  String get swaggerSpecReading => 'Читаем спецификацию…';

  @override
  String get swaggerSpecUpload => 'Загрузить файл';

  @override
  String get swaggerSpecHint =>
      'Подойдёт и страница Swagger UI, Springdoc или Redoc: agnts найдёт за ней спецификацию. Swagger 2.0 и OpenAPI 3.x, до 5 МБ.';

  @override
  String swaggerSpecFound(String title, String version, num count, String format) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count эндпоинта',
      many: '$count эндпоинтов',
      few: '$count эндпоинта',
      one: '$count эндпоинт',
    );
    return '$title $version · $_temp0 · $format';
  }

  @override
  String get swaggerSpecChoose => 'На этой странице несколько спецификаций. Выберите одну:';

  @override
  String get swaggerBaseUrl => 'Базовый URL';

  @override
  String get swaggerBaseUrlHint =>
      'Куда идут запросы. Сначала это сервер из спецификации, а он часто боевой: проверьте. Имя хоста или IP, любой порт. Внутренним хостам нужен маршрут частной сети.';

  @override
  String get swaggerEndpoints => 'Эндпоинты';

  @override
  String swaggerEndpointsCount(String n, String total) {
    return 'Отмечено $n из $total';
  }

  @override
  String get swaggerSearch => 'Поиск эндпоинтов';

  @override
  String get swaggerAll => 'Все';

  @override
  String get swaggerNone => 'Ни одного';

  @override
  String swaggerUntickedSideEffect(String word) {
    return 'Не отмечен: по названию он что-то меняет ($word)';
  }

  @override
  String get swaggerUntickedDeprecated => 'Не отмечен: устарел';

  @override
  String get swaggerAuth => 'Аутентификация';

  @override
  String get swaggerAuthKind_none => 'Нет';

  @override
  String get swaggerAuthKind_bearer => 'Bearer-токен';

  @override
  String get swaggerAuthKind_header => 'API-ключ в заголовке';

  @override
  String get swaggerAuthKind_query => 'API-ключ в запросе';

  @override
  String get swaggerAuthKind_basic => 'Basic';

  @override
  String get swaggerAuthName => 'Имя заголовка или параметра';

  @override
  String get swaggerAuthValue => 'Токен';

  @override
  String get swaggerAuthValueBasic => 'пользователь:пароль или Basic-токен';

  @override
  String get swaggerAuthHint =>
      'Берите токен тестового аккаунта, никогда не личный и не боевой. Он запечатывается, больше не показывается и удаляется, когда тикет закрыт.';

  @override
  String swaggerAuthFromSpec(String schemes) {
    return 'В спецификации: $schemes';
  }

  @override
  String get swaggerWrite => 'Запросы';

  @override
  String get swaggerWriteOff => 'Только чтение';

  @override
  String get swaggerWriteOffHint => 'Только GET, HEAD и OPTIONS';

  @override
  String get swaggerWriteOn => 'И запросы на запись';

  @override
  String get swaggerWriteOnHint => 'Также POST, PUT, PATCH и DELETE';

  @override
  String swaggerWriteConfirm(String url) {
    return 'Подтверждаю: $url — не боевой сервер';
  }

  @override
  String get swaggerWriteConfirmNeeded => 'Подтвердите, что базовый URL не боевой, чтобы отправлять запросы на запись.';

  @override
  String get swaggerReadOnlyNote =>
      '«Только чтение» значит только GET, HEAD и OPTIONS, а не «безвредно»: некоторые API меняют данные и на GET. Решать вам.';

  @override
  String get swaggerLockoutNote =>
      'Проверки без токена и с неверным токеном могут выглядеть для файрвола как атака на вход. Тест отправит не больше 3 таких запросов, но всё же может заблокировать тестовый аккаунт или адрес отправителя. За частной сетью этот адрес — VPN-подключение рабочего пространства, которым пользуются GitLab и другие тесты.';

  @override
  String get swaggerRepository => 'Репозиторий (необязательно)';

  @override
  String get swaggerRepositoryHint => 'С ним agnts читает обработчики, чтобы объяснить сбои, а сбои можно превратить в тикет Bug или Code.';

  @override
  String get swaggerNoRepo => 'Без репозитория';

  @override
  String get swaggerNotes => 'Заметки';

  @override
  String get swaggerNotesPh => 'Например: пользователь 42 — тестовый; заказам нужен существующий id товара';

  @override
  String get swaggerLimits => 'Ограничения';

  @override
  String get swaggerRate => 'Запросов в секунду';

  @override
  String get swaggerMaxRequests => 'Запросов за запуск';

  @override
  String get swaggerStart => 'Запуск';

  @override
  String get swaggerStartNow => 'Сейчас';

  @override
  String get swaggerStartQueue => 'Оставить в очереди';

  @override
  String get swaggerCreate => 'Создать тест';

  @override
  String get swaggerCreateStart => 'Создать и запустить';

  @override
  String swaggerCreated(String key) {
    return '$key создан';
  }

  @override
  String get swaggerNeedSpec => 'Сначала прочитайте спецификацию.';

  @override
  String get swaggerNeedToken => 'Введите токен.';

  @override
  String get swaggerClaudeOnly =>
      'Тесты Swagger всегда выполняются на Claude (Sonnet), какой бы моделью ни программировало рабочее пространство.';

  @override
  String get swaggerTab => 'Результаты API';

  @override
  String get swaggerRequestsTab => 'Запросы';

  @override
  String get swaggerNoRun => 'Результатов пока нет: тест выполняется или ещё не запускался.';

  @override
  String get swaggerVerdict_pass => 'Пройдено';

  @override
  String get swaggerVerdict_fail => 'Сбой';

  @override
  String get swaggerVerdict_skipped => 'Пропущено';

  @override
  String get swaggerVerdict_blocked => 'Не выполнено';

  @override
  String swaggerCount_pass(String n) {
    return 'пройдено: $n';
  }

  @override
  String swaggerCount_fail(String n) {
    return 'сбоев: $n';
  }

  @override
  String swaggerCount_skipped(String n) {
    return 'пропущено: $n';
  }

  @override
  String swaggerCount_blocked(String n) {
    return 'не выполнено: $n';
  }

  @override
  String get swaggerColEndpoint => 'Эндпоинт';

  @override
  String get swaggerColCases => 'Проверки';

  @override
  String get swaggerColResult => 'Результат';

  @override
  String get swaggerAgntsCheck => 'проверка agnts';

  @override
  String get swaggerAgntsCheckHint => 'agnts сам сверил этот ответ со схемой спецификации';

  @override
  String swaggerExpected(String text) {
    return 'Ожидалось: $text';
  }

  @override
  String get swaggerRequestLabel => 'Запрос';

  @override
  String get swaggerResponseLabel => 'Ответ';

  @override
  String get swaggerNoResponse => 'Ответа нет';

  @override
  String get swaggerTruncated => 'Тело обрезано до 64 КБ';

  @override
  String get swaggerCopyCurl => 'Скопировать как curl';

  @override
  String get swaggerCopied => 'Скопировано';

  @override
  String get swaggerLoading => 'Загрузка…';

  @override
  String get swaggerCreateBug => 'Создать тикет Bug';

  @override
  String swaggerBugTitle(String key) {
    return 'Исправить сбои API, найденные $key';
  }

  @override
  String swaggerBugIntro(String key, String base) {
    return 'Тест Swagger $key сервера $base нашёл такие сбои:';
  }

  @override
  String swaggerBugCreated(String key) {
    return '$key создан';
  }

  @override
  String swaggerNewFailures(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n нового сбоя',
      many: '$n новых сбоев',
      few: '$n новых сбоя',
      one: '$n новый сбой',
    );
    return '$_temp0 с прошлого запуска';
  }

  @override
  String get swaggerNoNewFailures => 'С прошлого запуска новых сбоев нет';

  @override
  String swaggerPrevious(String passed, String failed) {
    return 'Прошлый запуск: пройдено $passed, сбоев $failed';
  }

  @override
  String get swaggerRerun => 'Запустить снова';

  @override
  String get swaggerRerunToken => 'Новый токен (необязательно)';

  @override
  String get swaggerRerunTokenNeeded => 'Новый токен (обязательно: старый удалён при закрытии тикета)';

  @override
  String get swaggerRerunStarted => 'Запущен снова';

  @override
  String swaggerRerunNew(String key) {
    return 'Запущен снова как $key';
  }

  @override
  String get swaggerModeRead => 'только чтение';

  @override
  String get swaggerModeWrite => 'с запросами на запись';

  @override
  String get swaggerTokenStored => 'токен сохранён';

  @override
  String get swaggerTokenGone => 'токена нет';

  @override
  String get swaggerAgntsNotes => 'Что поправил agnts';

  @override
  String get swaggerAllPassed => 'Все проверки пройдены.';

  @override
  String get swaggerRunningTitle => 'Проверяем API';

  @override
  String get swaggerRunningSub =>
      'agnts составляет проверки и отправляет настоящие запросы на базовый URL. Результаты появятся здесь, когда запуск закончится.';

  @override
  String get swaggerQueuedTitle => 'Тест Swagger в очереди';

  @override
  String get swaggerQueuedSub => 'Запустите, когда будете готовы.';

  @override
  String get swaggerSuites => 'Наборы Swagger';

  @override
  String get swaggerSuitesLede =>
      'Сохранённые тесты Swagger, которые запускаются снова по расписанию или после каждого деплоя. Каждый запуск — новый тикет: он сравнивается с прошлым запуском набора и берёт его план, поэтому повторные запуски тратят меньше шагов.';

  @override
  String get swaggerSuitesEmpty => 'Наборов пока нет. Откройте завершённый тест Swagger и сохраните его как набор.';

  @override
  String get swaggerSaveSuite => 'Сохранить как набор';

  @override
  String get swaggerSaveSuiteHint => 'Запускать этот тест снова по расписанию или после каждого деплоя. У набора своя копия токена.';

  @override
  String get swaggerSuiteName => 'Название';

  @override
  String get swaggerSchedule => 'Расписание';

  @override
  String get swaggerSchedule_off => 'Вручную или по хуку деплоя';

  @override
  String get swaggerSchedule_hourly => 'Каждый час';

  @override
  String get swaggerSchedule_daily => 'Каждый день';

  @override
  String get swaggerSchedule_weekly => 'По понедельникам';

  @override
  String get swaggerHourUtc => 'В (час, UTC)';

  @override
  String swaggerSuiteSaved(String name) {
    return 'Сохранено как набор $name';
  }

  @override
  String get swaggerRunNow => 'Запустить';

  @override
  String swaggerRunStarted(String key) {
    return '$key запущен';
  }

  @override
  String get swaggerBusy => 'Прошлый запуск ещё идёт';

  @override
  String get swaggerPause => 'Приостановить';

  @override
  String get swaggerResume => 'Возобновить';

  @override
  String get swaggerPaused => 'Приостановлен';

  @override
  String get swaggerDeleteSuite => 'Удалить';

  @override
  String swaggerDeleteConfirm(String name) {
    return 'Удалить набор $name? Прошлые запуски останутся.';
  }

  @override
  String get swaggerHookCreate => 'Создать хук деплоя';

  @override
  String get swaggerHookRotate => 'Новый хук деплоя';

  @override
  String get swaggerHookHint =>
      'Отправьте POST на этот URL из пайплайна деплоя, без тела, чтобы запускать набор после каждого деплоя. Он показывается один раз; новый отключает старый.';

  @override
  String swaggerHookExample(String url) {
    return 'curl -X POST $url';
  }

  @override
  String get swaggerLastRun => 'Последний запуск';

  @override
  String get swaggerNextRun => 'Следующий запуск';

  @override
  String get swaggerNever => 'никогда';

  @override
  String get swaggerColSuite => 'Набор';

  @override
  String get swaggerColSchedule => 'Расписание';

  @override
  String get swaggerColLast => 'Последний запуск';

  @override
  String get swaggerSuiteToken => 'Новый токен (необязательно)';

  @override
  String get swaggerSetToken => 'Задать токен';

  @override
  String get swaggerSpecAuth => 'Для ссылки на спецификацию нужен вход';

  @override
  String get swaggerSpecAuthHint => 'Отправляется вместе с загрузкой спецификации только на её хост и нигде не сохраняется.';

  @override
  String get swaggerSpecAuthNeeded => 'Адрес спецификации ответил 401/403: укажите нужный токен и прочитайте снова.';

  @override
  String get swaggerSpecAuthReused => 'Запросы к API тоже пойдут с этим токеном. Если нужен другой, поменяйте его здесь.';

  @override
  String get swaggerSpecAuthLogin => 'Логин и пароль';

  @override
  String get swaggerSpecAuthToken => 'Токен';

  @override
  String get swaggerSpecLogin => 'Логин';

  @override
  String get swaggerSpecPassword => 'Пароль';

  @override
  String get swaggerSpecLoginNeeded => 'Ссылка на спецификацию просит логин и пароль: введите их и прочитайте снова.';

  @override
  String get swaggerSpecLoginHint =>
      'Нужны только чтобы открыть ссылку на спецификацию и нигде не сохраняются. Запросы агента к API идут с токеном из раздела «Аутентификация» ниже.';

  @override
  String get swaggerFilterProblems => 'Сбои и не выполненные';

  @override
  String get swaggerFilterAll => 'Все проверки';

  @override
  String get swaggerNothingToShow => 'Сбоев и не выполненных проверок нет. Откройте все проверки, чтобы увидеть остальные.';

  @override
  String swaggerCasesHidden(num n) {
    return 'Скрыто эндпоинтов без сбоев: $n';
  }

  @override
  String get swaggerWhatToTest => 'Что тестировать';

  @override
  String get swaggerWhatToTestPh =>
      'Например: только POST-эндпоинты в /v1/orders и /v1/payments; проверить ошибки валидации и несуществующие id. Пользователь 42 — тестовый.';

  @override
  String get swaggerWhatToTestHint => 'agnts тестирует только то, что вы здесь напишете. Чтобы задать точные эндпоинты, отметьте их ниже.';

  @override
  String get swaggerWhatToTestNeeded => 'Напишите, что тестировать, или отметьте эндпоинты.';

  @override
  String get swaggerEndpointsOptional => 'Выбрать эндпоинты (необязательно)';

  @override
  String get swaggerEndpointsOptionalHint =>
      'Отмеченные эндпоинты тестируются ровно как отмечены. Если ничего не отмечено, что тестировать решает текст выше.';

  @override
  String get swaggerSuggested => 'Рекомендуемые';

  @override
  String get swaggerNoneTicked => 'ничего не отмечено: решает текст выше';

  @override
  String get tasksTitle => 'Задачи';

  @override
  String get tasksLede =>
      'Работа для ваших проектов. Задачи остаются в agnts и не попадают в Jira. Всё остальное так же: вопросы, разработка, ваше ревью.';

  @override
  String get tasksNew => 'Новая задача';

  @override
  String tasksAllRepos(String count) {
    return 'Все репозитории $count';
  }

  @override
  String get tasksFilterLabel => 'Фильтр по репозиторию';

  @override
  String get tasksColTask => 'Задача';

  @override
  String get tasksColRepo => 'Репозиторий';

  @override
  String get tasksColStatus => 'Статус';

  @override
  String get tasksColUpdated => 'Обновлено';

  @override
  String get tasksNoMatch => 'Нет задач по вашему запросу.';

  @override
  String get tasksEmpty => 'В этом репозитории пока нет задач.';

  @override
  String get tasksRepos => 'Репозитории';

  @override
  String get tasksReposSub => 'Репозитории ваших проектов на этом сервере';

  @override
  String tasksRepoLine(String test, String open) {
    return 'тесты: $test, открыто: $open';
  }

  @override
  String get tasksNoTest => 'нет';

  @override
  String get tasksNoRepos => 'Пока нет репозиториев для своих проектов.';

  @override
  String get tasksHelp =>
      'Для репозиториев, в которых работаете только вы, можно разрешить agnts отправлять сразу в main после одобрения. Без вашего ревью он всё равно ничего не отправляет.';

  @override
  String get tasksDrawerSub => 'Для ваших проектов. Не синхронизируется с Jira.';

  @override
  String get tasksRepository => 'Репозиторий';

  @override
  String get tasksFieldTitle => 'Название';

  @override
  String get tasksTitlePh => 'Например: добавить таймер отдыха между подходами';

  @override
  String get tasksTicketNumber => 'Номер задачи';

  @override
  String get tasksTicketNumberPh => 'Например: AMANAT-2288';

  @override
  String get tasksTicketNumberHelp =>
      'Необязательно. Номер этой работы у вашей команды; используется в именах веток и коммитов вместо ключа задачи.';

  @override
  String get tasksFieldDesc => 'Что нужно сделать';

  @override
  String get tasksDescPh => 'Опишите нужный результат. Чем яснее, тем меньше вопросов задаст agnts.';

  @override
  String get tasksPriority => 'Приоритет';

  @override
  String get tasksLow => 'Низкий';

  @override
  String get tasksMedium => 'Средний';

  @override
  String get tasksHigh => 'Высокий';

  @override
  String get tasksAfter => 'После вашего одобрения';

  @override
  String get tasksAfterMain => 'Отправить в main';

  @override
  String get tasksAfterPr => 'Открыть пул-реквест';

  @override
  String get tasksStart => 'Как начать';

  @override
  String get tasksStartAsk => 'Сначала задать вопросы';

  @override
  String get tasksStartAskHint => 'agnts читает код и задаёт вопросы перед разработкой. Лучше всего для неясных задач.';

  @override
  String get tasksStartCode => 'Сразу начать разработку';

  @override
  String get tasksStartCodeHint => 'Без вопросов. Подходит для небольших, хорошо описанных задач.';

  @override
  String get tasksStartQueue => 'Оставить в очереди';

  @override
  String get tasksStartQueueHint => 'Сохранить и начать позже.';

  @override
  String get tasksCreate => 'Создать задачу';

  @override
  String get tasksCreateStart => 'Создать и начать';

  @override
  String get tasksAddRepoFirst => 'Сначала добавьте репозиторий проекта.';

  @override
  String get tasksTitleRequired => 'Введите название.';

  @override
  String tasksCreated(String key) {
    return 'Задача $key создана';
  }

  @override
  String tasksCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n задачи', many: '$n задач', few: '$n задачи', one: '$n задача');
    return '$_temp0';
  }

  @override
  String get tasksNoRepo => 'Без репозитория';

  @override
  String get tasksRepoNeeded => 'Для кода и тестов нужен репозиторий: выберите его или другой тип.';

  @override
  String ticketUpdateTitle(String source) {
    return 'Изменено в $source после начала работы agnts';
  }

  @override
  String get ticketUpdateSub =>
      'agnts продолжает работать с версией, с которой начал. Перезапустите, чтобы отбросить сделанное и начать заново с новой версии, или продолжайте с текущей.';

  @override
  String ticketUpdateNow(String when) {
    return 'Новая версия, $when';
  }

  @override
  String get ticketUpdateRestart => 'Перезапустить с новой версией';

  @override
  String get ticketUpdateKeep => 'Оставить текущую версию';

  @override
  String ticketUpdateRestartConfirm(String key, String source) {
    return 'Перезапустить $key с новой версией из $source? Анализ, ответы, коммиты и ревью будут отброшены, и agnts начнёт заново.';
  }

  @override
  String get ticketUpdatePushed =>
      'Уже отправлено: перезапуск невозможен. Отклоните тикет, чтобы agnts взял задачу заново, или оставьте текущую версию.';

  @override
  String ticketUpdateRestarted(String key) {
    return '$key перезапускается с новой версией';
  }

  @override
  String get ticketUpdateKept => 'agnts продолжает работать с текущей версией';

  @override
  String get ticketBack => 'Все тикеты';

  @override
  String get ticketPlan => 'План';

  @override
  String get ticketAnalysis => 'Что нашёл agnts';

  @override
  String get ticketQuestions => 'Вопросы';

  @override
  String get ticketYourAnswer => 'Ваш ответ';

  @override
  String get ticketNote => 'Комментарий (необязательно)';

  @override
  String get ticketSendAnswers => 'Отправить ответы и начать разработку';

  @override
  String get ticketChanges => 'Изменения';

  @override
  String ticketFilesChanged(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла изменено',
      many: '$count файлов изменено',
      few: '$count файла изменено',
      one: '$count файл изменён',
    );
    return '$_temp0';
  }

  @override
  String get ticketChecks => 'Проверки';

  @override
  String get ticketPassed => 'пройдено';

  @override
  String get ticketFailedCheck => 'не пройдено';

  @override
  String get ticketNotes => 'Заметки для ревьюера';

  @override
  String get ticketApprove => 'Одобрить и отправить';

  @override
  String ticketApproveConfirm(String branch) {
    return 'Отправить $branch и открыть пул-реквест?';
  }

  @override
  String get ticketRequestChanges => 'Запросить изменения';

  @override
  String get ticketFeedbackPlaceholder => 'Что нужно изменить?';

  @override
  String get ticketSend => 'Отправить';

  @override
  String get ticketCancel => 'Отмена';

  @override
  String get ticketReject => 'Отклонить';

  @override
  String ticketRejectConfirm(String key) {
    return 'Остановить всю работу над $key? Это нельзя отменить.';
  }

  @override
  String get ticketRetry => 'Повторить';

  @override
  String ticketPullRequest(String number) {
    return 'Пул-реквест #$number';
  }

  @override
  String get ticketBranch => 'Ветка';

  @override
  String ticketRevision(String n) {
    return 'Ревизия $n';
  }

  @override
  String get ticketLog => 'Лог в реальном времени';

  @override
  String get ticketLogEmpty => 'Пока пусто.';

  @override
  String ticketNotFound(String key) {
    return 'Тикет $key не найден.';
  }

  @override
  String get ticketConflict => 'Тикет уже изменился; обновлено.';

  @override
  String get ticketStopAnalyze => 'Анализ';

  @override
  String get ticketStopAnswers => 'Ваши ответы';

  @override
  String get ticketStopCoding => 'Разработка';

  @override
  String get ticketStopTests => 'Тесты';

  @override
  String get ticketStopReview => 'Ваше ревью';

  @override
  String get ticketStopPushed => 'Отправлено';

  @override
  String get ticketProgress => 'Прогресс';

  @override
  String ticketBackTo(String page) {
    return 'Назад: $page';
  }

  @override
  String get ticketQueuedTitle => 'Ожидает в очереди';

  @override
  String get ticketQueuedSub =>
      'agnts читает тикет и связанный код, затем возвращается с планом и вопросами. На этом шаге ничего не меняется.';

  @override
  String get ticketHeldSub => 'Задача ждёт в очереди, пока вы её не запустите.';

  @override
  String get ticketStart => 'Запустить';

  @override
  String get ticketStartHint => 'Начнётся, когда освободится слот';

  @override
  String get ticketAnalyzingTitle => 'Читает код';

  @override
  String ticketAnalyzingSub(String repo) {
    return 'Изучает $repo, чтобы составить план.';
  }

  @override
  String ticketQuestionsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n вопроса до начала разработки',
      many: '$n вопросов до начала разработки',
      few: '$n вопроса до начала разработки',
      one: '$n вопрос до начала разработки',
    );
    return '$_temp0';
  }

  @override
  String get ticketQuestionsSub => 'Выберите вариант или напишите свой ответ. Ответы попадут в промпт вместе с планом.';

  @override
  String get ticketAddDetails => 'Добавьте детали (необязательно)';

  @override
  String ticketDetailsFor(String n) {
    return 'Детали к вопросу $n';
  }

  @override
  String ticketAnswerFor(String n) {
    return 'Ответ на вопрос $n';
  }

  @override
  String get ticketStartCoding => 'Начать разработку';

  @override
  String ticketQuestionsLeft(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Осталось $n вопроса',
      many: 'Осталось $n вопросов',
      few: 'Осталось $n вопроса',
      one: 'Остался $n вопрос',
    );
    return '$_temp0';
  }

  @override
  String get ticketAllAnswered => 'На все вопросы есть ответы';

  @override
  String get ticketCodingTitle => 'Разработка';

  @override
  String get ticketTestingTitle => 'Идут тесты';

  @override
  String ticketRevisionSuffix(String title, String n) {
    return '$title, ревизия $n';
  }

  @override
  String ticketCodingSub(String branch) {
    return 'Работает в новом контейнере на ветке $branch. Вы проверите изменения до отправки.';
  }

  @override
  String get ticketFactModel => 'Модель';

  @override
  String get ticketFactTurns => 'Шаги';

  @override
  String get ticketFactTurnLimit => 'Лимит шагов';

  @override
  String get ticketFactSession => 'Использование сессии';

  @override
  String get ticketFactTests => 'Тесты';

  @override
  String get ticketFactChanged => 'Изменено';

  @override
  String ticketChangedValue(num n, String add, String del) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n файла', many: '$n файлов', few: '$n файла', one: '$n файл');
    return '$_temp0, +$add −$del';
  }

  @override
  String ticketChecksPassed(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n проверки пройдены',
      many: '$n проверок пройдено',
      few: '$n проверки пройдены',
      one: '$n проверка пройдена',
    );
    return '$_temp0';
  }

  @override
  String get ticketNoChecks => 'Проверки не настроены';

  @override
  String get ticketStopRun => 'Остановить запуск';

  @override
  String ticketStopConfirm(String key) {
    return 'Остановить запуск $key? Его можно будет повторить.';
  }

  @override
  String get ticketReviewTitle => 'Проверьте изменения';

  @override
  String ticketReviewSubPr(String branch) {
    return 'Ничего ещё не покинуло сервер. Одобрение отправит $branch и откроет пул-реквест.';
  }

  @override
  String ticketReviewSubJira(String branch) {
    return 'Ничего ещё не покинуло сервер. Одобрение отправит $branch, откроет пул-реквест и обновит тикет в Jira.';
  }

  @override
  String get ticketReviewSubMain => 'Ничего ещё не покинуло сервер. Одобрение отправит изменения прямо в основную ветку.';

  @override
  String get ticketWhatAgntsDid => 'Что сделал agnts';

  @override
  String get ticketDiff => 'Изменения';

  @override
  String get ticketFeedback => 'Комментарий';

  @override
  String get ticketAssignTitle => 'Назначить пул-реквест';

  @override
  String get ticketAssignSub => 'Необязательно. Выберите, на кого он будет назначен, когда agnts его откроет.';

  @override
  String ticketAssignError(String error) {
    return 'Не удалось загрузить участников репозитория: $error. Одобрить можно и без назначения.';
  }

  @override
  String get ticketAssignNone => 'Нет участников репозитория для выбора.';

  @override
  String ticketApproveAssignees(String names) {
    return 'Назначить на $names.';
  }

  @override
  String get ticketKvAssignees => 'Назначены';

  @override
  String get ticketFeedbackHint => 'Опишите, что изменить. Обязательно для запроса изменений.';

  @override
  String get ticketApproveMainConfirm => 'Отправить изменения прямо в основную ветку?';

  @override
  String get ticketPushingTitle => 'Отправка';

  @override
  String get ticketPushingSub => 'Коммит от вашего имени и открытие пул-реквеста.';

  @override
  String get ticketDoneTitle => 'Отправлено';

  @override
  String ticketDoneMain(String repo) {
    return 'Закоммичено от вашего имени и отправлено в основную ветку $repo.';
  }

  @override
  String ticketDonePr(String number, String branch) {
    return 'Пул-реквест #$number открыт для $branch.';
  }

  @override
  String ticketOpenPr(String number) {
    return 'Открыть пул-реквест #$number';
  }

  @override
  String get ticketRejectedTitle => 'Отклонено';

  @override
  String get ticketRejectedSub => 'agnts прекратил работу над этим тикетом. Ветка не отправлялась.';

  @override
  String get ticketFailedTitle => 'agnts остановился';

  @override
  String get ticketFailedUnknown => 'Запуск остановлен. Подробности в логе запуска.';

  @override
  String get ticketRetryNote => 'Заметка к повтору';

  @override
  String get ticketRetryNoteHint =>
      'Необязательно. Подскажите agnts, как обойти ошибку; следующий запуск получит заметку вместе с ошибкой.';

  @override
  String get ticketTakeItMyself => 'Сделаю сам';

  @override
  String get ticketRateTitle => 'Пауза: лимит тарифа';

  @override
  String get ticketResume => 'Продолжить запуск';

  @override
  String ticketRateHint(String pct) {
    return 'Сейчас использовано $pct% сессии.';
  }

  @override
  String get ticketModelsTitle => 'Модели для этого тикета';

  @override
  String get ticketModelsHint => 'Меняет настройки по умолчанию только для этого тикета.';

  @override
  String ticketModelDefault(String model) {
    return 'По умолчанию ($model)';
  }

  @override
  String get ticketStageAnalyze => 'Чтение тикета и вопросы';

  @override
  String get ticketStageCoding => 'Разработка';

  @override
  String get ticketStageRetry => 'Повторы и запрошенные изменения';

  @override
  String get ticketStageReview => 'Код-ревью agnts';

  @override
  String get ticketStagePreview => 'Скриншоты (превью)';

  @override
  String ticketModelAuto(String model) {
    return 'Авто ($model)';
  }

  @override
  String get ticketSideTicket => 'Тикет';

  @override
  String get ticketSideTask => 'Задача';

  @override
  String get ticketKvKey => 'Ключ';

  @override
  String get ticketKvSource => 'Источник';

  @override
  String get ticketKvRepo => 'Репозиторий';

  @override
  String get ticketKvAfter => 'После одобрения';

  @override
  String get ticketKvPriority => 'Приоритет';

  @override
  String get ticketKvBranch => 'Ветка';

  @override
  String get ticketKvRevision => 'Ревизия';

  @override
  String get ticketKvTurns => 'Использовано шагов';

  @override
  String get ticketKvCodingModel => 'Модель разработки';

  @override
  String get ticketKvRetryModel => 'Модель для повторов';

  @override
  String get ticketSrcJira => 'Jira';

  @override
  String get ticketSrcTask => 'Задача agnts';

  @override
  String get ticketAfterMain => 'Отправить в main';

  @override
  String get ticketAfterPr => 'Открыть пул-реквест';

  @override
  String get ticketHistoryTitle => 'История';

  @override
  String get ticketHistoryEmpty => 'Истории пока нет.';

  @override
  String get ticketAnswersTitle => 'Ваши ответы';

  @override
  String get ticketAnswersSub => 'Отправлены вместе с промптом';

  @override
  String get ticketRunLog => 'Лог запуска';

  @override
  String ticketRunLogSub(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n события',
      many: '$n событий',
      few: '$n события',
      one: '$n событие',
    );
    return '$_temp0, по шагам';
  }

  @override
  String ticketGroupEvents(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n события',
      many: '$n событий',
      few: '$n события',
      one: '$n событие',
    );
    return '$_temp0';
  }

  @override
  String ticketGroupErrors(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ошибки', many: '$n ошибок', few: '$n ошибки', one: '$n ошибка');
    return '$_temp0';
  }

  @override
  String get ticketOpenInLogs => 'Открыть в логах';

  @override
  String get ticketStepOther => 'Общее';

  @override
  String get ticketDelete => 'Удалить';

  @override
  String ticketDeleteConfirm(String key) {
    return 'Удалить задачу $key?';
  }

  @override
  String get ticketUsageTitle => 'Лимиты тарифа';

  @override
  String get ticketUsageSession => 'Текущая сессия';

  @override
  String get ticketUsageWeek => 'Эта неделя';

  @override
  String get ticketMerged => 'Смёржено';

  @override
  String ticketMergedAt(String time) {
    return 'Смёржено $time.';
  }

  @override
  String get ticketRepoTitle => 'Репозиторий';

  @override
  String get ticketRepoHint => 'Где agnts анализирует тикет и пишет код.';

  @override
  String get ticketRepoNone => 'Выберите репозиторий…';

  @override
  String get ticketRepoMissing => 'К тикету не привязан репозиторий. Выберите его и повторите.';

  @override
  String get ticketRepoRestartTitle => 'Сменить репозиторий?';

  @override
  String ticketRepoRestart(String repo, String next) {
    return 'Работа по тикету уже шла в $repo. В $next он начнётся заново с анализа после повтора.';
  }

  @override
  String get ticketRepoChange => 'Сменить';

  @override
  String ticketRepoChanged(String repo) {
    return 'Репозиторий: $repo';
  }

  @override
  String get ticketQueuedSubReport =>
      'agnts прочитает тикет (и код, если есть репозиторий) и вернётся с планом и вопросами. Ничего не меняется.';

  @override
  String get ticketAnalyzingTitleNoRepo => 'Читает тикет';

  @override
  String get ticketAnalyzingSubNoRepo => 'Репозитория нет: agnts работает по тексту тикета.';

  @override
  String get ticketStartWriting => 'Начать отчёт';

  @override
  String get ticketWritingTitle => 'Пишет отчёт';

  @override
  String get ticketWritingSub => 'Работает в новом контейнере. Код не меняется; сначала вы проверите отчёт.';

  @override
  String get ticketReviewReportTitle => 'Проверьте отчёт';

  @override
  String get ticketReviewReportSub => 'После одобрения отчёт остаётся здесь, а задача закрывается.';

  @override
  String get ticketReviewReportSubJira =>
      'После одобрения отчёт остаётся здесь, а тикет закрывается. В Jira он попадёт, только если отметить пункт ниже.';

  @override
  String get ticketReport => 'Отчёт';

  @override
  String get ticketReportMissing => 'Отчёт не сохранён.';

  @override
  String ticketPostReport(String key) {
    return 'Также опубликовать отчёт комментарием в $key в Jira';
  }

  @override
  String get ticketFeedbackReportHint => 'Что изменить или добавить в отчёт?';

  @override
  String get ticketApproveReport => 'Одобрить';

  @override
  String get ticketApproveReportConfirm => 'Одобрить отчёт и закрыть тикет?';

  @override
  String ticketApproveReportPostConfirm(String key) {
    return 'Одобрить отчёт, закрыть тикет и опубликовать отчёт в $key в Jira?';
  }

  @override
  String get ticketDeliveringTitle => 'Завершает';

  @override
  String get ticketDeliveringSub => 'Сохраняет одобренный отчёт и публикует его в трекер задач, если вы просили.';

  @override
  String get ticketDoneReportTitle => 'Отчёт одобрен';

  @override
  String get ticketDoneReport => 'Отчёт хранится здесь.';

  @override
  String ticketDoneReportPosted(String key) {
    return 'Отчёт хранится здесь и опубликован в $key в Jira.';
  }

  @override
  String get ticketStopWriting => 'Отчёт';

  @override
  String get ticketStopDone => 'Готово';

  @override
  String get ticketTabsLabel => 'Детали тикета';

  @override
  String get ticketTabReview => 'Код-ревью';

  @override
  String get ticketTabFollowUps => 'Последующие';

  @override
  String get ticketTabAnswers => 'Ответы';

  @override
  String get ticketTabLessons => 'Уроки';

  @override
  String get ticketShowMore => 'Показать ещё';

  @override
  String get ticketShowLess => 'Свернуть';

  @override
  String get ticketTranslate => 'Перевести';

  @override
  String get ticketTranslateOriginal => 'Язык оригинала';

  @override
  String get ticketTranslating => 'Перевод… в первый раз это занимает до минуты, потом он сохраняется.';

  @override
  String ticketTranslateFailed(String error) {
    return 'Не удалось перевести: $error';
  }

  @override
  String get ticketSrcPlane => 'Plane';

  @override
  String ticketReviewSubPlane(String branch) {
    return 'С сервера пока ничего не ушло. Одобрение отправит $branch, откроет pull request и обновит задачу в Plane.';
  }

  @override
  String get ticketReviewReportSubPlane =>
      'Одобрение сохранит отчёт здесь и закроет тикет. В Plane он попадёт, только если отметить пункт ниже.';

  @override
  String ticketPostReportPlane(String key) {
    return 'Также опубликовать отчёт комментарием к $key в Plane';
  }

  @override
  String ticketApproveReportPostConfirmPlane(String key) {
    return 'Одобрить отчёт, закрыть тикет и опубликовать отчёт в $key в Plane?';
  }

  @override
  String ticketDoneReportPostedPlane(String key) {
    return 'Отчёт сохранён здесь и опубликован в $key в Plane.';
  }

  @override
  String get ticketPickAny => 'Выберите все подходящие';

  @override
  String get ticketOtherAnswer => 'Что-то другое (необязательно)';

  @override
  String get ticketSrcGit => 'Пул-реквест';

  @override
  String get ticketSrcCi => 'Падение CI';

  @override
  String get ticketKvCi => 'CI';

  @override
  String ticketCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раза', many: '$n раз', few: '$n раза', one: '$n раз');
    return 'CI $_temp0 вернул пул-реквест в работу';
  }

  @override
  String get ticketsTitle => 'Тикеты';

  @override
  String get ticketsNeedsYou => 'Ждёт вас';

  @override
  String get ticketsRunning => 'Выполняется';

  @override
  String get ticketsFinished => 'Завершённые';

  @override
  String get ticketsAll => 'Все';

  @override
  String get ticketsEmpty => 'Здесь нет тикетов.';

  @override
  String ticketsEmptyHint(String label) {
    return 'Добавьте задаче в Jira метку «$label», и agnts возьмёт её в работу.';
  }

  @override
  String ticketsUpdated(String time) {
    return 'Обновлено $time';
  }

  @override
  String get ticketsColTicket => 'Тикет';

  @override
  String get ticketsColSource => 'Источник';

  @override
  String get ticketsColRepo => 'Репозиторий';

  @override
  String get ticketsRepoLabel => 'Репозиторий';

  @override
  String get ticketsAllRepos => 'Все репозитории';

  @override
  String get ticketsNoRepo => 'Без репозитория';

  @override
  String get ticketsColStatus => 'Статус';

  @override
  String get ticketsColUpdated => 'Обновлено';

  @override
  String get ticketsSourceJira => 'Jira';

  @override
  String get ticketsSourceTask => 'Задача';

  @override
  String ticketsRev(String n) {
    return 'рев. $n';
  }

  @override
  String ticketsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n тикета', many: '$n тикетов', few: '$n тикета', one: '$n тикет');
    return '$_temp0';
  }

  @override
  String get ticketsViewLabel => 'Вид';

  @override
  String get ticketsViewTable => 'Таблица';

  @override
  String get ticketsViewBoard => 'Доска';

  @override
  String get ticketsBoardEmpty => 'Пусто';

  @override
  String get ticketsListSub => 'Тикеты Jira и Plane с меткой agnts, а также задачи, которые вы создаёте для своих проектов.';

  @override
  String get ticketsNoMatch => 'Нет тикетов, подходящих под фильтры.';

  @override
  String get ticketsEmptyNeeds => 'Сейчас ничего не ждёт вас. Тикеты появятся здесь, когда у agnts будут вопросы или изменения на ревью.';

  @override
  String get ticketsEmptyOther => 'Здесь пока нет тикетов.';

  @override
  String get ticketsStatNeeds => 'Ждёт вас';

  @override
  String get ticketsStatNeedsNote => 'Ждут ответы или ревью';

  @override
  String get ticketsStatRunning => 'Выполняется';

  @override
  String get ticketsStatRunningNote => 'Сейчас в контейнерах';

  @override
  String get ticketsStatPushed => 'Отправлено за неделю';

  @override
  String get ticketsStatPushedNote => 'Открыто пул-реквестов';

  @override
  String get ticketsStatSession => 'Сессия тарифа';

  @override
  String get ticketsSourcePlane => 'Plane';

  @override
  String get ticketsSourceGit => 'PR';

  @override
  String get ticketsSourceCi => 'CI';

  @override
  String get usageTitle => 'Лимиты тарифа';

  @override
  String get usageLede =>
      'agnts работает на вашей подписке Claude. Эти лимиты общие с вашим собственным использованием Claude и Claude Code.';

  @override
  String get usageCard => 'Лимиты тарифа';

  @override
  String usageUpdated(String time) {
    return 'Обновлено $time';
  }

  @override
  String get usageNoReading => 'Данных пока нет';

  @override
  String get usageRefresh => 'Обновить';

  @override
  String get usageRefreshing => 'Обновление…';

  @override
  String get usageRefreshStarted => 'Обновление запущено. Новые данные появятся через минуту.';

  @override
  String get usageSession => 'Текущая сессия';

  @override
  String get usageWeek => 'Эта неделя';

  @override
  String get usageUnknown => 'Лимиты неизвестны';

  @override
  String usageResetsIn(String time) {
    return 'Сброс через $time';
  }

  @override
  String usageResetsAt(String time) {
    return 'Сброс $time';
  }

  @override
  String get usageResettingNow => 'Сбрасывается сейчас';

  @override
  String get usageNoReset => 'Время сброса неизвестно';

  @override
  String get usageWarn80 => 'Использование сессии выше 80%. Новые запуски могут встать на паузу до завершения.';

  @override
  String usagePaused(String time) {
    return 'Новые запуски приостановлены из-за лимита тарифа до $time.';
  }

  @override
  String get usagePausedNoTime => 'Новые запуски приостановлены из-за лимита тарифа.';

  @override
  String get usageStatus => 'Статус';

  @override
  String get usageStatus_allowed => 'Разрешено';

  @override
  String get usageStatus_allowed_warning => 'Близко к лимиту';

  @override
  String get usageStatus_rejected => 'Лимит исчерпан';

  @override
  String get usageStatus_unknown => 'Неизвестно';

  @override
  String get usageSource => 'Берётся из событий лимитов Claude Code. Включает ваше собственное использование Claude на этом аккаунте.';

  @override
  String get usageLimitTitle => 'Когда достигнут лимит';

  @override
  String get usageLimitSub => 'Как agnts ведёт себя у лимита';

  @override
  String usageAbove(String pct) {
    return 'Выше $pct% сессии';
  }

  @override
  String get usageAboveDo => 'Не начинать новые запуски; текущие продолжаются';

  @override
  String get usageMidRun => 'Лимит достигнут во время запуска';

  @override
  String get usageMidRunDo => 'Пауза, ветка сохраняется';

  @override
  String get usageAfterReset => 'После сброса';

  @override
  String get usageResumeAuto => 'Автоматически продолжать приостановленные запуски';

  @override
  String get usageResumeManual => 'Ждать, пока вы продолжите';

  @override
  String get usageIdle => 'Обновление в простое';

  @override
  String get usageIdleDo => 'Каждые 30 мин';

  @override
  String get usageHelp =>
      'Данные берутся из событий лимитов, которые Claude Code отправляет во время каждого запуска. Когда agnts простаивает, небольшой запуск обновляет их.';

  @override
  String get wsTitle => 'Рабочее пространство';

  @override
  String get wsSwitcher => 'Сменить рабочее пространство';

  @override
  String get wsAll => 'Все пространства';

  @override
  String get wsNew => 'Новое пространство';

  @override
  String get wsRole_owner => 'Владелец';

  @override
  String get wsRole_user => 'Участник';

  @override
  String get wsTabGeneral => 'Общее';

  @override
  String get wsTabMembers => 'Участники';

  @override
  String get wsTabClaude => 'Claude';

  @override
  String get wsTabBilling => 'Оплата';

  @override
  String get wsGeneral => 'Рабочее пространство';

  @override
  String get wsGeneralSub => 'Название и адрес в ссылках.';

  @override
  String get wsName => 'Название';

  @override
  String get wsSlug => 'Адрес';

  @override
  String wsSlugHelp(String slug) {
    return 'Ссылки на это пространство: /w/$slug. При смене старые ссылки перестают работать.';
  }

  @override
  String get wsSave => 'Сохранить';

  @override
  String get wsSaved => 'Пространство сохранено';

  @override
  String get wsReadOnly => 'Изменить это может только владелец.';

  @override
  String get wsPlan => 'Тариф';

  @override
  String get wsSlots => 'Параллельные запуски';

  @override
  String get wsSlotsHelp => 'Сколько запусков это пространство может выполнять одновременно. Меняется в разделе «Оплата».';

  @override
  String wsTrialEnds(String date) {
    return 'Пробный период до $date';
  }

  @override
  String get wsSuspended => 'Пространство приостановлено: новые запуски не начнутся, пока его не возобновят.';

  @override
  String get wsDanger => 'Опасная зона';

  @override
  String get wsDangerSub =>
      'Удаление останавливает все запуски и удаляет пространство, копии его репозиториев, тикеты и историю. 7 дней его можно восстановить, затем оно стирается.';

  @override
  String get wsDelete => 'Удалить пространство';

  @override
  String wsDeleteTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String wsDeleteBody(String slug) {
    return 'Введите адрес ($slug) для подтверждения. Все потеряют доступ.';
  }

  @override
  String get wsDeleted => 'Пространство удалено';

  @override
  String get wsMembers => 'Участники';

  @override
  String get wsMembersSub =>
      'Все участники видят тикеты пространства, могут создавать их, отвечать, проверять и перезапускать. Владелец также управляет настройками, интеграциями, Claude, участниками и оплатой.';

  @override
  String get wsYou => 'вы';

  @override
  String get wsRemove => 'Удалить';

  @override
  String wsRemoveTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get wsRemoveBody => 'Участник потеряет доступ к пространству. Его тикеты останутся.';

  @override
  String wsRemoved(String name) {
    return '$name удалён';
  }

  @override
  String get wsMakeOwner => 'Сделать владельцем';

  @override
  String wsTransferTitle(String name) {
    return 'Сделать $name владельцем?';
  }

  @override
  String get wsTransferBody => 'Вы останетесь участником, но больше не сможете менять настройки, участников и оплату.';

  @override
  String wsTransferred(String name) {
    return 'Теперь владелец — $name';
  }

  @override
  String get wsLeave => 'Покинуть пространство';

  @override
  String wsLeaveTitle(String name) {
    return 'Покинуть $name?';
  }

  @override
  String get wsLeaveBody => 'Вы потеряете доступ, пока вас снова не пригласят.';

  @override
  String get wsOwnerCannotLeave => 'Владелец не может уйти: сначала передайте права другому участнику.';

  @override
  String get wsClaudeBadge => 'Claude подключён';

  @override
  String get wsNoClaudeBadge => 'Без Claude';

  @override
  String get wsInvite => 'Пригласить людей';

  @override
  String get wsInviteSub => 'Отправьте ссылку по почте или создайте ссылку, чтобы поделиться самому. Ссылка действует 7 дней и один раз.';

  @override
  String get wsInviteEmail => 'Почта (необязательно)';

  @override
  String get wsInviteSend => 'Создать приглашение';

  @override
  String get wsInviteLink => 'Ссылка-приглашение (показывается один раз)';

  @override
  String wsInviteEmailed(String email) {
    return 'Отправлено на $email';
  }

  @override
  String get wsInviteCopy => 'Копировать';

  @override
  String get wsInvites => 'Открытые приглашения';

  @override
  String get wsInviteAnyone => 'Любой со ссылкой';

  @override
  String wsInviteExpires(String date) {
    return 'до $date';
  }

  @override
  String get wsRevoke => 'Отозвать';

  @override
  String get wsRevoked => 'Приглашение отозвано';

  @override
  String wsMemberLimit(String n, String limit) {
    return '$n из $limit участников';
  }

  @override
  String wsMemberLimitNone(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n участника',
      many: '$n участников',
      few: '$n участника',
      one: '$n участник',
    );
    return '$_temp0';
  }

  @override
  String get wsClaude => 'Claude';

  @override
  String get wsClaudeSub => 'Какой аккаунт Claude используют запуски этого пространства.';

  @override
  String get wsMode => 'Режим';

  @override
  String get wsModeShared => 'Общий';

  @override
  String get wsModeSharedHelp => 'Все запуски используют аккаунт пространства, который подключает владелец.';

  @override
  String get wsModeMember => 'У каждого свой';

  @override
  String get wsModeMemberHelp =>
      'Каждый запуск использует аккаунт участника, которому принадлежит тикет. Участники подключают свой аккаунт в профиле.';

  @override
  String get wsConnection => 'Аккаунт пространства';

  @override
  String get wsConnectionSub => 'Используется всеми запусками в общем режиме.';

  @override
  String get wsKind => 'Тип';

  @override
  String get wsKindSubscription => 'Подписка Claude';

  @override
  String get wsKindApiKey => 'API-ключ Anthropic';

  @override
  String get wsKindSubscriptionHelp => 'Выполните `claude setup-token` там, где вы вошли в свой тариф Claude, и вставьте токен.';

  @override
  String get wsKindApiKeyHelp => 'Создайте ключ в Anthropic Console (sk-ant-api…). Расход оплачивает владелец ключа.';

  @override
  String get wsKeyStep1 => 'Войдите в Claude Console (кнопка ниже) и откройте Settings → API keys.';

  @override
  String get wsKeyStep2 =>
      'Нажмите Create Key, назовите ключ (например, agnts) и выберите рабочую область Console, на которую пойдут расходы.';

  @override
  String get wsKeyStep3 => 'Скопируйте ключ (он начинается с sk-ant-api) и вставьте ниже. Console показывает его только один раз.';

  @override
  String get wsKeyStep4 =>
      'Запуски оплачиваются по токенам с этого аккаунта Console: пополните баланс и задайте лимит расходов в разделе Billing.';

  @override
  String get wsKeyOpen => 'Открыть Claude Console';

  @override
  String get wsSubscriptionsOff => 'Этот сервер принимает только API-ключи Anthropic.';

  @override
  String get wsToken => 'Токен';

  @override
  String get wsConnect => 'Подключить';

  @override
  String get wsReplace => 'Заменить';

  @override
  String get wsDisconnect => 'Отключить';

  @override
  String get wsConnected => 'Подключён';

  @override
  String get wsNotConnected => 'Не подключён';

  @override
  String wsPausedUntil(String time) {
    return 'Лимит исчерпан до $time';
  }

  @override
  String wsConnectedAs(String account, String hint) {
    return '$account · …$hint';
  }

  @override
  String get wsFallback => 'Продолжать на кредитах';

  @override
  String get wsFallbackHelp =>
      'Когда выбранный аккаунт упёрся в лимит или не подключён, запуски продолжаются на API-ключе agnts и тратят кредиты пространства вместо паузы.';

  @override
  String get wsFallbackOff => 'Кредиты на этом сервере недоступны.';

  @override
  String wsCredits(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n кредита',
      many: '$n кредитов',
      few: '$n кредита',
      one: '$n кредит',
    );
    return '$_temp0';
  }

  @override
  String get wsDefaultMember => 'Тикеты без автора';

  @override
  String get wsDefaultMemberHelp =>
      'Тикеты из Jira, Plane, последующие задачи и инциденты в режиме «у каждого свой» выполняются на аккаунте этого участника.';

  @override
  String get wsDefaultOwner => 'Владелец';

  @override
  String get wsMemberAccounts => 'Аккаунты участников';

  @override
  String get wsMemberAccountsSub => 'Кто подключил свой аккаунт Claude (Профиль → Claude).';

  @override
  String get wsYourAccount => 'Подключить свой в профиле';

  @override
  String get wsClaudeSaved => 'Настройки Claude сохранены';

  @override
  String get wsRole_viewer => 'Наблюдатель';

  @override
  String get wsViewerBanner => 'Вы здесь наблюдатель: видите всё, но ничего не можете изменить.';

  @override
  String get wsInviteAs => 'Роль';

  @override
  String get wsInviteAsHelp => 'Участники работают с тикетами; наблюдатели только смотрят.';

  @override
  String wsRoleChanged(String name, String role) {
    return '$name теперь: $role';
  }

  @override
  String wsRoleLabel(String name) {
    return 'Роль: $name';
  }
}
