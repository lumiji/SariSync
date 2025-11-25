// This is the "ADD" form for the ledger page

//flutter dependencies
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';

//models, widgets & services
import '../services/ledger_service.dart';
import 'package:sarisync/widgets/inv_add-label.dart';
import 'package:sarisync/models/ledger_item.dart';
import 'package:sarisync/services/history_service.dart';
import 'package:sarisync/widgets/image_helper.dart';
import 'package:sarisync/widgets/message_prompts.dart';


class LedgerAddPage extends StatefulWidget {
  final LedgerItem? item;

  const LedgerAddPage({Key? key, this.item}) : super(key: key);

  @override
  State<LedgerAddPage> createState() => _LedgerAddPageState();
}

class _LedgerAddPageState extends State<LedgerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _ledgerService = LedgerService();

 // for picking image
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedImage =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    print('Picked image: ${pickedImage.path}');
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedImage =
                      await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    print('Picked image: ${pickedImage.path}');
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Controllers
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _creditController = TextEditingController();
  final _partialController = TextEditingController();
  final _receivedByController = TextEditingController();

  // State
  File? _selectedImage;
  String? imageUrl;
  String _paymentStatus = 'Unpaid';
 
  
  @override
  void initState() {
    super.initState();

    if (widget.item != null) {
      final item = widget.item!;
      _nameController.text = item.name;
      _contactController.text = item.contact.toString();
      _paymentStatus = item.payStatus;
      _creditController.text = item.credit.toString();
      _partialController.text = '';
      _receivedByController.text = item.received;



      // load image preview if existing
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
        imageUrl = item.imageUrl;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ImageHelper.prefetchImages(
            context: context,
            urls: [item.imageUrl!],
          );
        });
      }
    }
  }

  
  Future<void> addPartialPayment(LedgerItem item, double amountPaid) async {
    final newPartial = (item.partialPay ?? 0) + amountPaid;

    await _ledgerService.updateLedgerItem(item.id!, {
      'partialPay': newPartial,
      'updatedAt': FieldValue.serverTimestamp(),
      'payStatus': newPartial >= item.credit ? 'Paid' : 'Partial',
    });
  }


  // Save ledger item
  void _saveLedger() async {
    if (!_formKey.currentState!.validate()) return;

    final credit = double.tryParse(_creditController.text) ?? 0.0;
    final partial = _paymentStatus == 'Partial'
        ? double.tryParse(_partialController.text) ?? 0.0
        : 0.0;

    DialogHelper.showLoading(context,message: "Saving item. Please wait.");

    try {
      if (widget.item == null) {
        // ADD NEW CUSTOMER

        final customerID = await _ledgerService.generateCustomerId();

        await _ledgerService.addLedgerItem(
          name: _nameController.text.trim(),
          customerID: customerID,
          contact: _contactController.text.trim(),
          payStatus: _paymentStatus,
          credit: credit,
          partialPay: partial,
          received: _receivedByController.text.trim(),
          imageFile: _selectedImage,
        );

        if (!mounted) return;
        Navigator.pop(context, "added");
      } else {
        // UPDATE EXISTING CUSTOMER
        final docId = widget.item!.id;
        final enteredPartial = double.tryParse(_partialController.text) ?? 0.0;
        double newPartial = (widget.item!.partialPay ?? 0) + enteredPartial;
        final updatedCredit = credit;

        double remaining = (updatedCredit - newPartial).clamp(0.0, updatedCredit);
        
        String updatedStatus = _paymentStatus;

        if (_paymentStatus == 'Paid') {
          updatedStatus = 'Paid';
          newPartial = credit;
          remaining = 0.0;
        } else if (_paymentStatus == 'Partial') {
          updatedStatus = 'Partial';
        } else {
          updatedStatus = 'Unpaid';
          newPartial = 0.0;
          remaining = updatedCredit;
        }

        final data = {
          'name': _nameController.text.trim(),
          'customerID': widget.item!.customerID, 
          'contact': _contactController.text.trim(),
          'payStatus':updatedStatus,
          'credit': updatedCredit,
          'partialPay': newPartial,
          'received': _receivedByController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _ledgerService.updateLedgerItem(docId, data);

     
        if (_selectedImage != null) {
          final url = await _ledgerService.uploadImage(_selectedImage!);
          if (url != null) {
            await _ledgerService.updateLedgerItem(docId, {'imageUrl': url});
          }
        }

        await HistoryService.recordLedgerCreditEvent(
          amount: updatedCredit,
          customerName:  _nameController.text.trim(),
          paymentStatus: updatedStatus, // "Unpaid" / "Partial" / "Paid"
        );
        
        if (!mounted) return;
        Navigator.pop(context, "updated");
      }
    } finally {
      DialogHelper.closeLoading(context);
    }
  }



// for cleaning up controllers
  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _creditController.dispose();
    _partialController.dispose();
    _receivedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor:  const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded, 
            color: Colors.white,
            size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.item == null ? 'Add' : 'Edit',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // for customer image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageUrl!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.image_outlined,
                                  size: 64, color: Color(0xFFFEFEFE)),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFFEFEFE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 2,
                                  offset: const Offset(0,2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 24, color: Color(0xFF1565C0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

             InvAddLabel(
              text: 'Name'), 
              TextFormField(
                controller: _nameController,
                decoration:
                  _inputDecoration(
                    hintText:  'Enter name'),
                validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter customer name': null,
              ),
              
              const SizedBox(height: 16),

              InvAddLabel(
              text: 'Contact Number'), 
              TextFormField(
                controller: _contactController,
                decoration:
                  _inputDecoration(
                    hintText:  'Enter contact number (Optional)'),
              ),

              const SizedBox(height: 16),

              // Payment Status
              InvAddLabel(
                text: 'Payment Status'),
              Row(
                children: ['Unpaid', 'Paid', 'Partial'].map((status) {
                  return Row(
                    children: [
                      Transform.scale( 
                        scale: 1.5,
                        child: Radio<String>(
                        value: status,
                        groupValue: _paymentStatus,
                        onChanged: (v) => setState(() => _paymentStatus = v!),
                        activeColor: Color(0xFF1565C0),
                      ),
                    ),
                      Text(status, style: GoogleFonts.inter()),
                      const SizedBox(width: 24),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              InvAddLabel(
                text: 'Credit Amount (Utang)'),
              TextFormField(
                controller:  _creditController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration:     
                  _inputDecoration(hintText: '0.00'),
                validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter credit (utang) amount' : null,
              ),

              const SizedBox(height: 16),

              InvAddLabel(
                text: 'Partial Payment Amount'),
              TextFormField(
                controller: _partialController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: _paymentStatus == 'Partial',

                style: TextStyle(
                  color: _paymentStatus == 'Partial'
                      ? Colors.black
                      : Colors.grey,  // Text color when disabled
                ),

                decoration: InputDecoration(
                  hintText: '0.00',
                  filled: true,
                  fillColor: _paymentStatus == 'Partial'
                      ? Color(0xFFF0F8FF)
                      : Colors.grey.shade200, // Background when disabled

                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB4D7FF)),
                  ),

                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // Border when disabled
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB4D7FF), width: 1),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),

                validator: _paymentStatus == 'Partial'
                    ? (v) => v == null || v.isEmpty ? 'Enter partial payment' : null
                    : null,
              ),


              const SizedBox(height: 16),


              InvAddLabel(
              text: 'Received by:'), 
              TextFormField(
                controller: _receivedByController,
                decoration:
                  _inputDecoration(
                    hintText:  'Enter name of cashier'),
                validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter cashier name': null,
              ),

              const SizedBox(height: 24),

            // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLedger,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon, Color? fillColor}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Color(0xFFB4D7FF),
        )
      ),
      hintText: hintText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      filled: true,           
      fillColor: fillColor ?? Color(0xFFF0F8FF), 
    );
  }
}
