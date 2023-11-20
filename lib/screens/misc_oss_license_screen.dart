import 'package:flutter/material.dart';
import '../oss_licenses.dart';

class MiscOssLicenseScreen extends StatelessWidget {
  final Package package;

  const MiscOssLicenseScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(package.name, style: const TextStyle(color: Colors.black)), // 패키지 이름
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView( // 긴 텍스트를 위해 SingleChildScrollView 사용
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Version: ${package.version}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('License:\n${package.license}', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
