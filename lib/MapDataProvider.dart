import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:joe/FlutterMap.dart';
import 'package:joe/widgets.dart';




class MapDataProvider extends ChangeNotifier {

  List<String> macAddresses = [
    'C8:FD:19:62:CC:44',
    '10:CE:A9:2E:8C:98',
    '58:7A:62:39:1C:CB'
  ];

  double d1=0;
  double d2=0;
  double d3=0;
  double rssi1=0;
  double rssi2=0;
  double rssi3=0;

  int currentIndex = 0;
  bool connecting = false;


  List<Beacon> beacons = [];


  Future<void> startConnectionLoop() async {
    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 3));

    connecting = true;
    notifyListeners();

    for (int i = 0; i < macAddresses.length; i++) {
      String macAddress = macAddresses[i];
      await connectToDevice(macAddress);
      await Future.delayed(const Duration(seconds: 2)); // Delay for 2 seconds

    }
    connecting = false;
    notifyListeners();
  }

  Future<ScanResult?> connectToDevice(String macAddress) async {
    List<ScanResult> scanResults = await FlutterBlue.instance.scanResults.first;
    try {
      ScanResult result = scanResults.firstWhere((result) => result.device.id.id == 'C8:FD:19:62:CC:44');
      result.device.connect(autoConnect: true);
      rssi1=newrsssi;
      d1 = pow(10, ((-59 - rssi1) / (10 * 2))).toDouble();
      print('rssi 1 : $rssi1');
      print('d1 : $d1');
      await Future.delayed( const Duration(seconds: 5)); // Delay for connection
      result.device.disconnect();
      await Future.delayed(const Duration(seconds: 5));

      result = scanResults.firstWhere((result) => result.device.id.id == '10:CE:A9:2E:8C:98');
      result.device.connect(autoConnect: true);
      rssi2=newrsssi;
      d2 = pow(10, ((-59 - rssi2) / (10 * 2))).toDouble();
      print('rssi 2 : $rssi2');
      print('d2 : $d2');
      await Future.delayed(const Duration(seconds: 5));
      result.device.disconnect();

      await Future.delayed(const Duration(seconds: 5));
      result = scanResults.firstWhere((result) => result.device.id.id == '58:7A:62:39:1C:CB');
      result.device.connect(autoConnect: true);
      rssi3=newrsssi;
      d3 = pow(10, ((-59 - rssi3) / (10 * 2))).toDouble();
      print('rssi 3 : $rssi3');
      print('d3 : $d3');
      await Future.delayed(const Duration(seconds: 5));
      result.device.disconnect();

      beacons = [
        Beacon(mac: "C8:FD:19:62:CC:44", x: 0, y: 0, distance: d1),
        Beacon(mac: "10:CE:A9:2E:8C:98", x: 380, y: 0, distance: d2),
        Beacon(mac: "58:7A:62:39:1C:CB", x: 200, y: 700, distance: d3),
      ];

    } catch (e) {
      print('Error occurred while finding the device: $e');
      return null;
    }
  }

  Future<void> connectToDeviceSequentially(BluetoothDevice device) async {
    connecting = true;

    ScanResult? result = await connectToDevice(device.id.id);
    if (result != null) {
      await Future.delayed(const Duration(seconds: 2)); // Delay for 2 seconds
    }

    connecting = false;
  }


}