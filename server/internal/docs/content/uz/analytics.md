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
