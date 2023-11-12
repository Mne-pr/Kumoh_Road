import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.photo_library), // 갤러리 아이콘 추가
              label: const Text('QR 코드 등록'),
              onPressed: _pickImageFromGallery,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
                ),
              ),
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GuideStep(
                    imagePath: 'assets/images/QR_guide0.jpg',
                    instruction: '1. 카카오톡 실행 후 "더보기" 탭을 선택합니다.',
                  ),
                  GuideStep(
                    imagePath: 'assets/images/QR_guide1.jpg',
                    instruction: '2. 오른쪽 상단의 QR 코드 버튼을 누릅니다.',
                  ),
                  GuideStep(
                    imagePath: 'assets/images/QR_guide2.jpg',
                    instruction: '3. QR 코드가 나오면 저장 버튼을 선택하여 저장합니다.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

class GuideStep extends StatelessWidget {
  final String imagePath;
  final String instruction;

  const GuideStep({
    Key? key,
    required this.imagePath,
    required this.instruction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            instruction,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Image.asset(imagePath),
        ],
      ),
    );
  }
}
