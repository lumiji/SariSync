import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sarisync/models/receipt_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sarisync/services/user_display_service.dart';
// import 'package:sarisync/utilities/save_receipt_png.dart';
// import 'package:sarisync/widgets/message_prompts.dart';

class TransactionReceipt extends StatelessWidget {
  final String transactionId;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final displayName = UserDisplay.getDisplayName();


  TransactionReceipt({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: const Text(
          "Receipt",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.w700)
          ),

          // actions: [
          //   IconButton(
          //     onPressed: () async {
          //       final path = await saveReceiptAsImage(
          //         receiptKey, 
          //         fileName: "receipt_${DateTime.now().millisecondsSinceEpoch}");

          //       if (path != null) {
          //         DialogHelper.success(
          //           context, 
          //           "Receipt saved successfully!");
          //        } else {
          //         DialogHelper.warning(context, "Failed to save receipt.");
          //       }
          //     },
          //     icon: const Icon(
          //       Icons.file_download_outlined,
          //       size: 24,
          //       color: Colors.white,
          //     ),
          //   ),
          // ],
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
            return const Center(
              child: 
              Text(
                "No receipt found",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  ),
              ));
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
            padding: const EdgeInsets.symmetric(
              horizontal: 25, 
              vertical: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ITEM NAME + PRICE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "₱${item.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          // DESCRIPTION 
                          if (item.add_info != null && item.add_info!.isNotEmpty)
                            Text(
                              item.add_info!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),

                          // UNIT OF MEASUREMENT + QUANTITY
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.unit != null && item.unit!.isNotEmpty
                                    ? "${item.unit}"
                                    : "",
                                style: TextStyle( fontFamily: 'Inter',fontSize: 13, color: Colors.black45),
                              ),
                              Text(
                                "x ${item.quantity}",
                                style: TextStyle( fontFamily: 'Inter',fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  


                const SizedBox(height: 15),

                // PAYMENT BREAKDOWN HEADER
                const Text(
                  "PAYMENT BREAKDOWN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                // Payment method
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:Color(0xFF1565C0), 
                            width: 2,
                          ),
                          color: data['paymentMethod'].toString().toLowerCase() == "cash"
                              ? Color(0xFF1565C0) 
                              : Colors.transparent, 
                        ),
                        child: data['paymentMethod'].toString().toLowerCase() == "cash"
                            ? const Icon(
                                Icons.check_rounded, 
                                size: 16, 
                                color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Cash", 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color(0xFF212121),
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color(0xFF1565C0),
                            width: 2),
                          color: data['paymentMethod'].toString().toLowerCase() == "credit"
                              ? Color(0xFF1565C0)
                              : Colors.transparent,
                        ),
                        child: data['paymentMethod'].toString().toLowerCase() == "credit"
                            ? const Icon(
                                Icons.check_rounded,
                                 size: 16, 
                                 color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Credit", 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          color: Color(0xFF212121),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // PAYMENT VALUES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize:  16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      data['totalAmount'].toStringAsFixed(2),
                      style: TextStyle( fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        fontSize: 16,
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
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        fontSize: 16,
                        fontFamily: 'Inter',
                        ),
                      ),
                    Text(
                        data['totalPaid'].toStringAsFixed(2),
                        style: TextStyle( fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF212121),
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
                       style: TextStyle(
                        fontWeight: FontWeight.w400, 
                        fontSize: 16),
                      ),
                    Text(
                      data['change'].toStringAsFixed(2),
                      style: TextStyle( fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color:Color(0xFF212121),
                        ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

               // FOOTER DETAILS
                const SizedBox(height: 20),

                // CUSTOMER NAME
                Row(
                  children: [
                    const Text(
                      "Customer: ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        fontSize: 16,
                        fontFamily: 'Inter',
                        ),
                    ),
                    Expanded(
                      child: Text(
                        data['name'] ?? "N/A",
                        style: TextStyle( fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                  ],
                ),

                // CASHIER NAME
                Row(
                  children: [
                    Text(
                      "Cashier: ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        fontSize: 16,
                        fontFamily: 'Inter',
                        ),
                    ),
                    Expanded(
                      child: Text(
                        displayName,
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
                      style: TextStyle( fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),

                // DATE/TIME — VALUE RIGHT ALIGN
                Row(
                  children: [
                    const Text(
                      "Date/Time",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal, 
                        fontSize: 14),
                    ),
                    Expanded(child: Container()), 
                    Text(
                      "${createdAt.month}-${createdAt.day}-${createdAt.year} "
                      "${(createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12)}:"
                      "${createdAt.minute.toString().padLeft(2, '0')} "
                      "${createdAt.hour >= 12 ? 'PM' : 'AM'}",
                      style: TextStyle( fontFamily: 'Inter',
                        fontSize: 15,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // SariSync Logo Button at Bottom
                Padding(
                   padding: const EdgeInsets.only(
                    top: 0.5),
                 child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); 
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
      ));
    
  }
}