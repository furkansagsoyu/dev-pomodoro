enum AppLang { en, tr }

class L10n {
  final AppLang lang;
  const L10n(this.lang);

  bool get _tr => lang == AppLang.tr;
  String _t(String en, String tr) => _tr ? tr : en;

  // Navigation
  String get navHome => _t('Home', 'Ana sayfa');
  String get navStats => _t('Statistics', 'İstatistikler');
  String get navSettings => _t('Settings', 'Ayarlar');

  // Phases
  String get focus => _t('Focus', 'Odak');
  String get shortBreak => _t('Short break', 'Kısa mola');
  String get longBreak => _t('Long break', 'Uzun mola');

  // Home
  String todayCount(int n, int goal) => _t('$n/$goal today', '$n/$goal bugün');
  String get focusDone =>
      _t('Focus session complete!', 'Odak oturumu tamamlandı!');
  String get breakOver => _t('Break is over', 'Mola bitti');
  String timeForBreak(bool isLong) => _t(
        'Time for a ${isLong ? 'long' : 'short'} break.',
        '${isLong ? 'Uzun' : 'Kısa'} mola zamanı.',
      );
  String get readyNext => _t(
        'Ready for the next focus session? Clear your desk, then press play.',
        'Sıradaki odak oturumuna hazır mısınız? Masanızı toparlayın, sonra oynat tuşuna basın.',
      );
  String get gotIt => _t('Got it', 'Tamam');
  String get breakTime => _t('Break time', 'Mola zamanı');
  String get breakReminder => _t('Break reminder', 'Mola hatırlatıcısı');
  String reminderBody(String longText) => _t(
        "You'll get a reminder when this session ends. $longText",
        'Bu oturum bittiğinde size hatırlatılacak. $longText',
      );
  String longBreakAfter(int n) => n == 1
      ? _t('A long break comes after this session.',
          'Uzun mola bu oturumdan sonra.')
      : _t('A long break comes after $n more sessions.',
          'Uzun mola $n oturum sonra.');
  String get dailyBrief => _t('DAILY BRIEF', 'GÜNÜN BİLGİSİ');
  String get anotherTip => _t('Another tip', 'Başka bir ipucu');
  String get reset => _t('Reset', 'Sıfırla');
  String get skipBreak => _t('Skip break', 'Molayı atla');

  // Desk scan
  String get showDesk =>
      _t('Show your desk to the camera', 'Masanızı kameraya gösterin');
  String get scanDesk => _t('Scan my desk', 'Masamı tara');
  String get cameraUnavailable =>
      _t('Camera unavailable.', 'Kamera kullanılamıyor.');
  String get tryAgain => _t('Try again', 'Tekrar dene');
  String get startWithoutScan =>
      _t('Start without scan', 'Taramadan başla');
  String get deskCheck => _t('Desk check', 'Masa kontrolü');
  String get deskClear => _t('Your desk looks clear. Good luck!',
      'Masanız temiz görünüyor. Başarılar!');
  String distractionsFound(String list) => _t(
        'Possible distractions: $list.\nMove them away before you start.',
        'Olası dikkat dağıtıcılar: $list.\nBaşlamadan önce bunları uzaklaştırın.',
      );
  String get rescan => _t('Rescan', 'Yeniden tara');
  String get startTimer => _t('Start timer', 'Zamanlayıcıyı başlat');
  String get startAnyway => _t('Start anyway', 'Yine de başla');

  static const _objTr = {
    'cell phone': 'telefon',
    'cup': 'fincan',
    'bottle': 'şişe',
    'wine glass': 'kadeh',
    'bowl': 'kase',
    'banana': 'muz',
    'apple': 'elma',
    'sandwich': 'sandviç',
    'orange': 'portakal',
    'donut': 'donut',
    'cake': 'pasta',
    'pizza': 'pizza',
    'hot dog': 'sosisli',
    'remote': 'kumanda',
    'tv': 'televizyon',
    'cat': 'kedi',
    'dog': 'köpek',
    'teddy bear': 'oyuncak ayı',
    'sports ball': 'top',
  };
  String object(String label) => _tr ? (_objTr[label] ?? label) : label;

