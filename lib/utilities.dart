
import 'dart:math';

import 'package:intl/intl.dart';

var rnd = Random();

bool p(int percent) => rnd.nextInt(100) > percent;

var timeFormatter = DateFormat.Hm();

String dayFormat(DateTime dateTime) {
  int d = dateTime.day;
  int m = dateTime.month;
  return '${d < 10 ? '0$d' : '$d'}/${m < 10 ? '0$m' : '$m'}';
}

bool daysDiffer(DateTime a, DateTime b) {
  if (a.day != b.day)
    return true;
  else if (a.month != b.month)
    return true;
  else if (a.year != b.year)
    return true;
  else
    return false;
}

const transferSymbol = '➥';