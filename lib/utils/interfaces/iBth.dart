import 'dart:async';
// Assuming these models are imported from your project
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/bluetoothDevices_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';

abstract class IBth {
  Future<String> start(String name, int sleepTime, bool readAsCharArray);
  
  void cancel();
  
  List<BluetoothDevicesModel> pairedDevices();
  
  Future<bool> checkBtConnection();
  
  Future<String> getFirmware1();
  
  Future<String> getFirmware();

  /// Combined GetDongleMacID overloads using optional parameters
  Future<String> getDongleMacID({
    required bool isDisconnect,
    String? protocolName,
    int? protocolValue,
    String? txHeader,
    String? rxHeader,
  });

  /// Combined SetDongleProperties overloads
  Future<String> setDongleProperties({
    String? protocolName,
    String? txHeaderTemp,
    String? rxHeaderTemp,
  });

  Future<String> connect();
  
  Future<List<String>> getSsidPassword();
  
  Future<ReadDtcResponseModel> readDtc(String indexKey);
  
  Future<String> clearDtc(String indexKey);

  /// Combined ReadPid overloads
  /// Note: Check the type of the list to decide logic in implementation
  Future<List<ReadPidResponseModel>> readPid(List<dynamic> pidList);

  Future<List<WriteParameterStatus>> writePid(
    String writePidIndex, 
    List<WriteParameterPid> pidList,
  );

  Future<String> unlockEcu(ResultUnlock unlockData);

  void startTesterPresent();

  void stopTesterPresent();

  Future<TestRoutineResponseModel> setTestRoutineCommand(
    String seedKey, 
    String writeParaIndex, 
    String startCommand,
  );

  Future<TestRoutineResponseModel> requestIorTest(String requestCommand);

  Future<TestRoutineResponseModel> stopIorTest(String stopCommand);

  Future<String> startECUFlashing(
    String flashJson, 
    String interpreter, 
    Ecu2 ecu2, 
    SeedkeyalgoFnIndex sklFIN, 
    List<EcuMapFile> ecuMapFile,
  );

  Future<String> getDongleMacIDForTerminal(bool isDisconnect, String protocol);

  Future<List<String>> sendTerminalCommands(List<String> commands);

  Future<String> setData(String commands);

  Future<ReadPidResponseModel> setTestRoutineCommandSingle(String command);

  Future<List<IvnReadDtcResponseModel>> ivnReadDtc(List<String> frameIDC);

// Change IvnSelectedPID to IvnSelectedPid
Future<List<ReadPidResponseModel>> ivnReadPid(List<IvnSelectedPid> ivnPidList);

  Future<double> flashingData();
}