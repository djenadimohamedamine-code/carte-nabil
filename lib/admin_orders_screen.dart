import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Future<void> _clearOrders(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vider les commandes ?"),
        content: const Text("Toutes les commandes de maillots seront supprimées définitivement."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ANNULER")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("OUI, TOUT VIDER", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 tabs now
      child: Column(
        children: [
          Container(
            color: Colors.red.shade900,
            child: Row(
              children: [
                const Expanded(
                  child: TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(icon: Icon(Icons.list_alt), text: "DÉTAILS"),
                      Tab(icon: Icon(Icons.pie_chart), text: "TAILLES"),
                      Tab(icon: Icon(Icons.map), text: "ZONES"),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  tooltip: "Vider les commandes",
                  onPressed: () => _clearOrders(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Erreur."));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final orders = snapshot.data!.docs;

                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Aucune commande pour le moment.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  children: [
                    _buildOrdersList(orders),
                    _buildStatsBySize(orders),
                    _buildStatsByZone(orders),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<QueryDocumentSnapshot> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final data = orders[index].data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)),
            title: Text(data['memberName'] ?? 'Inconnu', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("ID: ${data['memberId']} • Zone ${data['zone']}"),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
              child: Text(
                data['size'] ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsBySize(List<QueryDocumentSnapshot> orders) {
    Map<String, int> stats = {};
    for (var doc in orders) {
      final size = (doc.data() as Map<String, dynamic>)['size'] ?? 'Unknown';
      stats[size] = (stats[size] ?? 0) + 1;
    }

    final sortedSizes = ['S', 'M', 'L', 'XL', 'XXL'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("TOTAL PAR TAILLE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ...sortedSizes.map((size) {
          final count = stats[size] ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
            child: ListTile(
              title: Text("Taille $size", style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text("$count", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.red)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsByZone(List<QueryDocumentSnapshot> orders) {
    Map<int, int> stats = {};
    for (var doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      final zone = data['zone'] ?? 0;
      stats[zone] = (stats[zone] ?? 0) + 1;
    }

    final sortedZones = stats.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("TOTAL PAR ZONE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ...sortedZones.map((zone) {
          final count = stats[zone] ?? 0;
          return Card(
            child: ListTile(
              title: Text("ZONE $zone"),
              trailing: Text("$count commandes", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ],
    );
  }
}
