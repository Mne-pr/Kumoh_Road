import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/announcement_model.dart';

class AddAnnouncementScreen extends StatefulWidget {
  final Announcement? initialAnnouncement;

  const AddAnnouncementScreen({Key? key, this.initialAnnouncement}) : super(key: key);

  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = '공지';
  String _title = '';
  String _content = '';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialAnnouncement != null) {
      // 수정 모드인 경우, 초기값 설정
      _type = widget.initialAnnouncement!.type;
      _title = widget.initialAnnouncement!.title;
      _content = widget.initialAnnouncement!.content;
      _date = widget.initialAnnouncement!.date;
    }
  }

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final announcement = Announcement(
        id: widget.initialAnnouncement?.id ?? '', // ID 추가
        type: _type,
        title: _title,
        content: _content,
        date: _date,
        views: widget.initialAnnouncement?.views ?? 0,
      );
      if (widget.initialAnnouncement != null) {
        // 수정 모드
        await FirebaseFirestore.instance.collection('announcements').doc(widget.initialAnnouncement!.id).update(announcement.toMap());
      } else {
        // 새로운 공지사항 작성 모드
        await FirebaseFirestore.instance.collection('announcements').add(announcement.toMap());
      }
      Navigator.pop(context, announcement); // 수정된 공지사항 객체를 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialAnnouncement == null ? '공지사항 작성' : '공지사항 수정', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _type = newValue;
                  });
                }
              },
              items: <String>['공지', '점검']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: '공지사항 종류',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _title, // 초기 제목 값 설정
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                _title = value ?? ''; // null이 아니면 제목을 저장
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '공지사항의 제목을 입력해주세요.'; // 공백만 있는 경우도 체크
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _content, // 초기 내용 값 설정
              minLines: 15,
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: '내용',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                if (value != null) {
                  _content = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '공지사항의 내용을 입력해주세요.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAnnouncement,
              child: Text(widget.initialAnnouncement == null ? '공지사항 작성' : '공지사항 수정'),
            ),
          ],
        ),
      ),
    );
  }
}
