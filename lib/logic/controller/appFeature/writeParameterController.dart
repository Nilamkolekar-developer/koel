import 'dart:convert';
import 'dart:typed_data';
import 'package:ap_dongle_diagnostic_core/model/writeParameterPidModel.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/pidByAddrReqLocal_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/writeParameter_model.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WriteParameterController extends GetxController {
  final AuthApiService _services = AuthApiService();

  // Observables
  var ecusList = <EcuModel>[].obs;
  var pidList = <PidCode>[].obs;

  var staticPidList = <PidCode>[].obs;
  var selectedEcu = Rxn<EcuModel>();
  var selectedPid = Rxn<PiCodeVariable>();
  var selectedPidList = Rxn<PidCode>();
  var isEnumVisible = false.obs;
  var listHeight = 0.0.obs;
  var newValue = "".obs;
  var title = "Select a parameter to write".obs;
  var pidViewVisible = false.obs;
  var isRunning = false.obs;

  // ✅ FIX 1: Added missing searchKey observable
  var searchKey = "".obs;

  var sessionModel = Rxn<SessionModel>();
  ModelResult? vehicleModels;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args == null) {
      debugPrint("⚠️ WriteParameterController: No arguments received");
      return;
    }

    try {
      sessionModel.value = args['sessionModel'] as SessionModel?;
      vehicleModels = args['vehicleModels'] as ModelResult?;

      debugPrint("✅ sessionModel: ${sessionModel.value?.id}");
      debugPrint("✅ vehicleModels: ${vehicleModels?.id}");

      if (sessionModel.value == null || vehicleModels == null) {
        debugPrint("⚠️ Required data missing");
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        getPidList();
      });
    } catch (e) {
      debugPrint("🔥 WriteParameterController onInit error: $e");
    }

    // ✅ FIX 2: Filter pidList whenever searchKey changes
    ever(searchKey, (_) => _filterPidList());
  }

  // ── SEARCH FILTER ────────────────────────────────────────────────────────
  void _filterPidList() {
    final key = searchKey.value.trim().toLowerCase();
    if (key.isEmpty) {
      pidList.value = List<PidCode>.from(staticPidList);
    } else {
      pidList.value = staticPidList
          .where((p) => (p.code ?? "").toLowerCase().contains(key))
          .toList();
    }
  }

  // ✅ FIX 3: Added missing popup methods
  void showPidPopup() {
    pidViewVisible.value = true;
  }

  void closePopupClicked() {
    pidViewVisible.value = false;
  }

  // ✅ FIX 4: Alias used by the UI's write button
  Future<void> btnWriteClicked() => writeParameter();

  // ✅ FIX 5: Alias used by the PID popup list tap
  Future<void> selectPidClicked(PidCode pid) async {
    final firstVar = pid.piCodeVariable?.firstOrNull;
    if (firstVar != null) {
      await selectPid(firstVar);
    }
  }

  // ── 1. GET PID LIST ──────────────────────────────────────────────────────
  Future<void> getPidList() async {
    isRunning.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final pidByAddrSeqStr =
          await AndroidOperationsService.getData("PidByAddrSeqData");
      List<PidByAddrSeqLocalModel> pidByAddrSeqList = [];
      if (pidByAddrSeqStr != null && pidByAddrSeqStr.isNotEmpty) {
        pidByAddrSeqList = (jsonDecode(pidByAddrSeqStr) as List)
            .map((e) => PidByAddrSeqLocalModel.fromJson(e))
            .toList();
      }

      ecusList.clear();
      int count = 0;

      for (var ecu in StaticData.ecuInfo) {
        count++;
        Ecu modelEcu = Ecu();

        final subModel = vehicleModels?.subModels
            ?.firstWhereOrNull((x) => x.id == App.subModelId);
        if (subModel != null) {
          final found =
              subModel.ecus?.firstWhereOrNull((x) => x.id == ecu.ecuId);
          if (found != null) modelEcu = found;
        }

        final pidByAddr = pidByAddrSeqList
                .firstWhereOrNull((x) => x.ecuId == ecu.ecuId)
                ?.pidByAddrFsq ??
            "";

        ecusList.add(EcuModel(
          pidByAddrSeq: pidByAddr,
          ecuName: ecu.ecuName,
          opacity: count == 1 ? 1.0 : 0.5,
          pidList: ecu.pidList
                  ?.where((y) => y.write == true && y.isActive == true)
                  .toList() ??
              [],
          protocol: modelEcu.protocol,
          txHeader: modelEcu.txHeader ?? "",
          rxHeader: modelEcu.rxHeader ?? "",
        ));
      }

      if (ecusList.isNotEmpty) {
        staticPidList.value =
            pidList.value = List<PidCode>.from(ecusList.first.pidList ?? []);
        selectedEcu.value = ecusList.first;
        await setDongleProperties();
      }
    } catch (e) {
      debugPrint("getPidList error: $e");
    } finally {
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 2. GET PIDs VALUE ────────────────────────────────────────────────────
  Future<void> getPidsValue() async {
    try {
      if (selectedPidList.value == null) return;

      List<ReadPidResponseModel?>? result = [];

      if (App.connectedVia == "USB") {
        result = await App.usbConnectorService!.readPid(
          pidList: [selectedPidList.value!],
          pidByAddrSeq: selectedEcu.value?.pidByAddrSeq ?? "",
        );
      } else if (App.connectedVia == "WIFI") {
        result = (await App.wifiConnectorService!.readPid(
                  pidList: [selectedPidList.value!],
                  pidByAddrSeq: selectedEcu.value?.pidByAddrSeq ?? "",
                ))
            .cast<ReadPidResponseModel?>();
      }

      setPidValue(result);
    } catch (e) {
      debugPrint("getPidsValue error: $e");
    }
  }

  // ── 3. SET PID VALUE ─────────────────────────────────────────────────────
  void setPidValue(List<ReadPidResponseModel?> result) {
    if (result.isEmpty || selectedPidList.value == null) {
      print("🔍 setPidValue — result empty or selectedPidList null, returning");
      return;
    }

    print("🔍 setPidValue called — result count: ${result.length}");

    for (var pid in result) {
      if (pid == null) {
        print("🔍 pid is null, skipping");
        continue;
      }

      print("🔍 pid.status: ${pid.status}");
      print("🔍 pid.variables count: ${pid.variables?.length ?? 0}");
      pid.variables?.forEach((v) {
        print(
            "🔍   variable — pidNumber: ${v.pidNumber}, responseValue: '${v.responseValue}'");
      });

      if (pid.status == "NOERROR") {
        final pidVars = selectedPidList.value!.piCodeVariable ?? [];
        print("🔍 selectedPidList piCodeVariable count: ${pidVars.length}");

        for (var variable in pidVars) {
          print("🔍 trying to match variable.id: ${variable.id}");
          final item = pid.variables
              ?.firstWhereOrNull((x) => x.pidNumber == variable.id);
          print(
              "🔍   match found: ${item != null} — responseValue: '${item?.responseValue}'");

          if (item != null) {
            variable.writeValue = item.responseValue ?? "";
            variable.showResolution = item.responseValue ?? "";
            print(
                "✅   set writeValue='${variable.writeValue}' showResolution='${variable.showResolution}'");
          } else {
            print("⚠️   no match — setting ERR fallback? No — leaving as-is");
          }
        }

        print("✅ calling selectedPidList.refresh()");
        selectedPidList.refresh();
      } else if (pid.status == "Communication Error") {
        print("⚠️ Communication Error — setting ERR on all variables");
        for (var variable in selectedPidList.value!.piCodeVariable ?? []) {
          variable.writeValue = "ERR";
          variable.showResolution = "ERR";
        }
        selectedPidList.refresh();
        Get.dialog(AlertDialog(
          title: Text(pid.status ?? "Error"),
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
      } else {
        print(
            "⚠️ Other error status: ${pid.status} — setting ERR on all variables");
        for (var variable in selectedPidList.value!.piCodeVariable ?? []) {
          variable.writeValue = "ERR";
          variable.showResolution = "ERR";
        }
        selectedPidList.refresh();
      }
    }
  }

  void setPidValue1(List<ReadPidResponseModel?> result) {
    if (result.isEmpty || selectedPidList.value == null) return;

    for (var pid in result) {
      if (pid == null) continue;

      if (pid.status == "NOERROR") {
        // ✅ FIX 6: Use piCodeVariable (not variables)
        for (var variable in selectedPidList.value!.piCodeVariable ?? []) {
          final item = pid.variables
              ?.firstWhereOrNull((x) => x.pidNumber == variable.id);
          if (item != null) {
            variable.writeValue = item.responseValue ?? "";
            variable.showResolution = item.responseValue ?? "";
          }
        }
        selectedPidList.refresh();
      } else if (pid.status == "Communication Error") {
        for (var variable in selectedPidList.value!.piCodeVariable ?? []) {
          variable.writeValue = "ERR";
          variable.showResolution = "ERR";
        }
        selectedPidList.refresh();
        Get.dialog(AlertDialog(
          title: Text(pid.status ?? "Error"),
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
      } else {
        for (var variable in selectedPidList.value!.piCodeVariable ?? []) {
          variable.writeValue = "ERR";
          variable.showResolution = "ERR";
        }
        selectedPidList.refresh();
      }
    }
  }

  // ── 4. SELECT PID ────────────────────────────────────────────────────────

  Future<void> selectPid(PiCodeVariable pid) async {
    pidViewVisible.value = false;
    selectedPid.value = pid;

    isRunning.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      selectedPidList.value = PidCode();

      for (var item in pidList) {
        // ✅ FIX 7: Use piCodeVariable (not variables)
        for (var variable in item.piCodeVariable ?? []) {
          if (pid.id == variable.id) {
            selectedPidList.value = item;
            break;
          }
        }
        if (selectedPidList.value?.piCodeVariable?.isNotEmpty == true) break;
      }

      // Update title to selected pid's shortName
      title.value = pid.shortName ?? "Selected Parameter";

      listHeight.value = 0;

      if (selectedPidList.value?.piCodeVariable?.first.messageType == "IQA") {
        final noOfInjectorsStr =
            sessionModel.value?.variant?.noOfInjectors ?? "";
        if (noOfInjectorsStr.isEmpty) {
          Get.snackbar("Alert!", "Number of Injectors not available");
          return;
        }

        int noOfInjectors = int.tryParse(noOfInjectorsStr) ?? 0;
        if (noOfInjectors == 0) {
          Get.snackbar("Alert!", "Number of Injectors not available");
          return;
        }

        var list = List<PiCodeVariable>.from(
            selectedPidList.value!.piCodeVariable ?? [])
          ..sort(
              (a, b) => (a.bytePosition ?? 0).compareTo(b.bytePosition ?? 0));

        selectedPidList.value!.piCodeVariable = list;

        for (int i = 0; i < list.length; i++) {
          if (i >= noOfInjectors) {
            list[i].writeValue = "AAAAAAA";
            list[i].isVisible = false;
          }
        }
      } else {
        var list = List<PiCodeVariable>.from(
            selectedPidList.value!.piCodeVariable ?? [])
          ..sort(
              (a, b) => (a.bytePosition ?? 0).compareTo(b.bytePosition ?? 0));
        selectedPidList.value!.piCodeVariable = list;
      }

      if (selectedPidList.value?.piCodeVariable?.isNotEmpty == true) {
        listHeight.value =
            (selectedPidList.value!.piCodeVariable!.length * 90).toDouble();
        isEnumVisible.value =
            selectedPidList.value!.piCodeVariable!.first.messageType ==
                "ENUMRATED";
        await getPidsValue();
      }
    } catch (e) {
      newValue.value = "";
      pidViewVisible.value = false;
      title.value = pid.shortName ?? "";
      debugPrint("selectPid error: $e");
    } finally {
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 5. WRITE PARAMETER ───────────────────────────────────────────────────
  Future<void> writeParameter() async {
    try {
      if (selectedPidList.value == null) return;

      final totalLen = selectedPidList.value!.totalLen ?? 0;
      Uint8List writeInput = Uint8List(totalLen);
      List<VariantDataList> variantDataLists = [];

      // ✅ FIX 8: Use piCodeVariable (not variables)
      for (int i = 0;
          i < (selectedPidList.value!.piCodeVariable?.length ?? 0);
          i++) {
        final variable = selectedPidList.value!.piCodeVariable![i];

        if (variable.messageType!.contains("IQA") == true) {
          final bytes = variable.writeValue?.toUpperCase().codeUnits ?? [];
          final rxdata = Uint8List.fromList(bytes);
          for (int j = 0; j < rxdata.length && j < 7; j++) {
            if (7 * i + j < writeInput.length) {
              writeInput[7 * i + j] = rxdata[j];
            }
          }
          newValue.value = "IQA";
        } else if (variable.messageType!.contains("ASCII") == true) {
          final bytes = variable.writeValue?.toUpperCase().codeUnits ?? [];
          writeInput = Uint8List.fromList(bytes);
        } else if (variable.messageType!.contains("CONTINUOUS") == true) {
          final inputVal = double.tryParse(variable.writeValue ?? "");
          if (inputVal == null) {
            Get.snackbar("ERROR", "Invalid Value");
            return;
          }

          final min = variable.min ?? double.negativeInfinity;
          final max = variable.max ?? double.infinity;

          if (inputVal < min || inputVal > max) {
            Get.snackbar("ERROR", "Invalid Value");
            return;
          }

          double continuesValue =
              (inputVal - (variable.offset ?? 0)) / (variable.resolution ?? 1);

          final int intVal = continuesValue.toUInt32();
          final length = variable.length ?? 1;
          final val = Uint8List(length);
          for (int j = 0; j < length; j++) {
            val[length - j - 1] = (intVal >> (j * 8)) & 0xFF;
          }

          final startByte = (variable.bytePosition ?? 1) - 1;
          for (int j = 0; j < val.length; j++) {
            if (startByte + j < writeInput.length) {
              writeInput[startByte + j] = val[j];
            }
          }
        } else if (variable.messageType!.contains("ENUMRATED") == true) {
          double continuesValue =
              double.tryParse(variable.selectedEnum!.code ?? "0") ?? 0;
          final int intVal = continuesValue.toInt();
          final length = variable.length ?? 1;
          final val = Uint8List(length);
          for (int j = 0; j < length; j++) {
            val[length - j - 1] = (intVal >> (j * 8)) & 0xFF;
          }

          final startByte = (variable.bytePosition ?? 1) - 1;
          for (int j = 0; j < val.length; j++) {
            if (startByte + j < writeInput.length) {
              writeInput[startByte + j] = val[j];
            }
          }
        }

        variantDataLists.add(VariantDataList(
          pidId: variable.id,
          startByte: variable.bytePosition,
          datatype: variable.messageType,
          resolution: variable.resolution,
          offset: variable.offset,
          unit: variable.unit,
          pidName: variable.shortName,
          beforeValue: variable.showResolution,
        ));
      }

      await _executeWrite(writeInput, selectedPidList.value!, variantDataLists);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ── 6. EXECUTE WRITE ─────────────────────────────────────────────────────
// ── 6. EXECUTE WRITE ─────────────────────────────────────────────────────
  Future<void> _executeWrite(
    Uint8List writeInput,
    PidCode pid,
    List<VariantDataList> variantList,
  ) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text("Alert!!"),
      content: const Text("Are you sure you want to write Parameter?"),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: true),
            child: Text("Ok", style: TextStyles.labelStyle)),
        TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel", style: TextStyles.labelStyle)),
      ],
    ));

    if (confirm != true) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final modelDetail = StaticData.ecuInfo
          .firstWhereOrNull((x) => x.ecuName == selectedEcu.value?.ecuName);
      if (modelDetail == null) return;

      final List<VariantDataLists> mappedVariants = variantList.map((v) {
        return VariantDataLists(
          pidId: v.pidId,
          startByte: v.startByte,
          datatype: v.datatype,
          resolution: v.resolution,
          offset: v.offset,
          unit: v.unit,
          pidName: v.pidName,
          beforeValue: v.beforeValue,
        );
      }).toList();

      final writeParamPid = WriteParameterPid(
        seedKeyIndex: modelDetail.seedKeyIndex,
        writePamIndex: modelDetail.writePidIndex,
        writeInput: writeInput,
        writeParaDataSize: pid.totalLen,
        writePid: pid.writePid,
        readParameterPidDataType: selectedPid.value?.messageType,
        pid: pid.code,
        startByte: selectedPid.value?.bytePosition,
        totalBytes: pid.totalLen,
        variantList: mappedVariants,
        memory_address: (pid.memoryAddress == true) ? "true" : null,
      );

      List<WriteParameterStatus?> paramStatus = [];

      if (App.connectedVia == "USB") {
        paramStatus = await App.usbConnectorService!.writePid(
          modelDetail.writePidIndex ?? "",
          [writeParamPid],
          selectedEcu.value?.pidByAddrSeq ?? "",
        );
      } else if (App.connectedVia == "WIFI") {
        paramStatus = await App.wifiConnectorService!.writePid(
              modelDetail.writePidIndex ?? "",
              [writeParamPid],
              selectedEcu.value?.pidByAddrSeq ?? "",
            ) ??
            [];
      }

      if (Get.isDialogOpen == true) Get.back();

      String serverMessage = "";
      String messageTitle = "";
      String status = "";

      // ✅ Collect PidWriteRecordItem objects in a plain list
      List<PidWriteRecordItem> pidWriteItems = [];

      for (var item in paramStatus) {
        if (item == null) continue;

        if (item.status == "NOERROR") {
          await getPidsValue();
          newValue.value = "";
          messageTitle = "Writing Completed";
          status = "";

          for (var variant in selectedPidList.value?.piCodeVariable ?? []) {
            pidWriteItems.add(PidWriteRecordItem(
              pidCode: "${selectedPidList.value?.code} - ${variant.shortName}",
              valueBefore: variantList
                      .firstWhereOrNull((x) => x.pidId == variant.id)
                      ?.beforeValue ??
                  "",
              valueAfter: selectedPid.value?.showResolution ?? "",
              status: "pass",
            ));
          }
        } else {
          messageTitle = "Writing Incomplete";
          status = item.status ?? "";

          for (var variant in selectedPidList.value?.piCodeVariable ?? []) {
            pidWriteItems.add(PidWriteRecordItem(
              pidCode: "${selectedPidList.value?.code} - ${variant.shortName}",
              valueBefore: variantList
                      .firstWhereOrNull((x) => x.pidId == variant.id)
                      ?.beforeValue ??
                  "",
              valueAfter: selectedPid.value?.showResolution ?? "",
              status: "fail",
            ));
          }
        }

        final connectivity = await Connectivity().checkConnectivity();
        final hasInternet = connectivity != ConnectivityResult.none;

        if (hasInternet && (sessionModel.value?.id ?? 0) != 0) {
          // ✅ API call — pass pidWriteItems directly
          final saved = await _services.pidWriteRecord(
              pidWriteItems, App.jwtToken, sessionModel.value!.id!);
          serverMessage =
              saved ? "Parameter data saved" : "Parameter data not saved";
        } else {
          // ✅ Offline save — pass pidWriteItems directly
          // await _saveWriteParameterOffline(pidWriteItems);
          serverMessage = "Saved offline";
        }

        if (paramStatus.first?.status?.contains("NOERROR") == true) {
          status = "";
        }

        if (status == "Communication Error") {
          final resp = await Get.dialog<bool>(AlertDialog(
            title: Text(status),
            content: const Text("Do you want to reconnect?"),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: true),
                  child: Text("Yes", style: TextStyles.labelStyle)),
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("No", style: TextStyles.labelStyle)),
            ],
          ));
          if (resp == true) {
            // ReconnectService().reconnectDongle();
          }
        } else {
          Get.snackbar(messageTitle, "$status\n$serverMessage");
        }
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      debugPrint("_executeWrite error: $e");
    }
  }

