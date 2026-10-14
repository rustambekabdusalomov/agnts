# Repozitoriylar

agnts ishlay oladigan kod. Har bir ish repozitoriyni serveringizdagi yangi konteynerga klonlaydi.

## Manbalar

Jira repozitoriylari Jira loyihasidan, Plane repozitoriylari Plane loyihasidan tiket oladi. Shaxsiy loyiha repozitoriylari agnts'da yaratilgan vazifalarni oladi.

## Tekshiruvlar

Kod yozilgach build, linter va testlar ishga tushadi. Tiket faqat ular oʻtganda tekshiruvingizga keladi.

## CLAUDE.md

Repozitoriy ildizidagi tuzilma, qoidalar va test buyruqlari yozilgan fayl. Usiz agnts yoʻl topish uchun koʻproq qadam sarflaydi.

## Tahrirlash

URL, asosiy branch yoki buyruqlarni oʻzgartirish uchun repozitoriyni bosing.

## Oldindan koʻrish

Ishga tushirish buyrugʻi va portni bering, shunda agnts interfeys oʻzgarishlarini siz koʻrib chiqishdan oldin suratga oladi. Buyruq ishga tushirish konteynerida bajariladi (oʻrnatish, yigʻish, ishga tushirish); agnts port javob berishini kutadi. Interfeys fayllari qaysi oʻzgarishlar skrinshot olishini belgilaydi. Muhit oʻzgaruvchilari — KEY=value qatorlari, masalan staging API manzili; ular shifrlangan holda saqlanadi, faqat nomi koʻrsatiladi va ilova hamda agnts koʻra oladi, shuning uchun faqat test hisob maʼlumotlaridan foydalaning. Ilova murojaat qiladigan hostlarni Sozlamalar → Oldindan koʻrish → Ruxsat etilgan hostlarga qoʻshing.

## Toolchainlar

Har bir ishga tushirishga o‘rnatiladigan til muhitlari va yig‘ish vositalari, masalan go@1.24, node@20 yoki python@3.12. agnts ularni repozitoriy fayllaridan aniqlaydi (mise.toml, .tool-versions, go.mod, .nvmrc, pyproject.toml, Cargo.toml, pom.xml, global.json, Gemfile va boshqalar) va bu fayllar o‘zgarganda yangilaydi. «Aniqlash» asosiy branchni qayta o‘qiydi; «Claude’dan so‘rash» skanerlash buyruqlarni topmasa, README va CI fayllarini ham o‘qiydi. Ro‘yxatni qo‘lda o‘zgartirsangiz, avtomatik aniqlash unga tegmaydi. Har bir versiya bir marta o‘rnatiladi va barcha ishga tushirishlar uchun umumiy; har bir repozitoriyning paket keshi ishga tushirishlar orasida saqlanadi.

## Qo‘shimcha

Ishga tushirish obrazi bu repozitoriy uchun standart obrazni almashtiradi — toolchainlar bera olmaydigan tizim kutubxonalari yoki SDK uchun (Android, Flutter); uni serverda FROM agnts-runner asosida yig‘ing. Xotira og‘ir yig‘ishlar uchun konteyner xotirasini oshiradi. Yig‘ish muhiti — KEY=value qatorlari, masalan xususiy reyestr tokenlari; u shifrlangan holda saqlanadi, faqat nomlari ko‘rsatiladi va ishlayotganda Claude’ga ko‘rinadi, shuning uchun faqat o‘qish uchun tokenlardan foydalaning.

## Guruhlar

Guruh — bitta vazifa birga oʻzgartira oladigan repozitoriylarning nomlangan toʻplami, masalan backend va uning veb-ilovasi. Unga repozitoriylar qanday bogʻlanishi haqida koʻrsatmalar bering (kontraktlar, qaysi biri birinchi oʻzgaradi); guruh vazifalarining har bir ishga tushirilishi ularni oʻqiydi. Guruhdan yaratilgan vazifa yaratilganda uning repozitoriylarini nusxalaydi: keyin guruh oʻzgartirilsa, vazifa oʻzgarmaydi. Repozitoriylar bitta ishga tushirish konteynerini baham koʻradi, shuning uchun ularga bir xil runner image kerak va bitta vositaning bir-biriga zid versiyalari boʻlmasligi kerak; agnts konteynerni baham koʻra olmaydigan guruhni saqlamaydi va ikkalasida berilgan build oʻzgaruvchilari haqida ogohlantiradi. Arxivlangan repozitoriylar oʻz guruhlarida qoladi, lekin yangi vazifalarga kirmaydi.
