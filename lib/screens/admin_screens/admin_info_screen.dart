import 'package:flutter/material.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/screens/user_info_screens/privacy_policy_screen.dart';
import 'package:kumoh_road/screens/user_info_screens/qr_register_screen.dart';
import 'package:kumoh_road/screens/user_info_screens/report_list_screen.dart';
import 'package:kumoh_road/screens/user_info_screens/student_verification_screen.dart';
import 'package:kumoh_road/screens/user_info_screens/terms_service_screen.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import '../../widgets/user_info_section.dart';
import '../user_info_screens/developer_info_screen.dart';
import '../user_info_screens/faq_screen.dart';
import '../user_info_screens/manner_temp_screen.dart';
import '../user_info_screens/oss_licenses_screen.dart';

class AdminInfoScreen extends StatefulWidget {
  const AdminInfoScreen({Key? key}) : super(key: key);
  @override
  _AdminInfoScreenState createState() => _AdminInfoScreenState();
}

class _AdminInfoScreenState extends State<AdminInfoScreen> {
  late ScrollController _scrollController;
  bool _showRightArrow = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    userProvider.startListeningToUserChanges(); // Firestore의 변경사항을 실시간으로 감지하도록 설정

    return Scaffold(
      appBar: _buildAppBar(context, userProvider),
      body: ListView(
        children: [
          UserInfoSection(
            nickname: userProvider.nickname ?? 'N/A',
            imageUrl: userProvider.profileImageUrl ?? 'https://k.kakaocdn.net/dn/1G9kp/btsAot8liOn/8CWudi3uy07rvFNUkk3ER0/img_640x640.jpg',
            age: userProvider.age ?? 0,
            gender: userProvider.gender ?? 'N/A',
            mannerTemperature: userProvider.mannerTemperature ?? 0,
          ),
          _buildUserInteractionButtons(context,userProvider),
          _buildInformationTile(context),
          _buildOtherOptionsTile(context, userProvider),
        ],
      ),
      bottomNavigationBar: const AdminCustomBottomNavigationBar(selectedIndex: 4),
    );
  }

  AppBar _buildAppBar(BuildContext context, UserProvider userProvider) {
    return AppBar(
      title: const Text('나의 정보', style: TextStyle(color: Colors.black)),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () => _showAdditionalInfoDialog(context, userProvider), // 설정 아이콘 클릭 시 대화상자 표시
        ),
      ],
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
    );
  }

  void _showAdditionalInfoDialog(BuildContext context, UserProvider userProvider) {
    int age = userProvider.age ?? 25; // 사용자의 현재 나이를 가져오거나 기본값 설정
    String gender = userProvider.gender ?? '남성'; // 사용자의 현재 성별을 가져오거나 기본값 설정
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('추가 정보 수정'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "이 단계는 향후 비즈니스 검증 절차를 완료한 후\n 카카오 로그인을 통해 자동으로 수집될 예정입니다.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text('나이'),
                    Center(
                      child: SizedBox(
                        height: 100,
                        child: NumberPicker(
                          value: age,
                          minValue: 19,
                          maxValue: 30,
                          onChanged: (value) => setState(() => age = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('성별'),
                    Center(
                      child: SizedBox(
                        width: 150,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: gender,
                          items: <String>['남성', '여성'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              gender = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('저장'),
                  onPressed: () async {
                    await Provider.of<UserProvider>(context, listen: false)
                        .updateUserInfo(age: age, gender: gender);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // 스크롤 위치에 따라 화살표 표시 여부를 결정
    if (_scrollController.position.maxScrollExtent - _scrollController.offset < 50) {
      setState(() {
        _showRightArrow = false;
      });
    } else {
      setState(() {
        _showRightArrow = true;
      });
    }
  }
  Widget _buildUserInteractionButtons(BuildContext context, UserProvider userProvider) {
    return Stack(
      children: [
        SizedBox(
          height: 75.0,
          child: ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            children: [
              // 매너 평가 버튼
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: _buildButton(
                  icon: Icons.thumb_up_outlined,
                  label: '매너 평가',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MannerTemperatureScreen()),
                    );
                  },
                ),
              ),
              // 배지 정보 버튼
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: _buildButton(
                  icon: Icons.security_outlined,
                  label: '배지 정보',
                  onPressed: () {
                    // 배지 정보 화면으로 이동하는 코드 구현
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: _buildButton(
                  icon: Icons.gavel_outlined,
                  label: '신고 내역',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportListScreen()),
                    );
                  },
                ),
              ),
              // QR 코드 등록 버튼
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: _buildButtonWithCheckMark(
                  icon: Icons.qr_code,
                  label: 'QR 등록',
                  isChecked: userProvider.qrCodeUrl != null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRCodeRegistrationScreen()),
                    );
                  },
                ),
              ),
              // 학생 인증 버튼
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: _buildButtonWithCheckMark(
                  icon: Icons.school_outlined,
                  label: '학생 인증',
                  isChecked: userProvider.isStudentVerified,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentVerificationScreen()),
                    );
                  },
                ),
              ),
              // 추가 버튼들...
            ],
          ),
        ),
        if (_showRightArrow)
          const Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ),
          ),
      ],
    );
  }


  Widget _buildButtonWithCheckMark({required IconData icon, required String label, required bool isChecked, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                if (isChecked)
                  const WidgetSpan(
                    child: Icon(Icons.check, size: 18, color: Colors.grey),
                  ),
                TextSpan(
                  text: label,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
  Widget _buildInformationTile(BuildContext context) {
    // Information tile with expandable options
    return ExpansionTile(
      leading: const Icon(Icons.info_outline, color: Colors.black),
      title: const Text('이용안내'),
      children: [
        // 자주 묻는 질문 ListTile
        ListTile(
          leading: const Icon(Icons.question_answer, color: Colors.black),
          title: const Text('자주 묻는 질문'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQScreen()),
            );
          },
        ),
        // 서비스 이용 약관 ListTile
        ListTile(
          leading: const Icon(Icons.article, color: Colors.black),
          title: const Text('서비스 이용 약관'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
            );
          },
        ),
        // 개인정보 처리방침 ListTile
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: Colors.black),
          title: const Text('개인정보 처리방침'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            );
          },
        ),
        // 오픈소스 라이센스 ListTile
        ListTile(
          leading: const Icon(Icons.code, color: Colors.black),
          title: const Text('오픈소스 라이센스'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OssLicensesScreen()),
            );
          },
        ),
        // 개발자 정보 ListTile
        ListTile(
          leading: const Icon(Icons.developer_mode, color: Colors.black),
          title: const Text('개발자 정보'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DeveloperInfoScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtherOptionsTile(BuildContext context, UserProvider userProvider) {
    return ExpansionTile(
      leading: const Icon(Icons.more_horiz, color: Colors.black),
      title: const Text('기타'),
      children: [
        // 로그아웃 ListTile
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.black),
          title: const Text('로그아웃'),
          onTap: () => _showLogoutConfirmationDialog(context, userProvider),
        ),
        // 회원탈퇴 ListTile
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.black),
          title: const Text('회원탈퇴'),
          onTap: () => _showUnlinkConfirmationDialog(context, userProvider),
        ),
        // 추가적인 타일 구현 가능
      ],
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('로그아웃'),
            onPressed: () {
              userProvider.logout();
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  void _showUnlinkConfirmationDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?\n탈퇴 후에는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('탈퇴하기'),
            onPressed: () {
              userProvider.unlink();
              Navigator.of(ctx).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
