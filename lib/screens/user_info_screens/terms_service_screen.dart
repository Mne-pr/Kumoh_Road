import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서비스 이용 약관', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '금오로드 애플리케이션을 사용해 주셔서 감사합니다. 본 서비스 이용 약관은 사용자가 금오로드 애플리케이션을 이용함에 있어 필요한 권리, 의무 및 책임사항을 규정하고 있습니다.\n\n'
              '1. 서비스 이용 조건\n'
              ' - 사용자는 금오로드 애플리케이션을 통해 제공되는 서비스를 법률 및 이 약관에 어긋나지 않는 범위 내에서 사용할 수 있습니다.\n\n'
              '2. 사용자의 의무\n'
              ' - 사용자는 개인정보 보호, 저작권법 등 관련 법률을 준수해야 하며, 이를 위반할 경우 책임을 질 수 있습니다.\n\n'
              '3. 서비스 제공의 변경 및 중지\n'
              ' - 금오로드는 서비스 개선을 위해 서비스 내용을 변경하거나 중지할 수 있으며, 이에 대해 사전에 사용자에게 고지합니다.\n\n'
              '4. 계약 해지 및 이용 제한\n'
              ' - 사용자가 이 약관을 위반하는 경우, 금오로드는 서비스 이용을 제한하거나 계약을 해지할 수 있습니다.\n\n'
              '본 이용 약관은 법률 및 정책의 변경에 따라 변경될 수 있으며, 변경 시 사용자에게 적절한 방법으로 통지할 것입니다.\n'
              '본 약관에 동의하지 않는 경우, 서비스 이용이 제한될 수 있습니다.\n\n',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
