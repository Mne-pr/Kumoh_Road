import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widgets/loding_indicator_widget.dart';

class LoadingScreen extends StatefulWidget {
  final int miliTime;
  final bool limitTime;
  final double opacity;
  LoadingScreen({required this.limitTime, this.miliTime = 1000, this.opacity= 1.0});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loading();
  }

  void loading() {
    if (widget.limitTime){
      Timer(Duration(milliseconds: widget.miliTime), () {
        setState(() {isLoading = false;});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoading,
      child: Container(
        color: Colors.white.withOpacity(widget.opacity),
        child: Center( child: LoadingIndicatorWidget(),),
      ),
    );
  }

}
