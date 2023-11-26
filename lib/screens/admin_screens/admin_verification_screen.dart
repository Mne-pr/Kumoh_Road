import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:provider/provider.dart';

import '../../providers/user_providers.dart';
import 'admin_main_screen.dart';

class AdminVerificationScreen extends StatefulWidget {
  @override
  _AdminVerificationScreenState createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  EmailOTP myauth = EmailOTP();
  bool isOTPRequested = false;
  String? selectedAdminEmail;
  String? selectedAdmin;

  final Map<String, String?> adminEmails = {
    '송제용': 'joon6093@kumoh.ac.kr',
    '권태현': null,
    '손현락': null,
    '배건애': null,
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendOTP() async {
    if (selectedAdminEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("유효한 관리자를 선택해주세요")),
      );
      return;
    }

    myauth.setConfig(
      appEmail: "KumohRoad@kumoh.ac.kr",
      appName: "Kumoh_Road",
      userEmail: selectedAdminEmail!,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );

    bool result = await myauth.sendOTP();
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("인증번호가 발송되었습니다")),
      );
      setState(() {
        isOTPRequested = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("인증번호 발송에 실패했습니다")),
      );
    }
  }

  Future<void> verifyOTP() async {
    bool result = await myauth.verifyOTP(otp: otpController.text);
    if (result) {
      // 관리자 인증이 성공하면, 관리자 로그인을 실행합니다.
      await Provider.of<UserProvider>(context, listen: false)
          .loginAsAdmin();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("관리자 인증이 완료되었습니다")),
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminMainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("잘못된 인증번호입니다")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 인증', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: selectedAdmin,
              decoration: const InputDecoration(
                labelText: '관리자 선택',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              ),
              items: adminEmails.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedAdmin = newValue;
                  selectedAdminEmail = adminEmails[newValue];
                });
              },
            ),
            const SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('인증번호 발송'),
              onPressed: sendOTP,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(labelText: '인증번호 입력'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.verified_user),
              label: const Text('인증번호 확인'),
              onPressed: verifyOTP,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Spacer(), // Use Spacer to push the test button to the bottom
            ElevatedButton(
              onPressed: () async {
                // 관리자 로그인을 실행합니다.
                await Provider.of<UserProvider>(context, listen: false)
                    .loginAsAdmin();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AdminMainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('테스트용 관리자 화면 이동'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
