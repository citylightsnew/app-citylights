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
    this.height = 50,
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
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.7),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor ?? Colors.purple,
                  (backgroundColor ?? Colors.purple).withOpacity(0.8),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: isDarkTheme
            ? Border.all(color: Colors.white.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? Colors.black.withOpacity(0.3)
                : (backgroundColor ?? Colors.purple).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isDarkTheme
              ? Colors.black87
              : (textColor ?? Colors.white),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkTheme ? Colors.black87 : Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: isDarkTheme
                      ? Colors.black87
                      : (textColor ?? Colors.white),
                ),
              ),
      ),
    );
  }
}
