import 'dart:async';
import 'dart:typed_data';
// Assuming these models are defined elsewhere in your project
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/bluetoothDevices_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/mappedPidRoot_model.dart' hide PidCode;
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';
import 'package:autopeepal/utils/interfaces/iConnectionUsb.dart';


import 'wifi_connector.dart';


abstract class UsbConnectorService implements IConnectionUSB, Disposable {
  
  Future<bool> updateFirmware(String command);
  
  Future<List<BluetoothDevicesModel>> getDeviceList();
  
  Future<List<BluetoothDevicesModel>> enableHotspots();
  
  void connectDongle();
  
  Future<String> sendFotaCommand(String command);
  
  //Future<String> getDongleMacID(String ip, bool isLengthFFF, bool isChannels, String channelId);
  
  Future<dynamic> setDongleProperties({String? protocolName, String? rxHeaderTemp, String? txHeaderTemp});
  
  Future<void> setDonglePropertiesWithHeaders(String protocolName, String txHeaderTemp, String rxHeaderTemp);
  
  Future<bool> checkConnection();
  
  Future<List<String>> getSsidPassword();
  
  Future<String> getFirmware1();
  
  Future<String> getIpAddress();

  Future<String> writeSSIDPassword(String routerSSID, String routerPassword);
  
  Future<List<ReadPidResponseModel>> setRoutineValue(
    List<PidCode> pidList, 
    String pidByAddrSeq, 
    Uint8List actualResponse
  );

  Future<List<MappedPidResponseModel>> readMappedPid(List<MappedPiCodeVariable> mappedPiCodeVariable);

  Future<ReadDtcResponseModel> readDtc(String indexKey);
  
  Future<String> clearDtc(String indexKey, String seedKeyIndex, String writePidIndex);
  
  Future<FreezeFrameResponseModel> getFreezeFrame(
    String dtcCode, 
    FreezeFrameResult frameServerResult, 
    List<EnvironmentSnapshotCode> envSnapshotCodes
  );

  Future<String> setData(String commands);

  Future<String> unlockEcu(ResultUnlock unlockData);
  
  Future<List<ReadPidResponseModel>> readPid({
    List<ReadParameterPid>? parameterPidList,
    String? pidByAddrSeq,
    List<PidCode>? pidList,
  });

  Future<List<ReadPidResponseModel>> readPidParams(List<ReadParameterPid> pidList);
  
  Future<List<WriteParameterStatus>> writePid(
    String writePidIndex, 
    List<WriteParameterPid> pidList, 
    String pidByAddrSeq
  );

  Future<String> startECUFlashing(
    String flashJson, 
    String interpreter, 
    SeedkeyalgoFnIndex sklFIN, 
    List<EcuMapFile> ecuMapFile
  );

  Future<WriteParameterStatus> writeActuatorTest(
    String writeParaIndex, 
    String seedKeyIndex, 
    List<Uint8List> command, 
    bool isStartTest
  );

  //Future<TestRoutineResponseModel> setTestRoutineCommand(String seedKey, String writeParaIndex, String startCommand);

  Future<TestRoutineResponseModel> requestIorTest(String requestCommand);

  Future<TestRoutineResponseModel> stopIorTest(String stopCommand);

  Future<void> startTesterPresent();
  
  Future<void> stopTesterPresent();

  Future<List<IvnReadDtcResponseModel>> ivnReadDtc(List<String> frameIDC);

  Future<List<ReadPidResponseModel>> ivnReadPid(List<IvnSelectedPid> ivnPidList);

  Future<double> flashingData();
  
  Future<double> resetPercentage();

  @override
  void dispose() {
    // Implementation for cleanup
  }
}