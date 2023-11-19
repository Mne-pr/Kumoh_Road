import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:email_otp/email_otp.dart';
import 'package:provider/provider.dart';
import '../providers/kakao_login_providers.dart';
import '../utilities/url_launcher_util.dart'; // launchURL 유틸리티 함수를 사용하기 위해 임포트합니다.

class StudentVerificationScreen extends StatefulWidget {
  const StudentVerificationScreen({super.key});

  @override
  _StudentVerificationScreenState createState() => _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  EmailOTP myauth = EmailOTP();
  bool isOTPRequested = false;

  Future<void> sendOTP() async {
    String email = emailController.text;
    if (EmailValidator.validate(email) && email.endsWith('@kumoh.ac.kr')) {
      myauth.setConfig(
        appEmail: "KumohRoad@kumoh.ac.kr",
        appName: "Kumoh_Road",
        userEmail: email,
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
    } else if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("유효하지 않은 이메일 주소입니다")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("금오공과대학교 이메일을 입력하세요")),
      );
    }
  }

  Future<void> verifyOTP() async {
    bool result = await myauth.verifyOTP(otp: otpController.text);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("학생 인증이 완료되었습니다")),
      );
      Provider.of<KakaoLoginProvider>(context, listen: false).updateUserInfo(isStudentVerified: true);
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
        title: const Text('학생 인증', style: TextStyle(color: Colors.black)),
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
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '학교 이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: Icon(isOTPRequested ? Icons.mail_outline : Icons.send),
              label: Text(isOTPRequested ? '금오공과대학교 웹 메일 열기' : '웹 메일로 인증번호 발송'),
              onPressed: isOTPRequested ? () => launchURL('https://mail.kumoh.ac.kr/account/login.do') : sendOTP,
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
              label: const Text('금오공과대학교 학생 인증'),
              onPressed: verifyOTP,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
