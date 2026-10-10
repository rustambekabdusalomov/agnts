// A small Q&A assistant for the Pitch Day site. It answers from prepared
// questions and answers in this file, in English, Russian and Uzbek:
// no server, no network requests.
(function () {
  var UI = {
    en: { title: 'Ask about agnts', sub: 'Answers from prepared Q&A', hi: 'Hi! Ask me anything about agnts, or pick a question.',
      ph: 'Type a question', ask: 'Ask', close: 'Close',
      fallback: 'I answer from a prepared list of questions about agnts. Try one of the suggestions below, or email abdusalomovrustambek@gmail.com.' },
    ru: { title: 'Спросить об agnts', sub: 'Ответы из подготовленных вопросов', hi: 'Здравствуйте! Спросите что угодно об agnts или выберите вопрос.',
      ph: 'Введите вопрос', ask: 'Спросить', close: 'Закрыть',
      fallback: 'Я отвечаю по подготовленному списку вопросов об agnts. Выберите один из вариантов ниже или напишите на abdusalomovrustambek@gmail.com.' },
    uz: { title: 'agnts haqida soʻrash', sub: 'Tayyorlangan savol-javoblar asosida', hi: 'Salom! agnts haqida istalgan narsani soʻrang yoki savolni tanlang.',
      ph: 'Savolingizni yozing', ask: 'Soʻrash', close: 'Yopish',
      fallback: 'Men agnts haqidagi tayyorlangan savollar roʻyxati asosida javob beraman. Quyidagi variantlardan birini tanlang yoki abdusalomovrustambek@gmail.com ga yozing.' }
  };
  var QA = [
    { k: 'what agnts about product do что такое продукт делает nima mahsulot qiladi',
      q: { en: 'What is agnts?', ru: 'Что такое agnts?', uz: 'agnts nima?' },
      a: { en: 'agnts is an AI agent that takes tickets from Jira or Plane, reads your code, asks what is unclear, codes and tests the change in an isolated container, and opens a pull request after you approve it.',
           ru: 'agnts — ИИ-агент, который берёт задачи из Jira или Plane, читает ваш код, спрашивает о неясном, пишет и тестирует изменение в изолированном контейнере и открывает pull request после вашего одобрения.',
           uz: 'agnts — vazifalarni Jira yoki Planedan oladigan, kodingizni oʻqiydigan, noaniq narsalarni soʻraydigan, oʻzgarishni izolyatsiyalangan konteynerda yozib test qiladigan va siz tasdiqlagach pull request ochadigan AI agent.' } },
    { k: 'how work works flow process pipeline steps как работает процесс шаги qanday ishlaydi jarayon qadamlar',
      q: { en: 'How does it work?', ru: 'Как это работает?', uz: 'Qanday ishlaydi?' },
      a: { en: 'Label a ticket "agnts". It analyses the ticket and your code, asks short questions if needed, codes in a fresh container, runs your build, lint and tests, gets an AI review, and waits for your approval. Then it pushes and opens the pull request.',
           ru: 'Поставьте задаче метку «agnts». Он анализирует задачу и код, при необходимости задаёт короткие вопросы, пишет код в новом контейнере, запускает сборку, линтер и тесты, получает ИИ-ревью и ждёт вашего одобрения. Затем пушит и открывает pull request.',
           uz: 'Vazifaga «agnts» belgisini qoʻying. U vazifa va kodni tahlil qiladi, kerak boʻlsa qisqa savollar beradi, yangi konteynerda kod yozadi, build, lint va testlarni ishga tushiradi, AI review oladi va tasdigʻingizni kutadi. Soʻng push qilib, pull request ochadi.' } },
    { k: 'safe safety push deploy own security secure approve approval itself безопасно безопасность сам деплой одобрение xavfsiz xavfsizlik oʻzi deploy tasdiqlash',
      q: { en: 'Can it push or deploy on its own?', ru: 'Может ли он сам запушить или задеплоить?', uz: 'U oʻzi push yoki deploy qila oladimi?' },
      a: { en: 'No. The agent runs in an isolated container that can reach only Claude, your git host and package registries. agnts pushes only after you approve the diff.',
           ru: 'Нет. Агент работает в изолированном контейнере, которому доступны только Claude, ваш git-хостинг и реестры пакетов. agnts пушит только после того, как вы одобрите diff.',
           uz: 'Yoʻq. Agent faqat Claude, git xostingingiz va paket reyestrlariga ulana oladigan izolyatsiyalangan konteynerda ishlaydi. agnts faqat siz diffni tasdiqlaganingizdan keyin push qiladi.' } },
    { k: 'price pricing cost pay free plan money цена стоимость сколько бесплатно оплата тариф narx necha pul bepul toʻlov tarif',
      q: { en: 'How much does it cost?', ru: 'Сколько это стоит?', uz: 'Narxi qancha?' },
      a: { en: 'agnts is free while it is in demo. After the demo, agnts moves to paid plans.',
           ru: 'Пока идёт демо, agnts бесплатен. После демо agnts перейдёт на платные тарифы.',
           uz: 'Demo davrida agnts bepul. Demodan keyin agnts pullik tariflarga oʻtadi.' } },
    { k: 'jira plane github gitlab integration integrations connector connectors tools интеграции коннекторы инструменты integratsiya konnektor vositalar',
      q: { en: 'Which tools does it work with?', ru: 'С какими инструментами работает?', uz: 'Qaysi vositalar bilan ishlaydi?' },
      a: { en: 'Jira and Plane for tickets, GitHub and GitLab for code and pull requests, Claude for the AI, and Telegram for notifications. Teams can request new connectors on agnts.uz.',
           ru: 'Jira и Plane для задач, GitHub и GitLab для кода и pull request, Claude для ИИ и Telegram для уведомлений. Новые коннекторы можно запросить на agnts.uz.',
           uz: 'Vazifalar uchun Jira va Plane, kod va pull requestlar uchun GitHub va GitLab, AI uchun Claude, bildirishnomalar uchun Telegram. Yangi konnektorlarni agnts.uz da soʻrash mumkin.' } },
    { k: 'ai model models claude sonnet opus haiku llm chatgpt gpt openai kimi gemini ии модель модели нейросеть sun\'iy intellekt model',
      q: { en: 'Which AI does it use?', ru: 'Какой ИИ используется?', uz: 'Qaysi AI ishlatiladi?' },
      a: { en: 'agnts runs Claude Code: Sonnet writes the code, Opus handles hard retries and reviews of complex changes, and Haiku does summaries and small helper steps. Next, agnts will support more AI models, such as ChatGPT and Kimi.',
           ru: 'agnts работает на Claude Code: Sonnet пишет код, Opus берёт сложные повторы и ревью сложных изменений, а Haiku делает сводки и небольшие вспомогательные шаги. Дальше agnts будет поддерживать и другие ИИ-модели, например ChatGPT и Kimi.',
           uz: 'agnts Claude Code da ishlaydi: Sonnet kod yozadi, Opus qiyin qayta urinishlar va murakkab oʻzgarishlar reviewini bajaradi, Haiku esa xulosalar va kichik yordamchi qadamlarni bajaradi. Keyinchalik agnts boshqa AI modellarni ham, masalan ChatGPT va Kimini qoʻllab-quvvatlaydi.' } },
    { k: 'learn learns mistake mistakes feedback better smarter учится ошибки ошибка отзывы oʻrganadi xato xatolar fikr',
      q: { en: 'Does it learn from mistakes?', ru: 'Учится ли он на ошибках?', uz: 'Xatolardan oʻrganadimi?' },
      a: { en: 'Yes. When you request changes, agnts fixes them and distils lessons and suggested team rules. A person approves each rule before it is used in later tickets.',
           ru: 'Да. Когда вы запрашиваете изменения, agnts исправляет их, выделяет уроки и предлагает правила команды. Человек одобряет каждое правило, прежде чем оно применяется к следующим задачам.',
           uz: 'Ha. Oʻzgartirish soʻraganingizda agnts ularni tuzatadi, saboqlarni ajratadi va jamoa qoidalarini taklif qiladi. Har bir qoida keyingi vazifalarda ishlatilishidan oldin inson tomonidan tasdiqlanadi.' } },
    { k: 'team founder who built rustambek команда основатель кто создал jamoa asoschi kim yaratgan',
      q: { en: 'Who is behind agnts?', ru: 'Кто стоит за agnts?', uz: 'agnts ortida kim turibdi?' },
      a: { en: 'Rustambek Abdusalomov, a software engineer and team lead with over 5 years of experience, who designed and built agnts and uses it on real work.',
           ru: 'Рустамбек Абдусаломов — инженер-программист и тимлид с опытом более 5 лет, который спроектировал и построил agnts и использует его в реальной работе.',
           uz: 'Rustambek Abdusalomov — 5 yildan ortiq tajribaga ega dasturiy taʼminot muhandisi va jamoa rahbari, agnts ni loyihalab, yaratgan va undan haqiqiy ishda foydalanadi.' } },
    { k: 'stage roadmap mvp launch status when стадия этап запуск когда дорожная bosqich ishga tushirish qachon yoʻl xaritasi',
      q: { en: 'What stage is agnts at?', ru: 'На какой стадии agnts?', uz: 'agnts qaysi bosqichda?' },
      a: { en: 'MVP: live at agnts.uz with a free demo and first users. Next is the launch with paid plans, the mobile app in the app stores and new connectors.',
           ru: 'MVP: работает на agnts.uz с бесплатным демо и первыми пользователями. Дальше — запуск с платными тарифами, мобильным приложением в магазинах и новыми коннекторами.',
           uz: 'MVP: agnts.uz da bepul demo va birinchi foydalanuvchilar bilan ishlamoqda. Keyingisi — pullik tariflar, ilova doʻkonlaridagi mobil ilova va yangi konnektorlar bilan ishga tushirish.' } },
    { k: 'mobile phone app ios android telegram мобильное телефон приложение mobil telefon ilova',
      q: { en: 'Is there a mobile app?', ru: 'Есть ли мобильное приложение?', uz: 'Mobil ilova bormi?' },
      a: { en: 'Yes, a Flutter app for iOS and Android to answer questions, review and approve from your phone. It is in testing now and goes to the app stores after that. Telegram notifications already work.',
           ru: 'Да, приложение на Flutter для iOS и Android, чтобы отвечать на вопросы, делать ревью и одобрять с телефона. Сейчас оно в тестировании, затем появится в магазинах. Уведомления в Telegram уже работают.',
           uz: 'Ha, telefoningizdan savollarga javob berish, review qilish va tasdiqlash uchun iOS va Android uchun Flutter ilovasi. Hozir sinovda, keyin ilova doʻkonlariga chiqadi. Telegram bildirishnomalari allaqachon ishlaydi.' } },
    { k: 'api mcp rest openapi integrate',
      q: { en: 'Is there an API?', ru: 'Есть ли API?', uz: 'API bormi?' },
      a: { en: 'Yes. Everything in agnts is a REST API described by OpenAPI, and an MCP server lets you manage agnts from Claude chat, Claude Code or Claude Desktop.',
           ru: 'Да. Всё в agnts — REST API, описанный OpenAPI, а MCP-сервер позволяет управлять agnts из чата Claude, Claude Code или Claude Desktop.',
           uz: 'Ha. agnts dagi hamma narsa OpenAPI bilan tavsiflangan REST API, MCP server esa agnts ni Claude chat, Claude Code yoki Claude Desktopdan boshqarish imkonini beradi.' } },
    { k: 'language languages uzbek russian english uz ru язык языки узбекский русский til tillar oʻzbek rus ingliz',
      q: { en: 'Which languages are supported?', ru: 'Какие языки поддерживаются?', uz: 'Qaysi tillar qoʻllab-quvvatlanadi?' },
      a: { en: 'The website and the admin panel are in English, Russian and Uzbek.',
           ru: 'Сайт и админ-панель доступны на английском, русском и узбекском.',
           uz: 'Sayt va admin panel ingliz, rus va oʻzbek tillarida.' } },
    { k: 'try start demo signup sign account use попробовать начать демо аккаунт войти sinab boshlash demo akkaunt kirish',
      q: { en: 'How can I try it?', ru: 'Как попробовать?', uz: 'Qanday sinab koʻrsam boʻladi?' },
      a: { en: 'Open agnts.uz and sign in with Google. Connect Jira or Plane, GitHub or GitLab and your Claude plan, then label your first ticket.',
           ru: 'Откройте agnts.uz и войдите через Google. Подключите Jira или Plane, GitHub или GitLab и ваш план Claude, затем поставьте метку на первую задачу.',
           uz: 'agnts.uz ni oching va Google orqali kiring. Jira yoki Plane, GitHub yoki GitLab va Claude tarifingizni ulang, soʻng birinchi vazifangizga belgi qoʻying.' } }
  ];
  QA.forEach(function (x) { x.k = x.k.toLowerCase().split(/\s+/); });
  var STARTERS = [0, 1, 2, 3, 12];

  var box = document.getElementById('chat');
  var openBtn = document.getElementById('chat-open');
  if (!box || !openBtn) return;
  var lang = function () { return UI[window.agntsLang] ? window.agntsLang : 'en'; };
  var log, sugg, input;

  function build() {
    var u = UI[lang()];
    box.innerHTML =
      '<div class="chat-h"><div><b></b><small></small></div><button type="button" class="chat-x">&times;</button></div>' +
      '<div class="chat-log" aria-live="polite"></div><div class="sugg"></div>' +
      '<form class="chat-f"><input type="text" maxlength="200"><button type="submit" class="btn btn-dark btn-s"></button></form>';
    box.querySelector('.chat-h b').textContent = u.title;
    box.querySelector('.chat-h small').textContent = u.sub;
    box.querySelector('.chat-x').setAttribute('aria-label', u.close);
    box.querySelector('.chat-f button').textContent = u.ask;
    log = box.querySelector('.chat-log');
    sugg = box.querySelector('.sugg');
    input = box.querySelector('input');
    input.placeholder = u.ph;
    input.setAttribute('aria-label', u.ph);
    box.querySelector('.chat-x').onclick = function () { setOpen(false); };
    box.querySelector('form').onsubmit = function (e) {
      e.preventDefault();
      var t = input.value.trim();
      if (!t) return;
      input.value = '';
      ask(t);
    };
    say(u.hi, 'bot');
    suggest(STARTERS);
  }
  function say(text, who) {
    var m = document.createElement('div');
    m.className = 'msg ' + who;
    m.textContent = text;
    log.appendChild(m);
    log.scrollTop = log.scrollHeight;
  }
  function suggest(ids) {
    sugg.innerHTML = '';
    ids.forEach(function (i) {
      var b = document.createElement('button');
      b.type = 'button';
      b.textContent = QA[i].q[lang()];
      b.onclick = function () { ask(QA[i].q[lang()], i); };
      sugg.appendChild(b);
    });
  }
  function match(text) {
    var words = text.toLowerCase().replace(/[^\p{L}\p{N}ʻ'\s]/gu, ' ').split(/\s+/).filter(Boolean);
    var best = -1, score = 0;
    QA.forEach(function (x, i) {
      var s = 0;
      words.forEach(function (w) {
        if (x.k.indexOf(w) >= 0) s += w.length > 3 ? 2 : 1;
        else if (w.length > 4 && x.k.some(function (k) { return k.length > 4 && (k.indexOf(w.slice(0, 5)) === 0); })) s += 1;
      });
      if (s > score) { score = s; best = i; }
    });
    return score >= 2 ? best : -1;
  }
  function ask(text, known) {
    say(text, 'me');
    var i = known !== undefined ? known : match(text);
    setTimeout(function () {
      say(i >= 0 ? QA[i].a[lang()] : UI[lang()].fallback, 'bot');
      var rest = QA.map(function (_, j) { return j; }).filter(function (j) { return j !== i; });
      suggest(rest.sort(function () { return Math.random() - 0.5; }).slice(0, 3));
    }, 250);
  }
  function setOpen(on) {
    box.classList.toggle('open', on);
    openBtn.setAttribute('aria-expanded', String(on));
    if (on) input.focus(); else openBtn.focus();
  }
  build();
  // A new language starts the conversation over in that language.
  document.addEventListener('agnts:lang', build);
  openBtn.onclick = function () { setOpen(!box.classList.contains('open')); };
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && box.classList.contains('open')) setOpen(false); });
})();
