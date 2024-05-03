import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:joe/widgets.dart';// Import the collection package
import 'FlutterMap.dart';


double d1=0;
double d2=0;
double d3=0;
double rssi1=0;
double rssi2=0;
double rssi3=0;

class FlutterBlueApp extends StatefulWidget {
  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return FindDevicesScreen();
          }
          return BluetoothOffScreen(state: state);
        },
      ),
    );
  }
}

class BluetoothOffScreen extends StatefulWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  State<BluetoothOffScreen> createState() => _BluetoothOffScreenState();
}

class _BluetoothOffScreenState extends State<BluetoothOffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${widget.state != null ? widget.state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  List<String> macAddresses = [
    'C8:FD:19:62:CC:44',
    '10:CE:A9:2E:8C:98',
    '58:7A:62:39:1C:CB'
  ];

  int _currentIndex = 0;
  bool _connecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 5)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Existing StreamBuilder for connected devices
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Column(
                      children: snapshot.data!
                          .map(
                            (r) =>
                            ScanResultTile(
                              result: r,
                              onTap: () async {
                                if (macAddresses.contains(r.device.id.id)) {
                                  _connectToDeviceSequentially(r.device);
                                } else {
                                  print('Connection to ${r.device.id.id} rejected.');
                                }
                              },
                            ),
                      )
                          .toList(),
                    );
                  } else {
                    return Text('No available devices.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: _connecting ? CircularProgressIndicator() : Icon(Icons.search),
        onPressed: _connecting ? null : () => _startConnectionLoop(),
      ),
    );
  }

  Future<void> _startConnectionLoop() async {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 3));
    setState(() {
      _connecting = true;
    });

    for (int i = 0; i < macAddresses.length; i++) {
      String macAddress = macAddresses[i];
      await _connectToDevice(macAddress);
      await Future.delayed(Duration(seconds: 2)); // Delay for 2 seconds

    }

    setState(() {
      _connecting = false;
    });
  }

  Future<ScanResult?> _connectToDevice(String macAddress) async {
    List<ScanResult> scanResults = await FlutterBlue.instance.scanResults.first;
    try {
      ScanResult result = scanResults.firstWhere((result) => result.device.id.id == 'C8:FD:19:62:CC:44');
      result.device.connect(autoConnect: true);
      rssi1=newrsssi;
       d1 = pow(10, ((-59 - rssi1) / (10 * 2))).toDouble();
       print('rssi 1 : $rssi1');
       print('d1 : $d1');
      await Future.delayed(Duration(seconds: 5)); // Delay for connection
      result.device.disconnect();
      await Future.delayed(Duration(seconds: 5));

      result = scanResults.firstWhere((result) => result.device.id.id == '10:CE:A9:2E:8C:98');
      result.device.connect(autoConnect: true);
      rssi2=newrsssi;
       d2 = pow(10, ((-59 - rssi2) / (10 * 2))).toDouble();
      print('rssi 2 : $rssi2');
      print('d2 : $d2');
      await Future.delayed(Duration(seconds: 5));
      result.device.disconnect();

      await Future.delayed(Duration(seconds: 5));
      result = scanResults.firstWhere((result) => result.device.id.id == '58:7A:62:39:1C:CB');
      result.device.connect(autoConnect: true);
      rssi3=newrsssi;
       d3 = pow(10, ((-59 - rssi3) / (10 * 2))).toDouble();
      print('rssi 3 : $rssi3');
      print('d3 : $d3');
      await Future.delayed(Duration(seconds: 5));
      result.device.disconnect();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
          ),
        ),
      );

      return result;
    } catch (e) {
      print('Error occurred while finding the device: $e');
      return null;
    }
  }

  Future<void> _connectToDeviceSequentially(BluetoothDevice device) async {
    setState(() {
      _connecting = true;
    });

    ScanResult? result = await _connectToDevice(device.id.id);
    if (result != null) {
      await Future.delayed(Duration(seconds: 2)); // Delay for 2 seconds
    }

    setState(() {
      _connecting = false;
    });
  }
}

