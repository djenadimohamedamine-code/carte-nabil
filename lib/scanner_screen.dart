import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports to avoid compilation errors on Web
import 'scanner_mobile.dart' if (dart.library.html) 'scanner_web_stub.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  Widget build(BuildContext context) {
    // This delegates the build to the platform-specific implementation
    return const ScannerPlatformImplementation();
  }
}
