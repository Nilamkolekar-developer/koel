import 'dart:async';
import 'dart:typed_data';
import 'package:ap_dongle_diagnostic_core/model/freezeFrameModel.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart'
    hide FreezeFrameResponseModel;
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/mappedPidRoot_model.dart' hide PidCode;
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';

abstract class IConnectionUSB {
  Future<void> cancel();

  Future<bool> writeSSID(String routerSSID);

  Future<bool> writePassword(String routerPassword);

  Future<String> getDongleMacID(
    bool isLengthFFF,
    bool isChannels,
    String channelId,
    bool isObdCharger,
  );

  /// Combined overloads for SetDongleProperties
  Future<dynamic> setDongleProperties({
    String? protocolName,
    String? txHeaderTemp,
    String? rxHeaderTemp,
  });

  Future<void> disconnectUSB();

  Future<ReadDtcResponseModel?> readDtc(String indexKey);

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

  Future<String> unlockEcu(ResultUnlock unlockData);

  /// Combined overloads for ReadPid
  Future<List<ReadPidResponseModel?>> readPid({
    List<PidCode>? pidList,
    String? pidByAddrSeq,
    List<ReadParameterPid>? parameterPidList,
  });

  Future<List<ReadPidResponseModel>> setRoutineValue(
    List<PidCode> pidList,
    String pidByAddrSeq,
    Uint8List actualResponse,
  );

  Future<List<MappedPidResponseModel>> readMappedPid(
    List<MappedPiCodeVariable> mappedPiCodeVariable,
  );

  Future<List<WriteParameterStatus>> writePid(
    String writePidIndex,
    List<WriteParameterPid> pidList,
    String pidByAddrSeq,
  );

  Future<String> startECUFlashing(
    String flashJson,
    String interpreter,
    SeedkeyalgoFnIndex sklFIN,
    List<EcuMapFile> ecuMapFile,
  );

  Future<void> txHeader(String txHeader);

  Future<void> rxHeader(String rxHeader);

  Future<List<String>> sendTerminalCommands(List<String> commands);

  Future<String> setData(String commands);

  Future<WriteParameterStatus> writeAtuatorTest(
    String writeParaIndex,
    String seedKeyIndex,
    List<Uint8List> command,
    bool isStartTest,
  );

  /// Combined overloads for SetTestRoutineCommand
  Future<TestRoutineResponseModel?> setTestRoutineCommand({
    required String seedKey,
    required String writeParaIndex,
    required String startCommand,
    String? requestCommand,
    String? stopCommand,
    bool? testCondition,
    int? bitPosition,
    List<String>? activeCommand,
    String? stoppedCommand,
    String? failCommand,
    bool? isStop,
    int? timeBase,
  });

  Future<TestRoutineResponseModel?> continueIorTest(
    String seedKey,
    String writeParaIndex,
    String startCommand,
    String requestCommand,
    String stopCommand,
    bool testCondition,
    int bitPosition,
    List<String> activeCommand,
    String stoppedCommand,
    String failCommand,
    bool isStop,
    int timeBase,
    bool isTimebase,
  );

  Future<void> startTesterPresent();

  Future<void> stopTesterPresent();

  Future<TestRoutineResponseModel?> requestIorTest(String requestCommand);

// Change this in IConnectionUSB.dart
Future<TestRoutineResponseModel?> stopIorTest(String stopCommand);
// Add the '?' to the return type to match your implementation
Future<List<IvnReadDtcResponseModel>?> ivnReadDtc(List<String> frameIDC);

// Added '?' to make it nullable to match the implementation logic
// Update your interface to this:
Future<List<ReadPidPresponseModel>?> ivnReadPid(List<IvnSelectedPid> ivnPidList);

  Future<double> flashingData();

  Future<double> resetPercentage();
}
