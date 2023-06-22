import 'package:intl/intl.dart';

String getCurentDay(int dayOfWeek) {
  DateTime now = DateTime.now().add(Duration(days: dayOfWeek));
  return DateFormat('EEEEE').format(now).toLowerCase();
}

bool isToday(DateTime date) {
  DateTime now = DateTime.now();
  return date.day == now.day &&
      date.month == now.month &&
      date.year == now.year;
}

bool isTomorrow(DateTime date) {
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  return date.day == tomorrow.day &&
      date.month == tomorrow.month &&
      date.year == tomorrow.year;
}

String formatDate(DateTime date) {
  if (isToday(date)) {
    return 'Today';
  } else if (isTomorrow(date)) {
    return 'Tomorrow';
  }
  return DateFormat('E d MMM').format(date);
}

String eventFormatDate(DateTime date) {
  return DateFormat('EEEE, d MMMM yyyy HH:mm').format(date);
}
