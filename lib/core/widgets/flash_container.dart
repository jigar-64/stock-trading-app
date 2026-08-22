import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../features/market/domain/price_quote.dart';

/// A reusable container that flashes green (price up) or red (price down)
/// whenever the underlying price updates.
///
/// Uses an [AnimationController] to smoothly fade out the flash background
/// over 350 milliseconds. Flash state is kept entirely local to this widget,
/// ensuring zero pollution of global market state.
class FlashContainer extends StatefulWidget {
  const FlashContainer({
    super.key,
    required this.child,
    required this.direction,
    required this.timestamp,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 8.0,
  });

  /// The child content (e.g., stock row layout).
  final Widget child;

  /// Movement direction of the latest price update.
  final PriceDirection direction;

  /// Timestamp of the latest update. Used to trigger flash even if direction stays same.
  final DateTime timestamp;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Border radius of the container.
  final double borderRadius;

  @override
  State<FlashContainer> createState() => _FlashContainerState();
}

class _FlashContainerState extends State<FlashContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Color _flashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(FlashContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger flash if timestamp changed and direction is up or down
    if (widget.timestamp != oldWidget.timestamp &&
        widget.direction != PriceDirection.flat) {
      _triggerFlash();
    }
  }

  void _updateAnimation() {
    _colorAnimation = ColorTween(
      begin: _flashColor,
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _triggerFlash() {
    if (widget.direction == PriceDirection.up) {
      _flashColor = AppColors.flashGreen;
    } else if (widget.direction == PriceDirection.down) {
      _flashColor = AppColors.flashRed;
    } else {
      return;
    }

    _updateAnimation();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _colorAnimation.value ?? Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
