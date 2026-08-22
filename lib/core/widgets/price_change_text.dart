import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../utils/money_utils.dart';

/// Reusable text widget displaying price change (₹ and %) color-coded
/// green for gains, red for losses, and muted gray for flat.
class PriceChangeText extends StatelessWidget {
  const PriceChangeText({
    super.key,
    required this.changePaise,
    required this.changePercent,
    this.fontSize = 13.0,
    this.showBadge = false,
  });

  /// Price change in paise.
  final int changePaise;

  /// Price change percentage.
  final double changePercent;

  /// Font size.
  final double fontSize;

  /// Whether to render inside a colored pill/badge container.
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final isUp = changePaise > 0;
    final isDown = changePaise < 0;

    final Color color = isUp
        ? AppColors.priceUp
        : isDown
            ? AppColors.priceDown
            : AppColors.priceFlat;

    final IconData icon = isUp
        ? Icons.arrow_drop_up
        : isDown
            ? Icons.arrow_drop_down
            : Icons.remove;

    final formattedText =
        '${MoneyUtils.formatChange(changePaise)} (${MoneyUtils.formatChangePercent(changePercent)})';

    if (showBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 2),
            Text(
              formattedText,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: fontSize + 4, color: color),
        Text(
          formattedText,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
