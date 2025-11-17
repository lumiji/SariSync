// This is the "ADD" form for the ledger page

// flutter dependencies
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarisync/widgets/led-item_card.dart';
import 'dart:io';

//firebase dependencies

//pages

//models, widgets & services
import '../services/inventory_service.dart';
import 'package:sarisync/widgets/inv_add-label.dart';
import 'package:sarisync/widgets/led-item_card.dart';


class LedgerAddPage extends StatefulWidget {
  const LedgerAddPage({Key? key}) : super(key: key);

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
  String? _paymentStatus = 'Unpaid';

  // for saving item
  void _saveCustomer() async {
    double credit = double.tryParse(_creditController.text) ?? 0;
    double partial = _paymentStatus == 'Partial'
        ? double.tryParse(_partialController.text) ?? 0
        : 0;

    LedItemCard newItem = LedItemCard(
      name: _nameController.text.trim(),
      customerID: DateTime.now().millisecondsSinceEpoch.toString(), // simple unique ID
      contact: _contactController.text.trim(),
      pay_status: _paymentStatus,
      credit: credit,
      partial_pay: partial,
      received: _receivedByController.text.trim(),
      imageUrl: null, // handle image upload in your LedgerService if needed
      createdAt: DateTime.now(),
    );

    await _ledgerService.addLedgerItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer saved!')));
    Navigator.pop(context);
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

// UI for the form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFEFE),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: const Text(
          'Add Ledger',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImage!,
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.image_outlined,
                                size: 60, color: Color(0xFFFEFEFE)),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFFFEFEFE), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt,
                              size: 24, color: Color(0xFF1565C0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              Text('Name', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(hintText: 'Enter name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),

              // Contact Number
              Text('Contact Number (Optional)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              TextFormField(
                controller: _contactController,
                decoration: _inputDecoration(hintText: 'Enter contact'),
              ),
              const SizedBox(height: 16),

              // Payment Status
              Text('Payment Status',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Row(
                children: ['Unpaid', 'Paid', 'Partial'].map((status) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: status,
                        groupValue: _paymentStatus,
                        onChanged: (v) => setState(() => _paymentStatus = v!),
                      ),
                      Text(status, style: GoogleFonts.inter()),
                      const SizedBox(width: 12),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Credit Amount
              Text('Credit Amount (Utang)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              TextFormField(
                controller: _creditController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(hintText: '0.00'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter credit' : null,
              ),
              const SizedBox(height: 16),

              // Partial Payment (enabled only if Partial selected)
              Text('Partial Payment Amount',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              TextFormField(
                controller: _partialController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(hintText: '0.00'),
                enabled: _paymentStatus == 'Partial',
                validator: (v) {
                  if (_paymentStatus == 'Partial') {
                    return (v == null || v.isEmpty)
                        ? 'Enter partial payment amount'
                        : null;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Received by
              Text('Received by', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              TextFormField(
                controller: _receivedByController,
                decoration: _inputDecoration(hintText: 'Enter receiver name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter receiver' : null,
              ),
              const SizedBox(height: 24),

              // Save button
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
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF0F8FF),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    );
  }
}