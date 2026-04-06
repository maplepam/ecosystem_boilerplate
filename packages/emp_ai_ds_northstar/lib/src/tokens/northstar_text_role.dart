import 'package:flutter/material.dart';

/// Named roles aligned with **V3 NORTHSTAR** Figma text styles (Lexend Deca +
/// Inter). Resolved via [Theme.of(context).textTheme] after applying
/// [NorthstarTypographyStyle.figmaNorthstarV3] in [NorthstarTheme.buildThemeData].
enum NorthstarTextRole {
  /// Lexend Deca 40/40 — Figma `lexendHero`.
  hero,

  /// Lexend Deca 24/24 — `lexendTitle`.
  title,

  /// Lexend Deca 18/28 — `lexendPageTitle`.
  pageTitle,

  /// Inter 18/28 — `pageTitles` (Inter variant).
  interPageTitle,

  /// Inter 16/24 — `SubTitles`.
  subTitle,

  /// Inter 15/24 w400 — subheading regular.
  subheadingRegular,

  /// Inter 15/24 w600 — subheading semibold.
  subheadingSemiBold,

  /// Inter 15/24 w700 — subheading bold.
  subheadingBold,

  /// Inter 14/16 — `labelRegular` / label standard.
  label,

  /// Inter 14/24 — body large, Content Black.
  pageDescription,

  /// Inter 16/24 — section sub-header (`headingSubtitle` alias).
  headingSubtitle,

  /// Inter 14/24 — body large.
  bodyLarge,

  /// Inter 12/16 — body standard, Content Gray.
  body,

  /// Inter 10/16 — body small / IDs, Content Gray.
  bodySmall,

  /// Inter 14/16 w600 — compact heading.
  smallHeading,
}

extension NorthstarTextRoleX on NorthstarTextRole {
  /// Resolve against [Theme.of(context).textTheme] (Figma V3 scale).
  TextStyle style(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return switch (this) {
      NorthstarTextRole.hero => t.displayLarge!,
      NorthstarTextRole.title => t.displayMedium!,
      NorthstarTextRole.pageTitle => t.displaySmall!,
      NorthstarTextRole.interPageTitle => t.headlineLarge!,
      NorthstarTextRole.subTitle => t.headlineMedium!,
      NorthstarTextRole.subheadingRegular => t.headlineSmall!,
      NorthstarTextRole.subheadingSemiBold => t.titleLarge!,
      NorthstarTextRole.subheadingBold => t.titleMedium!,
      NorthstarTextRole.label => t.labelLarge!,
      NorthstarTextRole.pageDescription => t.bodyLarge!,
      NorthstarTextRole.headingSubtitle => t.headlineMedium!,
      NorthstarTextRole.bodyLarge => t.bodyLarge!,
      NorthstarTextRole.body => t.bodyMedium!,
      NorthstarTextRole.bodySmall => t.bodySmall!,
      NorthstarTextRole.smallHeading => t.titleSmall!,
    };
  }
}
