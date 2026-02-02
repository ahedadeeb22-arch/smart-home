import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// بطاقة زجاجية - Glassmorphism Card
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final double blur;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enableGlow;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.borderColor,
    this.borderWidth = 1,
    this.blur = 10,
    this.backgroundColor,
    this.onTap,
    this.enableGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveBorderColor = borderColor ??
        (isDark
            ? AppColors.primaryCyan.withOpacity(0.2)
            : Colors.white.withOpacity(0.5));

    final effectiveBackgroundColor = backgroundColor ??
        (isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7));

    final effectiveGlowColor = glowColor ?? AppColors.primaryCyan;

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: effectiveGlowColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// بطاقة زجاجية مع تأثير نيون
class NeonGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color neonColor;
  final VoidCallback? onTap;
  final bool isActive;

  const NeonGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.neonColor = AppColors.primaryCyan,
    this.onTap,
    this.isActive = false,
  });

  @override
  State<NeonGlassCard> createState() => _NeonGlassCardState();
}

class _NeonGlassCardState extends State<NeonGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassCard(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          margin: widget.margin,
          borderRadius: widget.borderRadius,
          borderColor: widget.isActive
              ? widget.neonColor.withOpacity(_animation.value)
              : widget.neonColor.withOpacity(0.2),
          borderWidth: widget.isActive ? 2 : 1,
          enableGlow: widget.isActive,
          glowColor: widget.neonColor,
          onTap: widget.onTap,
          child: widget.child,
        );
      },
    );
  }
}

/// زر زجاجي
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 15,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? (isDark ? AppColors.primaryCyan : AppColors.primaryBlue);

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height ?? 56,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              effectiveColor,
              effectiveColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}