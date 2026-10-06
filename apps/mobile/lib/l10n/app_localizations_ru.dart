// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

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
  String get appName => 'agnts';

  @override
  String get appTagline => 'Ваш агент, который не спит';

  @override
  String get authTitle => 'Вход';

  @override
  String get authLede => 'Войдите с вашей учётной записью и кодом из приложения-аутентификатора.';

  @override
  String get authUsername => 'Имя пользователя';

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
  String get followUpsTitle => 'Последующие тикеты';

  @override
  String get followUpsSub =>
      'Что, по мнению agnts, ещё нужно, чтобы довести этот тикет до конца. Выберите нужные: они создаются в очереди и не запускаются, пока вы их не запустите.';

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
  String get followUpsQueuedHint => 'Созданные тикеты ждут в очереди, пока вы их не запустите.';

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
      'В Repository permissions установите для Contents и Pull requests значение Read and write. Для вкладки «Пайплайны» также установите Actions — Read (Read and write для кнопки «Развернуть») и Deployments — Read. Metadata (чтение) добавляется автоматически.';

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
  String integrationsSynced(String found, String created) {
    return 'Открытых задач: $found, новых: $created';
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
      'Когда пул- или merge request смёржен, agnts отмечает тикет и переводит задачу Jira в статус, выбранный на странице Jira. События пайплайнов обновляют страницу репозитория.';

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
  String navSynced(String found, String created) {
    return 'Jira синхронизирована: открыто $found, новых $created';
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
  String get navLedeAll => 'Все тикеты, которые agnts взял из Jira.';

  @override
  String get navKnowledge => 'Знания';

  @override
  String get navLearn => 'Обучение';

  @override
  String get navLearnQueue => 'Очередь обучения';

  @override
  String get navRules => 'Правила';

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
  String get reposDrawerSub => 'Принимает задачи своего проекта, а с ключом проекта Jira — и тикеты Jira';

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
    return 'Задачи своего проекта нумеруются как $prefix-1, $prefix-2. Должен отличаться от ключа проекта Jira.';
  }

  @override
  String get reposBranch => 'Основная ветка';

  @override
  String get reposBranchHelp => 'Рабочие ветки создаются от неё.';

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
  String get settingsCommits => 'Коммиты и пул-реквесты';

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
  String get settingsOnThisPage => 'На этой странице';

  @override
  String get settingsSecretsHelp =>
      'Токены Jira, GitHub и Claude хранятся на вашем сервере в зашифрованном виде. Эта страница их никогда не показывает.';

  @override
  String get settingsSaved => 'Настройки сохранены';

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
  String get ticketDeliveringSub => 'Сохраняет одобренный отчёт и публикует его в Jira, если вы просили.';

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
  String get ticketsListSub => 'Тикеты Jira с меткой agnts, а также задачи, которые вы создаёте для своих проектов.';

  @override
  String get ticketsNoMatch => 'Нет тикетов по вашему запросу.';

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
}
