import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/kakao_login_providers.dart';
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
          String qrCodeUrl = barcode.rawValue!;
          Provider.of<KakaoLoginProvider>(context, listen: false).updateUserInfo(url: qrCodeUrl);
          launchURL(qrCodeUrl);
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
              icon: const Icon(Icons.photo_library),
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
                    instruction: '1. 카카오톡 실행 후 하단에',
                    icon: Icons.more_horiz,
                    trailingText: ' 탭을 선택합니다.',
                  ),
                  GuideStep(
                    imagePath: 'assets/images/QR_guide1.jpg',
                    instruction: '2. 오른쪽 상단의 ',
                    icon: Icons.qr_code,
                    trailingText: ' 을 누릅니다.',
                  ),
                  GuideStep(
                    imagePath: 'assets/images/QR_guide2.jpg',
                    instruction: '3. QR 코드가 나오면 ',
                    icon: Icons.save_alt ,
                    trailingText: ' 선택하여 저장합니다.',
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
  final IconData icon;
  final String trailingText;

  const GuideStep({
    Key? key,
    required this.imagePath,
    required this.instruction,
    required this.icon,
    required this.trailingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(text: instruction),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(icon, size: 16), // 아이콘
                  ),
                ),
                TextSpan(text: trailingText),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(imagePath),
        ],
      ),
    );
  }
}
