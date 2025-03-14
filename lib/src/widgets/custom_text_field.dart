import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.obscureTextValue,
    this.fontSize,
    this.fieldWidth,
    this.leadingIcon,
    this.suffixIcon,
    this.controllerParam,
    this.hintText,
  });

  final String? obscureTextValue;
  final double? fieldWidth;
  final double? fontSize;
  final IconData? leadingIcon;
  final IconData? suffixIcon;
  final TextEditingController? controllerParam;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.0),
        child: SizedBox(
          width: fieldWidth, // Runtime value
          height: screenHeight * 0.1, // Runtime value
          child: TextField(
            obscureText: false,
            controller: controllerParam,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: obscureTextValue,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: fontSize!,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF455A64),
                ),
                labelStyle: TextStyle(
                  fontSize: fontSize, // Runtime value
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF455A64),
                ),
                prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
                suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null
                // Provide a valid string
                ),
            style: TextStyle(
              fontSize: fontSize, // Runtime value
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: Color(0xFF455A64),
            ),
          ),
        ));
  }
}
