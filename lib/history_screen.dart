import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.black,
          child: const Text(
            "HISTORIQUE DES SCANS",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('scans_history')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Erreur de chargement de l'historique."));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final scans = snapshot.data!.docs;

              if (scans.isEmpty) {
                return const Center(
                  child: Text(
                    "Aucun scan enregistré pour le moment.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: scans.length,
                itemBuilder: (context, index) {
                  final scan = scans[index].data() as Map<String, dynamic>;
                  final String name = scan['name'] ?? 'Inconnu';
                  final String zone = (scan['zone'] ?? '?').toString();
                  final DateTime timestamp = (scan['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final String timeStr = DateFormat('HH:mm:ss').format(timestamp);
                  final String dateStr = DateFormat('dd/MM').format(timestamp);

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.history, color: Colors.black),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Zone $zone • $dateStr à $timeStr"),
                    trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
