import 'package:flutter/material.dart';

// Define a callback type for selection changes
typedef OnChanged<T> = void Function(T? newValue);
typedef ItemBuilder<T> = String Function(T item);

class CustomDropdown<T> extends StatefulWidget {
  final T? selectedItem;
  final List<T> items;
  final OnChanged<T> onChanged;
  final ItemBuilder<T> itemBuilder;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.selectedItem,
    this.validator, // validator bisa jadi opsional, tergantung penggunaannya.
    this.hintText = 'Select an option',
  }) : super(key: key);

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  T? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.0,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          hintText: widget.hintText,
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
        value: selectedItem,
        items: widget.items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(widget.itemBuilder(value)),
          );
        }).toList(),
        onChanged: (T? newValue) {
          setState(() {
            selectedItem = newValue;
          });
          widget.onChanged(newValue);
        },
        validator: (value) {
          if (value == null) {
            return 'Please make a selection';
          }
          return null;
        },
      ),
    );
  }
}
