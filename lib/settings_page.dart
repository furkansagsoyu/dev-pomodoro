import 'package:flutter/material.dart';
import 'l10n.dart';
import 'notification_service.dart';
import 'settings.dart';
import 'stats.dart';
import 'theme.dart';

class SettingsPage extends StatelessWidget {
  final AppSettings settings;
  final StatsStore stats;
  const SettingsPage({super.key, required this.settings, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = settings;
        final l = s.l;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(l.settingsTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _Section(title: l.secTimer, children: [
              _Stepper(
                title: l.focusLength,
                value: s.focusMin,
                suffix: l.unitMin,
                min: 5,
                max: 90,
                step: 5,
                onChanged: (v) => s.set(() => s.focusMin = v),
              ),
              _Stepper(
                title: l.shortBreak,
                value: s.shortBreakMin,
                suffix: l.unitMin,
                min: 1,
                max: 30,
                onChanged: (v) => s.set(() => s.shortBreakMin = v),
              ),
              _Stepper(
                title: l.longBreak,
                value: s.longBreakMin,
                suffix: l.unitMin,
                min: 5,
                max: 60,
                step: 5,
                onChanged: (v) => s.set(() => s.longBreakMin = v),
              ),
              _Stepper(
                title: l.sessionsBeforeLong,
                value: s.sessionsBeforeLong,
                suffix: '',
                min: 2,
                max: 8,
                onChanged: (v) => s.set(() => s.sessionsBeforeLong = v),
              ),
              _Stepper(
                title: l.dailyGoal,
                value: s.dailyGoal,
                suffix: l.unitSessions,
                min: 1,
                max: 12,
                onChanged: (v) => s.set(() => s.dailyGoal = v),
              ),
            ]),
            _Section(title: l.secDesk, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.scanBefore),
                subtitle: Text(l.scanBeforeSub),
                value: s.scanEnabled,
                onChanged: (v) => s.set(() => s.scanEnabled = v),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(l.threshold)),
                    Text('${(s.minConfidence * 100).round()}%',
                        style: TextStyle(color: context.pMuted)),
                  ]),
                  Slider(
                    value: s.minConfidence,
                    min: 0.3,
                    max: 0.9,
                    divisions: 6,
                    onChanged: (v) => s.set(() => s.minConfidence = v),
                  ),
                  Text(
                    l.thresholdHelp,
                    style: TextStyle(color: context.pMuted, fontSize: 12),
                  ),
                ]),
              ),
            ]),
            _Section(title: l.secNotifications, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.notifTimer),
                subtitle: Text(l.notifTimerSub),
                value: s.notifyEnabled,
                onChanged: (v) {
                  s.set(() => s.notifyEnabled = v);
                  if (v) NotificationService.requestPermission();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.notifExact),
                subtitle: Text(l.notifExactSub),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: NotificationService.requestExactAlarms,
              ),
            ]),
            _Section(title: l.secBehavior, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.autoStartBreaks),
                value: s.autoStartBreak,
                onChanged: (v) => s.set(() => s.autoStartBreak = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.vibrateEnd),
                value: s.vibrate,
                onChanged: (v) => s.set(() => s.vibrate = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.showBrief),
                value: s.showTip,
                onChanged: (v) => s.set(() => s.showTip = v),
              ),
            ]),
            _Section(title: l.secAppearance, children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l.themeSystem),
                        icon: const Icon(Icons.phone_android)),
                    ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l.themeLight),
                        icon: const Icon(Icons.light_mode)),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l.themeDark),
                        icon: const Icon(Icons.dark_mode)),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) =>
                      s.set(() => s.themeMode = v.first),
                ),
              ),
            ]),
            _Section(title: l.secLanguage, children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AppLang>(
                  segments: const [
                    ButtonSegment(value: AppLang.en, label: Text('English')),
                    ButtonSegment(value: AppLang.tr, label: Text('Türkçe')),
                  ],
                  selected: {s.lang},
                  onSelectionChanged: (v) => s.set(() => s.lang = v.first),
                ),
              ),
            ]),
            _Section(title: l.secData, children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: Text(l.resetStats),
                onTap: () => _confirmReset(context, l),
              ),
            ]),
          ],
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext context, L10n l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetTitle),
        content: Text(l.resetBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete)),
        ],
      ),
    );
    if (ok == true) stats.clear();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: context.pAccent)),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(children: children),
        ),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String title, suffix;
  final int value, min, max, step;
  final ValueChanged<int> onChanged;
  const _Stepper({
    required this.title,
    required this.value,
    required this.suffix,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title)),
      IconButton(
        onPressed: value - step >= min ? () => onChanged(value - step) : null,
        icon: const Icon(Icons.remove_circle_outline),
      ),
      SizedBox(
        width: 84,
        child: Text('$value $suffix'.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      IconButton(
        onPressed: value + step <= max ? () => onChanged(value + step) : null,
        icon: const Icon(Icons.add_circle_outline),
      ),
    ]);
  }
}