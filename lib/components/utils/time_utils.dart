// Crear un nuevo archivo lib/utils/time_utils.dart
// este archivo esta ubicado en lib/components/utils/time_utils.dart
import 'package:flutter/material.dart';

class TimeUtils {
  // Offset de tiempo manual para corregir la diferencia de zona horaria
  // Ajusta este valor según sea necesario (6 horas = 6 * 60 * 60 * 1000 ms)
  static const int manualOffsetMs = 12 * 60 * 60 * 1000; // 12 horas

  // Formatear tiempo con AM/PM y ajuste de zona horaria
  static String formatTimeWithAmPm(DateTime? dateTime) {
    if (dateTime == null) {
      return formatTimeWithAmPm(DateTime.now());
    }

    // Aplicar ajuste manual
    final adjustedDate = DateTime.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch + manualOffsetMs);

    // Formatear en 12 horas con AM/PM
    String amPm = adjustedDate.hour >= 12 ? 'PM' : 'AM';
    int hour =
        adjustedDate.hour > 12 ? adjustedDate.hour - 12 : adjustedDate.hour;
    hour = hour == 0 ? 12 : hour;

    return '${hour}:${adjustedDate.minute.toString().padLeft(2, '0')} $amPm';
  }

  // Versión alternativa que usa la zona horaria local del dispositivo
  static String formatLocalTimeWithAmPm(DateTime? dateTime) {
    if (dateTime == null) {
      return formatLocalTimeWithAmPm(DateTime.now());
    }

    // Asegurar que estamos en zona horaria local
    final localDate = dateTime.toLocal();

    // Formatear en 12 horas con AM/PM
    String amPm = localDate.hour >= 12 ? 'PM' : 'AM';
    int hour = localDate.hour > 12 ? localDate.hour - 12 : localDate.hour;
    hour = hour == 0 ? 12 : hour;

    return '${hour}:${localDate.minute.toString().padLeft(2, '0')} $amPm';
  }

  // Formatear solo para depuración
  static String debugTimeInfo(DateTime dateTime) {
    return 'Original: ${dateTime.toString()}\n'
        'ToLocal: ${dateTime.toLocal().toString()}\n'
        'AM/PM: ${formatLocalTimeWithAmPm(dateTime)}\n'
        'Manual Adjust: ${formatTimeWithAmPm(dateTime)}';
  }
}
