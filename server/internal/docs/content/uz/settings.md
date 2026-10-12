# Sozlamalar

agnts vositalaringizga qanday ulanadi va ish paytida qanday ishlaydi. Oʻzgarishlar «Oʻzgarishlarni saqlash»dan keyin qoʻllanadi.

## Koʻrinish

Mavzu va til. Shu brauzerda saqlanadi va darhol qoʻllanadi.

## Jira va GitHub

Tiketlar qayerdan keladi, agnts qaysi belgini oladi va commitlar kimning nomidan qilinadi.

## Claude Code

Har bir bosqichda qaysi model ishlaydi, qadamlar limiti va vaqt chegarasi, Claude Code qaysi buyruqlarni bajara oladi va qaysilarini hech qachon bajarmaydi.

**Kodni Codex da yozish** kod yozishni Claude Code oʻrniga Codex CLI da ishga tushiradi: Integratsiyalarda OpenAI ni ulang va api.openai.com ni ruxsat etilgan hostlarga qoʻshing. Codex ishga tushirishlarida agnts-guard hooklari yoʻq; ishga tushirishdan keyingi agnts tekshiruvlari odatdagidek ishlaydi.

## Ishlar

Savollar, limitdan keyin davom etish, yangi ish boshlash chegarasi va bir vaqtdagi ishlar soni uchun standart qiymatlar.

## Cheklovlar

agnts-guard Claude ishini har bir ishga tushirish ichida, jarayonning oʻzida tekshiradi; ishga tushirishdan keyingi agnts tekshiruvlari ham amal qiladi. **Profil** qatʼiylikni belgilaydi: *Minimal* maxfiy maʼlumotlar va .env fayllarini rad etadi, shablonli jamoa qoidalarini qoʻllaydi va Claude tugatishidan oldin build muvaffaqiyatli boʻlishini talab qiladi; *Standart* yana testlarni oʻtkazib yuborish va oʻchirish, linterlarni oʻchirish va tekshiruv sozlamalarini oʻzgartirishni rad etadi, toʻxtash tekshiruviga lint qoʻshadi va har bir tahrirlangan faylni tekshiradi; *Qatʼiy* yana toʻxtash tekshiruvida testlarni ishga tushiradi, yutib yuborilgan xatolar va olib tashlangan tekshiruvlarni rad etadi va tasklarning bir qismida Analitikada solishtirish uchun birinchi tahrirlardan oldin Claude dan faktlarni (faylni kim ishlatadi, buzuvchi buyruqni qanday qaytarish mumkin) soʻraydi. Odam task yoki javobda `agnts: allow skipped_test` (yoki boshqa turini) yozib, bitta rad etishni shu task uchun olib tashlaydi.

Shu yerda: ishga tushirish **tiqilib qolsa** agnts nima qiladi (belgilaydi yoki Claude ga bir marta toʻxtab oʻylashni aytadi), **Tuzatishlarni isbotlash** (oʻzgarishdan oldin yiqiladigan va keyin oʻtadigan test), **Chuqur review** (xavfsizlik, jim xatolar, testlar va turlar boʻyicha oʻtishlar; *Avto* katta yoki murakkab ish uchun), **Ishga tushirishlardan oʻrganish** (muammoli ishga tushirishlardan maslahatlar) va murakkab tasklarning tanlangan yondashuvini oʻqiydigan **Ikkinchi fikr** modeli. **Qoʻshimcha** alohida hooklarni oʻchiradi.

## Oldindan koʻrish

Oldindan koʻrish buyrugʻi bor repozitoriylarda har bir interfeys oʻzgarishining skrinshotlari, sahifalarni tanlab baholaydigan model, kod yozish jarayonlari ilovani oʻzi koʻrishi mumkinmi, va ishga tushirish konteynerlari murojaat qila oladigan qoʻshimcha hostlar (masalan ilovangizning staging API si).

## Xususiy tarmoqlar

Faqat VPN orqali ochiladigan GitLab, Jira, Plane yoki paketlar reyestri uchun oʻz tarmoqlaringizga tunnellar. Ish maydonida bir nechta boʻlishi mumkin — har bir kompaniya, ofis yoki data-markaz uchun bittadan. Har biri uchun **agnts-link** (tarmoq ichida ishga tushiriladigan kichik agent: oʻzi ulanadi, VPN maʼlumotlari kerak emas va vebhuklarni uzatadi), **WireGuard** yoki **OpenVPN** (mijoz konfiguratsiyasini joylashtiring) ni tanlang va uning marshrutlarini sanab oʻting: u orqali oʻtadigan hostlar, domenlar (.corp.local) yoki xususiy diapazonlar. Ulanish marshruti unga eng aniq mos keladigan tarmoq orqali oʻtadi: aniq host domendan, uzunroq domen qisqasidan, torroq diapazon kengidan ustun. Ikki tarmoq bir xil marshrutni koʻrsata olmaydi; boshqa tarmoq marshruti ichidagi torroq marshrut mumkin. Qolgan hammasi avvalgidek chiqadi. Hostlari ichki sertifikatlardan foydalansa, tarmoqning korporativ CA sini qoʻshing va integratsiyani ulashdan oldin **Tekshirish** bilan host:port qaysi tarmoq orqali oʻtishini koʻring. agnts vazifalaringiz uchun ishga tushiradigan kod roʻyxatdagi barcha hostlarga ulana oladi, shuning uchun faqat keraklisini yozing.

## Bildirishnomalar

Biror narsa sizni kutganda, ish toʻxtaganda yoki oʻzgarishlar yuborilganda Telegram xabarlari.

## Maxfiy maʼlumotlar

Tokenlar serveringiz muhitida saqlanadi va bu sahifada hech qachon koʻrsatilmaydi.
