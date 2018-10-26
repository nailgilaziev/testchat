
import 'dart:math';

import 'package:flutter/material.dart';
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
const forwardSymbol = '➤';

const space = 4.0;
const space05 = space / 2;
const space2 = space * 2;
const space3 = space * 3;
const space4 = space * 4;

const black6 = Color(0x0F000000);