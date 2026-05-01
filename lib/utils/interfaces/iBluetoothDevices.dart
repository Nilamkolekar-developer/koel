import 'dart:async';

abstract class IBlueToothDevices {
  /// Equivalent to Task SearchBT()
  Future<void> searchBT();

  /// Equivalent to void GetDongles()
  void getDongles();

  /// Equivalent to Task EndScanning()
  Future<void> endScanning();

  /// Equivalent to bool PairDevice(...)
  bool pairDevice(String bluetoothName, String bluetoothAddress);

  /// Equivalent to bool ConnectDevice(...)
  bool connectDevice(String bluetoothName, String bluetoothAddress);

  /// Equivalent to string SendSecurityCommand(...)
  String sendSecurityCommand(String securityCommand);

  /// Equivalent to string SendDongleVersionCommand(...)
  String sendDongleVersionCommand(String securityCommand);

  /// Equivalent to string SendCommandToECU(...)
  String sendCommandToECU(String ecuCommand);
}