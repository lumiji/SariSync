import 'package:flutter/material.dart';
import 'package:sarisync/services/ledger_service.dart';
import 'package:sarisync/services/receipt_service.dart';
import 'package:sarisync/models/receipt_item.dart';
import 'package:sarisync/services/process_sale.dart';
import 'package:sarisync/views/ledger.dart';
import 'package:sarisync/views/new_sales.dart';
import 'package:sarisync/views/home.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'package:sarisync/services/history_service.dart';
import 'package:sarisync/services/process_sale.dart';
import 'package:sarisync/services/receipt_service.dart';


//  Local message prompts for Receipt page only
// 🔔 Message Prompts UI copied from global version for Receipt page
class ReceiptMessagePrompts {
  static Future<void> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Text(message),
              actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  child: const Text("Confirm", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> success(BuildContext context, String message) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Text(message, textAlign: TextAlign.center),
            ),
          ),
        );
      },
    ).then((_) => Future.delayed(const Duration(milliseconds: 800), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }));
  }
}



class ReceiptPage extends StatefulWidget {
  final List<ReceiptItem> scannedItems;
  const ReceiptPage({super.key, required this.scannedItems});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
 
  String paymentMethod = 'cash';
  final TextEditingController totalPaidController = TextEditingController(text: '00.00');
  final TextEditingController nameController = TextEditingController(text: 'Customer Name');
  final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
  final now = DateTime.now();


  @override
  void dispose() {
    totalPaidController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void updateQuantity(String id, int delta) {
    setState(() {
      final index = widget.scannedItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        widget.scannedItems[index].quantity = (widget.scannedItems[index].quantity + delta).clamp(1, 999);
      }
    });
  }

  double get totalAmount {
    return widget.scannedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get totalPaid {
    return double.tryParse(totalPaidController.text) ?? 0.0;
  }

  double get change {
    return totalPaid - totalAmount;
  }

  int get totalItems {
    return widget.scannedItems.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              // Items List
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: widget.scannedItems.map((item) => _buildItemCard(item)).toList(),
                ),
              ),

              // Payment Breakdown
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PAYMENT BREAKDOWN',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Methods
                    _buildCheckbox(
                      'Cash', 
                      paymentMethod == 'cash', () {
                      setState(() => paymentMethod = 'cash'
                      );
                    }),
                    const SizedBox(height: 8),
                    _buildCheckbox(
                      'Credit', 
                      paymentMethod == 'credit', () {
                      setState(() => paymentMethod = 'credit'
                      );
                    }),
                    const SizedBox(height: 24),

                    // Item Count
                    Center(
                      child: Text(
                        '$totalItems Item(s)',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Totals
                    _buildTotalRow(
                      'Total Amount', 
                      totalAmount.toStringAsFixed(2), 
                      true
                    ),
                    const SizedBox(height: 12),
                    
                    // Conditional layout based on payment method
                    if (paymentMethod == 'credit')
                      _buildNameRow()
                    else ...[
                      _buildTotalPaidRow(),
                      const SizedBox(height: 12),
                      _buildTotalRow('Change', change.toStringAsFixed(2), true),
                    ],
                    
                    const SizedBox(height: 24),

                    // Transaction Info
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transaction No. :', style: TextStyle(fontSize: 16)),
                        Text(transactionId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date/Time', style: TextStyle(color: Colors.grey[600])),
                        Text('${now.month}-${now.day}-${now.year} ${now.hour}:${now.minute.toString().padLeft(2,'0')}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [

                    //DISCARD BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                        DialogHelper.confirmDelete(
                          context,
                          () {
                            DialogHelper.success(
                              context,
                              "Receipt has been successfully discarded.",
                              onOk: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage()),
                                );
                              },
                            );
                          },
                          title: "Discard Receipt?",
                          yesText: "Yes",
                          noText: "No",
                        );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Discard',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    //SAVE BUTTON
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final tid = transactionId; // Reference for Receipt ID

                          final itemsWithTimestamp = widget.scannedItems.map((item) => ReceiptItem(
                            id: item.id,
                            name: item.name,
                            price: item.price,
                            quantity: item.quantity,
                          )).toList();

                          // Calculate change (cash)
                          final paidAmount = paymentMethod == 'cash' ? totalPaid : 0.0;
                          final changeAmount = paymentMethod == 'cash' ? paidAmount - totalAmount : 0.0;
                          final status = paymentMethod == 'cash' ? 'paid' : 'credit';

                          // Call processSale
                          await processSale(
                            items: itemsWithTimestamp,
                            paymentMethod: paymentMethod,
                            name: paymentMethod == 'credit' ? nameController.text : null,
                            totalAmount: totalAmount,
                            totalPaid: paidAmount,
                            change: changeAmount,
                            status: status,
                            transactionId: transactionId, // 🔥 pass SAME ID
                            receivedBy: ' ', // ledger field
                            createdAt: now,
                          );

                          // Save to History  for CASH/CREDIT transactions
                          if (paymentMethod == 'cash') {
                            await HistoryService.recordSalesEvent(
                              totalAmount: totalAmount,
                              transactionId: transactionId,
                              );
                          } else if 
                          (paymentMethod == 'credit') {
                            await HistoryService.recordCreditEvent(
                              totalAmount: totalAmount,
                              customerName: nameController.text, 
                              transactionId: transactionId,
                            );
                          }

                          DialogHelper.success(
                            context,
                            "Transaction saved successfully.",
                            onOk: () {
                              if (paymentMethod == 'cash') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage()),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage(initialIndex: 2)),
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(ReceiptItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                item.price.toStringAsFixed(2),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => updateQuantity(item.id, -1),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => updateQuantity(item.id, 1),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Text(
                (item.price * item.quantity).toStringAsFixed(2),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, VoidCallback onChanged) {
    return GestureDetector(
      onTap: onChanged,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (_) => onChanged(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, bool bold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          amount,
          style: TextStyle(
            fontSize: bold ? 20 : 18,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPaidRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Paid', style: TextStyle(fontSize: 16)),
        SizedBox(
          width: 120,
          child: TextField(
            controller: totalPaidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Name:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: nameController,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
