// lib/services/pdf_generator.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PdfGenerator {
  static Future<void> generateFullReport(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final user = FirebaseAuth.instance.currentUser;
    if (uid == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signed-in user found.')),
      );
      return;
    }

    // fetch user display/store name (tries multiple common field names)
    String headerName = user.displayName ?? user.email ?? 'User';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        headerName = (data['storeName'] ?? data['displayName'] ?? data['ownerName'] ?? headerName).toString();
      }
    } catch (_) {}

    // Fetch collections: inventory, ledger, dailySales, History/transactions
    final invSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory')
        .orderBy('name', descending: false)
        .get();

    final ledgerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ledger')
        .get();

    final salesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailySales')
        .orderBy('date', descending: true)
        .get();

    final historySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('History')
        .orderBy('timestamp', descending: true)
        .get();

    // Prepare data lists
    final inventory = invSnapshot.docs.map((d) => d.data()).toList();
    final ledger = ledgerSnapshot.docs.map((d) => d.data()).toList();
    final dailySales = salesSnapshot.docs.map((d) => d.data()).toList();
    final transactions = historySnapshot.docs.map((d) => d.data()).toList();

    // Totals
    double totalInventoryValue = 0.0;
    int totalItemsCount = 0;
    for (var item in inventory) {
      final qty = (item['qty'] ?? item['quantity'] ?? 0);
      final price = (item['price'] ?? item['unitPrice'] ?? 0);
      // ensure numeric
      final q = _toDouble(qty);
      final p = _toDouble(price);
      totalItemsCount += q.round();
      totalInventoryValue += q * p;
    }

    double totalTransactionsAmount = 0.0;
    double totalReceived = 0.0;
    int totalTransactionsCount = transactions.length;
    for (var t in transactions) {
      totalTransactionsAmount += _toDouble(t['totalAmount'] ?? t['amount'] ?? 0);
      totalReceived += _toDouble(t['paid'] ?? t['received'] ?? 0);
    }

    // ledger totals (example: total debit = payments received)
    double totalDebit = 0.0;
    double outstandingPayments = 0.0;
    for (var l in ledger) {
      totalDebit += _toDouble(l['paymentReceived'] ?? l['credit'] ?? 0);
      outstandingPayments += _toDouble(l['balance'] ?? 0);
    }

    // Date range header (From DATE - Current DATE)
    final now = DateTime.now();
    final currentDateStr = DateFormat('yyyy-MM-dd').format(now);
    // Optionally compute earliest date from data; we'll use earliest transaction or inventory timestamp if present
    DateTime? earliest;
    for (var t in transactions) {
      final ts = t['timestamp'];
      if (ts is Timestamp) {
        final dt = ts.toDate();
        earliest = (earliest == null || dt.isBefore(earliest)) ? dt : earliest;
      } else if (t['date'] != null && t['date'] is String) {
        try {
          final dt = DateTime.parse(t['date']);
          earliest = (earliest == null || dt.isBefore(earliest)) ? dt : earliest;
        } catch (_) {}
      }
    }
    final fromDateStr = earliest == null ? 'Beginning' : DateFormat('yyyy-MM-dd').format(earliest);

    // Create PDF
    final pdf = pw.Document();

    // Common text styles
    final headerStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
    final tableHeaderStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final normal = pw.TextStyle(fontSize: 9);

    // Add a multi-page with sections (Inventory, Ledger, Transactions)
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          return [
            // Title/header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("$headerName's Store Data", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("From $fromDateStr - $currentDateStr", style: normal),
                  ],
                ),
                pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(now), style: normal),
              ],
            ),
            pw.SizedBox(height: 12),

            // INVENTORY Section
            pw.Text('INVENTORY', style: headerStyle),
            pw.SizedBox(height: 6),

            // Inventory table
            pw.Table.fromTextArray(
              headers: ['QTY', 'UOM', 'NAME', 'DESCRIPTION', 'CATEGORY', 'BCODE', 'PRICE', 'QTY SOLD', 'AMOUNT'],
              data: inventory.map((it) {
                final qty = _toDouble(it['qty'] ?? it['quantity'] ?? 0);
                final uom = (it['uom'] ?? '') .toString();
                final name = (it['name'] ?? '') .toString();
                final desc = (it['description'] ?? '') .toString();
                final cat = (it['category'] ?? '') .toString();
                final bcode = (it['barcode'] ?? it['bcode'] ?? '') .toString();
                final price = _toDouble(it['price'] ?? it['unitPrice'] ?? 0);
                final qtySold = _toDouble(it['qtySold'] ?? it['sold'] ?? 0);
                final amount = qty * price;
                return [
                  qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2),
                  uom,
                  name,
                  desc,
                  cat,
                  bcode,
                  _formatCurrency(price),
                  qtySold.toStringAsFixed(qtySold % 1 == 0 ? 0 : 2),
                  _formatCurrency(amount),
                ];
              }).toList(),
              headerStyle: tableHeaderStyle,
              cellStyle: normal,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(3),
                3: pw.FlexColumnWidth(3),
                4: pw.FlexColumnWidth(2),
                5: pw.FlexColumnWidth(2),
                6: pw.FlexColumnWidth(2),
                7: pw.FlexColumnWidth(1.5),
                8: pw.FlexColumnWidth(2),
              },
            ),

            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL ITEMS: $totalItemsCount', style: normal),
                pw.Text('TOTAL INVENTORY VALUE: ${_formatCurrency(totalInventoryValue)}', style: normal),
              ],
            ),

            pw.Divider(height: 18),

            // LEDGER Section
            pw.Text('LEDGER', style: headerStyle),
            pw.SizedBox(height: 6),

            pw.Table.fromTextArray(
              headers: ['NAME', 'CONTACT NO.', 'PAYMENT STATUS', 'CREDIT (UTANG)', 'PARTIAL PAYMENT', 'BALANCE', 'RECEIVED BY'],
              data: ledger.map((l) {
                return [
                  (l['name'] ?? '') .toString(),
                  (l['contact'] ?? l['phone'] ?? '') .toString(),
                  (l['paymentStatus'] ?? '') .toString(),
                  _formatCurrency(_toDouble(l['credit'] ?? l['utang'] ?? 0)),
                  _formatCurrency(_toDouble(l['partialPayment'] ?? l['partial'] ?? 0)),
                  _formatCurrency(_toDouble(l['balance'] ?? 0)),
                  (l['receivedBy'] ?? '') .toString(),
                ];
              }).toList(),
              headerStyle: tableHeaderStyle,
              cellStyle: normal,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            ),

            pw.SizedBox(height: 8),
            pw.Text('TOTAL DEBIT: ${_formatCurrency(totalDebit)}', style: normal),

            pw.Divider(height: 18),

            // OUTSTANDING PAYMENTS summary
            pw.Text("${headerName}'s Store Data", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('From $fromDateStr - $currentDateStr', style: normal),
            pw.SizedBox(height: 8),
            pw.Text('OUTSTANDING PAYMENTS: ${_formatCurrency(outstandingPayments)}', style: normal),

            pw.Divider(height: 18),

            // TRANSACTIONS / HISTORY
            pw.Text('TRANSACTIONS', style: headerStyle),
            pw.SizedBox(height: 6),

            // Transaction table headers similar to design
            pw.Table.fromTextArray(
              headers: ['TXN ID', 'PAYMENT METHOD', 'CUSTOMER NAME', 'ITEMS (NAME - QTY - PRICE)', 'TOTAL AMOUNT', 'TOTAL PAID', 'CHANGE/REC BY'],
              data: transactions.map((t) {
                final txnId = (t['txnId'] ?? t['id'] ?? '') .toString();
                final payMethod = (t['paymentMethod'] ?? t['method'] ?? '') .toString();
                final customer = (t['customerName'] ?? t['customer'] ?? '') .toString();
                final items = t['items'];
                String itemsStr = '';
                if (items is List) {
                  itemsStr = items.map((it) {
                    final n = (it['name'] ?? it['itemName'] ?? '') .toString();
                    final q = _toDouble(it['qty'] ?? it['quantity'] ?? 0);
                    final p = _toDouble(it['price'] ?? it['unitPrice'] ?? 0);
                    return '$n - ${q % 1 == 0 ? q.toInt() : q} - ${_formatCurrency(p)}';
                  }).join('\n');
                } else if (items is String) {
                  itemsStr = items;
                }
                final totalAmt = _toDouble(t['totalAmount'] ?? t['amount'] ?? 0);
                final paid = _toDouble(t['paid'] ?? t['received'] ?? 0);
                final changeRecBy = (t['changeRecBy'] ?? t['handledBy'] ?? '') .toString();

                return [
                  txnId,
                  payMethod,
                  customer,
                  itemsStr,
                  _formatCurrency(totalAmt),
                  _formatCurrency(paid),
                  changeRecBy,
                ];
              }).toList(),
              headerStyle: tableHeaderStyle,
              cellStyle: normal,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(4),
                4: pw.FlexColumnWidth(2),
                5: pw.FlexColumnWidth(2),
                6: pw.FlexColumnWidth(2),
              },
            ),

            pw.SizedBox(height: 8),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL TRANSACTIONS: $totalTransactionsCount', style: normal),
                  pw.Text('TOTAL AMOUNT: ${_formatCurrency(totalTransactionsAmount)}', style: normal),
                  pw.Text('TOTAL RECEIVED: ${_formatCurrency(totalReceived)}', style: normal),
                  pw.Text('OUTSTANDING: ${_formatCurrency(totalTransactionsAmount - totalReceived)}', style: normal),
                ]
            ),
          ];
        },
      ),
    );

    // Save PDF to local storage and prompt share/save
    final bytes = await pdf.save();
    final filename = 'SariSync_Report_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      // Show share/save dialog
      await Printing.sharePdf(bytes: bytes, filename: filename);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generated: $filename')),
      );
    } catch (e) {
      // fallback: directly open share dialog
      await Printing.sharePdf(bytes: bytes, filename: filename);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generated (shared): $filename')),
      );
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s.replaceAll(',', '')) ?? 0.0;
  }

  static String _formatCurrency(double v) {
    final nf = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    return nf.format(v);
  }
}
