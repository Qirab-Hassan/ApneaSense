import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apneasense/components/button.dart';
import 'package:apneasense/components/textfield.dart';
import 'package:apneasense/components/alertmessage.dart';

class SignUpPage extends StatefulWidget {
  void Function()? onTap;
  SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController userEditController = TextEditingController();

  TextEditingController emailEditController = TextEditingController();

  TextEditingController passwordEditController = TextEditingController();

  TextEditingController confirmPasswordEditController = TextEditingController();

  void register() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //Confirm Password Logic
    if (passwordEditController.text != confirmPasswordEditController.text) {
      Navigator.pop(context);
      displayMessageToUser("Password does not match.", context);
      return;
    }

    if (userEditController.text.isEmpty ||
        emailEditController.text.isEmpty ||
        passwordEditController.text.isEmpty ||
        confirmPasswordEditController.text.isEmpty) {
      Navigator.pop(context);
      displayMessageToUser("Fields cannot be empty.", context);
      return;
    }

    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailEditController.text.trim(),
              password: passwordEditController.text.trim());

      createUserDocument(userCredential);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': userEditController.text,
        'uid': userCredential.user!.uid,
        'userEmail': userCredential.user!.email,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0), // Make corners rounded
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/ApneaSenseLogo.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CustomTextField(
                          hint: "Name",
                          label: "Username",
                          obscureText: false,
                          controller: userEditController),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                          hint: "xyz@gmail.com",
                          label: "Email",
                          obscureText: false,
                          controller: emailEditController),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                          hint: "Password",
                          label: "Password",
                          obscureText: true,
                          controller: passwordEditController),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                          hint: "Password",
                          label: "Confirm Password",
                          obscureText: true,
                          controller: confirmPasswordEditController),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CustomButton(text: "Register", onTap: register),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              " Login Here.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
