// pdf_generator.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PdfGenerator {
  final FirebaseFirestore firestore;
  final String userId;

  PdfGenerator({required this.firestore, required this.userId});

  // Header/first column color (same as your header)
  final PdfColor _headerColor = PdfColor.fromInt(0xffd3e3ff);

  Future<void> generateAndDownloadPDF() async {
    final pdf = pw.Document();

    // ----------------------- Fetch data -----------------------
    // Inventory
    final inventorySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('inventory')
        .get();
    final inventoryData = inventorySnapshot.docs.map((d) => d.data()).toList();

    // Ledger
    final ledgerSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('ledger')
        .get();
    final ledgerData = ledgerSnapshot.docs.map((d) => d.data()).toList();

    // Receipts (transactions)
    final receiptSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('receipts')
        .get();
    final transactionData = receiptSnapshot.docs.map((d) => d.data()).toList();

    // Load logo from assets (fallback: if fails, we'll skip image)
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/Receipt Logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // ignore, logoImage stays null
      logoImage = null;
    }

    // Display name fallback
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName ?? 'User';

    // Compute fromDate by earliest createdAt in inventory or earliest dateTime in receipts
    DateTime? firstDate;
    for (var item in inventoryData) {
      final ts = item['createdAt'];
      if (ts != null) {
        try {
          final dt = (ts as Timestamp).toDate();
          if (firstDate == null || dt.isBefore(firstDate)) firstDate = dt;
        } catch (_) {}
      }
    }
    for (var r in transactionData) {
      final ts = r['dateTime'];
      if (ts != null) {
        try {
          final dt = (ts as Timestamp).toDate();
          if (firstDate == null || dt.isBefore(firstDate)) firstDate = dt;
        } catch (_) {}
      }
    }

    final now = DateTime.now();
    final fromDate = firstDate != null
        ? "${_two(firstDate.month)}/${_two(firstDate.day)}/${firstDate.year}"
        : "START";
    final toDate = "${_two(now.month)}/${_two(now.day)}/${now.year}";

    // ----------------------- Helper widgets & functions -----------------------
    pw.Widget headerCell(String text) => pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(text,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        );

    pw.Widget cell(String text, [bool isHeader = false]) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(4),
        color: isHeader ? PdfColor.fromInt(0xffd3e3ff) : PdfColors.white,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    pw.Widget firstCol(String text) => pw.Container(
          color: _headerColor,
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        );

    String formatCurrency(dynamic value) {
      double v = 0.0;
      if (value == null) return "PHP 0.00";
      try {
        v = (value is num) ? value.toDouble() : double.parse(value.toString());
      } catch (_) {
        v = 0.0;
      }
      return "PHP ${v.toStringAsFixed(2)}";
    }

    // ----------------------- INVENTORY PAGE -----------------------
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) {
          return pw.Column(children: [
            pw.SizedBox(height: 6),
            if (logoImage != null) pw.Center(child: pw.Image(logoImage, width: 120)),
            pw.SizedBox(height: 6),
            pw.Center(
                child: pw.Text("$displayName's Store Data",
                    style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 2),
            pw.Center(child: pw.Text("$fromDate - $toDate", style: const pw.TextStyle(fontSize: 10))),
            pw.SizedBox(height: 10), //8
          ]);
        },
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text("Page ${context.pageNumber} / ${context.pagesCount}", style: const pw.TextStyle(fontSize: 8)),
          );
        },
        build: (context) {
          // Build Inventory table rows
          final invRows = <pw.TableRow>[];

          invRows.add(pw.TableRow(
            decoration: pw.BoxDecoration(color: _headerColor),
            children: [
              headerCell("QTY"),
              headerCell("UOM"),
              headerCell("NAME"),
              headerCell("DESCRIPTION"),
              headerCell("CATEGORY"),
              headerCell("BCODE"),
              headerCell("PRICE"),
              headerCell("QTY SOLD"),
              headerCell("AMOUNT"),
            ],
          ));

          double totalInventoryValue = 0;
          int totalItems = 0;

          for (var item in inventoryData) {
            final qty = int.tryParse(item['quantity']?.toString() ?? "0") ?? 0;
            final price = double.tryParse(item['price']?.toString() ?? "0") ?? 0.0;
            final amount = qty * price;
            totalItems += qty;
            totalInventoryValue += amount;

            invRows.add(pw.TableRow(children: [
              // first column colored
              pw.Container(color: _headerColor, padding: const pw.EdgeInsets.all(4), child: pw.Text("$qty", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              cell(item['unit']?.toString() ?? ""),
              cell(item['name']?.toString() ?? ""),
              cell(item['add_info']?.toString() ?? ""),
              cell(item['category']?.toString() ?? ""),
              cell(item['barcode']?.toString() ?? ""),
              cell("PHP ${price.toStringAsFixed(2)}"),
              cell(item['sold']?.toString() ?? item['quantity']?.toString() ?? ""),
              cell("PHP ${amount.toStringAsFixed(2)}"),
            ]));
          }

          return [
            pw.Text("INVENTORY", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Table(border: pw.TableBorder.all(), children: invRows),
            pw.SizedBox(height: 12),
            pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(right: 15),
                alignment: pw.Alignment.centerRight,
                child: pw.Text("TOTAL ITEMS: $totalItems", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(right: 15, top: 4),
                alignment: pw.Alignment.centerRight,
                child: pw.Text("TOTAL INVENTORY VALUE: PHP ${totalInventoryValue.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 8),
          ];
        },
      ),
    );


    
// ----------------------- LEDGER PAGE -----------------------
pdf.addPage(pw.MultiPage(
  pageFormat: PdfPageFormat.a4,
  header: (context) {
    return pw.Column(children: [
      pw.SizedBox(height: 6),
      if (logoImage != null) pw.Center(child: pw.Image(logoImage, width: 120)),
      pw.SizedBox(height: 6),
      pw.Center(
          child: pw.Text("$displayName's Store Data",
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold))),
      pw.SizedBox(height: 2),
      pw.Center(child: pw.Text("$fromDate - $toDate", style: const pw.TextStyle(fontSize: 10))),
      pw.SizedBox(height: 10),
    ]);
  },
  footer: (context) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text("Page ${context.pageNumber} / ${context.pagesCount}",
          style: const pw.TextStyle(fontSize: 8))),
  build: (context) {
    // ledger header + rows
    final ledgerRows = <pw.TableRow>[];
    ledgerRows.add(pw.TableRow(
      decoration: pw.BoxDecoration(color: _headerColor),
      children: [
        headerCell("NAME"),
        headerCell("CONTACT NO."),
        headerCell("PAYMENT STATUS"),
        headerCell("CREDIT (UTANG)"),
        headerCell("PARTIAL PAYMENT"),
        headerCell("BALANCE"),
        headerCell("RECEIVED BY"),
      ],
    ));

    double totalDebit = 0.0;
    double totalOutstanding = 0.0; // NEW: sum of unpaid balances

    for (var item in ledgerData) {
      final credit = double.tryParse(item['credit']?.toString() ?? "0") ?? 0.0;
      final partial = double.tryParse(item['partialPay']?.toString() ?? "0") ?? 0.0;
      final balance = credit - partial;

      totalDebit += partial;
      totalOutstanding += balance; // accumulate outstanding

      ledgerRows.add(pw.TableRow(children: [
        // first col colored
        pw.Container(
            color: _headerColor,
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(item['name']?.toString() ?? "",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        cell(item['contact']?.toString() ?? ""),
        cell(item['payStatus']?.toString() ?? ""),
        cell(formatCurrency(credit)),
        cell(formatCurrency(partial)),
        cell(formatCurrency(balance)),
        cell(item['received']?.toString() ?? item['receivedBy']?.toString() ?? ""),
      ]));
    }

    return [
      pw.Text("LEDGER", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      pw.Table(
          border: pw.TableBorder.all(),
          defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(1.4),
            5: const pw.FlexColumnWidth(1.8),
            6: const pw.FlexColumnWidth(2),
          },
          children: ledgerRows),
      pw.SizedBox(height: 12),

      // TOTAL DEBIT
      pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(right: 15),
          alignment: pw.Alignment.centerRight,
          child: pw.Text("TOTAL DEBIT (PAYMENTS RECEIVED): ${formatCurrency(totalDebit)}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),

      pw.SizedBox(height: 4),

      // OUTSTANDING PAYMENTS
      pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(right: 15),
          alignment: pw.Alignment.centerRight,
          child: pw.Text("OUTSTANDING PAYMENTS: ${formatCurrency(totalOutstanding)}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black))),
      pw.SizedBox(height: 8),
    ];
  },
));

    // ===== COMPUTE SUMMARY VALUES =====
final int totalTransactions = transactionData.length;

final double totalAmount = transactionData.fold(0.0, (sum, item) {
  final price = double.tryParse(item["totalAmount"].toString()) ?? 0.0;
  return sum + price;
});

final double totalReceived = transactionData.fold(0.0, (sum, item) {
  final paid = double.tryParse(item["totalPaid"].toString()) ?? 0.0;
  return sum + paid;
});

final double totalOutstanding = totalAmount - totalReceived;


// =============== TRANSACTIONS PAGE ===============
pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    header: (context) => pw.Column(children: [
      pw.SizedBox(height: 6),
      if (logoImage != null) pw.Center(child: pw.Image(logoImage, width: 120)),
      pw.SizedBox(height: 6),
      pw.Center(
          child: pw.Text("$displayName's Store Data",
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold))),
      pw.SizedBox(height: 2),
      pw.Center(child: pw.Text("$fromDate - $toDate", style: const pw.TextStyle(fontSize: 10))),

      pw.SizedBox(height: 10),
    ]),
    footer: (context) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text("Page ${context.pageNumber} / ${context.pagesCount}",
          style: const pw.TextStyle(fontSize: 8)),
    ),
    build: (context) => [
      pw.SizedBox(height: 10),
      pw.Text(
        "TRANSACTIONS",
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      // ===== TABLE =====
      pw.Table(
        border: pw.TableBorder.all(),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(2.5),
          4: const pw.FlexColumnWidth(4),
          5: const pw.FlexColumnWidth(2),
          6: const pw.FlexColumnWidth(2),
          7: const pw.FlexColumnWidth(2),
        },
        children: [
          // header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xffd3e3ff)),
            children: [
              cell("TXN ID", true),
              cell("DATE", true),
              cell("METHOD", true),
              cell("CUSTOMER", true),
              cell("ITEMS (NAME × QTY × PRICE)", true),
              cell("TOTAL", true),
              cell("PAID", true),
              cell("CHANGE", true),
            ],
          ),
          ...transactionData.map((item) {
            final ts = item["dateTime"];
            final date = ts is Timestamp
                ? ts.toDate()
                : DateTime.tryParse(ts.toString()) ?? DateTime.now();
            final formattedDate = "${date.month}/${date.day}/${date.year}";
            final rawItems = item['items'] as List<dynamic>? ?? [];
            final itemsList = rawItems.map((it) {
              final n = it['name'] ?? "";
              final q = it['quantity'] ?? "";
              final p = double.tryParse(it['price']?.toString() ?? "0") ?? 0;
              return "$n × $q @ PHP ${p.toStringAsFixed(2)}";
            }).toList();

            return pw.TableRow(
              children: [
                pw.Container(
                  decoration: pw.BoxDecoration(color: _headerColor),
                  padding: const pw.EdgeInsets.all(4),
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    item["transactionId"] ?? "",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                  ),
                ),
                cell(formattedDate),
                cell(item["paymentMethod"] ?? ""),
                cell(item["name"]?.toString() ?? "-"),
                cell(itemsList.join("\n")),
                cell("PHP ${(double.tryParse(item["totalAmount"].toString()) ?? 0).toStringAsFixed(2)}"),
                cell("PHP ${(double.tryParse(item["totalPaid"].toString()) ?? 0).toStringAsFixed(2)}"),
                cell("PHP ${(double.tryParse(item["change"].toString()) ?? 0).toStringAsFixed(2)}"),
              ],
            );
          }),
        ],
      ),
      pw.SizedBox(height: 18),
      // ===== SUMMARY =====
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.only(right: 15),
        alignment: pw.Alignment.centerRight,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "TOTAL TRANSACTIONS: $totalTransactions",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "TOTAL AMOUNT: PHP ${totalAmount.toStringAsFixed(2)}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "TOTAL RECEIVED: PHP ${totalReceived.toStringAsFixed(2)}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              "OUTSTANDING: PHP ${totalOutstanding.toStringAsFixed(2)}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  ),
);

    // ----------------------- SAVE & OPEN -----------------------
    final downloadsDir = await getDownloadsDirectory();
    final filePath = "${downloadsDir!.path}/SariSync_Report_${now.toIso8601String().split('T')[0]}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    print("PDF saved at: $filePath");

    // Open file (if platform supports)
    try {
      OpenFile.open(filePath);
    } catch (_) {}
  }

  // small helper: zero-pad month/day
  static String _two(int n) => n < 10 ? "0$n" : "$n";
}
