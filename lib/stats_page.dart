import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'settings.dart';
import 'stats.dart';
import 'theme.dart';

class StatsPage extends StatelessWidget {
  final StatsStore stats;
  final AppSettings settings;
  const StatsPage({super.key, required this.stats, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([stats, settings]),
      builder: (context, _) {
        final l = settings.l;
        final today = stats.forDay(DateTime.now());
        final goal = settings.dailyGoal;
        final progress = (today.sessions / goal).clamp(0.0, 1.0);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(l.statsTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.today,
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          color: context.pAccent)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l.dur(today.focusSeconds),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w300)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l.focused,
                            style: TextStyle(color: context.pMuted)),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l.sessionsCount(today.sessions, goal),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: context.pBorder,
                    color: context.pAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _chart(context),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _Mini(
                    icon: Icons.local_fire_department_outlined,
                    value: '${stats.streak}',
                    label: l.dayStreak),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Mini(
                    icon: Icons.timer_outlined,
                    value: l.dur(stats.totalSeconds),
                    label: l.totalFocus),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _Mini(
                    icon: Icons.check_circle_outline,
                    value: '${stats.totalSessions}',
                    label: l.sessionsDone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Mini(
                    icon: Icons.visibility_outlined,
                    value: '${stats.totalDistractions}',
                    label: l.deskWarnings),
              ),
            ]),
          ],
        );
      },
    );
  }

  Widget _chart(BuildContext context) {
    final l = settings.l;
    final days = stats.lastDays(7);
    final maxSec = days.fold<int>(0, (m, e) => math.max(m, e.$2.focusSeconds));
    final names = l.weekdays;
    final todayIdx = DateTime.now().weekday;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.last7,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 16),
        SizedBox(
          height: 170,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (final (date, rec) in days)
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                    rec.focusSeconds == 0 ? '' : l.dur(rec.focusSeconds),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 10, color: context.pMuted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: maxSec == 0
                        ? 4.0
                        : (110 * rec.focusSeconds / maxSec)
                            .clamp(4.0, 110.0)
                            .toDouble(),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: rec.focusSeconds == 0
                            ? [context.pBorder, context.pBorder]
                            : const [Brand.blue, Brand.cyan],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    names[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: date.weekday == todayIdx
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: date.weekday == todayIdx
                          ? context.pAccent
                          : context.pMuted,
                    ),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _Mini extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Mini({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: context.pAccent, size: 22),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(color: context.pMuted, fontSize: 13)),
      ]),
    );
  }
}