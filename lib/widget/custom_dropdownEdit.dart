import 'package:flutter/material.dart';

class CustomDropdownFormFieldEdit extends StatelessWidget {
  final String hintText;
  final List<String> options;
  final TextEditingController controller;
  final String? Function(String?) validator;

  const CustomDropdownFormFieldEdit({
    Key? key,
    required this.hintText,
    required this.options,
    required this.controller,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.0,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          hintText: hintText,
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
        value: controller.text.isNotEmpty ? controller.text : null,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          controller.text = newValue ?? '';
        },
        validator: validator,
      ),
    );
  }
}
