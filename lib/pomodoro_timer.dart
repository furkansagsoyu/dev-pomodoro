import 'dart:async';
import 'package:flutter/foundation.dart';
import 'l10n.dart';
import 'notification_service.dart';
import 'settings.dart';
import 'stats.dart';

enum Phase { focus, shortBreak, longBreak }

extension PhaseInfo on Phase {
  String title(L10n l) => switch (this) {
        Phase.focus => l.focus,
        Phase.shortBreak => l.shortBreak,
        Phase.longBreak => l.longBreak,
      };
  bool get isBreak => this != Phase.focus;
}

class PomodoroTimer extends ChangeNotifier {
  PomodoroTimer(this.settings, this.stats) {
    _resetRemaining();
    settings.addListener(_onSettings);
  }

  final AppSettings settings;
  final StatsStore stats;

  Phase phase = Phase.focus;
  int remaining = 0; // seconds
  int completedFocus = 0;
  bool running = false;
  bool appInForeground = true; // set by the app shell
  int _phaseTotal = 0;
  DateTime? _endAt;
  Timer? _ticker;

  /// Called when a phase ends (UI shows the reminder).
  void Function(Phase finished)? onPhaseFinished;

  int get total => _phaseTotal;

  int get sessionsUntilLong =>
      settings.sessionsBeforeLong -
      (completedFocus % settings.sessionsBeforeLong);

  int _durationFor(Phase p) => 60 *
      switch (p) {
        Phase.focus => settings.focusMin,
        Phase.shortBreak => settings.shortBreakMin,
        Phase.longBreak => settings.longBreakMin,
      };

  void _resetRemaining() {
    _phaseTotal = _durationFor(phase);
    remaining = _phaseTotal;
  }

  void _onSettings() {
    if (!settings.notifyEnabled) NotificationService.cancelAll();
    if (!running && remaining == _phaseTotal) {
      _resetRemaining();
      notifyListeners();
    }
  }

  /// Updates the live countdown in the notification panel.
  void _pushNotification({bool first = false}) {
    if (!settings.notifyEnabled || !running) return;
    final l = settings.l;
    NotificationService.showRunning(
      l: l,
      phaseTitle: phase.title(l),
      remaining: remaining,
      total: _phaseTotal,
      first: first,
    );
  }

  /// Schedules the alert for the end of the session.
  void _scheduleEndAlert() {
    if (!settings.notifyEnabled || _endAt == null) return;
    final isFocus = phase == Phase.focus;
    final nextLong =
        isFocus && (completedFocus + 1) % settings.sessionsBeforeLong == 0;
    NotificationService.scheduleDone(
      l: settings.l,
      focusFinished: isFocus,
      nextIsLong: nextLong,
      endAt: _endAt!,
    );
  }

  void start() {
    if (running) return;
    _endAt = DateTime.now().add(Duration(seconds: remaining));
    running = true;
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    _pushNotification(first: true);
    _scheduleEndAlert();
    notifyListeners();
  }

  void pause() {
    _ticker?.cancel();
    running = false;
    _endAt = null;
    NotificationService.cancelDone(focus: phase == Phase.focus);
    NotificationService.stopRunning();
    if (settings.notifyEnabled) {
      final l = settings.l;
      NotificationService.showPaused(
          l: l, title: phase.title(l), remainingSeconds: remaining);
    }
    notifyListeners();
  }

  void _tick() {
    final ms = _endAt!.difference(DateTime.now()).inMilliseconds;
    final left = (ms / 1000).ceil();
    if (left <= 0) {
      _finish();
    } else if (left != remaining) {
      remaining = left;
      notifyListeners();
      _pushNotification();
    }
  }

  void _commitPartial() {
    if (phase == Phase.focus) {
      final elapsed = _phaseTotal - remaining;
      if (elapsed >= 60) stats.addFocus(elapsed);
    }
  }

  void reset() {
    _ticker?.cancel();
    running = false;
    _endAt = null;
    NotificationService.cancelAll();
    _commitPartial();
    _resetRemaining();
    notifyListeners();
  }

  void selectPhase(Phase p) {
    if (running || p == phase) return;
    NotificationService.cancelAll();
    _commitPartial();
    phase = p;
    _resetRemaining();
    notifyListeners();
  }

  void skipBreak() {
    if (!phase.isBreak) return;
    _ticker?.cancel();
    running = false;
    _endAt = null;
    NotificationService.cancelAll();
    phase = Phase.focus;
    _resetRemaining();
    notifyListeners();
  }

  void _finish() {
    _ticker?.cancel();
    running = false;
    _endAt = null;
    final finished = phase;

    // In the foreground the app shows its own reminder, so the scheduled
    // alert is not needed. In the background we let it fire.
    if (appInForeground) {
      NotificationService.cancelDone(focus: finished == Phase.focus);
    }

    if (finished == Phase.focus) {
      stats.addFocus(_phaseTotal, completed: true);
      completedFocus++;
      phase = completedFocus % settings.sessionsBeforeLong == 0
          ? Phase.longBreak
          : Phase.shortBreak;
    } else {
      phase = Phase.focus;
    }

    // Keep the notification alive if the next break starts by itself.
    final autoStart = phase.isBreak && settings.autoStartBreak;
    if (!autoStart) NotificationService.stopRunning();

    _resetRemaining();
    notifyListeners();
    onPhaseFinished?.call(finished);
    if (autoStart) start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    settings.removeListener(_onSettings);
    super.dispose();
  }
}