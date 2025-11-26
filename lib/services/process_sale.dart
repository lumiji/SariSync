import 'package:sarisync/models/receipt_item.dart';
import 'package:sarisync/services/ledger_service.dart';
import 'package:sarisync/services/receipt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  String? customerID;

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
    status: paymentStatus,     //status: 'credit',
    createdAt: createdAt,
    
  );

  // update daily summary for cash sales
  if (paymentMethod == 'cash') {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month}-${now.day}';
    final dailyRef = FirebaseFirestore.instance.collection('dailySales').doc(docId);

    await dailyRef.set({
      'totalSales': FieldValue.increment(totalAmount),
      'totalItemsSold': FieldValue.increment(
        items.fold<int>(0, (sum, item) => sum + (item.quantity)),
      ),
    }, SetOptions(merge: true));
  }
}