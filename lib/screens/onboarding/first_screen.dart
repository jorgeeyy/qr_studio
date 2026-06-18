import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_studio/screens/onboarding/second_screen.dart';
import 'package:qr_studio/screens/main/home_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            text: 'QR Studio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'ElmsSans',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('onboarding_complete', true);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 50),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/images/QR3.png'),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Generate QR Codes Easily',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ElmsSans',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Create QR Codes for links, texts, \ncontacts, Wi-Fi, and more.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: 'ElmsSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to the next onboarding screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondScreen()),
                      (route) => false,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'ElmsSans',
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "step 1 of 3".toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'ElmsSans',
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
