import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/screens/main_screens/main_screen.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class PostDetailsScreen extends StatefulWidget {
  final TaxiScreenUserModel writer;
  final TaxiScreenPostModel post;
  final String collectionName;
  const PostDetailsScreen({super.key, required this.writer, required this.post, required this.collectionName});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _content = "";
  bool _bottomShowed = true;
  FocusNode inputFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    inputFocusNode.addListener(() {
      if(inputFocusNode.hasFocus){
        setState(() {
          _bottomShowed = false;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Logger log = Logger(printer: PrettyPrinter());

    return Scaffold(
          body: SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  _bottomShowed = true;
                });
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopSection(),
                    UserInfoSection(
                      nickname: widget.writer.nickname,
                      imageUrl: widget.writer.profileImageUrl,
                      age: widget.writer.age,
                      gender: widget.writer.gender,
                      mannerTemperature: widget.writer.mannerTemperature,
                    ),
                    const Divider(),
                    _buildPostContentSection(context),
                    const Divider(),
                    _buildReviewSection(context),
                    const Divider(),
                    FutureBuilder(
                      future: _buildCommentSection(context),
                      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.hasError){
                          log.e(snapshot.error);
                          log.e(snapshot.stackTrace);
                          return const Center(
                            child: Text("댓글 로딩 실패"),
                          );
                        }
                        else if (snapshot.hasData) {
                          return snapshot.data!;
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _bottomShowed
            ? _buildBottomSection(context)
            : const SizedBox(width: 0,),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
  }

  PopupMenuItem<String> menuItem(String menuText){
    return PopupMenuItem<String>(
      onTap: (){
        //todo: 신고 페이지로 이동
      },
      child: Text(menuText)
    );
  }

  Widget _buildTopSection(){
    return Stack(
      children: [
        _buildImageSection(context),
        Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                    )
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    )
                ),
                const Spacer(),
                PopupMenuButton<String>(
                    color: Colors.white,
                    itemBuilder: (context){
                      return [
                        menuItem("신고하기")
                      ];
                    })
              ],
            )),
      ],
    );
  }

  Widget imageWidget(String imageUrl, BuildContext context){
    return imageUrl.isEmpty
      ? Image.asset(
        'assets/images/default_avatar.png',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.7,
        fit: BoxFit.cover,
      )
      : Image.network(
          widget.post.imageUrl,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            return child;
          },
          loadingBuilder: (context, child, loadingProgress) {
            if(loadingProgress == null){
              return child;
            } else{
              return const Center(child: CircularProgressIndicator(),);
            }
          },
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.cover,
      );
  }

  Widget _buildImageSection(BuildContext context) {
    return imageWidget(widget.post.imageUrl, context);
  }

  Widget _buildPostContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${DateTime.now().difference(widget.post.createdTime).inMinutes}분전",
          style: const TextStyle(
            color: Colors.grey
          ),
        ),
        Text(widget.post.content),
        Text(
          "조회 ${widget.post.viewCount}회",
          style: const TextStyle(
            color: Colors.grey
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    // 매너와 언매너 리스트 합치기
    List<Map<String, dynamic>> reviewList = widget.writer.mannerList!
        .followedBy(widget.writer.unmannerList!)
        .toList();
    reviewList.sort((a, b) => b["votes"].compareTo(a["votes"]));
    List<Map<String, dynamic>> showList = reviewList.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${widget.writer.nickname}님의 택시 합승 최근 리뷰",
            style: TextStyle(fontSize: defaultFontSize * 1.2, fontWeight: FontWeight.bold),
        ),
        Text("${showList[0]['content']}"),
        Text("${showList[1]['content']}"),
        Text("${showList[2]['content']}"),
      ],
    );
  }

  Future<Widget> _buildCommentSection(BuildContext context) async {
    UserProvider user = Provider.of<UserProvider>(context);

    List<dynamic> commentList = widget.post.commentList;
    if(widget.post.commentList.length > 3){
      commentList = widget.post.commentList.sublist(widget.post.commentList.length - 3);
    }
    List<String> commentUserIdList = commentList
        .map((e) => e['user_code'] as String)
        .toList();
    List<TaxiScreenUserModel> commentUserList = await TaxiScreenUserModel.getCommentUserList(commentUserIdList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("댓글",
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2,
              fontWeight: FontWeight.bold
            )
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user.profileImageUrl!),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  focusNode: inputFocusNode,
                  decoration: const InputDecoration(
                    hintText: "댓글 작성하기",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  onSaved: (value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "내용을 입력해주세요";
                    }
                    return null;
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                Logger log = Logger(printer: PrettyPrinter());
                if(_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('댓글 저장 중..')),
                  );

                  _formKey.currentState!.save();
                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference collection = firestore.collection(widget.collectionName);
                    QuerySnapshot querySnapshot = await collection
                        .where('createdTime', isEqualTo: widget.post.createdTime)
                        .get();
                    var doc = querySnapshot.docs.first;
                    var commentList = doc['commentList'] as List<dynamic>;
                    var newComment = {
                        'user_code': user.id.toString(),
                        'comment': _content,
                        'time': DateTime.now(),
                        'enable': true
                    };
                    commentList.add(newComment);
                    await collection.doc(doc.id).update({'commentList': commentList});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('댓글 작성 완료!')),
                    );
                    FocusScope.of(context).unfocus();
                    setState(() { });
                  } on Exception catch (error) {
                    log.e(error);
                  }
                }
              },
              icon: const Icon(Icons.send),
              color: Colors.grey,
            )
        ],),
        ListView.builder(
          shrinkWrap: true,
          itemCount: commentList.length,
          itemBuilder: (context, index) {
            return commentItem(context, commentList[index] as Map<String, dynamic>, commentUserList[index]);
          },
        ),
      ],
    );
  }

  Widget commentItem(BuildContext context, Map<String, dynamic> comment, TaxiScreenUserModel user) {
    DateTime writeTime = (comment['time'] as Timestamp).toDate();
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
        ),
        Column(
          children: [
            Row(
              children: [
                Text(user.nickname),
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                  child: Text(
                    "${DateTime.now().difference(writeTime).inMinutes}분전",
                    style: const TextStyle(
                      color: Colors.grey
                    ),
                  ),
                ),
              ],
            ),
            Text(comment['comment'])
          ],
        )
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    UserProvider currUser = Provider.of<UserProvider>(context);
    return Row(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "정원 4명중 ${widget.post.memberList.length + 1}명 참여중",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "${widget.writer.gender}만 참여가능",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize!,
                  color: Colors.grey
                ),
              )
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            if(widget.writer.userId == currUser.id.toString()){
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('승객 호소인 클릭함')),
            );
          },
          child: widget.writer.userId == currUser.id.toString()
            ? const Text("합승중")
            : const Text("합승하기")
        )
      ],
    );
  }

// Widget _buildBottom(BuildContext context) {}
}
