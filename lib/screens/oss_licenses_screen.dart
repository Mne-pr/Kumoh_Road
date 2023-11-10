import 'package:flutter/material.dart';
import '../oss_licenses.dart';
import 'misc_oss_license_screen.dart';

class OssLicensesScreen extends StatelessWidget {
  const OssLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오픈소스 라이센스', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        titleSpacing: -5.0, // AppBar 제목과 뒤로 가기 버튼 사이 간격 제거
      ),
      body: ListView.builder(
        itemCount: ossLicenses.length,
        itemBuilder: (context, index) {
          final package = ossLicenses[index];
          return ListTile(
            title: Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold)), // 패키지 이름
            subtitle: Text('Version ${package.version}', style: const TextStyle(color: Colors.grey)), // 패키지 버전
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MiscOssLicenseScreen(package: package),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
