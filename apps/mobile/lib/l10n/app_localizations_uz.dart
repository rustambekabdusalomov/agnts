// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get analyticsTitle => 'Analitika';

  @override
  String get analyticsLede =>
      'agnts vaqt oʻtishi bilan siz uchun qanchalik yaxshi ishlayapti: unumdorlik, sifat, vaqt qayerga ketadi va tarifingizga qanchaga tushadi.';

  @override
  String get analyticsPeriod => 'Davr';

  @override
  String analyticsDays(num n) {
    return '$n kun';
  }

  @override
  String get analyticsExportCsv => 'CSV eksport';

  @override
  String get analyticsLoading => 'Analitika yuklanmoqda…';

  @override
  String get analyticsError => 'Analitikani yuklab boʻlmadi. Qayta urining.';

  @override
  String get analyticsEmptyTitle => 'Bu davr uchun hali maʼlumot yoʻq';

  @override
  String get analyticsEmpty =>
      'agnts tiketlarni olib, ishga tushirganda grafiklar toʻladi. Boshlash uchun Jira vazifasiga belgi qoʻying yoki vazifa yarating.';

  @override
  String get analyticsKpiPushed => 'Yuborilgan tiketlar';

  @override
  String analyticsKpiPushedNote(String n) {
    return '$n ta olingandan';
  }

  @override
  String get analyticsKpiSuccess => 'Muvaffaqiyat darajasi';

  @override
  String get analyticsKpiSuccessNote => 'Olinganlardan yuborilgani';

  @override
  String get analyticsKpiFirstTry => 'Birinchi urinishda tasdiqlangan';

  @override
  String get analyticsKpiFirstTryNote => 'Oʻzgartirish soʻralmagan';

  @override
  String get analyticsKpiAgnts => 'Bitta tiketga agnts vaqti';

  @override
  String get analyticsKpiAgntsNote => 'Tahlil, kod yozish va testlar';

  @override
  String get analyticsKpiWait => 'Sizni kutish';

  @override
  String get analyticsKpiWaitNote => 'Har bir tiketga oʻrtacha';

  @override
  String get analyticsKpiTurns => 'Oʻrtacha qadamlar';

  @override
  String get analyticsKpiTurnsNote => 'Har bir tiketga';

  @override
  String analyticsCompared(num n) {
    return 'Oʻzgarishlar oldingi $n kun bilan solishtiriladi. Yashil — yaxshiroq.';
  }

  @override
  String get analyticsThroughput => 'Unumdorlik';

  @override
  String get analyticsThroughputSub => 'Olingan tiketlar va ularning yakuni, kunlar boʻyicha';

  @override
  String get analyticsPushed => 'Yuborildi';

  @override
  String get analyticsRejected => 'Rad etildi';

  @override
  String get analyticsStopped => 'Toʻxtatildi';

  @override
  String get analyticsOutcomes => 'Natijalar';

  @override
  String get analyticsOutcomesSub => 'Tiketlar qanday yakunlangan';

  @override
  String get analyticsFirstTry => 'Birinchi urinishda tasdiqlangan';

  @override
  String get analyticsAfterChanges => 'Oʻzgarishlardan keyin tasdiqlangan';

  @override
  String get analyticsDonutSub => 'yuborildi';

  @override
  String get analyticsSpeed => 'Tezlik';

  @override
  String get analyticsSpeedSub => 'Bitta tiketga oʻrtacha vaqt: agnts ishi va sizni kutish';

  @override
  String get analyticsAgntsWorking => 'agnts ishlayapti';

  @override
  String get analyticsWaitingOnYou => 'Sizni kutish';

  @override
  String get analyticsSteps => 'Vaqt qayerga ketyapti';

  @override
  String get analyticsStepsSub => 'Har bir tiketga oʻrtacha, bosqichlar boʻyicha';

  @override
  String get analyticsTurns => 'Bitta tiketga qadamlar';

  @override
  String get analyticsTurnsSub => 'Kamroq qadam — agnts tezroq yoʻl topadi va limitni kamroq sarflaydi';

  @override
  String get analyticsAvgTurns => 'Oʻrtacha qadamlar';

  @override
  String get analyticsStops => 'Ishlar nega toʻxtaydi';

  @override
  String analyticsStopsSub(num n) {
    return 'Bu davrda $n ta toʻxtagan ish';
  }

  @override
  String get analyticsStopTests => 'Testlar yiqilishda davom etdi';

  @override
  String get analyticsStopLimit => 'Tarif limiti tugadi';

  @override
  String get analyticsStopYou => 'Siz toʻxtatgansiz';

  @override
  String get analyticsStopTurns => 'Qadamlar limitiga yetildi';

  @override
  String get analyticsStopOther => 'Boshqa xatolar';

  @override
  String get analyticsModels => 'Modellar';

  @override
  String get analyticsModelsSub => 'Modellar boʻyicha ishlar va natijalari';

  @override
  String get analyticsChangeModels => 'Modellarni oʻzgartirish';

  @override
  String get analyticsColModel => 'Model';

  @override
  String get analyticsColRuns => 'Ishlar';

  @override
  String get analyticsColShare => 'Ulush';

  @override
  String get analyticsColReview => 'Tekshiruvgacha yetgan';

  @override
  String get analyticsColTurns => 'Oʻrtacha qadamlar';

  @override
  String get analyticsNoRuns => 'Bu davrda ishlar yoʻq.';

  @override
  String get analyticsUsage => 'Tarif limitlari';

  @override
  String get analyticsUsageSub => 'Kunlik eng yuqori sessiya sarfi';

  @override
  String get analyticsSession => 'Sessiya';

  @override
  String get analyticsAvgPeak => 'Oʻrtacha choʻqqi';

  @override
  String get analyticsDaysAbove => '80% dan yuqori kunlar';

  @override
  String get analyticsNoUsage => 'Bu davrda limit maʼlumotlari yoʻq.';

  @override
  String get analyticsSpend => 'Token sarfi';

  @override
  String get analyticsSpendSub => 'Claude kuniga sarflagan tokenlar, kirish va chiqish';

  @override
  String get analyticsSpendTokens => 'Kirish va chiqish tokenlari';

  @override
  String get analyticsSpendCost => 'API narxlarida';

  @override
  String get analyticsSpendStages => 'Bosqichlar boʻyicha sarf';

  @override
  String get analyticsSpendStagesSub => 'Tokenlar qayerga ketgani, eng qimmati yuqorida';

  @override
  String get analyticsNoSpend => 'Bu davrda Claude ishga tushirilmagan.';

  @override
  String get analyticsRepos => 'Repozitoriylar boʻyicha';

  @override
  String get analyticsReposSub => 'agnts qayerda eng yaxshi ishlaydi va qayerda qiynaladi';

  @override
  String get analyticsColRepo => 'Repozitoriy';

  @override
  String get analyticsColSource => 'Manba';

  @override
  String get analyticsColTickets => 'Tiketlar';

  @override
  String get analyticsColSuccess => 'Muvaffaqiyat darajasi';

  @override
  String get analyticsColAgnts => 'agnts vaqti';

  @override
  String get analyticsColClaudeMd => 'CLAUDE.md';

  @override
  String get analyticsSrcJira => 'Jira';

  @override
  String get analyticsSrcTask => 'Vazifa';

  @override
  String get analyticsMdFound => 'Bor';

  @override
  String get analyticsMdMissing => 'Yoʻq';

  @override
  String get analyticsMdUnknown => 'Nomaʼlum';

  @override
  String get analyticsNoRepos => 'Bu davrda hech bir repozitoriyda tiket boʻlmadi.';

  @override
  String get analyticsHours => 'Soatlar boʻyicha faollik';

  @override
  String analyticsHoursSub(String hour) {
    return 'agnts qachon ishlaydi, davr boʻyicha jami. Eng band soat: $hour:00';
  }

  @override
  String get analyticsEvents => 'Hodisalar';

  @override
  String get analyticsInsights => 'Xulosalar';

  @override
  String get analyticsInsightsSub => 'Raqamlar nimani koʻrsatadi';

  @override
  String get analyticsNoInsights => 'Xulosalar uchun hali maʼlumot yetarli emas.';

  @override
  String analyticsInsightClaudeMd(String gain, String repos) {
    return 'CLAUDE.md bor repozitoriylar ishni $gain% kamroq qadamda tugatadi. Uni $repos ga qoʻshish eng tez natija beradi.';
  }

  @override
  String analyticsInsightWaiting(String share, String review) {
    return 'Tiket umumiy vaqtining $share% sizni kutish bilan oʻtadi. Tekshiruv oʻrtacha taxminan $review daqiqa kutiladi.';
  }

  @override
  String analyticsInsightStopsTests(String n) {
    return 'Toʻxtagan ishlarning aksariyati ($n) yiqilgan testlar bilan tugaydi. Tiketlardagi aniq qabul mezonlari agnts\'ga ish qachon tayyorligini bilishga yordam beradi.';
  }

  @override
  String analyticsInsightStopsLimit(String n) {
    return 'Ishlarni ($n) eng koʻp tarif limiti toʻxtatadi. Kamroq parallel ish yoki xulosalar uchun Haiku limitni tejaydi.';
  }

  @override
  String analyticsInsightNight(String pct) {
    return 'agnts ishining $pct% siz oflayn boʻlgan 22:00 dan 07:00 gacha boʻlgan vaqtga toʻgʻri keladi.';
  }

  @override
  String analyticsMinutes(String n) {
    return '$n daq';
  }

  @override
  String analyticsHoursMinutes(String h, String m) {
    return '$h soat $m daq';
  }

  @override
  String get analyticsSrcPlane => 'Plane';

  @override
  String get appName => 'agnts';

  @override
  String get appTagline => 'Hech uxlamaydigan agentingiz';

  @override
  String get authTitle => 'Kirish';

  @override
  String get authLede => 'Hisobingiz va autentifikator ilovasidagi kod bilan kiring.';

  @override
  String get authUsername => 'Foydalanuvchi nomi';

  @override
  String get authPassword => 'Parol';

  @override
  String get authShowPassword => 'Parolni koʻrsatish';

  @override
  String get authHidePassword => 'Parolni yashirish';

  @override
  String get authCode => 'Autentifikator kodi';

  @override
  String get authCodeHint => 'Autentifikator ilovasidagi 6 ta raqam';

  @override
  String get authSubmit => 'Kirish';

  @override
  String get authSubmitting => 'Kirilmoqda…';

  @override
  String get authSignOut => 'Chiqish';

  @override
  String get authSignOutTitle => 'Hisobdan chiqasizmi?';

  @override
  String get authSignOutBody => 'Qayta kirish uchun parol va autentifikator ilovasidagi kod kerak boʻladi.';

  @override
  String get authWrongCredentials => 'Foydalanuvchi nomi, parol yoki kod noto‘g‘ri.';

  @override
  String authRateLimited(num seconds) {
    return 'Urinishlar juda ko‘p. $seconds soniyadan keyin qayta urining.';
  }

  @override
  String get commonLoading => 'Yuklanmoqda…';

  @override
  String get commonError => 'Nimadir xato ketdi. Qayta urining.';

  @override
  String commonSignedInAs(String username) {
    return '$username sifatida kirdingiz';
  }

  @override
  String commonVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String dashboardGreetNight(String name) {
    return 'Xayrli tun, $name';
  }

  @override
  String dashboardGreetMorning(String name) {
    return 'Xayrli tong, $name';
  }

  @override
  String dashboardGreetAfternoon(String name) {
    return 'Xayrli kun, $name';
  }

  @override
  String dashboardGreetEvening(String name) {
    return 'Xayrli kech, $name';
  }

  @override
  String dashboardLede(String date) {
    return '$date. agnts nima qilayotgani va sizni nima kutayotgani.';
  }

  @override
  String get dashboardOpenAnalytics => 'Analitikani ochish';

  @override
  String get dashboardNeedsYou => 'Sizni kutmoqda';

  @override
  String dashboardNeedsNote(String answers, String reviews, String stopped) {
    return '$answers ta javob, $reviews ta tekshiruv, $stopped ta toʻxtagan';
  }

  @override
  String get dashboardRunningNow => 'Hozir bajarilmoqda';

  @override
  String dashboardRunningNote(String n) {
    return 'bir vaqtda: $n';
  }

  @override
  String get dashboardPushedWeek => 'Shu hafta yuborilgan';

  @override
  String dashboardPushedNote(String n) {
    return 'oʻtgan hafta: $n';
  }

  @override
  String get dashboardPlanSession => 'Tarif sessiyasi';

  @override
  String get dashboardWaitingTitle => 'Sizni kutish';

  @override
  String get dashboardWaitingSub => 'Avval eng eskilari. Bu yerdagi har bir daqiqa — agnts ishlay olmaydigan daqiqa.';

  @override
  String get dashboardOpenInbox => 'Kiruvchilarni ochish';

  @override
  String get dashboardNothingWaiting =>
      'Hozir sizni hech narsa kutmayapti. Javob yoki tekshiruv kerak boʻlsa, agnts tiketlarni shu yerda koʻrsatadi.';

  @override
  String get dashboardColTicket => 'Tiket';

  @override
  String get dashboardColStatus => 'Holat';

  @override
  String get dashboardColWaiting => 'Kutmoqda';

  @override
  String get dashboardActAnswer => 'Javob berish';

  @override
  String get dashboardActReview => 'Tekshirish';

  @override
  String get dashboardActRetry => 'Qayta urinish';

  @override
  String get dashboardActResume => 'Davom ettirish';

  @override
  String get dashboardUsageTitle => 'Tarif limitlari';

  @override
  String dashboardUpdated(String time) {
    return 'Yangilandi: $time';
  }

  @override
  String get dashboardNotUpdated => 'Hali maʼlumot yoʻq';

  @override
  String get dashboardSession => 'Joriy sessiya';

  @override
  String get dashboardWeek => 'Shu hafta';

  @override
  String get dashboardPaused => 'Limit yangilanguncha yangi ishlar pauzada.';

  @override
  String get dashboardLiveTitle => 'Faol ishlar';

  @override
  String get dashboardLiveSub => 'Hozir konteynerlardagi tiketlar';

  @override
  String get dashboardNoRuns => 'Hozircha ishlar yoʻq.';

  @override
  String dashboardTurns(String n, String max) {
    return '$n / $max qadam';
  }

  @override
  String get dashboardPipelineTitle => 'Jarayon zanjiri';

  @override
  String get dashboardPipelineSub => 'Ochiq tiketlar bosqichlar boʻyicha';

  @override
  String get dashboardPipeQueue => 'Navbatda';

  @override
  String get dashboardPipeAnalyze => 'Tahlil';

  @override
  String get dashboardPipeAnswers => 'Javoblaringiz';

  @override
  String get dashboardPipeCoding => 'Kod yozish';

  @override
  String get dashboardPipeReview => 'Sizning tekshiruvingiz';

  @override
  String get dashboardPipeStopped => 'Toʻxtatildi';

  @override
  String get dashboardTodayTitle => 'Bugun soatlar boʻyicha';

  @override
  String get dashboardTodaySub => 'Bugungi hodisalar. Siz uxlayotganda ham agnts ishlayveradi.';

  @override
  String get dashboardTodayAria => 'Bugungi hodisalar soatlar boʻyicha';

  @override
  String get dashboardLegendAgnts => 'agnts ishlayapti';

  @override
  String get dashboardLegendYou => 'Sizning harakatlaringiz';

  @override
  String get dashboardLegendProblems => 'Ogohlantirish va xatolar';

  @override
  String get dashboardWeekTitle => 'Shu hafta';

  @override
  String get dashboardWeekSub => 'Oʻtgan hafta bilan solishtirganda';

  @override
  String get dashboardPicked => 'Olingan tiketlar';

  @override
  String get dashboardFirstTry => 'Birinchi urinishda tasdiqlangan';

  @override
  String get dashboardAvgTurns => 'Oʻrtacha qadamlar';

  @override
  String get dashboardAvgWait => 'Sizni kutish, oʻrtacha';

  @override
  String get dashboardStoppedRuns => 'Toʻxtagan ishlar';

  @override
  String get dashboardReposTitle => 'Repozitoriylar';

  @override
  String get dashboardReposSub => 'Ochiq ishlar va har biridagi soʻnggi tiket';

  @override
  String get dashboardAllRepos => 'Barcha repozitoriylar';

  @override
  String get dashboardColRepo => 'Repozitoriy';

  @override
  String get dashboardColOpen => 'Ochiq';

  @override
  String get dashboardColLatest => 'Soʻnggi tiket';

  @override
  String get dashboardColClaudeMd => 'CLAUDE.md';

  @override
  String get dashboardFound => 'Bor';

  @override
  String get dashboardMissing => 'Yoʻq';

  @override
  String get dashboardUnknown => 'Nomaʼlum';

  @override
  String get dashboardNoRepos => 'Ochiq ishga ega repozitoriy yoʻq.';

  @override
  String get dashboardRecentTitle => 'Soʻnggi faollik';

  @override
  String get dashboardLogs => 'Loglar';

  @override
  String get dashboardNoActivity => 'Hozircha faollik yoʻq.';

  @override
  String get filesTitle => 'Ilovalar';

  @override
  String get filesAttach => 'Fayl biriktirish';

  @override
  String get filesAddPhoto => 'Rasm';

  @override
  String get filesCamera => 'Kamera';

  @override
  String get filesAddFile => 'Fayl';

  @override
  String get filesHint => 'Rasmlar, PDF, loglar yoki matn, har biri 10 MB gacha. Claude ularning barchasini oʻqiydi.';

  @override
  String filesUploading(String name) {
    return '$name yuklanmoqda…';
  }

  @override
  String filesRemove(String name) {
    return '$name ni olib tashlash';
  }

  @override
  String filesOpen(String name) {
    return '$name ni ochish';
  }

  @override
  String filesTooLarge(String name) {
    return '$name 10 MB dan katta';
  }

  @override
  String filesTooMany(String n) {
    return 'Koʻpi bilan $n ta fayl biriktiring';
  }

  @override
  String filesFailed(String name) {
    return '$name yuklanmadi';
  }

  @override
  String get filesWait => 'Yuklash tugashini kuting';

  @override
  String get filesFromTask => 'Vazifaga';

  @override
  String get filesFromRetry => 'Qayta urinishga';

  @override
  String get filesFromFeedback => 'Soʻralgan oʻzgarishlarga';

  @override
  String get followUpsTitle => 'Keyingi tiketlar';

  @override
  String get followUpsSub =>
      'agnts fikricha, bu tiketni oxiriga yetkazish uchun yana nima kerak. Keraklilarini tanlang: ular navbatda yaratiladi va siz ishga tushirmaguningizcha ishlamaydi.';

  @override
  String get followUpsMode => 'Keyingi tiket takliflari';

  @override
  String get followUpsModeInherit => 'Sozlamalardagidek';

  @override
  String get followUpsModeOn => 'Yoqilgan';

  @override
  String get followUpsModeOff => 'Oʻchirilgan';

  @override
  String get followUpsModeHint =>
      'Yoqilganda agnts ishlari bu tiketga yana kerak boʻlgan tiketlarni taklif qiladi. Har bir prompt biroz uzunroq boʻladi.';

  @override
  String get followUpsOffEmpty =>
      'Bu tiket uchun takliflar oʻchirilgan. Yoqsangiz, keyingi ish uni tugatish uchun yana nima kerakligini taklif qiladi.';

  @override
  String get followUpsOnEmpty => 'Hozircha hech narsa taklif qilinmagan. Koʻp tiketlarga davom kerak emas.';

  @override
  String get followUpsType_prerequisite => 'Oldindan kerak';

  @override
  String get followUpsType_split => 'Alohida ajratish';

  @override
  String get followUpsType_unfinished => 'Bajarilmagan';

  @override
  String get followUpsType_gap => 'Boʻshliq';

  @override
  String get followUpsSource_analyze => 'tahlildan';

  @override
  String get followUpsSource_work => 'ishdan';

  @override
  String get followUpsSource_review => 'kod koʻrigidan';

  @override
  String get followUpsSource_manual => 'koʻrik izohidan';

  @override
  String followUpsPick(String title) {
    return '“$title” ni yaratish';
  }

  @override
  String get followUpsEditTitle => 'Tiket nomi';

  @override
  String get followUpsServes => 'Nima uchun';

  @override
  String get followUpsDetails => 'Batafsil';

  @override
  String get followUpsWaitsForDone => 'Bu tiket ishiga tayanadi: tiket tugagach yaratish mumkin.';

  @override
  String get followUpsTarget => 'Qanday yaratish';

  @override
  String get followUpsTargetLocal => 'Mahalliy vazifa';

  @override
  String get followUpsTargetJira => 'Jira vazifasi';

  @override
  String get followUpsJiraOff => 'U yerda vazifa ochish uchun Jira\'ni ulang';

  @override
  String followUpsCreate(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta tiket yaratish', zero: 'Tiketlarni yaratish');
    return '$_temp0';
  }

  @override
  String get followUpsQueuedHint => 'Yaratilgan tiketlar siz ishga tushirmaguningizcha navbatda turadi.';

  @override
  String get followUpsDismiss => 'Rad etish';

  @override
  String followUpsDismissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta rad etilgan taklif');
    return '$_temp0';
  }

  @override
  String get followUpsChildren => 'Shu tiketdan yaratilgan';

  @override
  String get followUpsFollowUpOf => 'Davomi';

  @override
  String followUpsCreatedNotice(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta tiket yaratildi');
    return '$_temp0, ishga tushirguningizcha navbatda.';
  }

  @override
  String followUpsFailedItem(String title, String error) {
    return '$title: $error';
  }

  @override
  String get followUpsFromFinding => 'Keyingi tiketga';

  @override
  String get followUpsFromFindingDone => 'Davom sifatida taklif qilindi';

  @override
  String get followUpsFromFindingHint => 'Bu oʻzgarishdan tashqaridagi ish uchun: qaytarish oʻrniga alohida tiket sifatida taklif qilish';

  @override
  String followUpsOpenBadge(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta taklif');
    return '$_temp0';
  }

  @override
  String get followUpsSettingLabel => 'Keyingi tiketlarni taklif qilish';

  @override
  String get followUpsSettingHelp =>
      'Tahlil, ish va koʻrik jarayonlari tiketni tugatish uchun yana kerak boʻlgan tiketlarni taklif qiladi: oldindan kerak ishlar, ajratiladigan qismlar, bajarilmagan ishlar, hisobot topgan boʻshliqlar. Qaysilarini yaratishni siz hal qilasiz. Har bir prompt biroz uzayishi sababli sukut boʻyicha oʻchirilgan; tiket buni oʻzi uchun yoqishi mumkin.';

  @override
  String get followUpsNotifyLabel => 'Keyingi tiketlar taklif qilindi';

  @override
  String get followUpsJiraIssueType => 'Davomlar uchun vazifa turi';

  @override
  String get followUpsJiraIssueTypeHelp => 'Davomni Jira\'da yaratganingizda agnts ochadigan Jira vazifalari turi. Sukut boʻyicha: Task.';

  @override
  String get followUpsTargetPlane => 'Plane vazifasi';

  @override
  String get followUpsPlaneOff => 'U yerda vazifa yaratish uchun Plane\'ni ulang va repozitoriyni Plane loyihasiga bogʻlang';

  @override
  String get formSave => 'Oʻzgarishlarni saqlash';

  @override
  String get formSaving => 'Saqlanmoqda…';

  @override
  String get formDiscard => 'Bekor qilish';

  @override
  String get formCancel => 'Bekor qilish';

  @override
  String get formUnsaved => 'Saqlanmagan oʻzgarishlar bor';

  @override
  String get formClose => 'Yopish';

  @override
  String get formAdd => 'Qoʻshish';

  @override
  String formRemove(String name) {
    return '$name ni olib tashlash';
  }

  @override
  String get formAddCommand => 'Buyruq qoʻshish';

  @override
  String get formDecrease => 'Kamaytirish';

  @override
  String get formIncrease => 'Koʻpaytirish';

  @override
  String get formCopy => 'Nusxalash';

  @override
  String get formCopied => 'Nusxalandi';

  @override
  String get formSaved => 'Saqlandi';

  @override
  String get formSearch => 'Qidirish';

  @override
  String get formNoMatch => 'Hech narsa topilmadi';

  @override
  String get implementTitle => 'Keyingi qadam';

  @override
  String get implementSubPlan =>
      'agnts shu rejani bajarsin: shu bilan bogʻlangan kod vazifasi, reja uning topshirigʻi boʻladi. Diffni odatdagidek siz tekshirasiz.';

  @override
  String get implementSubBug =>
      'agnts taklif qilingan tuzatishni kiritsin: shu bilan bogʻlangan kod vazifasi, tekshiruv uning topshirigʻi boʻladi. Diffni odatdagidek siz tekshirasiz.';

  @override
  String get implementImplement => 'Rejani bajarish';

  @override
  String get implementFix => 'Xatoni tuzatish';

  @override
  String get implementPickRepo => 'Oʻzgartirish kiritiladigan repozitoriy';

  @override
  String get implementQueue => 'Vazifani boshlamasdan navbatda qoldirish';

  @override
  String get implementDoneBy => 'Bajaruvchi vazifa:';

  @override
  String get implementImplements => 'Bajaradi';

  @override
  String get integrationsTitle => 'Integratsiyalar';

  @override
  String get integrationsLede =>
      'agnts ishlaydigan xizmatlar. Tokenlar serveringizda shifrlangan holda saqlanadi va faqat har bir sahifada koʻrsatilgan amallar uchun ishlatiladi.';

  @override
  String get integrationsName_jira => 'Jira';

  @override
  String get integrationsName_github => 'GitHub';

  @override
  String get integrationsName_claude => 'Claude';

  @override
  String get integrationsDesc_jira => 'agnts belgisi bor tiketlarni olish va ularning holatini yangilab borish.';

  @override
  String get integrationsDesc_github => 'Kodni klonlash, branchlarni yuborish va pull requestlar ochish.';

  @override
  String get integrationsDesc_claude => 'Claude Code ishlaydigan Claude obunangiz.';

  @override
  String get integrationsConnected => 'Ulangan';

  @override
  String get integrationsNotConnected => 'Ulanmagan';

  @override
  String get integrationsConnect => 'Ulash';

  @override
  String get integrationsManage => 'Boshqarish';

  @override
  String get integrationsTest => 'Ulanishni tekshirish';

  @override
  String get integrationsDisconnect => 'Uzish';

  @override
  String integrationsDisconnectConfirm(String name) {
    return '$name uzilsinmi? agnts tokenni unutadi va undan foydalanishni toʻxtatadi.';
  }

  @override
  String integrationsDisconnected(String name) {
    return '$name uzildi';
  }

  @override
  String get integrationsAccount => 'Hisob';

  @override
  String get integrationsToken => 'Token';

  @override
  String get integrationsLastChecked => 'Oxirgi tekshiruv';

  @override
  String get integrationsLastError => 'Oxirgi xato';

  @override
  String get integrationsNever => 'Hech qachon';

  @override
  String get integrationsComing => 'Keyinroq';

  @override
  String get integrationsComingSub => 'Rejalashtirilgan integratsiyalar';

  @override
  String get integrationsBack => 'Integratsiyalarga qaytish';

  @override
  String integrationsConnectedAs(String account, String time) {
    return '$account sifatida ulangan. Oxirgi tekshiruv: $time.';
  }

  @override
  String get integrationsNotYet => 'Hali ulanmagan.';

  @override
  String integrationsConnectTitle(String name) {
    return '$name ni ulash';
  }

  @override
  String get integrationsConnectSub_jira => 'Atlassian hisobingizdagi API tokenidan foydalaning.';

  @override
  String get integrationsTokenOpen_jira => 'Atlassian API tokenlarini ochish';

  @override
  String get integrationsTokenStep1_jira =>
      'agnts nomidan ishlaydigan Atlassian hisobiga kiring va Account settings → Security → API tokens boʻlimini oching (yoki quyidagi tugmadan foydalaning).';

  @override
  String get integrationsTokenStep2_jira =>
      'Create API token ni bosing (scopes bilan boʻlganini emas), nom bering (masalan, agnts) va amal qilish muddatini tanlang.';

  @override
  String get integrationsTokenStep3_jira => 'Tokenni nusxalang va pastga joylang. Atlassian uni faqat bir marta koʻrsatadi.';

  @override
  String get integrationsTokenStep4_jira =>
      'Sayt maydoniga Jira manzilingizni (https://your-team.atlassian.net), hisob emailiga esa oʻsha hisobning emailini kiriting. Hisob agnts ishlaydigan Jira loyihalariga kira olishi kerak.';

  @override
  String get integrationsConnectSub_github =>
      'Quyidagi ruxsatlar bilan fine-grained shaxsiy kirish tokenini yarating va shu yerga joylang.';

  @override
  String get integrationsTokenHow => 'Tokenni qanday olish mumkin';

  @override
  String get integrationsTokenCommand => 'Buyruq';

  @override
  String get integrationsTokenOpen_github => 'GitHub token sahifasini ochish';

  @override
  String get integrationsTokenStep1_github =>
      'GitHubʼda Settings → Developer settings → Personal access tokens → Fine-grained tokens boʻlimini oching va Generate new token tugmasini bosing (yoki quyidagi tugmadan foydalaning).';

  @override
  String get integrationsTokenStep2_github =>
      'Nom bering (masalan, agnts), amal qilish muddatini tanlang, Resource ownerʼda repozitoriylar egasi boʻlgan hisob yoki tashkilotni, Repository accessʼda esa agnts ishlaydigan repozitoriylarni tanlang.';

  @override
  String get integrationsTokenStep3_github =>
      'Repository permissionsʼda Contents va Pull requests uchun Read and write ni tanlang; agnts .github/workflows dagi CI fayllarini oʻzgartirishi mumkin boʻlsa, Workflows uchun ham Read and write ni tanlang. Pipelines boʻlimi uchun Actions — Read (Deploy uchun Read and write) va Deployments — Read ni ham tanlang. Metadata (oʻqish) avtomatik qoʻshiladi.';

  @override
  String get integrationsTokenStep4_github =>
      'Generate token ni bosing, tokenni nusxalang (github_pat_ bilan boshlanadi) va pastga joylang. GitHub uni faqat bir marta koʻrsatadi. Tashkilot uchun avval egasi tokenni tasdiqlashi kerak boʻlishi mumkin.';

  @override
  String get integrationsConnectSub_claude =>
      'Claude tarifingizga kirgan kompyuterda `claude setup-token` ni ishga tushiring va tokenni joylang.';

  @override
  String get integrationsTokenStep1_claude =>
      'Claude Pro yoki Max obunasi kerak. Istalgan kompyuterda Claude Codeʼni oʻrnating: npm install -g @anthropic-ai/claude-code';

  @override
  String get integrationsTokenStep2_claude => 'Terminalda claude ni ishga tushiring va Claude hisobingizga kiring.';

  @override
  String get integrationsTokenStep3_claude =>
      'Quyidagi buyruqni bajaring. U ruxsatni tasdiqlash uchun brauzerni ochadi va uzoq muddatli tokenni chiqaradi.';

  @override
  String get integrationsTokenStep4_claude =>
      'Tokenni nusxalang (sk-ant- bilan boshlanadi) va pastga joylang. U taxminan bir yil amal qiladi, ishga tushirishlar obunangiz limitidan sarflanadi.';

  @override
  String get integrationsSite => 'Sayt';

  @override
  String get integrationsSiteHelp => 'Masalan https://your-team.atlassian.net';

  @override
  String get integrationsEmail => 'Hisob emaili';

  @override
  String get integrationsApiToken => 'API token';

  @override
  String get integrationsApiTokenHelp => 'id.atlassian.com → Security → API tokens';

  @override
  String get integrationsAccessToken => 'Kirish tokeni';

  @override
  String get integrationsTokenHelp => 'Serveringizda shifrlangan holda saqlanadi. agnts uni boshqa koʻrsatmaydi.';

  @override
  String get integrationsScopes => 'Kerakli ruxsatlar';

  @override
  String get integrationsPermContents => 'Oʻqish va yozish. Kodni klonlash va branchlarni yuborish.';

  @override
  String get integrationsPermPulls => 'Oʻqish va yozish. Pull requestlar ochish.';

  @override
  String get integrationsPermWorkflows =>
      'Oʻqish va yozish. .github/workflows (CI fayllari) dagi oʻzgarishlarni yuborish; busiz bunday push rad etiladi.';

  @override
  String get integrationsPermMetadata => 'Oʻqish. Repozitoriylar va branchlar roʻyxati.';

  @override
  String get integrationsPermActions => 'Oʻqish — Pipelines boʻlimi va muhitlar uchun; oʻqish va yozish — Deploy uchun.';

  @override
  String get integrationsPermDeployments => 'Oʻqish. Har bir muhitda nima joylanganini koʻrsatadi.';

  @override
  String get integrationsRequired => 'Majburiy';

  @override
  String get integrationsRecommended => 'Tavsiya etiladi';

  @override
  String get integrationsConnecting => 'Token tekshirilmoqda…';

  @override
  String integrationsConnectedToast(String name) {
    return '$name ulandi';
  }

  @override
  String integrationsTestOk(String name) {
    return '$name: ulanish ishlayapti';
  }

  @override
  String integrationsTestFail(String name, String error) {
    return '$name: $error';
  }

  @override
  String get integrationsWebhookTitle => 'Jira webhookini sozlang';

  @override
  String get integrationsWebhookSteps => 'Jira\'da Settings → System → WebHooks → Create ni oching va kiriting:';

  @override
  String get integrationsWebhookUrl => 'URL';

  @override
  String get integrationsWebhookSecret => 'Maxfiy kalit';

  @override
  String get integrationsWebhookOnce => 'Bu maxfiy kalit faqat bir marta koʻrsatiladi. Uni hozir Jira\'ga joylang.';

  @override
  String get integrationsEvents => 'Hodisalar';

  @override
  String get integrationsEventsValue => 'Issue created, Issue updated';

  @override
  String get integrationsConnection => 'Ulanish';

  @override
  String get integrationsPickup => 'Olish qoidalari';

  @override
  String get integrationsPickupSub => 'agnts qaysi tiketlarni oladi';

  @override
  String get integrationsLabel => 'Belgi';

  @override
  String get integrationsLabelHelp => 'Tiketni agnts\'ga topshirish uchun shu belgini qoʻshing';

  @override
  String get integrationsQuery => 'agnts bajaradigan soʻrov';

  @override
  String get integrationsStatuses => 'Holat yangilanishlari';

  @override
  String get integrationsStatusesSub => 'agnts doskangizda tiketlarni qanday siljitadi. Holatni oʻzgartirmaslik uchun boʻsh qoldiring.';

  @override
  String get integrationsMapStarted => 'agnts boshlaganda';

  @override
  String get integrationsMapReview => 'Oʻzgarishlar yuborilganda';

  @override
  String get integrationsMapRejected => 'Oʻzgarishlarni rad etganingizda';

  @override
  String get integrationsKeepStatus => 'Holatni saqlash';

  @override
  String get integrationsComments => 'Izohlar';

  @override
  String get integrationsCommentsSub => 'agnts tiketga nima yozadi';

  @override
  String get integrationsCQuestions => 'agnts savollari';

  @override
  String get integrationsCQuestionsHelp => 'Hamkasblar nima noaniq boʻlganini koʻrishi uchun';

  @override
  String get integrationsCPlan => 'Kod yozishdan oldingi reja';

  @override
  String get integrationsCPr => 'Pull request havolasi';

  @override
  String get integrationsCSummary => 'Oʻzgarishlar xulosasi';

  @override
  String get integrationsCStatus => 'Tarif limiti sababli pauzalar';

  @override
  String get integrationsSync => 'Sinxronlash';

  @override
  String get integrationsSyncNow => 'Hozir sinxronlash';

  @override
  String integrationsSynced(String found, String created) {
    return 'Ochiq vazifalar: $found, yangilari: $created';
  }

  @override
  String get integrationsSyncHelp =>
      'Jira yangi tiketlarni darhol webhookga yuboradi; yetkazish oʻtkazib yuborilgan boʻlsa, agnts har soatda ham tekshiradi.';

  @override
  String get integrationsWebhook => 'Webhook';

  @override
  String integrationsSaved(String name) {
    return '$name sozlamalari saqlandi';
  }

  @override
  String get integrationsSecretsHelp =>
      'agnts faqat soʻrovga mos tiketlarni oʻqiydi va faqat shu yerda yoqqan holat oʻzgarishlari va izohlarni yozadi.';

  @override
  String get integrationsGithubHelp =>
      'Repozitoriylaringizga yubora oladigan hisob tokenidan foydalaning. Commitlar Sozlamalardagi ism va email bilan qilinadi.';

  @override
  String get integrationsClaudeHelp => 'Token taxminan bir yil amal qiladi. Muddati tugashidan oldin `claude setup-token` bilan yangilang.';

  @override
  String get integrationsName_telegram => 'Telegram';

  @override
  String get integrationsDesc_telegram =>
      'Siz kerak boʻlganda xabarlar. Savollarga javob bering, tasdiqlang yoki oʻzgartirish soʻrang — toʻgʻridan-toʻgʻri chatda.';

  @override
  String get integrationsConnectSub_telegram =>
      '@BotFather orqali bot yarating, tokenini qoʻying va chat id ingizni kiriting. agnts webhookni oʻzi roʻyxatdan oʻtkazadi.';

  @override
  String get integrationsTokenOpen_telegram => '@BotFatherʼni ochish';

  @override
  String get integrationsChatIdFind => 'Chat idʼni bilish';

  @override
  String get integrationsTokenStep1_telegram =>
      'Telegramʼda @BotFatherʼni oching (quyidagi tugma), /newbot yuboring va nom hamda bot bilan tugaydigan username tanlang.';

  @override
  String get integrationsTokenStep2_telegram =>
      'BotFather bot tokenini yuboradi (masalan, 123456789:AA…). Uni quyidagi «Kirish tokeni» maydoniga joylang.';

  @override
  String get integrationsTokenStep3_telegram => 'Yangi botingizni Telegramʼda oching va Start ni bosing, shunda unda sizdan xabar boʻladi.';

  @override
  String get integrationsTokenStep4_telegram =>
      '«Chat idʼni bilish» tugmasini bosing (token joylangach chiqadi). Ochilgan sahifada \"chat\" ni toping va \"id\" dan keyingi raqamni chat id maydoniga nusxalang. Xabarlar koʻrinmasa, botga yana yozing va sahifani yangilang.';

  @override
  String get integrationsChatId => 'Chat id ingiz';

  @override
  String get integrationsChatIdHelp => 'Botdan foydalanishga ruxsat berilgan chat. Faqat shu chat amal bajara oladi.';

  @override
  String get integrationsTelegramHelp => 'Tasdiqlash va rad etish ikkinchi bosish bilan tasdiqlanadi; tasdiq 10 daqiqadan keyin eskiradi.';

  @override
  String integrationsTelegramHttps(String url) {
    return 'Telegram yangilanishlarni faqat ochiq HTTPS manzilga yuboradi, bu agnts esa $url da ishlayapti, shuning uchun bu yerda ulanish amalga oshmaydi. Telegramʼni HTTPS bilan ishlaydigan serverda ulang, u yerda AGNTS_PUBLIC_URL https:// manzil boʻladi.';
  }

  @override
  String get integrationsName_gitlab => 'GitLab';

  @override
  String get integrationsDesc_gitlab =>
      'gitlab.com yoki oʻz GitLab ingizda kodni klon qiladi, branchlarni yuboradi va merge request ochadi.';

  @override
  String get integrationsConnectSub_gitlab => 'Quyidagi huquqlarga ega shaxsiy token yarating va shu yerga qoʻying.';

  @override
  String get integrationsTokenOpen_gitlab => 'GitLab token sahifasini ochish';

  @override
  String get integrationsTokenStep1_gitlab =>
      'Avval quyida server manzilini kiriting. Soʻng GitLabʼda avatar → Edit profile → Access tokens → Add new token ni oching (yoki quyidagi tugmadan foydalaning).';

  @override
  String get integrationsTokenStep2_gitlab =>
      'Nom bering (masalan, agnts) va amal qilish muddatini belgilang. Loyihalaringizga push qila oladigan hisobdan foydalaning.';

  @override
  String get integrationsTokenStep3_gitlab => 'api, read_repository va write_repository ruxsatlarini belgilang.';

  @override
  String get integrationsTokenStep4_gitlab =>
      'Create token ni bosing, tokenni nusxalang (glpat- bilan boshlanadi) va pastga joylang. GitLab uni faqat bir marta koʻrsatadi.';

  @override
  String get integrationsGitlabUrl => 'Instance manzili';

  @override
  String get integrationsGitlabUrlHelp => 'https://gitlab.com yoki oʻz GitLab serveringiz.';

  @override
  String get integrationsGlApi => 'API ga toʻliq kirish. Merge request ochish va pipelinelarni oʻqish.';

  @override
  String get integrationsGlRead => 'Kodni klon qilish.';

  @override
  String get integrationsGlWrite => 'Branchlarni yuborish.';

  @override
  String get integrationsGitlabHelp =>
      'Loyihalaringizga push qila oladigan hisob tokenidan foydalaning. Ish konteynerlari uni koʻrmaydi; push siz tasdiqlagandan keyin serverda bajariladi.';

  @override
  String get integrationsMapMerged => 'Pull request birlashtirilganda';

  @override
  String get integrationsGitWebhookSteps_github =>
      'Repozitoriy (yoki tashkilot) da Settings → Webhooks → Add webhook ni oching. Content type application/json, quyidagi URL va sirni qoʻying.';

  @override
  String get integrationsGitWebhookSteps_gitlab =>
      'Loyihada Settings → Webhooks ni oching. URL ni qoʻying, quyidagi sirni Secret token maydoniga kiriting.';

  @override
  String get integrationsGitEvents_github => 'Pull requests, Workflow runs';

  @override
  String get integrationsGitEvents_gitlab => 'Merge request events, Pipeline events';

  @override
  String get integrationsGitWebhookWhy =>
      'Pull yoki merge request birlashtirilganda agnts tiketni belgilaydi va Jira yoki Plane vazifasini treker sahifasida tanlangan holatga oʻtkazadi. Pipeline hodisalari repozitoriy sahifasini yangilab turadi.';

  @override
  String get integrationsName_plane => 'Plane';

  @override
  String get integrationsDesc_plane =>
      'Plane Cloud yoki oʻzingizning Plane\'dan agnts belgili vazifalarni oladi va ularning holatini yangilab boradi.';

  @override
  String get integrationsConnectSub_plane =>
      'Plane\'dagi shaxsiy kirish tokenidan foydalaning. Plane Cloud va oʻz serveringizdagi Plane bilan ishlaydi.';

  @override
  String get integrationsTokenOpen_plane => 'Plane API hujjatlarini ochish';

  @override
  String get integrationsTokenStep1_plane =>
      'Plane\'ga agnts nomidan ishlaydigan foydalanuvchi sifatida kiring (izohlar shu nom bilan chiqadi) va Profile settings → Personal access tokens\'ni oching.';

  @override
  String get integrationsTokenStep2_plane =>
      'Add personal access token\'ni bosing, nom bering (masalan, agnts), muddatni tanlang va tokenni nusxalang. Plane uni faqat bir marta koʻrsatadi.';

  @override
  String get integrationsTokenStep3_plane =>
      '«API manzili» maydonida Plane Cloud uchun https://api.plane.so ni qoldiring yoki Plane oʻz serveringizda boʻlsa, uning manzilini kiriting.';

  @override
  String get integrationsTokenStep4_plane =>
      '«Ish maydoni» maydoniga Plane manzilidagi slugni kiriting: app.plane.so/acme/projects dagi acme.';

  @override
  String get integrationsPlaneBaseUrl => 'API manzili';

  @override
  String get integrationsPlaneBaseUrlHelp => 'Plane Cloud uchun https://api.plane.so yoki Plane manzilingiz';

  @override
  String get integrationsPlaneWorkspace => 'Ish maydoni';

  @override
  String get integrationsPlaneWorkspaceHelp => 'Plane manzilidagi slug, masalan acme';

  @override
  String get integrationsApiKey => 'API kaliti';

  @override
  String get integrationsApiKeyHelp => 'Profile settings → Personal access tokens';

  @override
  String get integrationsPlaneWebhookTitle => 'Plane webhookini sozlang';

  @override
  String get integrationsPlaneWebhookSteps =>
      'Plane\'da Workspace settings → Webhooks → Add webhook\'ni oching, quyidagi manzilni kiriting va vazifa (issue) hodisalarini belgilang. Plane sirni bir marta koʻrsatadi — uni shu yerga joylang.';

  @override
  String get integrationsPlaneEventsValue => 'Vazifalar (issues)';

  @override
  String get integrationsPlaneSecret => 'Plane\'dagi sir';

  @override
  String get integrationsPlaneSecretHelp => 'Plane uni webhook yaratilganda bir marta koʻrsatadi';

  @override
  String get integrationsPlaneSecretSave => 'Sirni saqlash';

  @override
  String get integrationsPlaneSecretReplace => 'Sirni almashtirish';

  @override
  String get integrationsPlaneSecretSaved => 'Webhook siri saqlandi: endi Plane yetkazmalari qabul qilinadi';

  @override
  String get integrationsPlaneSecretSet => 'Sir saqlangan. Yetkazmalar qabul qilinadi.';

  @override
  String get integrationsPlaneSecretMissing =>
      'Sir hali yoʻq: Plane koʻrsatgan sirni joylamaguningizcha agnts yetkazmalarni rad etadi va vazifalarni faqat har soatlik sinxronlash oladi.';

  @override
  String integrationsPlaneQueryText(String labels) {
    return 'Repozitoriylarga bogʻlangan Plane loyihalaridagi quyidagi belgilardan biri bor ochiq vazifalar: $labels';
  }

  @override
  String get integrationsPlaneNoProjects =>
      'Hali hech bir repozitoriy Plane loyihasiga bogʻlanmagan. Repozitoriy sozlamalarida loyiha identifikatorini (WEB-123 dagi WEB) kiriting.';

  @override
  String get integrationsPlaneStatusesSub =>
      'agnts vazifalarni qanday siljitadi. «Standart» — mos guruhning birinchi holati; «koʻrib chiqishda» — faqat siz tanlagan holatga.';

  @override
  String integrationsPlaneStateDefault(String group) {
    return 'Standart: birinchi $group holati';
  }

  @override
  String get integrationsPlaneStateNone => 'Holatni saqlash';

  @override
  String integrationsPlaneStatesError(String error) {
    return 'Plane\'dan holatlarni olib boʻlmadi: $error';
  }

  @override
  String get integrationsPlaneSyncHelp =>
      'Plane oʻzgarishlarni darhol webhookka yuboradi; agnts ham yetkazma oʻtkazib yuborilgan boʻlsa deb har soatda tekshiradi.';

  @override
  String get integrationsPlaneHelp =>
      'agnts bogʻlangan loyihalardagi faqat oʻz belgilari bor vazifalarni oʻqiydi va faqat shu yerda yoqilgan holat oʻzgarishlari va izohlarni yozadi. Plane har bir kalit uchun daqiqasiga 60 ta API soʻroviga ruxsat beradi; agnts 50 tadan oshmaydi.';

  @override
  String integrationsPlaneSynced(String found, String created) {
    return '$found ta ochiq vazifa, $created ta yangi';
  }

  @override
  String get kindTitle => 'Turi';

  @override
  String get kindAuto => 'Avto';

  @override
  String get kindAutoHint => 'agnts tiketni oʻqiyotganda turini oʻzi tanlaydi';

  @override
  String get kindCode => 'Kod';

  @override
  String get kindCodeHint => 'Kodga oʻzgartirish kiritish. Repozitoriy kerak; natijasi — pull request.';

  @override
  String get kindTest => 'Testlar';

  @override
  String get kindTestHint => 'Avtotestlarni yozish yoki tuzatish. Repozitoriy kerak; natijasi — pull request.';

  @override
  String get kindPlan => 'Reja';

  @override
  String get kindPlanHint => 'Amalga oshirish rejasini yozish. Kod oʻzgarmaydi; natijasi — hisobot.';

  @override
  String get kindAnalysis => 'Tahlil';

  @override
  String get kindAnalysisHint => 'Savolni oʻrganib, xulosalarni yozish. Kod oʻzgarmaydi.';

  @override
  String get kindBug => 'Xatoni tekshirish';

  @override
  String get kindBugHint => 'Xatoning asl sababini topib, tuzatishni taklif qilish. Kod oʻzgarmaydi.';

  @override
  String get kindPickerHint => 'agnts nima qiladi. Tanlangan tur oʻzgarmaydi; «Avto»da agnts tiketni oʻqib, oʻzi hal qiladi.';

  @override
  String kindSwitchTo(String kind) {
    return '«$kind»ga oʻtkazish';
  }

  @override
  String get learnTitle => 'Oʻrganish';

  @override
  String get learnLede =>
      'agnts yuborgan oʻzgarish bu kodda avval boʻlmagan narsani qilsa, agnts uni shu yerda tushuntiradi: bu nima, nega kerak boʻldi, qayerga qarash kerak va qisqa test.';

  @override
  String learnViewNew(String n) {
    return 'Yangi ($n)';
  }

  @override
  String get learnViewLearned => 'Oʻrganilgan';

  @override
  String learnViewAll(String n) {
    return 'Hammasi ($n)';
  }

  @override
  String get learnViewLabel => 'Koʻrsatish';

  @override
  String get learnAllRepos => 'Barcha repozitoriylar';

  @override
  String get learnRepoLabel => 'Repozitoriy';

  @override
  String get learnNone =>
      'Hozircha darslar yoʻq. agnts repozitoriy uchun yangi narsa qiladigan oʻzgarishni yuborganda, dars shu yerda paydo boʻladi.';

  @override
  String get learnNoneNew => 'Hammasi oʻrganilgan: har bir dars belgilangan.';

  @override
  String get learnNoMatch => 'Qidiruvga mos dars yoʻq.';

  @override
  String learnFromTicket(String key) {
    return '$key dan';
  }

  @override
  String learnQuizCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta savol', one: '$n ta savol');
    return '$_temp0';
  }

  @override
  String get learnNewBadge => 'Yangi';

  @override
  String get learnLearned => 'Oʻrganilgan';

  @override
  String get learnMarkLearned => 'Oʻrganildi deb belgilash';

  @override
  String get learnMarkUnlearned => 'Belgini olib tashlash';

  @override
  String get learnMarkedLearned => 'Oʻrganildi deb belgilandi';

  @override
  String get learnBack => 'Darslarga qaytish';

  @override
  String get learnNotFound => 'Bunday dars yoʻq.';

  @override
  String get learnWhatTitle => 'Bu nima';

  @override
  String get learnWhyTitle => 'Nega bu oʻzgarishga kerak boʻldi';

  @override
  String get learnWhereTitle => 'Qayerga qarash kerak';

  @override
  String learnWhereSub(String repo, String key) {
    return '$key vaqtidagi $repo fayllari.';
  }

  @override
  String get learnQuizTitle => 'Oʻzingizni tekshiring';

  @override
  String get learnQuizSub => 'Toʻgʻriligini bilish uchun javobni tanlang.';

  @override
  String get learnCorrect => 'Toʻgʻri.';

  @override
  String get learnWrong => 'Unchalik emas.';

  @override
  String learnScore(String right, String total) {
    return '$total tadan $right tasi toʻgʻri';
  }

  @override
  String get learnRetry => 'Qaytadan';

  @override
  String get learnReadingTitle => 'Qoʻshimcha oʻqish';

  @override
  String get learnReadingNote => 'Bu havolalarni Claude taklif qilgan. Ularga tayanishdan oldin tekshiring.';

  @override
  String get learnCategory_pattern => 'Pattern';

  @override
  String get learnCategory_architecture => 'Arxitektura';

  @override
  String get learnCategory_algorithm => 'Algoritm';

  @override
  String get learnCategory_library => 'Kutubxona';

  @override
  String get learnCategory_language => 'Til';

  @override
  String get learnCategory_testing => 'Testlash';

  @override
  String get learnCategory_security => 'Xavfsizlik';

  @override
  String get learnCategory_performance => 'Unumdorlik';

  @override
  String get learnCategory_tooling => 'Vositalar';

  @override
  String get learnCategory_other => 'Boshqa';

  @override
  String get learnLevel_beginner => 'Boshlangʻich';

  @override
  String get learnLevel_intermediate => 'Oʻrta';

  @override
  String get learnLevel_advanced => 'Yuqori';

  @override
  String get learnTicketTitle => 'Bu oʻzgarishda nima yangi';

  @override
  String get learnTicketSub => 'Bu oʻzgarish repozitoriyga birinchi marta olib kirgan usullar.';

  @override
  String get learnTicketPending => 'agnts bu oʻzgarishda repozitoriyda avval boʻlmagan narsani qidirmoqda.';

  @override
  String get learnTicketNone => 'Yangi narsa yoʻq: oʻzgarish faqat repozitoriyda bor usullardan foydalangan.';

  @override
  String get learnTicketFailed => 'agnts bu oʻzgarishni oʻqib chiqa olmadi. Sababi logda.';

  @override
  String get learnTicketIdle => 'agnts bu oʻzgarishdan hali dars qidirmagan.';

  @override
  String get learnLearnNow => 'Yangisini topish';

  @override
  String get learnLearnAgain => 'Yana koʻrish';

  @override
  String get learnQueued => 'Navbatda: agnts bu oʻzgarishda yangi narsa qidiradi.';

  @override
  String get learnQueueTitle => 'Oʻrganish navbati';

  @override
  String get learnQueueSub => 'Yuborilgan tiketlar: agnts ulardan yangi usullarni qidiradi, tiketlarga ishchi kerak boʻlmaganda bittadan.';

  @override
  String get learnStatus_running => 'Oʻrganilmoqda';

  @override
  String get learnStatus_pending => 'Navbatda';

  @override
  String get learnStatus_failed => 'Xato';

  @override
  String get learnStatus_none => 'Hali oʻrganilmagan';

  @override
  String learnQueuePosition(String n) {
    return 'Navbatda $n-oʻrin';
  }

  @override
  String get learnQueueBtn => 'Oʻrganish';

  @override
  String get learnRetryBtn => 'Qaytadan';

  @override
  String learnQueueAll(String n) {
    return 'Hammasidan oʻrganish ($n)';
  }

  @override
  String learnQueuedAll(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta tiket navbatda', one: '$n ta tiket navbatda');
    return '$_temp0';
  }

  @override
  String learnReadTime(num n) {
    return '$n daqiqa oʻqish';
  }

  @override
  String get learnQueueLede =>
      'Yuborilgan tiketlar: agnts ulardan kodda avval ishlatilmagan usullarni qidiradi. Istalgan tugagan tiketni navbatga qoʻying yoki xato boʻlganini qaytadan ishga tushiring.';

  @override
  String get learnQueueEmpty => 'Hozir oʻrganadigan narsa yoʻq: barcha yuborilgan tiketlar oʻqilgan.';

  @override
  String get logsTitle => 'Loglar';

  @override
  String get logsLede =>
      'agnts har bir qadami sodir boʻlishi bilan yoziladi. Vaqt qayerga ketayotgani va ishlar nega toʻxtayotganini shu yerda koʻrasiz.';

  @override
  String get logsLive => 'Jonli';

  @override
  String get logsExportJson => 'JSON eksport';

  @override
  String get logsExportCsv => 'CSV eksport';

  @override
  String get logsRunsStarted => 'Boshlangan ishlar';

  @override
  String get logsRunsNote => 'Kod yozish sessiyalari, qayta urinishlar bilan';

  @override
  String get logsReached => 'Tekshiruvgacha yetgan';

  @override
  String logsReachedNote(String n, String total) {
    return '$total ta ishdan $n tasi testdan oʻtdi';
  }

  @override
  String get logsAvgTurns => 'Oʻrtacha qadamlar';

  @override
  String get logsAvgTurnsNote => 'Har bir tiket uchun';

  @override
  String get logsStops => 'Toʻxtash va pauzalar';

  @override
  String logsStopsNote(num n) {
    return 'Jami $n ta xato hodisasi';
  }

  @override
  String get logsPeriod => 'Soʻnggi 30 kun';

  @override
  String get logsWhereTime => 'Vaqt qayerga ketyapti';

  @override
  String get logsWhereTimeSub => 'Barcha tiket va vazifalar boʻyicha har bir bosqichdagi oʻrtacha vaqt';

  @override
  String get logsNoData => 'Maʼlumot yoʻq';

  @override
  String get logsLegendAgnts => 'agnts ishlayapti';

  @override
  String get logsLegendYou => 'Sizni kutish';

  @override
  String get logsEventsTitle => 'Hodisalar';

  @override
  String logsEventsSub(num n) {
    return '$n ta hodisa koʻrsatilgan, avval yangilari. Maʼlumotni koʻrish uchun qatorni tanlang.';
  }

  @override
  String get logsTabAll => 'Barchasi';

  @override
  String get logsTabState => 'Holat oʻzgarishlari';

  @override
  String get logsTabTool => 'Vosita chaqiruvlari';

  @override
  String get logsTabCommand => 'Buyruqlar';

  @override
  String get logsTabUser => 'Sizning harakatlaringiz';

  @override
  String get logsTabLimit => 'Tarif limitlari';

  @override
  String get logsTabProblems => 'Ogohlantirish va xatolar';

  @override
  String get logsKeyFilter => 'Tiket kaliti, masalan PAY-214';

  @override
  String get logsKeyFilterLabel => 'Tiket kaliti boʻyicha filtr';

  @override
  String get logsErrorsOnly => 'Faqat xatolar';

  @override
  String get logsClear => 'Filtrlarni tozalash';

  @override
  String get logsColTime => 'Vaqt';

  @override
  String get logsColTicket => 'Tiket';

  @override
  String get logsColStep => 'Bosqich';

  @override
  String get logsColType => 'Turi';

  @override
  String get logsColEvent => 'Hodisa';

  @override
  String get logsColDuration => 'Davomiyligi';

  @override
  String get logsNoEvents => 'Bu filtrlar boʻyicha hodisa yoʻq.';

  @override
  String get logsNoDetail => 'Bu hodisa uchun qoʻshimcha maʼlumot yoʻq.';

  @override
  String get logsShowMore => 'Yana koʻrsatish';

  @override
  String get logsTypeState => 'Holat';

  @override
  String get logsTypeTool => 'Vosita';

  @override
  String get logsTypeCommand => 'Buyruq';

  @override
  String get logsTypeYou => 'Siz';

  @override
  String get logsTypeLimit => 'Limit';

  @override
  String get logsTypeError => 'Xato';

  @override
  String get logsTypeEvent => 'Hodisa';

  @override
  String manalyticsTickets(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tiket', one: '$n tiket');
    return '$_temp0';
  }

  @override
  String manalyticsTurns(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n qadam', one: '$n qadam');
    return '$_temp0';
  }

  @override
  String manalyticsShareOfRuns(String n) {
    return 'Ishga tushirishlarning $n%';
  }

  @override
  String manalyticsReachedReview(String n) {
    return '$n% tekshiruvgacha yetdi';
  }

  @override
  String get manalyticsAbout => 'Analitika haqida';

  @override
  String manalyticsStopped(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Bu davrda $n ta toʻxtagan ish',
      one: 'Bu davrda $n ta toʻxtagan ish',
    );
    return '$_temp0';
  }

  @override
  String manalyticsDays(num n) {
    return '$n kun';
  }

  @override
  String manalyticsCompared(num n) {
    return 'Oʻzgarishlar oldingi $n kun bilan solishtiriladi. Yashil — yaxshiroq.';
  }

  @override
  String get mcpTitle => 'Claude chat (MCP)';

  @override
  String get mcpSub => 'agnts ni brauzer, kompyuter va telefondagi Claude orqali boshqaring';

  @override
  String get mcpUrl => 'Konnektor URL';

  @override
  String get mcpConnections => 'Ulangan Claude ilovalari';

  @override
  String get mcpStaticToken => 'Statik token';

  @override
  String get mcpSet => 'Oʻrnatilgan';

  @override
  String get mcpNotSet => 'Oʻrnatilmagan';

  @override
  String get mcpHowTo =>
      'Claude da Sozlamalar → Konnektorlar → Maxsus konnektor qoʻshish ni oching va URL ni qoʻying. Claude ulanishni tasdiqlash uchun sizni shu yerga yuboradi. Chatda har bir oʻzgarish (javoblar, tasdiqlash, rad etish, yangi vazifalar) avval tayyorlanadi va faqat siz tasdiqlagandan keyin bajariladi. Claude Code yoki Claude Desktop uchun statik tokenni Authorization: Bearer sarlavhasida yuborish mumkin.';

  @override
  String get mcpNewToken => 'Yangi token';

  @override
  String get mcpShownOnce => 'Hozir nusxa oling: u faqat bir marta koʻrsatiladi. Oldingi token endi ishlamaydi.';

  @override
  String get mcpCreate => 'Statik token yaratish';

  @override
  String get mcpRotate => 'Statik tokenni almashtirish';

  @override
  String get mcpRevoke => 'Hammasini uzish';

  @override
  String get mcpRevokeConfirm => 'Barcha Claude ilovalari uzilsinmi va statik token oʻchirilsinmi?';

  @override
  String get mcpRevoked => 'Barcha Claude ulanishlari oʻchirildi';

  @override
  String get mcpConsentTitle => 'Claude ni agnts ga ulash';

  @override
  String mcpConsentAsk(String client, String user) {
    return '$client agnts dan $user nomidan foydalanmoqchi.';
  }

  @override
  String get mcpConsentWhat =>
      'U tiketlar, loglar, limitlar va repozitoriylarni oʻqiy oladi hamda amallarni tayyorlaydi. Har bir amalni chatda tasdiqlamaguningizcha hech narsa oʻzgarmaydi. Deploy, sozlamalar va integratsiyalar unga ochiq emas.';

  @override
  String mcpConsentRedirect(String host) {
    return 'Siz $host ga qaytasiz.';
  }

  @override
  String get mcpAllow => 'Ruxsat berish';

  @override
  String get mcpDeny => 'Rad etish';

  @override
  String get mdetailApprove => 'Tasdiqlash';

  @override
  String get mdetailWorking => 'agnts ishlayapti. Sizni kutganda bildirishnoma olasiz.';

  @override
  String get mdetailCopyPr => 'Pull request havolasini nusxalash';

  @override
  String get mdetailCopied => 'Havola nusxalandi';

  @override
  String get mdetailFactTime => 'Vaqt';

  @override
  String mhomeRunningNote(String parallel, String queued) {
    return 'Bir vaqtda: $parallel, navbatda: $queued';
  }

  @override
  String mhomeWaiting(String time) {
    return '$time kutmoqda';
  }

  @override
  String get mhomeActAnswers => 'agnts savollariga javob bering';

  @override
  String get mhomeActReview => 'Oʻzgarishlarni koʻrib chiqing';

  @override
  String get mhomeActStopped => 'Toʻxtadi. agnts nimani sinashini ayting';

  @override
  String get mhomeActResume => 'Tayyor boʻlganingizda davom ettiring';

  @override
  String get mhomeActStart => 'Navbatda turibdi. Boshlash uchun bosing';

  @override
  String get mhomeLiveFallback => 'Ishlamoqda…';

  @override
  String get mhomeSearchEmpty => 'Qidiruvingiz boʻyicha tiketlar topilmadi.';

  @override
  String mmoreAgo(String time) {
    return '$time oldin';
  }

  @override
  String get mmoreJustNow => 'hozirgina';

  @override
  String get mmoreLangPhone => 'Telefon tili';

  @override
  String mmoreSignedInTo(String server) {
    return '$server serveriga kirilgan';
  }

  @override
  String get mmorePipelineRuns => 'Pipeline ishga tushirishlari';

  @override
  String get mmoreLoginLede =>
      'Savollarga javob berish, oʻzgarishlarni koʻrib chiqish va ishlarni kuzatish uchun agnts serveringizga kiring.';

  @override
  String get mobileServer => 'Server manzili';

  @override
  String get mobileServerHint => 'https://agnts.example.com';

  @override
  String get mobileServerInvalid => 'agnts serveringizning https manzilini kiriting.';

  @override
  String get mobileHome => 'Bosh sahifa';

  @override
  String get mobileActivity => 'Faollik';

  @override
  String get mobileMore => 'Yana';

  @override
  String mobileGreeting(String name) {
    return 'Salom, $name';
  }

  @override
  String get mobileNeedsYou => 'Sizni kutmoqda';

  @override
  String get mobileRunningNow => 'Hozir ishlamoqda';

  @override
  String get mobileInQueue => 'Navbatda';

  @override
  String get mobileNothingWaiting => 'Sizni hech narsa kutmayapti.';

  @override
  String get mobileNoRuns => 'Hozircha ishlar yoʻq.';

  @override
  String get mobileLiveRuns => 'Joriy ishlar';

  @override
  String mobileTurnsOf(String turns, String max) {
    return '$turns / $max qadam';
  }

  @override
  String mobileWaitingFor(String time) {
    return '$time kutmoqda';
  }

  @override
  String get mobileUsage => 'Tarif limitlari';

  @override
  String get mobileSession => 'Joriy sessiya';

  @override
  String get mobileWeek => 'Shu hafta';

  @override
  String get mobileRefresh => 'Yangilash';

  @override
  String get mobilePaused => 'Limit yangilanguncha yangi ishlar toʻxtatilgan.';

  @override
  String get mobileAppearance => 'Koʻrinish';

  @override
  String get mobileTheme => 'Mavzu';

  @override
  String get mobileThemeSystem => 'Tizim';

  @override
  String get mobileThemeLight => 'Kunduz';

  @override
  String get mobileThemeDark => 'Tun';

  @override
  String get mobileLanguage => 'Til';

  @override
  String get mobileDefaultModels => 'Standart modellar';

  @override
  String get mobilePush => 'Push bildirishnomalar';

  @override
  String get mobilePushOn => 'Shu telefonga yuborish';

  @override
  String get mobilePushNeeds => 'Siz kerak boʻlganda';

  @override
  String get mobilePushStopped => 'Ish toʻxtaganda';

  @override
  String get mobilePushDone => 'Oʻzgarishlar yuborilganda';

  @override
  String get mobilePushUnavailable => 'Serverda push sozlanmagan.';

  @override
  String get mobileIntegrations => 'Integratsiyalar';

  @override
  String get mobileRepositories => 'Repozitoriylar';

  @override
  String get mobileConnected => 'Ulangan';

  @override
  String get mobileNotConnected => 'Ulanmagan';

  @override
  String get mobileSaved => 'Saqlandi';

  @override
  String get mobileSignOut => 'Chiqish';

  @override
  String get mobileNewTask => 'Yangi vazifa';

  @override
  String get mobileTaskTitle => 'Nomi';

  @override
  String get mobileTaskDescription => 'Nima qilish kerak';

  @override
  String get mobileTaskRepo => 'Repozitoriy';

  @override
  String get mobileTaskPriority => 'Muhimlik';

  @override
  String get mobilePriorityLow => 'Past';

  @override
  String get mobilePriorityMedium => 'Oʻrta';

  @override
  String get mobilePriorityHigh => 'Yuqori';

  @override
  String get mobileAfterApprove => 'Tasdiqlagandan keyin';

  @override
  String get mobileAfterMain => 'main ga yuborish';

  @override
  String get mobileAfterPr => 'Pull request ochish';

  @override
  String get mobileStart => 'Qanday boshlash';

  @override
  String get mobileStartAsk => 'Avval savol berish';

  @override
  String get mobileStartCode => 'Darhol kod yozish';

  @override
  String get mobileStartQueue => 'Navbatda qoldirish';

  @override
  String get mobileCreate => 'Yaratish';

  @override
  String get mobileNoSideRepos => 'Avval admin panelda shaxsiy loyiha repozitoriysini qoʻshing.';

  @override
  String get mobileNoTasks => 'Hozircha vazifalar yoʻq.';

  @override
  String get mobileNoEvents => 'Hozircha hech narsa yoʻq.';

  @override
  String get mobileFilterAll => 'Barchasi';

  @override
  String get mobileFilterProblems => 'Muammolar';

  @override
  String get mobileFilterYou => 'Sizning harakatlaringiz';

  @override
  String get mobileAnswer => 'Javob berish';

  @override
  String get mobileReview => 'Tekshirish';

  @override
  String get mobileConfirm => 'Tasdiqlash';

  @override
  String get mobileCancel => 'Bekor qilish';

  @override
  String get mobileRetry => 'Qayta urinish';

  @override
  String get mobileStop => 'Toʻxtatish';

  @override
  String get mobileOffline => 'Serverga ulanib boʻlmadi. Qayta urinish uchun torting.';

  @override
  String get mobileOpenInBrowser => 'Brauzerda ochish';

  @override
  String mobileVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String get mobileBranches => 'Branchlar';

  @override
  String get mobileCommits => 'Kommitlar';

  @override
  String get mobilePipelines => 'Pipelinelar';

  @override
  String get mobileDeploy => 'Deploy qilish';

  @override
  String mobileDeployConfirm(String stage) {
    return '$stage ishga tushirilsinmi? Bu ishchi muhitga deploy qiladi.';
  }

  @override
  String get mobileDeployStarted => 'Deploy boshlandi';

  @override
  String mobileAheadBehind(String ahead, String behind) {
    return '↑$ahead ↓$behind';
  }

  @override
  String get mobileCiOk => 'Oʻtdi';

  @override
  String get mobileCiFail => 'Yiqildi';

  @override
  String get mobileCiRun => 'Bajarilmoqda';

  @override
  String get mobileCiWaiting => 'Kutmoqda';

  @override
  String get mobileCiManual => 'Sizni kutmoqda';

  @override
  String get mobileCiNone => 'Pipeline yoʻq';

  @override
  String get mobileGitHostError => 'Git xosting xato qaytardi. Integratsiyani tekshiring.';

  @override
  String get mobileLastDays => 'Oxirgi 7 kun';

  @override
  String get mobilePushed => 'Yuborildi';

  @override
  String get mobileFirstTry => 'Birinchi urinishda';

  @override
  String get mobileWaitingAvg => 'Sizni kutish';

  @override
  String mobileMinutes(String n) {
    return '$n daq';
  }

  @override
  String get mpreviewTitle => 'agnts oldindan koʻrishi';

  @override
  String get mpreviewSub =>
      'Ushbu oʻzgarish bilan ilovaning skrinshotlari. Sizning tekshiruvingiz yonidagi maslahat: u hech qachon tasdiqlashni toʻsmaydi.';

  @override
  String get mpreviewPending => 'Navbatda: ishchi boʻshashi bilan agnts ilovani ishga tushirib, skrinshotlar oladi.';

  @override
  String get mpreviewRunning => 'agnts ilovani ishga tushirib, skrinshotlar olmoqda…';

  @override
  String get mpreviewFailed => 'Oldindan koʻrish bajarilmadi. Ilovani oʻzingiz tekshiring yoki qayta ishga tushiring.';

  @override
  String get mpreviewAppFailed => 'Ilova ishga tushmadi, shuning uchun skrinshotlar yoʻq. Uning logining oxiri:';

  @override
  String mpreviewStale(String n) {
    return 'Bu $n-tahrir skrinshotlari; shundan beri ish oʻzgargan.';
  }

  @override
  String get mpreviewRun => 'Skrinshotlar olish';

  @override
  String get mpreviewRunAgain => 'Qayta ishga tushirish';

  @override
  String get mpreviewCompare => 'Asosiy tarmoq bilan solishtirish';

  @override
  String get mpreviewCompareHelp => 'Xuddi shu skrinshotlarni ushbu oʻzgarishsiz ham oladi.';

  @override
  String get mpreviewStatus_ok => 'Tayyor';

  @override
  String get mpreviewStatus_partial => 'Qisman';

  @override
  String get mpreviewStatus_failed => 'Ishga tushmadi';

  @override
  String mpreviewModel(String model) {
    return '$model tekshirdi';
  }

  @override
  String mpreviewIssues(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta muammo', zero: 'Muammo yoʻq');
    return '$_temp0';
  }

  @override
  String get mpreviewNoIssues => 'agnts vizual muammo koʻrmadi.';

  @override
  String get mpreviewSev_high => 'Yuqori';

  @override
  String get mpreviewSev_medium => 'Oʻrta';

  @override
  String get mpreviewSev_low => 'Past';

  @override
  String get mpreviewShowShot => 'Skrinshotni koʻrsatish';

  @override
  String get mpreviewDesktop => 'Kompyuter';

  @override
  String get mpreviewPhone => 'Telefon';

  @override
  String get mpreviewBefore => 'Oldin';

  @override
  String get mpreviewAfter => 'Keyin';

  @override
  String get mpreviewNoShots => 'Bu kenglik uchun skrinshotlar yoʻq.';

  @override
  String mpreviewConsoleErrors(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Konsolda $count ta xato');
    return '$_temp0';
  }

  @override
  String get mpreviewLoadFailed => 'Skrinshotni yuklab boʻlmadi.';

  @override
  String get mpreviewAddToFeedback => 'Fikrga qoʻshish';

  @override
  String get mpreviewAdded => 'Fikrda';

  @override
  String get mpreviewAttached => 'Fikr bilan yuboriladigan skrinshotlar';

  @override
  String mpreviewAttachLimit(String max) {
    return 'Fikr bilan koʻpi bilan $max ta skrinshot yuborish mumkin.';
  }

  @override
  String get mpreviewRemove => 'Olib tashlash';

  @override
  String get mpreviewSettingsModel => 'Oldindan koʻrish';

  @override
  String get mpreviewSettingsModelHelp => 'Ishlayotgan ilova skrinshotlarini koʻrib chiqadi';

  @override
  String get mpreviewNotify => 'Oldindan koʻrish skrinshotlari tayyor';

  @override
  String get mtasksActAnswers => 'agnts savollariga javob bering';

  @override
  String get mtasksActReview => 'Oʻzgarishlarni koʻrib chiqing';

  @override
  String get mtasksActFailed => 'Toʻxtadi. agnts nimani sinab koʻrishini ayting';

  @override
  String get mtasksActResume => 'Tayyor boʻlganingizda davom ettiring';

  @override
  String get mtasksActAnalyze => 'Tahlil qilish uchun bosing';

  @override
  String get mtasksActHeld => 'Navbatda turibdi. Boshlash uchun bosing';

  @override
  String get mtasksYesterday => 'Kecha';

  @override
  String get navOverview => 'Umumiy';

  @override
  String get navDashboard => 'Boshqaruv paneli';

  @override
  String get navAnalytics => 'Analitika';

  @override
  String get navTickets => 'Tiketlar';

  @override
  String get navNeeds => 'Sizni kutmoqda';

  @override
  String get navRunning => 'Bajarilmoqda';

  @override
  String get navQueue => 'Navbatda';

  @override
  String get navDone => 'Yakunlangan';

  @override
  String get navAll => 'Barcha tiketlar';

  @override
  String get navSideProjects => 'Shaxsiy loyihalar';

  @override
  String get navTasks => 'Vazifalar';

  @override
  String get navMonitor => 'Monitoring';

  @override
  String get navLogs => 'Loglar';

  @override
  String get navUsage => 'Tarif limitlari';

  @override
  String get navSetup => 'Sozlash';

  @override
  String get navIntegrations => 'Integratsiyalar';

  @override
  String get navRepos => 'Repozitoriylar';

  @override
  String get navSettings => 'Sozlamalar';

  @override
  String get navSearch => 'Tiket va vazifalarni qidirish';

  @override
  String get navSyncJira => 'Jira bilan sinxronlash';

  @override
  String navSynced(String found, String created) {
    return 'Jira sinxronlandi: $found ta ochiq, $created ta yangi';
  }

  @override
  String get navSession => 'Joriy sessiya';

  @override
  String get navWeek => 'Shu hafta';

  @override
  String get navDayMode => 'Kunduzgi rejimga oʻtish';

  @override
  String get navNightMode => 'Tungi rejimga oʻtish';

  @override
  String get navCollapseSidebar => 'Yon panelni yigʻish';

  @override
  String get navExpandSidebar => 'Yon panelni yoyish';

  @override
  String get navLanguage => 'Til';

  @override
  String get navGuide => 'Sahifa qanday ishlaydi';

  @override
  String get navClose => 'Yopish';

  @override
  String get navMain => 'Asosiy menyu';

  @override
  String get navLive => 'Jonli';

  @override
  String get navOffline => 'Qayta ulanmoqda…';

  @override
  String navResetsIn(String time) {
    return '$time dan keyin yangilanadi';
  }

  @override
  String get navResettingNow => 'Hozir yangilanmoqda';

  @override
  String get navUsageUnknown => 'Limitlar nomaʼlum';

  @override
  String get navBack => 'Orqaga';

  @override
  String get navLedeNeeds => 'Javobingiz yoki tekshiruvingizni kutayotgan tiketlar hamda toʻxtagan ishga tushirishlar.';

  @override
  String get navLedeRunning => 'agnts hozir ishlayotgan tiketlar.';

  @override
  String get navLedeQueue => 'agnts belgisi bor, hali tahlil qilinmagan tiketlar.';

  @override
  String get navLedeDone => 'Yuborilgan yoki rad etilgan tiketlar.';

  @override
  String get navLedeAll => 'agnts Jira va Plane\'dan olgan barcha tiketlar.';

  @override
  String get navKnowledge => 'Bilim';

  @override
  String get navLearn => 'Oʻrganish';

  @override
  String get navLearnQueue => 'Oʻrganish navbati';

  @override
  String get navRules => 'Qoidalar';

  @override
  String get navSyncPlane => 'Plane\'ni sinxronlash';

  @override
  String navSyncedPlane(String found, String created) {
    return 'Plane sinxronlandi: $found ochiq, $created yangi';
  }

  @override
  String get previewTab => 'Oldindan koʻrish';

  @override
  String get previewTitle => 'Ilova skrinshotlari';

  @override
  String get previewSub =>
      'agnts ilovani shu oʻzgarish bilan ishga tushirib, skrinshotlar oldi. Bu maslahat: tasdiqlashni hech qachon toʻsmaydi.';

  @override
  String get previewPending => 'Navbatda: ishchi boʻshashi bilan agnts skrinshotlar oladi.';

  @override
  String get previewRunning => 'agnts ilovani ishga tushirib, skrinshotlar olmoqda…';

  @override
  String get previewFailed => 'Oldindan koʻrish bajarilmadi. Ishga tushirish jurnalini koʻring yoki qayta ishga tushiring.';

  @override
  String previewStale(String n) {
    return 'Bu $n-tahrir skrinshotlari; shundan beri oʻzgarish yangilangan.';
  }

  @override
  String get previewNone => 'Hali skrinshot yoʻq.';

  @override
  String get previewStatus_ok => 'Olindi';

  @override
  String get previewStatus_partial => 'Qisman olindi';

  @override
  String get previewStatus_failed => 'Ilova ishga tushmadi';

  @override
  String previewModel(num n, String model) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta skrinshot', zero: 'Skrinshot yoʻq');
    return '$_temp0, $model oldi';
  }

  @override
  String get previewWithBase => 'solishtirish uchun asosiy tarmoq bilan';

  @override
  String get previewSev_high => 'Yuqori';

  @override
  String get previewSev_medium => 'Oʻrta';

  @override
  String get previewSev_low => 'Past';

  @override
  String get previewNoIssues => 'agnts vizual muammo koʻrmadi.';

  @override
  String get previewViewport => 'Ekran oʻlchami';

  @override
  String get previewVp_all => 'Hammasi';

  @override
  String get previewVp_desktop => 'Kompyuter';

  @override
  String get previewVp_phone => 'Telefon';

  @override
  String get previewMode => 'Koʻrsatish';

  @override
  String get previewMode_after => 'Keyin';

  @override
  String get previewMode_before => 'Oldin';

  @override
  String get previewMode_side => 'Yonma-yon';

  @override
  String get previewMode_slider => 'Surgich';

  @override
  String get previewSlider => 'Oldin va keyinni solishtirish uchun suring';

  @override
  String previewConsoleErrors(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Konsolda $count ta xato');
    return '$_temp0';
  }

  @override
  String get previewNoBefore => '“Oldin” skrinshoti yoʻq: sahifa yangi yoki asosiy tarmoqda ochilmadi.';

  @override
  String get previewAddToFeedback => 'Fikrga qoʻshish';

  @override
  String get previewAdded => 'Fikrda';

  @override
  String get previewCompare => 'Asosiy tarmoq bilan solishtirish';

  @override
  String get previewRun => 'Skrinshot olish';

  @override
  String get previewRunAgain => 'Qayta skrinshot olish';

  @override
  String previewTooMany(String n) {
    return 'Fikrga koʻpi bilan $n ta skrinshot biriktirish mumkin.';
  }

  @override
  String get previewAttached => 'Fikr bilan yuboriladigan skrinshotlar';

  @override
  String previewDetach(String name) {
    return '$name ni olib tashlash';
  }

  @override
  String get previewRepoTitle => 'Oldindan koʻrish';

  @override
  String get previewRepoHelp =>
      'Siz koʻrib chiqishdan oldin interfeys oʻzgarishlarining skrinshotlarini olish uchun agnts ilovani qanday ishga tushiradi. Oldindan koʻrishni oʻchirish uchun buyruqni boʻsh qoldiring.';

  @override
  String get previewRepoCommand => 'Ishga tushirish buyrugʻi';

  @override
  String get previewRepoCommandHelp =>
      'Ishga tushirish konteynerida /workspace ichida bajariladi: oʻrnatish, yigʻish va dev-serverni ishga tushirish. U quyidagi portni tinglashi kerak.';

  @override
  String get previewRepoPort => 'Port';

  @override
  String get previewRepoReady => 'Tayyorlik yoʻli';

  @override
  String get previewRepoUiPaths => 'Interfeys fayllari';

  @override
  String get previewRepoUiPathsHelp =>
      'Har qatorda bitta glob, repozitoriy ildiziga nisbatan. Shunday faylga tegadigan oʻzgarish skrinshot oladi. Boʻsh: har qanday oʻzgarish.';

  @override
  String get previewRepoRoutes => 'Har doim olish';

  @override
  String get previewRepoRoutesHelp => 'agnts diffdan tanlaganlardan tashqari har safar olinadigan yoʻllar, har qatorda bittadan.';

  @override
  String get previewRepoLogin => 'Kirish';

  @override
  String get previewRepoLoginPh => 'demo@acme.test sifatida kiring; parol PREVIEW_PASSWORD da.';

  @override
  String get previewRepoLoginHelp =>
      'Ilovada kirish boʻlsa, agnts undan qanday oʻtishini yozing. Maxfiy qiymatlarni oʻzgaruvchi nomi bilan ayting.';

  @override
  String get previewRepoEnv => 'Muhit oʻzgaruvchilari';

  @override
  String previewRepoEnvSet(String names) {
    return 'Berilgan: $names. Qiymatlar hech qachon koʻrsatilmaydi.';
  }

  @override
  String get previewRepoEnvReplace => 'Almashtirish';

  @override
  String get previewRepoEnvClear => 'Tozalash';

  @override
  String get previewRepoEnvCleared => 'Saqlaganingizda muhit oʻzgaruvchilari oʻchiriladi.';

  @override
  String get previewRepoEnvHelp =>
      'Ilovaga beriladigan KEY=value qatorlari, masalan staging API manzili. Shifrlangan holda saqlanadi va qayta koʻrsatilmaydi. Faqat test hisob maʼlumotlaridan foydalaning: ularni ilova ham, agnts ham oʻqiy oladi. Ilova murojaat qiladigan hostlarni Sozlamalar → Oldindan koʻrish → Ruxsat etilgan hostlarga qoʻshing.';

  @override
  String get previewSettingsTitle => 'Oldindan koʻrish';

  @override
  String get previewSettingsSub => 'Oldindan koʻrish buyrugʻi bor repozitoriylar uchun interfeys oʻzgarishlari skrinshotlari.';

  @override
  String get previewAutoPreview => 'Har bir interfeys oʻzgarishini suratga olish';

  @override
  String get previewAutoPreviewHelp =>
      'Oʻzgarish sizni kutayotganda agnts ilovani ishga tushiradi, u tegadigan sahifalarni ochadi va skrinshotlarni diff yonida koʻrsatadi. Tasdiqlashni hech qachon toʻsmaydi.';

  @override
  String get previewVisualCheck => 'Kod yozish jarayoniga ilovani koʻrishga ruxsat berish';

  @override
  String get previewVisualCheckHelp =>
      'Claude tugatishdan oldin ilovani ishga tushirib, oʻzgartirgan sahifalarini koʻrishi va buzilgan joylarni tuzatishi mumkin. Bir necha qoʻshimcha qadamga tushadi.';

  @override
  String get previewModel_ => 'Oldindan koʻrish modeli';

  @override
  String get previewModelHelp => 'Sahifalarni tanlaydi va skrinshotlarni baholaydi.';

  @override
  String get previewEgress => 'Ruxsat etilgan hostlar';

  @override
  String get previewEgressHelp =>
      'Ichki roʻyxatdan (Claude, git xostinglar, paket reyestrlari) tashqari ishga tushirish konteynerlari murojaat qila oladigan hostlar, masalan oldindan koʻrishda ilova murojaat qiladigan staging API. .example.com uning subdomenlariga ruxsat beradi.';

  @override
  String get previewNotify => 'Oldindan koʻrish skrinshotlari tayyor boʻlganda';

  @override
  String get previewNotifyPhotos => 'Telefon skrinshotlarini Telegramga yuborish';

  @override
  String get previewNotifyPhotosHelp => 'Telegram xabariga toʻrttagacha skrinshot qoʻshiladi.';

  @override
  String get relationsTab => 'Tartib';

  @override
  String get relationsTitle => 'Tartib va toʻqnashuvlar';

  @override
  String get relationsSub =>
      'agnts bir vaqtda bir nechta tiket ustida kod yozadi va ularni birma-bir birlashtiradi. Tiket oʻzi bogʻliq tiketlar birlashtirilishini kutadi, bir xil kodni oʻzgartiradigan ikki tiket esa hech qachon bir vaqtda yozilmaydi.';

  @override
  String get relationsWaitingTitle => 'Boshqa tiketlarni kutmoqda';

  @override
  String get relationsWaitingSub => 'Ular birlashtirilishi yoki rad etilishi bilan kod yozish oʻzi boshlanadi.';

  @override
  String get relationsWaitingBadge => 'Kutmoqda';

  @override
  String get relationsWaitsFor => 'Kutadi';

  @override
  String get relationsWaitedBy => 'Ushlab turadi';

  @override
  String get relationsConflicts => 'Bir vaqtda emas';

  @override
  String get relationsProposedTitle => 'agnts taklifi';

  @override
  String get relationsProposedSub =>
      'agnts bularga ishonchi komil emas. Qabul qilinganlari navbatni boshqaradi; rad etilganlari boshqa taklif qilinmaydi.';

  @override
  String get relationsActiveTitle => 'Amalda';

  @override
  String get relationsEmpty => 'Bogʻliqlik yoʻq. Joy boʻshashi bilan tiket ishga tushadi.';

  @override
  String get relationsAccept => 'Qabul qilish';

  @override
  String get relationsDismiss => 'Rad etish';

  @override
  String get relationsRemove => 'Baribir ishga tushirish';

  @override
  String relationsRemoveConfirm(String key, String other) {
    return '$key va $other endi bir-birini kutmaydi. Davom etasizmi?';
  }

  @override
  String relationsConfidence(String pct) {
    return '$pct% ishonch';
  }

  @override
  String get relationsLanded => 'birlashtirilgan';

  @override
  String get relationsSource_jira => 'Jira bogʻlanishi';

  @override
  String get relationsSource_user => 'Siz qoʻshgansiz';

  @override
  String get relationsSource_agnts => 'agnts';

  @override
  String get relationsSource_rule => 'Taxminiy kesishma';

  @override
  String get relationsSource_git => 'Difflarda topilgan';

  @override
  String relationsBasis_files(String files) {
    return 'Ikkalasi ham $files ni oʻzgartiradi';
  }

  @override
  String get relationsBasis_migrations => 'Ikkalasi ham maʼlumotlar bazasi migratsiyasini qoʻshadi';

  @override
  String get relationsBasis_lockfile => 'Ikkalasi ham bogʻliqliklar lock-fayllarini oʻzgartiradi';

  @override
  String get relationsBasis_codegen => 'Ikkalasi ham API spetsifikatsiyasi yoki generatsiya qilingan kodni oʻzgartiradi';

  @override
  String get relationsBasis_i18n => 'Ikkalasi ham tarjima fayllarini oʻzgartiradi';

  @override
  String relationsBasis_diff(String files) {
    return 'Tayyor oʻzgarishlar $files da bir xil qatorlarga tegadi';
  }

  @override
  String get relationsConfirmed => 'Difflar tasdiqladi';

  @override
  String relationsDismissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta rad etilgan');
    return '$_temp0';
  }

  @override
  String get relationsAddTitle => 'Bogʻliqlik qoʻshish';

  @override
  String get relationsAddType => 'Bogʻliqlik';

  @override
  String get relationsAddOther => 'Tiket kaliti';

  @override
  String get relationsAddOtherPh => 'PAY-12';

  @override
  String get relationsAdd => 'Qoʻshish';

  @override
  String get relationsAddHint =>
      'Kutadi: boshqasi birlashtirilgach, bu tiket kod yozishni boshlaydi. Bir vaqtda emas: ikkinchi boshlagani birinchisi birlashtirilguncha kutadi.';

  @override
  String get relationsAdded => 'Bogʻliqlik qoʻshildi';

  @override
  String get relationsFootprintTitle => 'Taxminiy iz';

  @override
  String get relationsFootprintSub =>
      'Tahlilga koʻra bu tiket nimani oʻzgartiradi. agnts toʻqnashadigan tiketlarni ajratish uchun izlarni solishtiradi.';

  @override
  String get relationsFootprintFiles => 'Fayllar';

  @override
  String get relationsFootprintProvides => 'Qoʻshadi';

  @override
  String get relationsFootprintConsumes => 'Kerak';

  @override
  String get relationsFootprintMigrations => 'Maʼlumotlar bazasi migratsiyasini qoʻshadi';

  @override
  String get relationsMarkMerged => 'Birlashtirilgan deb belgilash';

  @override
  String get relationsMarkMergedHint =>
      'Birlashtirish webhooki yoʻqmi? Uni kutayotgan tiketlar boshlashi uchun pull requestni birlashtirilgan deb belgilang.';

  @override
  String get relationsSource_plane => 'Plane bogʻlanishi';

  @override
  String get repoBack => 'Repozitoriylarga qaytish';

  @override
  String get repoNotFound => 'Bunday repozitoriy yoʻq.';

  @override
  String get repoEdit => 'Sozlamalarni tahrirlash';

  @override
  String get repoBranches => 'Branchlar';

  @override
  String get repoCommits => 'Commitlar';

  @override
  String get repoPipelines => 'Pipelinelar';

  @override
  String get repoMembers => 'Aʼzolar';

  @override
  String get repoMembersSub_github =>
      'GitHubʼdagi hamkorlar. Koʻrib chiqishni tasdiqlaganingizda pull requestni ularga biriktirish mumkin.';

  @override
  String get repoMembersSub_gitlab =>
      'GitLabʼdagi loyiha aʼzolari, guruhlardagilar ham. Koʻrib chiqishni tasdiqlaganingizda merge requestni ularga biriktirish mumkin.';

  @override
  String get repoMembersSearch => 'Aʼzolarni qidirish';

  @override
  String get repoMembersNone => 'Aʼzolar topilmadi. Token ularni koʻrishga ruxsat bermasligi mumkin.';

  @override
  String repoBranchesSub(String branch) {
    return 'agnts har bir tiket uchun alohida branchda ishlaydi va hech qachon $branch ga commit qilmaydi.';
  }

  @override
  String repoArchivedBanner(String time) {
    return '$time arxivlangan. Siz tiklamaguningizcha agnts bu repozitoriy uchun yangi tiketlar va vazifalar olmaydi.';
  }

  @override
  String get repoSrcLabel => 'Qayerda';

  @override
  String get repoSrcOrigin => 'Origin';

  @override
  String get repoSrcLocal => 'Lokal';

  @override
  String repoSrcLocalN(String n) {
    return 'Lokal ($n)';
  }

  @override
  String repoLocalSub(String branch) {
    return 'agnts serveringizdagi oʻz klonlaridagi branchlar. agnts avval shu yerga commit qiladi va faqat siz tasdiqlagandan keyin yuboradi; $branch ga hech qachon commit qilmaydi.';
  }

  @override
  String get repoColPush => 'Originda';

  @override
  String get repoPush_local => 'Yuborilmagan';

  @override
  String get repoPush_pushed => 'Yuborilgan';

  @override
  String repoPush_unpushed(num n) {
    return '$n ta commit yuborilmagan';
  }

  @override
  String get repoPush_differs => 'Origin oʻzgargan';

  @override
  String get repoPush_local_help => 'Faqat serverda. Koʻrib chiqishni tasdiqlaganingizda agnts uni yuboradi.';

  @override
  String get repoPush_pushed_help => 'Originda xuddi shu commit bor.';

  @override
  String get repoPush_unpushed_help => 'Originda branch bor, lekin oxirgi commitlarsiz.';

  @override
  String get repoPush_differs_help => 'Kimdir bu branchga agnts nusxasida yoʻq commitlarni yubordi.';

  @override
  String get repoLocalNone => 'Hozircha lokal branchlar yoʻq. agnts tiket ustida ishlashni boshlaganda branch yaratadi.';

  @override
  String get repoCommitsSub => 'Asosiy branchdagi soʻnggi commitlar, yangilari yuqorida.';

  @override
  String get repoLoadMore => 'Yana yuklash';

  @override
  String get repoMoreError => 'Qoʻshimcha yuklab boʻlmadi.';

  @override
  String repoCommitsEnd(num n) {
    return 'Barcha $n ta commit koʻrsatildi';
  }

  @override
  String get repoPipelinesSub => 'Git xostingidagi build, test va deploy ishlari.';

  @override
  String repoPipelinesEnd(num n) {
    return 'Barcha $n ta ishga tushirish koʻrsatildi';
  }

  @override
  String get repoFilterAll => 'Barchasi';

  @override
  String get repoFilterOthers => 'Boshqalar';

  @override
  String get repoColBranch => 'Branch';

  @override
  String get repoColCommit => 'Soʻnggi commit';

  @override
  String get repoColAuthor => 'Muallif';

  @override
  String get repoColAheadBehind => 'Oldinda / ortda';

  @override
  String get repoColChecks => 'Tekshiruvlar';

  @override
  String get repoColUpdated => 'Yangilangan';

  @override
  String get repoDefault => 'Asosiy';

  @override
  String get repoNone => 'Hozircha hech narsa yoʻq.';

  @override
  String get repoCi_ok => 'Oʻtdi';

  @override
  String get repoCi_fail => 'Yiqildi';

  @override
  String get repoCi_run => 'Bajarilmoqda';

  @override
  String get repoCi_pending => 'Kutmoqda';

  @override
  String get repoCi_manual => 'Sizni kutmoqda';

  @override
  String get repoCi_skip => 'Oʻtkazib yuborildi';

  @override
  String get repoCi_canceled => 'Bekor qilindi';

  @override
  String get repoCi_none => 'Pipeline yoʻq';

  @override
  String get repoKpiBranches => 'Branchlar';

  @override
  String repoKpiBranchesNote(String n) {
    return '$n tasi agnts dan';
  }

  @override
  String get repoKpiCommits => 'Shu haftadagi commitlar';

  @override
  String repoKpiCommitsNote(String n) {
    return '$n tasini agnts yozgan';
  }

  @override
  String get repoKpiPipelines => 'Muvaffaqiyatli pipelinelar';

  @override
  String repoKpiPipelinesNote(String n) {
    return 'Soʻnggi $n ta tugagan ish';
  }

  @override
  String get repoKpiProd => 'Production';

  @override
  String repoDeployedAgo(String time) {
    return 'Joylandi $time';
  }

  @override
  String get repoNotDeployed => 'Hali joylanmagan';

  @override
  String get repoDeployed => 'Joylangan';

  @override
  String get repoEmpty => 'Boʻsh';

  @override
  String get repoCommit => 'Commit';

  @override
  String get repoOpen => 'Ochish';

  @override
  String get repoNoEnvironments => 'Git xostingida deploy muhitlari yoʻq.';

  @override
  String get repoDeployHelp =>
      'agnts tiket tekshiruvingizga kelishidan oldin tekshiruvlarni kutadi. Deploy har doim sizning qaroringiz va Claude chatidan mavjud emas.';

  @override
  String repoDeployBranch(String branch) {
    return '$branch ni joylash';
  }

  @override
  String get repoDeploy => 'Joylash';

  @override
  String repoDeployConfirm(String stage, String sha) {
    return '$sha uchun $stage ishga tushirilsinmi?';
  }

  @override
  String repoDeployWorkflowConfirm(String workflow, String branch) {
    return '$branch da $workflow ishga tushirilsinmi?';
  }

  @override
  String get repoDeployStarted => 'Deploy boshlandi';

  @override
  String get repoStage => 'Bosqich';

  @override
  String get repoStatus => 'Holat';

  @override
  String get repoDuration => 'Davomiyligi';

  @override
  String get repoOpenRun => 'Git xostingida ochish';

  @override
  String get reposTitle => 'Repozitoriylar';

  @override
  String get reposLede =>
      'agnts ishlashi mumkin boʻlgan kod. Har bir ishga tushirish repozitoriyni serveringizdagi yangi konteynerga klonlaydi va biror narsa tekshiruvingizga yetguncha shu tekshiruvlarni bajaradi.';

  @override
  String get reposAdd => 'Repozitoriy qoʻshish';

  @override
  String get reposViewLabel => 'Koʻrsatish';

  @override
  String reposViewActive(String n) {
    return 'Faol ($n)';
  }

  @override
  String reposViewArchived(String n) {
    return 'Arxiv ($n)';
  }

  @override
  String get reposArchivedSub =>
      'Arxivdagi repozitoriylar tarixini saqlaydi, lekin yangi tiketlar va vazifalar olmaydi. Qayta ishlash uchun uni tiklang.';

  @override
  String get reposArchive => 'Arxivlash';

  @override
  String get reposRestore => 'Tiklash';

  @override
  String reposArchived(String name) {
    return '$name arxivlandi';
  }

  @override
  String reposRestored(String name) {
    return '$name tiklandi';
  }

  @override
  String reposArchiveConfirm(String name) {
    return '$name arxivlansinmi? Tiketlari va tarixi saqlanadi, lekin agnts u uchun yangi Jira tiketlari va vazifalarni olmaydi. Boshlangan ishlar yakunlanadi. Istalgan vaqtda tiklashingiz mumkin.';
  }

  @override
  String get reposNoArchived => 'Arxivda repozitoriylar yoʻq.';

  @override
  String get reposImport => 'GitHub/GitLabʼdan import';

  @override
  String get reposImportTitle => 'Repozitoriyni import qilish';

  @override
  String get reposImportSub => 'GitHub yoki GitLab tokeningiz kira oladigan repozitoriylar. Birini tanlang va tekshiruvlarini sozlang.';

  @override
  String get reposImportFrom => 'Manba';

  @override
  String get reposImportSearch => 'Repozitoriylarni qidirish';

  @override
  String get reposImportLoading => 'Repozitoriylar yuklanmoqda…';

  @override
  String get reposImportEmpty => 'Token hech qaysi repozitoriyga kira olmaydi. Unga qaysi repozitoriylarga ruxsat berilganini tekshiring.';

  @override
  String get reposImportNone => 'Avval GitHub yoki GitLabʼni ulang.';

  @override
  String get reposImportConnect => 'Integratsiyalarni ochish';

  @override
  String get reposImportPrivate => 'Yopiq';

  @override
  String reposImportUpdated(String time) {
    return '$time yangilangan';
  }

  @override
  String get reposImportAdded => 'Qoʻshilgan';

  @override
  String get reposImportPick => 'Qoʻshish';

  @override
  String reposMissingHelp(num count) {
    return '$count ta repozitoriyda CLAUDE.md yoʻq. agnts baribir ishlaydi, lekin yoʻl topishga koʻproq qadam sarflaydi. Loyiha tuzilmasi, kelishuvlar va test buyruqlari bilan fayl qoʻshing.';
  }

  @override
  String get reposColRepo => 'Repozitoriy';

  @override
  String get reposColSource => 'Manba';

  @override
  String get reposColBranch => 'Branch';

  @override
  String get reposColTest => 'Test buyrugʻi';

  @override
  String get reposColClaude => 'CLAUDE.md';

  @override
  String get reposColOpen => 'Ochiq';

  @override
  String reposJira(String project) {
    return 'Jira $project';
  }

  @override
  String get reposSide => 'Shaxsiy loyiha';

  @override
  String get reposFound => 'Topildi';

  @override
  String get reposMissing => 'Yoʻq';

  @override
  String get reposUnknown => 'Tekshirilmagan';

  @override
  String get reposNoMatch => 'Qidiruvingizga mos repozitoriy yoʻq.';

  @override
  String get reposNone => 'Hali repozitoriylar yoʻq. agnts ishlashi uchun birinchisini qoʻshing.';

  @override
  String get reposDrawerSub => 'Shaxsiy loyiha vazifalarini, loyihaga bogʻlangach Jira tiketlari yoki Plane vazifalarini ham qabul qiladi';

  @override
  String get reposName => 'Nomi';

  @override
  String get reposCloneUrl => 'Klonlash URL manzili';

  @override
  String get reposCloneHelp => 'github.com yoki ulangan GitLab dagi https manzil. agnts shu xostning tokeni bilan klon qiladi va yuboradi.';

  @override
  String get reposJiraProject => 'Jira loyiha kaliti';

  @override
  String get reposJiraHelp => 'Ixtiyoriy. Ushbu Jira loyihasidagi agnts belgisi bor tiketlar shu yerda bajariladi.';

  @override
  String get reposTaskPrefix => 'Vazifa kaliti prefiksi';

  @override
  String reposTaskPrefixHelp(String prefix) {
    return 'Shaxsiy loyiha vazifalari $prefix-1, $prefix-2 kabi raqamlanadi. Jira loyiha kalitidan va Plane loyihasidan farq qilishi kerak.';
  }

  @override
  String get reposBranch => 'Asosiy branch';

  @override
  String get reposBranchHelp => 'Ish branchlari shu yerdan boshlanadi.';

  @override
  String get reposBuild => 'Yigʻish buyrugʻi';

  @override
  String get reposLint => 'Lint buyrugʻi';

  @override
  String get reposTest => 'Test buyrugʻi';

  @override
  String get reposTestHelp => 'Tiket tekshiruvingizga yetguncha muvaffaqiyatli oʻtishi kerak.';

  @override
  String get reposInstructions => 'Qoʻshimcha koʻrsatmalar';

  @override
  String get reposInstructionsHelp => 'Bu repozitoriy uchun har bir soʻrovga CLAUDE.md ga qoʻshimcha ravishda qoʻshiladi.';

  @override
  String get reposClaudeFound => 'Repozitoriy ildizida topildi';

  @override
  String get reposClaudeMissing => 'Yoʻq. agnts baribir ishlaydi, lekin CLAUDE.md qadamlarni tejaydi.';

  @override
  String get reposClaudeUnknown => 'Saqlangandan keyin tekshiriladi';

  @override
  String get reposSaved => 'Repozitoriy saqlandi';

  @override
  String get reposEdit => 'Tahrirlash';

  @override
  String get reposDeployWorkflow => 'Deploy workflow';

  @override
  String get reposDeployWorkflowHelp =>
      'workflow_dispatch li GitHub Actions workflow fayli, masalan deploy.yml. Repozitoriy sahifasidagi Deploy tugmasi uni ishga tushiradi.';

  @override
  String get reposColStack => 'Toolchainlar';

  @override
  String get reposToolchains => 'Toolchainlar';

  @override
  String get reposToolchainsHelp =>
      'Har bir ishga tushirishga o‘rnatiladigan til muhitlari va yig‘ish vositalari: har bir versiya bir marta o‘rnatiladi va keyingi ishga tushirishlar uchun saqlanadi.';

  @override
  String get reposToolchainsAuto =>
      'Repozitoriydan aniqlangan (go.mod, .nvmrc, .python-version, mise.toml, …) va bu fayllar o‘zgarganda yangilanadi.';

  @override
  String get reposToolchainsManual => 'Qo‘lda belgilangan: avtomatik aniqlash ularni o‘zgartirmaydi.';

  @override
  String get reposToolchainsBackToAuto => 'Avtomatik aniqlash';

  @override
  String reposToolchainFrom(String source) {
    return '$source dan';
  }

  @override
  String reposToolchainRemove(String tool) {
    return '$tool ni olib tashlash';
  }

  @override
  String get reposToolchainAdd => 'Qo‘shish';

  @override
  String get reposToolchainPh => 'vosita@versiya, masalan python@3.12';

  @override
  String get reposToolchainBad => 'vosita@versiya ko‘rinishida yozing, masalan node@20 yoki rust@stable.';

  @override
  String get reposToolchainsNone => 'Hozircha yo‘q: saqlagandan keyin aniqlanadi yoki «Aniqlash» tugmasini bosing.';

  @override
  String get reposDetect => 'Aniqlash';

  @override
  String get reposDetectDeep => 'Claude’dan so‘rash';

  @override
  String get reposDetectDeepHelp =>
      'Skanerlash buyruqlarni topmasa, Claude README va CI fayllarini o‘qiydi. Taxminan bir daqiqa oladi va Claude tarifingizdan foydalanadi.';

  @override
  String get reposDetecting => 'Repozitoriy o‘qilmoqda…';

  @override
  String reposDetectDone(String list) {
    return 'Topildi: $list.';
  }

  @override
  String get reposDetectNothing => 'Ma’lum yig‘ish fayllari topilmadi. Toolchain va buyruqlarni qo‘lda qo‘shing yoki Claude’dan so‘rang.';

  @override
  String get reposDetectFilled => 'Bo‘sh tekshiruv buyruqlari to‘ldirildi — saqlashdan oldin ko‘rib chiqing.';

  @override
  String get reposDetectByClaude => 'Claude skanerlash topa olmagan narsalarni to‘ldirdi.';

  @override
  String get reposDetectNeedsUrl => 'Avval klonlash URL manzilini kiriting.';

  @override
  String get reposCmdAuto => 'saqlangandan keyin aniqlanadi';

  @override
  String get reposNotes => 'Aniqlash izohlari';

  @override
  String get reposAdvanced => 'Qo‘shimcha';

  @override
  String get reposRunnerImage => 'Ishga tushirish obrazi';

  @override
  String get reposRunnerImageHelp =>
      'Ixtiyoriy. Serverda FROM agnts-runner asosida yig‘ilgan obraz — toolchainlar bera olmaydigan tizim kutubxonalari yoki SDK uchun (Android, Flutter). Bo‘sh bo‘lsa — standart obraz.';

  @override
  String get reposMemory => 'Xotira';

  @override
  String get reposMemoryHelp =>
      'Ixtiyoriy, og‘ir yig‘ishlar uchun (JVM, Rust, .NET). Belgilanmasa — server qiymati; server maksimumni cheklaydi (AGNTS_RUN_MEMORY_MAX_MB, standart 8 GB).';

  @override
  String get reposMemoryDefault => 'Server qiymati';

  @override
  String get reposBuildEnv => 'Yig‘ish muhiti';

  @override
  String get reposBuildEnvHelp =>
      'Har bir ishga tushirish uchun KEY=value qatorlari, masalan, xususiy paket reyestrlari tokenlari (NPM_TOKEN, PIP_INDEX_URL). Shifrlangan holda saqlanadi va boshqa ko‘rsatilmaydi. Claude ishlayotganda ularni o‘qishi mumkin, shuning uchun faqat o‘qish uchun tokenlardan foydalaning.';

  @override
  String reposBuildEnvSet(String names) {
    return 'Belgilangan: $names';
  }

  @override
  String get reposBuildEnvReplace => 'Almashtirish';

  @override
  String get reposBuildEnvClear => 'Tozalash';

  @override
  String get reposBuildEnvCleared => 'Saqlaganda tozalanadi.';

  @override
  String reposPlane(String project) {
    return 'Plane $project';
  }

  @override
  String get reposPlaneProject => 'Plane loyihasi';

  @override
  String get reposPlaneHelp =>
      'Ixtiyoriy. Loyiha identifikatori (WEB-123 dagi WEB). Shu Plane loyihasidagi agnts belgili vazifalar shu yerda bajariladi.';

  @override
  String get reviewTitle => 'agnts kod sharhi';

  @override
  String get reviewReportTitle => 'agnts hisobot sharhi';

  @override
  String get reviewSub => 'Siz koʻrib chiqayotganda ikkinchi fikr. U hech qachon tasdiqlashni toʻsmaydi: qarorni siz qabul qilasiz.';

  @override
  String get reviewPending => 'Navbatda: ishchi boʻshashi bilan agnts buni koʻrib chiqadi. Bu orada oʻzingiz koʻrib chiqishingiz mumkin.';

  @override
  String get reviewRunning => 'agnts koʻrib chiqmoqda…';

  @override
  String get reviewFailed => 'Sharh bajarilmadi. Oʻzingiz koʻrib chiqing yoki qayta ishga tushiring.';

  @override
  String get reviewNone => 'agnts buni koʻrib chiqmagan.';

  @override
  String reviewStale(String n) {
    return 'Bu $n-tahrir sharhi; shundan beri ish oʻzgargan.';
  }

  @override
  String get reviewRun => 'agnts bilan koʻrib chiqish';

  @override
  String get reviewRunAgain => 'Qayta koʻrib chiqish';

  @override
  String get reviewVerdict_looks_good => 'Hammasi yaxshi';

  @override
  String get reviewVerdict_has_concerns => 'Eʼtirozlar bor';

  @override
  String get reviewVerdict_needs_changes => 'Oʻzgartirish kerak';

  @override
  String get reviewSev_blocker => 'Toʻsiq';

  @override
  String get reviewSev_major => 'Jiddiy';

  @override
  String get reviewSev_minor => 'Kichik';

  @override
  String get reviewSev_nit => 'Mayda';

  @override
  String get reviewCat_correctness => 'Toʻgʻrilik';

  @override
  String get reviewCat_security => 'Xavfsizlik';

  @override
  String get reviewCat_performance => 'Unumdorlik';

  @override
  String get reviewCat_tests => 'Testlar';

  @override
  String get reviewCat_rules => 'Jamoa qoidalari';

  @override
  String get reviewCat_maintainability => 'Qoʻllab-quvvatlash';

  @override
  String get reviewCat_accuracy => 'Aniqlik';

  @override
  String get reviewCat_completeness => 'Toʻliqlik';

  @override
  String get reviewCat_other => 'Boshqa';

  @override
  String reviewFindings(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta topilma', zero: 'Topilma yoʻq');
    return '$_temp0';
  }

  @override
  String get reviewNoFindings => 'agnts muammo topmadi.';

  @override
  String get reviewStrengths => 'Yaxshi qilingan';

  @override
  String get reviewSuggestion => 'Taklif';

  @override
  String get reviewAddToFeedback => 'Fikrga qoʻshish';

  @override
  String get reviewAdded => 'Fikrda';

  @override
  String get reviewAddAll => 'Hammasini fikrga qoʻshish';

  @override
  String get reviewShowInDiff => 'Diffda koʻrsatish';

  @override
  String reviewModel(String model, String reason) {
    return '$model koʻrib chiqdi: $reason';
  }

  @override
  String get rulesTitle => 'Qoidalar';

  @override
  String get rulesLede =>
      'agnts har bir tiketda amal qiladigan koʻrsatmalar: barcha repozitoriylar uchun global qoidalar va bitta repozitoriy uchun qoidalar. Claude har bir qoidani tekshiradi va u kuchga kirishidan oldin noaniq joylar haqida savol beradi.';

  @override
  String get rulesAdd => 'Qoida qoʻshish';

  @override
  String get rulesAddSubmit => 'Qoʻshish va tekshirish';

  @override
  String get rulesDrawerSub => 'Yangi hamkasbga tushuntirgandek yozing. Claude uni biror tiket amal qilishidan oldin tekshiradi.';

  @override
  String get rulesRuleTitle => 'Nomi';

  @override
  String get rulesTitlePlaceholder => 'Yangi endpointlar uchun testlar';

  @override
  String get rulesScope => 'Qayerda amal qiladi';

  @override
  String get rulesScopeHelp =>
      'Global qoidalar barcha repozitoriylarda amal qiladi. Ular bir-biriga zid boʻlsa, repozitoriy qoidasi ustun.';

  @override
  String get rulesGlobal => 'Global';

  @override
  String get rulesGlobalHint => 'Barcha repozitoriylar';

  @override
  String get rulesBody => 'Qoida';

  @override
  String get rulesBodyPlaceholder => 'Har bir yangi HTTP endpoint uchun handler yonida integratsion test yoziladi.';

  @override
  String get rulesBodyHelp => 'Nima qilish, qayerda va qoidaga amal qilib boʻlmasa nima qilishni yozing.';

  @override
  String get rulesEnabled => 'Yoqilgan';

  @override
  String rulesEnabledFor(String title) {
    return '$title qoidasi yoqilgan';
  }

  @override
  String get rulesRereviewHelp =>
      'Qoida matnini oʻzgartirdingiz, shuning uchun Claude uni qayta tekshiradi. Tekshiruv tugaguncha tiketlar uni olmaydi.';

  @override
  String get rulesSaved => 'Qoida saqlandi';

  @override
  String get rulesSavedReview => 'Qoida saqlandi; Claude uni tekshirmoqda';

  @override
  String get rulesScopeLabel => 'Qoidalarni koʻrsatish';

  @override
  String rulesScopeAll(String n) {
    return 'Barcha qoidalar ($n)';
  }

  @override
  String rulesScopeGlobal(String n) {
    return 'Global ($n)';
  }

  @override
  String get rulesNone =>
      'Hali qoidalar yoʻq. Jamoangiz qanday ishlashini agntsga aytish uchun qoida qoʻshing: testlar, nomlash, loglash, nimaga tegmaslik kerak.';

  @override
  String get rulesNoMatch => 'Mos qoidalar yoʻq.';

  @override
  String rulesWaitingHelp(num n) {
    return '$n ta qoida javoblaringizni kutmoqda. Javob berilmaguncha ular tiketlarga qoʻllanmaydi.';
  }

  @override
  String get rulesStatus_pending => 'Tekshiruv navbatida';

  @override
  String get rulesStatus_analyzing => 'Tekshirilmoqda';

  @override
  String get rulesStatus_questions => 'Javob kerak';

  @override
  String get rulesStatus_ready => 'Amal qiladi';

  @override
  String get rulesStatus_failed => 'Tekshiruv muvaffaqiyatsiz';

  @override
  String get rulesOff => 'Oʻchirilgan';

  @override
  String get rulesEdit => 'Tahrirlash';

  @override
  String get rulesDelete => 'Oʻchirish';

  @override
  String rulesDeleteBody(String title) {
    return '“$title” qoidasini oʻchirasizmi? Bundan keyin boshlangan tiketlar unga amal qilmaydi.';
  }

  @override
  String get rulesPending => 'Boʻsh ishchini kutmoqda. Claude qoidalarni keyingi tiket boshlanishidan oldin tekshiradi.';

  @override
  String get rulesAnalyzing => 'Claude qoidani oʻqib, undagi noaniqlik va ziddiyatlarni qidirmoqda.';

  @override
  String rulesQuestionsTitle(num n) {
    return 'Qoida kuchga kirishidan oldin $n ta savol';
  }

  @override
  String get rulesQuestionsSub => 'Claude noaniq joy topdi. Javoblaringiz qoidaning bir qismiga aylanadi.';

  @override
  String get rulesYourAnswer => 'Javobingiz';

  @override
  String get rulesAddDetails => 'Tafsilot qoʻshing (ixtiyoriy)';

  @override
  String rulesAnswerFor(String n) {
    return '$n-savolga javob';
  }

  @override
  String rulesDetailsFor(String n) {
    return '$n-savol uchun tafsilot';
  }

  @override
  String get rulesSendAnswers => 'Javoblarni yuborish';

  @override
  String rulesQuestionsLeft(num n) {
    return 'Javobsiz $n ta savol qoldi';
  }

  @override
  String get rulesAllAnswered => 'Barcha savollarga javob berildi';

  @override
  String get rulesAccept => 'Yozilganicha ishlatish';

  @override
  String get rulesAcceptTitle => 'Qoidani yozilganicha ishlatasizmi?';

  @override
  String get rulesAcceptBody =>
      'Tiketlar qoidani siz yozgandek, hozirgacha berilgan javoblar bilan oladi. Ochiq savollar tashlab yuboriladi.';

  @override
  String rulesFailed(String error) {
    return 'Claude bu qoidani tekshira olmadi: $error';
  }

  @override
  String get rulesReviewAgain => 'Qayta tekshirish';

  @override
  String get rulesInterpretation => 'agnts uni qanday tushunadi';

  @override
  String get rulesClarified => 'Tiketlar nimani oladi';

  @override
  String get rulesAsWritten => 'Yozilganicha ishlatiladi.';

  @override
  String rulesAnswersTitle(num n) {
    return 'Javob berilgan $n ta savol';
  }

  @override
  String rulesReviewedAgo(String ago) {
    return '$ago tekshirilgan';
  }

  @override
  String rulesAddedAgo(String ago) {
    return '$ago qoʻshilgan';
  }

  @override
  String get rulesAnswered => 'Javoblar yuborildi; Claude qoidani qayta tekshirmoqda';

  @override
  String get rulesAccepted => 'Qoida yozilganicha amal qiladi';

  @override
  String get rulesQueued => 'Tekshiruv navbatiga qoʻyildi';

  @override
  String get rulesDeleted => 'Qoida oʻchirildi';

  @override
  String get rulesTurnedOn => 'Qoida yoqildi';

  @override
  String get rulesTurnedOff => 'Qoida oʻchirildi';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get settingsLede => 'agnts vositalaringizga qanday ulanadi va ish paytida qanday ishlaydi.';

  @override
  String get settingsAppearance => 'Koʻrinish';

  @override
  String get settingsAppearanceSub => 'Shu brauzerda saqlanadi va darhol qoʻllanadi';

  @override
  String get settingsTheme => 'Mavzu';

  @override
  String get settingsThemeHelp => 'Tizim qurilmangizning kunduzgi yoki tungi sozlamasiga ergashadi';

  @override
  String get settingsSystem => 'Tizim';

  @override
  String get settingsDay => 'Kunduzgi';

  @override
  String get settingsNight => 'Tungi';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsIntegrations => 'Integratsiyalar';

  @override
  String get settingsIntegrationsSub => 'Tiketlar qayerdan keladi va kod qayerga yuboriladi';

  @override
  String get settingsManageAll => 'Boshqarish';

  @override
  String get settingsManage => 'Boshqarish';

  @override
  String get settingsConnect => 'Ulash';

  @override
  String get settingsConnected => 'Ulangan';

  @override
  String get settingsNotConnected => 'Ulanmagan';

  @override
  String get settingsClaude => 'Claude Code';

  @override
  String get settingsClaudeSub => 'Kod yozadigan mexanizm';

  @override
  String get settingsModels => 'Bosqichlar boʻyicha modellar';

  @override
  String get settingsModelsHelp => 'Har bir qadam uchun modelni tanlang. Haiku tarif limitidan eng kam, Opus esa eng koʻp foydalanadi.';

  @override
  String get settingsStageAnalyze => 'Tiketni oʻqish va savol berish';

  @override
  String get settingsStageAnalyzeHelp => 'Faqat oʻqish. Har bir tiket uchun bir marta.';

  @override
  String get settingsStageCoding => 'Kod yozish';

  @override
  String get settingsStageCodingHelp => 'Asosiy ish. Tarifning katta qismini sarflaydi.';

  @override
  String get settingsStageRetry => 'Qayta urinishlar va soʻralgan oʻzgarishlar';

  @override
  String get settingsStageRetryHelp => 'Muvaffaqiyatsiz testlar, fikringiz yoki toʻxtagan ishdan keyin.';

  @override
  String get settingsStageHelper => 'Limitlarni yangilash va qisqa matnlar';

  @override
  String get settingsStageHelperHelp => 'Boʻsh vaqtdagi limit yangilanishi kabi kichik ishlar.';

  @override
  String get settingsStageLearn => 'Tugagan ishdan darslar';

  @override
  String get settingsStageLearnHelp => 'Har bir yuborilgan oʻzgarishni oʻqiydi va repozitoriy uchun yangi narsalar haqida dars yozadi.';

  @override
  String get settingsStageReview => 'Kod sharhi';

  @override
  String get settingsStageReviewHelp =>
      'Har bir natijani siz koʻrib chiqayotganda tekshiradi. Avto murakkab tiketlar uchun Opus, qolganlari uchun Sonnet ishlatadi.';

  @override
  String get settingsModelAuto => 'Avto';

  @override
  String get settingsMaxTurns => 'Har bir ish uchun qadamlar limiti';

  @override
  String get settingsMaxTurnsHelp => 'Ish shu limitga yetganda toʻxtaydi va xabar beradi';

  @override
  String get settingsTimeout => 'Ish vaqti chegarasi';

  @override
  String settingsMinutes(String n) {
    return '$n daq';
  }

  @override
  String get settingsAllow => 'Ruxsat etilgan buyruqlar';

  @override
  String get settingsAllowHelp => 'Claude Code bularni soʻramasdan bajara oladi';

  @override
  String get settingsDeny => 'Taqiqlangan buyruqlar';

  @override
  String get settingsDenyHelp => 'Tiket soʻrasa ham doim rad etiladi. Kodni agnts yuboradi, hech qachon Claude Code emas.';

  @override
  String get settingsCommits => 'Commitlar va pull requestlar';

  @override
  String get settingsCommitsSub => 'Commitlar kimning nomidan va pull requestlar qanday ochiladi';

  @override
  String get settingsAuthorName => 'Muallif ismi';

  @override
  String get settingsAuthorNameHelp => 'Commitlar sizning nomingizdan qilinadi';

  @override
  String get settingsAuthorEmail => 'Muallif emaili';

  @override
  String get settingsAuthorEmailHelp => 'Sizniki boʻlib koʻrinishi uchun GitHub hisobingizga mos kelishi kerak';

  @override
  String get settingsCoAuthor => 'Co-authored-by: agnts qatorini qoʻshish';

  @override
  String get settingsCoAuthorHelp => 'Hamkasblar qaysi commitlarni agnts yozganini koʻradi';

  @override
  String get settingsPrTitle => 'Pull request sarlavhasi';

  @override
  String settingsPrTitleHelp(String key, String title) {
    return '\'$key\' va \'$title\' tiket kaliti va sarlavhasi bilan almashtiriladi';
  }

  @override
  String get settingsDraft => 'Qoralama sifatida ochish';

  @override
  String get settingsRuns => 'Ishlar';

  @override
  String get settingsRunsSub => 'Barcha tiket va vazifalar uchun standart qiymatlar';

  @override
  String get settingsAskFirst => 'Kod yozishdan oldin savol berish';

  @override
  String get settingsAskFirstHelp => 'Yangi Jira tiketlari uchun standart. Vazifalar uchun yaratishda tanlanadi.';

  @override
  String get settingsAutoResume => 'Limit yangilangach toʻxtatilgan ishlarni davom ettirish';

  @override
  String get settingsAutoLearn => 'Har bir yuborilgan oʻzgarishdan oʻrganish';

  @override
  String get settingsAutoLearnHelp =>
      'Yuborilgandan keyin agnts repozitoriyda avval ishlatilmagan usullarni qidiradi va «Oʻrganish» boʻlimida dars yozadi. Limitni faqat kutayotgan tiket boʻlmaganda sarflaydi.';

  @override
  String get settingsAutoReview => 'Har bir natijani koʻrib chiqish';

  @override
  String get settingsAutoReviewHelp =>
      'Oʻzgarish yoki hisobot sizni kutayotganda agnts uni koʻrib chiqadi va topilmalarni yonida koʻrsatadi. Tasdiqlashni hech qachon toʻsmaydi.';

  @override
  String get settingsPauseAbove => 'Bundan yuqorida yangi ish boshlamaslik';

  @override
  String get settingsPauseAboveHelp => 'Sessiyadan foydalanish. Boshlangan ishlar davom etadi.';

  @override
  String get settingsParallel => 'Bir vaqtda ishlar soni';

  @override
  String get settingsParallelHelp => 'Koʻproq ish tezroq tugaydi, lekin tarif limiti tezroq sarflanadi';

  @override
  String get settingsNotify => 'Bildirishnomalar';

  @override
  String get settingsNotifySub => 'Telefonga push va Telegram xabarlari';

  @override
  String get settingsPush => 'Push bildirishnomalar';

  @override
  String get settingsPushHelp => 'Telefoningizdagi agnts ilovasiga';

  @override
  String get settingsTelegram => 'Telegram xabarlari';

  @override
  String get settingsTelegramHelp => 'Telegram Integratsiyalar sahifasida ulangandan keyingina yuboriladi';

  @override
  String get settingsNeedsYou => 'Biror narsa sizni kutganda';

  @override
  String get settingsNeedsYouHelp => 'Javob berish kerak boʻlgan savollar yoki tekshirish kerak boʻlgan oʻzgarishlar';

  @override
  String get settingsStopped => 'Ish toʻxtaganda yoki pauzaga qoʻyilganda';

  @override
  String get settingsDone => 'Oʻzgarishlar yuborilganda';

  @override
  String get settingsLessons => 'agnts oʻrganish uchun yangi narsa topganda';

  @override
  String get settingsReviewDone => 'agnts kod sharhi tugaganda';

  @override
  String get settingsOnThisPage => 'Ushbu sahifada';

  @override
  String get settingsSecretsHelp =>
      'Jira, GitHub va Claude tokenlari serveringizda shifrlangan holda saqlanadi. Bu sahifa ularni hech qachon koʻrsatmaydi.';

  @override
  String get settingsSaved => 'Sozlamalar saqlandi';

  @override
  String get spendTitle => 'Token sarfi';

  @override
  String spendSub(String tokens, String cost) {
    return 'Kirish va chiqishda $tokens token · API narxlarida taxminan $cost';
  }

  @override
  String get spendEmpty =>
      'Hali hech narsa yozilmagan. Sarf agnts bu tiket boʻyicha Claude\'ni birinchi marta ishga tushirgandan keyin koʻrinadi.';

  @override
  String get spendInput => 'Kirish';

  @override
  String get spendOutput => 'Chiqish';

  @override
  String spendCache(String read, String write) {
    return 'Kesh: $read oʻqilgan, $write yozilgan';
  }

  @override
  String spendCalls(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta ishga tushirish', one: '$n ta ishga tushirish');
    return '$_temp0';
  }

  @override
  String get spendPartial => 'Ishga tushirish toʻxtatilgan, shuning uchun narxi nomaʼlum';

  @override
  String get spendCostNote =>
      'Narx — Claude Code\'ning xuddi shu ish uchun API narxlaridagi bahosi. Claude obunasida u toʻlanmaydi; u har bir bosqichning nisbiy ogʻirligini koʻrsatadi.';

  @override
  String spendTokens(String n) {
    return '$n token';
  }

  @override
  String get spendColTokens => 'Tokenlar';

  @override
  String get spendStageAnalyze => 'Tahlil';

  @override
  String get spendStageCoding => 'Kod yozish';

  @override
  String get spendStageWriting => 'Yozish';

  @override
  String get spendStageRetry => 'Tuzatishlar va oʻzgarishlar';

  @override
  String get spendStageReview => 'Kod tekshiruvi';

  @override
  String get spendStagePreview => 'Oldindan koʻrish';

  @override
  String get spendStageLearn => 'Saboqlar';

  @override
  String get spendStageHelper => 'Yordamchi';

  @override
  String get spendTopTitle => 'Sarf boʻyicha tiketlar';

  @override
  String spendTopSub(String tokens, String cost) {
    return 'Kirish va chiqishda $tokens token · API narxlarida taxminan $cost';
  }

  @override
  String get spendTopSubEmpty => 'Qaysi tiketlar obunangizni eng koʻp sarflagan';

  @override
  String get spendTopEmpty => 'Bu davrda Claude ishlari yozilmagan.';

  @override
  String get spendTopNote =>
      'Tartib Claude Code narx bahosi boʻyicha, u keshni toʻgʻri hisobga oladi. Ulush — davrdagi taxminiy narxdan. Faqat davr ichidagi sarf hisoblanadi.';

  @override
  String get spendColStage => 'Eng qimmat bosqich';

  @override
  String get spendColCost => 'Taxminiy narx';

  @override
  String get spendColShare => 'Ulush';

  @override
  String get stateNew => 'Navbatda';

  @override
  String get stateAnalyzing => 'Kodni oʻqiyapti';

  @override
  String get stateWaiting_for_answers => 'Javoblaringiz kerak';

  @override
  String get stateCoding => 'Kod yozish';

  @override
  String get stateTesting => 'Testlar ishlamoqda';

  @override
  String get stateWaiting_for_review => 'Tekshiruvga tayyor';

  @override
  String get statePushing => 'Yuborilmoqda';

  @override
  String get stateDone => 'Yuborildi';

  @override
  String get stateRejected => 'Rad etildi';

  @override
  String get stateFailed => 'Toʻxtatildi';

  @override
  String get stateRate_limited => 'Pauza: tarif limiti';

  @override
  String get stateReportCoding => 'Hisobot yozmoqda';

  @override
  String get stateReportPushing => 'Topshirmoqda';

  @override
  String get stateReportDone => 'Tayyor';

  @override
  String get tasksTitle => 'Vazifalar';

  @override
  String get tasksLede =>
      'Shaxsiy loyihalaringiz uchun ishlar. Vazifalar agnts ichida qoladi va Jira\'ga tushmaydi. Qolgani bir xil: savollar, kod yozish, sizning tekshiruvingiz.';

  @override
  String get tasksNew => 'Yangi vazifa';

  @override
  String tasksAllRepos(String count) {
    return 'Barcha repozitoriylar $count';
  }

  @override
  String get tasksFilterLabel => 'Repozitoriy boʻyicha saralash';

  @override
  String get tasksColTask => 'Vazifa';

  @override
  String get tasksColRepo => 'Repozitoriy';

  @override
  String get tasksColStatus => 'Holat';

  @override
  String get tasksColUpdated => 'Yangilangan';

  @override
  String get tasksNoMatch => 'Qidiruvingizga mos vazifa yoʻq.';

  @override
  String get tasksEmpty => 'Bu repozitoriyda hali vazifalar yoʻq.';

  @override
  String get tasksRepos => 'Repozitoriylar';

  @override
  String get tasksReposSub => 'Ushbu serverdagi shaxsiy loyiha repozitoriylaringiz';

  @override
  String tasksRepoLine(String test, String open) {
    return 'testlar: $test, ochiq: $open';
  }

  @override
  String get tasksNoTest => 'yoʻq';

  @override
  String get tasksNoRepos => 'Hali shaxsiy loyiha repozitoriylari yoʻq.';

  @override
  String get tasksHelp =>
      'Faqat siz ishlaydigan repozitoriylar uchun agnts\'ga tasdiqlaganingizdan keyin toʻgʻridan-toʻgʻri main\'ga yuborishga ruxsat berishingiz mumkin. Baribir sizning tekshiruvingizsiz hech narsa yubormaydi.';

  @override
  String get tasksDrawerSub => 'Shaxsiy loyihalaringiz uchun. Jira bilan sinxronlanmaydi.';

  @override
  String get tasksRepository => 'Repozitoriy';

  @override
  String get tasksFieldTitle => 'Sarlavha';

  @override
  String get tasksTitlePh => 'Masalan: yondashuvlar orasiga dam olish taymerini qoʻshish';

  @override
  String get tasksFieldDesc => 'Nima qilish kerak';

  @override
  String get tasksDescPh => 'Kerakli natijani tasvirlang. Qanchalik aniq boʻlsa, agnts shuncha kam savol beradi.';

  @override
  String get tasksPriority => 'Muhimlik';

  @override
  String get tasksLow => 'Past';

  @override
  String get tasksMedium => 'Oʻrta';

  @override
  String get tasksHigh => 'Yuqori';

  @override
  String get tasksAfter => 'Tasdiqlaganingizdan keyin';

  @override
  String get tasksAfterMain => 'main\'ga yuborish';

  @override
  String get tasksAfterPr => 'Pull request ochish';

  @override
  String get tasksStart => 'Qanday boshlash';

  @override
  String get tasksStartAsk => 'Avval savollar berish';

  @override
  String get tasksStartAskHint => 'agnts kodni oʻqiydi va kod yozishdan oldin soʻraydi. Noaniq ishlar uchun eng yaxshisi.';

  @override
  String get tasksStartCode => 'Darhol kod yozishni boshlash';

  @override
  String get tasksStartCodeHint => 'Savollarsiz. Kichik, yaxshi tasvirlangan vazifalar uchun mos.';

  @override
  String get tasksStartQueue => 'Navbatda qoldirish';

  @override
  String get tasksStartQueueHint => 'Saqlab, keyinroq boshlash.';

  @override
  String get tasksCreate => 'Vazifa yaratish';

  @override
  String get tasksCreateStart => 'Yaratish va boshlash';

  @override
  String get tasksAddRepoFirst => 'Avval shaxsiy loyiha repozitoriysini qoʻshing.';

  @override
  String get tasksTitleRequired => 'Sarlavhani kiriting.';

  @override
  String tasksCreated(String key) {
    return '$key vazifasi yaratildi';
  }

  @override
  String tasksCount(num n) {
    return '$n ta vazifa';
  }

  @override
  String get tasksNoRepo => 'Repozitoriysiz';

  @override
  String get tasksRepoNeeded => 'Kod va testlar uchun repozitoriy kerak: uni yoki boshqa turni tanlang.';

  @override
  String get ticketBack => 'Barcha tiketlar';

  @override
  String get ticketPlan => 'Reja';

  @override
  String get ticketAnalysis => 'agnts nimani topdi';

  @override
  String get ticketQuestions => 'Savollar';

  @override
  String get ticketYourAnswer => 'Javobingiz';

  @override
  String get ticketNote => 'Izoh (ixtiyoriy)';

  @override
  String get ticketSendAnswers => 'Javoblarni yuborish va kod yozishni boshlash';

  @override
  String get ticketChanges => 'Oʻzgarishlar';

  @override
  String ticketFilesChanged(num count) {
    return '$count ta fayl oʻzgardi';
  }

  @override
  String get ticketChecks => 'Tekshiruvlar';

  @override
  String get ticketPassed => 'oʻtdi';

  @override
  String get ticketFailedCheck => 'oʻtmadi';

  @override
  String get ticketNotes => 'Tekshiruvchi uchun izohlar';

  @override
  String get ticketApprove => 'Tasdiqlash va yuborish';

  @override
  String ticketApproveConfirm(String branch) {
    return '$branch yuborilsinmi va pull request ochilsinmi?';
  }

  @override
  String get ticketRequestChanges => 'Oʻzgartirish soʻrash';

  @override
  String get ticketFeedbackPlaceholder => 'Nimani oʻzgartirish kerak?';

  @override
  String get ticketSend => 'Yuborish';

  @override
  String get ticketCancel => 'Bekor qilish';

  @override
  String get ticketReject => 'Rad etish';

  @override
  String ticketRejectConfirm(String key) {
    return '$key boʻyicha barcha ish toʻxtatilsinmi? Buni qaytarib boʻlmaydi.';
  }

  @override
  String get ticketRetry => 'Qayta urinish';

  @override
  String ticketPullRequest(String number) {
    return 'Pull request #$number';
  }

  @override
  String get ticketBranch => 'Branch';

  @override
  String ticketRevision(String n) {
    return 'Tahrir $n';
  }

  @override
  String get ticketLog => 'Jonli log';

  @override
  String get ticketLogEmpty => 'Hozircha hech narsa yoʻq.';

  @override
  String ticketNotFound(String key) {
    return '$key tiketi topilmadi.';
  }

  @override
  String get ticketConflict => 'Tiket allaqachon oʻzgardi; yangilandi.';

  @override
  String get ticketStopAnalyze => 'Tahlil';

  @override
  String get ticketStopAnswers => 'Javoblaringiz';

  @override
  String get ticketStopCoding => 'Kod yozish';

  @override
  String get ticketStopTests => 'Testlar';

  @override
  String get ticketStopReview => 'Sizning tekshiruvingiz';

  @override
  String get ticketStopPushed => 'Yuborildi';

  @override
  String get ticketProgress => 'Jarayon';

  @override
  String ticketBackTo(String page) {
    return 'Orqaga: $page';
  }

  @override
  String get ticketQueuedTitle => 'Navbatda kutmoqda';

  @override
  String get ticketQueuedSub =>
      'agnts tiket va tegishli kodni oʻqiydi, keyin reja va savollar bilan qaytadi. Bu bosqichda hech narsa oʻzgartirilmaydi.';

  @override
  String get ticketHeldSub => 'Bu vazifa siz boshlamaguningizcha navbatda turadi.';

  @override
  String get ticketStart => 'Hozir boshlash';

  @override
  String get ticketStartHint => 'Boʻsh joy chiqqanda boshlanadi';

  @override
  String get ticketAnalyzingTitle => 'Kodni oʻqiyapti';

  @override
  String ticketAnalyzingSub(String repo) {
    return 'Reja tuzish uchun $repo ni koʻrib chiqmoqda.';
  }

  @override
  String ticketQuestionsTitle(num n) {
    return 'Kod yozishdan oldin $n ta savol';
  }

  @override
  String get ticketQuestionsSub => 'Variantni tanlang yoki oʻz javobingizni yozing. Javoblar reja bilan birga promptga qoʻshiladi.';

  @override
  String get ticketAddDetails => 'Tafsilot qoʻshing (ixtiyoriy)';

  @override
  String ticketDetailsFor(String n) {
    return '$n-savol uchun tafsilot';
  }

  @override
  String ticketAnswerFor(String n) {
    return '$n-savolga javob';
  }

  @override
  String get ticketStartCoding => 'Kod yozishni boshlash';

  @override
  String ticketQuestionsLeft(num n) {
    return 'Javobsiz $n ta savol qoldi';
  }

  @override
  String get ticketAllAnswered => 'Barcha savollarga javob berildi';

  @override
  String get ticketCodingTitle => 'Kod yozish';

  @override
  String get ticketTestingTitle => 'Testlar ishlamoqda';

  @override
  String ticketRevisionSuffix(String title, String n) {
    return '$title, $n-tahrir';
  }

  @override
  String ticketCodingSub(String branch) {
    return '$branch ustida yangi konteynerda ishlayapti. Hech narsa yuborilishidan oldin oʻzgarishlarni tekshirasiz.';
  }

  @override
  String get ticketFactModel => 'Model';

  @override
  String get ticketFactTurns => 'Qadamlar';

  @override
  String get ticketFactTurnLimit => 'Qadamlar limiti';

  @override
  String get ticketFactSession => 'Sessiya sarfi';

  @override
  String get ticketFactTests => 'Testlar';

  @override
  String get ticketFactChanged => 'Oʻzgargan';

  @override
  String ticketChangedValue(num n, String add, String del) {
    return '$n ta fayl, +$add −$del';
  }

  @override
  String ticketChecksPassed(num n) {
    return '$n ta tekshiruv oʻtdi';
  }

  @override
  String get ticketNoChecks => 'Tekshiruvlar sozlanmagan';

  @override
  String get ticketStopRun => 'Ishni toʻxtatish';

  @override
  String ticketStopConfirm(String key) {
    return '$key ishi toʻxtatilsinmi? Keyin qayta urinish mumkin.';
  }

  @override
  String get ticketReviewTitle => 'Oʻzgarishlarni tekshiring';

  @override
  String ticketReviewSubPr(String branch) {
    return 'Hali hech narsa serverdan chiqmagan. Tasdiqlash $branch ni yuboradi va pull request ochadi.';
  }

  @override
  String ticketReviewSubJira(String branch) {
    return 'Hali hech narsa serverdan chiqmagan. Tasdiqlash $branch ni yuboradi, pull request ochadi va Jira tiketini yangilaydi.';
  }

  @override
  String get ticketReviewSubMain => 'Hali hech narsa serverdan chiqmagan. Tasdiqlash toʻgʻridan-toʻgʻri asosiy branchga yuboradi.';

  @override
  String get ticketWhatAgntsDid => 'agnts nima qildi';

  @override
  String get ticketDiff => 'Oʻzgarishlar';

  @override
  String get ticketFeedback => 'Fikr-mulohaza';

  @override
  String get ticketAssignTitle => 'Pull requestni biriktirish';

  @override
  String get ticketAssignSub => 'Ixtiyoriy. agnts uni ochganda kimga biriktirilishini tanlang.';

  @override
  String ticketAssignError(String error) {
    return 'Repozitoriy aʼzolarini yuklab boʻlmadi: $error. Biriktirmasdan ham tasdiqlashingiz mumkin.';
  }

  @override
  String get ticketAssignNone => 'Tanlash uchun repozitoriy aʼzolari yoʻq.';

  @override
  String ticketApproveAssignees(String names) {
    return '$names ga biriktirish.';
  }

  @override
  String get ticketKvAssignees => 'Biriktirilganlar';

  @override
  String get ticketFeedbackHint => 'Nimani oʻzgartirish kerakligini yozing. Oʻzgartirish soʻrash uchun majburiy.';

  @override
  String get ticketApproveMainConfirm => 'Oʻzgarishlar toʻgʻridan-toʻgʻri asosiy branchga yuborilsinmi?';

  @override
  String get ticketPushingTitle => 'Yuborilmoqda';

  @override
  String get ticketPushingSub => 'Sizning nomingizdan commit qilinmoqda va pull request ochilmoqda.';

  @override
  String get ticketDoneTitle => 'Yuborildi';

  @override
  String ticketDoneMain(String repo) {
    return 'Sizning nomingizdan commit qilindi va $repo asosiy branchiga yuborildi.';
  }

  @override
  String ticketDonePr(String number, String branch) {
    return '$branch uchun #$number pull request ochildi.';
  }

  @override
  String ticketOpenPr(String number) {
    return '#$number pull requestni ochish';
  }

  @override
  String get ticketRejectedTitle => 'Rad etildi';

  @override
  String get ticketRejectedSub => 'agnts bu tiket ustida ishlashni toʻxtatdi. Branch yuborilmadi.';

  @override
  String get ticketFailedTitle => 'agnts toʻxtadi';

  @override
  String get ticketFailedUnknown => 'Ish toʻxtadi. Tafsilotlar ish logida.';

  @override
  String get ticketRetryNote => 'Qayta urinish uchun izoh';

  @override
  String get ticketRetryNoteHint => 'Ixtiyoriy. Xatoni qanday chetlab oʻtishni agnts ga yozing; keyingi ish uni xato bilan birga oladi.';

  @override
  String get ticketTakeItMyself => 'Oʻzim qilaman';

  @override
  String get ticketRateTitle => 'Pauza: tarif limiti';

  @override
  String get ticketResume => 'Ishni davom ettirish';

  @override
  String ticketRateHint(String pct) {
    return 'Hozir sessiyaning $pct% sarflangan.';
  }

  @override
  String get ticketModelsTitle => 'Shu tiket uchun modellar';

  @override
  String get ticketModelsHint => 'Standart sozlamalarni faqat shu tiket uchun almashtiradi.';

  @override
  String ticketModelDefault(String model) {
    return 'Standart ($model)';
  }

  @override
  String get ticketStageAnalyze => 'Tiketni oʻqish va savollar';

  @override
  String get ticketStageCoding => 'Kod yozish';

  @override
  String get ticketStageRetry => 'Qayta urinishlar va soʻralgan oʻzgarishlar';

  @override
  String get ticketStageReview => 'agnts kod sharhi';

  @override
  String get ticketStagePreview => 'Skrinshotlar (oldindan koʻrish)';

  @override
  String ticketModelAuto(String model) {
    return 'Avto ($model)';
  }

  @override
  String get ticketSideTicket => 'Tiket';

  @override
  String get ticketSideTask => 'Vazifa';

  @override
  String get ticketKvKey => 'Kalit';

  @override
  String get ticketKvSource => 'Manba';

  @override
  String get ticketKvRepo => 'Repozitoriy';

  @override
  String get ticketKvAfter => 'Tasdiqlangandan keyin';

  @override
  String get ticketKvPriority => 'Muhimlik';

  @override
  String get ticketKvBranch => 'Branch';

  @override
  String get ticketKvRevision => 'Reviziya';

  @override
  String get ticketKvTurns => 'Sarflangan qadamlar';

  @override
  String get ticketKvCodingModel => 'Kod yozish modeli';

  @override
  String get ticketKvRetryModel => 'Qayta urinish modeli';

  @override
  String get ticketSrcJira => 'Jira';

  @override
  String get ticketSrcTask => 'agnts vazifasi';

  @override
  String get ticketAfterMain => 'main\'ga yuborish';

  @override
  String get ticketAfterPr => 'Pull request ochish';

  @override
  String get ticketHistoryTitle => 'Tarix';

  @override
  String get ticketHistoryEmpty => 'Hali tarix yoʻq.';

  @override
  String get ticketAnswersTitle => 'Javoblaringiz';

  @override
  String get ticketAnswersSub => 'Prompt bilan birga yuborilgan';

  @override
  String get ticketRunLog => 'Ishga tushirish logi';

  @override
  String ticketRunLogSub(num n) {
    return '$n ta hodisa, bosqichlar boʻyicha';
  }

  @override
  String ticketGroupEvents(num n) {
    return '$n ta hodisa';
  }

  @override
  String ticketGroupErrors(num n) {
    return '$n ta xato';
  }

  @override
  String get ticketOpenInLogs => 'Loglarda ochish';

  @override
  String get ticketStepOther => 'Umumiy';

  @override
  String get ticketDelete => 'Oʻchirish';

  @override
  String ticketDeleteConfirm(String key) {
    return '$key vazifasi oʻchirilsinmi?';
  }

  @override
  String get ticketUsageTitle => 'Tarif limitlari';

  @override
  String get ticketUsageSession => 'Joriy sessiya';

  @override
  String get ticketUsageWeek => 'Shu hafta';

  @override
  String get ticketMerged => 'Birlashtirildi';

  @override
  String ticketMergedAt(String time) {
    return 'Birlashtirildi: $time.';
  }

  @override
  String get ticketRepoTitle => 'Repozitoriy';

  @override
  String get ticketRepoHint => 'agnts shu tiketni qayerda tahlil qiladi va kod yozadi.';

  @override
  String get ticketRepoNone => 'Repozitoriyni tanlang…';

  @override
  String get ticketRepoMissing => 'Tiketga repozitoriy bogʻlanmagan. Birini tanlang va qayta urinib koʻring.';

  @override
  String get ticketRepoRestartTitle => 'Repozitoriy almashtirilsinmi?';

  @override
  String ticketRepoRestart(String repo, String next) {
    return 'Bu tiket boʻyicha $repo da ish boshlangan edi. $next da qayta urinishda tahlildan boshlanadi.';
  }

  @override
  String get ticketRepoChange => 'Almashtirish';

  @override
  String ticketRepoChanged(String repo) {
    return 'Repozitoriy: $repo';
  }

  @override
  String get ticketQueuedSubReport =>
      'agnts tiketni (repozitoriy boʻlsa, kodni ham) oʻqiydi va reja hamda savollar bilan qaytadi. Hech narsa oʻzgarmaydi.';

  @override
  String get ticketAnalyzingTitleNoRepo => 'Tiketni oʻqiyapti';

  @override
  String get ticketAnalyzingSubNoRepo => 'Repozitoriy yoʻq: agnts tiket matni asosida ishlaydi.';

  @override
  String get ticketStartWriting => 'Hisobotni boshlash';

  @override
  String get ticketWritingTitle => 'Hisobot yozilmoqda';

  @override
  String get ticketWritingSub => 'Yangi konteynerda ishlayapti. Kod oʻzgarmaydi; avval hisobotni siz tekshirasiz.';

  @override
  String get ticketReviewReportTitle => 'Hisobotni tekshiring';

  @override
  String get ticketReviewReportSub => 'Tasdiqlansa, hisobot shu yerda qoladi va vazifa yopiladi.';

  @override
  String get ticketReviewReportSubJira =>
      'Tasdiqlansa, hisobot shu yerda qoladi va tiket yopiladi. Quyidagi belgini qoʻysangizgina Jira\'ga yuboriladi.';

  @override
  String get ticketReport => 'Hisobot';

  @override
  String get ticketReportMissing => 'Hisobot saqlanmagan.';

  @override
  String ticketPostReport(String key) {
    return 'Hisobotni Jira\'dagi $key ga izoh sifatida ham yuborish';
  }

  @override
  String get ticketFeedbackReportHint => 'Hisobotda nimani oʻzgartirish yoki qoʻshish kerak?';

  @override
  String get ticketApproveReport => 'Tasdiqlash';

  @override
  String get ticketApproveReportConfirm => 'Hisobotni tasdiqlab, tiketni yopasizmi?';

  @override
  String ticketApproveReportPostConfirm(String key) {
    return 'Hisobotni tasdiqlab, tiketni yopib, hisobotni Jira\'dagi $key ga yuborasizmi?';
  }

  @override
  String get ticketDeliveringTitle => 'Yakunlamoqda';

  @override
  String get ticketDeliveringSub => 'Tasdiqlangan hisobotni saqlayapti va soʻragan boʻlsangiz, vazifa trekeriga yuboryapti.';

  @override
  String get ticketDoneReportTitle => 'Hisobot tasdiqlandi';

  @override
  String get ticketDoneReport => 'Hisobot shu yerda saqlanadi.';

  @override
  String ticketDoneReportPosted(String key) {
    return 'Hisobot shu yerda saqlanadi va Jira\'dagi $key ga yuborildi.';
  }

  @override
  String get ticketStopWriting => 'Hisobot';

  @override
  String get ticketStopDone => 'Tayyor';

  @override
  String get ticketTabsLabel => 'Tiket tafsilotlari';

  @override
  String get ticketTabReview => 'Kod sharhi';

  @override
  String get ticketTabFollowUps => 'Keyingi tiketlar';

  @override
  String get ticketTabAnswers => 'Javoblar';

  @override
  String get ticketTabLessons => 'Darslar';

  @override
  String get ticketShowMore => 'Yana koʻrsatish';

  @override
  String get ticketShowLess => 'Yigʻish';

  @override
  String get ticketTranslate => 'Tarjima qilish';

  @override
  String get ticketTranslateOriginal => 'Asl til';

  @override
  String get ticketTranslating => 'Tarjima qilinmoqda… birinchi marta bir daqiqagacha vaqt oladi, keyin saqlanadi.';

  @override
  String ticketTranslateFailed(String error) {
    return 'Tarjima qilib boʻlmadi: $error';
  }

  @override
  String get ticketSrcPlane => 'Plane';

  @override
  String ticketReviewSubPlane(String branch) {
    return 'Serverdan hali hech narsa chiqmadi. Tasdiqlash $branch ni yuboradi, pull request ochadi va Plane vazifasini yangilaydi.';
  }

  @override
  String get ticketReviewReportSubPlane =>
      'Tasdiqlash hisobotni shu yerda saqlaydi va tiketni yopadi. U Plane\'ga faqat quyidagi belgini qoʻysangiz yuboriladi.';

  @override
  String ticketPostReportPlane(String key) {
    return 'Hisobotni Plane\'dagi $key ga izoh sifatida ham joylash';
  }

  @override
  String ticketApproveReportPostConfirmPlane(String key) {
    return 'Hisobot tasdiqlansin, tiket yopilsin va hisobot Plane\'dagi $key ga joylansinmi?';
  }

  @override
  String ticketDoneReportPostedPlane(String key) {
    return 'Hisobot shu yerda saqlandi va Plane\'dagi $key ga joylandi.';
  }

  @override
  String get ticketPickAny => 'Mos keladiganlarning barchasini tanlang';

  @override
  String get ticketOtherAnswer => 'Boshqa narsa (ixtiyoriy)';

  @override
  String get ticketsTitle => 'Tiketlar';

  @override
  String get ticketsNeedsYou => 'Sizni kutmoqda';

  @override
  String get ticketsRunning => 'Bajarilmoqda';

  @override
  String get ticketsFinished => 'Yakunlangan';

  @override
  String get ticketsAll => 'Barchasi';

  @override
  String get ticketsEmpty => 'Bu yerda tiketlar yoʻq.';

  @override
  String ticketsEmptyHint(String label) {
    return 'Jira vazifasiga “$label” belgisini qoʻying, agnts uni oladi.';
  }

  @override
  String ticketsUpdated(String time) {
    return 'Yangilandi $time';
  }

  @override
  String get ticketsColTicket => 'Tiket';

  @override
  String get ticketsColSource => 'Manba';

  @override
  String get ticketsColRepo => 'Repozitoriy';

  @override
  String get ticketsColStatus => 'Holat';

  @override
  String get ticketsColUpdated => 'Yangilangan';

  @override
  String get ticketsSourceJira => 'Jira';

  @override
  String get ticketsSourceTask => 'Vazifa';

  @override
  String ticketsRev(String n) {
    return 'rev $n';
  }

  @override
  String ticketsCount(num n) {
    return '$n ta tiket';
  }

  @override
  String get ticketsViewLabel => 'Koʻrinish';

  @override
  String get ticketsViewTable => 'Jadval';

  @override
  String get ticketsViewBoard => 'Doska';

  @override
  String get ticketsBoardEmpty => 'Boʻsh';

  @override
  String get ticketsListSub => 'agnts belgili Jira va Plane tiketlari hamda shaxsiy loyihalaringiz uchun yaratgan vazifalaringiz.';

  @override
  String get ticketsNoMatch => 'Qidiruvingiz boʻyicha tiket topilmadi.';

  @override
  String get ticketsEmptyNeeds =>
      'Hozir sizni hech narsa kutmayapti. agnts savol bersa yoki oʻzgarishlarni tekshirishingiz kerak boʻlsa, tiketlar shu yerda chiqadi.';

  @override
  String get ticketsEmptyOther => 'Bu yerda hozircha tiket yoʻq.';

  @override
  String get ticketsStatNeeds => 'Sizni kutmoqda';

  @override
  String get ticketsStatNeedsNote => 'Javob yoki tekshiruv kutilmoqda';

  @override
  String get ticketsStatRunning => 'Bajarilmoqda';

  @override
  String get ticketsStatRunningNote => 'Hozir konteynerlarda';

  @override
  String get ticketsStatPushed => 'Shu hafta yuborilgan';

  @override
  String get ticketsStatPushedNote => 'Ochilgan pull requestlar';

  @override
  String get ticketsStatSession => 'Tarif sessiyasi';

  @override
  String get ticketsSourcePlane => 'Plane';

  @override
  String get usageTitle => 'Tarif limitlari';

  @override
  String get usageLede =>
      'agnts Claude obunangizda ishlaydi. Bu limitlar Claude va Claude Code\'dan oʻzingiz foydalanishingiz bilan umumiy.';

  @override
  String get usageCard => 'Tarif limitlari';

  @override
  String usageUpdated(String time) {
    return 'Yangilandi $time';
  }

  @override
  String get usageNoReading => 'Hali maʼlumot yoʻq';

  @override
  String get usageRefresh => 'Yangilash';

  @override
  String get usageRefreshing => 'Yangilanmoqda…';

  @override
  String get usageRefreshStarted => 'Yangilash boshlandi. Yangi raqamlar bir daqiqada keladi.';

  @override
  String get usageSession => 'Joriy sessiya';

  @override
  String get usageWeek => 'Shu hafta';

  @override
  String get usageUnknown => 'Limitlar nomaʼlum';

  @override
  String usageResetsIn(String time) {
    return '$time dan keyin yangilanadi';
  }

  @override
  String usageResetsAt(String time) {
    return 'Yangilanish $time';
  }

  @override
  String get usageResettingNow => 'Hozir yangilanmoqda';

  @override
  String get usageNoReset => 'Yangilanish vaqti nomaʼlum';

  @override
  String get usageWarn80 => 'Sessiyadan foydalanish 80% dan yuqori. Yangi ishlar tugashidan oldin pauzaga tushishi mumkin.';

  @override
  String usagePaused(String time) {
    return 'Yangi ishlar tarif limiti sababli $time gacha toʻxtatilgan.';
  }

  @override
  String get usagePausedNoTime => 'Yangi ishlar tarif limiti sababli toʻxtatilgan.';

  @override
  String get usageStatus => 'Holat';

  @override
  String get usageStatus_allowed => 'Ruxsat berilgan';

  @override
  String get usageStatus_allowed_warning => 'Limitga yaqin';

  @override
  String get usageStatus_rejected => 'Limit tugagan';

  @override
  String get usageStatus_unknown => 'Nomaʼlum';

  @override
  String get usageSource =>
      'Claude Code limit hodisalaridan olinadi. Ushbu hisobdagi Claude\'dan oʻzingiz foydalanishingizni ham oʻz ichiga oladi.';

  @override
  String get usageLimitTitle => 'Limitga yetilganda';

  @override
  String get usageLimitSub => 'Limitga yaqin agnts qanday ishlaydi';

  @override
  String usageAbove(String pct) {
    return 'Sessiyaning $pct% dan yuqori';
  }

  @override
  String get usageAboveDo => 'Yangi ish boshlanmaydi; boshlanganlari davom etadi';

  @override
  String get usageMidRun => 'Ish davomida limitga yetildi';

  @override
  String get usageMidRunDo => 'Pauza, branch saqlanadi';

  @override
  String get usageAfterReset => 'Yangilangandan keyin';

  @override
  String get usageResumeAuto => 'Toʻxtatilgan ishlarni avtomatik davom ettirish';

  @override
  String get usageResumeManual => 'Siz davom ettirishingizni kutish';

  @override
  String get usageIdle => 'Boʻsh vaqtda yangilash';

  @override
  String get usageIdleDo => 'Har 30 daqiqada';

  @override
  String get usageHelp =>
      'Raqamlar Claude Code har bir ish davomida yuboradigan limit hodisalaridan olinadi. agnts boʻsh turganda kichik yangilash ishi ularni dolzarb saqlaydi.';
}
