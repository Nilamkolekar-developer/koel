import 'dart:async';
import 'package:bonsoir/bonsoir.dart';

class BluetoothDevicesModel {
  String? name;
  String? ip;
  String? macAddress;
 

  BluetoothDevicesModel({
    this.name,
    this.ip,
    this.macAddress,
   
  });

  // JSON -> Object
  factory BluetoothDevicesModel.fromJson(Map<String, dynamic> json) {
    return BluetoothDevicesModel(
      name: json['Name'],
      ip: json['Ip'],
      macAddress: json['Mac_Address'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Ip': ip,
      'Mac_Address': macAddress,
    };
  }
}


/// 1. THE SERVICE CLASS
class MdnsDiscoveryService {
  final String serviceType;
  final StreamController<BluetoothDevicesModel> _discoveredStreamController =
      StreamController.broadcast();
  final StreamController<BluetoothDevicesModel> _deviceOfflineStreamController =
      StreamController.broadcast();

  final Set<String> _discoveredHosts = {}; 
  BonsoirDiscovery? _discovery;
  StreamSubscription? _eventSub;

  MdnsDiscoveryService({this.serviceType = '_http._tcp'});

  Stream<BluetoothDevicesModel> get discoveredServices =>
      _discoveredStreamController.stream;

  Stream<BluetoothDevicesModel> get deviceOffline =>
      _deviceOfflineStreamController.stream;

  Future<void> startDiscovery() async {
    await stopDiscovery();
    _discovery = BonsoirDiscovery(type: serviceType);
    await _discovery!.initialize();

    _eventSub = _discovery!.eventStream!.listen((event) {
      if (!(_discoveredStreamController.isClosed)) {
        scheduleMicrotask(() => _handleEvent(event));
      }
    });
    await _discovery!.start();
  }

  void _handleEvent(BonsoirDiscoveryEvent event) {
    if (event is BonsoirDiscoveryServiceFoundEvent) {
      event.service.resolve(_discovery!.serviceResolver);
    }

    if (event is BonsoirDiscoveryServiceResolvedEvent ||
        event is BonsoirDiscoveryServiceUpdatedEvent) {
      final service = event.service;
      if (service == null) return;

      final id = '${service.host}:${service.port}';

      if (!_discoveredHosts.contains(id)) {
        _discoveredHosts.add(id);

        // Uses the class defined below in the same file
        final discovered = BluetoothDevicesModel(
          name: service.name,
          ip: service.host,
          macAddress: '',
        );

        _discoveredStreamController.add(discovered);
        print('[mDNS] Discovered: ${discovered.name}');
      }
    }

    if (event is BonsoirDiscoveryServiceLostEvent) {
      final service = event.service;
      final id = '${service.host}:${service.port}';
      _discoveredHosts.remove(id);

      final removed = BluetoothDevicesModel(
        name: service.name,
        ip: service.host,
        macAddress: '',
      );

      _deviceOfflineStreamController.add(removed);
    }
  }

  Future<void> stopDiscovery() async {
    try {
      await _eventSub?.cancel();
      _eventSub = null;
      if (_discovery != null) {
        await _discovery!.stop();
        _discovery = null;
      }
      _discoveredHosts.clear();
    } catch (e) {
      print("Error stopping discovery: $e");
    }
  }

  Future<void> dispose() async {
    await stopDiscovery();
    await _discoveredStreamController.close();
    await _deviceOfflineStreamController.close();
  }
}

