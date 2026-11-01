// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get accountSignupTitle => 'Hisob yarating';

  @override
  String get accountSignupLede => 'Boshlash uchun sizda o‘z ish maydoningiz bo‘ladi.';

  @override
  String accountSignupInviteLede(String workspace) {
    return '$workspace ga qo‘shilish uchun hisob yarating.';
  }

  @override
  String get accountSignupClosed => 'Bu serverda ro‘yxatdan o‘tish faqat taklif orqali. Ish maydoni egasidan taklif havolasini so‘rang.';

  @override
  String get accountFirstUser => 'Bu birinchi hisob: u platforma administratori bo‘ladi.';

  @override
  String get accountEmail => 'Pochta';

  @override
  String get accountDisplayName => 'Ismingiz';

  @override
  String get accountUsername => 'Foydalanuvchi nomi';

  @override
  String get accountUsernameHelp => 'Ixtiyoriy; bo‘sh bo‘lsa, pochtadan olinadi.';

  @override
  String get accountPassword => 'Parol';

  @override
  String get accountPasswordHelp => 'Kamida 12 ta belgi.';

  @override
  String get accountPasswordAgain => 'Parolni takrorlang';

  @override
  String get accountPasswordsDiffer => 'Parollar mos emas.';

  @override
  String get accountWorkspaceName => 'Ish maydoni nomi';

  @override
  String get accountWorkspaceNameHelp => 'Birinchi ish maydoningiz, masalan loyihangiz nomi. Keyin nomini o‘zgartirish mumkin.';

  @override
  String get accountCreate => 'Hisob yaratish';

  @override
  String get accountCreating => 'Yaratilmoqda…';

  @override
  String get accountHaveAccount => 'Hisobingiz bormi?';

  @override
  String get accountSignIn => 'Kirish';

  @override
  String get accountNoAccount => 'Hali hisobingiz yo‘qmi?';

  @override
  String get accountSignUp => 'Yaratish';

  @override
  String get accountForgot => 'Parolni unutdingizmi?';

  @override
  String get accountForgotTitle => 'Parolni tiklash';

  @override
  String get accountForgotLede => 'Yangi parol tanlash uchun havola yuboramiz.';

  @override
  String get accountForgotSend => 'Havola yuborish';

  @override
  String get accountForgotSent => 'Agar bu pochta hisobga tegishli bo‘lsa, havola yo‘lda. U bir soat amal qiladi.';

  @override
  String get accountResetTitle => 'Yangi parol tanlang';

  @override
  String get accountResetSave => 'Parolni saqlash';

  @override
  String get accountResetDone => 'Parol o‘zgartirildi. Barcha seanslar yopildi.';

  @override
  String get accountVerifyTitle => 'Pochtani tasdiqlash';

  @override
  String get accountVerifying => 'Tasdiqlanmoqda…';

  @override
  String get accountVerified => 'Pochtangiz tasdiqlandi.';

  @override
  String get accountVerifyFailed => 'Havola noto‘g‘ri yoki muddati o‘tgan.';

  @override
  String get accountContinue => 'Davom etish';

  @override
  String accountInviteTitle(String workspace) {
    return '$workspace ga qo‘shilish';
  }

  @override
  String accountInviteBy(String name) {
    return 'Sizni $name taklif qildi.';
  }

  @override
  String accountInviteFor(String email) {
    return 'Taklif $email uchun.';
  }

  @override
  String get accountInviteJoin => 'Qo‘shilish';

  @override
  String get accountInviteJoining => 'Qo‘shilmoqda…';

  @override
  String get accountInviteInvalid => 'Taklif havolasi noto‘g‘ri yoki muddati o‘tgan. Yangisini so‘rang.';

  @override
  String get accountInviteSignInFirst => 'Qo‘shilish uchun kiring yoki hisob yarating.';

  @override
  String get accountWorkspacesTitle => 'Ish maydonlaringiz';

  @override
  String get accountWorkspacesLede => 'Ish maydoni — bitta loyiha: uning repozitoriylari, tiketlari, a’zolari va sozlamalari.';

  @override
  String get accountNoWorkspaces =>
      'Siz hali hech bir ish maydonida emassiz. O‘zingiznikini yarating yoki sizga yuborilgan taklif havolasini oching.';

  @override
  String get accountOpen => 'Ochish';

  @override
  String get accountCreateWorkspace => 'Ish maydoni yaratish';

  @override
  String get accountCreateWorkspaceSub => 'Siz uning egasi bo‘lasiz.';

  @override
  String get accountWorkspaceSlug => 'Manzil';

  @override
  String get accountWorkspaceSlugHelp => 'Havolalarda ishlatiladi; bo‘sh bo‘lsa, nomdan olinadi.';

  @override
  String get accountCreateWs => 'Ish maydoni yaratish';

  @override
  String get accountProfileTitle => 'Profil';

  @override
  String get accountProfile => 'Profilingiz';

  @override
  String get accountProfileSub => 'Ish maydonlaringiz a’zolari sizni qanday ko‘radi.';

  @override
  String get accountSaveProfile => 'Saqlash';

  @override
  String get accountProfileSaved => 'Profil saqlandi';

  @override
  String get accountEmailUnverified => 'Hali tasdiqlanmagan';

  @override
  String get accountEmailVerified => 'Tasdiqlangan';

  @override
  String get accountResend => 'Havolani qayta yuborish';

  @override
  String get accountResent => 'Tasdiqlash havolasi yuborildi';

  @override
  String get accountPasswordTitle => 'Parol';

  @override
  String get accountPasswordSub => 'O‘zgartirilsa, boshqa seanslaringiz yopiladi.';

  @override
  String get accountCurrentPassword => 'Joriy parol';

  @override
  String get accountNewPassword => 'Yangi parol';

  @override
  String get accountChangePassword => 'Parolni o‘zgartirish';

  @override
  String get accountPasswordChanged => 'Parol o‘zgartirildi';

  @override
  String get accountTotpTitle => 'Ikki bosqichli kirish';

  @override
  String get accountTotpSub => 'Har kirishda autentifikator ilovasidan kod.';

  @override
  String get accountTotpOn => 'Yoqilgan';

  @override
  String get accountTotpOff => 'O‘chirilgan';

  @override
  String get accountTotpSetup => 'Yoqish';

  @override
  String get accountTotpScan =>
      'Hisobni autentifikator ilovasiga sir kaliti orqali qo‘shing (yoki havolani telefonda oching), so‘ng ilova ko‘rsatgan kodni kiriting.';

  @override
  String get accountTotpSecret => 'Sir kaliti';

  @override
  String get accountTotpLink => 'Sozlash havolasi';

  @override
  String get accountTotpCode => 'Kod';

  @override
  String get accountTotpConfirm => 'Tasdiqlash';

  @override
  String get accountTotpEnabled => 'Ikki bosqichli kirish yoqildi';

  @override
  String get accountTotpDisable => 'O‘chirish';

  @override
  String get accountTotpDisabled => 'Ikki bosqichli kirish o‘chirildi';

  @override
  String get accountMyClaude => 'Claude hisobingiz';

  @override
  String get accountMyClaudeSub => '«Har kimniki o‘zi» rejimidagi ish maydonlarida tiketlaringiz ishlari shundan foydalanadi.';

  @override
  String get accountClaudeSaved => 'Claude hisobi ulandi';

  @override
  String get accountClaudeRemoved => 'Claude hisobi uzildi';

  @override
  String get accountAdmin => 'Platforma administratori';

  @override
  String get accountAdminConsole => 'Operator konsolini ochish';

  @override
  String get accountReturnTitle => 'To‘lov';

  @override
  String get accountReturnLede =>
      'Rahmat. To‘lov tizimi to‘lovni tasdiqlashi bilan kreditlar «To‘lov» bo‘limida ko‘rinadi (odatda bir daqiqa ichida).';

  @override
  String get accountReturnBack => 'To‘lovga qaytish';

  @override
  String get accountLastOpened => 'Oxirgi ochilgan';

  @override
  String accountMemberCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n a\'zo', one: '$n a\'zo');
    return '$_temp0';
  }

  @override
  String accountSlotCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n parallel ishga tushirish', one: '$n parallel ishga tushirish');
    return '$_temp0';
  }

  @override
  String get accountSuspended => 'To\'xtatilgan';

  @override
  String get accountNoWorkspacesTitle => 'Hali ish maydonlari yo\'q';

  @override
  String get accountCreateFirst => 'Birinchi ish maydoningizni yarating';

  @override
  String get accountInviteGoogle => 'Qo\'shilish uchun Google orqali davom eting. Yangimisiz? Akkauntingiz darhol yaratiladi.';

  @override
  String get accountTotpRequiredAdmin =>
      'Administrator akkauntlari uchun ikki bosqichli kirish majburiy, shuning uchun u yoqilgan holda qoladi.';

  @override
  String get accountGoHome => 'Bosh sahifaga qaytish';

  @override
  String accountBackToDashboard(String name) {
    return '$name ish maydoni bosh sahifasiga qaytish';
  }

  @override
  String get accountMyClaudeMuse => 'Sizning Muse hisobingiz';

  @override
  String get accountClaudeSavedMuse => 'Muse hisobi ulandi';

  @override
  String get accountClaudeRemovedMuse => 'Muse hisobi uzildi';

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
  String get analyticsSpendSub => 'Muse kuniga sarflagan tokenlar, kirish va chiqish';

  @override
  String get analyticsSpendTokens => 'Kirish va chiqish tokenlari';

  @override
  String get analyticsSpendCost => 'API narxlarida';

  @override
  String get analyticsSpendStages => 'Bosqichlar boʻyicha sarf';

  @override
  String get analyticsSpendStagesSub => 'Tokenlar qayerga ketgani, eng qimmati yuqorida';

  @override
  String get analyticsNoSpend => 'Bu davrda Muse ishga tushirilmagan.';

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
  String get analyticsQuality => 'Agent sifati';

  @override
  String get analyticsQualitySub =>
      'Tiketlar birinchi kodlash ishga tushirilishidagi prompt versiyasi bo‘yicha guruhlangan. Agentdagi o‘zgarish foyda berganini bilish uchun versiyalarni solishtiring.';

  @override
  String get analyticsNoQuality => 'Bu davrda kodlash ishga tushirilmagan.';

  @override
  String get analyticsColVersion => 'Prompt versiyasi';

  @override
  String get analyticsVersionUnknown => 'hisobdan oldin';

  @override
  String get analyticsColFirstPass => 'Birinchi urinishda';

  @override
  String get analyticsColFirstPassHint => 'Inson o‘zgartirish so‘ramasdan tasdiqlangan yakunlangan tiketlar';

  @override
  String get analyticsColRounds => 'Tuzatish bosqichlari';

  @override
  String get analyticsColRoundsHint => 'Ko‘rib chiqishga yetgan har bir tiket uchun insondan o‘rtacha o‘zgartirish so‘rovlari';

  @override
  String get analyticsColCIRounds => 'CI bosqichlari';

  @override
  String get analyticsColCIRoundsHint =>
      'Ko‘rib chiqishga yetgan har bir tiket uchun pull requestdagi qizil CI ishni o‘rtacha necha marta qaytargani (tuzatish bosqichlariga kirmaydi)';

  @override
  String get analyticsColFixes => 'Tekshiruv tuzatishlari';

  @override
  String get analyticsColFixesHint => 'Muvaffaqiyatsiz tekshiruvlar Muse’ga o‘rtacha necha marta qaytarilgan';

  @override
  String get analyticsColSerious => 'Jiddiy kamchiliklar';

  @override
  String get analyticsColSeriousHint => 'agnts ko‘rib chiqishi to‘suvchi yoki jiddiy muammo topgan tiketlar ulushi';

  @override
  String get analyticsColFootprint => 'Reja aniqligi';

  @override
  String get analyticsColFootprintHint => 'Tahlil oldindan aytgan o‘zgargan fayllar ulushi';

  @override
  String get analyticsColRedFlags => 'Xavfli belgilar';

  @override
  String get analyticsColRedFlagsHint =>
      'Difflarda topilgan o‘tkazib yuborilgan testlar, olib tashlangan tekshiruvlar, o‘chirilgan linterlar va shu kabilar';

  @override
  String get analyticsColSelfFixes => 'O‘z-o‘zini tuzatish';

  @override
  String get analyticsColSelfFixesHint =>
      'agnts o‘z ko‘rib chiqishi kamchiliklarni inson ko‘rishidan oldin dasturchiga necha marta qaytargan';

  @override
  String get analyticsTabOverview => 'Umumiy';

  @override
  String get analyticsTabDelivery => 'Yetkazish';

  @override
  String get analyticsTabQuality => 'Sifat';

  @override
  String get analyticsTabLearning => 'Oʻrganish';

  @override
  String get analyticsTabCost => 'Xarajat';

  @override
  String get analyticsTabRepos => 'Repozitoriylar';

  @override
  String analyticsDaysHours(String d, String h) {
    return '$d kun $h soat';
  }

  @override
  String get analyticsKpiMerged => 'Birlashtirilgan pull requestlar';

  @override
  String analyticsKpiMergedNote(String n) {
    return '$n tasi birlashtirilmasdan yopildi';
  }

  @override
  String get analyticsKpiCostPerTicket => 'Bitta tiket narxi';

  @override
  String get analyticsKpiCostPerTicketNote => 'API narxlarida, barcha bosqichlar';

  @override
  String analyticsInsightMergeRate(String pct, String closed) {
    return 'agnts pull requestlarining faqat $pct% birlashtirildi; $closed tasi birlashtirilmasdan yopildi. Sababini «Yetkazish» boʻlimida koʻring.';
  }

  @override
  String analyticsInsightSlowAnswers(String hours) {
    return 'Tiketlar agnts savollariga javobingizni taxminan $hours soat kutadi. Tezroq javob berish yetkazishni tezlashtirishning eng oson yoʻli.';
  }

  @override
  String analyticsInsightFollowUpsNoise(String pct) {
    return 'Taklif qilingan qoʻshimcha vazifalarning faqat $pct% qabul qilindi. Aksariyati rad etilmoqda.';
  }

  @override
  String analyticsInsightFlakyJob(String job, String repo, String n) {
    return '$repo dagi $job qayta ishga tushirilganda $n marta oʻtdi: beqarorga oʻxshaydi. Uni tuzatish yoki chetlatish CI vaqtini tejaydi.';
  }

  @override
  String get analyticsPrMerged => 'Birlashtirildi';

  @override
  String get analyticsPrClosed => 'Birlashtirilmasdan yopildi';

  @override
  String get analyticsPrOpened => 'Ochildi';

  @override
  String get analyticsPrOpen => 'Hali ochiq';

  @override
  String get analyticsCyclePushed => 'Olindi → yuborildi';

  @override
  String get analyticsCycleMerged => 'Olindi → birlashtirildi';

  @override
  String get analyticsSplitAnswers => 'Javob kutish';

  @override
  String get analyticsSplitReview => 'Tekshiruv kutish';

  @override
  String get analyticsSplitQueue => 'Navbatda yoki pauzada';

  @override
  String get analyticsKpiMergeRate => 'Birlashtirish ulushi';

  @override
  String analyticsKpiMergeRateNote(String merged, String closed) {
    return '$merged birlashtirildi, $closed yopildi';
  }

  @override
  String get analyticsKpiTimeToMerge => 'Birlashtirishgacha vaqt';

  @override
  String get analyticsKpiTimeToMergeNote => 'Pull requestdan birlashtirishgacha';

  @override
  String get analyticsKpiCyclePushed => 'Olindi → yuborildi';

  @override
  String get analyticsKpiCyclePushedNote => 'agnts qismidagi ish';

  @override
  String get analyticsKpiCycleMerged => 'Olindi → birlashtirildi';

  @override
  String get analyticsKpiCycleMergedNote => 'Haqiqiy yetkazish vaqti';

  @override
  String get analyticsKpiAnswer => 'Javob vaqti';

  @override
  String get analyticsKpiAnswerNote => 'agnts savollariga javob berguningizcha';

  @override
  String get analyticsTypicalNote => 'Vaqtlar odatiy qiymat (mediana): tiketlarning yarmi tezroq, yarmi sekinroq boʻlgan.';

  @override
  String get analyticsPrOutcomes => 'Pull requestlar natijasi';

  @override
  String get analyticsPrOutcomesSub =>
      'Davrda ochilgan agnts pull requestlari va ular bilan nima boʻldi; kunlik birlashtirish va yopishlar';

  @override
  String analyticsMergeSpread(String p50, String p90) {
    return 'Odatda pull request $p50 da birlashtiriladi; oʻntadan eng sekini $p90 yoki undan koʻproq vaqt oladi.';
  }

  @override
  String get analyticsStale => 'Bir haftadan ortiq ochiq';

  @override
  String get analyticsStaleSub => 'Hali hech kim birlashtirmagan yoki yopmagan pull requestlar';

  @override
  String get analyticsNoStale => 'Bir haftadan ortiq ochiq turgan pull request yoʻq.';

  @override
  String analyticsOpenDays(num n) {
    return '$n kundan beri ochiq';
  }

  @override
  String get analyticsOpenPr => 'Pull requestni ochish';

  @override
  String get analyticsCycle => 'Sikl vaqti';

  @override
  String get analyticsCycleSub => 'Tiketni olishdan yuborish va birlashtirishgacha boʻlgan odatiy vaqt, kunlar boʻyicha';

  @override
  String analyticsCycleSpread(String pushed, String pushed90, String merged, String merged90) {
    return 'Odatda $pushed da yuboriladi (oʻntadan eng sekini $pushed90); $merged da birlashtiriladi ($merged90).';
  }

  @override
  String get analyticsQuestions => 'Savollar';

  @override
  String get analyticsQuestionsSub => 'agnts koddan oldin nima soʻragani va javobni qanchalik tez olgani';

  @override
  String get analyticsQuestionsAsked => 'Berilgan savollar';

  @override
  String get analyticsQuestionsShare => 'Savolli tiketlar';

  @override
  String get analyticsAnswerTypical => 'Odatiy javob vaqti';

  @override
  String get analyticsAnswerSlow => 'Oʻntadan eng sekini';

  @override
  String get analyticsUnanswered => 'Hozir javob kutmoqda';

  @override
  String get analyticsSlowest => 'Eng sekin tiketlar';

  @override
  String get analyticsSlowestSub => 'Davrda olishdan yuborishgacha eng koʻp vaqt olgan tiketlar va vaqt qayerga ketgani';

  @override
  String get analyticsNoSlowest => 'Bu davrda hech bir tiket yuborilmadi.';

  @override
  String get analyticsKpiCiSeen => 'CI xatolari';

  @override
  String analyticsKpiCiSeenNote(String n) {
    return 'Davrda $n ta yangi';
  }

  @override
  String get analyticsKpiCiAuto => 'agnts tuzatgan';

  @override
  String analyticsKpiCiAutoNote(String auto, String fixed) {
    return '$fixed ta tuzatilgandan $auto tasi';
  }

  @override
  String get analyticsKpiCiFix => 'Tuzatish vaqti';

  @override
  String get analyticsKpiCiFixNote => 'Birinchi xatodan birlashtirilgan tuzatishgacha';

  @override
  String get analyticsKpiCiFlaky => 'Beqaror xatolar';

  @override
  String get analyticsKpiCiFlakyNote => 'Qayta ishga tushirilganda oʻtdi';

  @override
  String get analyticsKpiCiOwn => 'Oʻz PRlari tuzatildi';

  @override
  String get analyticsKpiCiOwnNote => 'agnts PRlaridagi qizil tekshiruvlar tekshiruvdan oldin tuzatildi';

  @override
  String get analyticsCiUnknown => 'Tasniflanmagan';

  @override
  String get analyticsCiNew => 'Yangi xatolar';

  @override
  String get analyticsCiFixed => 'Tuzatildi';

  @override
  String get analyticsCiTitle => 'CI holati';

  @override
  String analyticsCiSub(String n) {
    return 'Kunlik yangi va tuzatilgan CI xatolari. Hozir eʼtibor talab qiladi: $n.';
  }

  @override
  String get analyticsCiOffSub =>
      'CI kuzatuvi sozlanmagan. Uni repozitoriy uchun yoqing — agnts qizil buildlarni tahlil qiladi va kod sabab boʻlganlarini tuzatadi.';

  @override
  String get analyticsCiSetUp => 'CI kuzatuvini sozlash';

  @override
  String get analyticsCiOpen => 'CI ni ochish';

  @override
  String get analyticsCiClasses => 'Xatolar sabablari';

  @override
  String get analyticsCiClassesSub => 'Tahlil har bir xatoni nima deb topgani';

  @override
  String get analyticsCiNone => 'Bu davrda CI xatolari boʻlmadi.';

  @override
  String get analyticsCiFlakiest => 'Eng beqaror vazifalar';

  @override
  String get analyticsCiFlakiestSub => 'Eng koʻp yiqilib, qayta ishga tushirilganda oʻtgan vazifalar';

  @override
  String get analyticsCiNoFlaky => 'Bu davrda beqaror vazifalar boʻlmadi.';

  @override
  String get analyticsColJob => 'Vazifa';

  @override
  String get analyticsColFailure => 'Xato';

  @override
  String get analyticsColFlaky => 'Qayta ishga tushirilganda oʻtdi';

  @override
  String get analyticsColFailures => 'Xatolar';

  @override
  String get analyticsKpiLessons => 'Darslar';

  @override
  String analyticsKpiLessonsNote(String n) {
    return '$n tasi oʻrganildi';
  }

  @override
  String get analyticsKpiRulesLearned => 'Oʻrganilgan qoidalar';

  @override
  String analyticsKpiRulesLearnedNote(String n) {
    return 'Ishlatilmoqda, tiketlardan taklif qilingan $n tadan';
  }

  @override
  String get analyticsKpiRulesManual => 'Yozilgan qoidalar';

  @override
  String get analyticsKpiRulesManualNote => 'Odamlar qoʻshgan';

  @override
  String get analyticsKpiReflections => 'Tahlillar';

  @override
  String analyticsKpiReflectionsNote(String n) {
    return 'Oʻzgartirilgan yoki rad etilgan tiketlar boʻyicha; $n ta qoida taklif qilindi';
  }

  @override
  String get analyticsKpiFollowUps => 'Qabul qilingan qoʻshimchalar';

  @override
  String analyticsKpiFollowUpsNote(String n) {
    return 'Davrda $n ta taklif qilindi';
  }

  @override
  String get analyticsKpiReviewerNotes => 'Tekshiruvchi izohlari';

  @override
  String get analyticsKpiReviewerNotesNote => 'Qayta tekshiruvlar, rad etilgan topilmalar va izohlar';

  @override
  String get analyticsLearningNote =>
      'agnts fikringizdan qanday oʻrganadi: vaqt oʻtib izohlar kamayib, qabul qilingan qoidalar koʻpaysa — oʻrganish ishlayapti.';

  @override
  String get analyticsFollowUps => 'Qoʻshimcha vazifalar turlari';

  @override
  String get analyticsFollowUpsSub => 'agnts davrda taklif qilgan qoʻshimcha tiketlar va qarorlaringiz';

  @override
  String get analyticsNoFollowUps => 'Bu davrda qoʻshimcha vazifalar taklif qilinmadi.';

  @override
  String get analyticsColType => 'Tur';

  @override
  String get analyticsColSuggested => 'Taklif qilindi';

  @override
  String get analyticsColAccepted => 'Qabul qilindi';

  @override
  String get analyticsColDismissed => 'Rad etildi';

  @override
  String get analyticsColOpen => 'Ochiq';

  @override
  String get analyticsColAcceptRate => 'Qabul ulushi';

  @override
  String get analyticsFollowUpSources => 'Qoʻshimchalar manbai';

  @override
  String get analyticsFollowUpSourcesSub => 'Taklif qilingan qoʻshimchalar ularni topgan bosqich boʻyicha';

  @override
  String get analyticsLessons => 'Mavzular boʻyicha darslar';

  @override
  String analyticsLessonsSub(String n) {
    return 'Davrda yozilgan darslar; $n tasi oʻrganildi';
  }

  @override
  String get analyticsOpenLearn => 'Oʻrganishni ochish';

  @override
  String get analyticsNoLessons => 'Bu davrda darslar yoʻq.';

  @override
  String get analyticsReviewers => 'Tekshiruvchilar';

  @override
  String get analyticsReviewersSub => 'Kod tekshiruvlarida agntsga eng koʻp fikr bildiradiganlar';

  @override
  String get analyticsOpenRules => 'Qoidalarni ochish';

  @override
  String get analyticsNoReviewers => 'Bu davrda tekshiruvchi izohlari yoʻq.';

  @override
  String get analyticsColReviewer => 'Tekshiruvchi';

  @override
  String get analyticsColRereview => 'Qayta tekshiruvlar';

  @override
  String get analyticsColRereviewHint => 'Tekshiruvchi agntsdan qayta koʻrib chiqishni necha marta soʻragani';

  @override
  String get analyticsColDismissedNotes => 'Rad etildi';

  @override
  String get analyticsColDismissedNotesHint => 'Tekshiruvchi rad etgan agnts tekshiruvi topilmalari';

  @override
  String get analyticsColManual => 'Izohlar';

  @override
  String get analyticsColManualHint => 'Tekshiruvchi qoʻlda yozgan izohlar';

  @override
  String get analyticsColRepos => 'Repozitoriylar';

  @override
  String get analyticsKpiCostNote => 'Davrdagi barcha Muse chaqiruvlari';

  @override
  String analyticsKpiDaysAboveNote(String n) {
    return 'Sessiya limitining 80% dan oshgan kunlar: $n';
  }

  @override
  String get analyticsColCost => 'Xarajat';

  @override
  String get analyticsColMergeRate => 'Birlashtirish ulushi';

  @override
  String get analyticsColMergeRateHint => 'Davrda birlashtirilgan yoki yopilganlar ichida birlashtirilgan pull requestlar';

  @override
  String get analyticsColQuestions => 'Tiketga savollar';

  @override
  String get analyticsColQuestionsHint =>
      'Tahlil qilingan bitta tiketga agnts savollari. Savollar koʻp boʻlsa, CLAUDE.md yoki qoidalar yetishmaydi.';

  @override
  String get analyticsColCi => 'CI xatolari';

  @override
  String get analyticsColCiHint => 'Davrdagi CI xato guruhlari';

  @override
  String get analyticsTabAssistant => 'Yordamchi';

  @override
  String get analyticsColScore => 'Ball';

  @override
  String get analyticsColScoreHint =>
      '0–100: birinchi urinishda tayyor 35%, birlashtirilgan 25%, jiddiy kamchiliksiz 20%, kam tuzatish bosqichi 20%. Yangi versiyalar pull requestlari birlashtirilguncha pastroq ball oladi.';

  @override
  String get analyticsColCostMerged => '\$/birlashtirilgan';

  @override
  String get analyticsColCostMergedHint => 'Versiyadagi barcha tiketlar narxi, birlashtirilganlar soniga bo‘lingan';

  @override
  String get analyticsFewTickets => '10 tadan kam tiket: solishtirish uchun juda oz';

  @override
  String get analyticsColPeopleEdited => 'Odamlar tuzatishi';

  @override
  String get analyticsColPeopleEditedHint =>
      'Birlashtirishdan oldin odamlar o‘zgartirgan yoki olib tashlagan agnts qatorlarining o‘rtacha ulushi. Qanchalik kam bo‘lsa, shuncha yaxshi.';

  @override
  String get analyticsColReverted => 'Bekor qilingan';

  @override
  String get analyticsColRevertedHint => 'Birlashtirilgan ishi odamlar tomonidan bekor qilingan tiketlar';

  @override
  String get appName => 'agnts';

  @override
  String get appTagline => 'Hech uxlamaydigan agentingiz';

  @override
  String get authTitle => 'Kirish';

  @override
  String get authLede => 'Pochta yoki foydalanuvchi nomi va parol bilan kiring.';

  @override
  String get authUsername => 'Pochta yoki foydalanuvchi nomi';

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
  String get authCodeLede => 'Autentifikator ilovasidagi kodni kiriting.';

  @override
  String get authBack => 'Boshqa hisob';

  @override
  String get authOr => 'yoki';

  @override
  String get authGoogleRedirecting => 'Kirilmoqda…';

  @override
  String get authGoogleUnavailable => 'Google orqali kirishni yuklab bo\'lmadi. Internetni yoki reklama blokerini tekshiring.';

  @override
  String get authGoogleFailed => 'Google orqali kirish amalga oshmadi. Qayta urinib ko\'ring.';

  @override
  String get authGoogleClosed => 'Bu serverda ro\'yxatdan o\'tish faqat taklif orqali: ish maydoni egasidan taklif havolasini so\'rang.';

  @override
  String get authGoogleRateLimited => 'Juda ko\'p urinish. Bir daqiqa kutib, qayta urinib ko\'ring.';

  @override
  String get authGoogleError => 'Google orqali kirishda xatolik yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get authUseGoogle => 'Bu yerda parollar faqat administratorlar uchun. Google orqali kiring.';

  @override
  String get authAdminsLede => 'Administratorlar parol bilan kiradi. Qolganlar Google orqali davom etadi.';

  @override
  String get authGoogleInvite => 'Taklif havolasi yaroqsiz, allaqachon ishlatilgan, muddati o\'tgan yoki boshqa Google akkaunti uchun.';

  @override
  String get authGoogleAdmin => 'Bu administrator akkaunti: administratorlar login va parol bilan kiradi.';

  @override
  String get authSetupLede =>
      'Administratorlar ikki bosqichli himoya bilan kiradi. Kodni autentifikator ilovasida (Google Authenticator, 1Password, Authy) skanerlang va u ko\'rsatgan 6 xonali kodni kiriting.';

  @override
  String get authSignOutBodyGoogle => 'Istalgan vaqtda Google orqali qayta kirishingiz mumkin.';

  @override
  String get billingTitle => 'To‘lov';

  @override
  String get billingSelfHosted =>
      'Bu server mustaqil o‘rnatilgan: to‘lash shart emas. Bir vaqtdagi ishlar sonini quyida belgilang; a’zolar limitini administrator belgilaydi.';

  @override
  String get billingPlan => 'Tarif';

  @override
  String billingPlanSub(String members) {
    return 'Asosiy tarifga 1 ta parallel ish va $members ta a’zo kiradi.';
  }

  @override
  String billingMonthly(String amount) {
    return 'Oyiga $amount';
  }

  @override
  String billingPaidUntil(String date) {
    return '$date gacha to‘langan';
  }

  @override
  String billingTrialUntil(String date) {
    return '$date gacha bepul sinov';
  }

  @override
  String get billingSlots => 'Parallel ishlar';

  @override
  String billingSlotsHelp(String price) {
    return 'Har bir qo‘shimcha bir vaqtdagi ish oyiga $price turadi. Qo‘shilganda oyning qolgan qismi kreditlardan yechiladi.';
  }

  @override
  String billingSlotsHelpSelfHosted(String max) {
    return 'Bu ish maydonida bir vaqtda nechta ish bajariladi; bu serverda bepul. Ko‘pi bilan $max; chegarani serverdagi AGNTS_MAX_SLOTS belgilaydi.';
  }

  @override
  String get billingSlotsSave => 'O‘zgartirish';

  @override
  String billingSlotsSaved(String n) {
    return 'Parallel ishlar: $n';
  }

  @override
  String get billingMembers => 'A’zolar';

  @override
  String billingMembersHelp(String included, String price) {
    return '$included tasi kiradi; har bir qo‘shimchasi oyiga $price.';
  }

  @override
  String get billingCredits => 'Kreditlar';

  @override
  String get billingCreditsSub =>
      'agnts API kalitidagi ishlar (zaxira variant) kredit sarflaydi: 1 kredit — Anthropic API narxining \$0.01 qismi. Oylik tarif ham shulardan to‘lanadi.';

  @override
  String get billingBalance => 'Balans';

  @override
  String billingCreditPrice(String price) {
    return '1 kredit = $price';
  }

  @override
  String get billingBuy => 'Kredit sotib olish';

  @override
  String get billingAmount => 'Summa (so‘m)';

  @override
  String billingYouGet(String n) {
    return '≈ $n kredit';
  }

  @override
  String billingPayWith(String provider) {
    return '$provider orqali to‘lash';
  }

  @override
  String get billingPaymentsOff => 'Bu serverda to‘lov hali sozlanmagan; administratordan kredit berishni so‘rang.';

  @override
  String get billingHistory => 'Tarix';

  @override
  String get billingNoHistory => 'Hozircha hech narsa yo‘q.';

  @override
  String get billingReason_purchase => 'Sotib olindi';

  @override
  String get billingReason_run => 'Sarflandi';

  @override
  String get billingReason_refund => 'Qaytarildi';

  @override
  String get billingReason_grant => 'Berildi';

  @override
  String get billingReason_document => 'Hujjatga sarflandi';

  @override
  String get billingFreeCredits => 'Bepul kreditlaringiz';

  @override
  String get billingFreeCreditsSub => 'agnts’dan. agnts’ning Muse kalitidagi ishlar ularni ish maydoni kreditlaridan oldin sarflaydi.';

  @override
  String billingFreeCreditsLeft(String n, String limit) {
    return '$limit kreditdan $n tasi qoldi';
  }

  @override
  String billingFreeCreditsWorth(String amount, String total) {
    return '$total dan $amount';
  }

  @override
  String get billingFreeCreditsNone =>
      'Hozircha yo‘q. Administrator sizga agnts’ning Muse kalitidagi ishlar uchun bepul kredit berishi mumkin.';

  @override
  String get billingLimitsTitle => 'Bu oydagi limitlaringiz';

  @override
  String get billingLimitsSub => 'agnts’ning Muse kalitidagi ishlar uchun administrator belgilaydi. Har oyning 1-sanasida yangilanadi.';

  @override
  String billingMonthLimit(String used, String limit) {
    return '$limit kreditdan $used tasi ishlatildi';
  }

  @override
  String get briefTitle => 'Repozitoriy tavsifi';

  @override
  String get briefSub =>
      'Bu kod bazasi qanday ishlaydi: arxitektura, odatiy o‘zgarishlar uchun retseptlar, namuna fayllar, kelishuvlar va tuzoqlar. Bu repozitoriy tiketlarining har bir ishga tushirilishi uni o‘qiydi, shunda agnts jamoangiz qanday qilsa, shunday quradi.';

  @override
  String get briefSurvey => 'O‘rganish';

  @override
  String get briefUpdate => 'Yangilash';

  @override
  String get briefEdit => 'Tahrirlash';

  @override
  String get briefWrite => 'O‘zingiz yozish';

  @override
  String get briefSave => 'Tavsifni saqlash';

  @override
  String get briefCancel => 'Bekor qilish';

  @override
  String get briefEditHint => 'Markdown. Saqlaganingizni bundan keyin ishga tushirishlar o‘qiydi; tavsif bermaslik uchun bo‘sh qoldiring.';

  @override
  String get briefNone => 'Hali tavsif yo‘q. Muse qoralama yozishi uchun repozitoriyni o‘rganing yoki o‘zingiz yozing.';

  @override
  String get briefSurveying => 'Muse repozitoriyni o‘rganmoqda. Qoralama tasdiqlashingiz uchun shu yerda paydo bo‘ladi.';

  @override
  String briefFailed(String error) {
    return 'Oxirgi o‘rganish muvaffaqiyatsiz tugadi: $error';
  }

  @override
  String briefApproved(String time) {
    return 'Tasdiqlangan: $time';
  }

  @override
  String briefAtCommit(String sha) {
    return '$sha kommitida';
  }

  @override
  String briefMerges(String n, String of) {
    return 'keyingi yangilanishgacha $of ta birlashtirishdan $n tasi';
  }

  @override
  String get briefDraftTitle => 'O‘rganishdan keyingi qoralama';

  @override
  String briefDraftSub(String time) {
    return '$time yozilgan. Ishga tushirishlar uni faqat siz tasdiqlaganingizdan keyin o‘qiydi.';
  }

  @override
  String get briefApprove => 'Tasdiqlash';

  @override
  String get briefDiscard => 'Qoralamani o‘chirish';

  @override
  String get briefDiscardBody => 'Qoralama o‘chiriladi; tasdiqlangan tavsif o‘zgarmaydi.';

  @override
  String get briefStatus_pending => 'O‘rganish navbatda';

  @override
  String get briefStatus_surveying => 'O‘rganilmoqda…';

  @override
  String get briefDone_survey => 'O‘rganish navbatga qo‘yildi';

  @override
  String get briefDone_approve => 'Tavsif tasdiqlandi: yangi ishga tushirishlar uni o‘qiydi';

  @override
  String get briefDone_discard => 'Qoralama o‘chirildi';

  @override
  String get briefDone_save => 'Tavsif saqlandi';

  @override
  String get briefArchTitle => 'Arxitektura';

  @override
  String get briefArchSub =>
      'agnts ishni solishtiradigan qism: qatlamlar va ularga ruxsat etilgan importlar, umumiy yordamchilar, namuna fayllari bilan retseptlar. Ishga tushirishlar uni architecture.json sifatida o‘qiydi; qatlamlar orasidagi taqiqlangan import belgilanadi.';

  @override
  String get briefArchNone => 'Hozircha arxitektura yo‘q. Keyingi so‘rov uni tavsif bilan birga yozadi yoki o‘zingiz yozing.';

  @override
  String briefArchCounts(String layers, String helpers, String recipes) {
    return '$layers qatlam · $helpers yordamchi · $recipes retsept';
  }

  @override
  String get briefArchEdit => 'JSONni tahrirlash';

  @override
  String get briefArchEditHint =>
      'Bo‘sh qiymat uni o‘chiradi. Yo‘llar repozitoriyga nisbatan; qatlam yo‘llari shablonlar (** istalgan chuqurlik uchun); cheklovsiz qatlam uchun mayImport’ni yozmang.';

  @override
  String get briefArchDraft => 'Tavsif qoralamasi bilan birga shu arxitektura keladi; tavsifni tasdiqlash uni ham tasdiqlaydi.';

  @override
  String get briefDone_saveArch => 'Arxitektura saqlandi';

  @override
  String get ciTitle => 'CI';

  @override
  String get ciLede =>
      'Kuzatiladigan branchlardagi yiqilgan pipelinelar, job va xato boʻyicha guruhlangan. agnts yangi yiqilishni bir marta qayta ishga tushiradi, haqiqiylarini esa tuzatadi.';

  @override
  String get ciBack => 'CI';

  @override
  String get ciRepo => 'Repozitoriy';

  @override
  String get ciAllRepos => 'Barcha repozitoriylar';

  @override
  String get ciFilterLabel => 'Holat';

  @override
  String get ciFilter_red => 'Qizil';

  @override
  String get ciFilter_flaky => 'Beqaror';

  @override
  String get ciFilter_infra => 'Infratuzilma';

  @override
  String get ciFilter_fixed => 'Tuzatilgan';

  @override
  String get ciFilter_muted => 'Yashirilgan';

  @override
  String get ciFilter_all => 'Hammasi';

  @override
  String get ciStatus_triage => 'Yangi';

  @override
  String get ciStatus_open => 'Yiqilmoqda';

  @override
  String get ciStatus_fixing => 'Tuzatilmoqda';

  @override
  String get ciStatus_fixed => 'Tuzatish qoʻshildi';

  @override
  String get ciStatus_resolved => 'Yana yashil';

  @override
  String get ciStatus_flaky => 'Beqaror';

  @override
  String get ciStatus_infra => 'Infratuzilma';

  @override
  String get ciStatus_muted => 'Yashirilgan';

  @override
  String get ciStatus_regression => 'Regressiya';

  @override
  String get ciStatusHelp_triage => 'Yangi yiqilish, tasdiqlash uchun qayta ishga tushirishni kutmoqda';

  @override
  String get ciStatusHelp_open => 'Tasdiqlangan, uning ustida hech qanday tiket ishlamayapti';

  @override
  String get ciStatusHelp_fixing => 'Uning ustida tiket ishlamoqda';

  @override
  String get ciStatusHelp_fixed => 'Tuzatish qoʻshildi, yashil ishga tushirish kutilmoqda';

  @override
  String get ciStatusHelp_resolved => 'Branch yana yashil';

  @override
  String get ciStatusHelp_flaky => 'Qayta ishga tushirilganda oʻtdi';

  @override
  String get ciStatusHelp_infra => 'Kod emas, runner yoki tarmoq yiqildi';

  @override
  String get ciStatusHelp_muted => 'Qaytarilmaguncha eʼtiborsiz qoldiriladi';

  @override
  String get ciStatusHelp_regression => 'Tuzatish qoʻshilgandan keyin yana yiqildi';

  @override
  String get ciClass_code => 'Kod';

  @override
  String get ciClass_test => 'Test';

  @override
  String get ciClass_config => 'Sozlama';

  @override
  String get ciClass_dependency => 'Bogʻliqlik';

  @override
  String get ciClass_infra => 'Infratuzilma';

  @override
  String get ciClass_flaky => 'Beqaror';

  @override
  String get ciClass_report => 'Hisobot';

  @override
  String get ciColStatus => 'Holat';

  @override
  String get ciColFailure => 'Yiqilish';

  @override
  String get ciColCount => 'Yiqildi';

  @override
  String get ciColLastSeen => 'Oxirgi marta';

  @override
  String get ciColTicket => 'Tiket';

  @override
  String get ciColTime => 'Vaqt';

  @override
  String get ciColCommit => 'Commit';

  @override
  String get ciColJob => 'Job';

  @override
  String ciTimes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n marta', one: '$n marta');
    return '$_temp0';
  }

  @override
  String get ciFix => 'Tuzatish';

  @override
  String ciFixStarted(String key) {
    return '$key tiketi ochildi';
  }

  @override
  String get ciMute => 'Yashirish';

  @override
  String get ciUnmute => 'Qaytarish';

  @override
  String get ciMuted => 'Yashirildi: endi agnts bu yiqilishga eʼtibor bermaydi';

  @override
  String get ciUnmuted => 'Qaytarildi';

  @override
  String get ciRerun => 'Qayta ishga tushirish';

  @override
  String get ciRerunStarted => 'Qayta ishga tushirildi';

  @override
  String get ciCommentOnly => 'Faqat izoh';

  @override
  String get ciEmptyRed => 'Hech narsa qizil emas. Barcha kuzatiladigan branchlar oʻtmoqda.';

  @override
  String get ciEmptyFilter => 'Bu yerda yiqilishlar yoʻq.';

  @override
  String get ciHowTitle => 'Kuzatishni qanday boshlash kerak';

  @override
  String get ciHowWatch =>
      'Repozitoriyni oching, uning CI yorligʻiga oʻting va kuzatishni yoqing. Asosiy branch har doim kuzatiladi; release/* kabi boshqalarini qoʻshing.';

  @override
  String get ciHowWebhook =>
      'Yiqilishlardan bir necha soniyada xabar topish uchun git xostingida workflow_run (GitHub) yoki Pipeline events (GitLab) uchun webhook qoʻshing. Usiz agnts har 5 daqiqada tekshiradi.';

  @override
  String get ciNotFound => 'Bu CI yiqilishi topilmadi.';

  @override
  String ciOpenTicket(String key) {
    return '$key ni ochish';
  }

  @override
  String ciPrNote(String n) {
    return 'Bu yiqilish boshqa birovning #$n pull requestida. agnts u yerda hech qachon tiket ochmaydi va push qilmaydi; izohlar yoqilgan boʻlsa, bitta tashxis izohini qoldiradi.';
  }

  @override
  String ciRegressionNote(String sha) {
    return '$sha tuzatishini oʻz ichiga olgan commitda yana yiqildi. Asl tiketga davomiy taklif beriladi.';
  }

  @override
  String get ciLogTitle => 'Log';

  @override
  String get ciLogSub => 'Oxirgi yiqilgan ishga tushirishning tozalangan parchasi';

  @override
  String get ciLogAnnotations => 'Annotatsiyalar';

  @override
  String get ciLogFirstError => 'Birinchi xato';

  @override
  String get ciLogEnd => 'Log oxiri';

  @override
  String get ciLogTail => 'Oxirgi qatorlar';

  @override
  String get ciNoLog => 'Bu yiqilish uchun log saqlanmagan.';

  @override
  String get ciOccurrences => 'Yiqilgan ishga tushirishlar';

  @override
  String get ciOccurrencesSub => 'Bu yiqilish uchragan oxirgi 20 ta ishga tushirish';

  @override
  String get ciNoOccurrences => 'Ishga tushirishlar yozilmagan.';

  @override
  String get ciPassedOnRerun => 'Qayta ishga tushirilganda oʻtdi';

  @override
  String get ciOpenRun => 'Ishga tushirishni ochish';

  @override
  String get ciFacts => 'Tafsilotlar';

  @override
  String get ciCount => 'Yiqildi';

  @override
  String get ciFlakyCount => 'Qayta ishga tushirilganda oʻtdi';

  @override
  String get ciFirstSeen => 'Birinchi marta';

  @override
  String get ciLastSeen => 'Oxirgi marta';

  @override
  String get ciFirstSha => 'Birinchi yiqilgan commit';

  @override
  String get ciLastSha => 'Oxirgi commit';

  @override
  String get ciFixedSha => 'Tuzatish commiti';

  @override
  String get ciFixedAt => 'Tuzatish qoʻshildi';

  @override
  String get ciTicket => 'Tiket';

  @override
  String get ciBranch => 'Branch';

  @override
  String get ciWatchTitle => 'CI kuzatuvi';

  @override
  String get ciWatchSub => 'agnts bu repozitoriy pipelinelarini oʻqiydi va yiqilganini tuzatadi';

  @override
  String get ciWatchEnabled => 'CI ni kuzatish';

  @override
  String get ciWatchEnabledHelp => 'Odatda oʻchiq. Kuzatiladigan branchlardagi yiqilishlar guruhlanadi va tuzatiladi.';

  @override
  String get ciBranches => 'Qoʻshimcha branchlar';

  @override
  String ciBranchesHelp(String branch) {
    return 'Shablonlar, har qatorda bittadan. Asosiy branch ($branch) har doim kuzatiladi.';
  }

  @override
  String get ciIgnore => 'Eʼtiborsiz workflow va joblar';

  @override
  String get ciIgnoreHelp =>
      'Shablonlar, har qatorda bittadan, workflow va job nomlari bilan solishtiriladi. Boʻsh boʻlsa — *deploy*, *release* va *publish*.';

  @override
  String get ciPrs => 'Boshqalarning pull requestlari';

  @override
  String get ciPrsHelp =>
      'agnts hech qachon hamkasbning branchiga push qilmaydi. Izohlar yoqilgan boʻlsa, pull requestda bitta tashxis izohini qoldiradi.';

  @override
  String get ciPrs_off => 'Eʼtiborsiz';

  @override
  String get ciPrs_comment => 'Izoh qoldirish';

  @override
  String get ciAutoFix => 'Avtomatik tuzatish';

  @override
  String get ciAutoFixRepoHelp => 'Har bir tasdiqlangan yiqilish uchun tiket ochish yoki «Tuzatish» tugmasini kutish';

  @override
  String get ciAutoFix_inherit => 'Ish maydonidagidek';

  @override
  String get ciAutoFix_on => 'Yoqiq';

  @override
  String get ciAutoFix_off => 'Oʻchiq';

  @override
  String get ciSave => 'Saqlash';

  @override
  String get ciWatchSaved => 'CI kuzatuvi saqlandi';

  @override
  String get ciFailuresTitle => 'Yiqilishlar';

  @override
  String get ciFailuresSub => 'Bu repozitoriyning yiqilgan joblari, avval yangilari';

  @override
  String get ciFlakyTitle => 'Beqaror testlar';

  @override
  String get ciFlakySub => 'Qayta ishga tushirilganda oʻtgan yiqilishlar';

  @override
  String get ciFlakyEmpty => 'Beqaror testlar topilmadi.';

  @override
  String get ciCardTitle => 'CI yiqilishi';

  @override
  String get ciFailingRuns => 'Yiqilgan ishga tushirishlar';

  @override
  String get ciLastRun => 'Oxirgi yiqilgan ishga tushirish';

  @override
  String get ciStillFailing => 'Hali ham yiqilmoqda';

  @override
  String get ciWaitingGreen => 'Tuzatish qoʻshildi, yashil ishga tushirish kutilmoqda';

  @override
  String get ciGreenAgain => 'Yana yashil';

  @override
  String get ciOpenFailure => 'Yiqilishni ochish';

  @override
  String get ciSettingsTitle => 'CI';

  @override
  String get ciSettingsSub => 'Kuzatiladigan pipeline qizarganda agnts nima qiladi. Kuzatish har bir repozitoriy uchun alohida yoqiladi.';

  @override
  String get ciAutoFixHelp => 'Har bir tasdiqlangan yiqilish uchun tiket ochish. Oʻchiq boʻlsa, yiqilishlar «Tuzatish» tugmasini kutadi.';

  @override
  String get ciMaxAutoPerDay => 'Kuniga avtomatik tiketlar';

  @override
  String get ciMaxAutoPerDayHelp =>
      'Limitdan oshsa, yiqilishlar «Tuzatish» tugmasini kutadi. agnts oʻz pull requestlarini qayta ishlashi hisobga olinmaydi.';

  @override
  String ciPerDay(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Kuniga $n', one: 'Kuniga $n', zero: 'Hech biri');
    return '$_temp0';
  }

  @override
  String get ciRetryFlaky => 'Yangi yiqilishlarni bir marta qayta ishga tushirish';

  @override
  String get ciRetryFlakyHelp =>
      'agnts yangi yiqilishga ishonishidan oldin uning joblari yana ishga tushiriladi. Oʻtsa, beqaror deb belgilanadi.';

  @override
  String get ciFeedbackRounds => 'agnts pull requestlarini qayta ishlash';

  @override
  String get ciFeedbackRoundsHelp => 'Qizil tekshiruv agnts oʻz pull requestini necha marta qayta kodlashga qaytaradi. 0 — oʻchiq.';

  @override
  String get ciInfraPatterns => 'Infratuzilma shablonlari';

  @override
  String get ciInfraPatternsHelp =>
      'Regulyar ifodalar, har qatorda bittadan. Mos kelgan log infratuzilma yiqilishi hisoblanadi: koʻrsatiladi va sanaladi, lekin tiket ochilmaydi. Oʻrnatilganlariga qoʻshiladi.';

  @override
  String get codechatTitle => 'Kod';

  @override
  String get codechatModeLabel => 'Chat rejimi';

  @override
  String get codechatModeChat => 'Chat';

  @override
  String get codechatModeCode => 'Kod';

  @override
  String get codechatNewConversation => 'Yangi kod suhbati';

  @override
  String get codechatEmptyTitle => 'Kodni chatdan oʻzgartiring';

  @override
  String get codechatEmptyText =>
      'Repozitoriylarni tanlang va nima qilish kerakligini yozing. agnts buni tiket sifatida bajaradi: ishni shu yerda kuzating, savollarga javob bering, oʻzgarish soʻrang va pull requestni tasdiqlang.';

  @override
  String get codechatViewersOnly => 'Kod rejimi ish maydonini oʻzgartira oladiganlar uchun.';

  @override
  String get codechatRepos => 'Repozitoriylar';

  @override
  String get codechatReposNone => 'Ishlash uchun repozitoriylarni tanlang yoki xabarda @ bilan ayting';

  @override
  String get codechatReposChange => 'Oʻzgartirish';

  @override
  String get codechatReposSave => 'Repozitoriylarni saqlash';

  @override
  String get codechatReposSaved => 'Repozitoriylar oʻzgardi: keyingi tiket ularda ishlaydi';

  @override
  String get codechatKind => 'Turi';

  @override
  String get codechatQuick => 'Tez: tekshiruvlarsiz';

  @override
  String get codechatQuickHint => 'Build, lint va testlar ishlamaydi, shuning uchun koʻrib chiqish tezroq keladi.';

  @override
  String get codechatTicketPick => 'Yoki mavjud tiket ustida ishlang';

  @override
  String get codechatTicketPlaceholder => 'Tiket kaliti, masalan PAY-214';

  @override
  String get codechatTicketAttach => 'Ulash';

  @override
  String codechatTicketAttached(String key) {
    return 'Endi $key ustida ishlaymiz';
  }

  @override
  String get codechatPlaceholderNew => 'Oʻzgarishni tasvirlang…';

  @override
  String get codechatPlaceholderReview => 'Oʻzgarish soʻrang yoki yuqorida tasdiqlang…';

  @override
  String get codechatPlaceholderAnswers => 'Savolga javob bering…';

  @override
  String get codechatPlaceholderRunning => 'Soʻrovga qoʻshing: bu ishga tushirish tugaganda yuboriladi…';

  @override
  String get codechatPlaceholderStopped => 'Buni qanday chetlab oʻtishni yozing, u qayta urinadi…';

  @override
  String get codechatPlaceholderPushing => 'Yuborilmoqda…';

  @override
  String get codechatPlaceholderDone => 'Keyingi oʻzgarishni yozing…';

  @override
  String get codechatSend => 'Yuborish';

  @override
  String get codechatSendHint => 'Enter yuboradi, Shift+Enter yangi qator, @ repozitoriyni ko‘rsatadi';

  @override
  String codechatCount(String n) {
    return '$n / 4000';
  }

  @override
  String codechatRoutedCreated(String key) {
    return '$key boshlandi';
  }

  @override
  String codechatRoutedAnswered(String key) {
    return '$key savollariga javob berildi';
  }

  @override
  String codechatRoutedChanges(String key) {
    return '$key dan oʻzgarish soʻraldi';
  }

  @override
  String codechatRoutedContinued(String key) {
    return '$key davom ettirildi';
  }

  @override
  String codechatRoutedRetried(String key) {
    return '$key qayta ishga tushirildi';
  }

  @override
  String codechatRoutedQueued(String key) {
    return '$key ishga tushirishi tugashini kutmoqda';
  }

  @override
  String codechatRoutedSent(String key) {
    return '$key ga yuborildi';
  }

  @override
  String codechatRoutedFailed(String reason) {
    return 'Yuborilmadi: $reason';
  }

  @override
  String get codechatRoutedSteered => 'Ishlayotgan agentga yetkazildi';

  @override
  String codechatQueuedTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta xabar');
    return '$_temp0 bu ishga tushirish tugashini kutmoqda';
  }

  @override
  String get codechatSendNow => 'Toʻxtatib, hozir yuborish';

  @override
  String codechatSendNowTitle(String key) {
    return '$key hozir toʻxtatilsinmi?';
  }

  @override
  String get codechatSendNowText => 'Joriy bosqich toʻxtaydi va xabarlaringiz darhol tiketga ketadi.';

  @override
  String codechatSteps(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n qadam');
    return '$_temp0';
  }

  @override
  String codechatStateLine(String key, String state) {
    return '$key: $state';
  }

  @override
  String codechatCheckPassed(String name) {
    return '$name: oʻtdi';
  }

  @override
  String codechatCheckFailed(String name) {
    return '$name: xato';
  }

  @override
  String get codechatPrOpened => 'Pull request ochildi';

  @override
  String get codechatPushed => 'Yuborildi';

  @override
  String get codechatMerged => 'Birlashtirildi';

  @override
  String get codechatWorking => 'Ishlayapman…';

  @override
  String codechatResultTitle(String key) {
    return '$key koʻrib chiqishingizga tayyor';
  }

  @override
  String codechatReportTitle(String key) {
    return '$key hisobotini yozdi';
  }

  @override
  String codechatFilesChanged(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta fayl oʻzgardi');
    return '$_temp0';
  }

  @override
  String get codechatChecksPassed => 'Tekshiruvlar oʻtdi';

  @override
  String codechatChecksFailed(String failed, String n) {
    return '$n tadan $failed ta tekshiruv oʻtmadi';
  }

  @override
  String get codechatChecksSkipped => 'Tekshiruvlar oʻtkazib yuborildi';

  @override
  String get codechatViewDiff => 'Diffni koʻrsatish';

  @override
  String get codechatHideDiff => 'Diffni yashirish';

  @override
  String get codechatApprove => 'Tasdiqlash';

  @override
  String codechatApproveTitle(String key) {
    return '$key tasdiqlansinmi?';
  }

  @override
  String codechatApprovePr(String branch) {
    return 'agnts $branch ni yuboradi va pull request ochadi.';
  }

  @override
  String get codechatApproveMain => 'agnts oʻzgarishni toʻgʻridan-toʻgʻri asosiy branchga yuboradi.';

  @override
  String get codechatApproveReport => 'Tiket shu hisobot bilan yopiladi.';

  @override
  String get codechatReject => 'Rad etish';

  @override
  String codechatRejectTitle(String key) {
    return '$key rad etilsinmi?';
  }

  @override
  String get codechatRejectText => 'Undagi barcha ish toʻxtaydi. Keyinroq uni shu chatdan davom ettirish mumkin.';

  @override
  String get codechatOpenTicket => 'Tiketni ochish';

  @override
  String codechatQuestionsTitle(String key) {
    return '$key davom etishdan oldin soʻrayapti';
  }

  @override
  String get codechatAnswersSend => 'Javoblarni yuborish';

  @override
  String codechatStoppedTitle(String key) {
    return '$key toʻxtadi';
  }

  @override
  String get codechatStoppedHint => 'Buni qanday chetlab oʻtishni yozing: u maslahatingiz bilan qayta urinadi.';

  @override
  String codechatDoneTitle(String key) {
    return '$key tayyor';
  }

  @override
  String get codechatDoneHint => 'Keyingi xabaringiz oʻsha repozitoriylarda yangi tiket boshlaydi.';

  @override
  String codechatRejectedTitle(String key) {
    return '$key rad etildi';
  }

  @override
  String get codechatRejectedHint => 'Nimani boshqacha qilishni yozing va u davom etadi.';

  @override
  String codechatMovedHint(String key) {
    return '$key boshqa suhbatingizga oʻtkazildi.';
  }

  @override
  String get codechatApprovalTitle => 'Agent buni ishga tushirishga ruxsat soʻrayapti';

  @override
  String codechatApprovalReason(String reason) {
    return 'Qoida soʻrashni talab qiladi: $reason';
  }

  @override
  String get codechatApprovalAllow => 'Ruxsat berish';

  @override
  String get codechatApprovalDeny => 'Taqiqlash';

  @override
  String get codechatApprovalAllowed => 'Ruxsat berildi';

  @override
  String get codechatApprovalDenied => 'Taqiqlandi';

  @override
  String get codechatApprovalExpired => 'Javob boʻlmadi: taqiqlandi';

  @override
  String codechatApprovalLeft(String seconds) {
    return '$seconds s qoldi';
  }

  @override
  String get codechatHandoffTitle => 'Buni Kod rejimida qilish';

  @override
  String get codechatHandoffOpen => 'Kodda ochish';

  @override
  String get codechatTicketChat => 'Chatda muhokama qilinmoqda';

  @override
  String get codechatContinueInChat => 'Chatda davom ettirish';

  @override
  String get codechatCodeBadge => 'Kod';

  @override
  String codechatMentioned(String names) {
    return 'Ish joyi: $names';
  }

  @override
  String get codechatMentionLabel => 'Repozitoriylar';

  @override
  String get commitBack => 'Commitlarga qaytish';

  @override
  String commitBackTo(String repo) {
    return '$repo ga qaytish';
  }

  @override
  String commitAuthoredAgo(String name, String time) {
    return '$name $time commit qildi';
  }

  @override
  String commitFilesN(num n) {
    return '$n ta fayl';
  }

  @override
  String get commitAuthor => 'Muallif';

  @override
  String get commitAuthored => 'Yozilgan';

  @override
  String get commitCommitter => 'Commit qilgan';

  @override
  String get commitCommitted => 'Commit qilingan';

  @override
  String commitParents(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Ota commitlar', one: 'Ota commit');
    return '$_temp0';
  }

  @override
  String get commitPulls => 'Pull requestlar';

  @override
  String get commitPullsSub => 'Shu commit kirgan pull requestlar (GitLabda merge requestlar).';

  @override
  String get commitNoPulls => 'Bu commit hech qaysi pull requestda yoʻq.';

  @override
  String get commitMessage => 'Xabar';

  @override
  String get commitPipelinesSub => 'Shu commitdagi CI ishlari, yangilari yuqorida.';

  @override
  String get commitNoPipelines => 'Bu commitda CI ishlari yoʻq.';

  @override
  String get commitChanges => 'Oʻzgarishlar';

  @override
  String commitChangesSub(num n, String add, String del) {
    return '$n ta fayl oʻzgargan: +$add, −$del.';
  }

  @override
  String get commitNoFiles => 'Bu commit hech qanday faylni oʻzgartirmaydi.';

  @override
  String commitFilesCapped(String n) {
    return 'Bu commit bu yerda koʻrsatib boʻladiganidan koʻproq faylni oʻzgartiradi. Dastlabki $n tasi koʻrsatildi; hammasini git xostingida oching.';
  }

  @override
  String get commonPagePrev => 'Oldingi sahifa';

  @override
  String get commonPageNext => 'Keyingi sahifa';

  @override
  String commonPageRange(String from, String to, String n) {
    return '$n tadan $from–$to';
  }

  @override
  String get commonPerPage => 'Sahifada';

  @override
  String get commonPager => 'Sahifalar';

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
  String get designApproach => 'Yondashuv';

  @override
  String get designFit => 'Kod bazasiga mosligi';

  @override
  String designAlternatives(num n) {
    return '$n ta muqobil ko‘rib chiqildi';
  }

  @override
  String get designWhyNot => 'Nega emas';

  @override
  String get designOutOfScope => 'Vazifa doirasidan tashqari';

  @override
  String get designShipping => 'Chiqarish';

  @override
  String get designShip_migrations => 'Migratsiyalar';

  @override
  String get designShip_compatibility => 'Moslik';

  @override
  String get designShip_rollout => 'Chiqarish tartibi';

  @override
  String get designShip_rollback => 'Orqaga qaytarish';

  @override
  String get designDeviations => 'Rejadan chetlanishlar';

  @override
  String get designFitTitle => 'Mavjud kodga qanday ergashish';

  @override
  String get designKind_copy => 'nusxa';

  @override
  String get designKind_adapt => 'moslash';

  @override
  String get designKind_new => 'yangi pattern';

  @override
  String get designLike => 'kabi';

  @override
  String get designConventionsFrom => 'qoidalar manbai';

  @override
  String get designGoesIn => 'joylashuvi';

  @override
  String get designPrecedent => 'namuna bo‘ladi: keyingi ishlar undan nusxa oladi';

  @override
  String get designReuseTitle => 'Foydalaniladigan mavjud yordamchilar';

  @override
  String get designTestPlanTitle => 'Qo‘shiladigan yoki o‘zgartiriladigan testlar';

  @override
  String get designEdgeCasesTitle => 'Chegaraviy holatlar';

  @override
  String get designReproTitle => 'Xato qayta ko‘rsatildi';

  @override
  String get designReproNot => 'Tahlil xatoni qayta ko‘rsata olmadi';

  @override
  String get documentsPageTitle => 'Hujjatlar';

  @override
  String get documentsLede =>
      'Jamoa uchun hisobotlar va qaydlar: siz yozgan yoki agnts tiketlar, commitlar, pull requestlar va repozitoriylar asosida yozgan.';

  @override
  String get documentsNew => 'Yangi hujjat';

  @override
  String get documentsNewLinked => 'Yangi hujjat';

  @override
  String get documentsScope => 'Qaysi hujjatlar';

  @override
  String get documentsScope_all => 'Men ocha oladiganlar';

  @override
  String get documentsScope_mine => 'Meniki';

  @override
  String get documentsScope_shared => 'Men bilan ulashilgan';

  @override
  String get documentsScope_deleted => 'Savat';

  @override
  String get documentsEmpty => 'Hozircha hujjat yoʻq. Hujjat yarating yoki agnts’dan hisobot yozishni soʻrang.';

  @override
  String get documentsTrashEmpty => 'Savat boʻsh.';

  @override
  String get documentsColTitle => 'Nomi';

  @override
  String get documentsColOwner => 'Egasi';

  @override
  String get documentsColTickets => 'Tiketlar';

  @override
  String get documentsColUpdated => 'Yangilangan';

  @override
  String get documentsColDeleted => 'Tiklash mumkin';

  @override
  String documentsDaysLeft(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'yana $n kun', one: 'yana $n kun');
    return '$_temp0';
  }

  @override
  String get documentsRestore => 'Tiklash';

  @override
  String get documentsRestored => 'Hujjat tiklandi';

  @override
  String get documentsPublic => 'Ochiq';

  @override
  String get documentsPrivate => 'Yopiq';

  @override
  String get documentsWriting => 'agnts yozmoqda';

  @override
  String get documentsGenFailed => 'Yozib boʻlmadi';

  @override
  String get documentsAccess_none => 'Ruxsat yoʻq';

  @override
  String get documentsAccess_view => 'Koʻrish';

  @override
  String get documentsAccess_edit => 'Tahrirlash';

  @override
  String get documentsAccess_owner => 'Egasi';

  @override
  String get documentsYouCan_view => 'Siz koʻra olasiz';

  @override
  String get documentsYouCan_edit => 'Siz tahrirlay olasiz';

  @override
  String get documentsRole_owner => 'Maydon egasi';

  @override
  String get documentsRole_user => 'Aʼzo';

  @override
  String get documentsRole_viewer => 'Kuzatuvchi';

  @override
  String get documentsNewTitle => 'Yangi hujjat';

  @override
  String get documentsNewSub => 'Oʻzingiz yozing yoki agnts maydondagi maʼlumotlar asosida yozsin.';

  @override
  String get documentsTitle => 'Nomi';

  @override
  String get documentsTitlePlaceholder => '42-sprint boʻyicha hisobot';

  @override
  String get documentsWhoWrites => 'Kim yozadi';

  @override
  String get documentsByAgnts => 'agnts';

  @override
  String get documentsByMe => 'Oʻzim yozaman';

  @override
  String get documentsLanguage => 'Til';

  @override
  String get documentsSource => 'Asosi';

  @override
  String get documentsKind_report => 'Tiket hisoboti';

  @override
  String get documentsKind_tickets => 'Tiketlar';

  @override
  String get documentsKind_commits => 'Commitlar';

  @override
  String get documentsKind_pulls => 'Pull requestlar';

  @override
  String get documentsKind_repo => 'Repozitoriy';

  @override
  String get documentsKindHelp_report =>
      'Reja, tahlil, xato yoki koʻrib chiqish tiketining tasdiqlangan hisoboti, oʻquvchilar uchun qayta yozilgan.';

  @override
  String get documentsKindHelp_tickets =>
      'Tanlangan tiketlar yoki holat va davr boʻyicha tiketlar: holati, sanalari, hisobotlari va commitlari.';

  @override
  String get documentsKindHelp_commits => 'Davr ichidagi repozitoriy commitlari va ularga bogʻlangan tiketlar.';

  @override
  String get documentsKindHelp_pulls => 'Tavsifi va diffi bilan pull requestlar: koʻrib chiqish sharhi yoki reliz qaydlari.';

  @override
  String get documentsKindHelp_repo => 'agnts butun repozitoriyni izolyatsiyada oʻqiydi: arxitektura, sifat, testlar, xavflar.';

  @override
  String get documentsTicket => 'Tiket';

  @override
  String get documentsTickets => 'Tiketlar';

  @override
  String get documentsTicketsPlaceholder => 'AMANAT-12, AMANAT-15';

  @override
  String get documentsByFilter => 'Holat va davr boʻyicha';

  @override
  String get documentsChosen => 'Tanlangan tiketlar';

  @override
  String get documentsStates => 'Holatlar';

  @override
  String get documentsStatesHelp => 'Hech biri belgilanmasa — barcha holatlar. Davr oxirgi yangilanish boʻyicha cheklaydi.';

  @override
  String get documentsRepos => 'Repozitoriylar';

  @override
  String get documentsRepo => 'Repozitoriy';

  @override
  String get documentsChooseRepo => 'Repozitoriyni tanlang';

  @override
  String get documentsBranch => 'Tarmoq';

  @override
  String get documentsBranchPlaceholder => 'Asosiy tarmoq';

  @override
  String get documentsAuthor => 'Muallif';

  @override
  String get documentsAuthorPlaceholder => 'Hamma';

  @override
  String get documentsPrState => 'Pull requestlar';

  @override
  String get documentsPr_merged => 'Birlashtirilgan';

  @override
  String get documentsPr_open => 'Ochiq';

  @override
  String get documentsPr_all => 'Hammasi';

  @override
  String get documentsPrNumbers => 'Raqamlar';

  @override
  String get documentsPrNumbersHelp => 'Ixtiyoriy, bitta repozitoriyda. Boʻsh boʻlsa — holat va davr boʻyicha.';

  @override
  String get documentsFrom => 'Dan';

  @override
  String get documentsTo => 'Gacha';

  @override
  String get documentsTemplate => 'Shakl';

  @override
  String get documentsTemplate_status => 'Holat hisoboti';

  @override
  String get documentsTemplate_release_notes => 'Reliz qaydlari';

  @override
  String get documentsTemplate_pr_review => 'Pull requestlar sharhi';

  @override
  String get documentsTemplate_repo_review => 'Repozitoriy sharhi';

  @override
  String get documentsTemplate_ticket_summary => 'Xulosa';

  @override
  String get documentsTemplate_blank => 'Faqat sizning koʻrsatmangiz';

  @override
  String get documentsTemplateHint_status => 'Bajarildi, jarayonda, bloklangan, xavflar, keyingi qadamlar';

  @override
  String get documentsTemplateHint_release_notes => 'Yangi, yaxshilangan, tuzatilgan, ichki';

  @override
  String get documentsTemplateHint_pr_review => 'Har bir oʻzgarish, xavfi, nimaga qarash kerak';

  @override
  String get documentsTemplateHint_repo_review => 'Arxitektura, sifat, testlar, qarz, tavsiyalar';

  @override
  String get documentsTemplateHint_ticket_summary => 'Maqsad, xulosalar, oʻzgarishlar, ochiq savollar';

  @override
  String get documentsTemplateHint_blank => 'Koʻrsatmangiz soʻragan shakl';

  @override
  String get documentsInstruction => 'Koʻrsatma';

  @override
  String get documentsInstructionPlaceholder => 'Mijoz uchun, texnik tafsilotlarsiz. Xavflarga eʼtibor qarat.';

  @override
  String get documentsGenerate => 'agnts yozsin';

  @override
  String get documentsCreate => 'Yaratish va tahrirlash';

  @override
  String get documentsBack => 'Hujjatlar';

  @override
  String get documentsNotFound => 'Bunday hujjat yoʻq yoki uni ochishga ruxsatingiz yoʻq.';

  @override
  String get documentsEditing => 'Tahrirlash';

  @override
  String documentsVersionN(String n) {
    return '$n-versiya';
  }

  @override
  String documentsOwnedBy(String name) {
    return 'Egasi: $name';
  }

  @override
  String documentsDataAsOf(String when) {
    return '$when holatidagi maʼlumotlar asosida';
  }

  @override
  String get documentsEdit => 'Tahrirlash';

  @override
  String get documentsRegenerate => 'Qayta yozish';

  @override
  String get documentsRegenerateSub => 'agnts uni xuddi shu manbadan qayta yozadi. Natija yangi versiya boʻladi, hech narsa yoʻqolmaydi.';

  @override
  String get documentsShare => 'Ulashish';

  @override
  String get documentsDelete => 'Oʻchirish';

  @override
  String documentsDeleteConfirm(String title) {
    return '“$title” savatga oʻtkazilsinmi? Uni 30 kun ichida tiklash mumkin.';
  }

  @override
  String get documentsDeleted => 'Savatga oʻtkazildi';

  @override
  String get documentsQueued => 'agnts yozishni boshlashini kutmoqda…';

  @override
  String get documentsWritingNow => 'agnts bu hujjatni yozmoqda. Tayyor boʻlgach shu yerda paydo boʻladi.';

  @override
  String get documentsGenFailedTitle => 'agnts uni yoza olmadi:';

  @override
  String get documentsTryAgain => 'Qayta urinish';

  @override
  String documentsOverwrote(String name, String when) {
    return 'agnts $name tomonidan $when kiritilgan tahrirlar ustidan yangi versiya yozdi.';
  }

  @override
  String documentsRestoreVersion(String n) {
    return '$n-versiyani tiklash';
  }

  @override
  String get documentsMarkdown => 'Markdown';

  @override
  String get documentsPreview => 'Koʻrinishi';

  @override
  String get documentsConflictTitle => 'Kimdir oraliqda saqladi.';

  @override
  String documentsConflictHelp(String n) {
    return 'Hujjat hozir $n-versiyada. Matningizni uning ustiga saqlang yoki ularning matnidan qayta boshlang.';
  }

  @override
  String get documentsTheirText => 'Ularning matni';

  @override
  String get documentsKeepMine => 'Meniki qolsin';

  @override
  String get documentsTakeTheirs => 'Ularnikini olish';

  @override
  String get documentsSave => 'Saqlash';

  @override
  String get documentsSaved => 'Yangi versiya sifatida saqlandi';

  @override
  String get documentsLeaveUnsaved => 'Tahrirlarni saqlamasdan chiqilsinmi?';

  @override
  String get documentsEmptyBody => 'Hali hech narsa yozilmagan.';

  @override
  String get documentsPublicLink => 'Ochiq havola';

  @override
  String get documentsDownloadMd => 'Markdown';

  @override
  String get documentsDownloadPdf => 'PDF';

  @override
  String get documentsPreparingPdf => 'PDF tayyorlanmoqda…';

  @override
  String get documentsPdfFailed => 'PDF yaratib boʻlmadi. Bir necha daqiqadan soʻng qayta urinib koʻring yoki Markdown yuklab oling.';

  @override
  String get documentsPdfSlow => 'PDF uzoq tayyorlanmoqda. Bir daqiqadan soʻng qayta urinib koʻring.';

  @override
  String get documentsLinkedTickets => 'Tiketlar';

  @override
  String get documentsLinkedTicketsSub => 'Hujjat tegishli boʻlgan tiketlar';

  @override
  String get documentsNoTickets => 'Hech qanday tiketga bogʻlanmagan.';

  @override
  String get documentsLinkedByAgnts => 'agnts bogʻlagan';

  @override
  String get documentsLinkedByAgntsHint => 'agnts hujjat asosidagi tiketlarni bogʻlagan';

  @override
  String get documentsUnlink => 'Uzish';

  @override
  String get documentsLinkTicket => 'Bogʻlash';

  @override
  String get documentsLinkPlaceholder => 'Tiket raqami';

  @override
  String get documentsBadKey => 'Bu tiket raqami emas.';

  @override
  String get documentsVersions => 'Versiyalar';

  @override
  String get documentsNoVersions => 'Hozircha versiyalar yoʻq.';

  @override
  String get documentsCurrent => 'joriy';

  @override
  String documentsByAgntsFor(String name) {
    return 'agnts, $name uchun';
  }

  @override
  String documentsRestoredBy(String name) {
    return '$name tikladi';
  }

  @override
  String documentsVersionTitle(String n) {
    return '$n-versiya';
  }

  @override
  String get documentsIsCurrent => 'Bu joriy versiya.';

  @override
  String documentsDiffHelp(String n) {
    return '$n-versiyadan joriy matngacha nima oʻzgargan: oʻchirilgan qatorlar chizilgan, qoʻshilganlari yashil.';
  }

  @override
  String get documentsSameText => 'Matn hozirgisi bilan bir xil.';

  @override
  String get documentsShareTitle => 'Ulashish';

  @override
  String get documentsType => 'Kim oʻqiy oladi';

  @override
  String get documentsPrivateHelp => 'Faqat siz, quyidagi odamlar va maydon egasi.';

  @override
  String get documentsPublicHelp => 'Havolasi bor har kim tizimga kirmasdan oʻqiy va yuklab oladi. Ismlar va tiketlar koʻrsatilmaydi.';

  @override
  String get documentsPublicOff => 'Ochiq hujjatlar maydon sozlamalarida oʻchirilgan.';

  @override
  String get documentsSecretsTitle => 'Matnda maxfiy maʼlumotlar borga oʻxshaydi.';

  @override
  String get documentsSecretsHelp => 'Ularni shu qatorlardan olib tashlang, saqlang va hujjatni qayta ochiq qiling.';

  @override
  String documentsLine(String n) {
    return '$n-qator';
  }

  @override
  String get documentsResetLink => 'Havolani yangilash';

  @override
  String get documentsResetHelp => 'Eski havola darhol ishlamay qoladi.';

  @override
  String get documentsWorkspaceAccess => 'Maydondagi hamma';

  @override
  String get documentsWorkspaceAccessHelp => 'Har bir aʼzo uchun kamida shu ruxsat. Kuzatuvchilar faqat oʻqiy oladi.';

  @override
  String get documentsPeople => 'Odamlar';

  @override
  String get documentsAddPerson => 'Odam qoʻshish';

  @override
  String get documentsRemove => 'Olib tashlash';

  @override
  String get documentsOwnerNote => 'Maydon egasi bu hujjatni har doim ocha oladi.';

  @override
  String get documentsSaveSharing => 'Saqlash';

  @override
  String get documentsTransfer => 'Boshqa aʼzoga berish';

  @override
  String get documentsTransferTo => 'Yangi egasi';

  @override
  String documentsTransferConfirm(String name) {
    return '$name egasi boʻlsinmi? Sizda tahrirlash ruxsati qoladi.';
  }

  @override
  String get documentsTicketTitle => 'Hujjatlar';

  @override
  String get documentsTicketSub => 'Bu tiket haqidagi siz ocha oladigan hujjatlar';

  @override
  String get documentsTicketEmpty => 'Hozircha hujjat yoʻq.';

  @override
  String get documentsFromReport => 'Hisobotdan hujjat yaratish';

  @override
  String get documentsPublicGoneTitle => 'Bu havola ishlamaydi';

  @override
  String get documentsPublicGone => 'Hujjat yopiq qilingan, oʻchirilgan yoki havolasi oʻzgartirilgan.';

  @override
  String documentsPublicUpdated(String when) {
    return 'Yangilangan: $when';
  }

  @override
  String get documentsSettingLabel => 'Ochiq hujjatlar';

  @override
  String get documentsSettingHelp =>
      'Hujjat egalariga har kim ocha oladigan ochiq havola ulashishga ruxsat berish. Oʻchirilsa — maydondagi barcha ochiq havolalar darhol ishlamay qoladi.';

  @override
  String documentsNewForTicket(String number) {
    return '$number ga bogʻlanadi. Oʻzingiz yozing yoki agnts yozsin.';
  }

  @override
  String get documentsDocKind => 'Turi';

  @override
  String get documentsDocKind_page => 'Sahifa';

  @override
  String get documentsDocKind_slides => 'Slaydlar';

  @override
  String get documentsDocKindHelp_page => 'Oʻqish uchun hujjat: batafsil, jamoa uchun.';

  @override
  String get documentsDocKindHelp_slides => 'Taqdimot: qisqa, mijozlar va jamoadan tashqaridagilar uchun.';

  @override
  String get documentsKindFilter_all => 'Sahifalar va slaydlar';

  @override
  String get documentsKindFilter_page => 'Sahifalar';

  @override
  String get documentsKindFilter_slides => 'Slaydlar';

  @override
  String get documentsKind_document => 'Hujjat';

  @override
  String get documentsKindHelp_document =>
      'Ushbu ish maydonidagi sahifa, slaydlar bilan qayta aytilgan. Slaydlar — oʻz ruxsatlariga ega alohida hujjat.';

  @override
  String get documentsSourceDocument => 'Hujjat';

  @override
  String get documentsChooseDocument => 'Hujjatni tanlang';

  @override
  String get documentsTemplate_presentation => 'Taqdimot';

  @override
  String get documentsTemplateHint_presentation => 'Asosiy fikrlar, ularning maʼnosi, keyingi qadamlar';

  @override
  String get documentsMakeSlides => 'Slaydlar yasash';

  @override
  String documentsSlidesOf(String title) {
    return '$title — slaydlar';
  }

  @override
  String get documentsSlidesSub => 'agnts ushbu hujjatni slaydlar bilan qayta aytadi — alohida ulashiladigan yangi hujjatda.';

  @override
  String get documentsMadeFrom => 'Manba hujjat:';

  @override
  String documentsSourceChanged(String n) {
    return 'Shundan beri hujjat oʻzgargan (hozir $n-versiya).';
  }

  @override
  String get documentsDecksTitle => 'Ushbu hujjatdan yasalgan slaydlar';

  @override
  String get documentsSlidesHelp =>
      'Faqat --- dan iborat qator yangi slaydni boshlaydi. Notes: bilan boshlanadigan qator slayd uchun maʼruzachi izohlarini boshlaydi.';

  @override
  String get documentsNoSlides => 'Hozircha slaydlar yoʻq. Slaydlarni --- qatori bilan ajrating.';

  @override
  String get documentsPresent => 'Namoyish qilish';

  @override
  String documentsPresentFrom(String n) {
    return '$n-slayddan namoyish qilish';
  }

  @override
  String get documentsStopPresenting => 'Namoyishni tugatish';

  @override
  String get documentsPrevSlide => 'Oldingi slayd';

  @override
  String get documentsNextSlide => 'Keyingi slayd';

  @override
  String get documentsNotes => 'Izohlar';

  @override
  String get documentsNoNotes => 'Bu slayd uchun izoh yoʻq.';

  @override
  String get documentsStarterSubtitle => 'Nima haqida va qachon';

  @override
  String get documentsStarterPoint => 'Birinchi fikr';

  @override
  String get documentsComments => 'Izohlar';

  @override
  String get documentsAddComment => 'Izoh qoldirish';

  @override
  String get documentsCommentPlaceholder => 'Izoh yozing…';

  @override
  String get documentsReplyPlaceholder => 'Javob…';

  @override
  String get documentsPost => 'Yuborish';

  @override
  String get documentsNoComments => 'Hozircha izohlar yoʻq.';

  @override
  String get documentsNoCommentsHint => 'Izoh qoldirish uchun matnni belgilang.';

  @override
  String get documentsGuestsCanRead => 'Hujjat ochiq: havola orqali kirgan mehmonlar izohlarni koʻradi.';

  @override
  String documentsSlideN(String n) {
    return '$n-slayd';
  }

  @override
  String get documentsTextChanged => 'Izoh tegishli boʻlgan matn oʻzgargan.';

  @override
  String get documentsEdited => 'tahrirlangan';

  @override
  String get documentsResolve => 'Hal qilindi';

  @override
  String get documentsResolveHelp => 'Hal qilingan deb belgilash: muhokama yigʻiladi';

  @override
  String get documentsReopen => 'Qayta ochish';

  @override
  String documentsResolvedN(String n) {
    return 'Hal qilinganlar ($n)';
  }

  @override
  String documentsResolvedBy(String name) {
    return 'Hal qildi: $name';
  }

  @override
  String documentsRepliesN(num n) {
    return '$n ta javob';
  }

  @override
  String get documentsDeleteThreadConfirm => 'Izoh va unga javoblar oʻchirilsinmi?';

  @override
  String get documentsDeleteCommentConfirm => 'Javob oʻchirilsinmi?';

  @override
  String documentsViewingNow(num n) {
    return 'Hozir $n kishi koʻrmoqda';
  }

  @override
  String get documentsYou => 'siz';

  @override
  String get documentsGuest => 'mehmon';

  @override
  String get documentsViaGoogle => 'Google orqali mehmon';

  @override
  String get documentsWhoAreYou => 'Siz kimsiz?';

  @override
  String get documentsWhoAreYouSub => 'Ismingiz hujjat ustida ishlayotganlarga koʻrinadi: izohlaringiz yonida va hujjat ochiq turganida.';

  @override
  String get documentsYourName => 'Ismingiz';

  @override
  String get documentsYourNamePlaceholder => 'Ism va kompaniya';

  @override
  String get documentsEnter => 'Davom etish';

  @override
  String get documentsOrGoogle => 'Yoki xohlasangiz, Google orqali kim ekaningizni koʻrsating:';

  @override
  String get documentsViaAccount => 'akkaunt orqali';

  @override
  String get documentsTranslate => 'Tarjima qilish';

  @override
  String get documentsTranslateOriginal => 'Asl til';

  @override
  String get documentsTranslating => 'Tarjima qilinmoqda… uzun hujjat birinchi marta bir daqiqagacha tarjima qilinadi, keyin saqlanadi.';

  @override
  String documentsTranslateFailed(String error) {
    return 'Tarjima qilib boʻlmadi: $error';
  }

  @override
  String get documentsTranslatedNoComments => 'Siz tarjimani oʻqiyapsiz. Izoh qoldirish uchun asl matnga oʻting.';

  @override
  String get documentsShowOriginal => 'Asl matnni koʻrsatish';

  @override
  String get documentsTranslatedIncomplete => 'Baʼzi qismlar hali asl tilda.';

  @override
  String get draftsTitle => 'Ko\'rib chiqish izohlari';

  @override
  String draftsSub(String host) {
    return 'agnts izohlari siz qabul qilmaguningizcha shu yerda qoladi. ${host}ga faqat qabul qilinganlari bitta ko\'rib chiqish sifatida chiqariladi; qolganlari agnts\'dan tashqariga chiqmaydi.';
  }

  @override
  String get draftsLockedSub => 'Ko\'rib chiqish tugagan yoki pull request yopilgan: bu izohlarni faqat o\'qish mumkin.';

  @override
  String get draftsChip => 'Qoralama';

  @override
  String get draftsSummary => 'Xulosa';

  @override
  String get draftsSomeone => 'Kimdir';

  @override
  String get draftsEdited => 'tahrirlangan';

  @override
  String get draftsState_draft => 'Qoralama';

  @override
  String get draftsState_accepted => 'Qabul qilingan';

  @override
  String get draftsState_publishing => 'Chiqarilmoqda';

  @override
  String get draftsState_dismissed => 'Rad etilgan';

  @override
  String get draftsState_published => 'Chiqarilgan';

  @override
  String get draftsState_outdated => 'Eskirgan';

  @override
  String get draftsKind_summary => 'xulosa';

  @override
  String get draftsKind_finding => 'topilma';

  @override
  String get draftsKind_comment => 'izoh';

  @override
  String get draftsAccept => 'Qabul qilish';

  @override
  String get draftsUndo => 'Bekor qilish';

  @override
  String get draftsDismiss => 'Rad etish';

  @override
  String get draftsReopen => 'Qoralamaga qaytarish';

  @override
  String get draftsReasonLabel => 'Nega? (ixtiyoriy: agnts siz nimani shovqin deb bilishingizni o\'rganadi)';

  @override
  String get draftsReasonHint => 'masalan, bu xizmatda keshlarni cheklamaymiz';

  @override
  String draftsDismissedBecause(String reason) {
    return 'Rad etilgan: $reason';
  }

  @override
  String get draftsOutdatedHint => 'agnts\'ning eng yangi ko\'rib chiqishi buni endi topmaydi.';

  @override
  String draftsFailed(String error) {
    return 'Chiqarib bo\'lmadi: $error';
  }

  @override
  String get draftsDeleteTitle => 'Izohingiz o\'chirilsinmi?';

  @override
  String get draftsDeleteConfirm => 'U hech qachon chiqarilmagan; agnts\'dan o\'chiriladi.';

  @override
  String draftsNAccepted(String n) {
    return '$n ta qabul qilingan';
  }

  @override
  String draftsNDraft(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta qoralama');
    return '$_temp0';
  }

  @override
  String draftsNDismissed(String n) {
    return '$n ta rad etilgan';
  }

  @override
  String draftsNPublished(String n) {
    return '$n ta chiqarilgan';
  }

  @override
  String draftsNOutdated(String n) {
    return '$n ta eskirgan';
  }

  @override
  String get draftsAcceptMajor => 'Major va undan yuqorisini qabul qilish';

  @override
  String get draftsAcceptAll => 'Hammasini qabul qilish';

  @override
  String draftsPublishBtn(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tasini chiqarish', zero: 'Chiqarish');
    return '$_temp0: $host';
  }

  @override
  String draftsPublishTitle(String host) {
    return '${host}ga chiqarish';
  }

  @override
  String draftsPublishSub(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta izoh');
    return '$_temp0 pull request\'ga $host token foydalanuvchisi nomidan bitta ko\'rib chiqish sifatida chiqariladi. O\'zgargan qatorda bo\'lmagan izohlar ko\'rib chiqish matniga qo\'shiladi.';
  }

  @override
  String draftsPublishedToast(num n, String host) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta izoh');
    return '$_temp0 ${host}ga chiqarildi';
  }

  @override
  String draftsHeadMoved(String from, String to, String host) {
    return 'agnts ko\'rib chiqqandan keyin yangi commitlar bor ($from, hozir $to): izohlar agnts ko\'rgan versiyaga qo\'yiladi va $host ularni eskirgan deb ko\'rsatishi mumkin. Ularni eng yangi qatorlarga qo\'yish uchun avval qayta ko\'rib chiqing.';
  }

  @override
  String draftsShowClosed(String n) {
    return 'Rad etilgan, eskirgan va chiqarilganlarni ko\'rsatish ($n)';
  }

  @override
  String draftsDraftsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta qoralama');
    return '$_temp0';
  }

  @override
  String get draftsNotOnDiff => 'agnts izohlari bu yerda ko\'rsatilgan qatorlarda emas (boshqa versiya yoki diff tashqarisida):';

  @override
  String get draftsAddToReview => 'Ko\'rib chiqishga qo\'shish';

  @override
  String get draftsAddedToast => 'Ko\'rib chiqishga qo\'shildi: qabul qilingan izohlar bilan birga chiqariladi';

  @override
  String get draftsOnDiff => 'Ularni diffda ko\'rish';

  @override
  String get draftsReviewWithBtn => 'agnts bilan ko\'rib chiqish';

  @override
  String get draftsReviewAgainBtn => 'agnts bilan qayta ko\'rib chiqish';

  @override
  String draftsReviewTitle(String number) {
    return '#${number}ni agnts bilan ko\'rib chiqish';
  }

  @override
  String get draftsReviewSub =>
      'agnts pull request\'ni hozirgi holatida ko\'rib chiqadi. Uning izohlari siz qabul qilmaguningizcha agnts\'da qoralama bo\'lib qoladi; pull request\'ga faqat qabul qilinganlari tushadi. Tekshiruvni tasdiqlash uni faqat sizga biriktirilgan yoki sizdan tekshiruv so\'ralgan bo\'lsa merge qiladi.';

  @override
  String get draftsReviewBtn => 'Ko\'rib chiqishni boshlash';

  @override
  String get draftsFocusLabel => 'Alohida e\'tibor beradigan joy bormi? (ixtiyoriy)';

  @override
  String get draftsFocusHint => 'masalan, migratsiya va qayta urinish mantiqi';

  @override
  String get draftsDeepLabel => 'Chuqur ko\'rib chiqish (xavfsizlik, xatolar, testlar va turlar bo\'yicha)';

  @override
  String get draftsDeep_default => 'Workspace sozlamasi';

  @override
  String get draftsDeep_always => 'Yoqilgan';

  @override
  String get draftsDeep_off => 'O\'chirilgan';

  @override
  String draftsStartedToast(String key) {
    return 'agnts uni ${key}da ko\'rib chiqmoqda';
  }

  @override
  String draftsReviewingNow(String key) {
    return 'agnts bu pull request\'ni ko\'rib chiqmoqda ($key). Tugagach, izohlari shu yerda qoralama sifatida paydo bo\'ladi.';
  }

  @override
  String get draftsFinishBtn => 'Ko\'rib chiqishni tugatish';

  @override
  String draftsFinishConfirm(String number) {
    return '#$number ko\'rib chiqilishi tugatilsinmi? Chiqarilmagan izohlar agnts\'da qoladi. Pull request o\'z holicha qoladi: agnts uni merge qilmaydi.';
  }

  @override
  String draftsReadySub(String host) {
    return 'agnts izohlarini ko\'rib chiqing, rozi bo\'lganlaringizni ${host}ga chiqaring va ko\'rib chiqishni tugating. Yoki eslatma bilan qayta ko\'rib chiqishni so\'rang yoki uni rad eting.';
  }

  @override
  String get draftsFinishedTitle => 'Ko\'rib chiqish tugadi';

  @override
  String draftsFinishedSub(String number) {
    return '#$number ko\'rib chiqilishi tugadi. Pull request o\'z holicha qoldirildi.';
  }

  @override
  String get feedbackTitle => 'Fikr yuborish';

  @override
  String get feedbackLede => 'agnts jamoasiga nima ishlayotgani, nima ishlamayotgani yoki keyin nimani xohlashingizni yozing.';

  @override
  String get feedbackTitleLabel => 'Sarlavha';

  @override
  String get feedbackTitlePlaceholder => 'Bir necha so\'z bilan';

  @override
  String get feedbackDescLabel => 'Tavsif';

  @override
  String get feedbackDescPlaceholder => 'Nima bo\'ldi, nimani kutgan edingiz yoki g\'oyangiz';

  @override
  String get feedbackSend => 'Yuborish';

  @override
  String get feedbackSent => 'Rahmat! Fikringiz yuborildi.';

  @override
  String get feedbackAdminTitle => 'Fikrlar';

  @override
  String get feedbackAdminLede =>
      'Odamlar o‘z akkauntlaridan yuborgan fikrlar va saytdan kelgan konnektor so‘rovlari, eng yangilari birinchi. Har birini hal qilgach, bajarildi deb belgilang.';

  @override
  String get feedbackF_new => 'Yangi';

  @override
  String get feedbackF_done => 'Bajarilgan';

  @override
  String get feedbackF_all => 'Hammasi';

  @override
  String get feedbackS_new => 'Yangi';

  @override
  String get feedbackS_done => 'Bajarildi';

  @override
  String get feedbackSearch => 'Fikrlar, odamlar yoki ish maydonlarini qidirish';

  @override
  String get feedbackNone => 'Fikrlar yo\'q.';

  @override
  String get feedbackNoneNew => 'Yangi fikrlar yo\'q. Ajoyib!';

  @override
  String feedbackFrom(String workspace) {
    return '$workspace dan';
  }

  @override
  String get feedbackAccountGone => 'akkaunt o\'chirilgan';

  @override
  String get feedbackMarkDone => 'Bajarildi deb belgilash';

  @override
  String get feedbackReopen => 'Qayta ochish';

  @override
  String get feedbackMarkedDone => 'Bajarildi deb belgilandi';

  @override
  String get feedbackReopened => 'Yana yangi deb belgilandi';

  @override
  String get feedbackKind => 'Turi';

  @override
  String get feedbackK_any => 'Hammasi';

  @override
  String get feedbackK_feedback => 'Fikrlar';

  @override
  String get feedbackK_connector => 'Konnektor so‘rovlari';

  @override
  String get feedbackConnectorBadge => 'Konnektor so‘rovi';

  @override
  String get feedbackFromSite => 'saytdan';

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
  String get filesHint => 'Rasmlar, PDF, loglar yoki matn, har biri 10 MB gacha. Muse ularning barchasini oʻqiydi.';

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
      'agnts fikricha, bu tiketni oxiriga yetkazish uchun yana nima kerak. Keraklilarini tanlang va darhol ishga tushiring yoki har birini o\'zingiz ishga tushirguningizcha ushlab turing.';

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
  String get followUpsAfter => 'Keyin';

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
  String followUpsCreateStart(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta tiketni yaratish va ishga tushirish',
      zero: 'Yaratish va ishga tushirish',
    );
    return '$_temp0';
  }

  @override
  String get followUpsCreateHeld => 'Yaratib, ushlab turish';

  @override
  String get followUpsQueuedHint =>
      'Ishga tushirilgan tiketlar darhol navbatga turadi; boshqasini kutadigan tiket u birlashtirilgandan keyin kod yozishni boshlaydi. Ushlab turilganlar siz ishga tushirguningizcha kutadi.';

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
  String followUpsStartedNotice(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta tiket yaratildi');
    return '$_temp0 va ishga tushirish navbatiga qo\'yildi.';
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
  String groupsView(String n) {
    return 'Guruhlar ($n)';
  }

  @override
  String get groupsSub =>
      'Birga oʻzgaradigan repozitoriylar. Guruhdan yaratilgan tiket ularning hammasida ishlaydi va oʻzgartirgan har birida pull request ochadi.';

  @override
  String get groupsNone =>
      'Hozircha guruhlar yoʻq. Guruh bitta tiketga bir nechta repozitoriyni, masalan API va veb-ilovani oʻzgartirish imkonini beradi.';

  @override
  String get groupsAdd => 'Yangi guruh';

  @override
  String get groupsDrawerSub => 'Birga oʻzgaradigan repozitoriylar, tartib bilan: birinchisi guruh tiketlarining asosiy repozitoriysi.';

  @override
  String get groupsName => 'Nomi';

  @override
  String get groupsNamePh => 'Doʻkon';

  @override
  String get groupsDescription => 'Tavsif';

  @override
  String get groupsMembers => 'Repozitoriylar';

  @override
  String get groupsMembersHelp =>
      'Tartib muhim: birinchisi asosiy repozitoriy. Rol agnts ga har biri nima ekanini aytadi, masalan backend yoki web.';

  @override
  String get groupsMembersNeeded => 'Kamida bitta repozitoriy qoʻshing.';

  @override
  String get groupsNoMembers => 'Hozircha repozitoriylar yoʻq.';

  @override
  String get groupsAddMember => 'Repozitoriy qoʻshish…';

  @override
  String get groupsNoMoreRepos => 'Barcha faol repozitoriylar guruhda';

  @override
  String get groupsRolePh => 'Rol, masalan backend';

  @override
  String groupsRoleOf(String name) {
    return '$name roli';
  }

  @override
  String groupsMoveUp(String name) {
    return '$name ni yuqoriga';
  }

  @override
  String groupsMoveDown(String name) {
    return '$name ni pastga';
  }

  @override
  String get groupsPrimary => 'asosiy';

  @override
  String get groupsArchived => 'arxivda';

  @override
  String groupsPrefixHelp(String prefix) {
    return 'Guruhdan yaratilgan vazifalar kaliti prefiksi, masalan $prefix-12. Boʻsh boʻlsa, birinchi repozitoriyniki ishlatiladi.';
  }

  @override
  String groupsBranchTemplateHelp(String key, String number) {
    return 'Bu guruh vazifalari branchlarining nomi barcha repozitoriylarda bir xil boʻlishi uchun. Har bir repozitoriyning oʻz formatini almashtiradi. $key yoki $number boʻlishi kerak. Har bir repozitoriyning oʻzinikini qoldirish uchun boʻsh qoldiring.';
  }

  @override
  String get groupsCommitTemplateHelp =>
      'Bu guruh vazifalari kommit xabarlari barcha repozitoriylarda shu formatda yoziladi; har bir repozitoriyning oʻz formatini almashtiradi. Har birining oʻzinikini qoldirish uchun boʻsh qoldiring.';

  @override
  String get groupsInstructions => 'Koʻrsatmalar';

  @override
  String get groupsInstructionsPh =>
      'Veb-ilova API ga src/api orqali murojaat qiladi; ikkalasini birga oʻzgartiring va OpenAPI spetsifikatsiyasini dolzarb saqlang.';

  @override
  String get groupsInstructionsHelp =>
      'Repozitoriylar bir-biriga qanday bogʻlangani, Markdown da. Guruh tiketlarining har bir promptiga qoʻshiladi.';

  @override
  String get groupsWarningsTitle => 'Saqlandi, lekin ogohlantirishlar bor:';

  @override
  String groupsWarningsBadge(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta ogohlantirish');
    return '$_temp0';
  }

  @override
  String groupsSaved(String name) {
    return '$name guruhi saqlandi';
  }

  @override
  String get groupsDelete => 'Oʻchirish';

  @override
  String groupsDeleteConfirm(String name) {
    return '$name guruhi oʻchirilsinmi? Uning tiketlari oʻz repozitoriylarini saqlab qoladi.';
  }

  @override
  String groupsDeleted(String name) {
    return '$name guruhi oʻchirildi';
  }

  @override
  String get groupsColGroup => 'Guruh';

  @override
  String get groupsColMembers => 'Repozitoriylar';

  @override
  String get groupsColPrefix => 'Prefiks';

  @override
  String groupsInGroups(String names) {
    return 'Guruhlarda: $names';
  }

  @override
  String get groupsInLabel => 'Guruhlar:';

  @override
  String get groupsPickerGroups => 'Repozitoriy guruhlari';

  @override
  String get groupsChosen => 'Tanlangan repozitoriylar';

  @override
  String groupsFromGroup(String name) {
    return '$name guruhidan';
  }

  @override
  String get groupsMakePrimary => 'Asosiy repozitoriy qilish';

  @override
  String groupsMore(String count) {
    return '+$count';
  }

  @override
  String get groupsAllGroups => 'Barcha guruhlar';

  @override
  String get groupsFilterLabel => 'Guruh';

  @override
  String get groupsKvRepos => 'Repozitoriylar';

  @override
  String get groupsKvGroup => 'Guruh';

  @override
  String groupsTicketRepos(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta repozitoriy');
    return '$_temp0';
  }

  @override
  String get groupsPartlyMerged => 'Qisman birlashtirilgan';

  @override
  String groupsPr(String number) {
    return 'PR #$number';
  }

  @override
  String groupsOpenPrIn(String repo, String number) {
    return '$repo #$number ni ochish';
  }

  @override
  String groupsFiles(num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta fayl');
    return '$_temp0';
  }

  @override
  String groupsFilesIn(String repo, num count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta fayl');
    return '$repo · $_temp0';
  }

  @override
  String groupsPushError(String error) {
    return 'Yuborib boʻlmadi: $error';
  }

  @override
  String groupsRetryHint(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Qayta urinish xato boʻlgan $count ta repozitoriyni yuboradi; qolganlari oʻzgarmaydi.',
    );
    return '$_temp0';
  }

  @override
  String get groupsState_pending => 'Yuborilmagan';

  @override
  String get groupsState_unchanged => 'Oʻzgarmagan';

  @override
  String get groupsState_pushed => 'Yuborilgan';

  @override
  String get groupsState_merged => 'Birlashtirilgan';

  @override
  String get groupsState_dropped => 'Yopilgan';

  @override
  String get groupsMaxTicketRepos => 'Bitta tiketdagi repozitoriylar soni (maksimal)';

  @override
  String get groupsMaxTicketReposHelp => 'Bitta tiket va bitta repozitoriy guruhida nechta repozitoriy boʻlishi mumkin.';

  @override
  String get harnessRepoTab => 'Himoya';

  @override
  String get harnessRepoTitle => 'Himoya';

  @override
  String get harnessRepoSub => 'agnts-guard bu repozitoriyda Muse ishini qanchalik qatʼiy tekshiradi — ish davomida va undan keyin.';

  @override
  String get harnessRepoSave => 'Himoyani saqlash';

  @override
  String get harnessRepoSaved => 'Himoya saqlandi';

  @override
  String get harnessRepoAgentTitle => 'Agentlar uchun koʻrsatma fayllari';

  @override
  String get harnessRepoAgentSub =>
      'agnts CLAUDE.md, AGENTS.md, .claude/ va .mcp.json fayllarida agentni boshqarishga urinadigan matnni qidiradi. Bu repozitoriyning hooklari va MCP serverlarini agnts hech qachon ishga tushirmaydi.';

  @override
  String harnessRepoAgentScanned(String time) {
    return '$time tekshirilgan';
  }

  @override
  String get harnessRepoAgentNotScanned => 'Hali tekshirilmagan: bu repozitoriydagi keyingi ishga tushirish fayllarni tekshiradi.';

  @override
  String get harnessRepoAgentNothing => 'Hech narsa topilmadi.';

  @override
  String harnessRepoAgentWarn(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n qator');
    return '$_temp0 agentni boshqarishga urinishi mumkin. Ishga tushirishlar bu fayllarni koʻrsatma emas, maʼlumot sifatida oʻqiydi; ularga ishonishdan oldin oʻqib chiqing.';
  }

  @override
  String get harnessRepoAgentInfo => 'agnts eʼtiborsiz qoldiradigan sozlamalar';

  @override
  String get harnessRepoKind_hidden_unicode => 'Yashirin belgilar';

  @override
  String get harnessRepoKind_agent_instruction => 'Agentga koʻrsatma';

  @override
  String get harnessRepoKind_exfiltration => 'Maʼlumotni tashqariga yuboradi';

  @override
  String get harnessRepoKind_encoded_blob => 'Kodlangan matn';

  @override
  String get harnessRepoKind_hooks => 'Muse hooklari';

  @override
  String get harnessRepoKind_mcp_server => 'MCP serverlar';

  @override
  String get harnessRepoProfile => 'Himoya profili';

  @override
  String get harnessRepoProfileHelp => 'Bu repozitoriyda ish davomidagi tekshiruvlar qanchalik qatʼiy.';

  @override
  String get harnessRepoProfile_ => 'Ish maydonidagidek';

  @override
  String get harnessRepoProfile_minimal => 'Minimal';

  @override
  String get harnessRepoProfile_standard => 'Oddiy';

  @override
  String get harnessRepoProfile_strict => 'Qatʼiy';

  @override
  String get harnessRepoProfileHelp_ => 'Ish maydoni sozlamasiga amal qiladi.';

  @override
  String get harnessRepoProfileHelp_minimal => 'Faqat sirlar va majburiy qoidalar bloklanadi; Muse tugatishidan oldin build tekshiriladi.';

  @override
  String get harnessRepoProfileHelp_standard =>
      'Oʻtkazib yuborilgan testlar, oʻchirilgan linterlar va tekshiruv sozlamalariga oʻzgartirishlar ham bloklanadi; Muse tugatishidan oldin build va lint oʻtishi kerak.';

  @override
  String get harnessRepoProfileHelp_strict =>
      'Yutib yuborilgan xatolar va testlardan olib tashlangan tekshiruvlar ham bloklanadi, Muse tugatishidan oldin testlar ishga tushadi, faylni tahrirlashdan oldin faktlar soʻralishi mumkin.';

  @override
  String get harnessRepoSecretAllow => 'Namuna kalitlarga ruxsat berilgan joylar';

  @override
  String get harnessRepoSecretAllowHelp => 'Soxta kalitlar kutiladigan yoʻl shablonlari, testdata/, fixtures/ va *.example dan tashqari.';

  @override
  String get harnessRepoChecksTitle => 'Har bir faylni tekshirish';

  @override
  String get harnessRepoChecksSub =>
      'Muse tahrirlagan har bir faylda agnts-guard ishga tushiradigan tez formatter va linterlar, muammolar darhol tuzatilishi uchun.';

  @override
  String get harnessRepoChecksOff => 'Fayl tekshiruvlarini oʻchirish';

  @override
  String get harnessRepoChecksOffHelp => 'Muse har bir tahrirdan keyin tekshirilmaydi; ishga tushirishdan keyingi tekshiruvlar qoladi.';

  @override
  String get harnessRepoOwnChecks => 'Oʻz tekshiruvlarim';

  @override
  String get harnessRepoOwnChecksHelp => 'agnts vositalardan chiqaradigan tekshiruvlarni oʻz roʻyxatingiz bilan almashtiring.';

  @override
  String get harnessRepoDerivedTitle => 'Vositalardan chiqarilgan';

  @override
  String get harnessRepoDerivedNone => 'agnts bu repozitoriy vositalari uchun fayl tekshiruvlarini bilmaydi.';

  @override
  String get harnessRepoCheckName => 'Nomi';

  @override
  String get harnessRepoCheckGlobs => 'Fayllar (shablonlar, vergul bilan)';

  @override
  String get harnessRepoCheckCmd => 'Buyruq';

  @override
  String harnessRepoCheckCmdHelp(String file, String dir) {
    return '\'$file\' — tahrirlangan fayl, \'$dir\' — uning papkasi, ikkalasi ham repozitoriyga nisbatan.';
  }

  @override
  String get harnessRepoCheckEvery => 'Eng koʻpi bilan har (soniya)';

  @override
  String get harnessRepoAddCheck => 'Tekshiruv qoʻshish';

  @override
  String harnessRepoRemoveCheck(String name) {
    return '$name ni olib tashlash';
  }

  @override
  String get harnessRepoCoverageTitle => 'Oʻzgargan qatorlarning qamrovi';

  @override
  String get harnessRepoCoverageSub =>
      'Tekshiruvlar oʻtgach, agnts testlarni qamrov bilan yana bir bor ishga tushiradi va qaysi qoʻshilgan qatorlarni hech bir test bajarmaganini koʻrsatadi.';

  @override
  String get harnessRepoCoverage => 'Qamrovni oʻlchash';

  @override
  String get harnessRepoCoverageHelp => 'Tekshiruvlardan keyin qoʻshimcha test ishga tushirish; ishga tushirish undan yiqilmaydi.';

  @override
  String get harnessRepoThreshold => 'Chegara';

  @override
  String get harnessRepoThresholdHelp => 'Undan past boʻlsa, kod reviewga qamrov haqida izoh qoʻshiladi. 0 izohni oʻchiradi.';

  @override
  String get harnessRepoCoverageCmd => 'Qamrov buyrugʻi';

  @override
  String get harnessRepoCoverageCmdHelp => 'agnts chiqaradigan buyruqdan foydalanish uchun boʻsh qoldiring.';

  @override
  String get harnessRepoCoverageReport => 'Hisobot fayli';

  @override
  String get harnessRepoCoverageReportHelp => 'Go cover profile yoki lcov fayli, repozitoriyda yoki /agnts/out/ ichida.';

  @override
  String get harnessRepoCoverageNoDerived => 'agnts bu vositalar uchun qamrov buyrugʻini bilmaydi: uni kiriting.';

  @override
  String get harnessRepoAcceptance => 'Ilovada qabulni tekshirish';

  @override
  String get harnessRepoAcceptanceHelp =>
      'Previewdan keyin agnts tiketning qabul mezonlarini ishlab turgan ilovada tekshiradi va natijani skrinshotlar bilan koʻrsatadi.';

  @override
  String get harnessRepoAcceptanceNoPreview => 'Preview buyrugʻi kerak: repozitoriyni tahrirlaganda uni kiriting.';

  @override
  String get harnessRepoStarterTitle => 'Boshlangʻich qoidalar';

  @override
  String get harnessRepoStarterSub =>
      'Bu repozitoriy tillari uchun aniq, tekshiriladigan kelishuvlar. Ular taklif sifatida qoʻshiladi: siz qabul qilmaguningizcha hech narsa qoʻllanmaydi.';

  @override
  String get harnessRepoStarterNone => 'Bu repozitoriy vositalariga mos boshlangʻich toʻplam yoʻq.';

  @override
  String harnessRepoStarterRules(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n qoida');
    return '$_temp0';
  }

  @override
  String harnessRepoStarterOffer(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n qoidani');
    return '$_temp0 taklif qilish';
  }

  @override
  String get harnessRepoStarterOffered => 'Allaqachon taklif qilingan';

  @override
  String harnessRepoStarterAdded(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n qoida taklif qilindi',
      zero: 'Taklif qilinadigan yangi narsa yoʻq',
    );
    return '$_temp0';
  }

  @override
  String get harnessRepoStarterOpenRules => 'Takliflarni ochish';

  @override
  String get harnessRepoLayersBlock => 'Qatlamlararo importlarni bloklash';

  @override
  String get harnessRepoLayersBlockHelp =>
      'Tasdiqlangan arxitektura bo‘lsa, agnts qatlamlar ruxsat bermaydigan import qo‘shgan o‘zgarishni belgilaydi. Yoqilgan bo‘lsa, bu bloklovchi bo‘ladi va agnts’ning o‘z ko‘rib chiqishi uni siz ko‘rishingizdan oldin dasturchiga qaytaradi.';

  @override
  String get harnessRulesDelivery => 'Ishga tushirishlar uni qanday oladi';

  @override
  String get harnessRulesDelivery_prompt => 'Har bir promptda';

  @override
  String get harnessRulesDelivery_skill => 'Koʻnikma';

  @override
  String get harnessRulesDeliveryHelp_prompt => 'Har bir promptda, doim koʻz oldida.';

  @override
  String get harnessRulesDeliveryHelp_skill =>
      'Tavsifi ishga mos kelganda Muse yuklaydigan koʻnikma: qoidalar koʻpayganda promptlar qisqa qoladi. Muhim qoidalarni har bir promptda saqlang.';

  @override
  String get harnessRulesEnforce => 'Majburiy';

  @override
  String get harnessRulesEnforceHelp => 'agnts-guard qoidani faqat soʻramaydi, Muse ishlayotganda tekshiradi.';

  @override
  String get harnessRulesOn => 'Tekshirish';

  @override
  String get harnessRulesOn_file => 'Fayl tahrirlari';

  @override
  String get harnessRulesOn_bash => 'Buyruqlar';

  @override
  String get harnessRulesOn_diff => 'Tayyor oʻzgarish';

  @override
  String get harnessRulesOnHelp_file => 'Quyidagi fayllar tahrirlari; shablon bilan — faqat unga mos keladigan qoʻshilgan qatorlar.';

  @override
  String get harnessRulesOnHelp_bash => 'Muse ishga tushiradigan va shablonga mos keladigan shell buyruqlari.';

  @override
  String get harnessRulesOnHelp_diff => 'Tayyor oʻzgarish, ishga tushirishdan keyin serverda tekshiriladi.';

  @override
  String get harnessRulesPaths => 'Fayllar (shablonlar)';

  @override
  String get harnessRulesPathsPlaceholder => 'server/migrations/*.sql';

  @override
  String get harnessRulesPattern => 'Shablon (RE2 regular expression)';

  @override
  String get harnessRulesAction => 'Mos kelganda';

  @override
  String get harnessRulesAction_block => 'Bloklash';

  @override
  String get harnessRulesAction_warn => 'Ogohlantirish';

  @override
  String get harnessRulesMessage => 'Muse uchun xabar';

  @override
  String get harnessRulesMessagePlaceholder => 'Oʻrniga yangi migratsiya qoʻshing.';

  @override
  String get harnessRulesTry => 'Tarixda sinash';

  @override
  String get harnessRulesTrying => 'Tekshirilmoqda…';

  @override
  String harnessRulesTryChecked(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta oʻzgarish');
    return 'agnts qilgan $_temp0 tekshirildi.';
  }

  @override
  String get harnessRulesTryNone => 'Ularning hech biriga mos kelmagan boʻlardi.';

  @override
  String harnessRulesTryHits(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta tiket');
    return '${_temp0}ga mos kelgan boʻlardi:';
  }

  @override
  String get harnessRulesBadgeBlock => 'Majburiy: bloklaydi';

  @override
  String get harnessRulesBadgeWarn => 'Majburiy: ogohlantiradi';

  @override
  String get harnessRulesBadgeSkill => 'Koʻnikma';

  @override
  String get harnessRulesBadgeTip => 'Maslahat';

  @override
  String get harnessRulesSource_reflect => 'Fikrdan';

  @override
  String get harnessRulesSource_run => 'Ishga tushirishdan';

  @override
  String get harnessRulesSource_promoted => 'Bir nechta repozitoriyda koʻrilgan';

  @override
  String harnessRulesSourceStarter(String name) {
    return 'Boshlangʻich: $name';
  }

  @override
  String harnessRulesConfidence(String n) {
    return 'Ishonch $n%';
  }

  @override
  String harnessRulesSeen(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n marta koʻrilgan');
    return '$_temp0';
  }

  @override
  String harnessRulesWatching(String n) {
    return 'Kuzatuvda ($n)';
  }

  @override
  String get harnessRulesWatchingHelp =>
      'agnts bir-ikki marta payqagan saboqlar. Yana koʻrganida ular taklifga aylanadi; shungacha hech bir tiketga tushmaydi.';

  @override
  String get harnessSettingsTitle => 'Cheklovlar';

  @override
  String get harnessSettingsSub =>
      'agnts-guard Muse ishini har bir ishga tushirish ichida, jarayonning oʻzida tekshiradi; ishga tushirishdan keyingi agnts tekshiruvlari ham amal qiladi.';

  @override
  String get harnessSettingsProfile => 'Cheklov profili';

  @override
  String get harnessSettingsProfile_minimal => 'Minimal';

  @override
  String get harnessSettingsProfile_standard => 'Standart';

  @override
  String get harnessSettingsProfile_strict => 'Qatʼiy';

  @override
  String get harnessSettingsProfileHelp_minimal =>
      'Maxfiy maʼlumotlar va .env fayllarini bloklaydi, shablonli jamoa qoidalarini qoʻllaydi va Muse tugatishidan oldin build muvaffaqiyatli boʻlishini talab qiladi.';

  @override
  String get harnessSettingsProfileHelp_standard =>
      'Minimaldagi hammasi, yana: oʻtkazib yuborilgan va oʻchirilgan testlar, oʻchirilgan linterlar va tekshiruv sozlamalari oʻzgarishini bloklaydi; toʻxtash tekshiruvida lint; har bir tahrirlangan faylni tezkor tekshirish.';

  @override
  String get harnessSettingsProfileHelp_strict =>
      'Standartdagi hammasi, yana: toʻxtash tekshiruvida testlar, yutib yuborilgan xatolar va olib tashlangan tekshiruvlarni bloklash, birinchi tahrirlardan oldin faktlarni tekshirish.';

  @override
  String get harnessSettingsFactCheck => 'Faktlarni tekshirish ulushi';

  @override
  String get harnessSettingsFactCheckHelp =>
      'Qatʼiy profildagi tasklar ulushi: ularda ishga tushirish faylni oʻzgartirishdan oldin undan kim foydalanishini va buzuvchi buyruqlarni qanday qaytarishni aytishi kerak. Guruhlarni Analitikada solishtiring.';

  @override
  String get harnessSettingsStalls => 'Ishga tushirish tiqilib qolsa';

  @override
  String get harnessSettingsStallsHelp =>
      'Bir xil buyruq qayta-qayta yiqiladi, koʻp chaqiruvlar davomida tahrir yoʻq yoki bitta fayl qayta-qayta oʻqiladi.';

  @override
  String get harnessSettingsStalls_off => 'Eʼtiborsiz';

  @override
  String get harnessSettingsStalls_log => 'Belgilash';

  @override
  String get harnessSettingsStalls_act => 'Aralashish';

  @override
  String get harnessSettingsProveFixes => 'Tuzatishlarni isbotlash';

  @override
  String get harnessSettingsProveFixesHelp =>
      'Xato tuzatishiga oʻzgarishdan oldin yiqiladigan va keyin oʻtadigan test kerak; agnts uni ikkala holatda ishga tushirib, natijani koʻrsatadi.';

  @override
  String get harnessSettingsDeepReview => 'Chuqur review';

  @override
  String get harnessSettingsDeepReviewHelp =>
      'Kod reviewda maxsus oʻtishlar (xavfsizlik, jim xatolar, testlar, turlar). Avto: faqat katta yoki murakkab ish; koʻproq token sarflaydi.';

  @override
  String get harnessSettingsDeep_off => 'Oʻchiq';

  @override
  String get harnessSettingsDeep_auto => 'Avto';

  @override
  String get harnessSettingsDeep_always => 'Doim';

  @override
  String get harnessSettingsLearnFromRuns => 'Ishga tushirishlardan oʻrganish';

  @override
  String get harnessSettingsLearnFromRunsHelp =>
      'Tekshiruvlari yiqilgan yoki tiqilib qolgan ishga tushirishdan keyin agnts repozitoriy uchun maslahat taklif qilishi mumkin. Maslahatlar yana koʻringuncha kuzatiladi.';

  @override
  String get harnessSettingsMethodSkills => 'Uslubiy koʻnikmalar';

  @override
  String get harnessSettingsMethodSkillsHelp =>
      'Kodlash ishga tushirishlari agnts uslubiy koʻnikmalarini oladi: repozitoriyda allaqachon qilinganidek yana bir element qoʻshish, atrofdagi uslubga amal qilish, yozishdan oldin qayta foydalanish va maʼlumotlar bazasi sxemasini xavfsiz oʻzgartirish. Muse koʻnikmani faqat mos kelganda yuklaydi; Analitikada solishtiring.';

  @override
  String get harnessSettingsSecondOpinion => 'Ikkinchi fikr';

  @override
  String get harnessSettingsSecondOpinionHelp =>
      'Boshqa model murakkab tasklarning tanlangan yondashuvini oʻqib, rozi yoki rozi emasligini aytadi. Boʻsh boʻlsa oʻchiq.';

  @override
  String get harnessSettingsSecondOpinionHint => 'masalan, opus yoki codex:gpt-5-codex';

  @override
  String get harnessSettingsAdvanced => 'Qoʻshimcha: cheklov hooklari';

  @override
  String get harnessSettingsAdvancedHelp => 'Alohida hooklarni oʻchiring; qolganini profil hal qiladi.';

  @override
  String get harnessSettingsHook_pre_secret => 'maxfiy maʼlumotlar va .env fayllarini rad etish';

  @override
  String get harnessSettingsHook_pre_redflags =>
      'testlarni oʻtkazib yuborish, linterlarni oʻchirish, tekshiruvlarni zaiflashtirishni rad etish';

  @override
  String get harnessSettingsHook_pre_rules => 'shablonli jamoa qoidalarini qoʻllash';

  @override
  String get harnessSettingsHook_pre_fact_check => 'faylni birinchi tahrirlashdan oldin faktlarni soʻrash';

  @override
  String get harnessSettingsHook_pre_destructive => 'buzuvchi buyruqlardan oldin qaytarish rejasini soʻrash';

  @override
  String get harnessSettingsHook_post_edit_check => 'har bir tahrirlangan faylni tekshirish (formatter, linter)';

  @override
  String get harnessSettingsHook_stop_gate => 'Muse tugatishidan oldin build va lint oʻtishi kerak';

  @override
  String get harnessSettingsHook_session_progress => 'kontekst siqilgandan keyin rejani qaytarish';

  @override
  String get harnessSettingsCodex => 'Kodni Codex da yozish';

  @override
  String get harnessSettingsCodexHelp =>
      'Codex model nomi kod yozishni Muse oʻrniga Codex CLI da ishga tushiradi; boʻsh boʻlsa Muse. OpenAI integratsiyasi va ruxsat etilgan hostlarda api.openai.com kerak (Sozlamalar → Preview).';

  @override
  String get harnessSettingsCodexConnect => 'OpenAI integratsiyasi';

  @override
  String get harnessSettingsQualityTitle => 'Prompt versiyalari boʻyicha cheklovlar';

  @override
  String get harnessSettingsQualitySub => 'Har bir prompt versiyasidagi tasklar uchun agnts-guard va tekshiruvlar nima qildi.';

  @override
  String get harnessSettingsColBlocks => 'Bloklangan';

  @override
  String get harnessSettingsColBlocksHint => 'Kod yozish ishga tushirishlarida agnts-guard rad etgan harakatlar';

  @override
  String get harnessSettingsColStopSaves => 'Toʻxtash tekshiruvi qutqargan';

  @override
  String get harnessSettingsColStopSavesHint =>
      'Toʻxtash tekshiruvi yiqilgan tekshiruvlarni qaytargan, keyin agnts tekshiruvlari birinchi urinishda oʻtgan tasklar';

  @override
  String get harnessSettingsColStalls => 'Tiqilishlar';

  @override
  String get harnessSettingsColStallsHint => 'Ishga tushirishlar necha marta tiqilib qolgandek koʻringan';

  @override
  String get harnessSettingsColProven => 'Isbotlangan tuzatishlar';

  @override
  String get harnessSettingsColProvenHint => 'Testi oʻzgarishdan oldin yiqilgan va keyin oʻtgan xato tuzatishlari, isboti borlar ichidan';

  @override
  String get harnessSettingsColAdopted => 'Qabul qilingan izohlar';

  @override
  String get harnessSettingsColAdoptedHint => 'Odamlar oʻz fikr-mulohazasiga kiritgan review izohlari';

  @override
  String get harnessSettingsColTokens => 'Tayyor taskka tokenlar';

  @override
  String get harnessSettingsColTokensHint => 'Tayyor taskning oʻrtacha tokenlari, barcha bosqichlar';

  @override
  String get harnessSettingsColFactCheck => 'Faktlarni tekshirish, birinchi urinish';

  @override
  String get harnessSettingsColFactCheckHint =>
      'Faktlarni tekshirish guruhidagi tasklarning birinchi urinishda qabul qilinish ulushi, barcha tayyor tasklar ulushi yonida';

  @override
  String get harnessSettingsSkillsTitle => 'Uslubiy koʻnikmalar';

  @override
  String get harnessSettingsSkillsSub =>
      'Kodlash ishga tushirishlari har bir koʻnikmani olgan tiketlar, takrorlar bilan birga, koʻnikmasiz tiketlar yonida. Solishtirish uchun bir xil tiketlarni sozlama oʻchiq va yoqilgan holda takrorlang.';

  @override
  String get harnessSettingsSkillNone => 'yoʻq (asos)';

  @override
  String get harnessSettingsColSkill => 'Koʻnikma';

  @override
  String get harnessSettingsColSkillTickets => 'Tiketlar';

  @override
  String get harnessSettingsColSkillTicketsHint => 'Koʻnikmani olgan kodlash ishga tushirishli tiketlar';

  @override
  String get harnessSettingsColLoaded => 'Yuklangan';

  @override
  String get harnessSettingsColLoadedHint => 'Muse koʻnikmani yuklagan tiketlar ulushi';

  @override
  String get harnessSettingsColSkillFirstTry => 'Birinchi urinishda';

  @override
  String get harnessSettingsColSkillFirstTryHint => 'Tayyor tiketlardan, inson oʻzgartirish soʻramasdan tayyor boʻlganlari';

  @override
  String get harnessSettingsColLoadedFirstTry => 'Birinchi urinishda, yuklangan';

  @override
  String get harnessSettingsColLoadedFirstTryHint => 'Muse koʻnikmani yuklagan tayyor tiketlarning birinchi urinish ulushi';

  @override
  String get harnessSettingsColTargeted => 'Maqsadli izohlar';

  @override
  String get harnessSettingsColTargetedHint =>
      'Koʻnikmalar nishonga olgan turdagi tiketdagi koʻrib chiqish izohlari: arxitektura, qoʻllab-quvvatlanuvchanlik va migratsiya fayllaridagi har qanday izoh';

  @override
  String harnessSettingsXOfY(String x, String y) {
    return '$y dan $x';
  }

  @override
  String harnessSettingsVsAll(String n) {
    return 'barchasi $n%';
  }

  @override
  String get harnessSettingsEffort => 'Fikrlash darajasi';

  @override
  String get harnessSettingsEffortHelp =>
      'Muse har bir bosqichda qanchalik chuqur o‘ylashi (Muse’dagi --effort). Yuqori daraja sekinroq va rejangizdan ko‘proq sarflaydi. Murakkab tiketlarda kod va ko‘rib chiqish o‘z darajasidan foydalanadi.';

  @override
  String get harnessSettingsEffortAnalyze => 'Tahlil';

  @override
  String get harnessSettingsEffortCoding => 'Kod';

  @override
  String get harnessSettingsEffortReview => 'Ko‘rib chiqish';

  @override
  String get harnessSettingsEffortComplex => 'Murakkab tiketlar';

  @override
  String get harnessSettingsEffort_ => 'Standart';

  @override
  String get harnessSettingsEffort_low => 'Past';

  @override
  String get harnessSettingsEffort_medium => 'O‘rta';

  @override
  String get harnessSettingsEffort_high => 'Yuqori';

  @override
  String get harnessSettingsRecheckComplex => 'Murakkab tahlillarni qayta tekshirish';

  @override
  String get harnessSettingsRecheckComplexHelp =>
      'Tahlil modeli tiketni murakkab deb baholasa, kod modeli kod yozilishidan oldin tahlilni qayta o‘qiydi va xato yoki yetishmayotgan joylarni tuzatadi.';

  @override
  String get harnessSettingsBaselineChecks => 'Avval boshlang‘ich kommitni tekshirish';

  @override
  String get harnessSettingsBaselineChecksHelp =>
      'Tiketning birinchi kod yozish bosqichidan oldin agnts ish boshlanadigan kommitda tekshiruvlarni ishga tushiradi. U yerda allaqachon yiqilayotgan narsa tiketga tegishli emas: unga tuzatish urinishlari sarflanmaydi va ko‘rib chiquvchi u avval ham yiqilganini ko‘radi. Natijalar bir kommitdan boshlangan tiketlar uchun umumiy.';

  @override
  String get harnessTicketFlag_secret => 'Ehtimoliy maxfiy kalit';

  @override
  String get harnessTicketFlag_env_file => '.env fayli qo‘shilgan';

  @override
  String get harnessTicketFlag_debug_leftover => 'Nosozlik chiqishi qoldirilgan';

  @override
  String get harnessTicketFlag_check_config => 'Tekshiruv sozlamasi o‘zgargan';

  @override
  String get harnessTicketFlag_rule_violation => 'Jamoa qoidasi buzilgan';

  @override
  String get harnessTicketSecretsTitle => 'O‘zgarishda haqiqiy maxfiy ma’lumot bo‘lishi mumkin';

  @override
  String harnessTicketSecretsBody(num n) {
    return 'agnts $n ta qatorni ehtimoliy maxfiy kalit yoki .env fayli deb belgiladi. Ularni «Ko‘rib chiqish» bo‘limidagi xavfli belgilarda tekshiring: ular haqiqiy maxfiy ma’lumot emasligini tasdiqlamaguningizcha agnts o‘zgarishni yubormaydi.';
  }

  @override
  String get harnessTicketSecretsConfirm => 'Tekshirdim: bular haqiqiy maxfiy ma’lumot emas';

  @override
  String get harnessTicketSecretsDone => 'Tasdiqlandi: belgilangan qatorlar haqiqiy maxfiy ma’lumot emas.';

  @override
  String get harnessTicketSecretsNeeded => 'Avval maxfiy deb belgilangan qatorlar haqiqiy maxfiy ma’lumot emasligini tasdiqlang.';

  @override
  String get harnessTicketProofTitle => 'Tuzatishning isboti';

  @override
  String get harnessTicketProof_proven => 'Isbotlandi';

  @override
  String get harnessTicketProof_not_reproduced => 'Takrorlanmadi';

  @override
  String get harnessTicketProof_still_failing => 'Hali ham xato';

  @override
  String get harnessTicketProof_inconclusive => 'Noaniq';

  @override
  String get harnessTicketProof_no_test => 'Test yo‘q';

  @override
  String get harnessTicketProof_error => 'Tekshirilmadi';

  @override
  String get harnessTicketProofHelp_proven => 'Xatoni takrorlovchi test o‘zgarishdan oldingi kodda yiqiladi va keyin o‘tadi.';

  @override
  String get harnessTicketProofHelp_not_reproduced => 'Test o‘zgarishdan oldin ham o‘tadi, demak u xatoni ko‘rsatmaydi.';

  @override
  String get harnessTicketProofHelp_still_failing => 'Test o‘zgarish bilan ham yiqilmoqda.';

  @override
  String get harnessTicketProofHelp_inconclusive =>
      'Testni o‘zgarishdan oldingi kodda ishga tushirib bo‘lmadi; unga tuzatish qo‘shadigan narsa kerak bo‘lishi mumkin.';

  @override
  String get harnessTicketProofHelp_no_test => 'Xatoni hech bir avtomatik test takrorlamaydi.';

  @override
  String get harnessTicketProofHelp_error => 'agnts tuzatishni tekshira olmadi.';

  @override
  String harnessTicketProofBase(String sha) {
    return '$sha dan boshlangan';
  }

  @override
  String harnessTicketProofBefore(String code) {
    return 'O‘zgarishdan oldin (chiqish kodi $code)';
  }

  @override
  String harnessTicketProofAfter(String code) {
    return 'O‘zgarishdan keyin (chiqish kodi $code)';
  }

  @override
  String get harnessTicketCoverageTitle => 'O‘zgargan qatorlarning qamrovi';

  @override
  String harnessTicketCoveragePct(String pct, String covered, String total) {
    return 'Testlar o‘zgargan qatorlarning $pct% qismini bajardi ($total tadan $covered ta)';
  }

  @override
  String harnessTicketCoverageBelow(String n) {
    return 'Repozitoriyning $n% chegarasidan past';
  }

  @override
  String get harnessTicketCoverageNone => 'O‘zgargan qatorlarning hech biri qamrov hisoboti o‘lchaydigan kod emas.';

  @override
  String harnessTicketCoverageLines(String ranges) {
    return 'Bajarilmagan: $ranges qatorlar';
  }

  @override
  String harnessTicketCoverageError(String error) {
    return 'Qamrovni o‘lchab bo‘lmadi: $error';
  }

  @override
  String harnessTicketConfidence(String n) {
    return '$n% ishonch';
  }

  @override
  String get harnessTicketPass_security => 'Xavfsizlik tekshiruvi';

  @override
  String get harnessTicketPass_failures => 'Xatolar tekshiruvi';

  @override
  String get harnessTicketPass_tests => 'Testlar tekshiruvi';

  @override
  String get harnessTicketPass_types => 'Turlar tekshiruvi';

  @override
  String get harnessTicketAdopted => 'Fikringizda';

  @override
  String get harnessTicketDeep => 'Chuqur ko‘rib chiqish';

  @override
  String harnessTicketDropped(num n) {
    return '$n ta topilma ko‘rsatilmadi (past ishonch yoki takror)';
  }

  @override
  String get harnessTicketDefect => 'Xatoni tuzatish';

  @override
  String get harnessTicketAcceptanceTitle => 'Qabul mezonlari';

  @override
  String get harnessTicketCheck_ui => 'Ilovada';

  @override
  String get harnessTicketCheck_api => 'API';

  @override
  String get harnessTicketCheck_test => 'Test';

  @override
  String get harnessTicketCheck_manual => 'Qo‘lda';

  @override
  String get harnessTicketSecondTitle => 'Ikkinchi fikr';

  @override
  String harnessTicketSecondBy(String model) {
    return '$model dan';
  }

  @override
  String get harnessTicketSecondAgrees => 'Rozi';

  @override
  String get harnessTicketSecondConcerns => 'E’tirozlari bor';

  @override
  String get harnessTicketSecondAlternative => 'Buning o‘rniga qilardi';

  @override
  String harnessTicketSecondError(String error) {
    return 'Ikkinchi fikr yo‘q: $error';
  }

  @override
  String get harnessTicketAccTitle => 'Qabul tekshiruvi';

  @override
  String get harnessTicketAcc_ok => 'Hammasi bajarildi';

  @override
  String get harnessTicketAcc_partial => 'Qisman tekshirildi';

  @override
  String get harnessTicketAcc_failed => 'Bajarilmadi';

  @override
  String get harnessTicketVerdict_pass => 'Bajarildi';

  @override
  String get harnessTicketVerdict_fail => 'Bajarilmadi';

  @override
  String get harnessTicketVerdict_unknown => 'Tekshirilmadi';

  @override
  String get harnessTicketAccSteps => 'Qadamlar';

  @override
  String get harnessTicketAccShot => 'Skrinshot';

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
  String get integrationsAssignedOnly => 'Faqat menga biriktirilgan vazifalar';

  @override
  String integrationsAssignedOnlyHelp(String email) {
    return 'agnts belgili vazifani faqat u agnts Jira\'ga ulangan akkauntga ($email) biriktirilgan boʻlsa oladi. Barcha belgili vazifalarni olish uchun oʻchiring.';
  }

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
  String get integrationsLabelsTitle => 'Tiketlarni qanday belgilash';

  @override
  String get integrationsLabelsSub =>
      'Jira\'dagi tugallanmagan vazifaga shu belgilardan birini qoʻshing. Harf katta-kichikligi muhim emas.';

  @override
  String get integrationsLabelsRepo =>
      'Vazifa oʻz loyihasiga bogʻlangan repozitoriyga tushadi (Repozitoriylar → Jira loyihasi). Boshqasiga yuborish uchun agnts\'dagi repozitoriy nomi bilan repo: belgisini qoʻshing, masalan repo:web. Repozitoriysiz faqat rejalar, tahlillar va xato sabablarini izlash ishlaydi.';

  @override
  String get integrationsLabelsMany => 'Bir nechta tur belgisi boʻlsa, shu roʻyxatda birinchi kelgani tanlanadi.';

  @override
  String get integrationsLabelsLater =>
      'Ish boshlanishidan oldin qoʻshilgan tur belgisi tiket turini oʻzgartiradi. Barcha agnts belgilari olib tashlansa, Jira\'dan yangilanishlar kelmay qoladi.';

  @override
  String get integrationsPlaneLabelsSub => 'Ochiq vazifaga shu belgilardan birini qoʻshing. Harf katta-kichikligi muhim emas.';

  @override
  String get integrationsPlaneLabelsCreate =>
      'Plane belgilari loyihaga tegishli: avval har bir bogʻlangan loyihada kerakli belgilarni yarating.';

  @override
  String get integrationsPlaneLabelsRepo =>
      'Loyihani identifikatori orqali (WEB-123 dagi WEB) repozitoriyga bogʻlang: Repozitoriylar → Plane loyihasi. Sinxronlash faqat bogʻlangan loyihalarni oʻqiydi, kod va testlar uchun esa repozitoriy kerak. Bitta vazifani boshqa repozitoriyga yuborish uchun agnts\'dagi repozitoriy nomi bilan repo: belgisini qoʻshing, masalan repo:web.';

  @override
  String get integrationsPlaneLabelsLater =>
      'Ish boshlanishidan oldin qoʻshilgan tur belgisi tiket turini oʻzgartiradi. Barcha agnts belgilari olib tashlansa, Plane\'dan yangilanishlar kelmay qoladi.';

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
  String integrationsSynced(String found, String created, String updated, String waiting) {
    return 'Siz uchun ochiq vazifalar: $found, yangilari: $created, yangilangani: $updated, agnts boshlagandan keyin oʻzgargani: $waiting';
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
  String get integrationsGitEvents_github => 'Pushes, Pull requests, Workflow runs';

  @override
  String get integrationsGitEvents_gitlab => 'Push events, Merge request events, Pipeline events';

  @override
  String get integrationsGitWebhookWhy =>
      'Pull yoki merge request birlashtirilganda agnts tiketni belgilaydi va Jira yoki Plane vazifasini treker sahifasida tanlangan holatga oʻtkazadi. Pipeline hodisalari repozitoriy sahifasini yangilab turadi. Pushlar branchi yoki xabarida tiket raqami bor commitlarni o\'sha tiketga bog\'laydi.';

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
  String get integrationsName_openai => 'OpenAI';

  @override
  String get integrationsDesc_openai =>
      'agnts ning ikkinchi kod vositasi Codex CLI dagi ishga tushirishlar uchun OpenAI API kaliti. Undan foydalanish uchun Sozlamalarda codex: modelini tanlang.';

  @override
  String get integrationsConnectSub_openai =>
      'OpenAI API kalitini qoʻying. agnts uni tekshiradi, shifrlangan holda saqlaydi va faqat Codex dagi ishga tushirishlarga beradi.';

  @override
  String get integrationsTokenOpen_openai => 'API kalitlarini ochish';

  @override
  String get integrationsTokenStep1_openai => 'OpenAI platformasidagi API kalitlari sahifasini oching (pastdagi tugma) va kiring.';

  @override
  String get integrationsTokenStep2_openai => 'Yangi maxfiy kalit yarating, yaxshisi xarajat chegarasi bor loyihada.';

  @override
  String get integrationsTokenStep3_openai => 'Kalitni nusxalang (u sk- bilan boshlanadi) va pastdagi «API kaliti» maydoniga qoʻying.';

  @override
  String get integrationsTokenStep4_openai =>
      'Codex ishga tushirishlari OpenAI ga murojaat qila olishi uchun Sozlamalar → Preview boʻlimida api.openai.com ni ruxsat etilgan hostlarga qoʻshing.';

  @override
  String get integrationsOpenaiKeyHelp => 'Serveringizda shifrlangan holda saqlanadi. Uni faqat Codex dagi ishga tushirishlar oladi.';

  @override
  String get integrationsOpenaiHelp =>
      'Codex ishga tushirishlarida agnts-guard hooklari yoʻq: ishga tushirishdan keyingi agnts tekshiruvlari (qizil bayroqlar, build, lint, testlar, review) baribir ishlaydi. Ishga tushirishlarga ruxsat etilgan hostlarda api.openai.com ham kerak.';

  @override
  String get integrationsName_muse => 'Muse Code';

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
  String get kindReview => 'PR koʻrib chiqish';

  @override
  String get kindReviewHint => 'Boshqa birov ochgan pull requestni tekshirish. GitHub yoki GitLab’dan keladi.';

  @override
  String get kindSwaggertest => 'Swagger testi';

  @override
  String get kindSwaggertestHint =>
      'HTTP API\'ni Swagger/OpenAPI spetsifikatsiyasi boʻyicha tekshirish. Repozitoriy ixtiyoriy; natija — tekshiruvlar jadvali va hisobot.';

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
  String get learnReadingNote => 'Bu havolalarni Muse taklif qilgan. Ularga tayanishdan oldin tekshiring.';

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
  String get linkedCommitsTitle => 'Commitlar';

  @override
  String linkedCommitsSub(String number) {
    return 'Branchi yoki xabarida $number bor barcha commitlar: pushlardan va repozitoriylarning yaqin tarixidan.';
  }

  @override
  String linkedCommitsNone(String number) {
    return '$number bilan commitlar hali yo\'q. Shu raqam bilan branch push qiling yoki commit xabarini yozing, commitlar shu yerda ko\'rinadi.';
  }

  @override
  String linkedCommitsTotal(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta commit');
    return '$_temp0';
  }

  @override
  String get linkedCommitsOnBranch => 'branch';

  @override
  String get linkedCommitsOnMessage => 'xabar';

  @override
  String get linkedCommitsOnBranchHint => 'Raqam branch nomida bor';

  @override
  String get linkedCommitsOnMessageHint => 'Raqam commit xabarida bor';

  @override
  String linkedCommitsMeta(String author, String repo, String branch) {
    return '$author · $repo · $branch';
  }

  @override
  String linkedCommitsMore(String n) {
    return 'Yana ko\'rsatish ($n ta qoldi)';
  }

  @override
  String get linkedCommitsLoadError => 'Commitlarni yuklab bo\'lmadi.';

  @override
  String get linkedCommitsTickets => 'Tiketlar';

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
  String get logsTypeBudget => 'Sarf';

  @override
  String get maccountPasswordInstead => 'Parol bilan kirish';

  @override
  String get maccountGoogleInstead => 'Google orqali davom etish';

  @override
  String get maccountSetupLede =>
      'Adminlar ikki bosqichli kirish bilan kiradi. Akkauntni quyidagi kalit orqali autentifikator ilovasiga qo‘shing (yoki sozlash havolasini shu telefonda oching), so‘ng u ko‘rsatgan 6 xonali kodni kiriting.';

  @override
  String get maccountTotpOpen => 'Autentifikatorda ochish';

  @override
  String get maccountLinkFailed => 'Havolani ochib bo‘lmadi.';

  @override
  String get maccountCurrent => 'Joriy';

  @override
  String get maccountHaveInvite => 'Taklifingiz bormi?';

  @override
  String get maccountInviteHint => 'Taklif havolasini qo‘ying';

  @override
  String get maccountInviteOpen => 'Taklifni ochish';

  @override
  String maccountJoined(String date) {
    return '$date dan beri';
  }

  @override
  String get maccountPaying => 'To‘lovni brauzerda yakunlang. To‘lov tizimi tasdiqlashi bilan kreditlar shu yerda ko‘rinadi.';

  @override
  String maccountChars(String n, String max) {
    return '$n / $max';
  }

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
  String get massistantTitle => 'Yordamchi';

  @override
  String get massistantFab => 'Yordamchidan soʻrash';

  @override
  String get massistantMoreRow => 'Yordamchi';

  @override
  String get massistantMoreRowSub => 'Ish maydoni haqida soʻrang';

  @override
  String get massistantPlaceholder => 'Vazifalar, CI, xarajatlar haqida soʻrang…';

  @override
  String get massistantSend => 'Yuborish';

  @override
  String massistantCount(String n) {
    return '$n / 1000';
  }

  @override
  String get massistantNewConversation => 'Yangi suhbat';

  @override
  String get massistantHistory => 'Suhbatlar';

  @override
  String get massistantHistoryEmpty => 'Hali suhbatlar yoʻq.';

  @override
  String get massistantDelete => 'Oʻchirish';

  @override
  String get massistantDeleted => 'Suhbat oʻchirildi';

  @override
  String get massistantEmptyTitle => 'agntsdan ishingiz haqida soʻrang';

  @override
  String get massistantEmptyText =>
      'Yordamchi vazifalaringiz, CI va xarajatlaringiz boʻyicha javob beradi va tilga olganlariga havola qoʻyadi. Undan biror narsani tasdiqlash, ishga tushirish yoki yaratishni soʻrasangiz, u amalni taklif qiladi, siz esa tasdiqlaysiz.';

  @override
  String get massistantPrivate => 'Suhbatlaringizni faqat siz koʻrasiz. Ular 30 kun saqlanadi.';

  @override
  String get massistantSuggestWaiting => 'Meni nima kutmoqda?';

  @override
  String get massistantSuggestCi => 'Nega CI qizil?';

  @override
  String get massistantSuggestSpend => 'Bu hafta qancha sarfladik?';

  @override
  String get massistantSuggestDone => 'agnts bu hafta nimalarni tugatdi?';

  @override
  String massistantThinking(String seconds) {
    return 'Oʻylayapman… $seconds s';
  }

  @override
  String massistantReading(String what) {
    return '$what oʻqilmoqda';
  }

  @override
  String get massistantFileInbox => 'kiruvchilar';

  @override
  String get massistantFileTickets => 'vazifalar';

  @override
  String massistantFileTicket(String key) {
    return '$key';
  }

  @override
  String get massistantFileCi => 'CI nosozliklari';

  @override
  String get massistantFileUsage => 'tarif limitlari';

  @override
  String get massistantFileAnalytics => 'analitika';

  @override
  String get massistantFileRepos => 'repozitoriylar';

  @override
  String get massistantFileLessons => 'darslar';

  @override
  String get massistantFileConversation => 'suhbat';

  @override
  String get massistantFileQuestion => 'savolingiz';

  @override
  String get massistantFileOther => 'ish maydoni';

  @override
  String get massistantFailed => 'Javob yoʻq';

  @override
  String get massistantAskAgain => 'Yana soʻrash';

  @override
  String massistantLinkCi(String id) {
    return 'CI #$id';
  }

  @override
  String massistantLinkLesson(String id) {
    return 'Dars #$id';
  }

  @override
  String massistantTook(String seconds) {
    return '$seconds s';
  }

  @override
  String get massistantHelpful => 'Foydali';

  @override
  String get massistantNotHelpful => 'Foydasiz';

  @override
  String get massistantRateTitle => 'Javob qanday boʻldi?';

  @override
  String get massistantRateComment => 'Nima notoʻgʻri yoki yetishmadi? (ixtiyoriy)';

  @override
  String get massistantRateShare => 'agnts yaxshiroq javoblarni sinashi uchun bu savol maʼlumotlarini saqlash';

  @override
  String get massistantRateNote => 'Baho, izoh, savol va javobni ish maydoni egasi koʻradi.';

  @override
  String get massistantRateSend => 'Yuborish';

  @override
  String get massistantRateClear => 'Bahoni olib tashlash';

  @override
  String get massistantRated => 'Baho uchun rahmat';

  @override
  String get massistantStatsTitle => 'Yordamchi';

  @override
  String get massistantStatsQuestions => 'Savollar';

  @override
  String get massistantStatsAnswered => 'Javob berildi';

  @override
  String get massistantStatsMedian => 'Oʻrtacha vaqt';

  @override
  String get massistantStatsHelpful => 'Foydali';

  @override
  String get massistantStatsTokens => 'Tokenlar';

  @override
  String massistantStatsPeople(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n kishi soʻradi', one: '$n kishi soʻradi');
    return '$_temp0';
  }

  @override
  String get massistantStatsVersions => 'Prompt versiyalari boʻyicha';

  @override
  String massistantStatsVersionRow(String answered, String failed, String up, String down, String median) {
    return '$answered javob · $failed nosoz · $up 👍 $down 👎 · $median';
  }

  @override
  String get massistantStatsNone => 'Bu davrda savollar boʻlmadi.';

  @override
  String get massistantStatsRated => 'Baholangan javoblar';

  @override
  String get massistantRatedEmpty => 'Hali baholangan javoblar yoʻq.';

  @override
  String get massistantRatedShared => 'Promptlarni sinash uchun saqlangan';

  @override
  String massistantStatsParts(String start, String snapshot, String claude) {
    return 'Konteyner $start · maʼlumot $snapshot · Muse $claude';
  }

  @override
  String massistantStatsWarm(String n, String total) {
    return '$total tadan $n tasi ishlab turgan konteynerda';
  }

  @override
  String get massistantStatsSeeRated => 'Baholangan javoblar';

  @override
  String get massistantDeleteTitle => 'Bu suhbat oʻchirilsinmi?';

  @override
  String get massistantDeleteText => 'Undagi savol va javoblar butunlay oʻchiriladi.';

  @override
  String get massistantSendHint => 'Enter — yuborish, Shift+Enter — yangi qator';

  @override
  String get massistantConversationsLede => 'Savollaringiz va yordamchining javoblari. Ularni faqat siz koʻrasiz; 30 kun saqlanadi.';

  @override
  String get massistantOpenChat => 'Chatni ochish';

  @override
  String get massistantSuggestAct => 'Koʻrikdan oʻtganlarini tasdiqla';

  @override
  String get massistantFileMe => 'rolingiz';

  @override
  String get massistantFileGroups => 'repozitoriy guruhlari';

  @override
  String get massistantActionHint => 'Siz tasdiqlamaguningizcha hech narsa boʻlmaydi.';

  @override
  String get massistantActionConfirm => 'Tasdiqlash';

  @override
  String get massistantActionDecline => 'Rad etish';

  @override
  String get massistantActionRunning => 'Bajarilmoqda…';

  @override
  String get massistantActionDone => 'Bajarildi';

  @override
  String get massistantActionFailed => 'Bajarilmadi';

  @override
  String get massistantActionCancelled => 'Rad etildi';

  @override
  String get massistantActionExpired => 'Muddati oʻtdi. Qaytadan soʻrang.';

  @override
  String get massistantActionConfirmTitle => 'Tasdiqlaysizmi?';

  @override
  String massistantActionConfirmText(String summary) {
    return '$summary\n\nBuni bekor qilib boʻlmaydi.';
  }

  @override
  String massistantActionNotOffered(String reason) {
    return 'Taklif qilinmadi: $reason';
  }

  @override
  String get massistantStatsActions => 'Tasdiqlangan amallar';

  @override
  String massistantStatsActionsLine(String proposed, String done, String failed, String cancelled, String expired, String notOffered) {
    return '$proposed taklif qilindi · $done bajarildi · $failed bajarilmadi · $cancelled rad etildi · $expired muddati oʻtdi · $notOffered taklif qilinmadi';
  }

  @override
  String get massistantStatsActionsOffered => 'Taklif qilindi';

  @override
  String massistantStatsVersionActions(String proposed, String done) {
    return '$proposed amal taklif qilindi · $done bajarildi';
  }

  @override
  String get massistantVoiceStart => 'Ovoz bilan soʻrash';

  @override
  String get massistantVoiceSend => 'Toʻxtatib soʻrash';

  @override
  String get massistantVoiceRecording => 'Yozilmoqda';

  @override
  String get massistantVoiceHearing => 'Muse savolingizni tinglamoqda…';

  @override
  String massistantVoiceLimit(String n) {
    return '$n daqiqagacha';
  }

  @override
  String get massistantVoiceDenied => 'Ovoz bilan soʻrash uchun bu saytga mikrofonga ruxsat bering.';

  @override
  String get massistantVoiceNoMic => 'Mikrofonni ochib boʻlmadi.';

  @override
  String get mciTitle => 'CI nosozliklari';

  @override
  String get mciLede => 'Qizarib ketgan kuzatiladigan tarmoqlar: har bir xato uchun bitta qator.';

  @override
  String get mciFilterRed => 'Qizil';

  @override
  String get mciFilterFlaky => 'Beqaror';

  @override
  String get mciFilterAll => 'Hammasi';

  @override
  String get mciEmptyRed => 'Kuzatiladigan tarmoqlarning hech biri qizil emas.';

  @override
  String get mciEmpty => 'Bu yerda CI nosozliklari yoʻq.';

  @override
  String get mciStatus_triage => 'Tekshirilmoqda';

  @override
  String get mciStatus_open => 'Qizil';

  @override
  String get mciStatus_fixing => 'Tuzatilmoqda';

  @override
  String get mciStatus_fixed => 'Tuzatildi';

  @override
  String get mciStatus_resolved => 'Yana yashil';

  @override
  String get mciStatus_flaky => 'Beqaror';

  @override
  String get mciStatus_infra => 'Infratuzilma';

  @override
  String get mciStatus_muted => 'Oʻchirilgan';

  @override
  String get mciStatus_regression => 'Qaytdi';

  @override
  String mciLastSeen(String when) {
    return 'oxirgisi $when';
  }

  @override
  String get mciFactFirstCommit => 'Birinchi yiqilgan kommit';

  @override
  String get mciFactCount => 'Yiqildi';

  @override
  String mciTimes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n marta', one: '$n marta');
    return '$_temp0';
  }

  @override
  String get mciFactLastSeen => 'Oxirgi marta';

  @override
  String get mciFactFlaky => 'Qayta ishga tushirishda oʻtdi';

  @override
  String get mciJob => 'Vazifa';

  @override
  String get mciBranch => 'Tarmoq';

  @override
  String get mciFirstError => 'Birinchi xato';

  @override
  String get mciLogTail => 'Log oxiri';

  @override
  String get mciLogNote => 'Vazifa logidan, maxfiy maʼlumotlar olib tashlangan.';

  @override
  String get mciNoSample => 'Bu nosozlik uchun log parchasi saqlanmagan.';

  @override
  String get mciRuns => 'Yiqilgan ishga tushirishlar';

  @override
  String mciRunsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n yiqilgan ishga tushirish', one: '$n yiqilgan ishga tushirish');
    return '$_temp0';
  }

  @override
  String get mciRunFlaky => 'qayta ishga tushirishda oʻtdi';

  @override
  String get mciTicket => 'Tiket';

  @override
  String mciForeignPr(String n) {
    return 'Bu nosozlik boshqa birovning pull requestida (#$n): u yerda agnts faqat izoh qoldiradi.';
  }

  @override
  String get mciFix => 'Tuzatish';

  @override
  String get mciFixConfirm =>
      'agnts bu nosozlikni tuzatish uchun tiket ochadi. Hech narsa yuborilishidan oldin tuzatishni siz tekshirasiz.';

  @override
  String get mciMute => 'Oʻchirish';

  @override
  String get mciUnmute => 'Yoqish';

  @override
  String get mciMutedDone => 'Oʻchirildi: siz yoqmaguningizcha agnts bu nosozlikka tegmaydi.';

  @override
  String get mciUnmutedDone => 'Yoqildi.';

  @override
  String get mciRerun => 'Qayta ishga tushirish';

  @override
  String get mciRerunDone => 'Qayta ishga tushirish boshlandi.';

  @override
  String get mciCardTitle => 'CI nosozligi';

  @override
  String get mciCardOpen => 'CI nosozligini ochish';

  @override
  String mciCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'CI pull requestni $n marta qaytardi',
      one: 'CI pull requestni $n marta qaytardi',
    );
    return '$_temp0';
  }

  @override
  String get mciSourceCi => 'CI';

  @override
  String get mciNotify => 'Kuzatiladigan tarmoq qizarib ketdi';

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
  String get mcpPickWorkspace => 'Ish maydoni';

  @override
  String get mcpPickWorkspaceHelp => 'Claude shu ish maydonida sizning nomingizdan ishlaydi.';

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
  String get mdocumentsTitle => 'Hujjatlar';

  @override
  String get mdocumentsMoreRowSub => 'Ish maydonining hisobotlari va sahifalari';

  @override
  String get mdocumentsAll => 'Hammasi';

  @override
  String get mdocumentsMine => 'Meniki';

  @override
  String get mdocumentsShared => 'Menga ulashilgan';

  @override
  String get mdocumentsEmpty => 'Hali hujjatlar yoʻq';

  @override
  String get mdocumentsEmptyText => 'Hujjatlarni veb-ilovada yozing yoki tiket hisobotidan hujjat yarating.';

  @override
  String get mdocumentsTypePrivate => 'Shaxsiy';

  @override
  String get mdocumentsTypePublic => 'Ochiq';

  @override
  String get mdocumentsWriting => 'agnts yozmoqda';

  @override
  String get mdocumentsFailed => 'Yozib boʻlmadi';

  @override
  String mdocumentsFailedText(String error) {
    return 'agnts hujjatni yoza olmadi: $error';
  }

  @override
  String mdocumentsVersion(String n) {
    return '$n-versiya';
  }

  @override
  String mdocumentsAsOf(String date) {
    return '$date holatidagi maʼlumotlar asosida';
  }

  @override
  String mdocumentsMeta(String owner, String time) {
    return '$owner · $time';
  }

  @override
  String get mdocumentsNoBody => 'Hali hech narsa yozilmagan.';

  @override
  String get mdocumentsLinkedTickets => 'Bogʻlangan tiketlar';

  @override
  String get mdocumentsCopyLink => 'Ochiq havolani nusxalash';

  @override
  String get mdocumentsLinkCopied => 'Havola nusxalandi';

  @override
  String get mdocumentsSharing => 'Ruxsatlar';

  @override
  String get mdocumentsDownloadMd => '.md yuklab olish';

  @override
  String get mdocumentsDownloadPdf => '.pdf yuklab olish';

  @override
  String get mdocumentsPreparingPdf => 'PDF tayyorlanmoqda…';

  @override
  String get mdocumentsPdfSlow => 'PDF odatdagidan uzoqroq tayyorlanmoqda. Bir daqiqadan soʻng qayta urinib koʻring.';

  @override
  String get mdocumentsDownloadFailed => 'Yuklab boʻlmadi';

  @override
  String get mdocumentsPublicLink => 'Ochiq havola';

  @override
  String get mdocumentsPublicHint => 'Havolasi bor har kim tizimga kirmasdan oʻqiy oladi.';

  @override
  String get mdocumentsPublicOff => 'Bu ish maydoni sozlamalarida ochiq hujjatlar oʻchirilgan.';

  @override
  String get mdocumentsResetLink => 'Havolani yangilash';

  @override
  String get mdocumentsResetDone => 'Yangi havola yaratildi; eskisi endi ishlamaydi.';

  @override
  String get mdocumentsWorkspaceAccess => 'Ish maydonidagi hamma';

  @override
  String get mdocumentsAccessNone => 'Ruxsat yoʻq';

  @override
  String get mdocumentsAccessView => 'Koʻra oladi';

  @override
  String get mdocumentsAccessEdit => 'Tahrirlay oladi';

  @override
  String get mdocumentsPeople => 'Odamlar';

  @override
  String get mdocumentsViewerOnlyView => 'Kuzatuvchilar faqat koʻra oladi';

  @override
  String get mdocumentsSave => 'Saqlash';

  @override
  String get mdocumentsSaved => 'Saqlandi';

  @override
  String get mdocumentsSecrets => 'Hujjatda maxfiy maʼlumotlar borga oʻxshaydi. Eʼlon qilishdan oldin ularni olib tashlang:';

  @override
  String mdocumentsSecretLine(String line, String excerpt) {
    return '$line-qator: $excerpt';
  }

  @override
  String get mdocumentsTicketSection => 'Hujjatlar';

  @override
  String get mdocumentsTicketNone => 'Hali bogʻlangan hujjatlar yoʻq.';

  @override
  String get mdocumentsFromReport => 'Hisobotdan hujjat yaratish';

  @override
  String get mdocumentsFromReportStarted => 'agnts hujjatni yozmoqda';

  @override
  String get mdocumentsLedgerSpent => 'Hujjat uchun sarflandi';

  @override
  String get mdocumentsSlides => 'Slaydlar';

  @override
  String get mdocumentsPresent => 'Namoyish qilish';

  @override
  String get mdocumentsNotes => 'Izohlar';

  @override
  String get mdocumentsNoNotes => 'Bu slayd uchun izoh yoʻq.';

  @override
  String get mdocumentsNoSlides => 'Hozircha slaydlar yoʻq.';

  @override
  String get mdocumentsPrevSlide => 'Oldingi slayd';

  @override
  String get mdocumentsNextSlide => 'Keyingi slayd';

  @override
  String get mdocumentsStopPresenting => 'Namoyishni tugatish';

  @override
  String mdocumentsMadeFrom(String title) {
    return 'Manba: “$title”';
  }

  @override
  String get meetingsPageTitle => 'Uchrashuvlar';

  @override
  String get meetingsLede =>
      'Jamoa va siz kiritgan mehmonlar uchun videoqoʻngʻiroqlar. Muse eslatmalarni yozib, kelishilgan ishlarni vazifaga aylantiradi.';

  @override
  String get meetingsStartNow => 'Hozir boshlash';

  @override
  String get meetingsSchedule => 'Rejalashtirish';

  @override
  String get meetingsGetLink => 'Havola olish';

  @override
  String meetingsLinkCopied(String link) {
    return 'Havola nusxalandi: $link';
  }

  @override
  String get meetingsLinkCopiedShort => 'Havola nusxalandi';

  @override
  String get meetingsCopyLink => 'Havolani nusxalash';

  @override
  String get meetingsJoinWithCode => 'Kod yoki havola orqali kirish';

  @override
  String get meetingsCodePlaceholder => 'abc-defg-hij';

  @override
  String get meetingsBadCode => 'Bu uchrashuv kodi emas: u abc-defg-hij koʻrinishida boʻladi.';

  @override
  String get meetingsJoin => 'Kirish';

  @override
  String get meetingsOpen => 'Ochish';

  @override
  String get meetingsTab_upcoming => 'Kelgusi';

  @override
  String get meetingsTab_past => 'Oʻtgan qoʻngʻiroqlar';

  @override
  String get meetingsTab_mine => 'Men olib boraman';

  @override
  String get meetingsNoneUpcoming => 'Hozir yoki keyin boʻladigan uchrashuv yoʻq. Hozir boshlang yoki rejalashtiring.';

  @override
  String get meetingsNoneMine => 'Siz hali uchrashuv olib bormaysiz.';

  @override
  String get meetingsNonePast => 'Hali qoʻngʻiroq boʻlmagan.';

  @override
  String get meetingsLive => 'Davom etmoqda';

  @override
  String meetingsInCallNow(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Qoʻngʻiroqda $n kishi', one: 'Qoʻngʻiroqda $n kishi');
    return '$_temp0';
  }

  @override
  String get meetingsLiveEmpty => 'Qoʻngʻiroq ochiq';

  @override
  String get meetingsNobodyYet => 'Qoʻngʻiroqda hali hech kim yoʻq';

  @override
  String meetingsHostedBy(String name) {
    return 'Olib boruvchi: $name';
  }

  @override
  String get meetingsUntitled => 'Uchrashuv';

  @override
  String get meetingsKind_instant => 'Hozir';

  @override
  String get meetingsKind_scheduled => 'Keyinroq';

  @override
  String get meetingsColMeeting => 'Uchrashuv';

  @override
  String get meetingsColWhen => 'Qachon';

  @override
  String get meetingsColPeople => 'Ishtirokchilar';

  @override
  String get meetingsColNotes => 'Eslatmalar';

  @override
  String meetingsRecordings(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n yozuv', one: '$n yozuv');
    return '$_temp0';
  }

  @override
  String meetingsActionItemsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n vazifa', one: '$n vazifa');
    return '$_temp0';
  }

  @override
  String get meetingsOpenNotes => 'Eslatmalarni ochish';

  @override
  String get meetingsNotes_none => 'Eslatmasiz';

  @override
  String get meetingsNotes_recording => 'Eslatma yozilmoqda';

  @override
  String get meetingsNotes_queued => 'Eslatmalar navbatda';

  @override
  String get meetingsNotes_transcribing => 'Muse tinglamoqda';

  @override
  String get meetingsNotes_writing => 'Muse yozmoqda';

  @override
  String get meetingsNotes_done => 'Eslatmalar tayyor';

  @override
  String get meetingsNotes_failed => 'Eslatmalar chiqmadi';

  @override
  String get meetingsOffTitle => 'Bu serverda uchrashuvlar oʻchirilgan';

  @override
  String get meetingsOffBody => 'Server administratori ularni LiveKit serveri bilan yoqadi (AGNTS_LIVEKIT_URL).';

  @override
  String get meetingsYourReminders => 'Eslatmalaringiz';

  @override
  String get meetingsRemindersSub => 'Siz taklif qilingan uchrashuv boshlanishidan oldin — telefoningizda va shu yerda.';

  @override
  String meetingsMinutesBefore(String n) {
    return '$n daqiqa oldin';
  }

  @override
  String get meetingsNoReminders => 'Eslatmasiz';

  @override
  String get meetingsSettingsTitle => 'Bu ish maydonidagi uchrashuvlar';

  @override
  String get meetingsSettingsSub => 'Yozuvlar, nima va qancha saqlanadi, bitta qoʻngʻiroqqa necha kishi sigʻadi.';

  @override
  String get meetingsAllowRecording => 'Olib boruvchilar qoʻngʻiroqni videoga yozishi mumkin';

  @override
  String get meetingsKeepAudio => 'Muse tinglagandan keyin eslatmalar ovozini saqlash';

  @override
  String get meetingsRetention => 'Yozuv va matnlarni saqlash muddati (kun)';

  @override
  String get meetingsRetentionHelp => '0 — doim saqlanadi.';

  @override
  String get meetingsMaxPeople => 'Bitta qoʻngʻiroqdagi odamlar';

  @override
  String get meetingsServerCan => 'Bu server qila oladi:';

  @override
  String get meetingsRecordingWord => 'Yozuv';

  @override
  String get meetingsNotesWord => 'Eslatmalar';

  @override
  String get meetingsSave => 'Saqlash';

  @override
  String get meetingsSettingsSaved => 'Saqlandi';

  @override
  String get meetingsNewTitle => 'Yangi uchrashuv';

  @override
  String get meetingsNewSub => 'Hozirgi qoʻngʻiroq yoki taklifnomali taqvimdagi uchrashuv.';

  @override
  String get meetingsEditTitle => 'Uchrashuvni oʻzgartirish';

  @override
  String get meetingsWhen => 'Qachon';

  @override
  String get meetingsTitle => 'Nomi';

  @override
  String get meetingsTitlePlaceholder => 'Sprintni rejalashtirish';

  @override
  String get meetingsDate => 'Sana';

  @override
  String get meetingsTime => 'Vaqt';

  @override
  String get meetingsDuration => 'Davomiyligi';

  @override
  String meetingsMinutes(String n) {
    return '$n daqiqa';
  }

  @override
  String meetingsTimeZoneIs(String zone) {
    return 'Vaqt $zone boʻyicha.';
  }

  @override
  String get meetingsDescription => 'Kun tartibi';

  @override
  String get meetingsDescriptionPlaceholder => 'Uchrashuv nima uchun. Muse eslatmalarni yozganda buni oʻqiydi.';

  @override
  String get meetingsAccess => 'Kim taqillatmasdan kiradi';

  @override
  String get meetingsAccess_workspace => 'Ish maydonidagi hamma';

  @override
  String get meetingsAccess_invited => 'Faqat taklif qilinganlar';

  @override
  String get meetingsAccessHelp_workspace => 'Aʼzolar kiradi; mehmonlar taqillatadi.';

  @override
  String get meetingsAccessHelp_invited => 'Taklif qilinganlar kiradi; boshqa aʼzolar va mehmonlar taqillatadi.';

  @override
  String get meetingsGuestsMode => 'Mehmonlar';

  @override
  String get meetingsGuests_knock => 'Taqillatadi';

  @override
  String get meetingsGuests_open => 'Ochiq';

  @override
  String get meetingsGuests_off => 'Yoʻq';

  @override
  String get meetingsGuestsHelp_knock => 'Aʼzo boʻlmaganlar olib boruvchi kiritguncha kutadi.';

  @override
  String get meetingsGuestsHelp_open => 'Havolasi borlar qoʻngʻiroq tugaguncha kutmasdan kiradi.';

  @override
  String get meetingsGuestsHelp_off => 'Faqat ish maydoni aʼzolari.';

  @override
  String meetingsGuestsAre(String mode) {
    return 'mehmonlar: $mode';
  }

  @override
  String get meetingsInvite => 'Taklif qilish';

  @override
  String get meetingsEmailsPlaceholder => 'Elektron pochta manzillari, vergul bilan';

  @override
  String get meetingsInviteHelp => 'Hamma taqvim tadbiri bilan xat oladi; ish maydonidan tashqaridagilar shaxsiy havola oladi.';

  @override
  String get meetingsInviteHelpNow => 'Aʼzolarga agnts\'da xabar keladi; manzillarga havola xat bilan yuboriladi.';

  @override
  String get meetingsAi => 'Eslatmalar va yozuv';

  @override
  String get meetingsAutoNotes => 'Eslatma yozish: Muse qoʻngʻiroqni tinglab, qarorlar va vazifalarni yozadi';

  @override
  String get meetingsAutoRecord => 'Qoʻngʻiroqni videoga yozish';

  @override
  String get meetingsAutoNotesOn => 'Eslatmalar yoqilgan';

  @override
  String get meetingsAutoRecordOn => 'Yozilmoqda';

  @override
  String get meetingsNotesUnavailable => 'Bu serverda eslatmalar sozlanmagan.';

  @override
  String get meetingsLanguage => 'Eslatmalar tili';

  @override
  String get meetingsLang_auto => 'Gapirilgan tilda';

  @override
  String get meetingsCancel => 'Bekor qilish';

  @override
  String get meetingsEdit => 'Oʻzgartirish';

  @override
  String get meetingsDelete => 'Oʻchirish';

  @override
  String get meetingsCancelMeeting => 'Uchrashuvni bekor qilish';

  @override
  String get meetingsCancelTitle => 'Bu uchrashuv bekor qilinsinmi?';

  @override
  String get meetingsCancelBody => 'Taklif qilinganlar bekor qilinganini taqvimida koʻradi. Davom etayotgan qoʻngʻiroq tugaydi.';

  @override
  String get meetingsCancelled => 'Bu uchrashuv bekor qilingan.';

  @override
  String get meetingsCancelledShort => 'Bekor qilingan';

  @override
  String get meetingsDeleteTitle => 'Bu uchrashuv oʻchirilsinmi?';

  @override
  String get meetingsDeleteBody => 'Uning qoʻngʻiroqlari, yozuvlari, matnlari va chati oʻchiriladi. Eslatma hujjatlari qoladi.';

  @override
  String get meetingsLink => 'Havola';

  @override
  String get meetingsRing => 'Qoʻngʻiroq qilish';

  @override
  String get meetingsRingWho => 'Hozir kimga qoʻngʻiroq qilish';

  @override
  String get meetingsRingNow => 'Qoʻngʻiroq qilish';

  @override
  String get meetingsRinging => 'Qoʻngʻiroq qilinmoqda…';

  @override
  String get meetingsAreYouComing => 'Kelasizmi?';

  @override
  String get meetingsRsvp_yes => 'Ha';

  @override
  String get meetingsRsvp_no => 'Yoʻq';

  @override
  String get meetingsRsvp_maybe => 'Balki';

  @override
  String get meetingsRsvp_none => 'Javob yoʻq';

  @override
  String meetingsInvitees(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n taklif qilingan',
      one: '$n taklif qilingan',
      zero: 'Taklif qilinganlar',
    );
    return '$_temp0';
  }

  @override
  String get meetingsInviteMore => 'Taklif qilish';

  @override
  String get meetingsNoInvitees => 'Hech kim taklif qilinmagan.';

  @override
  String get meetingsByEmail => 'pochta orqali';

  @override
  String get meetingsUninvite => 'Taklifni qaytarish';

  @override
  String get meetingsCalls => 'Qoʻngʻiroqlar';

  @override
  String get meetingsNoCalls => 'Uchrashuv hali oʻtkazilmagan.';

  @override
  String get meetingsTheMeeting => 'uchrashuv';

  @override
  String get meetingsNotesTitle => 'Eslatmalar';

  @override
  String get meetingsNoNotes => 'Bu qoʻngʻiroqda eslatma yozilmagan.';

  @override
  String get meetingsNotesBusy_recording => 'Eslatma yozilmoqda; Muse ularni qoʻngʻiroq tugagach yozadi.';

  @override
  String get meetingsNotesBusy_queued => 'Muse qoʻngʻiroqni tinglashini kutyapmiz…';

  @override
  String get meetingsNotesBusy_transcribing => 'Muse qoʻngʻiroqni tinglamoqda…';

  @override
  String get meetingsNotesBusy_writing => 'Muse eslatmalarni yozmoqda…';

  @override
  String meetingsNotesFailed(String reason) {
    return 'Eslatmalarni yozib boʻlmadi: $reason';
  }

  @override
  String get meetingsWriteAgain => 'Qayta yozish';

  @override
  String get meetingsNotesAgain => 'Muse eslatmalarni qayta yozmoqda';

  @override
  String get meetingsActionItems => 'Vazifalar';

  @override
  String get meetingsAnyRepo => 'Istalgan repozitoriy';

  @override
  String get meetingsRepository => 'Repozitoriy';

  @override
  String get meetingsCreateTicket => 'Tiket yaratish';

  @override
  String meetingsTicketMade(String key) {
    return '$key yaratildi';
  }

  @override
  String get meetingsRecordingsTitle => 'Yozuv';

  @override
  String get meetingsRecordingNow => 'Yozilmoqda…';

  @override
  String get meetingsDownload => 'Yuklab olish';

  @override
  String get meetingsDeleteRecordingTitle => 'Bu yozuv oʻchirilsinmi?';

  @override
  String get meetingsDeleteRecordingBody => 'Video hamma uchun oʻchiriladi. Matn va eslatmalar qoladi.';

  @override
  String meetingsAttendance(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n kishi', one: '$n kishi');
    return '$_temp0';
  }

  @override
  String get meetingsStillIn => 'hali qoʻngʻiroqda';

  @override
  String get meetingsGuest => 'Mehmon';

  @override
  String get meetingsMember => 'Aʼzo';

  @override
  String get meetingsTranscript => 'Matn';

  @override
  String get meetingsNoTranscript => 'Matn yoʻq.';

  @override
  String get meetingsSearchTranscript => 'Aytilganlardan qidirish';

  @override
  String get meetingsMixedNote => 'Hammaning ovozi birga tinglangan, shuning uchun matn kim gapirganini koʻrsatmaydi.';

  @override
  String meetingsChatLog(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Chat · $n xabar', one: 'Chat · $n xabar', zero: 'Chat');
    return '$_temp0';
  }

  @override
  String get meetingsShow => 'Koʻrsatish';

  @override
  String get meetingsHide => 'Yashirish';

  @override
  String get meetingsTicketTitle => 'Uchrashuvlarda muhokama qilingan';

  @override
  String get meetingsNotFound => 'Bunday uchrashuv yoʻq';

  @override
  String get meetingsSomethingWrong => 'Nimadir xato ketdi';

  @override
  String get meetingsTryAgain => 'Qayta urinish';

  @override
  String get meetingsCameraStarting => 'Kamera yoqilmoqda…';

  @override
  String get meetingsCameraOff => 'Kamera oʻchiq';

  @override
  String get meetingsMicOn => 'Mikrofon yoqiq';

  @override
  String get meetingsMicOff => 'Mikrofon oʻchiq';

  @override
  String get meetingsCamOn => 'Kamera yoqiq';

  @override
  String get meetingsCamOff => 'Kamera oʻchiq';

  @override
  String get meetingsMicLevel => 'Mikrofon darajasi';

  @override
  String get meetingsDevicesBlocked => 'Brauzer kamera va mikrofonni taqiqladi. Ularni manzil qatorida ruxsat bering va qayta urining.';

  @override
  String get meetingsDevicesFailed => 'Kamera yoki mikrofon ishga tushmadi. Uni boshqa dastur ishlatayotgan boʻlishi mumkin.';

  @override
  String get meetingsMicrophone => 'Mikrofon';

  @override
  String get meetingsCamera => 'Kamera';

  @override
  String get meetingsSpeakers => 'Karnaylar';

  @override
  String get meetingsDefaultDevice => 'Standart';

  @override
  String get meetingsLobbyRecording => 'Bu qoʻngʻiroq yozib olinmoqda.';

  @override
  String get meetingsLobbyNotes => 'agnts bu qoʻngʻiroqning eslatmalarini yozmoqda.';

  @override
  String get meetingsNotStartedYet => 'Boshlanishidan 15 daqiqa oldin kirish mumkin.';

  @override
  String get meetingsYourName => 'Ismingiz';

  @override
  String get meetingsYourNamePlaceholder => 'Boshqalar sizni qanday koʻradi';

  @override
  String meetingsJoiningAs(String name) {
    return 'Siz $name sifatida kirasiz.';
  }

  @override
  String get meetingsJoinNow => 'Kirish';

  @override
  String get meetingsAskToJoin => 'Kirishni soʻrash';

  @override
  String get meetingsJoining => 'Kirilmoqda…';

  @override
  String get meetingsOrGoogle => 'Yoki Google orqali kimligingizni koʻrsating';

  @override
  String get meetingsWaitingTitle => 'Kirishga ruxsat soʻralmoqda…';

  @override
  String get meetingsWaitingBody => 'Qoʻngʻiroqdagi kimdir tez orada sizni kiritadi.';

  @override
  String get meetingsConnecting => 'Ulanmoqda…';

  @override
  String get meetingsYouLeft => 'Siz qoʻngʻiroqdan chiqdingiz';

  @override
  String get meetingsJoinedElsewhere => 'Siz boshqa oynadan kirdingiz';

  @override
  String get meetingsRejoin => 'Qaytib kirish';

  @override
  String get meetingsBackToMeetings => 'Uchrashuvlarga';

  @override
  String get meetingsEnded => 'Qoʻngʻiroq tugadi';

  @override
  String get meetingsEndedBody => 'Eslatmalar va yozuvlar tayyor boʻlgach oʻtgan qoʻngʻiroqlarda chiqadi.';

  @override
  String get meetingsRemovedTitle => 'Siz qoʻngʻiroqdan chiqarildingiz';

  @override
  String get meetingsRemovedBody => 'Olib boruvchi sizni chiqardi. Bu qoʻngʻiroqqa qaytib boʻlmaydi.';

  @override
  String get meetingsRefused_locked => 'Uchrashuv yopilgan';

  @override
  String get meetingsRefused_full => 'Uchrashuv toʻla';

  @override
  String get meetingsRefused_removed => 'Siz bu qoʻngʻiroqdan chiqarilgansiz';

  @override
  String get meetingsRefused_guests_off => 'Bu uchrashuv faqat ish maydoni aʼzolari uchun';

  @override
  String get meetingsRefused_not_started => 'Uchrashuv hali boshlanmagan';

  @override
  String get meetingsRefused_cancelled => 'Bu uchrashuv bekor qilingan';

  @override
  String get meetingsRefused_denied => 'Sizni kiritishmadi';

  @override
  String get meetingsRefused_expired => 'Hech kim javob bermadi';

  @override
  String get meetingsRole_host => 'Olib boruvchi';

  @override
  String get meetingsRole_cohost => 'Yordamchi olib boruvchi';

  @override
  String get meetingsRole_member => 'Aʼzo';

  @override
  String get meetingsRole_guest => 'Mehmon';

  @override
  String meetingsYou(String name) {
    return '$name (siz)';
  }

  @override
  String get meetingsYouShort => 'siz';

  @override
  String meetingsScreenOf(String name) {
    return '$name ekrani';
  }

  @override
  String get meetingsPoorConnection => 'Aloqa yomon';

  @override
  String get meetingsHandRaised => 'Qoʻl koʻtarilgan';

  @override
  String get meetingsPin => 'Mahkamlash';

  @override
  String get meetingsUnpin => 'Mahkamlashni olish';

  @override
  String get meetingsRecording => 'Yozuv';

  @override
  String get meetingsTakingNotes => 'Eslatma';

  @override
  String get meetingsLocked => 'Yopiq';

  @override
  String get meetingsReconnecting => 'Qayta ulanmoqda…';

  @override
  String get meetingsEnableAudio => 'Ovozni yoqish';

  @override
  String get meetingsWantsToJoin => 'kirmoqchi';

  @override
  String meetingsAndMore(String n) {
    return 'va yana $n kishi';
  }

  @override
  String get meetingsAdmit => 'Kiritish';

  @override
  String get meetingsDeny => 'Rad etish';

  @override
  String get meetingsSeeAll => 'Hammasi';

  @override
  String meetingsAskedToUnmute(String name) {
    return '$name mikrofonni yoqishingizni soʻrayapti.';
  }

  @override
  String get meetingsUnmute => 'Mikrofonni yoqish';

  @override
  String get meetingsNotNow => 'Hozir emas';

  @override
  String get meetingsChat => 'Chat';

  @override
  String get meetingsPeople => 'Ishtirokchilar';

  @override
  String get meetingsMicToggle => 'Mikrofon (Ctrl+D)';

  @override
  String get meetingsCamToggle => 'Kamera (Ctrl+E)';

  @override
  String get meetingsShareScreen => 'Ekranni koʻrsatish';

  @override
  String get meetingsStopSharing => 'Koʻrsatishni toʻxtatish';

  @override
  String get meetingsRaiseHand => 'Qoʻl koʻtarish';

  @override
  String get meetingsLowerHand => 'Qoʻlni tushirish';

  @override
  String get meetingsReact => 'Munosabat';

  @override
  String get meetingsSpeakerView => 'Soʻzlovchi katta';

  @override
  String get meetingsGridView => 'Toʻr';

  @override
  String get meetingsHostControls => 'Boshqaruv';

  @override
  String get meetingsStartRecording => 'Yozishni boshlash';

  @override
  String get meetingsStopRecording => 'Yozishni toʻxtatish';

  @override
  String get meetingsRecordTitle => 'Bu qoʻngʻiroq yozib olinsinmi?';

  @override
  String get meetingsRecordBody => 'Qoʻngʻiroqdagilarning hammasi yozuv ketayotganini koʻradi, kiruvchilar esa oldindan ogohlantiriladi.';

  @override
  String get meetingsStartNotes => 'Eslatma yozish';

  @override
  String get meetingsStopNotes => 'Eslatmani toʻxtatish';

  @override
  String get meetingsLock => 'Uchrashuvni yopish';

  @override
  String get meetingsUnlock => 'Uchrashuvni ochish';

  @override
  String get meetingsMuteAll => 'Hammaning mikrofonini oʻchirish';

  @override
  String get meetingsQuietGuests => 'Mehmonlarga chat va ekran koʻrsatishni oʻchirish';

  @override
  String get meetingsGuestsSpeakAgain => 'Mehmonlarga chat va ekran koʻrsatishni qaytarish';

  @override
  String get meetingsOpenTitle => 'Havolasi borlarning hammasi kirsinmi?';

  @override
  String get meetingsOpenBody => 'Qoʻngʻiroq tugaguncha mehmonlar kutmasdan kiradi.';

  @override
  String get meetingsLetAnyoneIn => 'Kiritish';

  @override
  String get meetingsEndForAll => 'Qoʻngʻiroqni hamma uchun tugatish';

  @override
  String get meetingsEndTitle => 'Qoʻngʻiroq hamma uchun tugatilsinmi?';

  @override
  String get meetingsEndBody => 'Hamma uziladi. Eslatmalar yozib olingan narsadan yoziladi.';

  @override
  String get meetingsLeave => 'Chiqish';

  @override
  String meetingsWaiting(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n kishi kutmoqda', one: '$n kishi kutmoqda');
    return '$_temp0';
  }

  @override
  String get meetingsAdmitAll => 'Hammasini kiritish';

  @override
  String meetingsHands(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n koʻtarilgan qoʻl', one: '$n koʻtarilgan qoʻl');
    return '$_temp0';
  }

  @override
  String meetingsInCall(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Qoʻngʻiroqda $n', one: 'Qoʻngʻiroqda $n');
    return '$_temp0';
  }

  @override
  String meetingsDevices(String n) {
    return '$n ta qurilma';
  }

  @override
  String meetingsActionsFor(String name) {
    return '$name uchun amallar';
  }

  @override
  String get meetingsMuteMic => 'Mikrofonni oʻchirish';

  @override
  String get meetingsStopCamera => 'Kamerani oʻchirish';

  @override
  String get meetingsStopScreen => 'Ekran koʻrsatishni toʻxtatish';

  @override
  String get meetingsAskUnmute => 'Mikrofonni yoqishni soʻrash';

  @override
  String get meetingsMakeCohost => 'Yordamchi olib boruvchi qilish';

  @override
  String get meetingsUncohost => 'Yordamchilikdan olish';

  @override
  String get meetingsRemove => 'Qoʻngʻiroqdan chiqarish';

  @override
  String meetingsRemoveTitle(String name) {
    return '$name chiqarilsinmi?';
  }

  @override
  String get meetingsRemoveBody => 'U barcha qurilmalarida uziladi va bu qoʻngʻiroqqa qaytolmaydi.';

  @override
  String get meetingsChatEmpty => 'Hali xabar yoʻq. Xabarlar qoʻngʻiroq bilan saqlanadi.';

  @override
  String get meetingsChatPlaceholder => 'Hammaga xabar';

  @override
  String get meetingsChatOff => 'Olib boruvchilar mehmonlar uchun chatni oʻchirgan.';

  @override
  String get meetingsSend => 'Yuborish';

  @override
  String meetingsCallingYou(String name) {
    return '$name sizga qoʻngʻiroq qilyapti';
  }

  @override
  String get meetingsStartsSoon => 'Uchrashuv tez orada boshlanadi';

  @override
  String get meetingsHasStarted => 'Siz taklif qilingan uchrashuv boshlandi';

  @override
  String meetingsKnockAway(String name) {
    return '$name uchrashuvingizga kirmoqchi';
  }

  @override
  String get meetingsDecline => 'Rad etish';

  @override
  String get meetingsDismiss => 'Yopish';

  @override
  String get meetingsColHost => 'Tashkilotchi';

  @override
  String get meetingsFullscreen => 'Toʻliq ekran';

  @override
  String get meetingsExitFullscreen => 'Toʻliq ekrandan chiqish';

  @override
  String get meetingsColPerson => 'Ishtirokchi';

  @override
  String get meetingsColInCall => 'Qoʻngʻiroqda';

  @override
  String get meetingsColDuration => 'Vaqt';

  @override
  String get meetingsLeaveTitle => 'Qoʻngʻiroqdan chiqasizmi?';

  @override
  String get meetingsLeaveBody => 'Qoʻngʻiroq davom etayotgan paytda xuddi shu havola orqali qaytishingiz mumkin.';

  @override
  String get meetingsLeaveBodyHost =>
      'Qoʻngʻiroq sizsiz davom etadi. Uni hamma uchun tugatish uchun «Boshqaruv» menyusida «Qoʻngʻiroqni hamma uchun tugatish»ni tanlang.';

  @override
  String get meetingsStopRecordingTitle => 'Yozib olish toʻxtatilsinmi?';

  @override
  String get meetingsStopRecordingBody => 'Shu paytgacha yozilgani saqlanadi va qoʻngʻiroq sahifasida chiqadi.';

  @override
  String get meetingsStopNotesTitle => 'Qaydlar toʻxtatilsinmi?';

  @override
  String get meetingsStopNotesBody => 'Muse qaydlarni shu paytgacha eshitganlari asosida yozadi.';

  @override
  String get meetingsMuteAllTitle => 'Hammaning mikrofoni oʻchirilsinmi?';

  @override
  String get meetingsMuteAllBody => 'Sizdan boshqa hammaning mikrofoni oʻchadi. Har kim oʻzinikini qayta yoqishi mumkin.';

  @override
  String get meetingsLockTitle => 'Uchrashuv yopilsinmi?';

  @override
  String get meetingsLockBody =>
      'Siz ochmaguningizcha yangi odamlar kira olmaydi va taqillata olmaydi. Avval kiritilganlar va tashkilotchilar qaytishi mumkin.';

  @override
  String meetingsAdmitAllTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n kishi kiritilsinmi?');
    return '$_temp0';
  }

  @override
  String get meetingsAdmitAllBody => 'Kutayotganlarning hammasi hoziroq qoʻngʻiroqqa kiradi.';

  @override
  String meetingsCohostTitle(String name) {
    return '$name hamtashkilotchi qilinsinmi?';
  }

  @override
  String get meetingsCohostBody =>
      'Hamtashkilotchilar odamlarni kiritishi, mikrofonini oʻchirishi va chiqarishi, qoʻngʻiroqni yozib olishi va qayd yuritishi mumkin.';

  @override
  String get meetingsWriteAgainTitle => 'Qaydlar qayta yozilsinmi?';

  @override
  String get meetingsWriteAgainBody =>
      'Muse ularni qoʻngʻiroq asosida qayta yozadi va hozirgi qaydlarni ulardagi oʻzgarishlar bilan birga almashtiradi.';

  @override
  String meetingsUninviteTitle(String name) {
    return '$name taklif qilinganlardan olib tashlansinmi?';
  }

  @override
  String get meetingsUninviteBody => 'U endi taklif qilinmagan va eslatmalar olmaydi.';

  @override
  String get mgroupsGroups => 'Guruhlar';

  @override
  String get mgroupsRepos => 'Repozitoriylar';

  @override
  String get mgroupsPickHint => 'Bir yoki bir nechtasini tanlang. Birinchisi asosiy boʻladi.';

  @override
  String get mgroupsInTask => 'Bu vazifada';

  @override
  String mgroupsFromGroup(String name) {
    return '$name guruhi toʻliq';
  }

  @override
  String mgroupsFromGroupEdited(String name) {
    return '$name guruhidan, oʻzgartirilgan';
  }

  @override
  String get mgroupsPrimary => 'asosiy';

  @override
  String mgroupsRemove(String name) {
    return '$name ni olib tashlash';
  }

  @override
  String get mgroupsNoMembers => 'Bu guruhda faol repozitoriylar yoʻq.';

  @override
  String mgroupsGroup(String name) {
    return '$name guruhi';
  }

  @override
  String get mgroupsPartlyMerged => 'Qisman birlashtirildi';

  @override
  String get mgroupsArchived => 'arxivda';

  @override
  String mgroupsPushError(String error) {
    return 'Yuborib boʻlmadi: $error';
  }

  @override
  String mgroupsFiles(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n fayl', one: '$n fayl');
    return '$_temp0';
  }

  @override
  String mgroupsCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n CI tuzatish', one: '$n CI tuzatish');
    return '$_temp0';
  }

  @override
  String get mgroupsStatePending => 'Kutilmoqda';

  @override
  String get mgroupsStateUnchanged => 'Oʻzgarishsiz';

  @override
  String get mgroupsStatePushed => 'Yuborildi';

  @override
  String get mgroupsStateMerged => 'Birlashtirildi';

  @override
  String get mgroupsStateDropped => 'Yopildi';

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
  String minsightsSaved(String name) {
    return '$name saqlandi';
  }

  @override
  String get minsightsEditTask => 'Vazifani tahrirlash';

  @override
  String get minsightsEditTaskSub => 'Faqat hali boshlanmagan vazifani o‘zgartirish mumkin.';

  @override
  String get minsightsSave => 'Saqlash';

  @override
  String get minsightsTaskSaved => 'Vazifa saqlandi';

  @override
  String minsightsTaskDeleted(String key) {
    return '$key vazifasi o‘chirildi';
  }

  @override
  String get minsightsTaskActions => 'Vazifa amallari';

  @override
  String get mmanageFillAll => 'Majburiy maydonlarni toʻldiring.';

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
  String get mobilePushProgress => 'Agent bosqichni tugatganda';

  @override
  String get mobilePushProgressHelp => 'Tahlil tayyor, kod yozildi. Faqat telefonga, ovozsiz, har bir tiket uchun bitta bildirishnoma';

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
  String get mobileAdminAppOnly => 'Bu Admin hisobi. Uni agnts admin ilovasida oching.';

  @override
  String get mobileGoogleContinue => 'Google orqali davom etish';

  @override
  String get mobileGoogleOff => 'Bu serverda Google orqali kirish oʻchirilgan.';

  @override
  String get mobileGoogleSetup => 'Ilovaning bu yigʻmasida Google orqali kirish sozlanmagan.';

  @override
  String get modulesName_muse => 'Muse Code';

  @override
  String get modulesName_claude => 'Claude Code';

  @override
  String get modulesName_codex => 'Codex';

  @override
  String get modulesTitle => 'Modullar';

  @override
  String get modulesSub => 'Odamlar qaysi kod modullaridan foydalana oladi. Odam ro‘yxatidagi birinchisi uning asosiy moduli.';

  @override
  String get modulesAvailable => 'Bu serverda mavjud';

  @override
  String get modulesAvailableHelp => 'Bu server nimalarni ishga tushira oladi (AGNTS_PROVIDERS). Buni bu yerda o‘zgartirib bo‘lmaydi.';

  @override
  String get modulesEnabled => 'Yoqilgan';

  @override
  String get modulesEnabledHelp => 'Odamlarga nima berish mumkin. O‘chirilgan modul hammadan olinadi.';

  @override
  String get modulesDefaultList => 'Odamlar uchun standart';

  @override
  String get modulesDefaultListHelp =>
      'Agar «Foydalanuvchilar» sahifasida odamga alohida ro‘yxat belgilamagan bo‘lsangiz, u shuni oladi. Birinchisi asosiy modul.';

  @override
  String get modulesDefault => 'Asosiy';

  @override
  String modulesMoveUp(String module) {
    return '${module}ni yuqoriga surish';
  }

  @override
  String modulesMoveDown(String module) {
    return '${module}ni pastga surish';
  }

  @override
  String get modulesProblem_noneEnabled => 'Kamida bitta modulni yoqing.';

  @override
  String get modulesProblem_empty => 'Kamida bitta modulni tanlang.';

  @override
  String get modulesProblem_codexFirst => 'Codex asosiy modul bo‘la olmaydi: birinchi o‘ringa Muse Code yoki Claude Code qo‘ying.';

  @override
  String get modulesSave => 'Saqlash';

  @override
  String get modulesSaved => 'Modullar saqlandi';

  @override
  String get modulesMineTitle => 'Kod modullaringiz';

  @override
  String get modulesMineSub =>
      'Administrator sizga ruxsat bergan modullar. Ularni o‘z tartibingizga qo‘ying: birinchisi standart modulingiz, sozlamalarda sizga mavjud bo‘lmagan modul ko‘rsatilganda shu ishlatiladi.';

  @override
  String get modulesMineSaved => 'Modullar tartibi saqlandi';

  @override
  String get modulesMineReset => 'Administrator tartibi';

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
  String get mpullsPlaceholder => 'Markdown';

  @override
  String get mpullsLineHint => 'Izoh qoldirish uchun qatorni bosing.';

  @override
  String mpullsCopyLink(String host) {
    return '$host da ochish';
  }

  @override
  String get mqualityNewTest => 'Yangi Swagger testi';

  @override
  String get mqualityStarterFor => 'Boshlangʻich qoidalar:';

  @override
  String get mqualityStarterPick => 'Tillari uchun boshlangʻich toʻplamlarni koʻrish uchun repozitoriyni tanlang.';

  @override
  String get mqualitySearchRules => 'Qoidalarni qidirish';

  @override
  String mqualityRequestTitle(String id) {
    return 'Soʻrov $id';
  }

  @override
  String mqualitySpecFile(String name) {
    return 'Spetsifikatsiya fayli: $name';
  }

  @override
  String get mqualityDeployHook => 'Deploy hook';

  @override
  String get mqualityTokenSaved => 'Token saqlandi';

  @override
  String get mqualitySuiteDeleted => 'Toʻplam oʻchirildi';

  @override
  String mqualityHourAt(String hour) {
    return '$hour:00 UTC';
  }

  @override
  String get mqualityReviewTickets => 'Pull requestlar';

  @override
  String get mqualityAddReviewer => 'Reviewer qoʻshish';

  @override
  String get mqualityEndpointsTicked => 'Endpointlar';

  @override
  String get mqualityShowCases => 'Holatlarni koʻrsatish';

  @override
  String get mqualityHideCases => 'Holatlarni yashirish';

  @override
  String mrepodetailCopyLink(String host) {
    return '$host da ochish';
  }

  @override
  String get mrepodetailOnePerLine => 'Har qatorda bittadan.';

  @override
  String mrepodetailLinesCapped(String n) {
    return 'Bu yerda faqat birinchi $n qator koʻrsatilgan.';
  }

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
  String get mwsNone =>
      'Siz hali hech qaysi ish maydoniga a\'zo emassiz. Veb-admin panelda yangisini yarating yoki taklifni qabul qiling, so\'ng yangilash uchun pastga torting.';

  @override
  String mwsSwitched(String name) {
    return '$name ochildi';
  }

  @override
  String mwsMembers(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n a\'zo', one: '$n a\'zo');
    return '$_temp0';
  }

  @override
  String get mwsSuspended => 'To\'xtatilgan';

  @override
  String get navOverview => 'Umumiy';

  @override
  String get navWorkflow => 'Ish jarayoni';

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
  String get navSearch => 'Sahifa, repozitoriy, tiket, suhbat va darslarni qidirish';

  @override
  String get navSearchPages => 'Sahifalar';

  @override
  String get navSearchNone => 'Hech narsa topilmadi';

  @override
  String get navSearchResults => 'Qidiruv natijalari';

  @override
  String get navSyncJira => 'Jira bilan sinxronlash';

  @override
  String navSynced(String found, String created, String updated, String waiting) {
    return 'Jira sinxronlandi: $found ta ochiq, $created ta yangi, $updated ta yangilandi, $waiting tasi qaroringizni kutmoqda';
  }

  @override
  String get navSession => 'Joriy sessiya';

  @override
  String get navWeek => 'Shu hafta';

  @override
  String navCreditsLeft(String amount, String total) {
    return '$total dan $amount kredit qoldi';
  }

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
  String get navWorkspace => 'Ish maydoni';

  @override
  String get navProfile => 'Profil';

  @override
  String get navPlatform => 'Administrator kabineti';

  @override
  String get navPeople => 'Odamlar';

  @override
  String get navAccount => 'Hisob';

  @override
  String get navReviews => 'PR tekshiruvlari';

  @override
  String get navCi => 'CI';

  @override
  String get navAiAssistant => 'AI yordamchi';

  @override
  String get navAssistantChat => 'Chat';

  @override
  String get navAssistantCode => 'Kod';

  @override
  String get navAssistantConversations => 'Suhbatlar';

  @override
  String get navDocuments => 'Hujjatlar';

  @override
  String get navMeetings => 'Uchrashuvlar';

  @override
  String get networkTitle => 'Xususiy tarmoqlar';

  @override
  String get networkSub =>
      'Tarmoqlaringiz ichidagi GitLab, Jira yoki paketlar reyestriga ulanish. Ulanish marshruti unga eng aniq mos keladigan tarmoq orqali oʻtadi.';

  @override
  String get networkUnavailable =>
      'Bu serverda xususiy tarmoqlar sozlanmagan: administrator gateway xizmatini ishga tushiradi va AGNTS_GATEWAY ni belgilaydi.';

  @override
  String get networkStatus_up => 'Ulangan';

  @override
  String get networkStatus_connecting => 'Ulanmoqda';

  @override
  String get networkStatus_error => 'Xato';

  @override
  String get networkStatus_gateway_down => 'Shlyuz ishlamayapti';

  @override
  String get networkStatus_disabled => 'Oʻchirilgan';

  @override
  String get networkHandshake => 'Oxirgi handshake';

  @override
  String get networkHeartbeat => 'Oxirgi signal';

  @override
  String get networkWebhooksRelay => 'agnts-link uzatadi';

  @override
  String networkWebhooksPolling(String n) {
    return 'Vebhuklar yoʻq: u orqali ulanadigan trekerlar har $n daqiqada oʻqiladi';
  }

  @override
  String get networkKind => 'Ulanish';

  @override
  String get networkKindConnector => 'agnts-link (tavsiya etiladi)';

  @override
  String get networkKindHelp_connector =>
      'Tarmogʻingiz ichida ishga tushiriladigan kichik agent. U agnts ga oʻzi ulanadi: VPN maʼlumotlari ham, kiruvchi firewall qoidasi ham kerak emas, vebhuklarni ham uzatadi.';

  @override
  String get networkKindHelp_wireguard => 'agnts WireGuard peeringizga mijoz sifatida ulanadi. Peer bu serverdan UDP qabul qilishi kerak.';

  @override
  String get networkKindHelp_openvpn =>
      'agnts OpenVPN mijoz konfigingizni alohida konteynerda ishga tushiradi. Sertifikatlar konfig ichida boʻlishi kerak; MFA talab qiladigan kirish qoʻllab-quvvatlanmaydi.';

  @override
  String get networkEnabled => 'Yoqilgan';

  @override
  String get networkConfigWg => 'WireGuard konfigi';

  @override
  String get networkConfigOvpn => 'OpenVPN konfigi (.ovpn)';

  @override
  String networkSavedConfig(String summary) {
    return 'Saqlangan: $summary. Oʻzgartirmaslik uchun boʻsh qoldiring.';
  }

  @override
  String get networkConfigWgHelp =>
      'wg-quick ga beradigan faylingiz. Xostlarga nom orqali ulanish uchun DNS qatorini qoʻshing. Kalitlar shifrlanadi va qayta koʻrsatilmaydi.';

  @override
  String get networkConfigOvpnHelp =>
      'ca, cert va key bloklari ichida joylashgan mijoz konfigi. Skriptlar (up, down, plugin…) qabul qilinmaydi.';

  @override
  String get networkUsername => 'Foydalanuvchi nomi';

  @override
  String get networkPassword => 'Parol';

  @override
  String get networkPasswordKeep => 'Saqlangan: boʻsh qoldiring';

  @override
  String get networkRoutes => 'Marshrutlar';

  @override
  String get networkRoutesHelp =>
      'Shu tarmoq orqali oʻtadigan hostlar (gitlab.corp.local), domenlar (.corp.local) yoki xususiy diapazonlar (10.20.0.0/16) va portlar (boʻsh boʻlsa 80 va 443). Boshqa tarmoqda ularning ichida torroq marshrut boʻlishi mumkin (10.0.0.0/8 ichida 10.30.0.0/16): aniqrogʻi ustun keladi. Ikki tarmoq bir xil marshrutni koʻrsata olmaydi.';

  @override
  String get networkRouteTarget => 'Xost, domen yoki diapazon';

  @override
  String get networkRoutePorts => 'Portlar';

  @override
  String get networkRemoveRoute => 'Marshrutni oʻchirish';

  @override
  String get networkAddRoute => 'Marshrut qoʻshish';

  @override
  String get networkBlastRadius =>
      'agnts vazifalaringiz uchun ishga tushiradigan kod shu roʻyxatdagi barcha xostlarga ulana oladi. Butun diapazonlar oʻrniga aniq xostlarni koʻrsating.';

  @override
  String get networkCa => 'Kompaniya CA sertifikatlari';

  @override
  String networkCaSaved(String subjects, String date) {
    return 'Ishonchli: $subjects ($date gacha).';
  }

  @override
  String get networkCaRemove => 'Oʻchirish';

  @override
  String get networkCaHelp =>
      'Ichki CA ingizning PEM sertifikatlari. agnts va uning ishga tushirishlari ularga ochiq ildiz sertifikatlari bilan birga ishonadi.';

  @override
  String networkSaved(String name) {
    return '$name saqlandi';
  }

  @override
  String get networkRemove => 'Oʻchirish';

  @override
  String get networkRemoved => 'Xususiy tarmoq oʻchirildi';

  @override
  String networkRemoveConfirm(String name) {
    return '$name oʻchirilsinmi? agnts uning marshrutlaridagi hostlarga ulanmay qoʻyadi.';
  }

  @override
  String get networkLinkTitle => 'agnts-link ni ishga tushiring';

  @override
  String get networkLinkHelp =>
      'Buni tarmoq ichidagi yuqoridagi hostlarni koʻra oladigan mashinada ishga tushiring. AGNTS_LINK_ALLOW — sizning chegarangiz: agnts-link boshqa hech narsaga ulanmaydi. Har bir tarmoqning oʻz tokeni bor, shuning uchun bitta mashina bir nechta linkni ishga tushira oladi.';

  @override
  String get networkToken => 'Token';

  @override
  String get networkTokenOnce => 'Hozir nusxa oling: u faqat bir marta koʻrsatiladi.';

  @override
  String get networkLinkHooks =>
      'Vebhuklar: GitLab va Jira da http://AGNTS-LINK-XOSTI:8080 manzilini Integratsiyalar sahifasidagi /webhooks/… yoʻli bilan koʻrsating.';

  @override
  String get networkRotate => 'Tokenni almashtirish';

  @override
  String get networkRotateConfirm =>
      'Yangi token yaratilsinmi? Ishlab turgan agnts-link yangisi bilan qayta ishga tushirilmaguncha uziladi.';

  @override
  String get networkTest => 'Ulanishni tekshirish';

  @override
  String get networkTestRun => 'Tekshirish';

  @override
  String get networkTesting => 'Tekshirilmoqda…';

  @override
  String networkTestOk(String name, String via, String ip, String ms) {
    return '$name ($via) orqali $ip ga $ms ms da ulandi.';
  }

  @override
  String networkTlsOk(String subject, String issuer) {
    return 'Sertifikat joyida: $subject, beruvchi $issuer.';
  }

  @override
  String networkTlsBad(String error) {
    return 'Sertifikatga ishonch yoʻq: $error';
  }

  @override
  String get networkActivity => 'Faollik';

  @override
  String networkActivityCounts(String n, String refused) {
    return '$n ta ulanish, $refused tasi rad etilgan yoki xato';
  }

  @override
  String get networkActivityShow => 'Ulanishlarni koʻrsatish';

  @override
  String get networkActivityHide => 'Ulanishlarni yashirish';

  @override
  String get networkRefused => 'rad etildi';

  @override
  String networkSecondsAgo(String n) {
    return '$n s oldin';
  }

  @override
  String networkMinutesAgo(String n) {
    return '$n daqiqa oldin';
  }

  @override
  String networkHoursAgo(String n) {
    return '$n soat oldin';
  }

  @override
  String get networkReconnect => 'Qayta ulash';

  @override
  String get networkReconnectHelp =>
      'Tunnelni qayta ishga tushirish: yangi OpenVPN mijozi, yangi WireGuard handshake yoki agnts-link qayta ulanadi';

  @override
  String get networkReconnecting => 'Qayta ulanmoqda: tunnel 15 soniya ichida qayta ishga tushadi';

  @override
  String get networkAdd => 'Tarmoq qoʻshish';

  @override
  String get networkAddTitle => 'Yangi xususiy tarmoq';

  @override
  String get networkAddSubmit => 'Tarmoq qoʻshish';

  @override
  String get networkEditorSub => 'Tarmoqlaringizdan biriga tunnel va u orqali oʻtadigan hostlar';

  @override
  String get networkEdit => 'Tahrirlash';

  @override
  String get networkDone => 'Tayyor';

  @override
  String get networkName => 'Nomi';

  @override
  String get networkNamePlaceholder => 'Mijoz A, Ofis, Data-markaz';

  @override
  String get networkNameHelp => 'Ish maydonida yagona: tarmoq olib boradigan kompaniya, ofis yoki data-markaz.';

  @override
  String get networkEmpty => 'Hozircha xususiy tarmoq yoʻq. Faqat tarmoq ichida mavjud hostlarga ulanish uchun tarmoq qoʻshing.';

  @override
  String networkLimit(String n) {
    return 'Ish maydonida koʻpi bilan $n ta xususiy tarmoq boʻladi';
  }

  @override
  String networkCaShort(String subjects) {
    return '$subjects ga ishonadi';
  }

  @override
  String get networkTestHelp =>
      'host:port kiriting. agnts marshrutlar olib boradigan tarmoqni tanlaydi, ulanadi va sertifikatni tekshiradi.';

  @override
  String get networkTestThrough => 'Orqali';

  @override
  String get networkTestAuto => 'Marshrutlar tanlagan tarmoq';

  @override
  String get networkActivityAll => 'Barcha tarmoqlar';

  @override
  String get networkActivityNetwork => 'Tarmoq';

  @override
  String get networkActivityTime => 'Vaqt';

  @override
  String get networkActivityTarget => 'Manzil';

  @override
  String get networkActivitySource => 'Tiket yoki manba';

  @override
  String get networkGone => 'oʻchirilgan';

  @override
  String get networkDisconnect => 'Uzish';

  @override
  String get networkDisconnectHelp =>
      'Tunnelni to\'xtatish. Qayta ulamaguningizcha ishga tushirishlar u orqali hech narsaga yetmaydi; sozlama saqlanadi';

  @override
  String networkDisconnectConfirm(String name) {
    return '$name uzilsinmi? U orqali ishlaydigan ishga tushirishlar va trekerlar qayta ulamaguningizcha ishlamaydi. Sozlamasi saqlanadi.';
  }

  @override
  String get networkDisconnected => 'Uzildi';

  @override
  String get networkConnect => 'Ulash';

  @override
  String get networkConnectHelp => 'Tunnelni saqlangan sozlama bilan qayta ishga tushirish';

  @override
  String get networkConnecting => 'Ulanmoqda: tunnel 15 soniya ichida ishga tushadi';

  @override
  String get networkManage => 'Boshqarish';

  @override
  String get platformTitle => 'Administrator kabineti';

  @override
  String get platformLede =>
      'Serverdagi barcha ish maydonlari, ishlar va foydalanuvchilar. Ish maydonlarining faqat metama’lumotlari ko‘rinadi: tiketlari a’zolarigagina tegishli.';

  @override
  String get platformCapacity => 'Server';

  @override
  String get platformReserved => 'Band qilingan xotira';

  @override
  String get platformBudgetNone => 'cheklanmagan';

  @override
  String get platformRuns => 'Ishlar';

  @override
  String get platformDisk => 'Diskda bo‘sh joy';

  @override
  String get platformFull => 'To‘lgan: ishlar serverni kutmoqda';

  @override
  String get platformRunning => 'Hozir bajarilmoqda';

  @override
  String get platformNoRuns => 'Hech narsa bajarilmayapti.';

  @override
  String get platformQueue => 'Server navbati';

  @override
  String get platformNoQueue => 'Serverni kutayotgan ish yo‘q.';

  @override
  String get platformWorkspace => 'Ish maydoni';

  @override
  String get platformTicket => 'Tiket';

  @override
  String get platformStage => 'Bosqich';

  @override
  String get platformStarted => 'Boshlangan';

  @override
  String get platformWorkspaces => 'Ish maydonlari';

  @override
  String get platformOwner => 'Egasi';

  @override
  String get platformPlan => 'Tarif';

  @override
  String get platformSlots => 'Slotlar';

  @override
  String get platformMembers => 'A’zolar';

  @override
  String get platformMemberLimit => 'A’zolar limiti';

  @override
  String get platformCredits => 'Kreditlar';

  @override
  String get platformState => 'Holat';

  @override
  String get platformActive => 'Faol';

  @override
  String get platformSuspended => 'To‘xtatilgan';

  @override
  String get platformDeleted => 'O‘chirilgan';

  @override
  String get platformEdit => 'Tahrirlash';

  @override
  String get platformSuspend => 'To‘xtatish';

  @override
  String get platformResume => 'Qayta yoqish';

  @override
  String get platformGrant => 'Kredit berish';

  @override
  String get platformGrantAmount => 'Kreditlar (manfiy son — qaytarib olish)';

  @override
  String get platformGrantNote => 'Izoh';

  @override
  String platformGrantDone(String n, String name) {
    return '$name ga $n kredit berildi';
  }

  @override
  String get platformSaved => 'Saqlandi';

  @override
  String get platformUsers => 'Foydalanuvchilar';

  @override
  String get platformUser => 'Foydalanuvchi';

  @override
  String get platformEmail => 'Pochta';

  @override
  String get platformAdmin => 'Admin';

  @override
  String get platformMakeAdmin => 'Admin qilish';

  @override
  String get platformRemoveAdmin => 'Admin rolini olib tashlash';

  @override
  String get platformJoined => 'Ro‘yxatdan o‘tgan';

  @override
  String get platformNoLimit => 'cheklovsiz';

  @override
  String get platformForbidden => 'Operator konsoli faqat administratorlar uchun.';

  @override
  String get platformCabinetBadge => 'Administrator kabineti';

  @override
  String get platformNavDashboard => 'Umumiy ko‘rinish';

  @override
  String get platformAdmins => 'Administratorlar';

  @override
  String get platformNavMine => 'Mening ishim';

  @override
  String get platformBackToWorkspace => 'Ish maydonimga qaytish';

  @override
  String get platformDashLede => 'Platformadagi barcha foydalanuvchilar, o‘sish sur’ati va server hozir nimani bajaryapti.';

  @override
  String platformNewThisWeek(String n) {
    return 'shu hafta $n ta yangi';
  }

  @override
  String platformViaGoogle(String n) {
    return '$n ta Google orqali';
  }

  @override
  String get platformActiveUsers => 'Shu hafta faol';

  @override
  String get platformActiveNote => 'So‘nggi 7 kunda kirganlar';

  @override
  String platformTeams(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n tasi jamoa bilan', one: '$n tasi jamoa bilan');
    return '$_temp0';
  }

  @override
  String platformRunsNow(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'hozir $n ta ishga tushirish', one: 'hozir $n ta ishga tushirish');
    return '$_temp0';
  }

  @override
  String get platformGrowthTitle => 'Ro‘yxatdan o‘tishlar';

  @override
  String platformGrowthSub(String n) {
    return 'So‘nggi $n kunda kunlik yangi akkauntlar va ish maydonlari';
  }

  @override
  String get platformLegendUsers => 'Akkauntlar';

  @override
  String get platformLegendWorkspaces => 'Ish maydonlari';

  @override
  String get platformRecentTitle => 'Eng yangi akkauntlar';

  @override
  String get platformSeeAll => 'Hammasi';

  @override
  String get platformNoUsers => 'Foydalanuvchi topilmadi.';

  @override
  String get platformWsLede =>
      'Barcha ish maydonlari va ulardagi a’zolar. Faqat metama’lumotlar ko‘rinadi: vazifalar va kod ish maydoni a’zolariga tegishli.';

  @override
  String get platformF_all => 'Hammasi';

  @override
  String get platformF_active => 'Faol';

  @override
  String get platformF_suspended => 'To‘xtatilgan';

  @override
  String get platformF_deleted => 'O‘chirilgan';

  @override
  String get platformSearchWs => 'Ish maydoni yoki egasini qidirish';

  @override
  String get platformNoWorkspaces => 'Ish maydoni topilmadi.';

  @override
  String get platformCreated => 'Yaratilgan';

  @override
  String get platformNoMembers => 'A’zolar yo‘q.';

  @override
  String platformSuspendTitle(String name) {
    return '$name to‘xtatilsinmi?';
  }

  @override
  String get platformSuspendBody =>
      'Yangi ishga tushirishlar boshlanmaydi va a’zolar ish maydoni to‘xtatilganini ko‘radi. Istalgan vaqtda qayta yoqish mumkin.';

  @override
  String get platformUsersLede =>
      'Google orqali ro\'yxatdan o\'tganlarning barchasi: ish maydonlari va oxirgi kirishi. Administrator akkauntlari «Administratorlar» sahifasida.';

  @override
  String get platformU_all => 'Hammasi';

  @override
  String get platformU_active => 'Faol';

  @override
  String get platformU_new => 'Shu hafta yangi';

  @override
  String get platformU_google => 'Google';

  @override
  String get platformU_admins => 'Administratorlar';

  @override
  String get platformSearchUsers => 'Ism, email yoki ish maydoni bo‘yicha qidirish';

  @override
  String get platformSignIn => 'Kirish';

  @override
  String get platformLastSeen => 'Oxirgi kirish';

  @override
  String get platformPassword => 'Parol';

  @override
  String get platformUnverified => 'tasdiqlanmagan';

  @override
  String get platformYou => 'Siz';

  @override
  String platformMakeAdminTitle(String name) {
    return '$name administrator qilinsinmi?';
  }

  @override
  String get platformMakeAdminBody =>
      'Administratorlar bu kabinetni ochadi: barcha foydalanuvchi va ish maydonlarini ko‘radi, tarif va kreditlarni o‘zgartiradi, ish maydonlarini to‘xtatadi va boshqa administratorlarni boshqaradi.';

  @override
  String platformRemoveAdminTitle(String name) {
    return '$name administratorlikdan olinsinmi?';
  }

  @override
  String get platformRemoveAdminBody => 'Akkaunt va ish maydonlari qoladi, lekin administrator kabinetiga kira olmaydi.';

  @override
  String platformAdminAdded(String name) {
    return 'Administrator $name yaratildi';
  }

  @override
  String platformAdminRemoved(String name) {
    return 'Administrator $name o\'chirildi';
  }

  @override
  String get platformAdminsLede =>
      'Platforma operatorlari. Har biri foydalanuvchilardan alohida akkaunt: administrator ish maydonlarining vazifalarini ko\'rmaydi.';

  @override
  String platformAdminsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n administrator', one: '$n administrator');
    return '$_temp0';
  }

  @override
  String get platformAddAdmin => 'Administrator qo‘shish';

  @override
  String get platformAddAdminSub =>
      'Administrator alohida akkaunt: parol bilan kiradi, shu kabinetni ochadi va ish maydonlarida bo\'lmaydi. Foydalanuvchini administrator qilib bo\'lmaydi.';

  @override
  String get platformFindUser => 'Odamni topish';

  @override
  String get platformNoMatch => 'Hech kim topilmadi yoki u allaqachon administrator.';

  @override
  String platformLastSeenAgo(String when) {
    return 'oxirgi kirish $when';
  }

  @override
  String get platformAdminName => 'Ism';

  @override
  String get platformAdminUsername => 'Login';

  @override
  String platformAdminPasswordHint(String n) {
    return 'Kamida $n ta belgi. Ikki bosqichli kirishni profilda yoqish mumkin.';
  }

  @override
  String get platformCreateAdmin => 'Administrator yaratish';

  @override
  String get platformDeleteAdmin => 'O\'chirish';

  @override
  String platformDeleteAdminTitle(String name) {
    return '$name administrator akkaunti o\'chirilsinmi?';
  }

  @override
  String get platformDeleteAdminBody => 'U endi kira olmaydi. Buni qaytarib bo\'lmaydi.';

  @override
  String get platformFreeCredits => 'Bepul kreditlar';

  @override
  String get platformSetFreeCredits => 'Bepul kreditlarni belgilash';

  @override
  String platformFreeCreditsSet(String name, String n, String amount) {
    return '$name $n bepul kredit ($amount) sarflashi mumkin';
  }

  @override
  String platformFreeCreditsUsed(String used, String limit) {
    return 'Hozircha $limit dan $used sarflangan.';
  }

  @override
  String get platformFreeCreditsLimit => 'Kreditlar (1 kredit = \$0.01; 0 — kreditsiz)';

  @override
  String platformFreeCreditsWorth(String amount) {
    return 'Bu agnts’ning Muse kaliti orqali $amount lik model chaqiruvlari.';
  }

  @override
  String get platformFreeCreditsInvalid => '0 dan 10 000 000 gacha butun son kiriting.';

  @override
  String get platformCreditUsage => 'Shu oydagi sarf';

  @override
  String platformCreditUsageTotal(String n) {
    return 'jami $n';
  }

  @override
  String get platformSetLimit => 'Limit belgilash';

  @override
  String get platformLimitTitle => 'Oylik kredit limiti';

  @override
  String platformLimitSet(String name, String n, String amount) {
    return '$name oyiga $n kreditgacha ($amount) sarflashi mumkin';
  }

  @override
  String platformLimitRemoved(String name) {
    return '$name uchun oylik limit olib tashlandi';
  }

  @override
  String platformLimitUsed(String used, String amount, String total) {
    return 'Shu oy $used kredit ($amount) sarflangan, jami $total.';
  }

  @override
  String get platformLimitField => 'Oyiga kreditlar (1 kredit = \$0.01; 0 — limitsiz)';

  @override
  String get platformLimitHelp =>
      'Bepul va ish maydoni kreditlari birgalikda. Limit tugagach, ishga tushirishlar keyingi oygacha yoki siz uni oshirguningizcha to\'xtaydi.';

  @override
  String platformLimitWorth(String amount) {
    return 'Oyiga $amount gacha model chaqiruvlari.';
  }

  @override
  String get platformLimitNone => 'Limitsiz: sarfni faqat ularning kreditlari cheklaydi.';

  @override
  String platformUsageTotals(String used, String amount, String limited) {
    return 'Shu oy: hammada $used kredit ($amount); $limited kishida limit bor.';
  }

  @override
  String get platformModules => 'Modullar';

  @override
  String get platformSetModules => 'Modullarni belgilash';

  @override
  String platformModulesDefault(String list) {
    return 'Standart ($list)';
  }

  @override
  String platformModulesNow(String list) {
    return 'Hozir foydalanadi: $list.';
  }

  @override
  String get platformModulesFollowDefault => 'Standart bo‘yicha';

  @override
  String get platformModulesCustom => 'Alohida ro‘yxat';

  @override
  String get platformModulesCustomHelp => 'Birinchisi asosiy modul. Faqat yoqilgan modullarni tanlash mumkin.';

  @override
  String platformModulesSet(String name, String list) {
    return '$name foydalana oladi: $list';
  }

  @override
  String platformModulesFollow(String name) {
    return '$name endi standart modullardan foydalanadi';
  }

  @override
  String platformModulesNotEnabled(String list) {
    return 'Hali yoqilmagan, shuning uchun bu yerda yo‘q: $list. Bu server ularni ishga tushira oladi.';
  }

  @override
  String get platformModulesOpenSettings => 'Modullar sozlamalarini ochish';

  @override
  String platformModulesServerOnly(String list) {
    return 'Bu server faqat $list ni ishga tushira oladi. Ko‘proq taklif qilish uchun modul serverdagi AGNTS_PROVIDERS ga (va ishga tushirish obraziga) qo‘shilishi kerak.';
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
      'Muse tugatishdan oldin ilovani ishga tushirib, oʻzgartirgan sahifalarini koʻrishi va buzilgan joylarni tuzatishi mumkin. Bir necha qoʻshimcha qadamga tushadi.';

  @override
  String get previewModel_ => 'Oldindan koʻrish modeli';

  @override
  String get previewModelHelp => 'Sahifalarni tanlaydi va skrinshotlarni baholaydi.';

  @override
  String get previewEgress => 'Ruxsat etilgan hostlar';

  @override
  String get previewEgressHelp =>
      'Ichki roʻyxatdan (Muse, git xostinglar, paket reyestrlari) tashqari ishga tushirish konteynerlari murojaat qila oladigan hostlar, masalan oldindan koʻrishda ilova murojaat qiladigan staging API. .example.com uning subdomenlariga ruxsat beradi.';

  @override
  String get previewNotify => 'Oldindan koʻrish skrinshotlari tayyor boʻlganda';

  @override
  String get previewNotifyPhotos => 'Telefon skrinshotlarini Telegramga yuborish';

  @override
  String get previewNotifyPhotosHelp => 'Telegram xabariga toʻrttagacha skrinshot qoʻshiladi.';

  @override
  String get pullsTab => 'Pull requestlar';

  @override
  String get pullsTitle => 'Pull requestlar';

  @override
  String get pullsSub => 'Git xostingda, oxirgi yangilanganlari birinchi. Izohlarni o\'qish va javob berish uchun oching.';

  @override
  String get pullsBack => 'Repozitoriyga qaytish';

  @override
  String get pullsState_open => 'Ochiq';

  @override
  String get pullsState_merged => 'Birlashtirilgan';

  @override
  String get pullsState_closed => 'Yopilgan';

  @override
  String get pullsState_all => 'Hammasi';

  @override
  String get pullsNone => 'Bu yerda pull request yo\'q.';

  @override
  String get pullsEnd => 'Hammasi shu.';

  @override
  String pullsUpdated(String time) {
    return '$time yangilangan';
  }

  @override
  String get pullsDraft => 'Qoralama';

  @override
  String pullsOwnTicket(String key) {
    return 'agnts o\'zgarishi · $key';
  }

  @override
  String pullsReviewTicket(String key) {
    return 'Ko\'rib chiqish · $key';
  }

  @override
  String get pullsConversation => 'Muhokama';

  @override
  String get pullsFiles => 'Fayllar';

  @override
  String pullsUnresolvedN(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ta hal qilinmagan muhokama',
      one: '$n ta hal qilinmagan muhokama',
    );
    return '$_temp0';
  }

  @override
  String pullsShowResolved(String n) {
    return 'Hal qilinganlarni ko\'rsatish ($n)';
  }

  @override
  String get pullsNoComments => 'Hozircha izoh yo\'q.';

  @override
  String get pullsNoFiles => 'Pull request hech qanday faylni o\'zgartirmaydi.';

  @override
  String get pullsNoPatch => 'Ko\'rsatadigan diff yo\'q (ikkilik fayl yoki juda katta).';

  @override
  String pullsFilesError(String error) {
    return 'O\'zgargan fayllarni o\'qib bo\'lmadi: $error';
  }

  @override
  String get pullsEarlierVersion => 'Faylning oldingi versiyasiga yozilgan:';

  @override
  String pullsThreadsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta muhokama', one: '$n ta muhokama');
    return '$_temp0';
  }

  @override
  String pullsCommentOnLine(String line) {
    return '$line-qatorga izoh';
  }

  @override
  String get pullsAddComment => 'Izoh qo\'shish';

  @override
  String get pullsComment => 'Izoh qoldirish';

  @override
  String get pullsCommentLabel => 'Izoh';

  @override
  String get pullsPlaceholder => 'Markdown. Ctrl+Enter yuboradi.';

  @override
  String get pullsWrite => 'Matn';

  @override
  String get pullsPreview => 'Ko\'rish';

  @override
  String get pullsReply => 'Javob berish';

  @override
  String get pullsEdit => 'Tahrirlash';

  @override
  String get pullsSave => 'Saqlash';

  @override
  String get pullsEdited => 'tahrirlangan';

  @override
  String get pullsDelete => 'O\'chirish';

  @override
  String get pullsDeleteTitle => 'Izohni o\'chirasizmi?';

  @override
  String get pullsDeleteConfirm => 'U git xostingda hamma uchun o\'chadi. Buni qaytarib bo\'lmaydi.';

  @override
  String get pullsDeleted => 'Izoh o\'chirildi';

  @override
  String get pullsResolve => 'Hal qilindi';

  @override
  String get pullsUnresolve => 'Qayta ochish';

  @override
  String get pullsResolved => 'Hal qilingan';

  @override
  String get pullsOutdated => 'Eskirgan';

  @override
  String get pullsSent => 'agnts\'ga yuborilgan';

  @override
  String get pullsAnswered => 'agnts javob bergan';

  @override
  String get pullsVerdict_APPROVED => 'Tasdiqlangan';

  @override
  String get pullsVerdict_CHANGES_REQUESTED => 'O\'zgartirish so\'ralgan';

  @override
  String get pullsVerdict_COMMENTED => 'Izoh';

  @override
  String get pullsVerdict_DISMISSED => 'Rad etilgan';

  @override
  String pullsPostsAs(String login, String host) {
    return '${host}da @$login nomidan';
  }

  @override
  String pullsPostsAsToken(String host) {
    return '$host tokeni egasi nomidan';
  }

  @override
  String pullsTicketTitle(String number, String host) {
    return '#$number izohlari ($host)';
  }

  @override
  String get pullsTicketSubOwn =>
      'agnts pull requestiga ko\'rib chiquvchilar izohlari. Shu yerda javob bering yoki ularni agnts\'ga qaytaring.';

  @override
  String get pullsTicketSubReview => 'Pull requestning git xostingdagi muhokamasi.';

  @override
  String pullsTicketSubIn(String repo) {
    return '$repo da.';
  }

  @override
  String get pullsOpenWithDiff => 'Diff bilan ochish';

  @override
  String pullsAddressBtn(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta izohni hisobga olish', one: '$n ta izohni hisobga olish');
    return '$_temp0';
  }

  @override
  String pullsAddressConfirm(String key, num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'shu $n ta muhokama', one: 'shu muhokama');
    return 'agnts $key ga $_temp0 bilan qaytadi: kodni o\'zgartiradi yoki har biriga javob beradi. Tuzatish odatdagidek tasdig\'ingizni kutadi; push qilingach, agnts har bir muhokamada javob yozadi.';
  }

  @override
  String pullsAddressed(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta muhokama', one: '$n ta muhokama');
    return '$_temp0 agnts\'ga qaytarildi';
  }

  @override
  String pullsAddressLater(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta yangi izoh', one: '$n ta yangi izoh');
    return '$_temp0: ularni tiket ko\'rib chiqishingizni kutayotganda yoki pull requesti ochiq holda tayyor bo\'lganda agnts\'ga qaytarish mumkin.';
  }

  @override
  String pullsPostTitle(String number) {
    return '#$number ga ko\'rib chiqishni joylash';
  }

  @override
  String pullsPostSub(String host) {
    return '${host}da token egasi nomidan bitta ko\'rib chiqish. Diff qatorlaridagi topilmalar o\'sha qatorga izoh bo\'ladi.';
  }

  @override
  String pullsPostBtn(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ta qator izohi bilan joylash',
      one: '$n ta qator izohi bilan joylash',
      zero: 'Joylash',
    );
    return '$_temp0';
  }

  @override
  String get pullsPostSummary => 'Xulosa (hukm va barcha topilmalar)';

  @override
  String get pullsPostFindings => 'O\'z qatorlarida:';

  @override
  String get pullsSummaryOnly => 'faqat xulosada: diffda bunday qator yo\'q';

  @override
  String get pullsRequestChanges => 'O\'zgartirish so\'rash';

  @override
  String get pullsNoRequestChanges => 'GitLab\'da bu yerda o\'zgartirish so\'rovi yo\'q: izohlar joylanadi, tasdiqlar o\'zgarmaydi.';

  @override
  String get pullsSettingsTitle => 'Pull request izohlari';

  @override
  String get pullsSet_attribution => 'Muallifni ko\'rsatish';

  @override
  String get pullsSet_attributionHelp =>
      'agnts\'dan yozilgan izohlar git xosting tokeni egasi nomidan ketadi; har birining ostiga \"via agnts · ismingiz\" qo\'shiladi.';

  @override
  String get pullsSet_learnFromComments => 'Izohlaringizdan o\'rganish';

  @override
  String get pullsSet_learnFromCommentsHelp =>
      'Boshqalarning pull requestlariga git xostingda yozganlaringiz qanday ko\'rib chiqishingiz haqidagi eslatmaga aylanadi.';

  @override
  String get pullsSet_resolveFixed => 'Tuzatilgan muhokamalarni yopish';

  @override
  String get pullsSet_resolveFixedHelp => 'agnts tuzatishni push qilib, muhokamada javob bergach, uni hal qilingan deb belgilaydi.';

  @override
  String get pullsSet_autoAddress => 'O\'zgartirish so\'rovini hisobga olish';

  @override
  String get pullsSet_autoAddressHelp =>
      'Ko\'rib chiquvchi agnts pull requestida o\'zgartirish so\'rasa, hal qilinmagan muhokamalar o\'zi tiketga qaytadi. Tuzatish baribir tasdig\'ingizni kutadi.';

  @override
  String get pullsCommentHint => 'Satrga kursorni olib boring va unga izoh yozish uchun izoh tugmasini bosing.';

  @override
  String queueHeader(String running, String slots) {
    return 'Bajarilmoqda $running/$slots';
  }

  @override
  String queueQueued(num n) {
    return '$n ta navbatda';
  }

  @override
  String queueWaitingServer(String n) {
    return '$n tasi serverni kutmoqda';
  }

  @override
  String get queueBadge_blocked => 'Kutmoqda · bog‘liq';

  @override
  String get queueBadge_slots => 'Navbatda · slotlar';

  @override
  String get queueBadge_server => 'Navbatda · server';

  @override
  String get queueBadge_claude => 'Pauza · Muse';

  @override
  String get queueTitle_blocked => 'Bog‘liq tiketlarni kutmoqda';

  @override
  String get queueTitle_slots => 'Bo‘sh slotni kutmoqda';

  @override
  String get queueTitle_server => 'Server navbatida';

  @override
  String get queueTitle_claude => 'Muse’ni kutmoqda';

  @override
  String queuePosition(String position) {
    return 'Server navbatida #$position';
  }

  @override
  String queueOthers(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'Oldinda boshqa ish maydonlarining $n ta tiketi bor.', zero: '');
    return '$_temp0';
  }

  @override
  String queueEstimate(num minutes) {
    return 'Taxminan $minutes daqiqadan keyin boshlanadi.';
  }

  @override
  String queueServerFull(String runs, String reserved, String budget) {
    return 'Server band ($runs ta ish, $budget dan $reserved band).';
  }

  @override
  String queueSlotsHint(String running, String slots) {
    return '$slots ta slotdan $running tasi band. Bittasi bo‘shashi bilan boshlanadi.';
  }

  @override
  String get queueAddSlot => 'Slot qo‘shish';

  @override
  String get queueClaudeHint => 'Ish maydoni sozlamalari → Muse bo‘limida hisob ulang yoki kreditlarni yoqing.';

  @override
  String get queueMember => 'A’zo';

  @override
  String get queueTakeOver => 'O‘zimga olish';

  @override
  String get queueTakenOver => 'Tiket sizniki: «har kimniki o‘zi» rejimida u sizning Muse hisobingizda bajariladi.';

  @override
  String queueCreatedBy(String name) {
    return 'Yaratgan: $name';
  }

  @override
  String queueBy(String name) {
    return '$name';
  }

  @override
  String redFlagsTitle(num n) {
    return '$n ta xavfli belgi';
  }

  @override
  String get redFlagsSub =>
      'agnts o‘zgarishni tekshirib, ushbu qatorlarni topdi. Ular ko‘pincha tekshiruvlar noto‘g‘ri yo‘l bilan o‘tkazilganini bildiradi; agnts ko‘rib chiqishi har birini tekshiradi.';

  @override
  String get redFlagsKind_skipped_test => 'O‘tkazib yuborilgan yoki ajratilgan test';

  @override
  String get redFlagsKind_removed_assertion => 'Tekshiruvlar olib tashlangan';

  @override
  String get redFlagsKind_deleted_test => 'Test fayli o‘chirilgan';

  @override
  String get redFlagsKind_silenced_lint => 'Linter o‘chirilgan';

  @override
  String get redFlagsKind_swallowed_error => 'Xato yutib yuborilgan';

  @override
  String get redFlagsKind_todo => 'TODO qoldirilgan';

  @override
  String get redFlagsKind_new_dependency => 'Yangi bog‘liqlik';

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
  String get replayTitle => 'Bugungi agnts bilan qayta bajarish';

  @override
  String get replaySub =>
      'Bu tiketni u boshlangan kommitdan, joriy promptlar, tavsif va qoidalar bilan qayta bajaring va natijani siz tasdiqlagan ish bilan solishtiring. Takror hech qachon push qilinmaydi.';

  @override
  String get replayStart => 'Qayta bajarish';

  @override
  String replayConfirm(String key) {
    return 'agnts ${key}ni boshlangan joyidan qayta bajaradigan yangi vazifa yaratadi. U har qanday tiket kabi Muse rejangizdan foydalanadi.';
  }

  @override
  String replayCreated(String key) {
    return '$key takrori navbatga qo‘yildi';
  }

  @override
  String get replayBanner => 'Bu agnts’ni baholash uchun takror: u hech qachon push qilinmaydi. Uni quyidagi bilan solishtiring:';

  @override
  String get replayEvalTitle => 'Takrorlarni baholash';

  @override
  String get replayEvalSub =>
      'Yangi agnts bilan qayta bajarilgan yakunlangan tiketlar, siz tasdiqlagan o‘zgarish bilan solishtirilgan. Yakunlangan tiketdagi «Qayta bajarish» tugmasi yoki `agnts eval replay KEY` bilan boshlang.';

  @override
  String get replayNone => 'Hali takrorlar yo‘q.';

  @override
  String get replayRecent => 'So‘nggi takrorlar';

  @override
  String get replayColReplays => 'Takrorlar';

  @override
  String get replayColChecks => 'Tekshiruvlar';

  @override
  String get replayColLooksGood => 'Ko‘rib chiqish OK';

  @override
  String get replayColOverlap => 'Bir xil fayllar';

  @override
  String get replayColOverlapHint => 'Takrorda o‘zgargan fayllar tasdiqlangan o‘zgarish fayllariga qanchalik mos (Jakkar indeksi)';

  @override
  String get replayColRecall => 'Qamrov';

  @override
  String get replayColRecallHint => 'Tasdiqlangan o‘zgarish fayllaridan takror ham o‘zgartirganlari ulushi';

  @override
  String get replayColTurns => 'Qadamlar (asl)';

  @override
  String get replayColCost => 'Narx (asl)';

  @override
  String get replayColReplay => 'Takror';

  @override
  String get replayColOf => 'Asli';

  @override
  String get replayColState => 'Holat';

  @override
  String get replayColReview => 'Ko‘rib chiqish';

  @override
  String get replayPass => 'o‘tdi';

  @override
  String get replayFail => 'o‘tmadi';

  @override
  String get replayVerdict_looks_good => 'yaxshi';

  @override
  String get replayVerdict_has_concerns => 'shubhalar bor';

  @override
  String get replayVerdict_needs_changes => 'o‘zgartirish kerak';

  @override
  String get replayBenchmarkTitle => 'Benchmark';

  @override
  String get replayBenchmarkSub =>
      'agnts’dagi har bir o‘zgarish qayta ishga tushiriladigan va birlashtirilgan natija bilan solishtiriladigan birlashtirilgan tiketlar. Turli hajmdagi 20–30 tasini tanlang.';

  @override
  String get replayBenchmarkAdd => 'Benchmarkka qo‘shish';

  @override
  String get replayBenchmarkRemove => 'Benchmarkdan olib tashlash';

  @override
  String get replayBenchmarkIn => 'Benchmarkda: agnts’dagi o‘zgarishlar shu tiketda qayta ishga tushiriladi.';

  @override
  String get replayBenchmarkNeedsMerge =>
      'Benchmarkka faqat birlashtirilgan tiketlar kiradi: qayta ishga tushirishlar birlashtirilgan natija bilan solishtiriladi.';

  @override
  String get replayBenchmarkRun => 'Benchmarkni ishga tushirish';

  @override
  String get replayBenchmarkModel => 'Kod modeli';

  @override
  String get replayBenchmarkModelDefault => 'asl tiketlardagidek';

  @override
  String replayBenchmarkConfirm(String n) {
    return 'agnts benchmarkdagi $n ta tiketni har biri boshlangan joydan qayta ishga tushiradi. Ular oddiy tiketlar kabi Muse rejangizdan foydalanadi.';
  }

  @override
  String replayBenchmarkStarted(String n) {
    return 'Navbatga $n ta qayta ishga tushirish qo‘yildi';
  }

  @override
  String replayBenchmarkFailed(String n, String why) {
    return '$n tasini qayta ishga tushirib bo‘lmadi: $why';
  }

  @override
  String get replayBenchmarkEmpty => 'Benchmark bo‘sh. Birlashtirilgan tiketni oching va «Benchmarkka qo‘shish»ni bosing.';

  @override
  String replayBenchmarkCount(String n) {
    return '$n ta tiket';
  }

  @override
  String get replayAllReplays => 'Barcha qayta ishga tushirishlar';

  @override
  String get replayColModel => 'Model';

  @override
  String get replayColLines => 'Birlashtirilgan qatorlar';

  @override
  String get replayColLinesHint =>
      'Birlashtirilgan pull request qo‘shgan qatorlardan qayta ishga tushirish ham qo‘shganlari ulushi; qavsda — agnts’ning asl o‘zgarishi uchun. Qanchalik yuqori bo‘lsa, odamlar chiqargan narsaga shunchalik yaqin.';

  @override
  String get replayAgainst_merged => 'birlashtirilganga';

  @override
  String get replayAgainst_agnts => 'agnts’ga';

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
      'agnts tiket tekshiruvingizga kelishidan oldin tekshiruvlarni kutadi. Deploy har doim sizning qaroringiz va Muse chatidan mavjud emas.';

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
  String get repoBrief => 'Tavsif';

  @override
  String get repoCi => 'CI';

  @override
  String get repoCode => 'Kod';

  @override
  String get repoCodeSub => 'Tanlangan branchdagi repozitoriy fayllari, git hostingdan oʻqilgan.';

  @override
  String get repoCodeBranch => 'Branch';

  @override
  String get repoCodePath => 'Yoʻl';

  @override
  String get repoCodeRoot => 'Ildiz';

  @override
  String repoCodeLines(num n) {
    return '$n ta qator';
  }

  @override
  String get repoCodeView => 'Koʻrinish';

  @override
  String get repoCodePreview => 'Koʻrish';

  @override
  String get repoCodeSource => 'Kod';

  @override
  String get repoCodeBinary => 'Bu ikkilik fayl, uni bu yerda koʻrsatib boʻlmaydi.';

  @override
  String get repoCodeTooLarge => 'Fayl 1 MB dan katta, uni bu yerda koʻrsatib boʻlmaydi. Git hostingda oching.';

  @override
  String get repoCodeEmptyFile => 'Bu fayl boʻsh.';

  @override
  String get repoCodeEmpty => 'Bu branchda hali fayllar yoʻq.';

  @override
  String get repoCodeSubmodule => 'Submodul';

  @override
  String get repoCodeSymlink => 'Havola';

  @override
  String repoCodeCapped(String n) {
    return 'Bu papkaning faqat dastlabki $n ta elementi koʻrsatilgan.';
  }

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
  String get reposBranchTemplate => 'Branch nomi formati';

  @override
  String reposBranchTemplateHelp(String key, String number, String fallback) {
    return 'agnts har bir vazifa uchun branch nomini qanday qo\'yadi. $key yoki $number bo\'lishi shart. Bo\'sh qoldirilsa $fallback.';
  }

  @override
  String reposBranchTemplateExample(String example) {
    return 'Misol: $example';
  }

  @override
  String get reposCommitTemplate => 'Commit xabari formati';

  @override
  String get reposCommitTemplateHelp =>
      'agnts commit xabarlarini qanday yozadi. Bo\'sh scope qavslarini olib tashlaydi. Bo\'sh qoldirilsa KEY: Title.';

  @override
  String reposCommitTemplateExample(String example) {
    return 'Misol: $example';
  }

  @override
  String get reposPlaceholders => 'O\'rinbosarlar';

  @override
  String get reposPhPrefix => 'Repozitoriyning branch prefiksi, odatda agnts/.';

  @override
  String get reposPhType => 'Ish turi: kod uchun feature, bag uchun bugfix, test, swagger-test.';

  @override
  String get reposPhKey => 'agnts vazifa kaliti: VIS-42 yoki Jira yoki Plane vazifa kaliti.';

  @override
  String get reposPhNumber => 'Vazifaning tiket raqami, masalan AMANAT-2288. Bo\'sh bo\'lsa kalit ishlatiladi.';

  @override
  String get reposPhSlug => 'Vazifa nomi kichik harflarda, defis bilan, 40 belgigacha.';

  @override
  String get reposPhUser => 'Vazifa biriktirilgan foydalanuvchi yoki uni yaratgan kishining nomi.';

  @override
  String get reposPhCommitType =>
      'Agent tanlagan o\'zgarish turi: feat, fix, chore, refactor, docs, test... Aks holda vazifa turidan olinadi.';

  @override
  String get reposPhScope => 'Agent o\'zgartirgan qism, masalan deps yoki auth. Bo\'sh bo\'lishi mumkin.';

  @override
  String get reposPhSubject => 'Agentning o\'zgarish haqidagi bir qatorli qisqa tavsifi. Aks holda vazifa nomi olinadi.';

  @override
  String get reposPhTitle => 'Vazifa nomi o\'zgarishsiz.';

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
  String get reposDetectDeep => 'Muse’dan so‘rash';

  @override
  String get reposDetectDeepHelp =>
      'Skanerlash buyruqlarni topmasa, Muse README va CI fayllarini o‘qiydi. Taxminan bir daqiqa oladi va Muse tarifingizdan foydalanadi.';

  @override
  String get reposDetecting => 'Repozitoriy o‘qilmoqda…';

  @override
  String reposDetectDone(String list) {
    return 'Topildi: $list.';
  }

  @override
  String get reposDetectNothing => 'Ma’lum yig‘ish fayllari topilmadi. Toolchain va buyruqlarni qo‘lda qo‘shing yoki Muse’dan so‘rang.';

  @override
  String get reposDetectFilled => 'Bo‘sh tekshiruv buyruqlari to‘ldirildi — saqlashdan oldin ko‘rib chiqing.';

  @override
  String get reposDetectByClaude => 'Muse skanerlash topa olmagan narsalarni to‘ldirdi.';

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
      'Har bir ishga tushirish uchun KEY=value qatorlari, masalan, xususiy paket reyestrlari tokenlari (NPM_TOKEN, PIP_INDEX_URL). Shifrlangan holda saqlanadi va boshqa ko‘rsatilmaydi. Muse ishlayotganda ularni o‘qishi mumkin, shuning uchun faqat o‘qish uchun tokenlardan foydalaning.';

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
  String get reposSearch => 'Nomi, steki, loyihasi yoki guruhi bo\'yicha qidirish';

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
  String get reviewCat_architecture => 'Arxitektura';

  @override
  String get reviewCat_scope => 'Vazifa doirasi';

  @override
  String get reviewsTitle => 'Pull request tekshiruvlari';

  @override
  String get reviewsLede =>
      'agnts GitHub va GitLab’dagi repozitoriylaringizning ochiq pull requestlarini koʻrsatadi. Keraklisini oching va agnts uni hozirgi holatida tekshirishi uchun «Tekshirish»ni bosing; xohlagan paytingizda, masalan yangi commitlardan keyin, qayta tekshiring. Uning tekshiruvlari pull requestda saqlanadi.';

  @override
  String get reviewsSyncing => 'Sinxronlanmoqda…';

  @override
  String get reviewsSyncErrors => 'Baʼzilarini oʻqib boʻlmadi:';

  @override
  String get reviewsSettingsTitle => 'agnts ularni qanday oladi';

  @override
  String get reviewsReviewRequested => 'Tekshiruv soʻrovlari ham';

  @override
  String get reviewsReviewRequestedHelp => 'Faqat sizga biriktirilganlarini emas, sizdan tekshiruv soʻralgan pull requestlarni ham olish.';

  @override
  String get reviewsAll => 'Barcha ochiq pull requestlar';

  @override
  String get reviewsAllHelp =>
      'Faqat sizga biriktirilgan yoki sizdan tekshiruv soʻralganlarini emas, repozitoriylaringizdagi barcha ochiq pull requestlarni, oʻzingiznikilarini ham olish. Bunday pull requestni tasdiqlash uni birlashtirmaydi.';

  @override
  String get reviewsSkipDrafts => 'Qoralamalarni oʻtkazib yuborish';

  @override
  String get reviewsSkipDraftsHelp => 'Qoralama pull requestlar tayyor boʻlguncha tegilmaydi.';

  @override
  String get reviewsMergeMethod => 'Birlashtirish usuli';

  @override
  String get reviewsMergeMethodHelp => 'Siz qabul qilgan pull requestni agnts qanday birlashtiradi.';

  @override
  String get reviewsMerge_merge => 'Merge commit';

  @override
  String get reviewsMerge_squash => 'Squash';

  @override
  String get reviewsMerge_rebase => 'Rebase';

  @override
  String get reviewsWaiting => 'Sizni kutmoqda';

  @override
  String get reviewsInProgress => 'Jarayonda';

  @override
  String get reviewsFinished => 'Yakunlangan';

  @override
  String get reviewsEmpty => 'Bu yerda hech narsa yoʻq.';

  @override
  String get reviewsEmptyAll => 'Ochiq pull requestlar yoʻq. Sozlamalarda qaysilari olinishini tekshiring va «Yangilash»ni bosing.';

  @override
  String get reviewsWhy_assigned => 'biriktirilgan';

  @override
  String get reviewsWhy_review_requested => 'tekshiruv soʻralgan';

  @override
  String get reviewsWhy_open => 'ochiq';

  @override
  String get reviewsWhy_own => 'sizniki';

  @override
  String get reviewsWhy_manual => 'agnts’da soʻralgan';

  @override
  String reviewsBy(String author) {
    return 'muallif @$author';
  }

  @override
  String get reviewsHowTitle => 'Siz qanday tekshirasiz';

  @override
  String get reviewsHowSub =>
      'Qayta tekshirishni soʻraganda yoki rad etganda qoldirgan izohlaringiz keyingi tekshiruvda profilingizga qoʻshiladi. Keyingi barcha tekshiruvlar uni oʻqiydi.';

  @override
  String get reviewsNoReviewers =>
      'agnts siz qanday tekshirishingiz haqida hali hech narsa bilmaydi. Qayta tekshirishni soʻraganda izoh qoldiring yoki quyida qoʻshing.';

  @override
  String get reviewsProfile => 'Profil';

  @override
  String get reviewsProfileHint => 'Markdown: siz uchun nima muhim, nima shovqin, jiddiylikni qanday baholaysiz.';

  @override
  String reviewsFolded(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta izoh oʻrganildi');
    return '$_temp0';
  }

  @override
  String get reviewsPending => 'Hali oʻrganilmagan';

  @override
  String get reviewsSaveProfile => 'Profilni saqlash';

  @override
  String get reviewsProfileSaved => 'Profil saqlandi';

  @override
  String get reviewsAddNote => 'Izoh qoʻshish';

  @override
  String get reviewsNotePlaceholder =>
      'Masalan: nomlash boʻyicha mayda gaplar men uchun shovqin; migratsiyalarni orqaga qaytarish mumkinligini doim tekshir.';

  @override
  String get reviewsNoteAdded => 'Izoh qoʻshildi';

  @override
  String get reviewsDeleteNote => 'Izohni oʻchirish';

  @override
  String get reviewsNoteKind_rereview => 'qayta tekshiruv';

  @override
  String get reviewsNoteKind_dismissed => 'rad etilgan';

  @override
  String get reviewsNoteKind_manual => 'shu yerda yozilgan';

  @override
  String get reviewsLogin => 'Git hostingdagi foydalanuvchi nomi';

  @override
  String reviewsPr(String number) {
    return 'Pull request #$number';
  }

  @override
  String reviewsReviewed(String sha) {
    return 'Oxirgi commit $sha';
  }

  @override
  String get reviewsNewCommits => 'Yangi commitlar bor';

  @override
  String reviewsPostBtn(String host) {
    return 'Koʻrib chiqishni ${host}ga joylash';
  }

  @override
  String reviewsPostConfirm(String number, String host) {
    return 'agnts #$number boʻyicha koʻrib chiqishini ${host}ga izoh sifatida joylasinmi? U sizning $host akkauntingizdan joylanadi va pull requestdagi hamma uni koʻradi.';
  }

  @override
  String reviewsPostedToast(String host) {
    return 'Koʻrib chiqish ${host}ga joylandi';
  }

  @override
  String reviewsPosted(String host, String when) {
    return 'agnts bu commit boʻyicha koʻrib chiqishi ${host}da · $when';
  }

  @override
  String get reviewsQueuedSub => 'agnts uni yuklab oladi va tekshiradi.';

  @override
  String get reviewsFetchingTitle => 'Pull request yuklanmoqda';

  @override
  String get reviewsReviewingTitle => 'Pull request tekshirilmoqda';

  @override
  String get reviewsReviewingSub => 'agnts oʻzgarishlarni oʻqimoqda. Uning tekshiruvi shu yerda chiqadi.';

  @override
  String get reviewsReadyTitle => 'agnts tekshiruvi tayyor';

  @override
  String reviewsReadySub(String host) {
    return 'Shu yerdan birlashtiring, izoh bilan qayta tekshirishni soʻrang yoki rad etib, ${host}da oʻzingiz tekshiring.';
  }

  @override
  String get reviewsNoteLabel => 'Izoh bilan qayta tekshirish';

  @override
  String get reviewsNoteHint =>
      'agnts nimada xato qilgani yoki nimani oʻtkazib yuborganini yozing. Izoh unga siz qanday tekshirishingizni ham oʻrgatadi.';

  @override
  String get reviewsMergeBtn => 'Pull requestni birlashtirish';

  @override
  String reviewsMergeConfirm(String number, String host, String method) {
    return 'agnts #$number ni ${host}da tekshirilgan commitda birlashtiradi ($method).';
  }

  @override
  String get reviewsRereviewBtn => 'Qayta tekshirish';

  @override
  String reviewsDismissBtn(String host) {
    return 'Rad etish, ${host}da oʻzim tekshiraman';
  }

  @override
  String get reviewsDismissReason => 'Nega (ixtiyoriy)';

  @override
  String get reviewsDismissReasonHint => 'Ixtiyoriy. Bu ham agnts’ga siz qanday tekshirishingizni oʻrgatadi.';

  @override
  String reviewsDismissConfirm(String number, String host) {
    return 'agnts #$number ni tekshirishni toʻxtatadi. Pull request ${host}da ochiq qoladi.';
  }

  @override
  String get reviewsMergingTitle => 'Pull request birlashtirilmoqda';

  @override
  String get reviewsMergedTitle => 'Birlashtirildi';

  @override
  String reviewsMergedSub(String number) {
    return '#$number birlashtirildi.';
  }

  @override
  String get reviewsDismissedTitle => 'Tekshiruv rad etildi';

  @override
  String reviewsDismissedSub(String host) {
    return 'Pull request ${host}da sizniki.';
  }

  @override
  String reviewsOpenOn(String host) {
    return '${host}da ochish';
  }

  @override
  String get reviewsReviewTitle => 'agnts’ning pull request tekshiruvi';

  @override
  String get reviewsRefresh => 'Yangilash';

  @override
  String get reviewsOpenPulls => 'Ochiq pull requestlar';

  @override
  String get reviewsNotReviewed => 'Tekshirilmagan';

  @override
  String get reviewsHistory => 'Tekshiruvlar';

  @override
  String get reviewsHistoryEmpty => 'Hali tekshirilmagan. Boshlash uchun «agnts bilan ko\'rib chiqish»ni bosing.';

  @override
  String reviewsReviewedAt(String sha) {
    return '$sha da';
  }

  @override
  String get rulesTitle => 'Qoidalar';

  @override
  String get rulesLede =>
      'agnts har bir tiketda amal qiladigan koʻrsatmalar: barcha repozitoriylar uchun global qoidalar va bitta repozitoriy uchun qoidalar. Muse har bir qoidani tekshiradi va u kuchga kirishidan oldin noaniq joylar haqida savol beradi.';

  @override
  String get rulesAdd => 'Qoida qoʻshish';

  @override
  String get rulesAddSubmit => 'Qoʻshish va tekshirish';

  @override
  String get rulesDrawerSub => 'Yangi hamkasbga tushuntirgandek yozing. Muse uni biror tiket amal qilishidan oldin tekshiradi.';

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
      'Qoida matnini oʻzgartirdingiz, shuning uchun Muse uni qayta tekshiradi. Tekshiruv tugaguncha tiketlar uni olmaydi.';

  @override
  String get rulesSaved => 'Qoida saqlandi';

  @override
  String get rulesSavedReview => 'Qoida saqlandi; Muse uni tekshirmoqda';

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
  String get rulesPending => 'Boʻsh ishchini kutmoqda. Muse qoidalarni keyingi tiket boshlanishidan oldin tekshiradi.';

  @override
  String get rulesAnalyzing => 'Muse qoidani oʻqib, undagi noaniqlik va ziddiyatlarni qidirmoqda.';

  @override
  String rulesQuestionsTitle(num n) {
    return 'Qoida kuchga kirishidan oldin $n ta savol';
  }

  @override
  String get rulesQuestionsSub => 'Muse noaniq joy topdi. Javoblaringiz qoidaning bir qismiga aylanadi.';

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
    return 'Muse bu qoidani tekshira olmadi: $error';
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
  String get rulesAnswered => 'Javoblar yuborildi; Muse qoidani qayta tekshirmoqda';

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
  String get rulesStatus_suggested => 'Taklif qilingan';

  @override
  String get rulesSuggestedFrom => 'agnts bu qoidani quyidagi tiketga bergan fikringizdan taklif qilmoqda:';

  @override
  String get rulesSuggestedHint =>
      'Siz qabul qilmaguningizcha tiketlar unga amal qilmaydi. O‘zgartirishlaringiz bilan qabul qilish uchun uni tahrirlang.';

  @override
  String rulesSuggestedHelp(num n) {
    return 'agnts fikr-mulohazalaringizdan o‘rganib, $n ta qoida taklif qilmoqda.';
  }

  @override
  String get rulesAdopt => 'Qabul qilish';

  @override
  String get rulesAdoptAsWritten => 'Yozilganicha qabul qilish';

  @override
  String get rulesDismiss => 'Rad etish';

  @override
  String rulesDismissBody(String title) {
    return 'agnts «$title»ni olib tashlaydi va uni boshqa taklif qilmaydi.';
  }

  @override
  String get rulesDismissed => 'Taklif rad etildi';

  @override
  String get rulesKind => 'Turi';

  @override
  String get rulesKindRule => 'Qoida';

  @override
  String get rulesKindContext => 'Biznes konteksti';

  @override
  String get rulesKindRuleHelp => 'agnts har bir tiketda amal qiladigan ko‘rsatma.';

  @override
  String get rulesKindContextHelp =>
      'Mahsulotingiz haqida bilim: atamalar nimani anglatadi, kod saqlashi kerak bo‘lgan invariantlar, kim nimadan foydalanadi. Har bir ishga tushirish boshlashdan oldin uni o‘qiydi.';

  @override
  String get rulesTag_reuse => 'qayta foydalanish';

  @override
  String get rulesTag_layer => 'qatlam';

  @override
  String get rulesTag_tests => 'testlar';

  @override
  String get rulesTag_style => 'uslub';

  @override
  String get rulesTag_logic => 'mantiq';

  @override
  String get rulesTag_other => 'boshqa';

  @override
  String get runsNavRuns => 'Ishga tushirishlar';

  @override
  String get runsTitle => 'Ishga tushirishlar tarixi';

  @override
  String get runsLede =>
      'Barcha ish maydonlaridagi har bir Muse va Codex chaqiruvi: qancha turgani, qancha davom etgani va qanday tugagani. Ochilgan chaqiruv mijoz ma’lumotlarini ko‘rsatadi, har bir ko‘rish jurnalga yoziladi.';

  @override
  String get runsRunTitle => 'Chaqiruv';

  @override
  String get runsBack => 'Barcha ishga tushirishlar';

  @override
  String get runsSettings => 'Sozlamalar';

  @override
  String get runsSumCount => 'Chaqiruvlar';

  @override
  String get runsSumErrors => 'Xatolar ulushi';

  @override
  String runsSumErrorsNote(String n) {
    return '$n tasi xato, vaqt tugashi yoki xotira yetishmasligi bilan tugadi';
  }

  @override
  String get runsSumStalls => 'Qotib qolganlar';

  @override
  String get runsSumStallsNote => 'kamida bir marta qotib qolgan chaqiruvlar';

  @override
  String get runsSumCost => 'Narx';

  @override
  String runsSumCostNote(String cost) {
    return 'fon chaqiruvlari $cost';
  }

  @override
  String get runsSumTokens => 'Tokenlar kirish / chiqish';

  @override
  String get runsSumTokensNote => 'keshdan o‘qishlarsiz';

  @override
  String get runsSumDuration => 'Davomiylik p50 / p95';

  @override
  String get runsSumDurationNote => 'tugagan chaqiruvlar';

  @override
  String get runsFWorkspace => 'Ish maydoni';

  @override
  String get runsAllWorkspaces => 'Barcha ish maydonlari';

  @override
  String get runsFPurpose => 'Maqsad';

  @override
  String get runsAllPurposes => 'Barcha maqsadlar';

  @override
  String get runsPStages => 'Tiket bosqichlari';

  @override
  String get runsPBackground => 'Fon chaqiruvlari';

  @override
  String get runsP_analyze => 'Tahlil';

  @override
  String get runsP_code => 'Kod yozish';

  @override
  String get runsP_review => 'Ko‘rib chiqish';

  @override
  String get runsP_push => 'Yuborish';

  @override
  String get runsP_learn => 'O‘rganish';

  @override
  String get runsP_preview => 'Oldindan ko‘rish';

  @override
  String get runsP_second_opinion => 'Ikkinchi fikr';

  @override
  String get runsP_assistant => 'Yordamchi';

  @override
  String get runsP_brief => 'Repozitoriy tavsifi';

  @override
  String get runsP_detect => 'Asboblarni aniqlash';

  @override
  String get runsP_reflect => 'Mulohaza';

  @override
  String get runsP_rules => 'Qoidalar';

  @override
  String get runsP_translate => 'Tarjima';

  @override
  String get runsFStatus => 'Holat';

  @override
  String get runsAnyStatus => 'Istalgan holat';

  @override
  String get runsS_running => 'Bajarilmoqda';

  @override
  String get runsS_done => 'Tayyor';

  @override
  String get runsS_error => 'Xato';

  @override
  String get runsS_timeout => 'Vaqt tugadi';

  @override
  String get runsS_cancelled => 'Bekor qilindi';

  @override
  String get runsS_oom => 'Xotira yetmadi';

  @override
  String get runsFEngine => 'Dvijok';

  @override
  String get runsAnyEngine => 'Istalgan dvijok';

  @override
  String get runsE_claude => 'Muse';

  @override
  String get runsE_codex => 'Codex';

  @override
  String get runsFModel => 'Model';

  @override
  String get runsFTicket => 'Tiket';

  @override
  String get runsFStalled => 'Qotib qolganlar';

  @override
  String get runsFPeriod => 'Davr';

  @override
  String get runsPer_1d => 'So‘nggi 24 soat';

  @override
  String get runsPer_7d => 'So‘nggi 7 kun';

  @override
  String get runsPer_30d => 'So‘nggi 30 kun';

  @override
  String get runsPer_all => 'Butun davr';

  @override
  String get runsFMinCost => 'Min. narx';

  @override
  String get runsClear => 'Filtrlarni tozalash';

  @override
  String get runsNone => 'Bu filtrlarga mos chaqiruv yo‘q.';

  @override
  String get runsLoadMore => 'Yana yuklash';

  @override
  String get runsColStarted => 'Boshlangan';

  @override
  String get runsColWorkspace => 'Ish maydoni';

  @override
  String get runsColTicket => 'Tiket yoki mavzu';

  @override
  String get runsColPurpose => 'Maqsad';

  @override
  String get runsColModel => 'Model';

  @override
  String get runsColTurns => 'Qadamlar';

  @override
  String get runsColTools => 'Asboblar';

  @override
  String get runsColCost => 'Narx';

  @override
  String get runsColDuration => 'Davomiylik';

  @override
  String get runsColOutcome => 'Natija';

  @override
  String runsToolsTitle(String calls, String errors) {
    return 'Asbob chaqiruvlari: $calls, xatolilari: $errors';
  }

  @override
  String runsStallsTitle(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n marta qotib qoldi', one: '$n marta qotib qoldi');
    return '$_temp0';
  }

  @override
  String get runsSettingsTitle => 'Ishga tushirishlar tarixi sozlamalari';

  @override
  String get runsSettingsSub =>
      'Yozuvlar qancha saqlanadi va ularning qancha qismi yoziladi. Cheklovlar saqlangandan keyin boshlangan chaqiruvlarga amal qiladi.';

  @override
  String get runsSet_retentionDays => 'Yozuvlarni saqlash, kun';

  @override
  String get runsSet_retentionDaysHelp => 'Eskilari har kuni o‘chiriladi; 0 — doim saqlash';

  @override
  String get runsSet_toolOutputKB => 'Asbob chiqishi chegarasi, KB';

  @override
  String get runsSet_toolOutputKBHelp => 'Bitta asbobning chiqishi; boshi va oxiri saqlanadi';

  @override
  String get runsSet_textKB => 'Matn chegarasi, KB';

  @override
  String get runsSet_textKBHelp => 'Bitta matn bloki yoki asbob kirishi';

  @override
  String get runsSet_transcriptMB => 'Yozuv chegarasi, MB';

  @override
  String get runsSet_transcriptMBHelp => 'Undan oshgach faqat asbob chaqiruvlari va natija saqlanadi';

  @override
  String get runsSettingsSave => 'Saqlash';

  @override
  String get runsSettingsSaved => 'Ishga tushirishlar tarixi sozlamalari saqlandi';

  @override
  String get runsBanner => 'Siz mijoz ma’lumotlarini ko‘ryapsiz. Bu kirish jurnalga yoziladi.';

  @override
  String get runsDownload => 'JSONL yuklab olish';

  @override
  String get runsNotFound => 'Bu yozuv endi mavjud emas.';

  @override
  String get runsUnreadable => 'Yozuvning bir qismini o‘qib bo‘lmadi; quyida o‘qilgan qismi.';

  @override
  String get runsTruncated => 'Hajm chegarasiga yetildi; keyingi tarkib saqlanmadi.';

  @override
  String get runsAccount => 'Muse hisobi';

  @override
  String get runsSession => 'Seans';

  @override
  String get runsStartedAt => 'Boshlangan';

  @override
  String get runsFinishedAt => 'Tugagan';

  @override
  String get runsTokens => 'Tokenlar';

  @override
  String runsTokensVal(String input, String output) {
    return '$input kirish · $output chiqish';
  }

  @override
  String runsCacheVal(String read, String write) {
    return 'kesh: $read o‘qish · $write yozish';
  }

  @override
  String get runsSize => 'Saqlangan / asl hajm';

  @override
  String get runsExitReason => 'Tugash sababi';

  @override
  String get runsRunningNote => 'Hali bajarilmoqda. Yangilash yozuvni qayta o‘qiydi va bu ham jurnalga yoziladi.';

  @override
  String get runsReload => 'Yangilash';

  @override
  String get runsSiblings => 'Bu ishga tushirishning chaqiruvlari';

  @override
  String get runsSiblingsSub => 'Birinchi o‘tish, tuzatish urinishlari va ikkinchi fikr, eskilari avval';

  @override
  String get runsThisOne => 'joriy';

  @override
  String get runsTab_timeline => 'Xronologiya';

  @override
  String get runsTab_prompt => 'Prompt';

  @override
  String get runsTab_result => 'Natija';

  @override
  String runsEventsCount(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n hodisa', one: '$n hodisa');
    return '$_temp0';
  }

  @override
  String runsNextError(String n) {
    return 'Keyingi xato ($n)';
  }

  @override
  String get runsNoErrors => 'Xato yo‘q';

  @override
  String get runsNoEvents => 'Hech narsa yozilmagan.';

  @override
  String runsShowMore(String n) {
    return 'Yana $n tasini ko‘rsatish';
  }

  @override
  String get runsKTool => 'Asbob';

  @override
  String get runsKToolResult => 'Asbob natijasi';

  @override
  String get runsKInit => 'Boshlanish';

  @override
  String get runsKRateLimit => 'So‘rovlar chegarasi';

  @override
  String get runsKNote => 'agnts';

  @override
  String get runsKResult => 'Natija';

  @override
  String get runsToolOk => 'Muvaffaqiyatli';

  @override
  String get runsToolFailed => 'Xato bilan';

  @override
  String runsExitCode(String code) {
    return 'kod $code';
  }

  @override
  String get runsInput => 'Kirish';

  @override
  String get runsOutput => 'Chiqish';

  @override
  String get runsNoOutput => '(chiqish yo‘q)';

  @override
  String runsCutNote(String kb) {
    return 'qisqartirilgan, asli $kb KB';
  }

  @override
  String runsTurnsN(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n qadam', one: '$n qadam');
    return '$_temp0';
  }

  @override
  String get runsNoPrompt => '(bo‘sh prompt)';

  @override
  String get runsNoResult => 'Natija yozilmagan.';

  @override
  String get runsSubtype => 'Turi';

  @override
  String get runsAuditTitle => 'Audit jurnali';

  @override
  String get runsAuditLede =>
      'Administrator mijoz ma’lumotlarini (yozuv, prompt, yuklab olish) ko‘rgan yoki ishga tushirishlar tarixi sozlamalarini o‘zgartirgan har bir holat, yangilari avval.';

  @override
  String get runsAllActions => 'Barcha amallar';

  @override
  String get runsA_transcript_view => 'Yozuvni ko‘rish';

  @override
  String get runsA_transcript_prompt => 'Promptni ko‘rish';

  @override
  String get runsA_transcript_download => 'Yozuvni yuklab olish';

  @override
  String get runsA_run_history_settings => 'Sozlamalarni o‘zgartirish';

  @override
  String get runsColTime => 'Vaqt';

  @override
  String get runsColAdmin => 'Administrator';

  @override
  String get runsColAction => 'Amal';

  @override
  String get runsColTarget => 'Obyekt';

  @override
  String get runsColIp => 'IP';

  @override
  String get runsNoAudit => 'Audit jurnali hozircha bo‘sh.';

  @override
  String get runsAuditSearch => 'Admin, obyekt yoki ish maydoni bo‘yicha qidirish';

  @override
  String runsAuditTranscript(String id) {
    return 'Transkript #$id';
  }

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
  String get settingsRunBudget => 'Bitta ish uchun byudjet';

  @override
  String get settingsRunBudgetHelp =>
      'Kreditdagi bitta ish sarflashi mumkin bo‘lgan eng ko‘p miqdor; 80% da Muse’ga yakunlash aytiladi va oshib ketishidan oldin to‘xtatiladi';

  @override
  String get settingsRunBudgetServer => 'Server limiti';

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
  String get settingsCommits => 'Commitlar va PR';

  @override
  String get settingsCommitsSub => 'Commitlar kimning nomidan va pull requestlar qanday ochiladi';

  @override
  String get settingsAuthorName => 'Muallif ismi';

  @override
  String get settingsAuthorNameHelp => 'Boʻsh qoldirsangiz, commitlar tiket egasi nomidan, uning hisobidagi ism va email bilan qilinadi';

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
  String get settingsProgress => 'Agent bosqichni tugatganda';

  @override
  String get settingsProgressHelp => 'Tahlil tayyor, kod yozildi. Faqat telefonga, ovozsiz, har bir tiket uchun bitta bildirishnoma';

  @override
  String get settingsLessons => 'agnts oʻrganish uchun yangi narsa topganda';

  @override
  String get settingsReviewDone => 'agnts kod sharhi tugaganda';

  @override
  String get settingsSecretsHelp =>
      'Jira, GitHub va Muse tokenlari serveringizda shifrlangan holda saqlanadi. Bu sahifa ularni hech qachon koʻrsatmaydi.';

  @override
  String get settingsSaved => 'Sozlamalar saqlandi';

  @override
  String settingsParallelSlots(num n) {
    return 'Bir vaqtda $n ta ish';
  }

  @override
  String get settingsParallelSlotsHelp => 'Ish maydoni slotlari. «Ish maydoni → To‘lov» bo‘limida o‘zgartiriladi.';

  @override
  String get settingsClaudeMoved => 'Claude endi har bir ish maydoni uchun alohida ulanadi.';

  @override
  String get settingsClaudeOpen => 'Ish maydoni → Claude';

  @override
  String get settingsSelfReview => 'Avval ko‘rib chiqish kamchiliklarini tuzatish';

  @override
  String get settingsSelfReviewHelp =>
      'agnts o‘z ko‘rib chiqishida to‘suvchi yoki jiddiy muammo topsa, siz ko‘rib chiqishingizdan oldin uni bir marta dasturchiga qaytaradi. Yuqoridagi kod ko‘rib chiqishi yoqilgan bo‘lishi kerak.';

  @override
  String get settingsAutoBrief => 'Repozitoriylarni o‘rganish';

  @override
  String get settingsAutoBriefHelp =>
      'Repozitoriyning birinchi tiketi tahlil qilinganda repozitoriy tavsifini (arxitektura, retseptlar, kelishuvlar) yozish va har 10 ta birlashtirishdan keyin yangilash. Tavsif agentga faqat siz tasdiqlaganingizdan keyin yetadi.';

  @override
  String get settingsReflect => 'Fikr-mulohazalaringizdan o‘rganish';

  @override
  String get settingsReflectHelp =>
      'O‘zgartirish so‘raganingizda yoki ishni sabab bilan rad etganingizda, agnts uning ortidagi umumiy qoidani qidiradi va «Qoidalar» sahifasida taklif qiladi. Siz qabul qilmaguningizcha hech narsa qo‘llanmaydi.';

  @override
  String get settingsCiRed => 'Kuzatiladigan branch qizarganda';

  @override
  String get settingsClaudeMuse => 'Muse Code';

  @override
  String get settingsClaudeMovedMuse => 'Muse har bir ish maydoni uchun alohida ulanadi.';

  @override
  String get settingsClaudeOpenMuse => 'Ish maydoni → Muse';

  @override
  String get settingsModelsHelpMuse => 'Har bir bosqich uchun modelni tanlang. Muse Spark eng arzoni; Muse Wonder kuchliroq va qimmatroq.';

  @override
  String get settingsStageCodingHelpMuse => 'Asosiy ish. Eng ko‘p sarflaydi.';

  @override
  String get settingsStageReviewHelpMuse =>
      'Siz ko‘rib chiqayotganda har bir natijani tekshiradi. «Avto» murakkab tiketlar uchun Muse Wonder, qolganlari uchun Muse Spark’dan foydalanadi.';

  @override
  String get settingsAllowHelpMuse => 'Muse Code bularni so‘ramasdan ishga tushira oladi';

  @override
  String get settingsDenyHelpMuse => 'Tiket so‘rasa ham doim rad etiladi. Push’ni Muse Code emas, agnts bajaradi.';

  @override
  String get spendTitle => 'Token sarfi';

  @override
  String spendSub(String tokens, String cost) {
    return 'Kirish va chiqishda $tokens token · API narxlarida taxminan $cost';
  }

  @override
  String get spendEmpty =>
      'Hali hech narsa yozilmagan. Sarf agnts bu tiket boʻyicha Muse\'ni birinchi marta ishga tushirgandan keyin koʻrinadi.';

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
      'Narx — Muse\'ning xuddi shu ish uchun API narxlaridagi bahosi. Muse obunasida u toʻlanmaydi; u har bir bosqichning nisbiy ogʻirligini koʻrsatadi.';

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
  String get spendTopEmpty => 'Bu davrda Muse ishlari yozilmagan.';

  @override
  String get spendTopNote =>
      'Tartib Muse narx bahosi boʻyicha, u keshni toʻgʻri hisobga oladi. Ulush — davrdagi taxminiy narxdan. Faqat davr ichidagi sarf hisoblanadi.';

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
  String get stateReviewAnalyzing => 'Yuklanmoqda';

  @override
  String get stateReviewCoding => 'Tekshirilmoqda';

  @override
  String get stateReviewWaiting_for_review => 'Tekshiruv tayyor';

  @override
  String get stateReviewPushing => 'Birlashtirilmoqda';

  @override
  String get stateReviewDone => 'Birlashtirildi';

  @override
  String get stateReviewRejected => 'Rad etildi';

  @override
  String get swaggerFormSub =>
      'HTTP API\'ni Swagger/OpenAPI spetsifikatsiyasi boʻyicha tekshirish: agnts tekshiruvlarni tuzadi, haqiqiy soʻrovlar yuboradi va har biri boʻyicha dalil bilan xulosa beradi.';

  @override
  String get swaggerSpec => 'Spetsifikatsiya';

  @override
  String get swaggerSpecUrl => 'Spetsifikatsiya yoki hujjatlar sahifasi manzili';

  @override
  String get swaggerSpecUrlPh => 'https://staging.example.com/swagger/index.html';

  @override
  String get swaggerSpecRead => 'Oʻqish';

  @override
  String get swaggerSpecReading => 'Spetsifikatsiya oʻqilmoqda…';

  @override
  String get swaggerSpecUpload => 'Fayl yuklash';

  @override
  String get swaggerSpecHint =>
      'Swagger UI, Springdoc yoki Redoc sahifasi ham boʻladi: agnts uning ortidagi spetsifikatsiyani topadi. Swagger 2.0 va OpenAPI 3.x, 5 MB gacha.';

  @override
  String swaggerSpecFound(String title, String version, num count, String format) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count ta endpoint');
    return '$title $version · $_temp0 · $format';
  }

  @override
  String get swaggerSpecChoose => 'Bu sahifada bir nechta spetsifikatsiya bor. Bittasini tanlang:';

  @override
  String get swaggerBaseUrl => 'Asosiy URL';

  @override
  String get swaggerBaseUrlHint =>
      'Soʻrovlar shu yerga boradi. Avval bu spetsifikatsiyadagi server, u esa koʻpincha production boʻladi: tekshiring. Xost nomi yoki IP, istalgan port. Ichki xostlarga xususiy tarmoq marshruti kerak.';

  @override
  String get swaggerEndpoints => 'Endpointlar';

  @override
  String swaggerEndpointsCount(String n, String total) {
    return '$total tadan $n tasi belgilangan';
  }

  @override
  String get swaggerSearch => 'Endpointlarni qidirish';

  @override
  String get swaggerAll => 'Hammasi';

  @override
  String get swaggerNone => 'Hech biri';

  @override
  String swaggerUntickedSideEffect(String word) {
    return 'Belgilanmadi: nomiga qaraganda u nimanidir oʻzgartiradi ($word)';
  }

  @override
  String get swaggerUntickedDeprecated => 'Belgilanmadi: eskirgan';

  @override
  String get swaggerAuth => 'Autentifikatsiya';

  @override
  String get swaggerAuthKind_none => 'Yoʻq';

  @override
  String get swaggerAuthKind_bearer => 'Bearer token';

  @override
  String get swaggerAuthKind_header => 'Sarlavhadagi API kalit';

  @override
  String get swaggerAuthKind_query => 'Soʻrovdagi API kalit';

  @override
  String get swaggerAuthKind_basic => 'Basic';

  @override
  String get swaggerAuthName => 'Sarlavha yoki parametr nomi';

  @override
  String get swaggerAuthValue => 'Token';

  @override
  String get swaggerAuthValueBasic => 'foydalanuvchi:parol yoki Basic token';

  @override
  String get swaggerAuthHint =>
      'Test akkauntining tokenini ishlating, hech qachon shaxsiy yoki production tokenini emas. U muhrlanadi, boshqa koʻrsatilmaydi va tiket yopilganda oʻchiriladi.';

  @override
  String swaggerAuthFromSpec(String schemes) {
    return 'Spetsifikatsiyada: $schemes';
  }

  @override
  String get swaggerWrite => 'Soʻrovlar';

  @override
  String get swaggerWriteOff => 'Faqat oʻqish';

  @override
  String get swaggerWriteOffHint => 'Faqat GET, HEAD va OPTIONS';

  @override
  String get swaggerWriteOn => 'Yozish soʻrovlari ham';

  @override
  String get swaggerWriteOnHint => 'POST, PUT, PATCH va DELETE ham';

  @override
  String swaggerWriteConfirm(String url) {
    return 'Tasdiqlayman: $url production emas';
  }

  @override
  String get swaggerWriteConfirmNeeded => 'Yozish soʻrovlarini yuborish uchun asosiy URL production emasligini tasdiqlang.';

  @override
  String get swaggerReadOnlyNote =>
      '«Faqat oʻqish» — bu faqat GET, HEAD va OPTIONS degani, «zararsiz» degani emas: baʼzi API\'lar GET\'da ham maʼlumotni oʻzgartiradi. Qaror sizniki.';

  @override
  String get swaggerLockoutNote =>
      'Tokensiz va notoʻgʻri token bilan tekshiruvlar fayrvolga kirishga hujumdek koʻrinishi mumkin. Test bunday soʻrovlardan koʻpi bilan 3 tasini yuboradi, lekin baribir test akkauntini yoki yuboruvchi manzilini bloklatishi mumkin. Xususiy tarmoq ortida bu manzil — ish maydonining VPN ulanishi, undan GitLab va boshqa testlar ham foydalanadi.';

  @override
  String get swaggerRepository => 'Repozitoriy (ixtiyoriy)';

  @override
  String get swaggerRepositoryHint =>
      'U bilan agnts nosozliklarni tushuntirish uchun handlerlarni oʻqiydi, nosozliklarni esa Bug yoki Code tiketiga aylantirish mumkin.';

  @override
  String get swaggerNoRepo => 'Repozitoriysiz';

  @override
  String get swaggerNotes => 'Izohlar';

  @override
  String get swaggerNotesPh => 'Masalan: 42-foydalanuvchi — test akkaunti; buyurtmalarga mavjud mahsulot id\'si kerak';

  @override
  String get swaggerLimits => 'Cheklovlar';

  @override
  String get swaggerRate => 'Soniyasiga soʻrovlar';

  @override
  String get swaggerMaxRequests => 'Bir ishga tushirishdagi soʻrovlar';

  @override
  String get swaggerStart => 'Boshlash';

  @override
  String get swaggerStartNow => 'Hozir';

  @override
  String get swaggerStartQueue => 'Navbatda qoldirish';

  @override
  String get swaggerCreate => 'Test yaratish';

  @override
  String get swaggerCreateStart => 'Yaratish va boshlash';

  @override
  String swaggerCreated(String key) {
    return '$key yaratildi';
  }

  @override
  String get swaggerNeedSpec => 'Avval spetsifikatsiyani oʻqing.';

  @override
  String get swaggerNeedToken => 'Tokenni kiriting.';

  @override
  String get swaggerClaudeOnly =>
      'Swagger testlari ish maydoni qaysi model bilan kod yozishidan qatʼi nazar, doim Muse\'ning yengil modelida bajariladi.';

  @override
  String get swaggerTab => 'API natijalari';

  @override
  String get swaggerRequestsTab => 'Soʻrovlar';

  @override
  String get swaggerNoRun => 'Hali natija yoʻq: test bajarilmoqda yoki hali ishga tushmagan.';

  @override
  String get swaggerVerdict_pass => 'Oʻtdi';

  @override
  String get swaggerVerdict_fail => 'Nosoz';

  @override
  String get swaggerVerdict_skipped => 'Oʻtkazib yuborildi';

  @override
  String get swaggerVerdict_blocked => 'Bajarilmadi';

  @override
  String swaggerCount_pass(String n) {
    return '$n ta oʻtdi';
  }

  @override
  String swaggerCount_fail(String n) {
    return '$n ta nosoz';
  }

  @override
  String swaggerCount_skipped(String n) {
    return '$n ta oʻtkazib yuborildi';
  }

  @override
  String swaggerCount_blocked(String n) {
    return '$n ta bajarilmadi';
  }

  @override
  String get swaggerColEndpoint => 'Endpoint';

  @override
  String get swaggerColCases => 'Tekshiruvlar';

  @override
  String get swaggerColResult => 'Natija';

  @override
  String get swaggerAgntsCheck => 'agnts tekshiruvi';

  @override
  String get swaggerAgntsCheckHint => 'agnts bu javobni spetsifikatsiya sxemasi bilan oʻzi solishtirdi';

  @override
  String swaggerExpected(String text) {
    return 'Kutilgan: $text';
  }

  @override
  String get swaggerRequestLabel => 'Soʻrov';

  @override
  String get swaggerResponseLabel => 'Javob';

  @override
  String get swaggerNoResponse => 'Javob yoʻq';

  @override
  String get swaggerTruncated => 'Tana 64 KB gacha qisqartirildi';

  @override
  String get swaggerCopyCurl => 'curl sifatida nusxalash';

  @override
  String get swaggerCopied => 'Nusxalandi';

  @override
  String get swaggerLoading => 'Yuklanmoqda…';

  @override
  String get swaggerCreateBug => 'Bug tiketini yaratish';

  @override
  String swaggerBugTitle(String key) {
    return '$key topgan API nosozliklarini tuzatish';
  }

  @override
  String swaggerBugIntro(String key, String base) {
    return '$base uchun $key Swagger testi quyidagi nosozliklarni topdi:';
  }

  @override
  String swaggerBugCreated(String key) {
    return '$key yaratildi';
  }

  @override
  String swaggerNewFailures(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ta yangi nosozlik');
    return 'Oxirgi ishga tushirishdan beri $_temp0';
  }

  @override
  String get swaggerNoNewFailures => 'Oxirgi ishga tushirishdan beri yangi nosozlik yoʻq';

  @override
  String swaggerPrevious(String passed, String failed) {
    return 'Oxirgi ishga tushirish: $passed ta oʻtdi, $failed ta nosoz';
  }

  @override
  String get swaggerRerun => 'Qayta ishga tushirish';

  @override
  String get swaggerRerunToken => 'Yangi token (ixtiyoriy)';

  @override
  String get swaggerRerunTokenNeeded => 'Yangi token (majburiy: eskisi tiket yopilganda oʻchirilgan)';

  @override
  String get swaggerRerunStarted => 'Qayta ishga tushirildi';

  @override
  String swaggerRerunNew(String key) {
    return '$key sifatida qayta ishga tushirildi';
  }

  @override
  String get swaggerModeRead => 'faqat oʻqish';

  @override
  String get swaggerModeWrite => 'yozish soʻrovlari yoqilgan';

  @override
  String get swaggerTokenStored => 'token saqlangan';

  @override
  String get swaggerTokenGone => 'token yoʻq';

  @override
  String get swaggerAgntsNotes => 'agnts nimani tuzatdi';

  @override
  String get swaggerAllPassed => 'Barcha tekshiruvlar oʻtdi.';

  @override
  String get swaggerRunningTitle => 'API tekshirilmoqda';

  @override
  String get swaggerRunningSub =>
      'agnts tekshiruvlarni tuzib, asosiy URL ga haqiqiy soʻrovlar yubormoqda. Ishga tushirish tugagach, natijalar shu yerda chiqadi.';

  @override
  String get swaggerQueuedTitle => 'Swagger testi navbatda';

  @override
  String get swaggerQueuedSub => 'Tayyor boʻlganingizda ishga tushiring.';

  @override
  String get swaggerSuites => 'Swagger toʻplamlari';

  @override
  String get swaggerSuitesLede =>
      'Jadval boʻyicha yoki har bir deploydan keyin qayta ishga tushadigan saqlangan Swagger testlari. Har bir ishga tushirish — yangi tiket: u toʻplamning oxirgi ishga tushirishi bilan solishtiriladi va uning rejasidan foydalanadi, shuning uchun takroriy ishga tushirishlar kamroq qadam sarflaydi.';

  @override
  String get swaggerSuitesEmpty => 'Hali toʻplam yoʻq. Tugagan Swagger testini oching va uni toʻplam sifatida saqlang.';

  @override
  String get swaggerSaveSuite => 'Toʻplam sifatida saqlash';

  @override
  String get swaggerSaveSuiteHint =>
      'Bu testni jadval boʻyicha yoki har bir deploydan keyin qayta ishga tushirish. Toʻplamda tokenning oʻz nusxasi saqlanadi.';

  @override
  String get swaggerSuiteName => 'Nomi';

  @override
  String get swaggerSchedule => 'Jadval';

  @override
  String get swaggerSchedule_off => 'Qoʻlda yoki deploy hooki bilan';

  @override
  String get swaggerSchedule_hourly => 'Har soatda';

  @override
  String get swaggerSchedule_daily => 'Har kuni';

  @override
  String get swaggerSchedule_weekly => 'Har dushanba';

  @override
  String get swaggerHourUtc => 'Soat (UTC)';

  @override
  String swaggerSuiteSaved(String name) {
    return '$name toʻplami sifatida saqlandi';
  }

  @override
  String get swaggerRunNow => 'Hozir ishga tushirish';

  @override
  String swaggerRunStarted(String key) {
    return '$key ishga tushirildi';
  }

  @override
  String get swaggerBusy => 'Oxirgi ishga tushirish hali davom etmoqda';

  @override
  String get swaggerPause => 'Toʻxtatib turish';

  @override
  String get swaggerResume => 'Davom ettirish';

  @override
  String get swaggerPaused => 'Toʻxtatilgan';

  @override
  String get swaggerDeleteSuite => 'Oʻchirish';

  @override
  String swaggerDeleteConfirm(String name) {
    return '$name toʻplami oʻchirilsinmi? Oldingi ishga tushirishlar qoladi.';
  }

  @override
  String get swaggerHookCreate => 'Deploy hookini yaratish';

  @override
  String get swaggerHookRotate => 'Yangi deploy hooki';

  @override
  String get swaggerHookHint =>
      'Har bir deploydan keyin toʻplamni ishga tushirish uchun deploy pipeline\'ingizdan bu URL ga tanasiz POST yuboring. U bir marta koʻrsatiladi; yangisi eskisini oʻchiradi.';

  @override
  String swaggerHookExample(String url) {
    return 'curl -X POST $url';
  }

  @override
  String get swaggerLastRun => 'Oxirgi ishga tushirish';

  @override
  String get swaggerNextRun => 'Keyingi ishga tushirish';

  @override
  String get swaggerNever => 'hech qachon';

  @override
  String get swaggerColSuite => 'Toʻplam';

  @override
  String get swaggerColSchedule => 'Jadval';

  @override
  String get swaggerColLast => 'Oxirgi ishga tushirish';

  @override
  String get swaggerSuiteToken => 'Yangi token (ixtiyoriy)';

  @override
  String get swaggerSetToken => 'Tokenni oʻrnatish';

  @override
  String get swaggerSpecAuth => 'Spetsifikatsiya havolasiga kirish kerak';

  @override
  String get swaggerSpecAuthHint => 'Spetsifikatsiyani yuklashda faqat uning xostiga yuboriladi va saqlanmaydi.';

  @override
  String get swaggerSpecAuthNeeded => 'Spetsifikatsiya manzili 401/403 javob berdi: kerakli tokenni kiriting va qayta oʻqing.';

  @override
  String get swaggerSpecAuthReused => 'API soʻrovlari ham shu token bilan yuboriladi. Boshqasi kerak boʻlsa, shu yerda oʻzgartiring.';

  @override
  String get swaggerSpecAuthLogin => 'Login va parol';

  @override
  String get swaggerSpecAuthToken => 'Token';

  @override
  String get swaggerSpecLogin => 'Login';

  @override
  String get swaggerSpecPassword => 'Parol';

  @override
  String get swaggerSpecLoginNeeded => 'Spetsifikatsiya havolasi login va parol soʻramoqda: ularni kiriting va qayta oʻqing.';

  @override
  String get swaggerSpecLoginHint =>
      'Faqat spetsifikatsiya havolasini ochish uchun kerak va saqlanmaydi. Agentning API soʻrovlari quyidagi «Autentifikatsiya» boʻlimidagi token bilan yuboriladi.';

  @override
  String get swaggerFilterProblems => 'Nosoz va bajarilmaganlar';

  @override
  String get swaggerFilterAll => 'Barcha tekshiruvlar';

  @override
  String get swaggerNothingToShow => 'Nosoz yoki bajarilmagan tekshiruv yoʻq. Qolganlarini koʻrish uchun barcha tekshiruvlarni oching.';

  @override
  String swaggerCasesHidden(num n) {
    return 'Nosozligi yoʻq $n ta endpoint yashirilgan';
  }

  @override
  String get swaggerWhatToTest => 'Nimani tekshirish kerak';

  @override
  String get swaggerWhatToTestPh =>
      'Masalan: faqat /v1/orders va /v1/payments dagi POST endpointlar; validatsiya xatolari va mavjud boʻlmagan id\'larni tekshiring. 42-foydalanuvchi — test akkaunti.';

  @override
  String get swaggerWhatToTestHint =>
      'agnts faqat shu yerda yozganingizni tekshiradi. Aniq endpointlarni tekshirish uchun ularni quyida belgilang.';

  @override
  String get swaggerWhatToTestNeeded => 'Nimani tekshirishni yozing yoki tekshiriladigan endpointlarni belgilang.';

  @override
  String get swaggerEndpointsOptional => 'Endpointlarni tanlash (ixtiyoriy)';

  @override
  String get swaggerEndpointsOptionalHint =>
      'Belgilangan endpointlar aynan belgilangandek tekshiriladi. Hech biri belgilanmasa, nimani tekshirishni yuqoridagi matn hal qiladi.';

  @override
  String get swaggerSuggested => 'Tavsiya etilganlar';

  @override
  String get swaggerNoneTicked => 'hech biri belgilanmagan: yuqoridagi matn hal qiladi';

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
  String get tasksTicketNumber => 'Vazifa raqami';

  @override
  String get tasksTicketNumberPh => 'Masalan: AMANAT-2288';

  @override
  String get tasksTicketNumberHelp =>
      'Ixtiyoriy. Jamoangizdagi bu ish raqami; branch va commit nomlarida vazifa kaliti o‘rniga ishlatiladi.';

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
  String ticketUpdateTitle(String source) {
    return 'agnts boshlagandan keyin ${source}da oʻzgardi';
  }

  @override
  String get ticketUpdateSub =>
      'agnts boshlagan versiyasi ustida ishlashda davom etadi. Qilingan ishni tashlab, yangi versiyadan qayta boshlash uchun qayta ishga tushiring yoki joriy versiya bilan davom eting.';

  @override
  String ticketUpdateNow(String when) {
    return 'Yangi versiya, $when';
  }

  @override
  String get ticketUpdateRestart => 'Yangi versiya bilan qayta boshlash';

  @override
  String get ticketUpdateKeep => 'Joriy versiyani qoldirish';

  @override
  String ticketUpdateRestartConfirm(String key, String source) {
    return '$key ${source}dagi yangi versiya bilan qayta boshlansinmi? Hozirgacha qilingan tahlil, javoblar, commitlar va koʻrib chiqishlar tashlanadi va agnts qaytadan boshlaydi.';
  }

  @override
  String get ticketUpdatePushed =>
      'Allaqachon yuborilgan: qayta boshlab boʻlmaydi. agnts vazifani qayta olishi uchun tiketni rad eting yoki joriy versiyani qoldiring.';

  @override
  String ticketUpdateRestarted(String key) {
    return '$key yangi versiya bilan qayta boshlanmoqda';
  }

  @override
  String get ticketUpdateKept => 'agnts joriy versiya ustida ishlashda davom etadi';

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
    return '$key boʻyicha barcha ish toʻxtatilsinmi? Keyin davom ettirish mumkin.';
  }

  @override
  String ticketRejectPushingConfirm(String key) {
    return '$key yuborilishi toʻxtatilsinmi? Git xostingga yetib borgan narsalar u yerda qoladi. Keyin davom ettirish mumkin.';
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
  String get ticketDraftSaving => 'Qoralama saqlanmoqda…';

  @override
  String get ticketDraftSaved => 'Qoralama saqlandi';

  @override
  String get ticketDraftFailed => 'Qoralama saqlanmadi, yana urinib ko‘ramiz';

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
  String get ticketChecksSkipped => 'Bu vazifa uchun oʻtkazib yuborildi';

  @override
  String get ticketSkipChecks => 'Tekshiruvlarni oʻtkazib yuborish: faqat kod boʻyicha koʻrib chiqish';

  @override
  String get ticketSkipChecksHint =>
      'Konteynerda ishga tushirib boʻlmaydigan tekshiruvlar uchun, masalan, u yopiq bogʻliqlikni yuklab ololmasa. Muse ham build, lint va testlarni ishga tushirmaydi, shuning uchun kodni oʻzingiz tekshirasiz. Belgini olib tashlamaguningizcha bu vazifa uchun amal qiladi.';

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
  String get ticketDiffReposLabel => 'Repozitoriylar boʻyicha oʻzgarishlar';

  @override
  String get ticketDiffOtherRepo => 'Boshqa fayllar';

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
  String get ticketRejectedSubContinue => 'agnts bu tiket ustida ishlashni toʻxtatdi. Ishni toʻxtagan joyidan davom ettirish mumkin.';

  @override
  String get ticketContinue => 'Davom ettirish';

  @override
  String get ticketContinueNote => 'agnts uchun izoh';

  @override
  String get ticketContinueNoteHint => 'Ixtiyoriy. Nimani boshqacha qilish kerak; keyingi ish uni soʻralgan oʻzgarishlar kabi oladi.';

  @override
  String get ticketContinueToNew => 'Tiket navbatga qaytadi va qayta tahlil qilinadi.';

  @override
  String get ticketContinueToAnswers => 'Tiket savollariga qaytadi; berilgan javoblar saqlanadi.';

  @override
  String get ticketContinueToCoding => 'agnts kodni toʻxtagan joyidan yozishda davom etadi.';

  @override
  String get ticketContinueToReview => 'Tiket reviewga qaytadi. Izoh boʻlsa, agnts avval oʻzgarishlarni kiritadi.';

  @override
  String get ticketContinueToFailed => 'Tiket toʻxtagan xatosiga qaytadi, uni qayta urinish mumkin.';

  @override
  String get ticketContinueToRateLimited => 'Tiket yana tarif limitini kutadi.';

  @override
  String get ticketStartOver => 'Qaytadan boshlash';

  @override
  String ticketStartOverConfirm(String key) {
    return '$key qaytadan boshlansinmi? Tahlil, javoblar va commitlar oʻchiriladi va agnts tiketni qayta tahlil qiladi.';
  }

  @override
  String get ticketFailedTitle => 'agnts toʻxtadi';

  @override
  String get ticketFailedUnknown => 'Ish toʻxtadi. Tafsilotlar ish logida.';

  @override
  String get ticketRetryNote => 'Qayta urinish uchun izoh';

  @override
  String get ticketRetryNoteHint => 'Ixtiyoriy. Xatoni qanday chetlab oʻtishni agnts ga yozing; keyingi ish uni xato bilan birga oladi.';

  @override
  String ticketSavedWork(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toʻxtatilgan ishdan $count ta tugallanmagan oʻzgartirilgan fayl qoldi.',
      one: 'Toʻxtatilgan ishdan $count ta tugallanmagan oʻzgartirilgan fayl qoldi.',
    );
    return '$_temp0 Keyingi ish uni toʻxtagan joyidan davom ettiradi.';
  }

  @override
  String get ticketSavedWorkFiles => 'Fayllarni koʻrsatish';

  @override
  String get ticketDiscardWork => 'Tugallanmagan oʻzgarishlarni bekor qilish';

  @override
  String get ticketDiscardWorkHint =>
      'Shunda keyingi ish oxirgi commitdan boshlanadi. Toʻxtatilgan ish notoʻgʻri yoʻldan ketgan boʻlsa foydalaning.';

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
  String get ticketBranchRename => 'Nomini oʻzgartirish';

  @override
  String get ticketBranchRenameHint => 'Pull request shu nomdagi branchdan ochiladi. Harflar, raqamlar, - _ . va /; boʻshliqsiz.';

  @override
  String get ticketNumberEdit => 'Oʻzgartirish';

  @override
  String get ticketNumberSet => 'Belgilash';

  @override
  String get ticketNumberHint =>
      'Yangi branch va commitlar shuni ishlatadi. Mavjudlari nomini saqlaydi: branchni qayta nomlang yoki commit formatini qayta qoʻllang. Boʻsh boʻlsa, kalit ishlatiladi.';

  @override
  String get ticketCommitsTitle => 'Kommitlar';

  @override
  String get ticketCommitsSub => 'agnts ularni siz tasdiqlaganingizda yuboradi. Ungacha xabarlarini oʻzgartirishingiz mumkin.';

  @override
  String get ticketCommitEdit => 'Xabarni tahrirlash';

  @override
  String get ticketCommitEditHint =>
      'Birinchi qatorda sarlavha, keyin boʻsh qator va tavsif. Oldingi kommitni oʻzgartirsangiz, undan keyingilari xuddi shu oʻzgarishlar bilan qaytadan yaratiladi.';

  @override
  String get ticketCommitsReapply => 'Formatni qayta qoʻllash';

  @override
  String get ticketCommitsReapplyHelp =>
      'Bu xabarlarni kommit xabari formati boʻyicha (guruhniki, boʻlmasa har bir repozitoriyniki) qayta yozadi; turi, sohasi va mavzusi har bir kommitni qilgan ishga tushirishdan olinadi. Oldindan koʻrib chiqing, keyin qoʻllang.';

  @override
  String ticketCommitsNumber(String number) {
    return '$number uchun vazifa raqami';
  }

  @override
  String get ticketCommitsPreview => 'Oldindan koʻrish';

  @override
  String ticketCommitsApply(num n) {
    return '$n ta oʻzgarishni qoʻllash';
  }

  @override
  String get ticketCommitsUpToDate => 'Xabarlar formatga allaqachon mos keladi.';

  @override
  String get ticketCommitsNotSuggested => 'Belgilanmagan: bu xabar qoʻlda yozilgan boʻlishi mumkin, qoʻllash uni almashtiradi.';

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
  String get ticketFactsTicket => 'Tiket';

  @override
  String get ticketFactsCode => 'Kod';

  @override
  String get ticketFactsPeople => 'Odamlar';

  @override
  String get ticketFactsLinks => 'Bogʻliq tiketlar';

  @override
  String get ticketFactsRuns => 'Ishga tushirishlar';

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
  String get ticketCopyQuestions => 'Savollarni nusxalash';

  @override
  String get ticketOtherAnswer => 'Boshqa narsa (ixtiyoriy)';

  @override
  String get ticketSrcGit => 'Pull request';

  @override
  String get ticketSrcCi => 'CI yiqilishi';

  @override
  String get ticketKvCi => 'CI';

  @override
  String ticketCiFixes(num n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n marta', one: '$n marta');
    return 'CI pull requestni $_temp0 qaytardi';
  }

  @override
  String get ticketMuseMeter => 'Ushbu ish uchun Muse sarfi';

  @override
  String ticketMuseSpentOf(String spent, String limit) {
    return '$limit dan $spent';
  }

  @override
  String ticketMuseCalls(num n) {
    return '$n ta chaqiruv';
  }

  @override
  String ticketMuseCharged(String amount) {
    return '$amount yechildi';
  }

  @override
  String get ticketMuseSteered => 'Byudjet kam: yakunlash buyurildi';

  @override
  String get ticketMuseStopped => 'Byudjet tugagani uchun to‘xtatildi';

  @override
  String ticketMuseEscalated(String model) {
    return '$model ga o‘tkazildi';
  }

  @override
  String get ticketsTabsLabel => 'Tiket roʻyxatlari';

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
  String get ticketsRepoLabel => 'Repozitoriy';

  @override
  String get ticketsAllRepos => 'Barcha repozitoriylar';

  @override
  String get ticketsNoRepo => 'Repozitoriysiz';

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
  String get ticketsNoMatch => 'Filtrlarga mos tiket yo\'q.';

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
  String get ticketsSourceGit => 'PR';

  @override
  String get ticketsSourceCi => 'CI';

  @override
  String get usageTitle => 'Tarif limitlari';

  @override
  String get usageLede => 'agnts Muse rejangizda ishlaydi. Bu limitlar Muse\'dan oʻzingiz foydalanishingiz bilan umumiy.';

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
  String get usageSource => 'Muse limit hodisalaridan olinadi. Ushbu hisobdagi Muse\'dan oʻzingiz foydalanishingizni ham oʻz ichiga oladi.';

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
      'Raqamlar Muse har bir ish davomida yuboradigan limit hodisalaridan olinadi. agnts boʻsh turganda kichik yangilash ishi ularni dolzarb saqlaydi.';

  @override
  String usageCardFor(String name) {
    return '$name tarifidan foydalanish';
  }

  @override
  String usageNotConnected(String name) {
    return 'Sizda $name hisobi ulanmagan, shuning uchun o‘qiladigan ma’lumot yo‘q. Uni Profilda (yoki ish maydonining hisobini ish maydoni sozlamalarida) ulang.';
  }

  @override
  String get usageMuseSource =>
      'Muse har bir ishga tushirishdan keyin xabar beradigan limitlardan (Meta obunasining 5 soatlik va haftalik oynalari). API kalitlari va kreditlarda oyna yo‘q.';

  @override
  String get usageCodexSub => 'OpenAI API kaliti';

  @override
  String get usageCodexBody =>
      'Codex ish maydonining OpenAI API kalitida ishlaydi va OpenAI har bir chaqiruv uchun haq oladi, shuning uchun kuzatiladigan tarif oynalari yo‘q. Uning ishga tushirishlari qancha turgani quyida, «Sarf boʻyicha tiketlar»da.';

  @override
  String get wsTitle => 'Ish maydoni';

  @override
  String get wsSwitcher => 'Ish maydonini almashtirish';

  @override
  String get wsAll => 'Barcha ish maydonlari';

  @override
  String get wsNew => 'Yangi ish maydoni';

  @override
  String get wsRole_owner => 'Egasi';

  @override
  String get wsRole_user => 'A’zo';

  @override
  String get wsTabGeneral => 'Umumiy';

  @override
  String get wsTabMembers => 'A’zolar';

  @override
  String get wsTabClaude => 'Claude';

  @override
  String get wsTabBilling => 'To‘lov';

  @override
  String get wsGeneral => 'Ish maydoni';

  @override
  String get wsGeneralSub => 'Nomi va havolalardagi manzili.';

  @override
  String get wsName => 'Nomi';

  @override
  String get wsSlug => 'Manzil';

  @override
  String wsSlugHelp(String slug) {
    return 'Bu ish maydoniga havolalar: /w/$slug. O‘zgartirilsa, eski havolalar ishlamay qoladi.';
  }

  @override
  String get wsSave => 'Saqlash';

  @override
  String get wsSaved => 'Ish maydoni saqlandi';

  @override
  String get wsReadOnly => 'Buni faqat egasi o‘zgartira oladi.';

  @override
  String get wsPlan => 'Tarif';

  @override
  String get wsSlots => 'Parallel ishlar';

  @override
  String get wsSlotsHelp => 'Bu ish maydoni bir vaqtda nechta ishni bajara oladi. «To‘lov» bo‘limida o‘zgartiriladi.';

  @override
  String wsTrialEnds(String date) {
    return 'Sinov muddati $date gacha';
  }

  @override
  String get wsSuspended => 'Ish maydoni to‘xtatilgan: qayta yoqilmaguncha yangi ishlar boshlanmaydi.';

  @override
  String get wsDanger => 'Xavfli zona';

  @override
  String get wsDangerSub =>
      'O‘chirish barcha ishlarni to‘xtatadi va ish maydonini, repozitoriylari nusxalarini, tiketlarni va tarixni o‘chiradi. 7 kun davomida tiklash mumkin, keyin butunlay o‘chiriladi.';

  @override
  String get wsDelete => 'Ish maydonini o‘chirish';

  @override
  String wsDeleteTitle(String name) {
    return '$name o‘chirilsinmi?';
  }

  @override
  String wsDeleteBody(String slug) {
    return 'Tasdiqlash uchun manzilni ($slug) kiriting. Hamma kirish huquqini yo‘qotadi.';
  }

  @override
  String get wsDeleted => 'Ish maydoni o‘chirildi';

  @override
  String get wsMembers => 'A’zolar';

  @override
  String get wsMembersSub =>
      'Ish maydonidagi har bir a’zo uning tiketlarini ko‘radi, ularni yaratadi, javob beradi, tekshiradi va qayta ishga tushiradi. Egasi bundan tashqari sozlamalar, integratsiyalar, Muse, a’zolar va to‘lovni boshqaradi.';

  @override
  String get wsYou => 'siz';

  @override
  String get wsRemove => 'Chiqarish';

  @override
  String wsRemoveTitle(String name) {
    return '$name chiqarilsinmi?';
  }

  @override
  String get wsRemoveBody => 'U bu ish maydoniga kira olmaydi. Uning tiketlari qoladi.';

  @override
  String wsRemoved(String name) {
    return '$name chiqarildi';
  }

  @override
  String get wsMakeOwner => 'Egasi qilish';

  @override
  String wsTransferTitle(String name) {
    return '$name egasi qilinsinmi?';
  }

  @override
  String get wsTransferBody => 'Siz a’zo bo‘lib qolasiz, lekin sozlamalar, a’zolar va to‘lovni o‘zgartira olmaysiz.';

  @override
  String wsTransferred(String name) {
    return 'Endi egasi — $name';
  }

  @override
  String get wsLeave => 'Ish maydonidan chiqish';

  @override
  String wsLeaveTitle(String name) {
    return '$name dan chiqasizmi?';
  }

  @override
  String get wsLeaveBody => 'Sizni qayta taklif qilishmaguncha kira olmaysiz.';

  @override
  String get wsOwnerCannotLeave => 'Egasi chiqib keta olmaydi: avval boshqa a’zoni ega qiling.';

  @override
  String get wsClaudeBadge => 'Claude ulangan';

  @override
  String get wsNoClaudeBadge => 'Claude yo‘q';

  @override
  String get wsInvite => 'Odamlarni taklif qilish';

  @override
  String get wsInviteSub =>
      'Havolani pochta orqali yuboring yoki o‘zingiz ulashish uchun havola yarating. Havola 7 kun va bir marta amal qiladi.';

  @override
  String get wsInviteEmail => 'Pochta (ixtiyoriy)';

  @override
  String get wsInviteSend => 'Taklif yaratish';

  @override
  String get wsInviteLink => 'Taklif havolasi (bir marta ko‘rsatiladi)';

  @override
  String wsInviteEmailed(String email) {
    return '$email manziliga yuborildi';
  }

  @override
  String get wsInviteCopy => 'Nusxa olish';

  @override
  String get wsInvites => 'Ochiq takliflar';

  @override
  String get wsInviteAnyone => 'Havolasi bor har kim';

  @override
  String wsInviteExpires(String date) {
    return '$date gacha';
  }

  @override
  String get wsRevoke => 'Bekor qilish';

  @override
  String get wsRevoked => 'Taklif bekor qilindi';

  @override
  String wsMemberLimit(String n, String limit) {
    return '$limit tadan $n ta a’zo';
  }

  @override
  String wsMemberLimitNone(num n) {
    return '$n ta a’zo';
  }

  @override
  String get wsClaude => 'Claude';

  @override
  String get wsClaudeSub => 'Bu ish maydonidagi ishlar qaysi Claude hisobidan foydalanadi.';

  @override
  String get wsMode => 'Rejim';

  @override
  String get wsModeShared => 'Umumiy';

  @override
  String get wsModeSharedHelp => 'Barcha ishlar egasi ulagan ish maydoni hisobidan foydalanadi.';

  @override
  String get wsModeMember => 'Har kimniki o‘zi';

  @override
  String get wsModeMemberHelp => 'Har bir ish tiket egasi bo‘lgan a’zoning hisobidan foydalanadi. A’zolar o‘z hisobini profilda ulaydi.';

  @override
  String get wsConnection => 'Ish maydoni hisobi';

  @override
  String get wsConnectionSub => 'Umumiy rejimda barcha ishlar shundan foydalanadi.';

  @override
  String get wsKind => 'Turi';

  @override
  String get wsKindSubscription => 'Claude obunasi';

  @override
  String get wsKindApiKey => 'Anthropic API kaliti';

  @override
  String get wsKindSubscriptionHelp => 'Claude tarifingizga kirgan joyda `claude setup-token` buyrug‘ini bajaring va tokenni joylang.';

  @override
  String get wsKindApiKeyHelp => 'Anthropic Console’da kalit yarating (sk-ant-api…). Sarfni kalit egasi to‘laydi.';

  @override
  String get wsKeyStep1 => 'Claude Console’ga kiring (pastdagi tugma) va Settings → API keys bo‘limini oching.';

  @override
  String get wsKeyStep2 =>
      'Create Key tugmasini bosing, kalitga nom bering (masalan, agnts) va xarajat yoziladigan Console ish maydonini tanlang.';

  @override
  String get wsKeyStep3 => 'Kalitni nusxalang (u sk-ant-api bilan boshlanadi) va pastga joylang. Console uni faqat bir marta ko‘rsatadi.';

  @override
  String get wsKeyStep4 =>
      'Ishga tushirishlar shu Console hisobidan token bo‘yicha to‘lanadi: Billing bo‘limida balansni to‘ldiring va xarajat chegarasini qo‘ying.';

  @override
  String get wsKeyOpen => 'Claude Console’ni ochish';

  @override
  String get wsSubscriptionsOff => 'Bu server faqat Anthropic API kalitlarini qabul qiladi.';

  @override
  String get wsToken => 'Token';

  @override
  String get wsConnect => 'Ulash';

  @override
  String get wsReplace => 'Almashtirish';

  @override
  String get wsDisconnect => 'Uzish';

  @override
  String get wsConnected => 'Ulangan';

  @override
  String get wsNotConnected => 'Ulanmagan';

  @override
  String wsPausedUntil(String time) {
    return '$time gacha limitga yetgan';
  }

  @override
  String wsConnectedAs(String account, String hint) {
    return '$account · …$hint';
  }

  @override
  String get wsFallback => 'Kreditlar hisobidan davom etish';

  @override
  String get wsFallbackHelp =>
      'Tanlangan hisob limitga yetganda yoki ulanmaganda ishlar to‘xtab qolmaydi: agnts API kaliti bilan davom etadi va ish maydoni kreditlarini sarflaydi.';

  @override
  String get wsFallbackOff => 'Bu serverda kreditlar mavjud emas.';

  @override
  String wsCredits(num n) {
    return '$n kredit';
  }

  @override
  String get wsDefaultMember => 'Muallifsiz tiketlar';

  @override
  String get wsDefaultMemberHelp =>
      'Jira, Plane’dan kelgan tiketlar, keyingi vazifalar va hodisalar «har kimniki o‘zi» rejimida shu a’zoning hisobidan bajariladi.';

  @override
  String get wsDefaultOwner => 'Egasi';

  @override
  String get wsMemberAccounts => 'A’zolar hisoblari';

  @override
  String get wsMemberAccountsSub => 'Kim o‘z Claude hisobini ulagan (Profil → Claude).';

  @override
  String get wsYourAccount => 'O‘zingiznikini profilda ulang';

  @override
  String get wsClaudeSaved => 'Claude sozlamalari saqlandi';

  @override
  String get wsRole_viewer => 'Kuzatuvchi';

  @override
  String get wsViewerBanner => 'Siz bu yerda kuzatuvchisiz: hammasini ko\'rasiz, lekin hech narsani o\'zgartira olmaysiz.';

  @override
  String get wsInviteAs => 'Rol';

  @override
  String get wsInviteAsHelp => 'A\'zolar tiketlar ustida ishlaydi; kuzatuvchilar faqat ko\'radi.';

  @override
  String wsRoleChanged(String name, String role) {
    return '$name endi: $role';
  }

  @override
  String wsRoleLabel(String name) {
    return '$name roli';
  }

  @override
  String get wsTabMuse => 'Muse';

  @override
  String get wsClaudeMuse => 'Muse';

  @override
  String get wsClaudeSubMuse => 'Bu ish maydonidagi ishlar qaysi Muse hisobidan foydalanadi.';

  @override
  String get wsClaudeSavedMuse => 'Muse sozlamalari saqlandi';

  @override
  String get wsFallbackHelpMuse =>
      'Tanlangan hisob ulanmagan yoki byudjeti tugagan bo‘lsa, ishlar to‘xtab qolmaydi: agnts’ning Muse kaliti bilan davom etadi va avval bepul kreditlaringizni, keyin ish maydoni kreditlarini sarflaydi.';

  @override
  String get wsMemberAccountsSubMuse => 'Kim o‘z Muse hisobini ulagan (Profil → Muse).';

  @override
  String get wsMuseBadge => 'Muse ulangan';

  @override
  String get wsNoMuseBadge => 'Muse yo‘q';

  @override
  String get wsKindMuseLogin => 'Meta hisobi';

  @override
  String get wsKindMuseApiKey => 'Muse API kaliti';

  @override
  String get wsMuseSignIn => 'Meta orqali kirish';

  @override
  String get wsMuseSignInHelp =>
      'Meta sahifasida tasdiqlash uchun kod ko‘rsatiladi; shundan so‘ng ishlar shu Meta hisobining Muse’idan foydalanadi.';

  @override
  String get wsMuseCode => 'Bu kodni Meta sahifasiga kiriting';

  @override
  String get wsMuseCopyCode => 'Kodni nusxalash';

  @override
  String get wsMuseOpenMeta => 'Meta’ni ochish';

  @override
  String get wsMuseWaiting => 'Tasdiqlashingizni kutyapmiz…';

  @override
  String wsMuseExpires(String time) {
    return 'Kod $time gacha amal qiladi.';
  }

  @override
  String get wsMuse_denied => 'Kirish Meta sahifasida rad etildi.';

  @override
  String get wsMuse_expired => 'Kod tasdiqlanmasdan muddati tugadi.';

  @override
  String get wsMuse_failed => 'Kirish amalga oshmadi.';

  @override
  String get wsMuseTryAgain => 'Qayta urinish';

  @override
  String get wsMuseUseKey => 'API kalitidan foydalanish';

  @override
  String get wsMuseKeyHelp => 'Muse API kalitini joylang (LLM_ bilan boshlanadi). Sarfni Meta’da kalit egasi to‘laydi.';

  @override
  String get wsClaudeBoth => 'Hisoblar';

  @override
  String get wsClaudeSubBoth => 'Bu ish maydonidagi ishlar qaysi Muse va Claude hisoblaridan foydalanadi.';

  @override
  String get wsClaudeSavedBoth => 'Hisob sozlamalari saqlandi';

  @override
  String get wsFallbackHelpBoth =>
      'Tanlangan hisob limitga yetganda yoki ulanmaganda ishlar to‘xtab qolmaydi: agnts kaliti bilan davom etadi va kreditlarni sarflaydi.';

  @override
  String get wsMemberAccountsSubBoth => 'Kim o‘z Muse va Claude hisoblarini ulagan (Profil).';

  @override
  String get wsConnectionMuse => 'Ish maydonining Muse hisobi';

  @override
  String get wsConnectionClaude => 'Ish maydonining Claude hisobi';

  @override
  String get wsNoAccountModules =>
      'Modullaringiz uchun bu yerda ulanadigan hisob yo‘q: Codex ish maydonining OpenAI integratsiyasi orqali ishlaydi.';

  @override
  String get wsCodexSub => 'Ish maydonining OpenAI API kalitida ishlaydi';

  @override
  String get wsCodexKey => 'OpenAI API kaliti';

  @override
  String get wsCodexConnected => 'Ulangan';

  @override
  String get wsCodexNotConnected => 'Ulanmagan: Codex ishga tushirishlari u ulanguncha kutadi';

  @override
  String get wsCodexConnect => 'OpenAI ni ulash';

  @override
  String get wsCodexManage => 'OpenAI sozlamalari';

  @override
  String get wsCodexCredits =>
      'OpenAI Codex ishga tushirishlari uchun to‘g‘ridan-to‘g‘ri, har bir chaqiruv uchun haq oladi. Ular ish maydoni kreditlarini sarflamaydi, kreditlar bilan davom ettirish ularga taalluqli emas.';
}
