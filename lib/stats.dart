import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayRecord {
  int focusSeconds;
  int sessions;
  int scans;
  int distractions;
  DayRecord({
    this.focusSeconds = 0,
    this.sessions = 0,
    this.scans = 0,
    this.distractions = 0,
  });

  Map<String, int> toJson() => {
        'f': focusSeconds,
        's': sessions,
        'c': scans,
        'd': distractions,
      };

  factory DayRecord.fromJson(Map<String, dynamic> j) => DayRecord(
        focusSeconds: (j['f'] ?? 0) as int,
        sessions: (j['s'] ?? 0) as int,
        scans: (j['c'] ?? 0) as int,
        distractions: (j['d'] ?? 0) as int,
      );
}

class StatsStore extends ChangeNotifier {
  late SharedPreferences _p;
  final Map<String, DayRecord> records = {};

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p.getString('stats');
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      m.forEach((k, v) =>
          records[k] = DayRecord.fromJson(v as Map<String, dynamic>));
    }
  }

  void _save() {
    _p.setString(
      'stats',
      jsonEncode(records.map((k, v) => MapEntry(k, v.toJson()))),
    );
    notifyListeners();
  }

  DayRecord forDay(DateTime d) => records[_key(d)] ?? DayRecord();
  DayRecord _today() => records.putIfAbsent(_key(DateTime.now()), DayRecord.new);

  void addFocus(int seconds, {bool completed = false}) {
    final r = _today();
    r.focusSeconds += seconds;
    if (completed) r.sessions++;
    _save();
  }

  void addScan(bool hadDistraction) {
    final r = _today();
    r.scans++;
    if (hadDistraction) r.distractions++;
    _save();
  }

  void clear() {
    records.clear();
    _save();
  }

  /// Oldest first, ending with today.
  List<(DateTime, DayRecord)> lastDays(int n) {
    final now = DateTime.now();
    return [
      for (var i = n - 1; i >= 0; i--)
        (
          DateTime(now.year, now.month, now.day - i),
          forDay(DateTime(now.year, now.month, now.day - i)),
        ),
    ];
  }

  int get totalSeconds =>
      records.values.fold(0, (a, r) => a + r.focusSeconds);
  int get totalSessions => records.values.fold(0, (a, r) => a + r.sessions);
  int get totalDistractions =>
      records.values.fold(0, (a, r) => a + r.distractions);

  int get streak {
    var d = DateTime.now();
    if (forDay(d).focusSeconds == 0) d = DateTime(d.year, d.month, d.day - 1);
    var n = 0;
    while (forDay(d).focusSeconds > 0) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }
}