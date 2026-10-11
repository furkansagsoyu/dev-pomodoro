import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'detector.dart';
import 'l10n.dart';
import 'notification_service.dart';
import 'pomodoro_timer.dart';
import 'scan_page.dart';
import 'settings.dart';
import 'stats.dart';
import 'theme.dart';
import 'tips.dart';

class HomePage extends StatefulWidget {
  final PomodoroTimer timer;
  final AppSettings settings;
  final StatsStore stats;
  final DeskDetector detector;
  const HomePage({
    super.key,
    required this.timer,
    required this.settings,
    required this.stats,
    required this.detector,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tipShift = 0;
  PomodoroTimer get t => widget.timer;
  L10n get l => widget.settings.l;

  @override
  void initState() {
    super.initState();
    t.onPhaseFinished = _onFinished;
  }

  @override
  void dispose() {
    t.onPhaseFinished = null;
    super.dispose();
  }

  void _onFinished(Phase finished) {
    if (widget.settings.vibrate) {
      HapticFeedback.vibrate();
      SystemSound.play(SystemSoundType.alert);
    }
    if (!mounted) return;
    final idea = breakIdea(l.lang, math.Random().nextInt(100));
    final focusDone = finished == Phase.focus;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(focusDone ? Icons.self_improvement : Icons.bolt,
              size: 44, color: ctx.pAccent),
          const SizedBox(height: 12),
          Text(focusDone ? l.focusDone : l.breakOver,
              style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            focusDone
                ? '${l.timeForBreak(t.phase == Phase.longBreak)} $idea'
                : l.readyNext,
            textAlign: TextAlign.center,
            style: TextStyle(color: ctx.pMuted),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.gotIt),
          ),
        ]),
      ),
    );
  }

  Future<void> _onPlay() async {
    if (t.running) {
      t.pause();
      return;
    }
    final fresh = t.remaining == t.total;
    if (t.phase == Phase.focus && fresh && widget.settings.scanEnabled) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ScanFlowPage(
            detector: widget.detector,
            minScore: widget.settings.minConfidence,
            l: l,
            onScanned: widget.stats.addScan,
          ),
        ),
      );
      if (ok != true || !mounted) return;
    }
    if (widget.settings.notifyEnabled) {
      await NotificationService.requestPermission();
      if (!mounted) return;
    }
    t.start();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([t, widget.stats, widget.settings]),
      builder: (context, _) {
        final today = widget.stats.forDay(DateTime.now());
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _header(context, today.sessions),
            const SizedBox(height: 20),
            _phasePills(),
            const SizedBox(height: 20),
            _timerRing(context),
            const SizedBox(height: 20),
            _controls(context),
            const SizedBox(height: 24),
            _breakCard(context),
            if (widget.settings.showTip) ...[
              const SizedBox(height: 16),
              _tipCard(context),
            ],
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, int sessions) {
    return Row(children: [
      Expanded(
        child: Text('Dev Pomodoro',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.pCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.pBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.flag_rounded, size: 16, color: context.pAccent),
          const SizedBox(width: 6),
          Text(l.todayCount(sessions, widget.settings.dailyGoal),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    ]);
  }

  Widget _phasePills() {
    return Row(children: [
      for (final p in Phase.values)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p == Phase.longBreak ? 0 : 8),
            child: _Pill(
              label: p.title(l),
              selected: t.phase == p,
              onTap: t.running ? null : () => t.selectPhase(p),
            ),
          ),
        ),
    ]);
  }

  Widget _timerRing(BuildContext context) {
    final frac = t.total == 0 ? 0.0 : t.remaining / t.total;
    final colors = t.phase.isBreak
        ? [Brand.cyan, Brand.mint]
        : [Brand.blue, Brand.cyan];
    final m = (t.remaining ~/ 60).toString().padLeft(2, '0');
    final s = (t.remaining % 60).toString().padLeft(2, '0');
    final cycle = widget.settings.sessionsBeforeLong;
    final done = t.completedFocus % cycle;
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
            child: CustomPaint(
              painter: RingPainter(
                progress: frac,
                track: context.pBorder,
                c1: colors[0],
                c2: colors[1],
              ),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(t.phase.title(l).toUpperCase(),
                style: TextStyle(
                    letterSpacing: 3,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.pMuted)),
            const SizedBox(height: 4),
            Text('$m:$s',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: context.pText,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
            const SizedBox(height: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < cycle; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < done ? context.pAccent : context.pBorder,
                  ),
                ),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton.filledTonal(
        onPressed: t.reset,
        icon: const Icon(Icons.refresh),
        tooltip: l.reset,
      ),
      const SizedBox(width: 24),
      Material(
        color: Colors.transparent,
        child: Ink(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Brand.blue, Brand.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: Color(0x663B82F6), blurRadius: 24, spreadRadius: 1),
            ],
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _onPlay,
            child: Icon(
              t.running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
        ),
      ),
      const SizedBox(width: 24),
      IconButton.filledTonal(
        onPressed: t.phase.isBreak ? t.skipBreak : null,
        icon: const Icon(Icons.skip_next),
        tooltip: l.skipBreak,
      ),
    ]);
  }

  Widget _breakCard(BuildContext context) {
    final isBreak = t.phase.isBreak;
    final idea = breakIdea(l.lang, t.completedFocus);
    return AppCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
          isBreak ? Icons.self_improvement : Icons.notifications_active_outlined,
          color: context.pAccent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isBreak ? l.breakTime : l.breakReminder,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              isBreak
                  ? idea
                  : l.reminderBody(l.longBreakAfter(t.sessionsUntilLong)),
              style: TextStyle(color: context.pMuted, height: 1.4),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _tipCard(BuildContext context) {
    final tip = tipForToday(_tipShift);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.lightbulb_outline, size: 18, color: context.pAccent),
          const SizedBox(width: 8),
          Text(l.dailyBrief,
              style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: context.pAccent)),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: l.anotherTip,
            onPressed: () => setState(() => _tipShift++),
            icon: Icon(Icons.refresh, size: 18, color: context.pMuted),
          ),
        ]),
        const SizedBox(height: 4),
        Text(tip.titleFor(l.lang),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 6),
        Text(tip.bodyFor(l.lang),
            style: TextStyle(color: context.pMuted, height: 1.45)),
        if (tip.code != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF060D20)
                  : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(tip.code!,
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: context.pAccent)),
          ),
        ],
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _Pill({required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [Brand.blue, Brand.cyan])
              : null,
          color: selected ? null : context.pCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? Colors.transparent : context.pBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : context.pMuted,
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color track, c1, c2;
  RingPainter({
    required this.progress,
    required this.track,
    required this.c1,
    required this.c2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - stroke;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);

    final shader = SweepGradient(colors: [c1, c2, c1]).createShader(rect);
    final glowShader = SweepGradient(
            colors: [c1.withAlpha(110), c2.withAlpha(110), c1.withAlpha(110)])
        .createShader(rect);

    canvas.drawArc(
      rect,
      0,
      sweep,
      false,
      Paint()
        ..shader = glowShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawArc(
      rect,
      0,
      sweep,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RingPainter old) =>
      old.progress != progress ||
      old.track != track ||
      old.c1 != c1 ||
      old.c2 != c2;
}