import 'package:cloud_firestore/cloud_firestore.dart';

class DataManager {
  static Future<void> seedInitialMembers() async {
    final collection = FirebaseFirestore.instance.collection('members');
    
    // Seed Souheib
    await collection.doc('ac001').set({
      'name': 'Laroui Souheib',
      'cardId': 'ac001',
      'is_present': false,
      'matricule': 'ac001',
      'zone': 14,
    }, SetOptions(merge: true));

    // Seed Nabil
    await collection.doc('ac010').set({
      'name': 'Lafri Nabil',
      'cardId': 'ac010',
      'is_present': false,
      'matricule': 'ac010',
      'zone': 14,
    }, SetOptions(merge: true));
    
    print("Initial members seeded successfully.");
  }
}
