import 'l10n.dart';

class DevTip {
  final String title, titleTr, body, bodyTr;
  final String? code;
  const DevTip(this.title, this.titleTr, this.body, this.bodyTr, [this.code]);

  String titleFor(AppLang l) => l == AppLang.tr ? titleTr : title;
  String bodyFor(AppLang l) => l == AppLang.tr ? bodyTr : body;
}

const devTips = <DevTip>[
  DevTip(
    'What is git push?',
    'git push nedir?',
    'Uploads your local commits to a remote repository such as GitHub, so your teammates can see them.',
    "Yerel commit'lerinizi GitHub gibi uzak bir depoya yükler, böylece ekip arkadaşlarınız görebilir.",
    'git push origin main',
  ),
  DevTip(
    'What is git pull?',
    'git pull nedir?',
    'Fetches new commits from the remote and merges them into your current branch.',
    "Uzak depodaki yeni commit'leri getirir ve bulunduğunuz dalla birleştirir.",
    'git pull origin main',
  ),
  DevTip(
    'What is git stash?',
    'git stash nedir?',
    'Temporarily shelves uncommitted changes so you can switch branches with a clean working directory.',
    'Commit edilmemiş değişikliklerinizi geçici olarak kenara alır; böylece temiz bir çalışma dizini ile başka bir dala geçebilirsiniz.',
    'git stash\ngit stash pop',
  ),
  DevTip(
    'Git merge vs rebase',
    'Git merge ve rebase farkı',
    'Merge keeps history as it happened and adds a merge commit. Rebase replays your commits on top of another branch for a linear history. Avoid rebasing commits you have already shared.',
    "Merge, geçmişi olduğu gibi korur ve bir birleştirme commit'i ekler. Rebase ise commit'lerinizi başka bir dalın üzerine yeniden uygulayarak doğrusal bir geçmiş oluşturur. Daha önce paylaştığınız commit'leri rebase etmekten kaçının.",
    'git rebase main',
  ),
  DevTip(
    'What is a pull request?',
    'Pull request nedir?',
    'A request to merge your branch into another one. It gives teammates a place to review and discuss the changes first.',
    'Dalınızı başka bir dala birleştirme isteğidir. Ekip arkadaşlarınıza değişiklikleri önce inceleme ve tartışma imkânı verir.',
  ),
  DevTip(
    'What is Big-O notation?',
    'Big-O notasyonu nedir?',
    "It describes how an algorithm's running time or memory grows as the input grows. O(n) grows linearly, O(n²) grows much faster.",
    'Girdi büyüdükçe bir algoritmanın çalışma süresinin veya bellek kullanımının nasıl arttığını anlatır. O(n) doğrusal artar, O(n²) çok daha hızlı büyür.',
  ),
  DevTip(
    'What is an API?',
    'API nedir?',
    'A defined way for programs to talk to each other: you send a request in an agreed format and get a response back.',
    'Programların birbiriyle konuşması için tanımlanmış bir yoldur: Kararlaştırılan biçimde bir istek gönderirsiniz ve karşılığında bir yanıt alırsınız.',
  ),
  DevTip(
    'HTTP 404 vs 500',
    'HTTP 404 ve 500',
    '404 means the resource was not found, usually because the client asked for something wrong. 500 means the server hit an unexpected error.',
    '404, kaynağın bulunamadığı anlamına gelir; genellikle istemci yanlış bir şey istemiştir. 500 ise sunucunun beklenmedik bir hatayla karşılaştığını gösterir.',
  ),
  DevTip(
    'What is a race condition?',
    'Race condition nedir?',
    'A bug where the result depends on the timing of operations, for example two threads updating the same variable at once.',
    'Sonucun işlemlerin zamanlamasına bağlı olduğu bir hatadır; örneğin iki iş parçacığının aynı değişkeni aynı anda güncellemesi.',
  ),
  DevTip(
    'What does chmod 755 do?',
    'chmod 755 ne yapar?',
    'Sets file permissions: the owner can read, write and execute; everyone else can read and execute.',
    'Dosya izinlerini ayarlar: sahibi okuyabilir, yazabilir ve çalıştırabilir; diğer herkes okuyabilir ve çalıştırabilir.',
    'chmod 755 script.sh',
  ),
  DevTip(
    'Docker image vs container',
    'Docker image ve container farkı',
    'An image is a read-only template with your app and its dependencies. A container is a running instance of an image.',
    "Image, uygulamanızı ve bağımlılıklarını içeren salt okunur bir şablondur. Container ise bir image'ın çalışan örneğidir.",
  ),
  DevTip(
    'What is idempotency?',
    'İdempotentlik nedir?',
    'An operation is idempotent if doing it many times has the same effect as doing it once. HTTP PUT and DELETE are defined this way.',
    'Bir işlemi birçok kez yapmanın, bir kez yapmakla aynı etkiyi yaratmasıdır. HTTP PUT ve DELETE bu şekilde tanımlanmıştır.',
  ),
  DevTip(
    'What is an SQL INNER JOIN?',
    'SQL INNER JOIN nedir?',
    'Returns only the rows that have matching values in both tables.',
    'Yalnızca iki tabloda da eşleşen değerlere sahip satırları döndürür.',
    'SELECT u.name, o.total\nFROM users u\nINNER JOIN orders o ON o.user_id = u.id;',
  ),
  DevTip(
    'What do async and await do?',
    'async ve await ne işe yarar?',
    'They let you write asynchronous code that reads like normal sequential code, waiting for a result without blocking the whole program.',
    'Asenkron kodu normal sıralı kod gibi okunur şekilde yazmanızı sağlar; programın tamamını engellemeden bir sonucu beklersiniz.',
    'final data = await fetchData();',
  ),
  DevTip(
    'What is the DRY principle?',
    'DRY prensibi nedir?',
    "Don't Repeat Yourself: each piece of knowledge should live in one place, so a change only has to happen once.",
    "Don't Repeat Yourself (Kendini Tekrar Etme): Her bilgi tek bir yerde bulunmalıdır, böylece bir değişikliğin yalnızca bir kez yapılması yeterli olur.",
  ),
  DevTip(
    'What is CI/CD?',
    'CI/CD nedir?',
    'Continuous Integration automatically builds and tests every change. Continuous Delivery or Deployment automatically ships changes that pass.',
    'Sürekli Entegrasyon her değişikliği otomatik olarak derler ve test eder. Sürekli Teslimat veya Dağıtım ise testleri geçen değişiklikleri otomatik olarak yayına alır.',
  ),
];

const breakIdeasEn = <String>[
  'Stand up and stretch your back and shoulders.',
  'Look at something far away for 20 seconds to rest your eyes.',
  'Drink a glass of water.',
  'Walk around for a couple of minutes.',
  'Open and close your hands to rest your wrists.',
  'Take a few slow, deep breaths.',
];

const breakIdeasTr = <String>[
  'Ayağa kalkın; sırtınızı ve omuzlarınızı esnetin.',
  'Gözlerinizi dinlendirmek için 20 saniye uzaktaki bir şeye bakın.',
  'Bir bardak su için.',
  'Birkaç dakika etrafta yürüyün.',
  'Bileklerinizi dinlendirmek için ellerinizi açıp kapatın.',
  'Birkaç yavaş ve derin nefes alın.',
];

String breakIdea(AppLang lang, int i) {
  final list = lang == AppLang.tr ? breakIdeasTr : breakIdeasEn;
  return list[i % list.length];
}

DevTip tipForToday(int shift) {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return devTips[(dayOfYear + shift) % devTips.length];
}