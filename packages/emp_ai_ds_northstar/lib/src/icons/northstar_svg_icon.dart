import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'northstar_icon_manifest_item.dart';

/// Renders a Northstar V3 SVG from [emp_ai_ds_northstar] assets.
class NorthstarSvgIcon extends StatelessWidget {
  const NorthstarSvgIcon({
    super.key,
    required this.item,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
  }) : relativeAssetPath = null;

  const NorthstarSvgIcon.fromPath({
    super.key,
    required this.relativeAssetPath,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
  }) : item = null;

  final NorthstarIconManifestItem? item;
  final String? relativeAssetPath;

  final double size;
  final Color? color;
  final BoxFit fit;

  String get _path {
    if (item != null) {
      return item!.relativeAssetPath;
    }
    return relativeAssetPath!;
  }

  @override
  Widget build(BuildContext context) {
    final Color? c = color ?? DefaultTextStyle.of(context).style.color;
    return SvgPicture.asset(
      _path,
      package: 'emp_ai_ds_northstar',
      width: size,
      height: size,
      fit: fit,
      colorFilter: c != null ? ColorFilter.mode(c, BlendMode.srcIn) : null,
    );
  }
}
