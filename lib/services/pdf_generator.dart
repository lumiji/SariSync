import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';

class PdfGenerator {
  final FirebaseFirestore firestore;
  final String userId;

  PdfGenerator({required this.firestore, required this.userId});

  Future<void> generateAndDownloadPDF() async {
    final pdf = pw.Document();

    // Fetch Inventory
    final inventorySnapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("inventory")
        .get();

    final inventoryData = inventorySnapshot.docs.map((doc) => doc.data()).toList();

    // Fetch Ledger
    final ledgerSnapshot = await firestore
    .collection("users")
    .doc(userId)
    .collection("ledger")
    .get();

    final ledgerData = ledgerSnapshot.docs.map((doc) => doc.data()).toList();

    // Fetch Transaction
    // final transactionSnapshot = await firestore
    // .collection("users")
    // .doc(userId)
    // .collection("ledger")
    // .get();

    // final transactionData = ledgerSnapshot.docs.map((doc) => doc.data()).toList();



    // Load logo
    final logoBytes = await rootBundle.load('assets/images/Receipt Logo.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Get display name
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName ?? "User";

    // Header dates - Determine earliest start date from items
    DateTime? firstDate;

    for (var item in inventoryData) {
  final ts = item["createdAt"];
  if (ts != null) {
    final dt = (ts as Timestamp).toDate();
    if (firstDate == null || dt.isBefore(firstDate!)) {
      firstDate = dt;
    }
  }
}
    // Header dates
    final now = DateTime.now();
    // Use formatted START date if exists, else text START
    final fromDate = firstDate != null
        ? "${firstDate!.month}/${firstDate!.day}/${firstDate!.year}"
        : "START";
    final toDate = "${now.month}/${now.day}/${now.year}";


    //  ===================== INVENTORY SECTION =====================

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Image(logo, width: 160), // logo centered
                  pw.SizedBox(height: 12),
                  pw.Text(
                    "$displayName's Store Data",
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "$fromDate - $toDate",
                    style: pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 22),
                ],
              ),
            ),

            pw.Text("INVENTORY", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xffd3e3ff)),
                  children: [
                    cell("QTY", true),
                    cell("UOM", true),
                    cell("NAME", true),
                    cell("DESCRIPTION", true),
                    cell("CATEGORY", true),
                    cell("BCODE", true),
                    cell("PRICE", true),
                    cell("QTY SOLD", true),
                    cell("AMOUNT", true),
                  ],
                ),

                ...inventoryData.map((item) {
                  final qty = int.tryParse(item["quantity"].toString()) ?? 0;
                  final price = double.tryParse(item["price"].toString()) ?? 0.0;
                  final amount = qty * price;

                  return pw.TableRow(
                    children: [
                      cell("$qty"),
                      cell(item["unit"] ?? ""),
                      cell(item["name"] ?? ""),
                      cell(item["add_info"] ?? ""),
                      cell(item["category"] ?? ""),
                      cell(item["barcode"] ?? ""),
                      cell("PHP ${price.toStringAsFixed(2)}"),
                      cell(item["quantity"]?.toString() ?? ""),
                      cell("PHP ${amount.toStringAsFixed(2)}"),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            // TOTAL ITEMS
            pw.Container(
              width: double.infinity,              // full page width
              padding: pw.EdgeInsets.only(right: 20), // adjust this number to control how far from right
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "TOTAL ITEMS: ${inventoryData.fold(0, (sum, item) => sum + (int.tryParse(item["quantity"].toString()) ?? 0))}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),

            // TOTAL INVENTORY VALUE
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.only(right: 20), // same padding para pareho alignment
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "TOTAL INVENTORY VALUE: PHP ${inventoryData.fold(0.0, (sum, item) {
                  final qty = int.tryParse(item["quantity"].toString()) ?? 0;
                  final price = double.tryParse(item["price"].toString()) ?? 0.0;
                  return sum + (qty * price);
                }).toStringAsFixed(2)}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),


          ];
        },
      ),
    );

    // ===================== LEDGER SECTION =====================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 10),
            pw.Text("LEDGER", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),  // NAME
                1: const pw.FlexColumnWidth(2),  // CONTACT NO.
                2: const pw.FlexColumnWidth(2),  // PAYMENT STATUS
                3: const pw.FlexColumnWidth(2),  // CREDIT (UTANG)
                4: const pw.FlexColumnWidth(2), // PARTIAL PAYMENT (slightly smaller)
                5: const pw.FlexColumnWidth(2), // BALANCE (more space)
                6: const pw.FlexColumnWidth(2),  // RECEIVED BY
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xffd3e3ff)),
                  children: [
                    cell("NAME", true),
                    cell("CONTACT NO.", true),
                    cell("PAYMENT STATUS", true),
                    cell("CREDIT (UTANG)", true),
                    cell("PARTIAL PAYMENT", true),
                    cell("BALANCE", true),
                    cell("RECEIVED BY", true),
                  ],
                ),

                ...ledgerData.map((item) {
                  final credit = double.tryParse(item["credit"].toString()) ?? 0.0;
                  final partial = double.tryParse(item["partialPay"].toString()) ?? 0.0;
                  final balance = credit - partial;

                  return pw.TableRow(
                    children: [
                      cell(item["name"] ?? ""),
                      cell(item["contact"] ?? ""),
                      cell(item["payStatus"] ?? ""),
                      cell("PHP ${credit.toStringAsFixed(2)}"),
                      cell("PHP ${partial.toStringAsFixed(2)}"),
                      cell("PHP ${balance.toStringAsFixed(2)}"),
                      cell(item["received"] ?? ""),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 14),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "TOTAL DEBIT: PHP ${ledgerData.fold(0.0, (sum, item) {
                  final partial = double.tryParse(item["partialPay"].toString()) ?? 0.0;
                  return sum + partial;
                }).toStringAsFixed(2)}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ); //End of LEDGER Page

    // ===================== TRANSACTIONS SECTION =====================
    // pdf.addPage(
    //   pw.Page(
    //     pageFormat: PdfPageFormat.a4,
    //     build: (context) => pw.Column(
    //       crossAxisAlignment: pw.CrossAxisAlignment.start,
    //       children: [
    //         pw.SizedBox(height: 10),
    //         pw.Text("TRANSACTIONS", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
    //         pw.SizedBox(height: 8),

    //         pw.Table(
    //           border: pw.TableBorder.all(),
    //           columnWidths: {
    //             0: const pw.FlexColumnWidth(2), // DATE
    //             1: const pw.FlexColumnWidth(3), // TRANSACTION ID
    //             2: const pw.FlexColumnWidth(2), // PAYMENT METHOD
    //             3: const pw.FlexColumnWidth(2), // TOTAL AMOUNT
    //           },
    //           children: [
    //             pw.TableRow(
    //               decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xffd3e3ff)),
    //               children: [
    //                 cell("DATE", true),
    //                 cell("TRANSACTION ID", true),
    //                 cell("METHOD", true),
    //                 cell("AMOUNT", true),
    //               ],
    //             ),

    //             ...transactionData.map((item) {
    //               final ts = item["createdAt"];
    //               final date =
    //                   ts is Timestamp ? ts.toDate() : DateTime.tryParse(ts.toString()) ?? DateTime.now();
    //               final formattedDate = "${date.month}/${date.day}/${date.year}";

    //               final amount = double.tryParse(item["totalAmount"].toString()) ?? 0.0;

    //               return pw.TableRow(
    //                 children: [
    //                   // First column header color
    //                   pw.Container(
    //                     color: PdfColor.fromInt(0xffd3e3ff),
    //                     padding: const pw.EdgeInsets.all(4),
    //                     child: pw.Text(
    //                       formattedDate,
    //                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    //                     ),
    //                   ),
    //                   cell(item["transactionId"] ?? ""),
    //                   cell(item["paymentMethod"] ?? ""),
    //                   cell("PHP ${amount.toStringAsFixed(2)}"),
    //                 ],
    //               );
    //             }),
    //           ],
    //         ),

    //         pw.SizedBox(height: 14),

    //         pw.Align(
    //           alignment: pw.Alignment.centerRight,
    //           child: pw.Text(
    //             "TOTAL SALES: PHP ${transactionData.fold(0.0, (sum, item) {
    //               final price = double.tryParse(item["totalAmount"].toString()) ?? 0.0;
    //               return sum + price;
    //             }).toStringAsFixed(2)}",
    //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );


    // --- SAVE TO DOWNLOADS FOLDER ---
    Directory? downloadsDir = await getDownloadsDirectory();
    final file = File("${downloadsDir!.path}/SariSync_Inventory.pdf");
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: ${file.path}");

    // --- OPEN FILE AFTER SAVING ---
    OpenFile.open(file.path);
  }

  pw.Widget cell(String text, [bool header = false]) {
    return pw.Container(
      padding: pw.EdgeInsets.all(4),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}