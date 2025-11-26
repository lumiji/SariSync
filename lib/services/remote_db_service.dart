import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoteDbService {
  /// Initialize user document and default collections in Firestore
  static Future<void> initializeUserDatabase({String? uid}) async {
    final userUid = uid ?? FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userUid);

    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': FirebaseAuth.instance.currentUser?.displayName ?? '',
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
      });

      await userDoc.collection('inventory').doc('init').set({'placeholder': true});
      await userDoc.collection('ledger').doc('init').set({'placeholder': true});
      await userDoc.collection('home').doc('init').set({'placeholder': true});
    }
  }
}
