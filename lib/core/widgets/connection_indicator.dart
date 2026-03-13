import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ConnectionIndicator extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;
  final double size;

  const ConnectionIndicator({
    super.key,
    this.isConnected = false,
    this.isConnecting = false,
    this.size = 10,
  });

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isConnecting) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ConnectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnecting && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isConnecting && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    if (widget.isConnecting) return AppColors.warning;
    if (widget.isConnected) return AppColors.success;
    return AppColors.error;
  }

  String get _label {
    if (widget.isConnecting) return 'Connecting...';
    if (widget.isConnected) return 'Connected';
    return 'Disconnected';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _color.withValues(
                  alpha: widget.isConnecting ? _pulseAnimation.value : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
