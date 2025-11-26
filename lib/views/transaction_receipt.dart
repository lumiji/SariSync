import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sarisync/models/receipt_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionReceipt extends StatelessWidget {
  final String transactionId;
  final uid = FirebaseAuth.instance.currentUser!.uid;

  TransactionReceipt({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: const Text("Receipt"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('receipts')
            .doc(transactionId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docData = snapshot.data!.data();
          if (docData == null) {
            return const Center(child: Text("No receipt found"));
          }

          final data = docData as Map<String, dynamic>;
          final items = (data['items'] as List<dynamic>)
              .map((e) => ReceiptItem.fromJson(e))
              .toList();

          // final createdAt = data['createdAt'] != null
          //     ? (data['createdAt'] as Timestamp).toDate()
          //     : DateTime.now();
          final createdAt = data['dateTime'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now();


          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ITEM NAME + PRICE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "₱${item.price.toStringAsFixed(2)}",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        // DESCRIPTION 
                        if (item.description != null && item.description!.isNotEmpty)
                          Text(
                            item.description!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),

                        // UNIT OF MEASUREMENT + QUANTITY
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.weight != null && item.weight!.isNotEmpty
                                  ? "Unit: ${item.weight}"
                                  : "",
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
                            ),
                            Text(
                              "x ${item.quantity}",
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),


                const SizedBox(height: 15),

                // PAYMENT BREAKDOWN HEADER
                const Text(
                  "PAYMENT BREAKDOWN",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                const SizedBox(height: 12),

                // Payment method
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6), // <-- Radius adjustable
                          border: Border.all(color: Colors.black, width: 2),
                          color: data['paymentMethod'].toString().toLowerCase() == "cash"
                              ? Colors.blue.shade800  // filled when selected
                              : Colors.transparent,   // empty when not selected
                        ),
                        child: data['paymentMethod'].toString().toLowerCase() == "cash"
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("Cash", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 2),
                          color: data['paymentMethod'].toString().toLowerCase() == "credit"
                              ? Colors.blue.shade800
                              : Colors.transparent,
                        ),
                        child: data['paymentMethod'].toString().toLowerCase() == "credit"
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("Credit", style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 20),

                // PAYMENT VALUES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
                      ),
                    Text(
                      data['totalAmount'].toStringAsFixed(2),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Paid",
                      style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        data['totalPaid'].toStringAsFixed(2),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Change",
                       style: TextStyle(fontWeight: FontWeight.w100, fontSize: 15),
                      ),
                    Text(
                      data['change'].toStringAsFixed(2),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

               // FOOTER DETAILS
                const SizedBox(height: 20),

                // CUSTOMER NAME
                Row(
                  children: [
                    const Text(
                      "Customer: ",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Expanded(
                      child: Text(
                        data['name'] ?? "N/A",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                // CASHIER NAME
                Row(
                  children: const [
                    Text(
                      "Cashier: ",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Expanded(
                      child: Text(
                        "Lorena", // make dynamic later if needed
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                // TRANSACTION NUMBER — VALUE RIGHT ALIGN
                Row(
                  children: [
                    const Text(
                      "Transaction No.:",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    Expanded(child: Container()), // pushes value to the right
                    Text(
                      transactionId,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // DATE/TIME — VALUE RIGHT ALIGN
                Row(
                  children: [
                    const Text(
                      "Date/Time",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    Expanded(child: Container()), // pushes value to the right
                    Text(
                      "${createdAt.month}-${createdAt.day}-${createdAt.year} "
                      "${(createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12)}:"
                      "${createdAt.minute.toString().padLeft(2, '0')} "
                      "${createdAt.hour >= 12 ? 'PM' : 'AM'}",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // SariSync Logo Button at Bottom
                Padding(
                   padding: const EdgeInsets.only(top: 0.5),
                 child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); //Can be used later if want the Logo to use as button to download the Receipt.
                    },
                    child: SizedBox(
                      height: 160,
                      width: 160,
                      child: Image.asset(
                        'assets/images/Receipt Logo.png',
                        fit: BoxFit.contain,
                        ),
                    ),
                  ),
                ),
               // const SizedBox(height: 20),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
