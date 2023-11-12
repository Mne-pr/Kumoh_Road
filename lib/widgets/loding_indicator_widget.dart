import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
/**
 * 여러 화면에서 편하게 로딩 화면을 사용하도록 한다.
 * _isLoading 변수를 통해 제어한다.
 */
class LoadingIndicatorWidget extends StatefulWidget {
  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicatorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform.rotate(
          angle: _animationController.value * 2 * pi,
          child: child,
        );
      },
      child: Image.asset('assets/images/app_logo.png', width: 100, height: 100),
    );
  }
}
