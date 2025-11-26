import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String?> saveReceiptAsImage(GlobalKey key, {String fileName = "receipt"}) async {
  try {

    // Capture widget
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    if (pngBytes == null) return null;

    // Save to external storage
    final directory = Directory('/storage/emulated/0/Pictures/SariSync');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath = '${directory.path}/$fileName.png';
    final file = await File(filePath).writeAsBytes(pngBytes);

    // Refresh gallery
    const platform = MethodChannel('com.yourapp/media_scan');
    await platform.invokeMethod('scanFile', {'path': file.path});

    return filePath;
  } catch (e) {
    print("Error saving receipt: $e");
    return null;
  }
}
