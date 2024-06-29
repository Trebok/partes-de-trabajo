import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:partesdetrabajo/utils.dart';

void main() {
  group('Fecha valida parte', () {
    test('Dia posterior, hora posterior', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 09, minute: 45);
      final fechaFinal = DateTime(2024, 04, 13);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, true);
    });
    test('Dia posterior, misma hora', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 09, minute: 00);
      final fechaFinal = DateTime(2024, 04, 13);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, true);
    });
    test('Dia posterior, hora anterior', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 08, minute: 15);
      final fechaFinal = DateTime(2024, 04, 13);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, true);
    });
    test('Mismo dia, hora posterior', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 10, minute: 30);
      final fechaFinal = DateTime(2024, 04, 12);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, true);
    });
    test('Mismo dia, misma hora', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 09, minute: 00);
      final fechaFinal = DateTime(2024, 04, 12);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, false);
    });

    test('Mismo dia, hora anterior', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 07, minute: 30);
      final fechaFinal = DateTime(2024, 04, 12);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, false);
    });

    test('Dia anterior, hora posterior', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 11, minute: 15);
      final fechaFinal = DateTime(2024, 04, 11);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, false);
    });
    test('Dia anterior, misma hora', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 09, minute: 00);
      final fechaFinal = DateTime(2024, 04, 11);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, false);
    });
    test('Dia anterior, hora anterior', () {
      const horaInicio = TimeOfDay(hour: 09, minute: 00);
      final fechaInicio = DateTime(2024, 04, 12);

      const horaFinal = TimeOfDay(hour: 06, minute: 45);
      final fechaFinal = DateTime(2024, 04, 11);

      final inicioMinutos = horaInicio.hour * 60 + horaInicio.minute;
      final finalMinutos = horaFinal.hour * 60 + horaFinal.minute;
      final valido = Utils.fechaValida(inicioMinutos, fechaInicio, finalMinutos, fechaFinal);
      expect(valido, false);
    });
  });
}
