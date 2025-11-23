import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalSearchService {
  static List<Map<String, dynamic>> globalSearchList = [];

  static Future<void> loadSearchData() async {
    globalSearchList = [];

    // Load inventory items
    final invSnapshot =
        await FirebaseFirestore.instance.collection('inventory').get();

    for (var doc in invSnapshot.docs) {
      globalSearchList.add({
        "name": doc['name'],
        "type": "inventory",
        "id": doc.id,
      });
    }

    // Load ledger customers
    final ledgerSnapshot =
        await FirebaseFirestore.instance.collection('ledger').get();

    for (var doc in ledgerSnapshot.docs) {
      globalSearchList.add({
        "name": doc['name'],
        "type": "ledger",
        "id": doc.id,
      });
    }
  }
}
