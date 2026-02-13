import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapWeb extends StatelessWidget {
  final double latitude;
  final double longitude;

  const GoogleMapWeb({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  Future<void> _openStreetView() async {
    final Uri streetViewUri = Uri.parse(
      "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$latitude,$longitude",
    );

    if (await canLaunchUrl(streetViewUri)) {
      await launchUrl(
        streetViewUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: _openStreetView,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.streetview,
                  size: 48,
                  color: Color(0xFFFC4566),
                ),
                SizedBox(height: 12),
                Text(
                  "Open Street View",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Tap to explore in Google Maps",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
