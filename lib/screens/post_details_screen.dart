import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/main_screen.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? writerDetails;
  PostDetailsScreen({
    super.key,
    required this.writerDetails,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    String writerName = widget.writerDetails!['nickname'] ?? "이름 없음";
    String writerImageUrl = widget.writerDetails!['profileImageUrl'] ?? "assets/images/default_avatar.png";
    int writerAge = widget.writerDetails!['age'] ?? 20;
    String writerGender = widget.writerDetails!['gender'] ?? "성별 없음";
    double mannerTemperature = widget.writerDetails!['mannerTemperature'] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildButtonSection(context),
            // _buildImageSection(context),
            UserInfoSection(
              nickname: writerName,
              imageUrl: writerImageUrl,
              age: writerAge,
              gender: writerGender,
              mannerTemperature: mannerTemperature,
            ),
            // _buildPostContentSection(context),
            // _buildViewCountSection(context)
            // _buildReviews(context),
            // _buildComments(context),
            // _buildBottom(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(onPressed: (){ Navigator.of(context).pop(); }, icon: const Icon(Icons.arrow_back_ios_outlined)),
        IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MainScreen(),
            ),
          );
        }, icon: const Icon(Icons.home_outlined)),
      ],
    );
  }

  // Widget _buildImageWidget(BuildContext context) {
  //   return AspectRatio(
  //     aspectRatio: 1,
  //     child: Padding(
  //       padding: const EdgeInsets.all(10),
  //       child: ClipRRect(
  //         borderRadius: const BorderRadius.all(Radius.circular(3)),
  //         child: Image.network(
  //           documents[index]["image"],
  //           width: imgHeight,
  //           fit: BoxFit.cover,
  //           errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
  //             return Image.asset(
  //               'assets/images/default_avatar.png',
  //               width: imgHeight,
  //               fit: BoxFit.cover,
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   ),
  // }
  //
  // Widget _buildUserInformation(BuildContext context) {}
  //
  // Widget _buildPost(BuildContext context) {}
  //
  // Widget _buildReviews(BuildContext context) {}
  //
  // Widget _buildComments(BuildContext context) {}
  //
  // Widget _buildBottom(BuildContext context) {}
}