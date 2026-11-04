# Analitika

agnts vaqt oʻtishi bilan siz uchun qanchalik yaxshi ishlayotgani. 7, 30 yoki 90 kunni tanlang; har bir raqam oldingi davr bilan solishtiriladi, yashil oʻzgarishlar — yaxshilanish. Sahifada oltita boʻlim bor, **CSV eksport** ochiq boʻlimning asosiy jadvalini saqlaydi.

## Umumiy

Avval xulosalar: raqamlardan chiqarilgan qisqa xulosalar va nimani oʻzgartirish kerakligi. Soʻng asosiy raqamlar (yuborilgan tiketlar, muvaffaqiyat ulushi, birinchi urinishda tasdiqlash, birlashtirilgan pull requestlar, sizni kutish vaqti, yuborilgan tiket narxi), kunlik tiketlar va ular qanday tugagani, hamda agnts kunning qaysi soatlarida ishlashi.

## Yetkazish

agnts yuborgandan keyin nima boʻladi. **Pull requestlar natijasi**: davrda ochilgan, birlashtirilgan, birlashtirilmasdan yopilgan va hali ochiq pull requestlar hamda birlashtirish ulushi (birlashtirilgan yoki yopilganlar ichida birlashtirilganlar). Bir haftadan ortiq ochiq turganlar alohida koʻrsatiladi. **Sikl vaqti**: tiketni olishdan yuborish va birlashtirishgacha odatiy vaqt. **Savollar**: nechta tiket koddan oldin savol bergani va javob qancha vaqt olishi. **Eng sekin tiketlar** vaqt qayerga ketganini koʻrsatadi: agnts ishi, javob kutish, tekshiruv kutish yoki navbat. Vaqtlar — mediana; sekin qiymat — oʻntadan eng sekini.

Birlashtirish va yopishlar git xostingining webhookidan keladi. Webhook boʻlmasa, agnts ochiq pull requestlarni xostingda oʻzi tekshiradi.

## Sifat

Tiketga qadamlar, ishlar nega toʻxtashi, prompt versiyalari boʻyicha agent sifati va takroriy natijalar. **CI holati** (CI kuzatuvi yoqilgan boʻlsa): kunlik xatolar sabablari boʻyicha, agnts oʻzi nechtasini va qanchalik tez tuzatgani, eng beqaror vazifalar hamda agnts pull requestlaridagi tekshiruvingizdan oldin tuzatilgan qizil tekshiruvlar.

**Prompt versiyalari boʻyicha cheklovlar**: agnts-guard rad etgan harakatlar, toʻxtash tekshiruvi qutqargan tasklar, tiqilishlar, isbotlangan tuzatishlar, odamlar qabul qilgan review izohlari ulushi, tayyor taskka tokenlar va faktlarni tekshirish guruhining birinchi urinishdagi ulushi umumiysi yonida.

## Oʻrganish

agnts fikringizdan oʻrganayaptimi: yozilgan va oʻrganilgan darslar, tiketlardan taklif qilingan va qabul qilingan qoidalar, siz yozgan qoidalar, oʻzgartirilgan yoki rad etilgan tiketlar tahlili, taklif qilingan qoʻshimcha vazifalarning qabul ulushi (tur va ularni topgan bosqich boʻyicha) va eng koʻp izoh qoldirgan tekshiruvchilar.

## Xarajat

Davrda Claude ishlatgan tokenlar, kunlik kirish va chiqish, kesh alohida; bosqichlar va modellar boʻyicha xarajat; yuborilgan tiket narxi va tarifdan kunlik eng yuqori foydalanish. Dollar summasi — Claude Code ning API narxlaridagi hisobi; Claude tarifida u undirilmaydi.

## Repozitoriylar

Har bir repozitoriy qanday ishlaydi: tiketlar, muvaffaqiyat ulushi, birlashtirish ulushi, qadamlar, agnts vaqti, tiketga savollar, CI xatolari va CLAUDE.md bormi.

## Dasturchilar

Bu bo'limni faqat ish maydoni egasi ko'radi va faqat **Sozlamalar → Ishni baholash** yoqilganda. Odatda u o'chiq: xodimlarni avtomatik baholash GDPR ning 22-moddasiga tushadi, ba'zi mamlakatlarda xodimlar kengashi roziligi kerak. Raqamlar sizning baholashingiz uchun ma'lumot, hukm emas.

Har bir topshirilgan vazifa 1, 2, 3, 5, 8 yoki 13 murakkablik bahosini oladi. Vazifa agnts da bajarilganda yoki uning Jira yoki Plane vazifasi bajarildi deb yopilganda va commitlaridan biri asosiy branchda bo'lganda topshirilgan hisoblanadi. Baho o'zgarishlardan olinadi: ularni model o'qiydi, kod hisoblagan faktlar (o'zgargan qatorlar, xavfli joylar — parallellik, avtorizatsiya, pul, ma'lumot migratsiyalari) esa u qanchalik yuqori bo'lishi mumkinligini cheklaydi. Har bir muallifning ulushi u commit qilgan turli kunlar soniga bog'liq, vazifani ikki-to'rt kishi bo'lishganda har biriga kamida 20%. agnts ning o'z commitlari uning o'z qatoriga yoziladi, ularni tekshirgan kishiga emas.

Oy keyingi oyning 3-sanasida yoki baholar kelayotgan bo'lsa keyinroq (10-sanagacha) yopiladi. Yopilgan oy o'z raqamlarini saqlaydi; keyingi o'zgarishlar (qo'lda o'zgartirilgan baho, bog'langan git hisobi, tasdiqlangan regressiya) siz oyni qayta yopguningizcha qavs ichida ko'rsatiladi. Qaytarish vazifa qatorlarining qaytarilgan ulushini, har bir tasdiqlangan regressiya esa ballarining 30% ini oladi. Muallifni oching: uning topshirishlarini ko'rish, bahoni o'zgartirish yoki ma'lumotlarini ko'rish so'rovi uchun u haqda saqlangan hamma narsani yuklab olish mumkin.
