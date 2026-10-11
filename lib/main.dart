import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'detector.dart';
import 'home_page.dart';
import 'l10n.dart';
import 'notification_service.dart';
import 'pomodoro_timer.dart';
import 'settings.dart';
import 'settings_page.dart';
import 'stats.dart';
import 'stats_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  final stats = StatsStore();
  await Future.wait([settings.load(), stats.load()]);
  await NotificationService.init();
  final detector = DeskDetector();
  await detector.load();
  runApp(DevPomodoroApp(
    settings: settings,
    stats: stats,
    timer: PomodoroTimer(settings, stats),
    detector: detector,
  ));
}

class DevPomodoroApp extends StatelessWidget {
  final AppSettings settings;
  final StatsStore stats;
  final PomodoroTimer timer;
  final DeskDetector detector;
  const DevPomodoroApp({
    super.key,
    required this.settings,
    required this.stats,
    required this.timer,
    required this.detector,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Dev Pomodoro',
        debugShowCheckedModeBanner: false,
        themeMode: settings.themeMode,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        locale: Locale(settings.lang.name),
        supportedLocales: const [Locale('en'), Locale('tr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Shell(
          settings: settings,
          stats: stats,
          timer: timer,
          detector: detector,
        ),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  final AppSettings settings;
  final StatsStore stats;
  final PomodoroTimer timer;
  final DeskDetector detector;
  const Shell({
    super.key,
    required this.settings,
    required this.stats,
    required this.timer,
    required this.detector,
  });

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.timer.appInForeground = state == AppLifecycleState.resumed;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final l = widget.settings.l;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF050A16), Color(0xFF0A1530)]
              : const [Color(0xFFF6FAFF), Color(0xFFE4EFFF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(index: _index, children: [
            HomePage(
              timer: widget.timer,
              settings: widget.settings,
              stats: widget.stats,
              detector: widget.detector,
            ),
            StatsPage(stats: widget.stats, settings: widget.settings),
            SettingsPage(settings: widget.settings, stats: widget.stats),
          ]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          backgroundColor: context.pCard,
          indicatorColor: context.pAccent.withAlpha(40),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
                icon: const Icon(Icons.timer_outlined),
                selectedIcon: const Icon(Icons.timer),
                label: l.navHome),
            NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l.navStats),
            NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l.navSettings),
          ],
        ),
      ),
    );
  }
}