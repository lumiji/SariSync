// This is the "ADD" form for the inventory page

// flutter dependencies
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//firebase dependencies

//pages
import 'sku_scanner.dart';


class InventoryAddPage extends StatefulWidget {
  const InventoryAddPage({Key? key}) : super(key: key);

  @override
  State<InventoryAddPage> createState() => _InventoryAddPageState();
}

class _InventoryAddPageState extends State<InventoryAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _expirationController = TextEditingController();
  final _infoController = TextEditingController();
  final _barcodeController = TextEditingController(); // text field for displaying barcode

  // State
  File? _selectedImage;
  String? _selectedCategory;
  int _quantity = 0;
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Snacks',
    'Drinks',
    'Cans & Packs',
    'Toiletries',
    'Condiments',
    'Other',
  ];

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

  //for increasing and decreasing quantity
  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _quantityController.text = _quantity.toString();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _quantityController.text = _quantity.toString();
      });
    }
  }

  // for expiration date (opens calendar for easy input)
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _expirationController.text =
            '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  // for saving item
  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

// for cleaning up controllers 
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _expirationController.dispose();
    _infoController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  // for opening barcode scanner page
  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Scan Barcode')),
          body: BarcodeScanner(
            onDetect: (barcode) {
              setState(() {
                _barcodeController.text = barcode;
              });
              Navigator.pop(context); // Closes scanner after scanning
            },
          ),
        ),
      ),
    );
  }

// UI for the form
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: Color(0xFFFEFEFE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
              // For product image
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
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
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

              // for category
              _buildLabel('Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(fillColor: const Color(0xFFF0F8FF)), // light grey background
                hint: const Text(
                  'Select category',
                  style: TextStyle(color: Color(0xFF9E9E9E)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Name
              _buildLabel('Name'),
              TextFormField(
                controller: _nameController,
                decoration:
                    _inputDecoration(hintText: 'Enter item name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter item name' : null,
              ),
              const SizedBox(height: 16),

              // Price
              _buildLabel('Price'),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(hintText: '0.00'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Quantity'),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              onChanged: (v) => _quantity = int.tryParse(v) ?? _quantity,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter quantity' : null,
              decoration: _inputDecoration(
                hintText: '0',
                suffixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 28,
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: _incrementQuantity,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 28,
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: _decrementQuantity,
                      ),
                    ),
                  ],
                ),
              ),
            ),

              // Barcode Field + Scan Button
              _buildLabel('Barcode'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: _inputDecoration(
                          hintText: 'Enter or scan barcode'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _openBarcodeScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'Scan',
                        style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFEFEFE),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expiration Date
              _buildLabel('Expiration Date'),
              TextFormField(
                controller: _expirationController,
                readOnly: true,
                onTap: _selectDate,
                decoration: _inputDecoration(
                  hintText: 'Select expiration date',
                  suffixIcon: const Icon(Icons.calendar_today,
                      size: 18, color: Color(0xFF757575)),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Info
              _buildLabel('Additional Info'),
              TextFormField(
                controller: _infoController,
                maxLines: 3,
                decoration: _inputDecoration(
                    hintText: 'Enter additional information'),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveItem,
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

  // Reusable UI helpers
  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF424242),
        ),
      );

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon, Color? fillColor}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      hintText: hintText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      filled: true,           
      fillColor: fillColor ?? Color(0xFFF0F8FF), 
    );
  }
// for quantity buttons
  Widget _buildQuantityButtons() => Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            IconButton(
                onPressed: _decrementQuantity,
                icon: const Icon(Icons.remove, size: 18)),
            const VerticalDivider(width: 1),
            IconButton(
                onPressed: _incrementQuantity,
                icon: const Icon(Icons.add, size: 18)),
          ],
        ),
      );
}


