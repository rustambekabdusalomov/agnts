# Swagger testlari

Swagger testi HTTP API'ni uning Swagger/OpenAPI spetsifikatsiyasi boʻyicha tekshiradi. Siz agnts'ga spetsifikatsiya, asosiy URL, endpointlar va, agar API talab qilsa, token berasiz. agnts har bir endpoint uchun tekshiruvlarni tuzadi (asosiy holat, yetishmayotgan va notoʻgʻri maydonlar, tokensiz va notoʻgʻri token bilan, mavjud boʻlmagan id'lar, sahifalash chegaralari), haqiqiy soʻrovlar yuboradi va har bir tekshiruv boʻyicha xulosa beradi — uning ortidagi soʻrov va javob bilan.

## Qanday yaratiladi

Yangi vazifa → **Swagger testi**.

- **Spetsifikatsiya**: spetsifikatsiya manzili (`…/openapi.json`, `…/swagger.json`, `…/v3/api-docs`) yoki Swagger UI, Springdoc yoki Redoc sahifasi — agnts uning ortidagi spetsifikatsiyani topadi. Faylni yuklash ham mumkin. Agar spetsifikatsiya havolasiga kirish kerak boʻlsa (401 yoki 403 javob bersa), **Spetsifikatsiya havolasiga kirish kerak** belgisini qoʻying. Havola login va parol soʻrasa, **Login va parol**ni tanlang (forma buni oʻzi ochadi): ular faqat havolani ochadi, agentning API soʻrovlari esa «Autentifikatsiya» boʻlimidagi token bilan yuboriladi. Yoki havola token qabul qilsa, **Token**ni tanlang; siz oʻzgartirmasangiz, u API tokeni ham boʻladi. Hech biri saqlanmaydi: ular yuklash bilan faqat spetsifikatsiya xostiga yuboriladi. Swagger 2.0 va OpenAPI 3.0/3.1, 5 MB gacha, bitta faylda (spetsifikatsiya ishora qilgan boshqa fayllarni agnts yuklamaydi).
- **Asosiy URL**: soʻrovlar boradigan joy. Avval bu spetsifikatsiyadagi server, u esa koʻpincha production — tekshiring. Xost nomi yoki IP, istalgan port.
- **Nimani tekshirish kerak**: qaysi endpointlarni tekshirishni va testga nima bilish kerakligini yozing («faqat /v1/orders dagi POST endpointlar; 42-foydalanuvchi — test akkaunti»). agnts faqat yozganingizni tekshiradi: ishga tushirish butun spetsifikatsiyani koʻradi, faqat siz aytgan endpointlar uchun tekshiruv tuzadi va qolganlari haqida hech narsa yozmaydi.
- **Endpointlarni tanlash (ixtiyoriy)**: avval hech narsa belgilanmagan. Aynan oʻshalarni tekshirish uchun endpointlarni belgilang; **Tavsiya etilganlar** eskirganlari va nomi nimanidir oʻzgartirishini bildiradigan GET'lardan (`logout`, `export`, `send`, `reset`, `sync` …) tashqari hammasini belgilaydi, forma esa ular nega chiqarib qoldirilganini aytadi. Testga ikkisidan biri kerak: matn yoki belgilangan endpointlar.
- **Autentifikatsiya**: yoʻq, Bearer token, sarlavha yoki soʻrovdagi API kalit, Basic. **Test akkauntining** tokenini ishlating, hech qachon shaxsiy yoki production tokenini emas.

## Faqat oʻqish va yozish

Odatda test **faqat oʻqiydi**: faqat GET, HEAD va OPTIONS yuboriladi. «Faqat oʻqish» «zararsiz» degani emas: baʼzi API'lar GET'da ham maʼlumotni oʻzgartiradi, endpointlarni belgilashda buni siz hal qilasiz. Yozish soʻrovlarini (POST, PUT, PATCH, DELETE) yoqish uchun asosiy URL production emasligini tasdiqlash kerak. Shunda agnts tekshiruvlarni yaratish → oʻqish → oʻzgartirish → oʻchirish tartibida bajaradi va yaratganini oʻchiradi.

## Akkauntlar va fayrvollar

«Tokensiz» va «notoʻgʻri token» tekshiruvlari fayrvolga kirishga hujumdek koʻrinadi. Ishga tushirish bunday soʻrovlardan koʻpi bilan 3 tasini yuboradi va uch marta 429 javobidan yoki tokenli soʻrovga 401/403 javobidan keyin toʻxtaydi. Baribir test akkaunti bloklanishi yoki manzil taqiqlanishi mumkin. Xususiy tarmoq ortida bu manzil — ish maydonining VPN ulanishi, undan GitLab va boshqa testlar ham foydalanadi.

## Ichki API'lar

Ish maydonining xususiy tarmoq marshrutlaridagi xostdagi API shu tarmoq orqali, GitLab kabi ochiladi. Boshqa har qanday xost ommaviy manzilga olib borishi kerak: tiketdan kelgan xostlar uchun agnts ichki manzillarni rad etadi.

## Natijalar

**API natijalari** yorligʻi endpointlarni koʻrsatadi, avval nosozliklari borlarini. Xulosa qaysi soʻrov va javobga asoslanganini koʻrish va uni curl sifatida nusxalash uchun tekshiruvni oching (token yashirin qoladi). agnts har bir javobni spetsifikatsiya sxemasi bilan oʻzi ham solishtiradi; bunday topilmalar **agnts tekshiruvi** deb belgilanadi. Ortida yozib olingan soʻrov boʻlmagan xulosa tashlab yuboriladi. **Soʻrovlar** — ishga tushirishning barcha soʻrovlari.

- **Oʻtdi / Nosoz**: tekshiruv bajarildi, javob toʻgʻri yoki notoʻgʻri.
- **Oʻtkazib yuborildi**: ataylab bajarilmadi: yozish oʻchiq, API kerakli maʼlumotni bermaydi, chegara yetdi.
- **Bajarilmadi**: bajarib boʻlmadi: token muddati tugadi yoki u bogʻliq soʻrov muvaffaqiyatsiz boʻldi. Hech bir tekshiruv bajarilmasa, ishga tushirish sababi bilan xato bilan tugaydi.

**Bug tiketini yaratish** nosozliklarni Bug tiketiga aylantiradi (agar testda repozitoriy boʻlsa, oʻsha repozitoriyda). **Qayta ishga tushirish** testni takrorlaydi; yopilgan test yangi tiket sifatida ishga tushadi.

## Toʻplamlar

Tugagan testdagi **Toʻplam sifatida saqlash** uni qayta ishga tushirish uchun saqlaydi: qoʻlda, har soatda, har kuni yoki har dushanba (siz tanlagan UTC soatida) yoki har bir deploydan keyin. Har bir ishga tushirish — yangi Swagger testi tiketi. U toʻplamning oxirgi ishga tushirishi rejasidan foydalanadi, shuning uchun takrorlar ancha kam qadam sarflaydi, va u bilan solishtiriladi: bildirishnoma oldin boʻlmagan nosozliklardan boshlanadi. Oxirgisi davom etayotganda yangi ishga tushirish boshlanmaydi.

**Deploy hookini yaratish** deploy pipeline'ingiz har bir deploydan keyin `curl -X POST <url>` bilan chaqiradigan URL beradi. U bir marta koʻrsatiladi; yangisi eskisini oʻchiradi. Toʻplamda tokenning oʻz nusxasi saqlanadi, tiketdagi kabi muhrlangan — uni almashtirguningizcha yoki toʻplamni oʻchirguningizcha.

## Token

U forma saqlanganda muhrlanadi, boshqa koʻrsatilmaydi, agnts saqlaydigan hamma narsadan (jurnallar, natijalar, hisobot, jonli hodisalar) olib tashlanadi va tiket yopilganda oʻchiriladi. Ishga tushirish ichida uni faqat soʻrovlarni yuboradigan mijoz — agnts-api oʻqiydi.

## Narxi

Ish maydoni qaysi model bilan kod yozishidan qatʼi nazar, koʻpi bilan 60 qadamli bitta Claude (Sonnet) sessiyasi: token va API himoyasi ishga tushirish ichidagi agnts qoʻriqchisiga tayanadi, Codex ishga tushirishlarida esa u yoʻq. Soʻrovlar bitta paket bilan, soniyasiga 5 ta (sozlanadi), bir ishga tushirishda koʻpi bilan 300 ta yuboriladi.
