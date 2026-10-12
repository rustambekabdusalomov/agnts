# Qoidalar

Qoidalar agntsga jamoangiz qanday ishlashini aytadi: qanday test yozish, nomlash, loglash, kod tuzilishi va nimaga tegmaslik kerakligi. agnts ularga har bir tiket va vazifada amal qiladi.

## Global va repozitoriy qoidalari

Global qoida barcha repozitoriylarda amal qiladi. Repozitoriy qoidasi faqat oʻsha yerda amal qiladi va global qoidaga zid boʻlsa, ustun turadi.

## Ishlatishdan oldin tekshiruv

Qoidani saqlaganingizda Claude uni oʻqiydi (repozitoriy qoidasini oʻsha repozitoriy kodi bilan birga) va undagi mavhum soʻzlar, noaniq chegaralar, koʻrsatilmagan holatlar va boshqa qoidalar bilan ziddiyatlarni qidiradi. Biror narsa noaniq boʻlsa, savol beradi. Javoblaringiz qoidaning bir qismiga aylanadi va Claude uni qayta tekshiradi; uch raunddan keyin u eng oqilona talqinni tanlaydi.

Qoida faqat aniq boʻlgandan keyin amal qiladi. **Yozilganicha ishlatish** ochiq savollarni oʻtkazib yuboradi va qoidani hozirgacha berilgan javoblar bilan qoʻllaydi.

## Tiketlar nimani oladi

Har bir tahlil va kod yozish ishga tushishi tegishli yoqilgan qoidalarni "Team rules" boʻlimida, Claude aniqlashtirgan matnda oladi. Tiket jurnalida u qaysi qoidalarga amal qilgani koʻrinadi. Qoida matnini oʻzgartirish uni qayta tekshiruvga yuboradi; oʻchirish keyingi ishga tushishdan kuchga kiradi.

## Narxi

Tekshiruv — Sozlamalardagi tahlil modeli bilan qisqa Claude ishga tushishi. U kutayotgan tiketlardan oldin bajariladi, chunki keyingi barcha tiketlar uning natijasiga bogʻliq.

## Majburiy qoidalar

Qoidaga shablon bering, shunda agnts-guard uni Claude ishlayotganda qoʻllaydi: mos fayllarni tahrirlashda (xohlasangiz, faqat regulyar ifodaga mos qoʻshilgan qatorlarda), buyruqlarda yoki tayyor oʻzgarishda. *Bloklash* harakatni rad etadi; *Ogohlantirish* Claude ga aytadi. Yoqishdan oldin **Tarixda sinash** shablon agnts ning oxirgi oʻzgarishlarida nimani ushlashini koʻrsatadi. Buzilgan majburiy qoida reviewda qizil bayroq sifatida ham koʻrinadi.

## Skillar, maslahatlar va boshlangʻich qoidalar

**Skill** sifatida yetkaziladigan qoida yoki biznes eslatma har bir promptga kirmaydi; tavsifi ishga mos kelganda Claude uni yuklaydi, shuning uchun qoidalar koʻpaysa ham promptlar qisqa qoladi. Doim amal qilishi kerak boʻlgan qoidalarni promptda qoldiring. **Maslahatlar** — agnts muammoli ishga tushirishlardan olgan amaliy saboqlar; oʻrganilgan takliflar agnts ularni har safar yana koʻrganda ishonch toʻplaydi va shungacha faqat *kuzatiladi*, ikki repozitoriyda koʻrilgani esa barcha repozitoriylar uchun taklif qilinadi. Repozitoriy tillari uchun **boshlangʻich qoidalar** uning sahifasida taklif qilinadi; qabul qilinganlari takliflar sifatida qoʻshiladi.