// ── HELPER: Save offline ──────────────────────────────────────────────────
// ✅ FIX: accepts List<PidWriteRecordItem> directly
//         wraps into WriteParameterOfflineAnalyze which takes pidWriteRecord
  // ── 7. TAB CLICKED ───────────────────────────────────────────────────────
  Future<void> tabClicked(EcuModel tappedEcu) async {
    if (ecusList.length <= 1) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      selectedEcu.value = tappedEcu;

      for (var ecu in ecusList) {
        ecu.opacity = ecu.ecuName == tappedEcu.ecuName ? 1.0 : 0.5;
      }
      ecusList.refresh();

      staticPidList.value =
          pidList.value = List<PidCode>.from(tappedEcu.pidList ?? []);
      selectedPidList.value = null; // ✅ FIX 10: null is cleaner than PidCode()

      title.value = "Select a parameter to write";

      await setDongleProperties();
    } catch (e) {
      debugPrint("tabClicked error: $e");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 8. SET DONGLE PROPERTIES ─────────────────────────────────────────────
  Future<void> setDongleProperties() async {
    try {
      if (App.connectedVia == "USB") {
        await App.usbConnectorService!.setDongleProperties(
          protocolName: selectedEcu.value?.protocol?.autopeepal ?? "",
          txHeaderTemp: selectedEcu.value?.txHeader ?? "",
          rxHeaderTemp: selectedEcu.value?.rxHeader ?? "",
        );
      } else if (App.connectedVia == "WIFI") {
        await App.wifiConnectorService!.setDongleProperties(
          protocolName: selectedEcu.value?.protocol?.autopeepal ?? "",
          txHeaderTemp: selectedEcu.value?.txHeader ?? "",
          rxHeaderTemp: selectedEcu.value?.rxHeader ?? "",
        );
      }
    } catch (e) {
      debugPrint("setDongleProperties error: $e");
    }
  }

  // ── HELPER: Save offline ──────────────────────────────────────────────────
}

// Extension helper for double to uint32
extension DoubleExt on double {
  int toUInt32() => toInt() & 0xFFFFFFFF;
}
