# Repozitoriylar

agnts ishlay oladigan kod. Har bir ish repozitoriyni serveringizdagi yangi konteynerga klonlaydi.

## Manbalar

Jira repozitoriylari Jira loyihasidan tiket oladi. Shaxsiy loyiha repozitoriylari agnts'da yaratilgan vazifalarni oladi.

## Tekshiruvlar

Kod yozilgach build, linter va testlar ishga tushadi. Tiket faqat ular oʻtganda tekshiruvingizga keladi.

## CLAUDE.md

Repozitoriy ildizidagi tuzilma, qoidalar va test buyruqlari yozilgan fayl. Usiz agnts yoʻl topish uchun koʻproq qadam sarflaydi.

## Tahrirlash

URL, asosiy branch yoki buyruqlarni oʻzgartirish uchun repozitoriyni bosing.

## Oldindan koʻrish

Ishga tushirish buyrugʻi va portni bering, shunda agnts interfeys oʻzgarishlarini siz koʻrib chiqishdan oldin suratga oladi. Buyruq ishga tushirish konteynerida bajariladi (oʻrnatish, yigʻish, ishga tushirish); agnts port javob berishini kutadi. Interfeys fayllari qaysi oʻzgarishlar skrinshot olishini belgilaydi. Muhit oʻzgaruvchilari — KEY=value qatorlari, masalan staging API manzili; ular shifrlangan holda saqlanadi, faqat nomi koʻrsatiladi va ilova hamda agnts koʻra oladi, shuning uchun faqat test hisob maʼlumotlaridan foydalaning. Ilova murojaat qiladigan hostlarni Sozlamalar → Oldindan koʻrish → Ruxsat etilgan hostlarga qoʻshing.
