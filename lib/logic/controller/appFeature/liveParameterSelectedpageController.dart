import 'dart:async';
import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/excelStructure.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart'
    hide SnapshotRecord;
import 'package:autopeepal/models/pidLiveRecord_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/excelService.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveParameterSelectedController extends GetxController {
  final AuthApiService _services = AuthApiService();

  // Observables
  var selectedParameterList = <PidCode>[].obs;
  var isRunning = false.obs;
  var isPidRunning = false.obs;
  var startTime = false.obs;
  var recordingStart = false.obs;
  var isSavePopupVisible = false.obs;
  var fileName = "".obs;
  var recordingTimerText = "00 : 00".obs;

  // State
  SessionModel? sessionModel;
  String pidByAddrSeq = "";
  bool isRecordingSaved = false;
  bool readCompleted = true;
  bool snapshot = false;
  int j = 0;

  // Recording data
  List<PIDLiveRecord> liveRecord = [];
  List<PidLive> live = [];
  List<YAxisPointName> yAxisPoint = [];
  List<String> xAxisPoint = [];
  List<SnapshotRecord> values = [];

  // Timer
  Stopwatch stopwatch = Stopwatch();
  Timer? _recordingTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null) return;

    try {
      sessionModel = args['sessionModel'] as SessionModel?;
      pidByAddrSeq = args['pidByAddrSeq'] as String? ?? "";
      final list = args['selectedPidList'] as List<PidCode>?;
      if (list != null) selectedParameterList.value = list;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        await getPidsValue();
      });
    } catch (e) {
      debugPrint("LiveParameterSelectedController onInit error: $e");
    }
  }

  @override
  void onClose() {
    startTime.value = false;
    recordingStart.value = false;
    _recordingTimer?.cancel();
    super.onClose();
  }

  // ── 1. GET PIDs VALUE ────────────────────────────────────────────────────
  Future<void> getPidsValue() async {
    try {
      List<ReadPidResponseModel?>? result = [];

      if (App.connectedVia == "USB") {
        result = (await App.usbConnectorService!.readPid(
                  pidList: selectedParameterList,
                  pidByAddrSeq: pidByAddrSeq,
                ) )
            .cast<ReadPidResponseModel?>();
      } else {
        result = (await App.wifiConnectorService!.readPid(
                  pidList: selectedParameterList,
                  pidByAddrSeq: pidByAddrSeq,
                ))
            .cast<ReadPidResponseModel?>();
      }
      await setPidValue(result);
    } catch (e) {
      debugPrint("getPidsValue error: $e");
    }
  }

  // ── 2. SET PID VALUE ─────────────────────────────────────────────────────
  Future<void> setPidValue(List<ReadPidResponseModel?> result) async {
    if (result.isEmpty) return;

    for (var pid in result) {
      if (pid == null) continue;

      final pidList =
          selectedParameterList.firstWhereOrNull((x) => x.id == pid.pidId);
      if (pidList == null) continue;

      if (pid.status == "NOERROR") {
        for (var variable in pidList.piCodeVariable ?? []) {
          final item = pid.variables
              ?.firstWhereOrNull((x) => x.pidNumber == variable.id);
          if (item != null) {
            variable.showResolution = item.responseValue ?? "";

            if (variable.messageType == "CONTINUOUS") {
              if (variable.minVal?.isEmpty == true) {
                variable.minVal = variable.showResolution;
              }
              if (variable.maxVal?.isEmpty == true) {
                variable.maxVal = variable.showResolution;
              }

              final minVal = double.tryParse(variable.minVal ?? "");
              final maxVal = double.tryParse(variable.maxVal ?? "");
              final currVal = double.tryParse(variable.showResolution ?? "");

              if (minVal != null && maxVal != null && currVal != null) {
                variable.minVal =
                    currVal < minVal ? currVal.toString() : minVal.toString();
                variable.maxVal =
                    currVal > maxVal ? currVal.toString() : maxVal.toString();
              }
            }
          }
        }
      } else {
        for (var variable in pidList.piCodeVariable ?? []) {
          variable.showResolution = "ERR";
        }
      }
    }

    selectedParameterList.refresh();

    // Check for communication errors
    final lastPids =
        result.length >= 3 ? result.skip(result.length - 3).toList() : result;

    if (lastPids.every((x) => x?.status == "Communication Error")) {
      await _disablePlayAndRecord(true);
    } else if (result.every((x) => x?.status == "ECUERROR_NORESPONSEFROMECU")) {
      await _disablePlayAndRecord(false);
    }
  }

  // ── 3. DISABLE PLAY AND RECORD ───────────────────────────────────────────
  Future<void> _disablePlayAndRecord(bool isCommError) async {
    startTime.value = false;
    isPidRunning.value = false;

    if (recordingStart.value) {
      await pidRecordingClicked();
    }

    if (isCommError) {
      final resp = await Get.dialog<bool>(AlertDialog(
        title: const Text("Communication Error"),
        content: const Text("Do you want to reconnect?"),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Yes")),
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("No")),
        ],
      ));
      if (resp == true) {
        // ReconnectService().reconnectDongle();
      }
    }
  }

  // ── 4. PLAY / PAUSE ──────────────────────────────────────────────────────
  void pidPlayPauseClicked() {
    try {
      if (!startTime.value) {
        startTime.value = true;
        isPidRunning.value = false;

        // Start polling loop
        Future.microtask(() async {
          while (startTime.value) {
            if (!isPidRunning.value) {
              isPidRunning.value = true;
              await getPidsValue();
              isPidRunning.value = false;
            }
            await Future.delayed(const Duration(milliseconds: 10));
          }
        });
      } else {
        startTime.value = false;

        if (isPidRunning.value) {
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );
          Future.microtask(() async {
            while (isPidRunning.value) {
              await Future.delayed(const Duration(milliseconds: 50));
            }
            if (Get.isDialogOpen == true) Get.back();
          });
        }
      }
    } catch (e) {
      debugPrint("pidPlayPauseClicked error: $e");
    }
  }

  // ── 5. RECORDING ─────────────────────────────────────────────────────────
  Future<void> pidRecordingClicked() async {
    try {
      startTime.value = false;
      stopwatch = Stopwatch();

      if (!recordingStart.value) {
        stopwatch.start();
        j = 0;
        recordingStart.value = true;

        // Start timer display
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          final minutes =
              stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
          final seconds =
              (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
          recordingTimerText.value = "$minutes : $seconds";
          if (!recordingStart.value) _recordingTimer?.cancel();
        });

        // Reset min/max values
        for (var pid in selectedParameterList) {
          for (var variable in pid.piCodeVariable ?? []) {
            variable.minVal = "";
            variable.maxVal = "";
          }
        }

        _startRecording();
      } else {
        recordingStart.value = false;

        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          while (isPidRunning.value) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
          while (!readCompleted) {
            await Future.delayed(const Duration(milliseconds: 50));
          }

          stopwatch.stop();

          live.add(PidLive(
            xAxisPoint: xAxisPoint,
            yAxisPointName: yAxisPoint,
            created: DateTime.now().toUtc().toIso8601String(),
          ));

          liveRecord.add(PIDLiveRecord(
            created: DateTime.now().toUtc().toIso8601String(),
            pidLive: live,
          ));

          if (liveRecord.first.pidLive?.first.xAxisPoint?.isNotEmpty == true) {
            isRecordingSaved = false;
            final datetime =
                DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '_');
            fileName.value = "LiveRecords_$datetime";
            isSavePopupVisible.value = true;

            final connectivity = await Connectivity().checkConnectivity();
            final hasInternet = connectivity != ConnectivityResult.none;

            if (hasInternet && (sessionModel?.id ?? 0) != 0) {
              final saved = await _services.pidLiveRecord(
                  liveRecord,
                  App.jwtToken,
                  sessionModel!.id!);
              isRecordingSaved = saved;
              if (saved) {
                stopwatch.reset();
                stopwatch.stop();
              }
            } else {
              await _savePidRecordingOffline();
            }

            recordingTimerText.value = "00 : 00";
          }
        } catch (e) {
          debugPrint("Recording stop error: $e");
        } finally {
          if (Get.isDialogOpen == true) Get.back();
        }
      }
    } catch (e) {
      debugPrint("pidRecordingClicked error: $e");
    }
  }

  // ── 6. START RECORDING LOOP ──────────────────────────────────────────────
  void _startRecording() {
    liveRecord = [];
    live = [];
    yAxisPoint = [];
    xAxisPoint = [];

    Future.microtask(() async {
      try {
        while (recordingStart.value) {
          if (!isPidRunning.value) {
            j++;
            isPidRunning.value = true;
            readCompleted = false;
            await getPidsValue();
            readCompleted = true;
            isPidRunning.value = false;

            // Build Y axis data
            for (var item in List<PidCode>.from(selectedParameterList)) {
              for (var variable
                  in List<PiCodeVariable>.from(item.piCodeVariable ?? [])) {
                final pidName = "${item.code} - ${variable.shortName}";
                final existing =
                    yAxisPoint.firstWhereOrNull((x) => x.pidName == pidName);

                final displayValue = variable.showResolution?.isNotEmpty == true
                    ? variable.showResolution!
                    : "NOT FOUND";

                if (existing != null) {
                  existing.max = variable.maxVal;
                  existing.min = variable.minVal;
                  existing.value ??= [];
                  existing.value!.add(displayValue);
                } else {
                  yAxisPoint.add(YAxisPointName(
                    pidName: pidName.isNotEmpty ? pidName : "NOT FOUND",
                    unit: variable.unit,
                    min: variable.minVal,
                    max: variable.maxVal,
                    value: [displayValue],
                  ));
                }
              }
            }

            xAxisPoint.add(
              "${DateTime.now().hour.toString().padLeft(2, '0')}:"
              "${DateTime.now().minute.toString().padLeft(2, '0')}:"
              "${DateTime.now().second.toString().padLeft(2, '0')}",
            );
          }
          await Future.delayed(const Duration(milliseconds: 10));
        }
      } catch (e) {
        debugPrint("Recording loop error: $e");
      }
    });
  }

  // ── 7. SNAPSHOT ──────────────────────────────────────────────────────────
  Future<void> pidSnapshotClicked() async {
    try {
      startTime.value = false;
      recordingStart.value = false;
      snapshot = true;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(milliseconds: 200));
      await getPidsValue();

      values = [];
      for (var item in selectedParameterList) {
        for (var variable in item.piCodeVariable ?? []) {
          String code = "${item.code} - ${variable.shortName}";
          String value = variable.showResolution ?? "";

          if (code.trim().isEmpty) code = "NOT FOUND";
          if (value.trim().isEmpty) value = "NOT FOUND";

          values.add(SnapshotRecord(code: code, value: value));
        }
      }

      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet = connectivity != ConnectivityResult.none;

      if (Get.isDialogOpen == true) Get.back();

      if (hasInternet && (sessionModel?.id ?? 0) != 0) {
        final saved = await _services.pidSnapshotRecord(
          values,
          App.jwtToken,
          sessionModel!.id!,
          DateTime.now().toUtc().toIso8601String(),
        );
        Get.snackbar(
          saved ? "SUCCESS" : "ERROR",
          saved
              ? "Snapshot Saved Successfully"
              : "Snapshot Not Saved Successfully",
        );
      } else {
        await _savePidSnapshotOffline();
      }

      snapshot = false;
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      debugPrint("pidSnapshotClicked error: $e");
    }
  }

  // ── 8. SAVE FILE ─────────────────────────────────────────────────────────
  // Future<void> saveFile() async {
  //   try {
  //     if (fileName.value.trim().isEmpty) {
  //       Get.snackbar("Error", "Please enter file name.");
  //       return;
  //     }

  //     Get.dialog(
  //       const Center(child: CircularProgressIndicator()),
  //       barrierDismissible: false,
  //     );

  //     // Excel generation logic goes here using your ExcelService equivalent
  //     // Pass liveRecord data to build the spreadsheet

  //     if (isRecordingSaved) {
  //       Get.snackbar("SUCCESS", "Recording Saved Successfully");
  //     }

  //     isSavePopupVisible.value = false;
  //   } catch (e) {
  //     isSavePopupVisible.value = false;
  //     debugPrint("saveFile error: $e");
  //   } finally {
  //     if (Get.isDialogOpen == true) Get.back();
  //   }
  // }

  Future<void> saveFile() async {
  if (fileName.value.trim().isEmpty) {
    Get.snackbar("Error", "Please enter file name.");
    return;
  }

  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    await Future.delayed(const Duration(milliseconds: 50));

    final excelService = ExcelServiceWindows();

    // 1. Generate the Excel file
    final filePath = await excelService.generateExcel("${fileName.value}.xlsx");

    if (filePath[0] != "true") {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar("Error", filePath[1]);
      return;
    }

    // 2. Build ExcelStructure exactly like C#
    final data = ExcelStructure(
      headers: ["SR Number", sessionModel?.srNumber ?? ""],
      values: [],
    );

    List<int> maxCountList = [];

    // 3. Loop through LiveRecord → PidLive → YAxisPointName (mirrors C# nested foreach)
    for (var record in liveRecord) {
      for (var pidLive in record.pidLive ?? []) {

        // Row 1: PID names header row
        List<String> pidNameList = [];
        for (var yAxis in pidLive.yAxisPointName ?? []) {
          pidNameList.add(yAxis.pidName ?? "");
          maxCountList.add(yAxis.value?.length ?? 0);
        }
        data.values.add(pidNameList);

        // Find max data point count across all PIDs
        int maxNumber = maxCountList.isNotEmpty
            ? maxCountList.reduce((a, b) => a > b ? a : b)
            : 0;

        // Rows 2..N: one row per time point
        for (int i = 0; i < maxNumber; i++) {
          List<String> rowValues = [];
          for (var yAxis in pidLive.yAxisPointName ?? []) {
            try {
              if (yAxis.value != null && i < yAxis.value!.length) {
                rowValues.add(yAxis.value![i]);
              } else {
                rowValues.add("");
              }
            } catch (_) {
              rowValues.add("");
            }
          }
          data.values.add(rowValues);
        }
      }
    }

    // 4. Write data into the sheet
    await excelService.insertDataIntoSheet(
      filePath[1],
      "Analyze Records",
      data,
    );

    isSavePopupVisible.value = false;
    if (Get.isDialogOpen == true) Get.back();

    if (isRecordingSaved) {
      Get.snackbar("SUCCESS", "Recording Saved Successfully");
    }

  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    isSavePopupVisible.value = false;
    debugPrint("saveFile error: $e");
    Get.snackbar("Error", "Failed to save file: $e");
  }
}

  // ── HELPER: Save offline ─────────────────────────────────────────────────
  Future<void> _savePidRecordingOffline() async {
    try {
      const key = "OfflineAnalyze_PidRecording";
      final existing = await AndroidOperationsService.getData(key);
      List<PidRecordingOfflineAnalyze> data = [];

      if (existing != null && existing.isNotEmpty) {
        data = (jsonDecode(existing) as List)
            .map((e) => PidRecordingOfflineAnalyze.fromJson(e))
            .toList();
      }

      data.add(PidRecordingOfflineAnalyze(
        type: "pid_recording",
        // liveRecord: liveRecord,
        srnId: sessionModel?.id,
        srNumber: sessionModel?.srNumber,
      ));

      await AndroidOperationsService.saveData(key, jsonEncode(data));
    } catch (e) {
      debugPrint("_savePidRecordingOffline error: $e");
    }
  }

  Future<void> _savePidSnapshotOffline() async {
    try {
      const key = "OfflineAnalyze_PidSnapshot";
      final existing = await AndroidOperationsService.getData(key);
      List<PidSnapshotOfflineAnalyze> data = [];

      if (existing != null && existing.isNotEmpty) {
        data = (jsonDecode(existing) as List)
            .map((e) => PidSnapshotOfflineAnalyze.fromJson(e))
            .toList();
      }

      data.add(PidSnapshotOfflineAnalyze(
        type: "pid_snapshot",
        // snapshotData: values,
        srnId: sessionModel?.id,
        srNumber: sessionModel?.srNumber,
        datetime: DateTime.now().toUtc().toIso8601String(),
      ));

      await AndroidOperationsService.saveData(key, jsonEncode(data));
    } catch (e) {
      Get.snackbar("Error", e.toString());
      debugPrint("_savePidSnapshotOffline error: $e");
    }
  }
}
