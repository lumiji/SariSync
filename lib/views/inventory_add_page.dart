// This is the "ADD" form for the inventory page (Offline-friendly version)

// flutter dependencies
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

//firebase dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//pages
import 'sku_scanner.dart';
import 'package:sarisync/services/history_service.dart';

//models, widgets & services
import '../services/inventory_service.dart';
import 'package:sarisync/widgets/inv_add-label.dart';
import '../models/inventory_item.dart';
import 'package:sarisync/widgets/message_prompts.dart';

class InventoryAddPage extends StatefulWidget {
  final InventoryItem? item; // null for Add, not null for Edit

  const InventoryAddPage({Key? key, this.item}) : super(key: key);

  @override
  State<InventoryAddPage> createState() => _InventoryAddPageState();
}

class _InventoryAddPageState extends State<InventoryAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _inventoryService = InventoryService();
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _unitDropdownValue = _units.first;
    _checkConnectivity();

    if (widget.item != null) {
      final item = widget.item!;
      _nameController.text = item.name;
      _priceController.text = item.price.toString();
      _quantityController.text = item.quantity.toString();
      _quantity = item.quantity;
      _selectedCategory = item.category;
      _barcodeController.text = item.barcode;
      _expirationController.text = item.expiration;
      _infoController.text = item.add_info;

      // Split unit before space: "60 mL"
      if (item.unit.contains(" ")) {
        final split = item.unit.split(" ");
        _unitAmountController.text = split.first;
        _unitDropdownValue = split.last;
      }

      // load image preview if existing
      if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
        imageUrl = item.imageUrl;
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult.first != ConnectivityResult.none;
    });
    
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (mounted) {
        setState(() {
          _isOnline = result.first != ConnectivityResult.none;
        });
      }
    });
  }

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
                  final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
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
                  final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
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
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _unitAmountController = TextEditingController();
  final _expirationController = TextEditingController();
  final _infoController = TextEditingController();
  final _barcodeController = TextEditingController();

  // State
  File? _selectedImage;
  String? _selectedCategory;
  int _quantity = 0;
  DateTime? _selectedDate;
  String? _unitDropdownValue;
  String? imageUrl;

  final List<String> _units = ['g', 'kg', 'mL', 'L', 'oz', 'pc', 'pk'];

  final List<String> _categories = [
    'Snacks',
    'Drinks',
    'Cans & Packs',
    'Toiletries',
    'Condiments',
    'Others',
  ];

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

  // Check for duplicate barcode (works both online and offline)
  Future<bool> _checkDuplicateBarcode(String barcode, String name) async {
    if (barcode.isEmpty) return false;
    
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final inventoryRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('inventory');

    try {
      QuerySnapshot querySnapshot;
      
      if (_isOnline) {
        // Online: Check server
        querySnapshot = await inventoryRef
            .where('barcode', isEqualTo: barcode)
            .limit(1)
            .get();
      } else {
        // Offline: Check cache only
        querySnapshot = await inventoryRef
            .where('barcode', isEqualTo: barcode)
            .limit(1)
            .get(const GetOptions(source: Source.cache));
      }

      if (querySnapshot.docs.isNotEmpty) {
        await DialogHelper.warning(
          context,
          '$name is already in your inventory.',
        );
        return true; // Duplicate found
      }
      
      return false; // No duplicate
    } catch (e) {
      print('Error checking for duplicates: $e');
      // If cache is empty or error, allow the save
      return false;
    }
  }

  // OFFLINE SAVE - Fast and simple
  Future<void> _saveOffline(
    String name,
    int quantity,
    double price,
    String category,
    String barcode,
    String unit,
    String info,
    String expiration,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      if (widget.item == null) {
        // ADD MODE - Offline
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('inventory')
            .add({
          'name': name,
          'quantity': quantity,
          'price': price,
          'category': category,
          'barcode': barcode,
          'unit': unit,
          'add_info': info,
          'expiration': expiration,
          'imageUrl': null, // No image offline
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // EDIT MODE - Offline
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('inventory')
            .doc(widget.item!.id)
            .update({
          'name': name,
          'quantity': quantity,
          'price': price,
          'category': category,
          'barcode': barcode,
          'unit': unit,
          'add_info': info,
          'expiration': expiration,
          // Keep existing imageUrl when editing offline
          if (imageUrl != null) 'imageUrl': imageUrl,
        });
      }

      // Success
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        await DialogHelper.success(
          context,
          'Item saved offline. Will sync when connected.',
        );
        Navigator.of(context).pop(widget.item == null ? "added" : "updated");
      }
    } catch (e) {
      print('Offline save error: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        await DialogHelper.warning(
          context,
          'Failed to save offline. Please try again.',
        );
      }
    }
  }

  // ONLINE SAVE - Full featured with images and history
  Future<void> _saveOnline(
    String name,
    int quantity,
    double price,
    String category,
    String barcode,
    String unit,
    String info,
    String expiration,
  ) async {
    String? uploadedImageUrl = imageUrl;

    try {
      // Upload image if new image selected
      if (_selectedImage != null) {
        try {
          uploadedImageUrl = await _inventoryService
              .uploadImage(_selectedImage!)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  print('Image upload timed out');
                  return null;
                },
              );
        } catch (e) {
          print('Image upload failed: $e');
          uploadedImageUrl = null;
        }
      }

      if (widget.item == null) {
        // ADD MODE - Online
        await _inventoryService.addItem(
          name: name,
          quantity: quantity,
          price: price,
          category: category,
          barcode: barcode,
          unit: unit,
          info: info,
          expirationDate: expiration,
          imageUrl: uploadedImageUrl,
        );

        // Run history checks
        try {
          await Future.wait([
            HistoryService.checkStockEvent(
              itemName: name,
              quantity: quantity,
            ),
            HistoryService.checkExpiryEvent(
              itemName: name,
              expirationDate: expiration,
            ),
          ]).timeout(const Duration(seconds: 5));
        } catch (e) {
          print('History service error: $e');
        }
      } else {
        // EDIT MODE - Online
        final updatedItem = InventoryItem(
          id: widget.item!.id,
          name: name,
          quantity: quantity,
          price: price,
          category: category,
          barcode: barcode,
          unit: unit,
          add_info: info,
          expiration: expiration,
          imageUrl: uploadedImageUrl,
          createdAt: widget.item!.createdAt,
        );

        await _inventoryService.updateItem(updatedItem);

        // Run history checks
        try {
          await Future.wait([
            HistoryService.checkStockEvent(
              itemName: name,
              quantity: quantity,
            ),
            HistoryService.checkExpiryEvent(
              itemName: name,
              expirationDate: expiration,
            ),
          ]).timeout(const Duration(seconds: 5));
        } catch (e) {
          print('History service error: $e');
        }
      }

      // Success
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.of(context).pop(widget.item == null ? "added" : "updated");
      }
    } catch (e) {
      print('Online save error: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        await DialogHelper.warning(
          context,
          'Failed to save item. Please try again.',
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final quantity = int.parse(_quantityController.text);
    final price = double.parse(_priceController.text);
    final category = _selectedCategory ?? '';
    final barcode = _barcodeController.text.trim();
    final unit = '${_unitAmountController.text} ${_unitDropdownValue ?? ''}';
    final info = _infoController.text.trim();
    final expiration = _expirationController.text.trim();

    // Double-check connectivity
    final connectivityCheck = await Connectivity().checkConnectivity();
    final isCurrentlyOnline = connectivityCheck.first != ConnectivityResult.none;
    
    if (isCurrentlyOnline != _isOnline) {
      setState(() {
        _isOnline = isCurrentlyOnline;
      });
    }

    // Check for duplicate barcode (works both online and offline)
    if (widget.item == null) {
      final isDuplicate = await _checkDuplicateBarcode(barcode, name);
      if (isDuplicate) return;
    }

    // Warn about offline image upload
    if (!isCurrentlyOnline && _selectedImage != null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Offline Mode'),
          content: const Text(
            'You are offline. The item will be saved without the image. You can edit it later to add the image when online.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save Without Image'),
            ),
          ],
        ),
      );
      
      if (proceed != true) return;
    }

    // Show loading
    DialogHelper.showLoading(
      context,
      message: isCurrentlyOnline ? "Saving item..." : "Saving offline...",
    );

    // Route to appropriate save method
    if (isCurrentlyOnline) {
      await _saveOnline(
        name,
        quantity,
        price,
        category,
        barcode,
        unit,
        info,
        expiration,
      );
    } else {
      await _saveOffline(
        name,
        quantity,
        price,
        category,
        barcode,
        unit,
        info,
        expiration,
      );
    }
  }

  // for cleaning up controllers
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _expirationController.dispose();
    _infoController.dispose();
    _barcodeController.dispose();
    _unitAmountController.dispose();
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
              Navigator.pop(context);
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
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
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
          style: const TextStyle(
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
              // Offline banner
              if (!_isOnline)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, size: 18, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline - images cannot be uploaded',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // For product image
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
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: Color(0xFFFEFEFE),
                              ),
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
                                  offset: const Offset(0, 2),
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

              // for category
              InvAddLabel(text: 'Category'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(
                  fillColor: const Color(0xFFF0F8FF),
                ),
                hint: const Text(
                  'Select category',
                  style: TextStyle(color: Color(0xFF9E9E9E)),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 32,
                  color: Color(0xFF757575),
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
              InvAddLabel(text: 'Name'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(hintText: 'Enter item name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter item name' : null,
              ),
              const SizedBox(height: 16),

              // Price
              InvAddLabel(text: 'Price'),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration(hintText: '0.00'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),

              // for quantity
              InvAddLabel(text: 'Quantity'),
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
                          iconSize: 32,
                          icon: const Icon(Icons.arrow_drop_up),
                          color: Color(0xFF757575),
                          onPressed: _incrementQuantity,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 32,
                          icon: const Icon(Icons.arrow_drop_down),
                          color: Color(0xFF757575),
                          onPressed: _decrementQuantity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              InvAddLabel(text: 'Unit of Measure'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _unitAmountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        hintText: 'Enter unit of measure (e.g., 60mL)',
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter unit of measure'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _unitDropdownValue,
                      decoration: _inputDecoration(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 32,
                        color: Color(0xFF757575),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _unitDropdownValue = value!;
                        });
                      },
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Select a unit' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barcode Field + Scan Button
              InvAddLabel(text: 'Barcode'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: _inputDecoration(
                        hintText: 'Enter or scan barcode',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _openBarcodeScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
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
              InvAddLabel(text: 'Expiration Date'),
              TextFormField(
                controller: _expirationController,
                readOnly: true,
                onTap: _selectDate,
                decoration: _inputDecoration(
                  hintText: 'Select expiration date',
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Info
              InvAddLabel(text: 'Additional Info'),
              TextFormField(
                controller: _infoController,
                maxLines: 3,
                decoration: _inputDecoration(
                  hintText: 'Enter additional information',
                ),
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
                      borderRadius: BorderRadius.circular(6),
                    ),
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

  InputDecoration _inputDecoration(
      {String? hintText, Widget? suffixIcon, Color? fillColor}) {
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
        ),
      ),
      hintText: hintText,
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      filled: true,
      fillColor: fillColor ?? Color(0xFFF0F8FF),
    );
  }
}