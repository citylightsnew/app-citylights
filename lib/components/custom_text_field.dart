import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        Theme.of(context).scaffoldBackgroundColor.computeLuminance() < 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: isDarkTheme
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.5),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkTheme
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.7),
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: isDarkTheme
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.withOpacity(0.8),
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixIconTap,
                      child: Icon(
                        suffixIcon,
                        color: isDarkTheme
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey.withOpacity(0.8),
                        size: 20,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkTheme
                      ? Colors.white.withOpacity(0.6)
                      : Colors.purple,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkTheme ? Colors.red.withOpacity(0.8) : Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkTheme ? Colors.red.withOpacity(0.8) : Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              filled: !isDarkTheme,
              fillColor: isDarkTheme ? null : Colors.grey.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}
