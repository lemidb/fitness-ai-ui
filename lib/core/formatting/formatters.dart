import 'package:intl/intl.dart';

import 'units.dart';

final _date = DateFormat('EEE, MMM d');
final _dateTime = DateFormat('EEE, MMM d • HH:mm');

String formatDate(DateTime value) => _date.format(value.toLocal());

String formatDateTime(DateTime value) => _dateTime.format(value.toLocal());

String formatWeight(double kg, WeightUnit unit, {int fractionDigits = 1}) {
  return '${kgToDisplay(kg, unit).toStringAsFixed(fractionDigits)} ${unitLabel(unit)}';
}

String formatVolume(double kg, WeightUnit unit) {
  return formatWeight(kg, unit, fractionDigits: 0);
}

String initialsFrom(String? name, String email) {
  final source = (name != null && name.trim().isNotEmpty) ? name.trim() : email;
  final parts = source.split(RegExp(r'[\s@._-]+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  final list = parts.take(2).toList();
  return list.map((p) => p[0].toUpperCase()).join();
}
