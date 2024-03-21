
import 'dart:js';
import 'dart:ui';
import 'package:f2/FlutterMap.dart';
import 'dart:math';
import 'package:f2/newB.dart';
import 'package:flutter/cupertino.dart';

Position? calculateCurrentPosition(Offset tapPosition) {
  List<Beacon> availableBeacons = beacons.where((beacon) =>
  beacon.distance != null).toList();
  if (availableBeacons.length < 3) {
    return null; // Not enough beacons to perform trilateration
  }

  double x1 = beacons[0].x;
  double y1 = beacons[0].y;
  double x2 = beacons[1].x;
  double y2 = beacons[1].y;
  double x3 = beacons[2].x;
  double y3 = beacons[2].y;

  double d1 = beacons[0].distance!;
  double d2 = beacons[1].distance!;
  double d3 = beacons[2].distance!;

  double A = x2 - x1;
  double B = y2 - y1;
  double C = x3 - x1;
  double D = y3 - y1;
  double E = ((d1 * d1) - (d2 * d2) - (x1 * x1) + (x2 * x2) - (y1 * y1) + (y2 * y2));
  double F = ((d1 * d1) - (d3 * d3) - (x1 * x1) + (x3 * x3) - (y1 * y1) + (y3 * y3));

  double denominator = (2 * ((A * D) - (B * C)));
  double x = ((D * E) - (B * F)) / denominator;
  double y = ((A * F) - (C * E)) / denominator;

  if (x < 0 || x > MediaQuery.of(context as BuildContext).size.width ||
      y < 0 || y > MediaQuery.of(context as BuildContext).size.height) {
    return null; // The calculated position is out of bounds
  }

  return Position(x: x, y: y);
}
