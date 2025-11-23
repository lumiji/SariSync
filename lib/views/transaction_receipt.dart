// // import 'package:flutter/material.dart';
// // import 'package:sarisync/services/ledger_service.dart';
// // import 'package:sarisync/services/receipt_service.dart';
// // import 'package:sarisync/models/receipt_item.dart';
// // import 'package:sarisync/services/process_sale.dart';
// // import 'package:sarisync/views/ledger.dart';
// // import 'package:sarisync/views/new_sales.dart';
// // import 'package:sarisync/views/home.dart';
// // import 'package:sarisync/widgets/message_prompts.dart';
// // import 'package:sarisync/services/history_service.dart';
// // import 'package:sarisync/services/process_sale.dart';
// // import 'package:sarisync/services/receipt_service.dart';
// // import 'package:sarisync/models/receipt_model.dart';
// // import 'package:intl/intl.dart';



// // class ReceiptMainPage extends StatelessWidget {
// //   final String receiptId;

// //   const ReceiptMainPage({super.key, required this.receiptId});

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder(
// //       future: ReceiptService().getReceiptById(receiptId),
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData) {
// //           return Scaffold(
// //             appBar: AppBar(title: Text("Viewing Receipt")),
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         final receipt = snapshot.data!;
// //         return ReceiptLayout(receipt: receipt);
// //       },
// //     );
// //   }
// // }

// // class ReceiptLayout extends StatelessWidget {
// //   final Receipt receipt;

// //   const ReceiptLayout({super.key, required this.receipt});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: const Text("Receipt"),
// //         centerTitle: true,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Text("SariSync Store",
// //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
// //             SizedBox(height: 4),
// //             Text(DateFormat("MMM dd | hh:mm a").format(receipt.createdAt)),
// //             SizedBox(height: 8),
// //             Text("Transaction ID: ${receipt.transactionId}",
// //                 style: TextStyle(fontSize: 12)),
// //             Divider(thickness: 1),

// //             // ITEMS LIST
// //             ListView.builder(
// //               shrinkWrap: true,
// //               physics: NeverScrollableScrollPhysics(),
// //               itemCount: receipt.items.length,
// //               itemBuilder: (_, i) {
// //                 final item = receipt.items[i];
// //                 return Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Expanded(child: Text("${item.name}  x${item.quantity}")),
// //                     Text("₱${(item.price * item.quantity).toStringAsFixed(2)}"),
// //                   ],
// //                 );
// //               },
// //             ),

// //             Divider(thickness: 1),

// //             // TOTALS
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text("Total Amount:",
// //                     style: TextStyle(fontWeight: FontWeight.bold)),
// //                 Text("₱${receipt.totalAmount.toStringAsFixed(2)}",
// //                     style: TextStyle(fontWeight: FontWeight.bold)),
// //               ],
// //             ),

// //             // CASH / CHANGE
// //             if (receipt.paymentMethod == 'cash') ...[
// //               SizedBox(height: 4),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text("Cash Tendered:"),
// //                   Text("₱${receipt.totalPaid.toStringAsFixed(2)}"),
// //                 ],
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text("Change:"),
// //                   Text("₱${receipt.change.toStringAsFixed(2)}"),
// //                 ],
// //               ),
// //             ],

// //             // CREDIT INFO
// //             if (receipt.paymentMethod == 'credit') ...[
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   const Text("Customer Name:"),
// //                   Text(receipt.name ?? "Unknown Customer"),
// //                 ],
// //               ),
// //             ],

// //             SizedBox(height: 10),

// //             Text(
// //               "Status: ${receipt.status.toUpperCase()}",
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: receipt.status == 'paid' ? Colors.green
// //                     : receipt.status == 'partial' ? Colors.orange
// //                     : Colors.red,
// //               ),
// //             ),

// //             SizedBox(height: 25),
// //             Text("Thank you for your purchase!",
// //                 style: TextStyle(fontSize: 12))
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:sarisync/models/receipt_model.dart';
// import 'package:sarisync/services/receipt_service.dart';
// import 'package:intl/intl.dart';

// class ReceiptMainPage extends StatefulWidget {
//   final String receiptId;
//   const ReceiptMainPage({super.key, required this.receiptId});

//   @override
//   State<ReceiptMainPage> createState() => _ReceiptMainPageState();
// }

// class _ReceiptMainPageState extends State<ReceiptMainPage> {
//   late Future<Receipt> receiptFuture;

//   @override
//   void initState() {
//     super.initState();
//     receiptFuture = ReceiptService().getReceiptById(widget.receiptId); // load once
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: receiptFuture,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Scaffold(
//             appBar: AppBar(title: const Text("Viewing Receipt")),
//             body: const Center(child: CircularProgressIndicator()),
//           );
//         }

//         final receipt = snapshot.data!;
//         return ReceiptLayout(receipt: receipt);
//       },
//     );
//   }
// }

// class ReceiptLayout extends StatelessWidget {
//   final Receipt receipt;
//   const ReceiptLayout({super.key, required this.receipt});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Receipt"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text("SariSync Store",
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(DateFormat("MMM dd | hh:mm a").format(receipt.createdAt)),
//             const SizedBox(height: 8),
//             Text("Transaction ID: ${receipt.transactionId}",
//                 style: const TextStyle(fontSize: 12)),
//             const Divider(thickness: 1),

//             // ITEMS LIST
//             Column(
//               children: receipt.items.map((item) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(child: Text("${item.name}  x${item.quantity}")),
//                     Text("₱${(item.price * item.quantity).toStringAsFixed(2)}"),
//                   ],
//                 );
//               }).toList(),
//             ),

//             const Divider(thickness: 1),

//             // TOTAL
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Total Amount:",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text("₱${receipt.totalAmount.toStringAsFixed(2)}",
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),

//             // CASH DETAILS
//             if (receipt.paymentMethod == 'cash') ...[
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Cash Tendered:"),
//                   Text("₱${receipt.totalPaid.toStringAsFixed(2)}"),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Change:"),
//                   Text("₱${receipt.change.toStringAsFixed(2)}"),
//                 ],
//               ),
//             ],

//             // CREDIT DETAILS
//             if (receipt.paymentMethod == 'credit') ...[
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Customer Name:"),
//                   Text(receipt.name ?? "Unknown Customer"),
//                 ],
//               ),
//             ],

//             const SizedBox(height: 12),

//             Text(
//               "Status: ${receipt.status.toUpperCase()}",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: receipt.status == 'paid'
//                     ? Colors.green
//                     : receipt.status == 'partial'
//                         ? Colors.orange
//                         : Colors.red,
//               ),
//             ),

//             const SizedBox(height: 25),
//             const Text("Thank you for your purchase!",
//                 style: TextStyle(fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }
// }
