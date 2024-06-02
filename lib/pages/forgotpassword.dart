import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apneasense/components/textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              'Password reset Link sent.',
              style: GoogleFonts.roboto(
                  textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                  fontWeight: FontWeight.bold),
            ),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (_emailController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor:
                  Colors.grey, // Change the background color of the AlertDialog
              title: Text(
                "Field cannot be empty.",
                style: GoogleFonts.roboto(
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 20),
                    fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Please provide your email address to receive a password reset link.",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: CustomTextField(
                hint: "xyz@gmail.com",
                label: "Email",
                obscureText: false,
                controller: _emailController),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: () {
              passwordReset();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xff64EBB6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    20), // Adjust the border radius as needed
              ),
              fixedSize: const Size(
                  200, 50), // Adjust the size of the button as needed
            ),
            child: const Text("Reset Password"),
          ),
        ],
      ),
    );
  }
}
