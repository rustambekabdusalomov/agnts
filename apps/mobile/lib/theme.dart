import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/// agnts's design tokens, copied from mobile.html's CSS variables (:root and
/// the dark theme). Keep in sync with apps/admin/src/styles/tokens.css.
@immutable
class Agnts extends ThemeExtension<Agnts> {
  const Agnts({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.line3,
    required this.line4,
    required this.hover,
    required this.field,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.primaryInk,
    required this.ring,
    required this.help,
    required this.ok,
    required this.okSoft,
    required this.okInk,
    required this.warn,
    required this.warnSoft,
    required this.warnInk,
    required this.bad,
    required this.badSoft,
    required this.badInk,
    required this.graySoft,
    required this.grayInk,
    required this.code,
    required this.codeInk,
    required this.codeDim,
    required this.taskSoft,
    required this.taskInk,
  });

  final Color bg, surface, ink, ink2, ink3, line, line2, line3, line4, hover, field;
  final Color primary, onPrimary, primarySoft, primaryInk, ring, help;
  final Color ok, okSoft, okInk, warn, warnSoft, warnInk, bad, badSoft, badInk, graySoft, grayInk;
  final Color code, codeInk, codeDim;
  final Color taskSoft, taskInk; // the "Task" source chip

  static const light = Agnts(
    bg: Color(0xFFF5F5F2),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF16181D),
    ink2: Color(0xFF555A63),
    ink3: Color(0xFF6B6F78),
    line: Color(0xFFE4E2DC),
    line2: Color(0xFFEFEDE8),
    line3: Color(0xFFD2CFC6),
    line4: Color(0xFFD9D6CE),
    hover: Color(0xFFF2F1ED),
    field: Color(0xFFFAFAF8),
    primary: Color(0xFF2E46A8),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE9ECF8),
    primaryInk: Color(0xFF26398C),
    ring: Color(0xFFDCE2F5),
    help: Color(0xFFF3F5FC),
    ok: Color(0xFF1F7A4D),
    okSoft: Color(0xFFE3F2EA),
    okInk: Color(0xFF1A6B43),
    warn: Color(0xFFC98A14),
    warnSoft: Color(0xFFFBEFD9),
    warnInk: Color(0xFF8A510A),
    bad: Color(0xFFB3261E),
    badSoft: Color(0xFFFBE4E2),
    badInk: Color(0xFFA3241B),
    graySoft: Color(0xFFEFEEEA),
    grayInk: Color(0xFF4A4E57),
    code: Color(0xFF16181D),
    codeInk: Color(0xFFE9E7E1),
    codeDim: Color(0xFF9AA0A8),
    taskSoft: Color(0xFFF0E8F8),
    taskInk: Color(0xFF5E3790),
  );

  static const dark = Agnts(
    bg: Color(0xFF121317),
    surface: Color(0xFF1B1D23),
    ink: Color(0xFFECEBE6),
    ink2: Color(0xFFB4B6BC),
    ink3: Color(0xFF8E9199),
    line: Color(0xFF2C2F37),
    line2: Color(0xFF24272E),
    line3: Color(0xFF3A3E46),
    line4: Color(0xFF3A3E46),
    hover: Color(0xFF24272E),
    field: Color(0xFF16181D),
    primary: Color(0xFF8299EC),
    onPrimary: Color(0xFF0F1220),
    primarySoft: Color(0xFF232B4A),
    primaryInk: Color(0xFFB5C3F3),
    ring: Color(0xFF2F3A66),
    help: Color(0xFF1D2340),
    ok: Color(0xFF5CC28E),
    okSoft: Color(0xFF183626),
    okInk: Color(0xFF7FD3A6),
    warn: Color(0xFFF0B95A),
    warnSoft: Color(0xFF3A2C12),
    warnInk: Color(0xFFF0B95A),
    bad: Color(0xFFF08A80),
    badSoft: Color(0xFF3D1C1A),
    badInk: Color(0xFFF08A80),
    graySoft: Color(0xFF2A2C33),
    grayInk: Color(0xFFC4C6CB),
    code: Color(0xFF0D0E11),
    codeInk: Color(0xFFE9E7E1),
    codeDim: Color(0xFF9AA0A8),
    taskSoft: Color(0xFF2E2340),
    taskInk: Color(0xFFCDB4EE),
  );

  /// The tokens for the current theme: `Agnts.of(context).primary`.
  static Agnts of(BuildContext context) => Theme.of(context).extension<Agnts>()!;

  @override
  Agnts copyWith() => this;

  @override
  Agnts lerp(ThemeExtension<Agnts>? other, double t) => t < 0.5 || other is! Agnts ? this : other;
}