  // Statistics
  String get statsTitle => _t('Statistics', 'İstatistikler');
  String get today => _t('TODAY', 'BUGÜN');
  String get focused => _t('focused', 'odaklanıldı');
  String sessionsCount(int n, int goal) =>
      _t('$n/$goal sessions', '$n/$goal oturum');
  String get last7 => _t('Last 7 days', 'Son 7 gün');
  List<String> get weekdays => _tr
      ? ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String get dayStreak => _t('day streak', 'günlük seri');
  String get totalFocus => _t('total focus', 'toplam odak');
  String get sessionsDone => _t('sessions done', 'tamamlanan oturum');
  String get deskWarnings => _t('desk warnings', 'masa uyarısı');

  String dur(int seconds) {
    final m = seconds ~/ 60;
    final hu = _t('h', 'sa');
    final mu = _t('m', 'dk');
    if (m < 60) return '$m$mu';
    final h = m ~/ 60;
    final r = m % 60;
    return r == 0 ? '$h$hu' : '$h$hu $r$mu';
  }

  // Settings
  String get settingsTitle => _t('Settings', 'Ayarlar');
  String get secTimer => _t('TIMER', 'ZAMANLAYICI');
  String get secDesk => _t('DESK SCAN', 'MASA TARAMASI');
  String get secNotifications => _t('NOTIFICATIONS', 'BİLDİRİMLER');
  String get secBehavior => _t('BEHAVIOR', 'DAVRANIŞ');
  String get secAppearance => _t('APPEARANCE', 'GÖRÜNÜM');
  String get secLanguage => _t('LANGUAGE', 'DİL');
  String get secData => _t('DATA', 'VERİ');
  String get focusLength => _t('Focus length', 'Odak süresi');
  String get sessionsBeforeLong =>
      _t('Sessions before long break', 'Uzun moladan önceki oturum');
  String get dailyGoal => _t('Daily goal', 'Günlük hedef');
  String get unitMin => _t('min', 'dk');
  String get unitSessions => _t('sessions', 'oturum');
  String get scanBefore =>
      _t('Scan desk before focusing', 'Odaklanmadan önce masayı tara');
  String get scanBeforeSub => _t('Warns you about distracting objects',
      'Dikkat dağıtıcı nesneler için uyarır');
  String get threshold => _t('Detection threshold', 'Algılama eşiği');
  String get thresholdHelp => _t(
        'Higher means fewer false alarms but more missed objects.',
        'Yüksek değer yanlış alarmı azaltır ama bazı nesneler kaçabilir.',
      );
  String get notifTimer => _t('Timer notification', 'Zamanlayıcı bildirimi');
  String get notifTimerSub => _t('Shows the time left in the notification panel',
      'Kalan süreyi bildirim panelinde gösterir');
  String get notifExact => _t('Allow exact alarms', 'Tam zamanlı alarmlara izin ver');
  String get notifExactSub => _t(
        'Makes the end-of-session alert arrive on time when the app is closed',
        'Uygulama kapalıyken oturum sonu uyarısının tam zamanında gelmesini sağlar',
      );
  String get autoStartBreaks =>
      _t('Auto-start breaks', 'Molaları otomatik başlat');
  String get vibrateEnd => _t('Vibrate and sound when a session ends',
      'Oturum bitince titreşim ve ses');
  String get showBrief => _t('Show daily brief', 'Günün bilgisini göster');
  String get themeSystem => _t('System', 'Sistem');
  String get themeLight => _t('Light', 'Açık');
  String get themeDark => _t('Dark', 'Koyu');
  String get resetStats => _t('Reset statistics', 'İstatistikleri sıfırla');
  String get resetTitle =>
      _t('Reset statistics?', 'İstatistikler sıfırlansın mı?');
  String get resetBody => _t('All saved daily records will be deleted.',
      'Kaydedilmiş tüm günlük kayıtlar silinecek.');
  String get cancel => _t('Cancel', 'İptal');
  String get delete => _t('Delete', 'Sil');

  // Notifications
  String notifBody(String phase) => _t('$phase · tap to open the app',
    '$phase · uygulamayı açmak için dokunun');
  String notifPaused(String phase) =>
      _t('$phase · paused', '$phase · duraklatıldı');
  String timeLeft(String mmss) => _t('$mmss left', '$mmss kaldı');
  String get chanRunning => _t('Running timer', 'Çalışan zamanlayıcı');
  String get chanDone => _t('Session alerts', 'Oturum uyarıları');
}