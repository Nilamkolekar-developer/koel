import 'dart:async';
import 'dart:typed_data';

// Assuming these models are imported from your project's model directory
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/bluetoothDevices_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/mappedPidRoot_model.dart' hide PidCode;
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';


abstract class IConnectionWifi {
  Future<bool> updateFirmware(String command);

  Future<List<BluetoothDevicesModel>> getDeviceList();

  Future<List<BluetoothDevicesModel>> enableHotspots();

  void connectDongle();

  Future<String> sendFotaCommand(String command);

  Future<String> getDongleMacID(
    String ip,
    bool isLengthFFF,
    bool isChannels,
    String channelId,
  );

  /// Combined overloads for SetDongleProperties using optional parameters
  Future<dynamic> setDongleProperties({
    String? protocolName,
    String? txHeaderTemp,
    String? rxHeaderTemp,
  });

  Future<bool> checkConnection();

  Future<List<String>> getSsidPassword();

  Future<String> getFirmware1();

  Future<String> getIpAddress();

  Future<String> writeSSIDPassword(String routerSSID, String routerPassword);

  Future<List<ReadPidResponseModel>> setRoutineValue(
    List<PidCode> pidList,
    String pidByAddrSeq,
    Uint8List actualResponse,
  );

  Future<List<MappedPidResponseModel>> readMappedPid(
    List<MappedPiCodeVariable> mappedPiCodeVariable,
  );

  // DTC Methods
  Future<ReadDtcResponseModel> readDtc(String indexKey);

  Future<String> clearDtc(
    String indexKey,
    String seedKeyIndex,
    String writePidIndex,
  );

  Future<FreezeFrameResponseModel> getFreezeFrame(
    String dtcCode,
    FreezeFrameResult frameServerResult,
    List<EnvironmentSnapshotCode> envSnapshotCodes,
  );

  Future<String> setData(String commands);

  Future<String> unlockEcu(ResultUnlock unlockData);

  // PID Methods (Combined overloads)
  Future<List<ReadPidResponseModel>> readPid({
    List<PidCode>? pidList,
    String? pidByAddrSeq,
    List<ReadParameterPid>? parameterPidList,
  });

  // Write PID
  Future<List<WriteParameterStatus>> writePid(
    String writePidIndex,
    List<WriteParameterPid> pidList,
    String pidByAddrSeq,
  );

  // Flashing
  Future<String> startECUFlashing(
    String flashJson,
    String interpreter,
    SeedkeyalgoFnIndex sklFIN,
    List<EcuMapFile> ecuMapFile,
  );

  Future<WriteParameterStatus> writeAtuatorTest(
    String writeParaIndex,
    String seedKeyIndex,
    List<Uint8List> command,
    bool isStartTest,
  );

  Future<TestRoutineResponseModel> setTestRoutineCommand(
    String seedKey,
    String writeParaIndex,
    String startCommand,
  );

  Future<TestRoutineResponseModel> requestIorTest(String requestCommand);

  Future<TestRoutineResponseModel> stopIorTest(String stopCommand);

  Future<void> startTesterPresent();

  Future<void> stopTesterPresent();

  Future<List<IvnReadDtcResponseModel>> ivnReadDtc(List<String> frameIDC);

  Future<List<ReadPidResponseModel>> ivnReadPid(List<IvnSelectedPid> ivnPidList);

  Future<double> flashingData();

  Future<double> resetPercentage();
}