import 'package:flutter/material.dart';
import '../services/google_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseServices = FirebaseServices();

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg_image.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Background Overlay
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(96, 49, 58, 0.40),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo and App Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/app_logo.png',
                      height: 60,
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/app_name.png',
                      height: 55  , 
                      // Adjust height based on actual aspect ratio
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Main Text: Complete Your TO DOs With Fun (Figma-aligned headline)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/Complete.png',
                          fit: BoxFit.contain,
                          height: 54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/Your TO DOs.png',
                          fit: BoxFit.contain,
                          height: 54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/with fun.png',
                          fit: BoxFit.contain,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Button Container
                Padding(
                  padding: const EdgeInsets.symmetric(
 
                    horizontal: 31,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Login Button
                      GestureDetector(
                        onTap: () async {
                          final success = await firebaseServices.signInWithGoogle();
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Google sign-in failed')),
                            );
                          }
                        },
                        child: Image.asset(
                          'assets/login_with_google.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      // Have an account button
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to login or handle account check
                        },
                        child: Image.asset(
                          'assets/have an account.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
