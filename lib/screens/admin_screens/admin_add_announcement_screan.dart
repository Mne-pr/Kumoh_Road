import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/announcement_model.dart';

class AddAnnouncementScreen extends StatefulWidget {
  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = '공지';
  String _title = '';
  String _content = '';
  final DateTime _date = DateTime.now();

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final announcement = Announcement(
        type: _type,
        title: _title,
        content: _content,
        date: _date,
        views: 0,
      );
      FirebaseFirestore.instance.collection('announcements').add(announcement.toMap());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항 작성', style: TextStyle(color: Colors.black)),
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
              child: const Text('공지사항 작성'),
            ),
          ],
        ),
      ),
    );
  }
}
