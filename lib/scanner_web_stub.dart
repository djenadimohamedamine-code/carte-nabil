import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerPlatformImplementation extends StatefulWidget {
  const ScannerPlatformImplementation({super.key});

  @override
  State<ScannerPlatformImplementation> createState() => _ScannerPlatformImplementationState();
}

class _ScannerPlatformImplementationState extends State<ScannerPlatformImplementation> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.medium);
        await _controller!.initialize();
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      print("Erreur caméra Web: $e");
    }
  }

  Future<void> _verifyMember(String matricule) async {
    final query = await FirebaseFirestore.instance
        .collection('members')
        .where('matricule', isEqualTo: matricule.toUpperCase())
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      
      await doc.reference.update({'is_present': true, 'last_scanned': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance.collection('scans_history').add({
        'name': data['name'],
        'cardId': data['cardId'],
        'zone': data['zone'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showResultDialog(data['name'], data['zone'], true);
        _searchController.clear();
      }
    } else {
      if (mounted) _showResultDialog("Inconnu", 0, false);
    }
  }

  void _showResultDialog(String name, int zone, bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: success ? Colors.green.shade50 : Colors.red.shade50,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(success ? "ACCÈS AUTORISÉ" : "ACCÈS REFUSÉ", style: TextStyle(fontWeight: FontWeight.w900, color: success ? Colors.green : Colors.red)),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (success) Text("Zone $zone", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview (même si OCR limité)
          if (_isCameraInitialized && _controller != null)
            Center(child: CameraPreview(_controller!))
          else
            const Center(child: Text("Caméra non disponible sur ce navigateur", style: TextStyle(color: Colors.white))),

          // UI Overlay
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.black54,
                child: const Text(
                  "SCANNER WEB USMA\n(OCR limité sur Web - Utilisez la recherche)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Entrer Matricule",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Colors.red),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                      onSubmitted: _verifyMember,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        onPressed: () => _verifyMember(_searchController.text),
                        child: const Text("VÉRIFIER L'ACCÈS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
