import 'package:flutter/material.dart';

/// Semantic colors for Northstar V3.
///
/// **Source of truth:** [NorthstarBaseTokens] — hand-maintained Dart
/// `Color` values (same numbers design once captured from Figma; no runtime
/// JSON loading in this package).
///
/// **Extending for a white-label app:** use [copyWith] or compose a new
/// instance — do not mutate a shared singleton.
@immutable
class NorthstarColorTokens extends ThemeExtension<NorthstarColorTokens> {
  const NorthstarColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.inverseSurface,
    required this.onInverseSurface,
  });

  /// Northstar V3 defaults; [inverseSurface] matches local `.fig` canvas meta.
  static const NorthstarColorTokens v3 = NorthstarColorTokens(
    primary: Color(0xFF005F8C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFB8E3FF),
    onPrimaryContainer: Color(0xFF001F2E),
    secondary: Color(0xFF4E616D),
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F9FA),
    onSurface: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFF697586),
    surfaceContainerLow: Color(0xFFEFF1F3),
    surfaceContainerHigh: Color(0xFFE2E6EA),
    outline: Color(0xFF72787E),
    outlineVariant: Color(0xFFC2C7CD),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF1B8735),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFB8860B),
    onWarning: Color(0xFF1A1C1E),
    inverseSurface: Color(0xFF121926),
    onInverseSurface: Color(0xFFE7ECF1),
  );

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color inverseSurface;
  final Color onInverseSurface;

  /// Resolve tokens from [BuildContext] after [ThemeData.extensions] is set.
  static NorthstarColorTokens of(BuildContext context) {
    final ext = Theme.of(context).extension<NorthstarColorTokens>();
    assert(
      ext != null,
      'NorthstarColorTokens missing — add via NorthstarTheme.buildThemeData',
    );
    return ext!;
  }

  @override
  NorthstarColorTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? surfaceContainerLow,
    Color? surfaceContainerHigh,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? onError,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? inverseSurface,
    Color? onInverseSurface,
  }) {
    return NorthstarColorTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
    );
  }

  @override
  NorthstarColorTokens lerp(ThemeExtension<NorthstarColorTokens>? other, double t) {
    if (other is! NorthstarColorTokens) {
      return this;
    }
    return NorthstarColorTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface:
          Color.lerp(onInverseSurface, other.onInverseSurface, t)!,
    );
  }

  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      error: error,
      onError: onError,
      outline: outline,
      outlineVariant: outlineVariant,
    );
  }

  @override
  int get hashCode => Object.hashAll([
        primary,
        onPrimary,
        primaryContainer,
        onPrimaryContainer,
        secondary,
        onSecondary,
        surface,
        onSurface,
        onSurfaceVariant,
        surfaceContainerLow,
        surfaceContainerHigh,
        outline,
        outlineVariant,
        error,
        onError,
        success,
        onSuccess,
        warning,
        onWarning,
        inverseSurface,
        onInverseSurface,
      ]);

  @override
  bool operator ==(Object other) {
    return other is NorthstarColorTokens &&
        other.primary == primary &&
        other.onPrimary == onPrimary &&
        other.primaryContainer == primaryContainer &&
        other.onPrimaryContainer == onPrimaryContainer &&
        other.secondary == secondary &&
        other.onSecondary == onSecondary &&
        other.surface == surface &&
        other.onSurface == onSurface &&
        other.onSurfaceVariant == onSurfaceVariant &&
        other.surfaceContainerLow == surfaceContainerLow &&
        other.surfaceContainerHigh == surfaceContainerHigh &&
        other.outline == outline &&
        other.outlineVariant == outlineVariant &&
        other.error == error &&
        other.onError == onError &&
        other.success == success &&
        other.onSuccess == onSuccess &&
        other.warning == warning &&
        other.onWarning == onWarning &&
        other.inverseSurface == inverseSurface &&
        other.onInverseSurface == onInverseSurface;
  }
}

/// Bridges common [ColorScheme] roles to [NorthstarColorTokens] so apps and
/// widgets can read **one** extension for semantic paint (even when
/// [ColorScheme] is seed-derived via [NorthstarTheme.buildThemeData]).
extension NorthstarColorTokensMaterialBridge on NorthstarColorTokens {
  /// Strongest container tier in M3; Northstar ships [surfaceContainerLow] and
  /// [surfaceContainerHigh] only — this maps to **high** for elevated panels.
  Color get surfaceContainerHighest => surfaceContainerHigh;
}
