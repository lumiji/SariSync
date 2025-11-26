import 'package:sarisync/models/receipt_item.dart';
import 'package:sarisync/services/ledger_service.dart';
import 'package:sarisync/services/receipt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> subtractStock(ReceiptItem item) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('inventory')
      .doc(item.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final currentQty = snapshot.get('quantity') as int? ?? 0;
      final newQty = (currentQty - item.quantity).clamp(0, currentQty);

      transaction.update(docRef, {'quantity': newQty});
    });
  }

  //for combining similar scanned items
  List<ReceiptItem> combineDuplicates(List<ReceiptItem> items) {
  final Map<String, ReceiptItem> combined = {};

  for (var item in items) {
    if (combined.containsKey(item.id)) {
      // Increase the quantity of the existing item
      combined[item.id]!.quantity += item.quantity;
    } else {
      // Add a copy of the item
      combined[item.id] = ReceiptItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
      );
    }
  }

  return combined.values.toList();
}


Future<void> processSale({
  required String transactionId,
  required List<ReceiptItem> items,
  required String paymentMethod,
  required String? name,
  required double totalAmount,
  required String receivedBy,
  required DateTime createdAt,
  //double? unit,
  //required String add_info,
  double? totalPaid, 
  double? change,    
  String? status,   
}) async {
  final ledgerService = LedgerService();
  final receiptService = ReceiptService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  String? customerID;

   for (var item in items) {
    await subtractStock(item);
  }


  // Credit payment handling
  if (paymentMethod == 'credit' && name != null && name.isNotEmpty) {
    final existingCustomer = await ledgerService.findCustomerByName(name);
    

    if (existingCustomer != null) {
      customerID = existingCustomer['customerID'];
      try{
      await ledgerService.addCustomerDebt(
        customerID: customerID!,
        name: name,
        credit: totalAmount,
        receivedBy: receivedBy,
      );
      print("EXISTING CUSTOMER: $existingCustomer");
      } catch (e) {
        print("error updating credit: $e");
      }
    } else {
      customerID = await ledgerService.createCustomer(
        name: name,
        initialCredit: totalAmount,
        receivedBy: receivedBy,
      );
    }
  }
  // Default totalPaid & change
  final paidAmount = totalPaid ?? totalAmount;
  final changeAmount = change ?? (paymentMethod == 'cash' ? paidAmount - totalAmount : 0.0);

  // Save receipt
  await receiptService.createReceipt(
    transactionId: transactionId,
    items: items,
    total: totalAmount,
    totalPaid: paidAmount,
    change: changeAmount,
    customerID: customerID,
    name: paymentMethod == 'credit' ? name : null,
    paymentMethod: paymentMethod,
    //status: paymentStatus, 
    status: 'credit',    //status: 'credit',
    createdAt: createdAt,
    
  );

  // update daily summary for cash sales
  if (paymentMethod == 'cash') {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month}-${now.day}';
    final dailyRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('dailySales')
      .doc(docId);

    await dailyRef.set({
      'totalSales': FieldValue.increment(totalAmount),
      'totalItemsSold': FieldValue.increment(
        items.fold<int>(0, (sum, item) => sum + (item.quantity)),
      ),
    }, SetOptions(merge: true));
  }

  
}
