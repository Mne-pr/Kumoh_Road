import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
/**
 * 여러 화면에서 편하게 로그를 이용한 신고 횟수를 출력할 수 있도록 한다.
 * 신고 횟수를 인자로 넘겨서 사용한다
 */
Widget ReportCountWidget(int count) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.red[100],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.report_problem,
          color: Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}