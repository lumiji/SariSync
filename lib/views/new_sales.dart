import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sarisync/models/inventory_item.dart';
import 'package:sarisync/widgets/pos-item_card.dart';
import 'package:sarisync/views/new_sales_search.dart';
import 'package:sarisync/models/receipt_item.dart';
import 'package:sarisync/views/receipt.dart';
import 'package:sarisync/widgets/message_prompts.dart';
import 'package:intl/intl.dart';

class PoSSystem extends StatefulWidget {
  final Function(String barcode)? onDetect;
  final Stream<List<InventoryItem>> inventoryStream;

  const PoSSystem({
    Key? key,
    this.onDetect,
    required this.inventoryStream,
  }) : super(key: key);

  @override
  State<PoSSystem> createState() => _PoSSystem();
}

class _PoSSystem extends State<PoSSystem> {
  List<InventoryItem> scannedItemsList = [];
  List<InventoryItem> allInventoryItems = [];

  final _MobileScannerController = MobileScannerController(
    cameraResolution: const Size(1280, 720),
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.all],
    torchEnabled: true,
    autoZoom: true,
    autoStart: true,
  );

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessing = false;
  bool _isTorchOn = true;
  int _scannedItems = 0;

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    _isProcessing = true;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue ?? '';

      if (value.isNotEmpty) {
        final match = allInventoryItems.firstWhere(
          (item) => item.barcode == value,
          orElse: () => null as InventoryItem,
        );

        if (match != null) {
          setState(() {
            _scannedItems++;
            scannedItemsList.add(match);
          });

          widget.onDetect?.call(value);
          _audioPlayer.play(AssetSource('audio/scanner_beep.mp3'));
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _isProcessing = false;
    });
  }

  void _toggleTorch() {
    _MobileScannerController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF7FBFF),
    appBar: AppBar(
      backgroundColor: const Color(0xFF1565C0),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Scan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: StreamBuilder<List<InventoryItem>>(
      stream: widget.inventoryStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          allInventoryItems = snapshot.data!;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 36),
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MobileScanner(
                    controller: _MobileScannerController,
                    fit: BoxFit.cover,
                    onDetect: _handleBarcode,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Scanned Items: $_scannedItems",
                    style: GoogleFonts.inter(
                      color: Color(0xFF212121),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      //opens the search page
                      _MobileScannerController.stop();
                      final selectedItem = await Navigator.push<InventoryItem>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(),
                        ),
                      );
                        _MobileScannerController.start();
        
                      // adds the manually selected item to the scanned item list
                      if (selectedItem != null) {
                        setState(() {
                          scannedItemsList.add(selectedItem);
                          _scannedItems++;
                        });
                      }
                    },
                    child: const Text(
                      'Manual Add',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Color(0xFF757575),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: scannedItemsList.isEmpty
                    ? Center(
                        child: Text(
                          "No scanned items",
                          style: GoogleFonts.inter(
                            fontSize: 14, 
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8
                        ),
                        itemCount: scannedItemsList.length,
                        itemBuilder: (context, index) {
                          final item = scannedItemsList[index];

                          return PosItemCard(
                            item: item,
                            onDelete: () {
                              try {
                                setState(() {
                                  scannedItemsList.removeAt(index);
                                  _scannedItems--;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error deleting item: $e')),
                                );
                              }
                            },
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                      ),
                ),
              ], 
            ),
          ); 
        },
      ),
              
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          _MobileScannerController.stop();

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          List<String> warnings = [];

          for (var item in scannedItemsList) {
            final parts = item.expiration.split('/'); // ["11", "25", "2025"]
              final expiryDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[0]), // month
                int.parse(parts[1]), // day
              );


            final isExpired = expiryDate != null &&
                !DateTime(expiryDate.year, expiryDate.month, expiryDate.day)
                    .isAfter(today);

            // Combine quantity and expiration check with OR
            if (item.quantity == 0 || isExpired) {
              if (item.quantity == 0) warnings.add("${item.name} is out of stock.");
              if (isExpired) warnings.add("${item.name} is expired.");
            }
          }

          if (warnings.isNotEmpty) {
            await DialogHelper.warning(
              context,
              warnings.join("\n"),
            );
            return;
          }

          // Proceed to receipt if no warnings
          final tabIndex = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptPage(
                scannedItems: scannedItemsList.map((item) => ReceiptItem(
                  id: item.id!,
                  name: item.name,
                  price: item.price,
                  quantity: 1,
                )).toList(),
              ),
            ),
          );

          if (tabIndex != null && tabIndex is int) {
            Navigator.pop(context, tabIndex);
          }
        },
        backgroundColor: const Color(0xFFFF9800),
        label: Text(
          'Proceed to Receipt',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFFFCFCFC),
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: const Icon(
          Icons.receipt,
          color: Color(0xFFFCFCFC),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

          );
        }


  @override
  void dispose() {
    _MobileScannerController.dispose();
    super.dispose();
  }
}
