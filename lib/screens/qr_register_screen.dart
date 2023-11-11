import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utilities/image_picker_util.dart';
import '../utilities/url_launcher_util.dart';

class QRCodeRegistrationScreen extends StatefulWidget {
  @override
  _QRCodeRegistrationScreenState createState() => _QRCodeRegistrationScreenState();
}

class _QRCodeRegistrationScreenState extends State<QRCodeRegistrationScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  File? _image;

  Future<void> _pickImageFromGallery() async {
    _image = await ImagePickerUtils.pickImageFromGallery();
    if (_image != null) {
      setState(() {});
      _scanImage(_image!);
    }
  }

  void _scanImage(File image) async {
    await _scannerController.analyzeImage(image.path);
  }

  @override
  void initState() {
    super.initState();
    _scannerController.barcodes.listen((barcodeCapture) {
      for (var barcode in barcodeCapture.barcodes) {
        if (barcode.format == BarcodeFormat.qrCode && barcode.rawValue != null) {
          launchURL(barcode.rawValue!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 코드 등록', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        titleSpacing: -5.0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text('갤러리에서 QR 코드 선택'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              _image != null ? Image.file(_image!) : const Text('이미지가 선택되지 않았습니다.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}