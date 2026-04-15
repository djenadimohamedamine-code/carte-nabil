import 'package:cloud_firestore/cloud_firestore.dart';

class DataManager {
  static Future<void> seedInitialMembers() async {
    final collection = FirebaseFirestore.instance.collection('members');
    
    // 1. Check if we already have members to avoid wiping data every time
    final snapshot = await collection.get();
    if (snapshot.docs.isNotEmpty) {
      print("La base de données contient déjà des membres. Pas de réinitialisation.");
      return;
    }
    
    print("Initialisation de la base de données (première fois)...");

    // 2. Sample data across different zones
    final List<Map<String, dynamic>> initialData = [
      {
        'cardId': 'AB005',
        'name': 'Lafri Ilyes',
        'is_present': false,
        'matricule': 'AB005',
        'zone': 5,
      },
      {
        'cardId': 'AN001',
        'name': 'Sidou Charefi',
        'is_present': false,
        'matricule': 'AN001',
        'zone': 1,
      },
      {
        'cardId': 'AC001',
        'name': 'Laroui Souheib',
        'is_present': false,
        'matricule': 'AC001',
        'zone': 14,
      },
      {
        'cardId': 'AC010',
        'name': 'Lafri Nabil Riad',
        'is_present': false,
        'matricule': 'AC010',
        'zone': 14,
      },
      {
        'cardId': 'AC002',
        'name': 'Brahimi Mohamed',
        'is_present': false,
        'matricule': 'AC002',
        'zone': 1,
      },
      {
        'cardId': 'AC003',
        'name': 'Ziani Mourad',
        'is_present': false,
        'matricule': 'AC003',
        'zone': 5,
      },
      {
        'cardId': 'AC004',
        'name': 'Belmadi Djamel',
        'is_present': false,
        'matricule': 'AC004',
        'zone': 7,
      },
      {
        'cardId': 'AC105',
        'name': 'Mahrez Riyad',
        'is_present': false,
        'matricule': 'AC105',
        'zone': 14,
      },
      {
        'cardId': 'AC106',
        'name': 'Slimani Islam',
        'is_present': false,
        'matricule': 'AC106',
        'zone': 14,
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var member in initialData) {
      batch.set(collection.doc(member['cardId']), {
        ...member,
        'last_scanned': null,
      });
    }
    
    await batch.commit();
    print("Base de données initialisée avec ${initialData.length} membres de test.");
  }
}
