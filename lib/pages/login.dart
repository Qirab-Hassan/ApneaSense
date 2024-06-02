import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apneasense/components/button.dart';
import 'package:apneasense/components/textfield.dart';
import 'package:apneasense/components/alertmessage.dart';
import 'package:apneasense/pages/forgotpassword.dart';

class LoginPage extends StatefulWidget {
  void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailEditController = TextEditingController();

  TextEditingController passwordEditController = TextEditingController();

  void Login() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailEditController.text.trim(),
          password: passwordEditController.text.trim());

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (emailEditController.text.isEmpty ||
          passwordEditController.text.isEmpty) {
        displayMessageToUser("Fields cannot be empty.", context);
      } else {
        displayMessageToUser(e.code, context);
      }
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
                          width: 230,
                          height: 230,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordPage(),
                                    ));
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.black),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CustomButton(text: "Login", onTap: Login),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              " Register Here.",
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
