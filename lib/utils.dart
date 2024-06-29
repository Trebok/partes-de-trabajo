import 'package:intl/intl.dart';

class Utils {
  static formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  static formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  static bool fechaValida(
    int horaInicio,
    DateTime fechaInicio,
    int horaFinal,
    DateTime fechaFinal,
  ) {
    if (fechaInicio.isAfter(fechaFinal)) {
      return false;
    } else if (fechaInicio.isAtSameMomentAs(fechaFinal)) {
      if (horaInicio >= horaFinal) {
        return false;
      }
    }
    return true;
  }
}
