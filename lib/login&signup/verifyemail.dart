import 'dart:async';
import 'package:brg_donation/Home/home.dart';
import 'package:brg_donation/login&signup/loginScreen.dart';
import 'package:brg_donation/themes/colors.dart';
import 'package:brg_donation/themes/dark_light_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  VerifyEmailScreen(this.email);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isEmailVerified = false;
  Timer? emailVerificationTimer;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    // Check if the user is already verified, otherwise start the timer
    if (user != null) {
      isEmailVerified = user!.emailVerified;
      if (!isEmailVerified) {
        startEmailVerificationTimer();
      } else {
        _navigateToHome();
      }
    }
  }

  void startEmailVerificationTimer() {
    emailVerificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await checkEmailVerified();
    });
  }

  Future<void> checkEmailVerified() async {
    await user?.reload(); // Refresh user data
    user = _auth.currentUser; // Update user instance
    if (user != null && user!.emailVerified) {
      setState(() {
        isEmailVerified = true;
      });
      emailVerificationTimer?.cancel(); // Stop the timer
      _navigateToHome();
    }
  }

  @override
  void dispose() {
    emailVerificationTimer?.cancel(); // Ensure the timer is disposed properly
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false, // Clear the stack
    );
  }

  Future<void> resendVerification() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification email resent to ${widget.email}"),
          backgroundColor: PrimaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error resending verification email."),
          backgroundColor: PrimaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkLight(isDarkMode),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail,
                  size: 100.0,
                  color: PrimaryColor,
                ),
                SizedBox(height: 24.0),
                Text(
                  'Verify your email address',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: LightDark(isDarkMode),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Text(
                  'We have sent a verification link to your email. '
                      'Please check your email and click on the link to verify your email address.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: LightDark(isDarkMode),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: isEmailVerified ? _navigateToHome : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: PrimaryColor),
                    ),
                    backgroundColor: darkLight(isDarkMode),
                    foregroundColor: PrimaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: isEmailVerified ? null : resendVerification,
                  child: Text(
                    'Resend E-Mail Link',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.blue),
                  label: Text(
                    'Back to login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
