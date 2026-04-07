import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';

/// Host branding: defaults follow [NorthstarBaseTokens].
///
/// Override per app: [NorthstarBaseTokens.whiteLabeledLight] or `copyWith` on
/// any preset from [NorthstarBaseTokens].
abstract final class AcmeBrandTokens {
  const AcmeBrandTokens._();

  static const NorthstarColorTokens light = NorthstarBaseTokens.light;

  static const NorthstarColorTokens dark = NorthstarBaseTokens.dark;
}
