// for saving customer into Firebase database
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:sarisync/models/ledger_item.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LedgerService {
  //initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get ledger =>
      _firestore.collection('users').doc(uid).collection('ledger');

  //checks if customer is in ledger
  Future<QueryDocumentSnapshot?> findCustomerByName(String name) async {
    final snap = await ledger.where('name', isEqualTo: name).limit(1).get();
    return snap.docs.isEmpty ? null : snap.docs.first;
  }

  //Create NEW customer ledger record
  Future<String> createCustomer({
  required String name,
  required double initialCredit,
  required String receivedBy,
}) async {
  final customerID = await generateCustomerId(); // generate new ID

  await ledger.doc(customerID).set({
    'customerID': customerID,   // save the same ID in the document
    'name': name,
    'credit': initialCredit,
    'payStatus' : 'Unpaid',
    'image': null,
    'receivedBy': receivedBy,
    'createdAt': Timestamp.now(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  return customerID;
}


  // Add credit to existing customer
  Future<void> updateCustomerCredit(String customerID, double amount) async {
  await ledger.doc(customerID).update({
    'credit': FieldValue.increment(amount),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}



  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      print('Uploading image: ${imageFile.path}');
      final ref = _storage
          .ref()
          .child('ledger_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();
      print('Upload successful, URL: $downloadUrl');
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Add item to Firestore
  Future<void> addLedgerItem({
    required String name,
    required String customerID,
    String? contact,
    required String payStatus,
    required double credit,
    double? partialPay,
    required String received,
    File? imageFile,
  }) async {
    try {

      final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .doc(customerID);

      await docRef.set({
        'name': name,
        'customerID': customerID,
        'contact': contact,
        'payStatus': payStatus,
        'credit': credit,
        'partialPay':  partialPay,
        'received': received,
        'imageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt' : FieldValue.serverTimestamp(),
      });

      print("Item added successfully!");
  
      if (imageFile != null){
        uploadImage(imageFile).then((url) async {
          if (url != null) {
            await docRef.update({'imageUrl' : url});
            print('Ledger item updated with image URL: $url');
          }
      });
    }
  } catch (e) {
    print('Error adding ledger item: $e');
    rethrow;
  }
  }

  Stream<List<LedgerItem>> getLedgerItems() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LedgerItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addCustomerDebt({
    required String customerID,
    required String name, 
    required double credit, 
    String? contact,
    required String receivedBy
  }) async {
    final docRef = ledger.doc(customerID);

    await docRef.set({
      'customerID': customerID,
      'name': name, 
      'contact' : contact, 
      'credit': credit,
      'partialPay' : 0,
      'payStatus': 'Unpaid',
      'image': null,
      'receivedBy' : receivedBy,
      'createdAt' : Timestamp.now(),
      'updatedAt' : FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLedgerItem(String customerID, Map<String, dynamic> data) async {
    try{
      await _firestore
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .doc(customerID)
        .update(data);
    } catch (e) {
      print("Error updating ledger item: $e");
      rethrow;
    }
  }

  Future<void> deleteLedgerItem(String customerID) async {
    try {
      await _firestore
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .doc(customerID)
        .delete();
    } catch (e) {
      print("Error deleting ledger item: $e");
      rethrow;
    }
  }

  Stream<double> totalDebtStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .where('payStatus', isNotEqualTo: 'Paid')
        .snapshots()
        .map((snapshot) {
          double totalDebt = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final credit = (data['credit'] ?? 0).toDouble();
            final partialPay = (data['partialPay'] ?? 0).toDouble();
            totalDebt += (credit - partialPay);
          }
          return totalDebt;
        });
    }

  Future<String> generateCustomerId() async {
    String year = DateFormat('yyyy').format(DateTime.now());

    final snapshot = await ledger
        .orderBy('customerID', descending: true)
        .limit(1)
        .get();

    int lastNumber = 0;

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>?; // cast to map
      final lastId = data?['customerID'] as String? ?? '';
      if (lastId.length > 4) {
        lastNumber = int.tryParse(lastId.substring(4)) ?? 0;
      }
    }

    int nextNumber = lastNumber + 1;
    String nextNumberStr = nextNumber.toString().padLeft(3, '0');

    return '$year$nextNumberStr';
  }


}

