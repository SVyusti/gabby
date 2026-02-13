import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/google_street_view.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.softGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Explore the World 🌍",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded( // 🔥 Important fix
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GoogleMapWeb( // ✅ Correct widget name
                  latitude: 37.869260,
                  longitude: -122.254811,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
