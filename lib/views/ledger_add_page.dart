import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ledger_item.dart';
import '../services/ledger_service.dart';

class LedgerAddPage extends StatefulWidget {
  const LedgerAddPage({Key? key}) : super(key: key);

  @override
  State<LedgerAddPage> createState() => _LedgerAddPageState();
}

class _LedgerAddPageState extends State<LedgerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _ledgerService = LedgerService();

  // Controllers
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _creditController = TextEditingController();
  final _partialController = TextEditingController();
  final _receivedByController = TextEditingController();

  // State
  File? _selectedImage;
  String _paymentStatus = 'Unpaid';

  // Image picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Save ledger item
  Future<void> _saveLedger() async {
  if (!_formKey.currentState!.validate()) return;

  final credit = double.tryParse(_creditController.text) ?? 0;
  final partial = _paymentStatus == 'Partial'
      ? double.tryParse(_partialController.text) ?? 0
      : 0.0;

  await _ledgerService.addLedgerItem(
    name: _nameController.text.trim(),
    customerID: DateTime.now().millisecondsSinceEpoch.toString(),
    contact: _contactController.text.trim(),
    pay_status: _paymentStatus,
    credit: credit,
    partial_pay: partial,
    received: _receivedByController.text.trim(),
    imageUrl: _selectedImage?.path, // optional
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Customer saved!')));
  Navigator.pop(context);
}


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
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFEFE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Ledger',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
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
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
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
                            color: Color(0xFFFEFEFE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 24, color: Color(0xFF1565C0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField('Name', _nameController, 'Enter name'),
              const SizedBox(height: 16),
              _buildTextField('Contact Number (Optional)', _contactController, 'Enter contact'),
              const SizedBox(height: 16),

              // Payment Status
              Text('Payment Status', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

              _buildTextField('Credit Amount (Utang)', _creditController, '0.00', isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(
                'Partial Payment Amount',
                _partialController,
                '0.00',
                isNumber: true,
                enabled: _paymentStatus == 'Partial',
                validator: _paymentStatus == 'Partial'
                    ? (v) => v == null || v.isEmpty ? 'Enter partial payment' : null
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField('Received by', _receivedByController, 'Enter receiver name'),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLedger,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

  Widget _buildTextField(String label, TextEditingController controller, String hint,
      {bool isNumber = false, bool enabled = true, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          decoration: _inputDecoration(hintText: hint),
          validator: validator ?? (v) => v == null || v.isEmpty ? 'Please enter $label' : null,
        ),
      ],
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
