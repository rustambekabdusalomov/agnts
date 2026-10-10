// Languages for the Pitch Day site: English is the text in the pages
// (data-i18n keys); Russian and Uzbek are below. The language comes from
// ?lang=, then the visitor's last choice, then the browser, then English.
(function () {
  var T = {
    ru: {
      'meta.title': 'agnts · Pitch Day 3.0',
      'meta.desc': 'agnts: ИИ-агенты, которые проводят задачу из Jira до проверенного pull request. Демо-сайт для Pitch Day 3.0.',
      'nav.problem': 'Проблема', 'nav.team': 'Команда', 'nav.why': 'Почему я', 'nav.roadmap': 'Дорожная карта', 'nav.plan': 'Реализация', 'nav.api': 'API',
      'cta.watch': 'Смотреть демо', 'cta.open': 'Открыть agnts.uz',
      'hero.tag': 'Pitch Day 3.0 · MVP работает на agnts.uz',
      'hero.title': 'ИИ-агенты, которые доводят задачу до <u>проверенного pull request</u>.',
      'hero.lede': 'agnts берёт задачу из Jira или Plane, читает ваш код, спрашивает о неясном, пишет и тестирует код в изолированном контейнере и открывает pull request только после вашего одобрения. Разработчики тратят время на архитектуру, масштабирование и бизнес-логику.',
      'facts.f1v': 'Май 2026', 'facts.f1': 'Идея',
      'facts.f2v': 'Июнь 2026', 'facts.f2': 'Первая версия, с тех пор работает на моих задачах',
      'facts.f3v': '20–25 мин', 'facts.f3': 'в день, чтобы проекты двигались во время поездки',
      'facts.f4': 'Языки интерфейса',
      'problem.label': 'Проблема → Решение',
      'problem.title': 'Код пишет ИИ. Всё остальное разработчики по-прежнему делают сами.',
      'problem.sub': 'Разработчики уже пишут код с ИИ, но каждую задачу всё так же нужно прочитать, объяснить, проверить, протестировать и закрыть вручную. Эта рутина занимает большую часть дня.',
      'problem.before': 'Проблема',
      'problem.p1t': 'Каждая задача превращается в промпт', 'problem.p1': 'Прочитать задачу, разобраться в коде и объяснить ИИ задачу так подробно, чтобы он сделал всё правильно.',
      'problem.p2t': 'Проверка и тесты вручную', 'problem.p2': 'Запустить сборку, линтер и тесты и исправить то, что сломалось, пока никто не увидел.',
      'problem.p3t': 'Рутина', 'problem.p3': 'Запушить ветку, открыть pull request, перевести задачу в «Готово».',
      'problem.p4t': 'Те же ошибки снова', 'problem.p4': 'ИИ забывает ваши правки, и на следующей задаче вы объясняете всё заново.',
      'problem.after': 'Решение: agnts',
      'problem.s1t': 'Читает задачу и ваш код', 'problem.s1': 'Берёт задачу из Jira или Plane и задаёт короткие вопросы только там, где что-то неясно.',
      'problem.s2t': 'Проверки проходят до вашего ревью', 'problem.s2': 'Пишет код в изолированном контейнере, запускает сборку, линтер и тесты и сам исправляет ошибки.',
      'problem.s3t': 'От задачи до pull request', 'problem.s3': 'После того как вы одобрите diff, agnts пушит, открывает pull request и обновляет задачу.',
      'problem.s4t': 'Учится на каждой ошибке', 'problem.s4': 'Объясните ошибку один раз. agnts исправит её и запомнит урок для следующих задач.',
      'team.title': 'Создан инженером, который сам им пользуется.',
      'team.sub': 'Я создаю agnts сам, как соло-основатель. Несколько друзей-программистов тестируют его в своей работе и в мобильном приложении.',
      'team.name': 'Рустамбек Абдусаломов', 'team.role': 'Основатель · инженер и тимлид',
      'team.bio': 'Более 5 лет в разработке и руководстве командами. Спроектировал и построил agnts целиком: сервер, админ-панель, сайт, мобильное приложение и инфраструктуру.',
      'team.skills': 'Навыки', 'team.tech': 'Технологии', 'team.links': 'Ссылки',
      'skill.1': 'Архитектура бэкенда (Go)', 'skill.2': 'Фронтенд (Vue, Nuxt)', 'skill.3': 'Мобильная разработка (Flutter)',
      'skill.5': 'Docker и DevOps', 'skill.6': 'ИИ-агенты (Claude Code, MCP)', 'skill.7': 'Проектирование API (OpenAPI)', 'skill.8': 'Руководство командой',
      'tech.server': 'Сервер', 'tech.serverv': 'Go, Clean Architecture, REST API с Server-Sent Events, MCP-сервер',
      'tech.db': 'База данных', 'tech.dbv': 'PostgreSQL с миграциями и изоляцией рабочих пространств на уровне строк',
      'tech.ai': 'Среда ИИ-агента', 'tech.aiv': 'Claude Code (Sonnet, Opus, Haiku), отдельный Docker-контейнер на каждый запуск',
      'tech.admin': 'Админ-панель', 'tech.site': 'Сайт', 'tech.sitev': 'Nuxt 3, статическая сборка на английском, русском и узбекском',
      'tech.mobile': 'Мобильное приложение', 'tech.mobilev': 'Flutter для iOS и Android, push-уведомления, Telegram-бот',
      'tech.int': 'Интеграции', 'tech.intv': 'Jira, Plane, GitHub, GitLab, Telegram',
      'tech.infra': 'Инфраструктура', 'tech.infrav': 'Docker Compose, Caddy (HTTPS), прокси с белым списком исходящих адресов, ночные бэкапы, установщик на Rust',
      'links.channel': 'Telegram-канал', 'links.community': 'Telegram-сообщество',
      'story.label': "Как появился agnts", 'story.title': "Утром я писал задачи. К вечеру они ждали моего ревью.", 'story.sig': "Рустамбек, основатель agnts", 'story.w1': "Июль 2026", 'story.t1': "Поездка в Турцию", 'story.w2': "Май – июнь 2026", 'story.t2': "Как всё началось", 'story.w3': "После поездки", 'story.t3': "Друзья и стартап", 'story.w4': "Сейчас", 'story.t4': "Мобильное приложение", 
      'story.p1': "В июле 2026 года я поехал в путешествие в Турцию. Каждое утро я тратил всего 5–10 минут, чтобы написать несколько задач, а вечером, вернувшись в отель, находил их готовыми pull request с пройденными тестами. На ревью уходило всего 10–15 минут. Так 20–25 минут в день хватало, чтобы задачи по проектам продолжали выполняться, и могу сказать, что это очень помогло сделать поездку именно такой, какой я хотел. В ту неделю я был искренне благодарен себе за то, что создал agnts.", 'story.p2': "Я начал в мае, когда увидел, сколько времени разработчика по-прежнему уходит на чтение задач, объяснение их ИИ, а потом на проверку и тестирование результата. Первая версия начала работать над моими задачами в конце июня и работает до сих пор.", 'story.p3': "Вернувшись, я рассказал об этом друзьям-программистам, и они заинтересовались. Они тоже захотели попробовать: я открыл им аккаунты, и вскоре от всех получил искренние отзывы. Тогда agnts и стал стартапом: я пришёл к выводу, что и другие разработчики должны тратить время не на повторяющиеся повседневные задачи, а на архитектуру, масштабирование и бизнес-логику. Я сам убедился, насколько это повышает продуктивность и позволяет реализовывать проекты с более совершенными решениями.", 'story.p4': "Сейчас мобильное приложение на стадии тестирования. Я разрабатываю его, чтобы всем процессом можно было управлять с телефона. После тестирования я планирую запустить его в полном виде, чтобы им могли пользоваться все.", 
      'why.title': 'Почему я смогу решить эту задачу.',
      'why.sub': 'Проблема взята из моей ежедневной работы, а продукт уже работает на реальных задачах.',
      'why.w1t': 'Создатель — сам пользователь', 'why.w1': 'С июня 2026 года я использую agnts на своих задачах. В поездке в Турцию мне хватало 20–25 минут в день: утром написать задачи, вечером проверить готовые pull request.',
      'why.w2t': 'Годы внутри процесса работы с задачами', 'why.w2': 'Более 5 лет разработки и руководства командами: я знаю, куда уходит день разработчика — от размытых задач до раундов ревью.',
      'why.w3t': 'Уже работает, а не макет', 'why.w3': 'Продукт работает на agnts.uz с бесплатным демо. Друзья-программисты используют его в своей работе и дали очень хорошие отзывы.',
      'why.w4t': 'Безопасность и локальный рынок', 'why.w4': 'Ничего не публикуется без одобрения человека, каждый запуск изолирован, а интерфейс и поддержка готовы для Узбекистана, на узбекском и русском.',
      'road.title': 'Идея → Прототип → MVP → Запуск.',
      'road.sub': 'agnts на стадии MVP: работает, бесплатен для пробы и уже используется первыми разработчиками.',
      'road.here': 'agnts сейчас здесь', 'road.r2d': 'В поездке проекты двигались за 20–25 минут в день', 'road.r3e': 'Друзья-программисты используют его в работе',
      'road.done': 'Готово', 'road.current': 'Текущая стадия', 'road.next': 'Дальше', 'road.nowWhen': 'Сейчас', 'road.nextWhen': 'После демо-периода',
      'road.r1': 'Идея', 'road.r1a': 'Автоматизировать путь от задачи до pull request с помощью ИИ-агентов', 'road.r1b': 'Архитектура и план реализации',
      'road.r2': 'Прототип', 'road.r2a': 'Задача из Jira → протестированный pull request', 'road.r2b': 'Изолированные запуски, проверки и одобрение', 'road.r2c': 'С тех пор работает на моих задачах',
      'road.r3a': 'Работает на agnts.uz, бесплатное демо', 'road.r3c': 'ИИ-ревью, превью, обучение', 'road.r3d': 'Мобильное приложение тестируется с друзьями',
      'road.r4': 'Запуск', 'road.r4a': 'Платные тарифы', 'road.r4b': 'Мобильное приложение в магазинах приложений', 'road.r4c': 'Новые коннекторы по запросам пользователей', 'road.r4d': 'Другие ИИ-модели помимо Claude: ChatGPT, Kimi и другие',
      'plan.title': 'Как я его строю и запускаю.',
      'plan.sub': 'Каждая задача проходит один и тот же путь. ИИ выполняет работу в изолированном контейнере, а человек принимает решение в каждой важной точке.',
      'plan.flowAria': 'Путь задачи',
      'flow.1': 'Задача в Jira или Plane', 'flow.2': 'Анализ кода', 'flow.3': 'Ответы на вопросы', 'flow.4': 'Код в контейнере', 'flow.5': 'Сборка, линтер, тесты',
      'flow.6': 'ИИ-ревью и превью', 'flow.7': 'Одобрение', 'flow.8': 'Pull request', 'flow.9': 'Обучение',
      'legend.ai': 'ИИ-агент', 'legend.you': 'Решает разработчик', 'legend.server': 'Сервер agnts',
      'plan.ai': 'ИИ-инструменты и решения',
      'model.s': 'Код', 'model.sv': 'Пишет изменение. Упавшие сборка, линтер или тесты возвращаются агенту, до двух раз.',
      'model.o': 'Сложные случаи', 'model.ov': 'Сложные повторы и ревью сложных или больших изменений.',
      'model.h': 'Помощник', 'model.hv': 'Сводки, переводы и небольшие вспомогательные шаги.',
      'ai.1t': 'Claude Code как среда агента', 'ai.1': 'Каждый запуск получает новый Docker-контейнер с репозиторием и его инструментами. Он может обращаться только к Claude, git-хостингу и реестрам пакетов.',
      'ai.2t': 'Спрашивает, а не угадывает', 'ai.2': 'Сначала анализ читает задачу и код и превращает всё неясное в короткие вопросы с вариантами ответа.',
      'ai.3t': 'Самопроверка и тревожные сигналы', 'ai.3': 'Отдельный запуск ревью читает diff, а сканер находит пропущенные тесты, удалённые проверки и отключённые линтеры до того, как посмотрит человек.',
      'ai.4t': 'Обучение на отзывах', 'ai.4': 'После пуша или запроса изменений agnts выделяет уроки и предлагает правила команды. Человек одобряет их, прежде чем они попадут в промпт.',
      'ai.5t': 'Визуальные превью', 'ai.5': 'Для фронтенда запуск превью открывает изменённые страницы и делает скриншоты для компьютера и телефона.',
      'ai.6t': 'Описание репозитория и повторы', 'ai.6': 'Описание каждой кодовой базы даёт агенту контекст, а повторный прогон готовых задач оценивает каждую новую версию промпта.',
      'plan.stages': 'Этапы',
      'ph.1t': 'Основной цикл агента', 'ph.1': 'Адаптер Jira, машина состояний оркестратора, запуск в контейнерах, проверки и повторы, pull request в GitHub.',
      'ph.2t': 'Админ-панель для ежедневной работы', 'ph.2': 'Живые логи, ревью diff, одобрения, учёт лимитов плана, рабочие пространства, три языка.',
      'ph.3t': 'Интеграции и интеллект агента', 'ph.3': 'Plane, GitLab, Telegram, MCP-сервер для чата Claude, ИИ-ревью, превью, обучение на отзывах.',
      'ph.4t': 'MVP с первыми пользователями (сейчас)', 'ph.4': 'Бесплатное демо на agnts.uz, друзья используют его в работе, мобильное приложение в тестировании.',
      'ph.5t': 'Запуск', 'ph.5': 'Платные тарифы, мобильное приложение в магазинах, новые коннекторы по запросам пользователей и другие ИИ-модели помимо Claude, например ChatGPT и Kimi.',
      'api.label': 'Доступ к API', 'api.title': 'Всё в agnts — это API.',
      'api.sub': 'Админ-панель, мобильное приложение и чат Claude — клиенты одного и того же API, поэтому команды могут автоматизировать agnts и сами.',
      'api.rest': 'Описан контрактом OpenAPI 3, с bearer-токенами и живыми обновлениями через Server-Sent Events.',
      'api.mcpt': 'MCP-сервер', 'api.mcp': 'Подключите agnts к чату Claude, Claude Code или Claude Desktop и управляйте задачами в диалоге, с подтверждением перед каждым изменением.',
      'code.0': '# Несколько операций из контракта OpenAPI', 'code.1': '# задачи и их состояние', 'code.2': '# живой лог запуска',
      'code.3': '# ответить на вопросы agnts', 'code.4': '# одобрить: пуш и pull request', 'code.5': '# вернуть с замечаниями',
      'band.title': 'Посмотрите, как agnts работает с реальной задачей.',
      'band.text': 'В демо задача проходит путь от Jira до проверенного pull request, и вы видите рабочий продукт, который можно попробовать уже сегодня.',
      'band.cta': 'Перейти к демо',
      'ft.line': 'agnts · Pitch Day 3.0 · Рустамбек Абдусаломов',
      'chat.open': 'Спросить об agnts',
      'demo.metaTitle': 'agnts · Демо', 'demo.metaDesc': 'Демо agnts: задача из Jira до протестированного и проверенного pull request.',
      'demo.label': 'Демо', 'demo.video': 'Видео', 'demo.title': 'agnts на реальной задаче.',
      'demo.sub': 'От задачи с меткой в Jira до протестированного и проверенного pull request — и ревью, которое занимает несколько минут.',
      'demo.phTitle': 'Демо-видео', 'demo.ph': 'Здесь будет демо-видео на 1–5 минут.',
      'demo.shows': 'Что показано в видео',
      'demo.intro': 'Разработчик передаёт agnts задачу и вмешивается только чтобы ответить и одобрить. Всё в видео — рабочий продукт на agnts.uz.',
      'demo.step1': 'Шаг 1', 'demo.step2': 'Шаг 2', 'demo.step3': 'Шаг 3', 'demo.step4': 'Шаг 4', 'demo.step5': 'Шаг 5',
      'demo.c1t': 'Метка на задаче', 'demo.c1': 'Задача в Jira получает метку agnts. agnts берёт её и читает задачу и кодовую базу.',
      'demo.c2t': 'Ответы на вопросы', 'demo.c2': 'Всё неясное превращается в короткий вопрос с вариантами, ответ — в один клик.',
      'demo.c3t': 'agnts пишет код и тестирует', 'demo.c3': 'В новом контейнере на своей ветке. Живой лог показывает, что сборка, линтер и тесты проходят.',
      'demo.c4t': 'Ревью результата', 'demo.c4': 'Сводка, diff, замечания ИИ-ревью и, для фронтенда, скриншоты изменённых страниц.',
      'demo.c5t': 'Одобрение', 'demo.c5': 'agnts пушит, открывает pull request и переводит задачу. Или запросите изменения — agnts исправит их и научится на этом.',
      'demo.step6': "Шаг 6", 'demo.c6t': "Обучение", 'demo.c6': "После пуша agnts читает изменение и превращает всё новое в нём (паттерн, алгоритм, библиотеку) в урок с объяснением, ссылками на код и коротким тестом. С каждой задачей растёт не только кодовая база, но и сам разработчик.", 
      'demo.proto': 'Рабочий прототип',
      'demo.protoText': 'Работает и бесплатен во время демо. Войдите через Google, подключите Jira или Plane, GitHub или GitLab и Claude, затем поставьте метку на задачу.',
      'demo.protoCta': 'Открыть прототип', 'demo.back': 'Назад к обзору'
    },
    uz: {
      'meta.title': 'agnts · Pitch Day 3.0',
      'meta.desc': 'agnts: vazifani Jiradan tekshirilgan pull requestgacha olib boradigan AI agentlar. Pitch Day 3.0 uchun demo-sayt.',
      'nav.problem': 'Muammo', 'nav.team': 'Jamoa', 'nav.why': 'Nega men', 'nav.roadmap': 'Yoʻl xaritasi', 'nav.plan': 'Amalga oshirish', 'nav.api': 'API',
      'cta.watch': 'Demoni koʻrish', 'cta.open': 'agnts.uz ni ochish',
      'hero.tag': 'Pitch Day 3.0 · MVP agnts.uz da ishlamoqda',
      'hero.title': 'Vazifalaringizni <u>tekshirilgan pull request</u>gacha olib boradigan AI agentlar.',
      'hero.lede': 'agnts vazifani Jira yoki Planedan oladi, kodingizni oʻqiydi, nima noaniq boʻlsa soʻraydi, izolyatsiyalangan konteynerda kod yozadi va test qiladi, pull requestni esa faqat siz tasdiqlaganingizdan keyin ochadi. Dasturchilar vaqtini arxitektura, masshtablash va biznes mantiqqa sarflaydi.',
      'facts.f1v': '2026-yil may', 'facts.f1': 'Gʻoya',
      'facts.f2v': '2026-yil iyun', 'facts.f2': 'Birinchi versiya, oʻshandan beri vazifalarim ustida ishlaydi',
      'facts.f3v': '20–25 daqiqa', 'facts.f3': 'sayohatda loyihalar ishlashi uchun kuniga',
      'facts.f4': 'Interfeys tillari',
      'problem.label': 'Muammo → Yechim',
      'problem.title': 'Kodni AI yozadi. Qolgan hammasini dasturchilar hali ham oʻzi qiladi.',
      'problem.sub': 'Dasturchilar allaqachon AI bilan kod yozmoqda, lekin har bir vazifani hali ham qoʻlda oʻqish, tushuntirish, tekshirish, test qilish va yopish kerak. Bu rutina kunning katta qismini oladi.',
      'problem.before': 'Muammo',
      'problem.p1t': 'Har bir vazifa promptga aylanadi', 'problem.p1': 'Vazifani oʻqish, kodni oʻrganish va AI toʻgʻri bajarishi uchun vazifani batafsil tushuntirish.',
      'problem.p2t': 'Qoʻlda tekshirish va test qilish', 'problem.p2': 'Build, linter va testlarni ishga tushirib, buzilgan joylarni boshqalar koʻrishidan oldin tuzatish.',
      'problem.p3t': 'Rutina ishlar', 'problem.p3': 'Branchni push qilish, pull request ochish, vazifani «Bajarildi»ga oʻtkazish.',
      'problem.p4t': 'Yana oʻsha xatolar', 'problem.p4': 'AI tuzatishlaringizni unutadi va keyingi vazifada hammasini qaytadan tushuntirasiz.',
      'problem.after': 'Yechim: agnts',
      'problem.s1t': 'Vazifani va kodingizni oʻqiydi', 'problem.s1': 'Vazifani Jira yoki Planedan oladi va faqat noaniq joylarda qisqa savollar beradi.',
      'problem.s2t': 'Tekshiruvlar siz koʻrishdan oldin oʻtadi', 'problem.s2': 'Izolyatsiyalangan konteynerda kod yozadi, build, lint va testlarni ishga tushiradi va xatolarni oʻzi tuzatadi.',
      'problem.s3t': 'Vazifadan pull requestgacha', 'problem.s3': 'Diffni tasdiqlaganingizdan soʻng agnts push qiladi, pull request ochadi va vazifani yangilaydi.',
      'problem.s4t': 'Har bir xatodan oʻrganadi', 'problem.s4': 'Xatoni bir marta tushuntiring. agnts uni tuzatadi va saboqni keyingi vazifalar uchun eslab qoladi.',
      'team.title': 'Undan haqiqiy ishda foydalanadigan muhandis tomonidan yaratilgan.',
      'team.sub': 'agnts ni yakka asoschi sifatida oʻzim yaratyapman. Bir nechta dasturchi doʻstlarim uni oʻz ishlarida va mobil ilovada sinab koʻrmoqda.',
      'team.name': 'Rustambek Abdusalomov', 'team.role': 'Asoschi · muhandis va jamoa rahbari',
      'team.bio': "5 yildan ortiq tajribaga ega Software engineer va Teamlead.",
      'team.skills': 'Koʻnikmalar', 'team.tech': 'Foydalanilgan texnologiyalar', 'team.links': 'Havolalar',
      'skill.1': 'Backend arxitekturasi (Go)', 'skill.2': 'Frontend (Vue, Nuxt)', 'skill.3': 'Mobil dasturlash (Flutter)',
      'skill.5': 'Docker va DevOps', 'skill.6': 'AI agentlar (Claude Code, MCP)', 'skill.7': 'API loyihalash (OpenAPI)', 'skill.8': 'Jamoani boshqarish',
      'tech.server': 'Server', 'tech.serverv': 'Go, Clean Architecture, Server-Sent Events bilan REST API, MCP server',
      'tech.db': 'Maʼlumotlar bazasi', 'tech.dbv': 'Migratsiyalar va satr darajasida ish maydonlari izolyatsiyasi bilan PostgreSQL',
      'tech.ai': 'AI agent muhiti', 'tech.aiv': 'Claude Code (Sonnet, Opus, Haiku), har bir ishga alohida Docker konteyner',
      'tech.admin': 'Admin panel', 'tech.site': 'Sayt', 'tech.sitev': 'Nuxt 3, ingliz, rus va oʻzbek tillarida statik build',
      'tech.mobile': 'Mobil ilova', 'tech.mobilev': 'iOS va Android uchun Flutter, push-bildirishnomalar, Telegram bot',
      'tech.int': 'Integratsiyalar', 'tech.intv': 'Jira, Plane, GitHub, GitLab, Telegram',
      'tech.infra': 'Infratuzilma', 'tech.infrav': 'Docker Compose, Caddy (HTTPS), chiquvchi manzillar oq roʻyxati bilan proksi, tungi zaxira nusxalar, Rustda yozilgan oʻrnatuvchi',
      'links.channel': 'Telegram kanal', 'links.community': 'Telegram hamjamiyat',
      'story.label': "agnts qanday paydo boʻldi", 'story.title': "Ertalab vazifalarni yozardim. Kechga ular reviewʼga tayyor edi.", 'story.sig': "Rustambek, agnts asoschisi", 'story.w1': "2026-yil iyul", 'story.t1': "Turkiyaga sayohat", 'story.w2': "2026-yil may – iyun", 'story.t2': "Qanday boshlandi", 'story.w3': "Sayohatdan keyin", 'story.t3': "Doʻstlar va startap", 'story.w4': "Hozir", 'story.t4': "Mobil ilova", 
      'story.p1': "2026-yil iyul oyida Turkiyaga sayohat qilish uchun borgan edim. Har kuni ertalab bir nechta vazifalarni yozib ketardim, bunga atiga 5-10 daqiqa vaqt sarflar edim, kechqurun mehmonxonaga qaytganimda esa ular testdan oʻtgan pull requestlar boʻlib meni kutib turardi. Ularni koʻrib chiqish 10–15 daqiqa vaqt talab qilar edi holos. Bu kunlik 20-25 daqiqalik vaqt ajratgan holda loyihalardagi vazifalarni bajarish imkoniyatini yaratdi. Va bu menga sayohatni koʻngildagidek boʻlishiga juda katta hissa qoʻshdi deb ayta olaman. Oʻsha hafta agntsʼni yaratganim uchun oʻzimga chin dildan rahmat aytdim.", 'story.p2': "Uni may oyida boshladim. Dasturchi kunining qanchasi hali ham vazifalarni oʻqish, ularni AIʼga tushuntirish, soʻng natijani tekshirish va test qilishga ketishini koʻrganimdan keyin. Birinchi versiya iyun oyining oxirlarida mening vazifalarim ustida ishlay boshladi va hozirgacha ishlab kelmoqda.", 'story.p3': "Qaytib kelganimda bu haqida dasturchi doʻstlarimga aytib berdim va ularda bunga qiziqish paydo boʻldi. Shundan soʻng ular ham sinab koʻrmoqchi boʻlishdi. Ularga akkauntlarini ochib berdim, orqadan koʻp oʻtmay, barchasidan samimiy fikrlar oldim. Shunda agnts startapga aylandi, boshqa dasturchilar ham vaqtini kunlik takrorlanuvchi vazifalarga emas, arxitektura, masshtablashtirish va biznes logika ustida ishlash uchun sarflashi kerak degan hulosaga keldim. Bu ish unumdorligini sezilarli darajada oshirishiga va proyektlarning yanada mukammalroq yechimlar bilan amalga oshirish mumkinligiga guvoh boʻldim.", 'story.p4': "Hozir mobil ilova sinov bosqichida. Ilovani barcha jarayonlarni telefondan boshqarish imkoniyatini yaratish uchun ishlab chiqyapman. Sinovni tugatgach, ilovani toʻliq holatda hamma foydalana olishi uchun ishga tushirishni reja qilganman.", 
      'why.title': 'Nega men bu muammoni hal qila olaman.',
      'why.sub': 'Muammo mening kundalik ishimdan olingan va mahsulot allaqachon haqiqiy vazifalarda ishlamoqda.',
      'why.w1t': 'Yaratuvchi — foydalanuvchining oʻzi', 'why.w1': '2026-yil iyunidan beri agnts dan oʻz vazifalarimda foydalanaman. Turkiyaga sayohatda kuniga 20–25 daqiqa yetardi: ertalab vazifalarni yozardim, kechqurun esa tayyor pull requestlarni koʻrib chiqardim.',
      'why.w2t': 'Vazifalar bilan ishlashda yillar', 'why.w2': '5 yildan ortiq dasturlash va jamoa boshqaruvi: dasturchi kuni noaniq vazifalardan tortib review bosqichlarigacha nimaga ketishini bilaman.',
      'why.w3t': 'Maket emas, allaqachon ishlaydi', 'why.w3': 'Mahsulot agnts.uz da bepul demo bilan ishlamoqda. Dasturchi doʻstlarim undan oʻz ishlarida foydalanmoqda va juda yaxshi fikrlar bildirdi.',
      'why.w4t': 'Xavfsizlik va mahalliy bozor', 'why.w4': 'Inson tasdigʻisiz hech narsa chiqarilmaydi, har bir ish izolyatsiyalangan, interfeys va yordam Oʻzbekiston uchun oʻzbek va rus tillarida tayyor.',
      'road.title': 'Gʻoya → Prototip → MVP → Ishga tushirilgan.',
      'road.sub': 'agnts MVP bosqichida: ishlamoqda, sinab koʻrish bepul va birinchi dasturchilar undan foydalanmoqda.',
      'road.here': 'agnts hozir shu yerda', 'road.r2d': 'Sayohatda loyihalar kuniga 20–25 daqiqa bilan ishlab turdi', 'road.r3e': 'Dasturchi doʻstlar undan ishda foydalanmoqda',
      'road.done': 'Bajarildi', 'road.current': 'Joriy bosqich', 'road.next': 'Keyingi', 'road.nowWhen': 'Hozir', 'road.nextWhen': 'Demo davridan keyin',
      'road.r1': 'Gʻoya', 'road.r1a': 'Vazifadan pull requestgacha boʻlgan yoʻlni AI agentlar bilan avtomatlashtirish', 'road.r1b': 'Arxitektura va amalga oshirish rejasi',
      'road.r2': 'Prototip', 'road.r2a': 'Jira vazifasidan test qilingan pull requestgacha', 'road.r2b': 'Izolyatsiyalangan ishlar, tekshiruvlar va tasdiqlash', 'road.r2c': 'Oʻshandan beri vazifalarimda ishlatiladi',
      'road.r3a': 'agnts.uz da ishlamoqda, bepul demo', 'road.r3c': 'AI review, preview, oʻrganish', 'road.r3d': 'Mobil ilova doʻstlar bilan sinovda',
      'road.r4': 'Ishga tushirilgan', 'road.r4a': 'Pullik tariflar', 'road.r4b': 'Mobil ilova ilova doʻkonlarida', 'road.r4c': 'Foydalanuvchilar soʻrovi boʻyicha yangi konnektorlar', 'road.r4d': 'Claudedan tashqari boshqa AI modellar: ChatGPT, Kimi va boshqalar',
      'plan.title': 'Men uni qanday quraman va ishlataman.',
      'plan.sub': 'Har bir vazifa bir xil yoʻldan oʻtadi. Ishni AI izolyatsiyalangan konteynerda bajaradi, muhim nuqtalarda esa qarorni inson qabul qiladi.',
      'plan.flowAria': 'Vazifa yoʻli',
      'flow.1': 'Jira yoki Planedagi vazifa', 'flow.2': 'Kodni tahlil qilish', 'flow.3': 'Savollarga javob', 'flow.4': 'Konteynerda kod', 'flow.5': 'Build, lint, testlar',
      'flow.6': 'AI review va preview', 'flow.7': 'Tasdiqlash', 'flow.8': 'Pull request', 'flow.9': 'Oʻrganish',
      'legend.ai': 'AI agent', 'legend.you': 'Dasturchi qaror qiladi', 'legend.server': 'agnts server',
      'plan.ai': 'AI vositalari va yechimlar',
      'model.s': 'Kod yozish', 'model.sv': 'Oʻzgarishni yozadi. Muvaffaqiyatsiz build, lint yoki testlar agentga ikki martagacha qaytariladi.',
      'model.o': 'Murakkab holatlar', 'model.ov': 'Qiyin qayta urinishlar va murakkab yoki katta oʻzgarishlarni review qilish.',
      'model.h': 'Yordamchi', 'model.hv': 'Xulosalar, tarjimalar va kichik yordamchi qadamlar.',
      'ai.1t': 'Agent muhiti sifatida Claude Code', 'ai.1': 'Har bir ish repozitoriy va uning vositalari bilan yangi Docker konteyner oladi. U faqat Claude, git xosting va paket reyestrlariga ulana oladi.',
      'ai.2t': 'Taxmin qilishdan oldin soʻraydi', 'ai.2': 'Avval tahlil vazifa va kodni oʻqiydi va noaniq narsalarni variantli qisqa savollarga aylantiradi.',
      'ai.3t': 'Oʻz-oʻzini tekshirish va xavf belgilari', 'ai.3': 'Alohida review ishi diffni oʻqiydi, skaner esa inson koʻrishidan oldin oʻtkazib yuborilgan testlar, olib tashlangan tekshiruvlar va oʻchirilgan linterlarni topadi.',
      'ai.4t': 'Fikrlardan oʻrganish', 'ai.4': 'Push yoki oʻzgartirish soʻrovidan keyin agnts saboqlarni ajratadi va jamoa qoidalarini taklif qiladi. Ular promptga tushishidan oldin inson tasdiqlaydi.',
      'ai.5t': 'Vizual preview', 'ai.5': 'Frontend ishlari uchun preview ishi oʻzgargan sahifalarni ochadi va kompyuter hamda telefon oʻlchamida skrinshot oladi.',
      'ai.6t': 'Repozitoriy tavsifi va qayta ishlatish', 'ai.6': 'Har bir kod bazasining tavsifi agentga kontekst beradi, bajarilgan vazifalarni qayta ishlatish esa har bir yangi prompt versiyasini baholaydi.',
      'plan.stages': 'Bosqichlar',
      'ph.1t': 'Agentning asosiy sikli', 'ph.1': 'Jira adapteri, orkestrator holat mashinasi, konteynerda ishga tushirish, tekshiruvlar va qayta urinishlar, GitHub pull requestlari.',
      'ph.2t': 'Kundalik ish uchun admin panel', 'ph.2': 'Jonli loglar, diff review, tasdiqlashlar, tarif limitlarini kuzatish, ish maydonlari, uch til.',
      'ph.3t': 'Integratsiyalar va agent intellekti', 'ph.3': 'Plane, GitLab, Telegram, Claude chat uchun MCP server, AI review, preview, fikrlardan oʻrganish.',
      'ph.4t': 'Birinchi foydalanuvchilar bilan MVP (hozir)', 'ph.4': 'agnts.uz da bepul demo, doʻstlar undan ishda foydalanmoqda, mobil ilova sinovda.',
      'ph.5t': 'Ishga tushirish', 'ph.5': 'Pullik tariflar, mobil ilova doʻkonlarda, foydalanuvchilar soʻrovi boʻyicha yangi konnektorlar va Claudedan tashqari boshqa AI modellar, masalan ChatGPT va Kimi.',
      'api.label': 'API kirish', 'api.title': 'agnts dagi hamma narsa — API.',
      'api.sub': 'Admin panel, mobil ilova va Claude chat bitta API ning mijozlari, shuning uchun jamoalar agnts ni oʻzlari ham avtomatlashtira oladi.',
      'api.rest': 'OpenAPI 3 kontrakti bilan tavsiflangan, bearer tokenlar va Server-Sent Events orqali jonli yangilanishlar bilan.',
      'api.mcpt': 'MCP server', 'api.mcp': 'agnts ni Claude chat, Claude Code yoki Claude Desktopga ulang va vazifalarni suhbatda boshqaring, har bir oʻzgarishdan oldin tasdiqlash bilan.',
      'code.0': '# OpenAPI kontraktidan bir nechta amallar', 'code.1': '# vazifalar va ularning holati', 'code.2': '# ishning jonli logi',
      'code.3': '# agnts savollariga javob berish', 'code.4': '# tasdiqlash: push va pull request', 'code.5': '# izohlar bilan qaytarish',
      'band.title': 'agnts haqiqiy vazifada qanday ishlashini koʻring.',
      'band.text': 'Demoda vazifa Jiradan tekshirilgan pull requestgacha boradi va bugunoq sinab koʻrish mumkin boʻlgan ishlaydigan mahsulot koʻrsatiladi.',
      'band.cta': 'Demoga oʻtish',
      'ft.line': 'agnts · Pitch Day 3.0 · Rustambek Abdusalomov',
      'chat.open': 'agnts haqida soʻrash',
      'demo.metaTitle': 'agnts · Demo', 'demo.metaDesc': 'agnts demosi: Jira vazifasidan test qilingan va tekshirilgan pull requestgacha.',
      'demo.label': 'Demo', 'demo.video': 'Video', 'demo.title': 'agnts haqiqiy vazifada.',
      'demo.sub': 'Jiradagi belgilangan vazifadan test qilingan va tekshirilgan pull requestgacha — va bir necha daqiqa oladigan review.',
      'demo.phTitle': 'Demo-video', 'demo.ph': 'Bu yerda 1–5 daqiqalik demo-video boʻladi.',
      'demo.shows': 'Videoda nima koʻrsatilgan',
      'demo.intro': 'Dasturchi vazifani agnts ga topshiradi va faqat javob berish va tasdiqlash uchun aralashadi. Videodagi hamma narsa agnts.uz dagi ishlaydigan mahsulot.',
      'demo.step1': '1-qadam', 'demo.step2': '2-qadam', 'demo.step3': '3-qadam', 'demo.step4': '4-qadam', 'demo.step5': '5-qadam',
      'demo.c1t': 'Vazifaga belgi qoʻyish', 'demo.c1': 'Jiradagi vazifa agnts belgisini oladi. agnts uni oladi, vazifani va kod bazasini oʻqiydi.',
      'demo.c2t': 'Savollarga javob berish', 'demo.c2': 'Noaniq narsalar variantli qisqa savolga aylanadi, javob bir bosishda beriladi.',
      'demo.c3t': 'agnts kod yozadi va test qiladi', 'demo.c3': 'Yangi konteynerda, oʻz branchida. Jonli log build, lint va testlar oʻtayotganini koʻrsatadi.',
      'demo.c4t': 'Natijani koʻrib chiqish', 'demo.c4': 'Xulosa, diff, AI review topilmalari va frontend ishlari uchun oʻzgargan sahifalar skrinshotlari.',
      'demo.c5t': 'Tasdiqlash', 'demo.c5': 'agnts push qiladi, pull request ochadi va vazifani oʻtkazadi. Yoki oʻzgartirish soʻrang — agnts ularni tuzatadi va bundan oʻrganadi.',
      'demo.step6': "6-qadam", 'demo.c6t': "Oʻrganish", 'demo.c6': "Pushdan keyin agnts oʻzgarishni oʻqiydi va undagi har qanday yangilikni (pattern, algoritm, kutubxona) tushuntirish, kodga havolalar va qisqa test bilan darsga aylantiradi. Har bir vazifa bilan faqat kod bazasi emas, dasturchining oʻzi ham oʻsadi.", 
      'demo.proto': 'Ishlayotgan prototip',
      'demo.protoText': 'Demo davrida ishlaydi va bepul. Google orqali kiring, Jira yoki Plane, GitHub yoki GitLab va Claudeni ulang, soʻng vazifaga belgi qoʻying.',
      'demo.protoCta': 'Prototipni ochish', 'demo.back': 'Umumiy sahifaga qaytish'
    }
  };
  var LANGS = ['en', 'ru', 'uz'];
  var en = {};

  // English is the page itself: read it once, so switching back restores it.
  function collect() {
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var k = el.getAttribute('data-i18n');
      if (!(k in en)) en[k] = el.innerHTML;
    });
    document.querySelectorAll('[data-i18n-content]').forEach(function (el) { en[el.getAttribute('data-i18n-content')] = el.getAttribute('content'); });
    document.querySelectorAll('[data-i18n-aria]').forEach(function (el) { en['aria:' + el.getAttribute('data-i18n-aria')] = el.getAttribute('aria-label'); });
  }
  function text(lang, k) {
    var d = T[lang];
    return d && k in d ? d[k] : en[k];
  }
  function pick() {
    var q = new URLSearchParams(location.search).get('lang');
    if (LANGS.indexOf(q) >= 0) return q;
    try { var s = localStorage.getItem('agnts-pitch-lang'); if (LANGS.indexOf(s) >= 0) return s; } catch (e) {}
    var b = (navigator.language || 'en').slice(0, 2).toLowerCase();
    return LANGS.indexOf(b) >= 0 ? b : 'en';
  }
  function apply(lang) {
    document.documentElement.lang = lang;
    document.querySelectorAll('[data-i18n]').forEach(function (el) { el.innerHTML = text(lang, el.getAttribute('data-i18n')); });
    document.querySelectorAll('[data-i18n-content]').forEach(function (el) { el.setAttribute('content', text(lang, el.getAttribute('data-i18n-content'))); });
    document.querySelectorAll('[data-i18n-aria]').forEach(function (el) {
      var k = el.getAttribute('data-i18n-aria');
      el.setAttribute('aria-label', (T[lang] && T[lang][k]) || en['aria:' + k]);
    });
    document.querySelectorAll('.lang button').forEach(function (b) { b.setAttribute('aria-pressed', String(b.getAttribute('data-lang') === lang)); });
    // Links between the two pages carry the language, even without storage.
    document.querySelectorAll('a[href]').forEach(function (a) {
      var h = a.getAttribute('href');
      if (/^(https?:|mailto:|#)/.test(h)) return;
      var u = new URL(h, location.href);
      if (lang === 'en') u.searchParams.delete('lang'); else u.searchParams.set('lang', lang);
      a.setAttribute('href', u.pathname + u.search + u.hash);
    });
    window.agntsLang = lang;
    document.dispatchEvent(new CustomEvent('agnts:lang', { detail: lang }));
  }
  // A new language plays the splash again. A fresh image URL restarts the
  // SVG animation, which a cached image would show at its last frame.
  function replaySplash() {
    var old = document.querySelector('.site-loader');
    if (!old) return;
    var img = old.querySelector('img');
    var fresh = old.cloneNode(true);
    fresh.querySelector('img').src = img.getAttribute('src').split('?')[0] + '?run=' + Date.now();
    old.replaceWith(fresh);
  }
  collect();
  apply(pick());
  document.querySelectorAll('.lang button').forEach(function (b) {
    b.addEventListener('click', function () {
      var lang = b.getAttribute('data-lang');
      try { localStorage.setItem('agnts-pitch-lang', lang); } catch (e) {}
      var u = new URL(location.href);
      if (lang === 'en') u.searchParams.delete('lang'); else u.searchParams.set('lang', lang);
      history.replaceState(null, '', u.pathname + u.search + u.hash);
      replaySplash();
      apply(lang);
    });
  });
})();
