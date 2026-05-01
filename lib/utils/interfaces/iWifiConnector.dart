import 'dart:async';

import 'package:autopeepal/models/bluetoothDevices_model.dart';



abstract class IWifiConnector {
  /// Equivalent to Task<ObservableCollection<BluetoothDevicesModel>> ConnectToWifi(...)
  Future<List<BluetoothDevicesModel>> connectToWifi(String ssid, String password);
}