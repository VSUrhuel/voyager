import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    this.labelText,
    this.fontSize,
    this.leadingIcon,
    this.controllerParam,
  });

  final String? labelText;
  final double? fontSize;
  final IconData? leadingIcon;
  final TextEditingController? controllerParam;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controllerParam,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscured,
      focusNode: textFieldFocusNode,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'StrongPass@123',
        hintStyle: TextStyle(
          fontSize: widget.fontSize!,
          fontStyle: FontStyle.italic,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Color(0xFF455A64),
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          fontSize: widget.fontSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Color(0xFF455A64),
        ),
        prefixIcon:
            widget.leadingIcon != null ? Icon(widget.leadingIcon) : null,
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: GestureDetector(
            onTap: _toggleObscured,
            child: Icon(
              _obscured
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 24,
            ),
          ),
        ),
      ),
      style: TextStyle(
        fontSize: widget.fontSize, // Runtime value
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        color: Color(0xFF455A64),
      ),
    );
  }
}
