/// Shared breakpoints for list (mobile vs web shell) and detail reading width.
abstract final class AnnouncementsLayoutTokens {
  const AnnouncementsLayoutTokens._();

  /// At or above: use wide home layout (filter rail + feed).
  static const double homeWideMinWidth = 900;

  /// Max content width for detail on wide viewports.
  static const double detailMaxContentWidth = 720;
}
