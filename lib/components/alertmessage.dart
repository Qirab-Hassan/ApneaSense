import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor:
            Colors.grey, // Change the background color of the AlertDialog
        title: Text(
          message,
          style: GoogleFonts.roboto(
              textStyle: const TextStyle(color: Colors.white, fontSize: 20),
              fontWeight: FontWeight.bold),
        ),
      );
    },
  );
}
