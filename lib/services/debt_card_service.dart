import 'package:cloud_firestore/cloud_firestore.dart';

class DebtService {
    Future<double> getTotalDebtSummary() async {
    
    final snapshot = await FirebaseFirestore.instance
      .collection('ledger')
      .where('payStatus', isNotEqualTo: 'Paid')
      .get();

    double totalDebt = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final credit = (data['credit'] ?? 0).toDouble();
      final partialPay = (data['partialPay'] ?? 0).toDouble();

      totalDebt += (credit - partialPay);
    }

    return totalDebt;
  }
}