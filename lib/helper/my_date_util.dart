import 'package:flutter/material.dart';

class MyDateUtil {
  static String getFormattedTime({
    required BuildContext context,
    required String time,
  }) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    // Add your logic here to format the time
    return TimeOfDay.fromDateTime(date)
        .format(context); // Ensure a non-nullable String is always returned
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return '${sent.day}/${_getMonth(sent)}/${sent.year}';
  }

  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  static String getFormattedDate(String createdAt) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt));
    return '${date.day} ${_getMonth(date)} ${date.year}';
  }
}
