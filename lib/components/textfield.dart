import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final bool obscureText;
  TextEditingController controller;
  CustomTextField(
      {super.key,
      required this.hint,
      required this.label,
      required this.obscureText,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff64EBB6), width: 2.0),
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: hint,
        ),
      ),
    );
  }
}
