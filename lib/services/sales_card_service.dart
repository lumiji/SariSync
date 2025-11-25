import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SalesService {
  Stream<Map<String, dynamic>> todaySalesStream() {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month}-${now.day}';
    final uid = FirebaseAuth.instance.currentUser!.uid;
    

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailySales')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'totalSales': (data['totalSales'] ?? 0).toDouble(),
          'totalItemsSold': (data['totalItemsSold'] ?? 0) as int,
        };
      } else {
        return {'totalSales': 0.0, 'totalItemsSold': 0};
      }
    });
  }
}
