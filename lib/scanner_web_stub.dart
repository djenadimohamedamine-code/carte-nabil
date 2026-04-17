import 'package:flutter/material.dart';

class ScannerPlatformImplementation extends StatelessWidget {
  const ScannerPlatformImplementation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              "SCANNER INDISPONIBLE",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Le scanneur OCR nécessite une installation sur mobile (Android/iOS) pour fonctionner.\n\nVeuillez utiliser l'application mobile pour scanner les cartes.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
