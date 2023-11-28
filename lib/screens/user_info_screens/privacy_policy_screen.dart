import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '금오로드는 사용자의 개인정보를 보호하고 사용자에게 안전하고 효과적인 서비스를 제공하기 위해 최선을 다하고 있습니다.\n 본 개인정보 처리방침은 금오로드가 어떻게 사용자의 정보를 수집, 사용, 공유하는지에 대한 중요한 정보를 담고 있습니다.\n\n'
              '1. 수집하는 개인정보의 항목 및 수집 방법\n'
              ' - 금오로드는 서비스 제공을 위해 이메일, 성별, 생년월일, 로그인 ID 등의 정보를 수집합니다.\n 이 정보는 주로 카카오 로그인을 통해 수집됩니다.\n\n'
              '2. 개인정보의 이용 목적\n'
              ' - 수집된 정보는 서비스 제공, 사용자 관리, 신규 기능 개발 및 개선, 안전한 서비스 이용 환경 조성 등을 위해 사용됩니다.\n\n'
              '3. 개인정보의 보유 및 이용 기간\n'
              ' - 사용자의 정보는 서비스 이용 기간 동안 보유하며, 법적인 요구가 있는 경우를 제외하고는 이용자의 요청에 따라 삭제됩니다.\n\n'
              '4. 개인정보의 파기 절차 및 방법\n'
              ' - 사용자의 개인정보는 목적 달성 후 별도의 DB로 옮겨져 일정 기간 저장된 후 파기됩니다.\n'
              ' - 전자적 파일 형태로 저장된 개인정보는 기술적 방법을 사용하여 복구 및 재생이 불가능하도록 안전하게 삭제됩니다.\n\n'
              '5. 개인정보 보호를 위한 기술적, 관리적 대책\n'
              ' - 금오로드는 사용자의 개인정보 보호를 위해 보안 시스템을 갖추고 있으며, 정기적인 점검을 통해 안전을 유지하고 있습니다.\n'
              ' - 사용자의 개인정보에 접근할 수 있는 인원을 최소한으로 제한하며, 이를 위반할 시 엄격한 처벌을 받을 수 있습니다.\n\n'
              '본 개인정보 처리방침은 법률 및 정책의 변경에 따라 변경될 수 있으며, 변경 시 사용자에게 적절한 방법으로 통지할 것입니다.\n',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}