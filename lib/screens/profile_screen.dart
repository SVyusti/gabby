import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_auth.dart';

import '../services/storage_service.dart';
import '../models/dream.dart';
import '../theme/app_theme.dart';
import '../auth_gate.dart';
import 'actions_screen.dart';

import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseServices().googleSignOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $err')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
         Container(
            width: double.infinity,
            height: 191,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_image.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(96, 49, 58, 0.40),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left: Title
                          Text(
                            'Profile',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          // Right: Logout Icon
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () => _logout(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // User Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF6F6F6),
                      border: Border.all(color: const Color(0xFFFC4566), width: 2),
                      image: FirebaseAuth.instance.currentUser?.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: FirebaseAuth.instance.currentUser?.photoURL == null
                        ? Center(
                            child: Text(
                              FirebaseAuth.instance.currentUser?.email?.isNotEmpty == true
                                  ? FirebaseAuth.instance.currentUser!.email![0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.bricolageGrotesque(
                                fontSize: 40,
                                color: const Color(0xFFFC4566),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Username
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? 'Dreamer',
                    style: GoogleFonts.bricolageGrotesque(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? 'No email',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout Button (Text)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF0F3), // Light pink
                        foregroundColor: const Color(0xFFFC4566), // Dark pink text
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: GoogleFonts.archivo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'StepUp v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
