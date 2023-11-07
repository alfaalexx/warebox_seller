import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormFieldPrice extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextStyle labelStyle;
  final String prefixText;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Function(String) onChanged;
  final String? Function(String?) validator;

  const CustomTextFormFieldPrice({
    Key? key,
    required this.controller,
    this.labelText = '',
    this.labelStyle = const TextStyle(),
    this.prefixText = '',
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: labelStyle,
        prefixText: prefixText,
        errorStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
        filled: true,
        fillColor: Color(0xFFF2F2F2),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0x00000000), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2E9496), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
