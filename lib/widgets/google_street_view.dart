import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// We keep the same class name so you don't break your other files.
class GoogleMapWeb extends StatelessWidget {
  final double latitude;
  final double longitude;

  const GoogleMapWeb({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    // Instead of a broken web view, we return a nice card/button
    // that the user taps to open the real Google Maps app.
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _launchMaps(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            height: 200, // Fixed height for the placeholder
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, size: 48, color: Colors.blue),
                const SizedBox(height: 12),
                Text(
                  "View Location in Google Maps",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Click to open external map",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMaps() async {
    // 1. Try to open the native Google Maps app using the 'geo:' intent
    final Uri nativeMapUri = Uri.parse("geo:$latitude,$longitude?q=$latitude,$longitude");

    // 2. Fallback URL (opens in browser if no map app is installed)
    final Uri browserMapUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    try {
      if (await canLaunchUrl(nativeMapUri)) {
        await launchUrl(nativeMapUri);
      } else {
        // If the app isn't installed, open the browser
        await launchUrl(browserMapUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch maps: $e");
    }
  }
}