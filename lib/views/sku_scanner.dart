import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String barcode)? onDetect;

  const BarcodeScanner({Key? key, this.onDetect}) : super(key: key);

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
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
  bool _isTorchOn = true; // initial state matches controller

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;
    _isProcessing = true;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue ?? '';
      if (value.isNotEmpty) {
        widget.onDetect?.call(value);
        _audioPlayer.play(AssetSource('audio/scanner_beep.mp3'));
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _MobileScannerController.dispose();
    super.dispose();
  }
}