/// Type families, as in the demo: a display face for titles and numbers, a
/// highly legible text face, and its mono for keys, branches and code.
/// Missing glyphs (Cyrillic, the Uzbek ʻ) fall back to the system font.
class AgntsFonts {
  static const display = 'BricolageGrotesque';
  static const sans = 'AtkinsonHyperlegibleNext';
  static const mono = 'AtkinsonHyperlegibleMono';
}

ThemeData agntsTheme(Brightness brightness) {
  final c = brightness == Brightness.light ? Agnts.light : Agnts.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.primary,
    onSecondary: c.onPrimary,
    error: c.bad,
    onError: c.onPrimary,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.ink3,
    outline: c.line3,
    outlineVariant: c.line,
    surfaceContainerHighest: c.hover,
  );
  final base = ThemeData(brightness: brightness, useMaterial3: true, fontFamily: AgntsFonts.sans);
  TextStyle disp(double size, {FontWeight w = FontWeight.w700, double ls = -0.02}) =>
      TextStyle(fontFamily: AgntsFonts.display, fontSize: size, fontWeight: w, letterSpacing: size * ls, height: 1.1, color: c.ink);
  final text = base.textTheme
      .apply(fontFamily: AgntsFonts.sans, bodyColor: c.ink, displayColor: c.ink)
      .copyWith(
        displaySmall: disp(32),
        headlineMedium: disp(28),
        headlineSmall: disp(25, ls: -0.01),
        titleLarge: disp(22, ls: -0.01),
        titleMedium: TextStyle(fontFamily: AgntsFonts.sans, fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
        titleSmall: TextStyle(fontFamily: AgntsFonts.sans, fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink3),
        bodyLarge: TextStyle(fontFamily: AgntsFonts.sans, fontSize: 16, height: 1.45, color: c.ink),
        bodyMedium: TextStyle(fontFamily: AgntsFonts.sans, fontSize: 15, height: 1.45, color: c.ink),
        bodySmall: TextStyle(fontFamily: AgntsFonts.sans, fontSize: 13, height: 1.4, color: c.ink3),
        labelLarge: TextStyle(fontFamily: AgntsFonts.sans, fontSize: 15.5, fontWeight: FontWeight.w700),
      );
  final radius12 = BorderRadius.circular(12);
  OutlineInputBorder field(Color col, [double w = 1]) => OutlineInputBorder(
    borderRadius: radius12,
    borderSide: BorderSide(color: col, width: w),
  );
  final btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  const btnSize = Size(48, 48);
  final btnText = const TextStyle(fontFamily: AgntsFonts.sans, fontSize: 15.5, fontWeight: FontWeight.w700);

  return base.copyWith(
    colorScheme: scheme,
    extensions: [c],
    scaffoldBackgroundColor: c.bg,
    textTheme: text,
    splashFactory: NoSplash.splashFactory,
    // iOS: swipe back from anywhere on the page, as native apps do since
    // iOS 26 (Flutter's own gesture starts only at the left edge).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder(), TargetPlatform.iOS: SwipeablePageTransitionsBuilder()},
    ),
    highlightColor: c.hover,
    dividerTheme: DividerThemeData(color: c.line2, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: field(c.line3),
      enabledBorder: field(c.line3),
      focusedBorder: field(c.primary, 1.5),
      errorBorder: field(c.bad),
      focusedErrorBorder: field(c.bad, 1.5),
      hintStyle: TextStyle(color: c.ink3),
      labelStyle: TextStyle(color: c.ink2, fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.primary.withValues(alpha: 0.45),
        disabledForegroundColor: c.onPrimary,
        minimumSize: btnSize,
        shape: btnShape,
        textStyle: btnText,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        backgroundColor: c.surface,
        minimumSize: btnSize,
        shape: btnShape,
        side: BorderSide(color: c.line3),
        textStyle: btnText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: c.primary, textStyle: btnText.copyWith(fontSize: 14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.ok : const Color(0xFFC9C5BB)),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary, linearTrackColor: c.line2),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.line3,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF16181D),
      contentTextStyle: const TextStyle(fontFamily: AgntsFonts.sans, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    popupMenuTheme: PopupMenuThemeData(color: c.surface, surfaceTintColor: Colors.transparent),
  );
}
