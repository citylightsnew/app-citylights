import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        Theme.of(context).scaffoldBackgroundColor.computeLuminance() < 0.5;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isDarkTheme
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.88),
                  Colors.white.withValues(alpha: 0.80),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor ?? Colors.blue,
                  (backgroundColor ?? Colors.blue).withValues(alpha: 0.85),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: isDarkTheme
            ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? Colors.white.withValues(alpha: 0.2)
                : (backgroundColor ?? Colors.blue).withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (isDarkTheme)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDarkTheme
              ? const Color(0xFF0A0A0A)
              : (textColor ?? Colors.white),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: isDarkTheme
              ? const Color(0xFF0A0A0A).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.6),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkTheme
                        ? const Color(0xFF0A0A0A)
                        : (textColor ?? Colors.white),
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isDarkTheme
                      ? const Color(0xFF0A0A0A)
                      : (textColor ?? Colors.white),
                ),
              ),
      ),
    );
  }
}
