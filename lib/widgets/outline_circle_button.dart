import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OutlineCircleButton extends StatelessWidget {
  final onTap;
  final radius;
  final borderSize;
  final borderColor;
  final foregroundColor;
  final child;

  OutlineCircleButton({
    super.key,
    this.onTap,
    this.borderSize = 0.5,
    this.radius = 20.0,
    this.borderColor = Colors.black,
    this.foregroundColor = Colors.white,
    this.child,
  });


  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderSize),
          color: foregroundColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              child: child??SizedBox(),
              onTap: () async {
                if(onTap != null) {
                  onTap();
                }
              }
          ),
        ),
      ),
    );
  }
}
// [출처] 플러터(Flutter) - 외각 라인 원형 버튼(Outline Circle Button) 코드|작성자 천동이