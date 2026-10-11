import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'l10n.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _runningId = 1;
  static const _focusDoneId = 2;
  static const _breakDoneId = 3;
  static const _pausedId = 4;

  static bool _serviceActive = false;
  static bool _serviceFailed = false;

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Notification errors must never crash the timer.
  static Future<void> _safe(Future<void> Function() job) async {
    try {
      await job();
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  static String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static Future<void> init() => _safe(() async {
        tzdata.initializeTimeZones();
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('ic_stat_pomodoro'),
          ),
        );
      });

  static Future<void> requestPermission() =>
      _safe(() async => await _android?.requestNotificationsPermission());

  /// Opens the system screen where the user can allow exact alarms.
  static Future<void> requestExactAlarms() =>
      _safe(() async => await _android?.requestExactAlarmsPermission());

  /// Live countdown. The first call starts the foreground service;
  /// later calls (once per second) only update the text.
  static Future<void> showRunning({
    required L10n l,
    required String phaseTitle,
    required int remaining,
    required int total,
    bool first = false,
  }) =>
      _safe(() async {
        final details = AndroidNotificationDetails(
          'timer_running',
          l.chanRunning,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          playSound: false,
          enableVibration: false,
          showWhen: false,
          showProgress: true,
          maxProgress: total,
          progress: (total - remaining).clamp(0, total).toInt(),
        );
        final title = _mmss(remaining);
        final body = l.notifBody(phaseTitle);

        if (first) await _plugin.cancel(id: _pausedId);

        if (!_serviceActive && !_serviceFailed) {
          try {
            await _android?.startForegroundService(
              id: _runningId,
              title: title,
              body: body,
              notificationDetails: details,
            );
            _serviceActive = true;
            return;
          } catch (e) {
            // Fall back to a normal ongoing notification.
            _serviceFailed = true;
            debugPrint('Foreground service unavailable: $e');
          }
        }
        await _plugin.show(
          id: _runningId,
          title: title,
          body: body,
          notificationDetails: NotificationDetails(android: details),
        );
      });

  static Future<void> stopRunning() => _safe(() async {
        _serviceFailed = false;
        if (_serviceActive) {
          _serviceActive = false;
          await _android?.stopForegroundService();
        }
        await _plugin.cancel(id: _runningId);
      });

  static Future<void> showPaused({
    required L10n l,
    required String title,
    required int remainingSeconds,
  }) =>
      _safe(() async {
        await _plugin.show(
          id: _pausedId,
          title: l.notifPaused(title),
          body: l.timeLeft(_mmss(remainingSeconds)),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'timer_running',
              l.chanRunning,
              importance: Importance.low,
              priority: Priority.low,
              autoCancel: false,
              onlyAlertOnce: true,
              playSound: false,
              enableVibration: false,
              showWhen: false,
            ),
          ),
        );
      });

  /// Alert at the end of the session, works even if the app is closed.
  static Future<void> scheduleDone({
    required L10n l,
    required bool focusFinished,
    required bool nextIsLong,
    required DateTime endAt,
  }) =>
      _safe(() async {
        final canExact =
            await _android?.canScheduleExactNotifications() ?? false;
        await _plugin.zonedSchedule(
          id: focusFinished ? _focusDoneId : _breakDoneId,
          title: focusFinished ? l.focusDone : l.breakOver,
          body: focusFinished ? l.timeForBreak(nextIsLong) : l.readyNext,
          // One second after the end, so the app can cancel it first
          // when it is open in the foreground.
          scheduledDate: tz.TZDateTime.from(
              endAt.add(const Duration(seconds: 1)), tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'timer_done',
              l.chanDone,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: canExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      });

  static Future<void> cancelDone({required bool focus}) => _safe(() async =>
      await _plugin.cancel(id: focus ? _focusDoneId : _breakDoneId));

  static Future<void> cancelAll() async {
    await stopRunning();
    await _safe(() async => await _plugin.cancelAll());
  }
}