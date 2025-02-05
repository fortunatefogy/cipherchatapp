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
}
