import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  String stripZeros(String str) {
    return str.replaceAll(RegExp(r'\.?0*$'), '');
  }

  if (amount >= 1000000000) {
    return '${stripZeros((amount / 1000000000).toStringAsFixed(3))} مليار';
  } else if (amount >= 1000000) {
    return '${stripZeros((amount / 1000000).toStringAsFixed(3))} مليون';
  } else if (amount >= 10000) {
    return '${stripZeros((amount / 1000).toStringAsFixed(2))} ألف';
  } else {
    return NumberFormat('#,##0.##').format(amount);
  }
}
