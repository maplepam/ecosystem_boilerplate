import 'package:flutter/material.dart';

import '../tokens/northstar_spacing.dart';

/// Reference table: **Token** / **rem** / **px** / swatch (matches Northstar V3 Spacing page).
///
/// Reuse in design-system docs, Storybook-style catalogs, or internal tooling.
class NorthstarSpacingScaleTable extends StatelessWidget {
  const NorthstarSpacingScaleTable({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(
      NorthstarSpacing.space48,
      NorthstarSpacing.space40,
      NorthstarSpacing.space48,
      NorthstarSpacing.space40,
    ),
    this.columnGap = NorthstarSpacing.space8,
    this.headerCellWidth = 188,
    this.swatchCellMinHeight = NorthstarSpacing.space24,
    this.frameBackgroundColor = const Color(0xFFF8FAFC),
    this.headerBackgroundColor = const Color(0xFF202939),
    this.headerForegroundColor = Colors.white,
    this.bodyForegroundColor = Colors.white,
    this.rowBackgroundColor = const Color(0xFF202939),
    this.swatchColor = const Color(0xFF1EA8AA),
    this.footerNote =
        "The spacing scale includes negative values which can be useful for breaking out of a container's padding or for overlapping elements.",
  });

  final EdgeInsetsGeometry padding;

  /// Horizontal gap between columns (Figma **8**).
  final double columnGap;

  final double headerCellWidth;

  /// Minimum row height for the example column; grows with larger swatches.
  final double swatchCellMinHeight;

  final Color frameBackgroundColor;
  final Color headerBackgroundColor;
  final Color headerForegroundColor;
  final Color bodyForegroundColor;
  final Color rowBackgroundColor;
  final Color swatchColor;
  final String footerNote;

  static const TextStyle _headerTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _bodyTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Four fixed columns plus [columnGap] between them (intrinsic table width).
  double get _tableWidth => 4 * headerCellWidth + 3 * columnGap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: frameBackgroundColor,
      child: Padding(
        padding: padding,
        child: SizedBox(
          width: _tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _HeaderRow(
                columnGap: columnGap,
                cellWidth: headerCellWidth,
                headerBackgroundColor: headerBackgroundColor,
                headerForegroundColor: headerForegroundColor,
                textStyle: _headerTextStyle,
              ),
              SizedBox(height: columnGap * 3),
              ...NorthstarSpacing.scale.map(
                (NorthstarSpacingToken t) => Padding(
                  padding: EdgeInsets.only(bottom: columnGap),
                  child: _DataRow(
                    token: t,
                    columnGap: columnGap,
                    cellWidth: headerCellWidth,
                    minSwatchCellHeight: swatchCellMinHeight,
                    rowBackgroundColor: rowBackgroundColor,
                    textStyle: _bodyTextStyle,
                    foregroundColor: bodyForegroundColor,
                    swatchColor: swatchColor,
                  ),
                ),
              ),
              SizedBox(height: columnGap * 2),
              ColoredBox(
                color: rowBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(NorthstarSpacing.space12),
                  child: Text(
                    footerNote,
                    style: _bodyTextStyle.copyWith(color: bodyForegroundColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columnGap,
    required this.cellWidth,
    required this.headerBackgroundColor,
    required this.headerForegroundColor,
    required this.textStyle,
  });

  final double columnGap;
  final double cellWidth;
  final Color headerBackgroundColor;
  final Color headerForegroundColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _HeaderCell(
          width: cellWidth,
          label: 'Token',
          backgroundColor: headerBackgroundColor,
          foregroundColor: headerForegroundColor,
          textStyle: textStyle,
        ),
        SizedBox(width: columnGap),
        _HeaderCell(
          width: cellWidth,
          label: 'rem',
          backgroundColor: headerBackgroundColor,
          foregroundColor: headerForegroundColor,
          textStyle: textStyle,
        ),
        SizedBox(width: columnGap),
        _HeaderCell(
          width: cellWidth,
          label: 'px',
          backgroundColor: headerBackgroundColor,
          foregroundColor: headerForegroundColor,
          textStyle: textStyle,
        ),
        SizedBox(width: columnGap),
        _HeaderCell(
          width: cellWidth,
          label: 'Example',
          backgroundColor: headerBackgroundColor,
          foregroundColor: headerForegroundColor,
          textStyle: textStyle,
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.width,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.textStyle,
  });

  final double width;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 24,
      child: ColoredBox(
        color: backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NorthstarSpacing.space4),
            child: Text(
              label,
              style: textStyle.copyWith(color: foregroundColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.token,
    required this.columnGap,
    required this.cellWidth,
    required this.minSwatchCellHeight,
    required this.rowBackgroundColor,
    required this.textStyle,
    required this.foregroundColor,
    required this.swatchColor,
  });

  final NorthstarSpacingToken token;
  final double columnGap;
  final double cellWidth;
  final double minSwatchCellHeight;
  final Color rowBackgroundColor;
  final TextStyle textStyle;
  final Color foregroundColor;
  final Color swatchColor;

  @override
  Widget build(BuildContext context) {
    final String remLabel = _formatRem(token.rem);
    final String pxLabel = token.logicalPixels == token.logicalPixels.roundToDouble()
        ? '${token.logicalPixels.round()}'
        : '${token.logicalPixels}';

    final double swatch = token.logicalPixels;
    final double swatchCellSide =
        (swatch + 16).clamp(minSwatchCellHeight, 112).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _TextCell(
          width: cellWidth,
          backgroundColor: rowBackgroundColor,
          text: token.name,
          textStyle: textStyle,
          foregroundColor: foregroundColor,
        ),
        SizedBox(width: columnGap),
        _TextCell(
          width: cellWidth,
          backgroundColor: rowBackgroundColor,
          text: remLabel,
          textStyle: textStyle,
          foregroundColor: foregroundColor,
        ),
        SizedBox(width: columnGap),
        _TextCell(
          width: cellWidth,
          backgroundColor: rowBackgroundColor,
          text: pxLabel,
          textStyle: textStyle,
          foregroundColor: foregroundColor,
        ),
        SizedBox(width: columnGap),
        SizedBox(
          width: cellWidth,
          height: swatchCellSide,
          child: ColoredBox(
            color: rowBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(NorthstarSpacing.space8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: swatch,
                  height: swatch,
                  child: ColoredBox(color: swatchColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextCell extends StatelessWidget {
  const _TextCell({
    required this.width,
    required this.backgroundColor,
    required this.text,
    required this.textStyle,
    required this.foregroundColor,
  });

  final double width;
  final Color backgroundColor;
  final String text;
  final TextStyle textStyle;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 24,
      child: ColoredBox(
        color: backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NorthstarSpacing.space4),
            child: Text(
              text,
              style: textStyle.copyWith(color: foregroundColor),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatRem(double rem) {
  if (rem == rem.roundToDouble()) {
    return '${rem.round()}';
  }
  final String s = rem.toStringAsFixed(3);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}
