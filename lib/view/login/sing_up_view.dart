import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ktk_food/common/color_extension.dart';
import 'package:ktk_food/common/extension.dart';
import 'package:ktk_food/common_widget/round_button.dart';
import 'package:ktk_food/view/login/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/round_textfield.dart';
import '../on_boarding/on_boarding_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
              Text(
                "Sign Up",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                "Add your details to sign up",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Name",
                controller: txtName,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Mobile No",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Address",
                controller: txtAddress,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 25,
              ),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 25,
              ),
              isloading
                  ? const CircularProgressIndicator()
                  : RoundButton(
                      title: "Sign Up",
                      onPressed: () {
                        btnSignUp();
                        // Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const OnBoardingView(),
                        //     ),
                        //     (route) => false);
                        //  Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const OTPView(),
                        //       ),
                        //     );
                      }),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an Account? ",
                      style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                          color: TColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void btnSignUp() async {
    if (txtName.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterName, () {});
      return;
    }

    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    if (txtMobile.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterMobile, () {});
      return;
    }

    if (txtAddress.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterAddress, () {});
      return;
    }

    if (txtPassword.text.length < 6) {
      mdShowAlert(Globs.appName, MSG.enterPassword, () {});
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      mdShowAlert(Globs.appName, MSG.enterPasswordNotMatch, () {});
      return;
    }

    try {
      setState(() {
        isloading = true; // Show loading indicator
      });

      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: txtEmail.text.trim(),
        password: txtPassword.text,
      );

      // Save additional user data in Firestore
      if (userCredential.user != null) {
        print("User Created: ${userCredential.user!.uid}");

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          "name": txtName.text.trim(),
          "mobile": txtMobile.text.trim(),
          "address": txtAddress.text.trim(),
          "email": txtEmail.text.trim(),
          "createdAt": FieldValue.serverTimestamp(),
        });

        setState(() {
          isloading = false; // Hide loading indicator
        });

        // Log that the navigation is happening
        print("Navigating to OnBoarding screen...");

        // Navigate to OnBoarding screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const OnBoardingView(),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          isloading = false; // Hide loading indicator
        });
        print("User creation failed");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isloading = false; // Hide loading indicator
      });
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak.";
      } else {
        errorMessage = "Sign-up failed: ${e.message}";
      }
      mdShowAlert(Globs.appName, errorMessage, () {});
    } catch (e) {
      setState(() {
        isloading = false; // Hide loading indicator
      });
      mdShowAlert(Globs.appName, "An unexpected error occurred: $e", () {});
    }
  }

  //TODO: Action
  // void btnSignUp() {
  //   if (txtName.text.isEmpty) {
  //     mdShowAlert(Globs.appName, MSG.enterName, () {});
  //     return;
  //   }

  //   if (!txtEmail.text.isEmail) {
  //     mdShowAlert(Globs.appName, MSG.enterEmail, () {});
  //     return;
  //   }

  //   if (txtMobile.text.isEmpty) {
  //     mdShowAlert(Globs.appName, MSG.enterMobile, () {});
  //     return;
  //   }

  //   if (txtAddress.text.isEmpty) {
  //     mdShowAlert(Globs.appName, MSG.enterAddress, () {});
  //     return;
  //   }

  //   if (txtPassword.text.length < 6) {
  //     mdShowAlert(Globs.appName, MSG.enterPassword, () {});
  //     return;
  //   }

  //   if (txtPassword.text != txtConfirmPassword.text) {
  //     mdShowAlert(Globs.appName, MSG.enterPasswordNotMatch, () {});
  //     return;
  //   }

  //   endEditing();

  //   serviceCallSignUp({
  //     "name": txtName.text,
  //     "mobile": txtMobile.text,
  //     "email": txtEmail.text,
  //     "address": txtAddress.text,
  //     "password": txtPassword.text,
  //     "push_token": "",
  //     "device_type": Platform.isAndroid ? "A" : "I"
  //   });
  // }

  // //TODO: ServiceCall

  // void serviceCallSignUp(Map<String, dynamic> parameter) {
  //   Globs.showHUD();

  //   ServiceCall.post(parameter, SVKey.svSignUp,
  //       withSuccess: (responseObj) async {
  //     Globs.hideHUD();
  //     if (responseObj[KKey.status] == "1") {
  //       Globs.udSet(responseObj[KKey.payload] as Map? ?? {}, Globs.userPayload);
  //       Globs.udBoolSet(true, Globs.userLogin);

  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const OnBoardingView(),
  //           ),
  //           (route) => false);
  //     } else {
  //       mdShowAlert(Globs.appName,
  //           responseObj[KKey.message] as String? ?? MSG.fail, () {});
  //     }
  //   }, failure: (err) async {
  //     Globs.hideHUD();
  //     mdShowAlert(Globs.appName, err.toString(), () {});
  //   });
  // }
}
