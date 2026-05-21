import 'package:intl/intl.dart';

extension DateUtils on DateTime {
  String get monthDay {
    return DateFormat('dd/MM').format(this);
  }
}
