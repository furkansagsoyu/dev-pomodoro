import 'package:flutter/material.dart';

class Brand {
  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF22D3EE);
  static const mint = Color(0xFF5EEAD4);
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: Brand.blue, brightness: b)
      .copyWith(
    primary: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
    surface: dark ? const Color(0xFF0E1730) : Colors.white,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF050A16) : const Color(0xFFF3F8FF),
  );
  final text = dark ? const Color(0xFFE8EEFF) : const Color(0xFF0B1B3A);
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
  );
}

extension Pal on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get pCard => isDark ? const Color(0xFF0E1730) : Colors.white;
  Color get pBorder =>
      isDark ? const Color(0xFF1C2B52) : const Color(0xFFDCE8FB);
  Color get pText =>
      isDark ? const Color(0xFFE8EEFF) : const Color(0xFF0B1B3A);
  Color get pMuted =>
      isDark ? const Color(0xFF8FA3CC) : const Color(0xFF5B6F94);
  Color get pAccent =>
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.pCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.pBorder),
        boxShadow: context.isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x143B82F6),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
  }
}