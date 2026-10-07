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

## Plane

Plane Cloud yoki oʻzingizning Plane. API manzilini (https://api.plane.so yoki Plane manzilingiz), Plane manzilidagi ish maydoni slugini va shaxsiy kirish tokenini kiriting. Plane'da shu yerda koʻrsatilgan manzil va vazifa hodisalari bilan webhook qoʻshing (Workspace settings → Webhooks), soʻng Plane koʻrsatgan sirni joylang. Repozitoriyni Plane loyihasiga identifikatori orqali bogʻlang (WEB-123 dagi WEB) va vazifalarga agnts yoki agnts-<tur> belgisini qoʻying. Boʻsh qoldirilgan holatlar mos guruhning birinchi holatiga oʻtkazadi (started, completed, cancelled); «koʻrib chiqishda» faqat siz nomlagan holatga oʻtkazadi. Har soatlik sinxronlash Plane yetkazmagan webhooklarni ushlaydi.

## Holatlar va izohlar

agnts tiketlarni doskada qanday siljitadi va izohlarda nima yozadi.
