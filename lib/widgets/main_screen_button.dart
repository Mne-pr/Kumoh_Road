import 'package:flutter/material.dart';

class MainScreenButton extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;
  final void Function()? onTap;

  const MainScreenButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
            margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: const Alignment(1.00, 0.00),
            end: const Alignment(-1, 0),
            colors: [Colors.black.withOpacity(0.7), color],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Row(
          children: <Widget>[
            Image.asset(icon),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
