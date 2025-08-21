import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {

  static String formatDate(String dateFromMySQL) {
    final DateTime parsedDate = DateTime.parse(dateFromMySQL);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(parsedDate);

    if (difference.inMinutes < 360) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 6) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('yy-MM-dd').format(parsedDate);
    }
  }

  static Widget formatDateCommentIcon(String dateFromMySQL,{
    required double iconSize, // 아이콘 크기
    required double textSize, // 텍스트 크기
    required Color textColor, // 기본 텍스트 색상
  }) {
    final DateTime parsedDate = DateTime.parse(dateFromMySQL);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(parsedDate);

    String formattedText;
    Icon? notificationIcon;
    print('differencedifferencedifferencedifference : $difference ');

    if (difference.inMinutes < 60) {
      formattedText = "방금 전";
      notificationIcon = Icon(Icons.notifications_active, color: Colors.red.shade400, size: iconSize); // 최근 댓글일 때 빨간색 아이콘
    } else if (difference.inMinutes < 240) {
      formattedText = "${difference.inMinutes}분 전";
      notificationIcon = Icon(Icons.notifications_active, color: Colors.orange, size: iconSize); // 1시간 이내 댓글일 때 주황색 아이콘
    } else if (difference.inHours < 24) {
      formattedText = "${difference.inHours}시간 전";
      notificationIcon = Icon(Icons.notifications_active, color: Colors.blue.shade700, size: iconSize); // 6시간 이내 댓글일 때 파란색 아이콘
    } else {
      formattedText = DateFormat('yy-MM-dd HH:mm').format(parsedDate);
      notificationIcon = null; // 6시간이 지나면 아이콘 표시 안 함
      // notificationIcon = Icon(Icons.notifications_active, color: Colors.orange, size: iconSize); // 6시간 이내 댓글일 때 파란색 아이콘
    }

    return Row(
      children: [
        if (notificationIcon != null) ...[
          notificationIcon,
          // Icon(Icons.notifications_active, color: Colors.orange, size: 10), // 조건에 따라 아이콘 추가
          // SizedBox(width: 10),
        ],
        // Icon(Icons.notifications_active, color: Colors.orange, size: 14),
        Text(formattedText,
        style: TextStyle(color: textColor, fontSize: textSize)),
      ],
    );
  }
}