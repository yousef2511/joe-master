import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:joe/widgets.dart';
import 'FlutterMap.dart';




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
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 10)),
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
      await Future.delayed(Duration(seconds: 5)); // Delay for connection
      result.device.disconnect();
      await Future.delayed(Duration(seconds: 5));

      result = scanResults.firstWhere((result) => result.device.id.id == '10:CE:A9:2E:8C:98');
      result.device.connect(autoConnect: true);
      await Future.delayed(Duration(seconds: 5));
      result.device.disconnect();

      await Future.delayed(Duration(seconds: 5));
      result = scanResults.firstWhere((result) => result.device.id.id == '58:7A:62:39:1C:CB');
      result.device.connect(autoConnect: true);
      await Future.delayed(Duration(seconds: 5));
      result.device.disconnect();


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

double  d = pow(10, ((-59 - newrsssi) / (10 * 2))).toDouble();

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  int _rssi = 0;
  // Distance from trilateration method
  StreamSubscription? _rssiSubscription;
  List<BluetoothDevice> _devices = [];


  @override
  void initState() {
    super.initState();
    _rssiSubscription = widget.device.state.listen((state) {
      if (state == BluetoothDeviceState.connected) {
        final String rssiCharacteristicUuid = "00002a19-0000-1000-8000-00805f9b34fb";
        widget.device.discoverServices().then((services) {
          services.forEach((service) {
            service.characteristics.forEach((characteristic) {
              if (characteristic.uuid.toString() == rssiCharacteristicUuid) {
                characteristic.read().then((value) {
                  setState(() {
                  });
                });
              }
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _rssiSubscription?.cancel();
  }


  // Other methods and widgets remain unchanged...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () {
                    widget.device.disconnect();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(),
                      ),
                    );
                  };
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () {
                    widget.device.connect();
                  };
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return ElevatedButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme
                        .of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('RSSI'),
              subtitle: Text('${newrsssi != 0 ? newrsssi : "N/A"} dBm'),
            ),
            ListTile(
              title: Text('Distance'),
              subtitle: Text('${d.toDouble()} meters'),
            ),
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) =>
                  ListTile(
                    leading: (snapshot.data == BluetoothDeviceState.connected)
                        ? Icon(Icons.bluetooth_connected)
                        : Icon(Icons.bluetooth_disabled),
                    title: Text(
                        'Device is ${snapshot.data.toString().split('.')[1]}.'),
                    subtitle: Text('${widget.device.name}'),
                    trailing: StreamBuilder<bool>(
                      stream: widget.device.isDiscoveringServices,
                      initialData: false,
                      builder: (c, snapshot) =>
                          IndexedStack(
                            index: snapshot.data! ? 1 : 0,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () =>
                                    widget.device.discoverServices(),
                              ),
                              IconButton(
                                icon: SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.grey),
                                  ),
                                  width: 18.0,
                                  height: 18.0,
                                ),
                                onPressed: null,
                              )
                            ],
                          ),
                    ),
                  ),
            ),
            StreamBuilder<int>(
              stream: widget.device.mtu,
              initialData: 0,
              builder: (c, snapshot) =>
                  ListTile(
                    title: Text('MTU Size'),
                    subtitle: Text('${snapshot.data} bytes'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => widget.device.requestMtu(223),
                    ),
                  ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) =>
          ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) =>
                  CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () => c.read(),
                    onWritePressed: () async {
                      await c.write(_getRandomBytes(), withoutResponse: true);
                      await c.read();
                    },
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      await c.read();
                    },
                    descriptorTiles: c.descriptors
                        .map(
                          (d) =>
                          DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                    )
                        .toList(),
                  ),
            )
                .toList(),
          ),
    )
        .toList();
  }

  void main() {
    runApp(FlutterBlueApp());
  }
}