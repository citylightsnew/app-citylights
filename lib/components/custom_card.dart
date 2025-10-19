import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        elevation: elevation ?? 8,
        color: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
