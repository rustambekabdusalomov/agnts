# Integratsiyalar

agnts ishlaydigan xizmatlar: tiketlar uchun Jira yoki Plane, kod uchun GitHub yoki GitLab. Har birining ulanish holati va sozlamalari bilan alohida sahifasi bor.

## Ulanish

Koʻrsatilgan huquqlarga ega kirish tokenini joylang. U serveringizda shifrlangan holda saqlanadi va boshqa koʻrsatilmaydi. «Ulanishni tekshirish» uni istalgan payt tekshiradi.

## Huquqlar

Git sahifasida token qaysi huquqlarga ega ekani koʻrinadi. Majburiylari berilishi shart, aks holda ishlar bajarilmaydi.

## Repozitoriyga kirish

Repozitoriyni oʻchirmasdan, agnts uni klonlamasligi va unga yubormasligi uchun oʻchirib qoʻying.

## Commitlar va pull requestlar

Commitlar kimning nomidan, Co-authored-by qatori, sarlavha formati, qoralama, belgilar, tekshiruvchilar va birlashtirilgandan keyin nima boʻladi.

## Jira qoidalari

Qaysi loyihalar kuzatiladi, belgi, agnts oladigan vazifa turlari va holatlari — aniq soʻrov koʻrinishida.

Vazifa oʻz loyihasiga bogʻlangan repozitoriyga tushadi (Repozitoriylar → Jira loyihasi). Vazifani boshqasiga yuborish uchun agnts'dagi repozitoriy nomi bilan repo:<nom> belgisini qoʻshing, masalan repo:web; harflar katta-kichikligi muhim emas. U loyiha repozitoriyidan ustun turadi, shuning uchun bitta Jira loyihasi bir nechta repozitoriyni yuritishi mumkin, loyihaning oʻziga esa repozitoriy shart emas. Belgi qoʻshilsa yoki oʻzgartirilsa, ish boshlanmagan tiket koʻchadi; ish boshlangach tiket oʻz repozitoriyida qoladi (navbatda yoki xatoda turganda uni tiket sahifasida oʻzgartirish mumkin). agnts bunday nomni bilmasa, vazifa loyiha repozitoriyiga tushadi va tiket tarixida ogohlantirish chiqadi. Bir nechta repo: belgisi bitta tiketni yaratadi, u barcha shu repozitoriylarni birga oʻzgartiradi (birinchisi asosiy, har bir oʻzgargan repozitoriyga bittadan pull request), group:<nom> belgisi esa uni guruh repozitoriylariga yuboradi; u repo: belgilaridan ustun turadi.

«Faqat menga biriktirilgan vazifalar» yoqilgan boʻlsa (standart holat), agnts belgili vazifani faqat u agnts ulangan Jira akkauntiga biriktirilgan boʻlsa oladi va soʻrovga assignee = currentUser() qoʻshiladi. Boshqaga yoki hech kimga biriktirilmagan vazifa yangi tiket yaratmaydi; mavjud tiket esa vazifa yangilanishlarini olishda davom etadi. Barcha belgili vazifalarni olish uchun oʻchiring.

## Plane

Plane Cloud yoki oʻzingizning Plane. API manzilini (https://api.plane.so yoki Plane manzilingiz), Plane manzilidagi ish maydoni slugini va shaxsiy kirish tokenini kiriting. Plane'da shu yerda koʻrsatilgan manzil va vazifa hodisalari bilan webhook qoʻshing (Workspace settings → Webhooks), soʻng Plane koʻrsatgan sirni joylang. Repozitoriyni Plane loyihasiga identifikatori orqali bogʻlang (WEB-123 dagi WEB) va vazifalarga agnts yoki agnts-<tur> belgisini qoʻying. Boʻsh qoldirilgan holatlar mos guruhning birinchi holatiga oʻtkazadi (started, completed, cancelled); «koʻrib chiqishda» faqat siz nomlagan holatga oʻtkazadi. Har soatlik sinxronlash Plane yetkazmagan webhooklarni ushlaydi.

Bitta vazifani boshqa repozitoriyga yuborish uchun agnts'dagi repozitoriy nomi bilan repo:<nom> belgisini qoʻshing, masalan repo:web; harflar katta-kichikligi muhim emas. U loyiha repozitoriyidan ustun turadi, shuning uchun bitta Plane loyihasi bir nechta repozitoriyni yuritishi mumkin. Sinxronlash va har soatlik tekshiruv faqat repozitoriyga bogʻlangan loyihalarni oʻqiydi, shuning uchun loyihani bogʻlangan holda qoldiring. Belgi qoʻshilsa yoki oʻzgartirilsa, ish boshlanmagan tiket koʻchadi; ish boshlangach tiket oʻz repozitoriyida qoladi. agnts bunday nomni bilmasa, vazifa loyiha repozitoriyiga tushadi va tiket tarixida ogohlantirish chiqadi. Bir nechta repo: belgisi yoki group:<nom> belgisi, Jira'dagi kabi, bir nechta repozitoriydagi bitta tiketni yaratadi.

## Holatlar va izohlar

agnts tiketlarni doskada qanday siljitadi va izohlarda nima yozadi.
