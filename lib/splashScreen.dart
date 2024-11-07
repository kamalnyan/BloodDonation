import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Apis/loginApis.dart';
import 'Home/home.dart';
import 'login&signup/intoScreen.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  @override
  void initState() {
    super.initState();
    // Timer to navigate to the next screen after 2 seconds
    Timer(const Duration(seconds: 2), () async {
      try {
        User? user = FirebaseAuth.instance.currentUser; // Get the current user
        if (user != null) {
          // Reload user data to get the latest status
          await user.reload();
          user = FirebaseAuth.instance.currentUser; // Update with the latest user data

          // Check if the user is not anonymous and the email is verified
          if (!user!.isAnonymous && user.emailVerified) {
            await OrganLS.fetchUserInfo();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
            );
            return;
          } else {
            // Sign out the user if they are anonymous or email is not verified
            await FirebaseAuth.instance.signOut();
          }
        } else {
          // Sign out if the user is null (not found)
          await FirebaseAuth.instance.signOut();
        }
      } catch (e) {
        // Handle any error that might occur, such as network issues
        print('Error: $e');
        // Sign out the user in case of any exception
        await FirebaseAuth.instance.signOut();
      }

      // Navigate to the IntroScreen if the user is not valid, not found, deleted, or anonymous
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.blue, // You can change this to any color or image
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/splashScreen.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              repeat: true,
              animate: true,
              frameRate: FrameRate(120),

            ),
            const SizedBox(height: 20),
            // Display text
            const Text(
              // 'HopeLink',
              'Organ Donation',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
