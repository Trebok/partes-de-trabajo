import 'package:intl/intl.dart';

class Utils {
  static formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  static formatTime(DateTime date) => DateFormat('HH:mm').format(date);
}