import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DtcController extends GetxController {
  // FMI Descriptions (J1939)
  static const Map<String, String> fmiDescriptions = {
    "0": "Data valid but above normal operational range (most severe)",
    "1": "Data valid but below normal operational range (most severe)",
    "2": "Data erratic, intermittent, or incorrect",
    "3": "Voltage above normal, or shorted to high source",
    "4": "Voltage below normal, or shorted to low source",
    "5": "Current below normal, or open circuit",
    "6": "Current above normal, or grounded circuit",
    "7": "Mechanical system not responding or out of adjustment",
    "8": "Abnormal frequency, pulse width, or period",
    "9": "Abnormal update rate",
    "10": "Abnormal rate of change",
    "11": "Root cause not known",
    "12": "Bad intelligent device or component",
    "13": "Out of calibration",
    "14": "Special instruction",
    "15": "Data valid but above normal operational range (least severe)",
    "16": "Data valid but below normal operational range (least severe)",
    "17": "Low idle",
    "18": "High idle",
    "19": "Received network data in error",
    "20": "Data drifted high",
    "21": "Data drifted low",
    "22": "Data valid but above normal operating range",
    "23": "Data valid but below normal operating range",
    "24": "Abnormal initialization",
    "25": "Condition exists",
    "26": "No response from device",
    "27": "Not plausible",
    "28": "Fault not active",
    "29": "Fault pending",
    "30": "Fault active",
    "31": "Condition met",
  };

  var dtcFoundOrNotMessage = "".obs;
  var dtcList = <DtcCode>[].obs;
  var dtcServerList = <DtcCode>[].obs;
  var ecusList = <DtcEcusModel>[].obs;
  var emptyViewText = "Loading...".obs;
  // Observables
  var isRunning = false.obs;

  var readDtc = Rxn<ReadDtcResponseModel>();
  var selectedEcu = Rxn<DtcEcusModel>();
  var sessionModel = Rxn<SessionModel>();
  ModelResult? vehicleModels;

  final AuthApiService _services = AuthApiService();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args == null) {
      debugPrint("⚠️ DtcController: No arguments received");
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

      // ✅ FIX: delay execution after UI build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getDTCList();
      });
    } catch (e) {
      debugPrint("🔥 DtcController onInit error: $e");
    }
  }

//   // ── 1. GET DTC LIST ────────────────────────────────────────────────────────
  Future<void> getDTCList() async {
    isRunning.value = true;
    emptyViewText.value = "Loading...";
    dtcFoundOrNotMessage.value = "Looking for DTC Record";

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      ecusList.clear();
      dtcList.clear();
      int count = 0;
      List<DtcResults> dtcLi = [];

      for (var ecu in StaticData.ecuInfo) {
        count++;

        // 1. Find ECU model info
        Ecu modelEcu = Ecu();
        final subModel = vehicleModels!.subModels
            ?.firstWhereOrNull((x) => x.id == App.subModelId);
        if (subModel != null) {
          final found =
              subModel.ecus?.firstWhereOrNull((x) => x.name == ecu.ecuName);
          if (found != null) modelEcu = found;
        }

        // 2. Fetch local DTC dataset
        final dtcLocalDataStr = await AndroidOperationsService.getData(
            "DtcDataset_${ecu.dtcDatasetId}");
        if (dtcLocalDataStr == null) {
          Get.snackbar("Failed", "DTC not found from server");
          dtcFoundOrNotMessage.value = "DTC not found from server.";
          return;
        }

        var dtcLocal = DtcMainModel.fromJson(jsonDecode(dtcLocalDataStr));

        // 3. SW Version check
        if (ecu.versionDataset != null && ecu.versionDataset!.isNotEmpty) {
          if (ecu.swVerPid != null && ecu.swVerPid!.isNotEmpty) {
            final swVerPid =
                ecu.pidList?.firstWhereOrNull((y) => y.code == ecu.swVerPid);

            if (swVerPid == null) {
              Get.snackbar("Failed", "SW Version not found");
              dtcFoundOrNotMessage.value = "SW Version not found.";
              return;
            }

            List<ReadPidResponseModel>? readPidResp;

            if (App.connectedVia == "USB") {
              readPidResp = (await App.usbConnectorService!
                      .readPid(pidList: [swVerPid], pidByAddrSeq: ""))
                  .whereType<ReadPidResponseModel>()
                  .toList(); // ✅ removes nulls
            } else if (App.connectedVia == "WIFI") {
              readPidResp = (await App.wifiConnectorService!
                      .readPid(pidList: [swVerPid], pidByAddrSeq: ""))
                  .whereType<ReadPidResponseModel>()
                  .toList(); // ✅ removes nulls
            }

            if (readPidResp == null || readPidResp.isEmpty) {
              Get.snackbar("Failed", "Could not read SW Version");
              dtcFoundOrNotMessage.value = "Could not read SW Version.";
              return;
            }

            final swVersion =
                readPidResp.first.variables?.first.responseValue ?? "";

            if (swVersion.isEmpty) {
              Get.snackbar("Failed", "Could not read SW Version");
              dtcFoundOrNotMessage.value = "Could not read SW Version.";
              return;
            }

            // Parse version using regex
            final match = RegExp(r'[Vv](\d+)').firstMatch(swVersion);
            if (match == null) {
              Get.snackbar("Failed", "SW Version is in incorrect format");
              dtcFoundOrNotMessage.value = "SW Version is in incorrect format.";
              return;
            }

            final version = int.tryParse(match.group(1) ?? "");
            final compareVersion = int.tryParse(
                ecu.versionDataset![0].version!.replaceAll("V", ""));

            if (version == null || compareVersion == null) {
              Get.snackbar(
                  "Failed", "SW Version is in incorrect format on server");
              dtcFoundOrNotMessage.value =
                  "SW Version is in incorrect format on server.";
              return;
            }

            if (version >= compareVersion) {
              dtcLi = dtcLocal.results ?? [];
            } else {
              final fallbackStr = await AndroidOperationsService.getData(
                  "DtcDataset_${ecu.versionDataset![0].dataset}");
              dtcLocal = DtcMainModel.fromJson(jsonDecode(fallbackStr ?? "{}"));
              dtcLi = dtcLocal.results ?? [];
            }
          } else {
            Get.snackbar("Failed", "SW Version not found");
            dtcFoundOrNotMessage.value = "SW Version not found.";
            return;
          }
        } else {
          dtcLi = dtcLocal.results ?? [];
        }

        if (dtcLi.isEmpty) {
          Get.snackbar("Failed", "DTC not found from server");
          dtcFoundOrNotMessage.value = "DTC not found from server.";
          return;
        }

        // 4. Setup dtc server list
        dtcServerList.value = List<DtcCode>.from(dtcLi.first.dtcCode ?? []);

        if (dtcServerList.isEmpty) {
          Get.snackbar("Failed", "DTC not found from server");
          dtcFoundOrNotMessage.value = "DTC not found from server.";
          return;
        }

        // 5. Build ECU model
        var dtcEcusModel = DtcEcusModel(
          ecuName: ecu.ecuName,
          ecuId: ecu.ecuId,
          opacity: count == 1 ? 1.0 : 0.5,
          txHeader: modelEcu.txHeader ?? "",
          rxHeader: modelEcu.rxHeader ?? "",
          protocol: modelEcu.protocol,
          ffSet: modelEcu.ffSet ?? 0,
          dtcList: [],
        );

        // 6. First ECU — auto read DTCs
        if (count < 2) {
          dtcEcusModel = await getDtc(dtcEcusModel, ecu);
          selectedEcu.value = dtcEcusModel;
          dtcList.assignAll(dtcEcusModel.dtcList ?? []);

          // Update empty view text
          final status = readDtc.value?.status ?? "";
          if (status.isNotEmpty && status != "NO_ERROR") {
            emptyViewText.value = status;
          } else if (status == "NO_ERROR") {
            emptyViewText.value = (dtcEcusModel.dtcList?.isNotEmpty == true)
                ? ""
                : "Dtc not found.";
          } else {
            emptyViewText.value = "ECU_COMMUNICATION_ERROR";
          }
        }

        ecusList.add(dtcEcusModel);

        // 7. Post DTC Record (online/offline)
        if (dtcEcusModel.dtcList != null && dtcEcusModel.dtcList!.isNotEmpty) {
          await _postDtcRecord(dtcEcusModel.dtcList!, "read_dtc");
        }
      }
    } catch (e) {
      emptyViewText.value = e.toString();
    } finally {
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

// ── 1. GET DTC LIST ────────────────────────────────────────────────────────
  Future<void> getDTCList1() async {
    print("--- [DEBUG] Starting getDTCList ---");
    isRunning.value = true;
    emptyViewText.value = "Loading...";
    dtcFoundOrNotMessage.value = "Looking for DTC Record";

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      ecusList.clear();
      dtcList.clear();
      int count = 0;
      List<DtcResults> dtcLi = [];

      print(
          "DEBUG: Processing ECU Info list. Total ECUs: ${StaticData.ecuInfo.length}");

      for (var ecu in StaticData.ecuInfo) {
        count++;
        print("\n--- Processing ECU [$count]: ${ecu.ecuName} ---");

        // 1. Find ECU model info
        Ecu modelEcu = Ecu();
        final subModel = vehicleModels!.subModels
            ?.firstWhereOrNull((x) => x.id == App.subModelId);

        if (subModel != null) {
          final found =
              subModel.ecus?.firstWhereOrNull((x) => x.name == ecu.ecuName);
          if (found != null) {
            modelEcu = found;
            print(
                "DEBUG: Found ECU Model Config (TX: ${modelEcu.txHeader}, RX: ${modelEcu.rxHeader})");
          }
        }

        // 2. Fetch local DTC dataset
        print("DEBUG: Fetching Local Dataset: DtcDataset_${ecu.dtcDatasetId}");
        final dtcLocalDataStr = await AndroidOperationsService.getData(
            "DtcDataset_${ecu.dtcDatasetId}");

        if (dtcLocalDataStr == null) {
          print(
              "ERROR: DtcDataset_${ecu.dtcDatasetId} not found in Local Storage");
          Get.snackbar("Failed", "DTC not found from server");
          dtcFoundOrNotMessage.value = "DTC not found from server.";
          return;
        }

        var dtcLocal = DtcMainModel.fromJson(jsonDecode(dtcLocalDataStr));

        // 3. SW Version check
        if (ecu.versionDataset != null && ecu.versionDataset!.isNotEmpty) {
          print("DEBUG: SW Version Check Required for ${ecu.ecuName}");

          if (ecu.swVerPid != null && ecu.swVerPid!.isNotEmpty) {
            final swVerPid =
                ecu.pidList?.firstWhereOrNull((y) => y.code == ecu.swVerPid);

            if (swVerPid == null) {
              print(
                  "ERROR: SW Version PID definition missing for code ${ecu.swVerPid}");
              Get.snackbar("Failed", "SW Version not found");
              return;
            }

            print(
                "DEBUG: Reading SW Version from ECU via ${App.connectedVia} using PID ${swVerPid.code}");
            List<ReadPidResponseModel>? readPidResp;

            if (App.connectedVia == "USB") {
              readPidResp = (await App.usbConnectorService!
                      .readPid(pidList: [swVerPid], pidByAddrSeq: ""))
                  .whereType<ReadPidResponseModel>()
                  .toList();
            } else if (App.connectedVia == "WIFI") {
              readPidResp = (await App.wifiConnectorService!
                      .readPid(pidList: [swVerPid], pidByAddrSeq: ""))
                  .whereType<ReadPidResponseModel>()
                  .toList();
            }

            if (readPidResp == null || readPidResp.isEmpty) {
              print(
                  "ERROR: Hardware returned null or empty SW Version response");
              Get.snackbar("Failed", "Could not read SW Version");
              return;
            }

            final swVersion =
                readPidResp.first.variables?.first.responseValue ?? "";
            print("DEBUG: Raw SW Version from ECU: '$swVersion'");

            final match = RegExp(r'[Vv](\d+)').firstMatch(swVersion);
            if (match == null) {
              print(
                  "ERROR: Regex failed to find version pattern in '$swVersion'");
              Get.snackbar("Failed", "SW Version is in incorrect format");
              return;
            }

            final version = int.tryParse(match.group(1) ?? "");
            final compareVersion = int.tryParse(
                ecu.versionDataset![0].version!.replaceAll("V", ""));

            print(
                "DEBUG: Comparing Version (Current: $version | Minimum: $compareVersion)");

            if (version == null || compareVersion == null) {
              Get.snackbar("Failed", "SW Version format error");
              return;
            }

            if (version >= compareVersion) {
              print("DEBUG: Version check passed. Using primary dataset.");
              dtcLi = dtcLocal.results ?? [];
            } else {
              print(
                  "DEBUG: Version check failed. Using fallback dataset: ${ecu.versionDataset![0].dataset}");
              final fallbackStr = await AndroidOperationsService.getData(
                  "DtcDataset_${ecu.versionDataset![0].dataset}");
              dtcLocal = DtcMainModel.fromJson(jsonDecode(fallbackStr ?? "{}"));
              dtcLi = dtcLocal.results ?? [];
            }
          }
        } else {
          print("DEBUG: No SW Version check required. Using default results.");
          dtcLi = dtcLocal.results ?? [];
        }

        if (dtcLi.isEmpty) {
          print("ERROR: Result list (dtcLi) is empty for this ECU");
          return;
        }

        // 4. Setup dtc server list
        dtcServerList.value = List<DtcCode>.from(dtcLi.first.dtcCode ?? []);
        print(
            "DEBUG: Loaded ${dtcServerList.length} DTC definitions from local dataset");

        // 5. Build ECU model
        var dtcEcusModel = DtcEcusModel(
          ecuName: ecu.ecuName,
          ecuId: ecu.ecuId,
          opacity: count == 1 ? 1.0 : 0.5,
          txHeader: modelEcu.txHeader ?? "",
          rxHeader: modelEcu.rxHeader ?? "",
          protocol: modelEcu.protocol,
          ffSet: modelEcu.ffSet ?? 0,
          dtcList: [],
        );

        // ── 6. First ECU — auto read DTCs ──────────────────────────────────────────
        if (count < 2) {
          print(
              "DEBUG: Automatically calling getDtc() for the first ECU: ${ecu.ecuName}");

          // 1. Await the hardware response and the mapping logic
          dtcEcusModel = await getDtc(dtcEcusModel, ecu);

          // 2. Update the reactive state
          selectedEcu.value = dtcEcusModel;

          // CRITICAL: We must assign the list AFTER the description matching is done in getDtc
          dtcList.assignAll(dtcEcusModel.dtcList ?? []);

          final status = readDtc.value?.status ?? "";
          print(
              "DEBUG: getDtc() completed. Status: '$status', List count: ${dtcList.length}");

          // 3. Finalize the Empty View State
          if (status == "NOERROR" || status == "NO_ERROR") {
            if (dtcList.isNotEmpty) {
              // Success: Clear the error text so the ListView shows
              emptyViewText.value = "";
            } else {
              // Success but empty: Show a user-friendly message
              emptyViewText.value = "No Diagnostic Trouble Codes found.";
            }
          } else if (status.isNotEmpty) {
            // Hardware returned an error (e.g., "7F 19 11" or "Timeout")
            emptyViewText.value = status;
          } else {
            // No response at all
            emptyViewText.value = "ECU_COMMUNICATION_ERROR";
          }

          // 4. Force a refresh of the ecusList to update the tab opacity/selection
          ecusList.refresh();
        }

        ecusList.add(dtcEcusModel);

        // 7. Post DTC Record
        if (dtcEcusModel.dtcList != null && dtcEcusModel.dtcList!.isNotEmpty) {
          print(
              "DEBUG: Posting ${dtcEcusModel.dtcList!.length} DTCs to cloud/local records.");
          await _postDtcRecord(dtcEcusModel.dtcList!, "read_dtc");
        }
      }
    } catch (e) {
      print("🔥 FATAL ERROR in getDTCList: $e");
      emptyViewText.value = e.toString();
    } finally {
      print("--- [DEBUG] getDTCList Completed ---");
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  Future<DtcEcusModel> getDtc(DtcEcusModel dtcEcusModel, EcuDataSet ecu) async {
    try {
      dtcEcusModel.dtcList = [];
      print("--- [DEBUG] getDtc started for ${dtcEcusModel.ecuName} ---");

      // 1. Connection Setup
      if (App.connectedVia == "USB") {
        if (App.usbConnectorService == null) return dtcEcusModel;
        await App.usbConnectorService!.setDongleProperties(
          protocolName: dtcEcusModel.protocol!.autopeepal ?? '',
          txHeaderTemp: dtcEcusModel.txHeader ?? "",
          rxHeaderTemp: dtcEcusModel.rxHeader ?? "",
        );
        readDtc.value =
            await App.usbConnectorService!.readDtc(ecu.readDtcIndex ?? '');
      } else {
        if (App.wifiConnectorService == null) return dtcEcusModel;
        await App.wifiConnectorService!.setDongleProperties(
          protocolName: dtcEcusModel.protocol!.autopeepal ?? '',
          txHeaderTemp: dtcEcusModel.txHeader ?? "",
          rxHeaderTemp: dtcEcusModel.rxHeader ?? "",
        );
        readDtc.value =
            await App.wifiConnectorService!.readDtc(ecu.readDtcIndex ?? '');
      }

      if (readDtc.value == null) return dtcEcusModel;

      final status = readDtc.value!.status ?? "";
      print("DEBUG: Raw DTC status from hardware: '$status'");

      // 2. Process Positive Response
      if (status == "NOERROR" || status == "NO_ERROR") {
        final rawDtcs = readDtc.value!.dtcs ?? [];
        print("DEBUG: Raw DTC count from parser: ${rawDtcs.length}");

        List<DtcCode> processedList = [];

        for (var rawItem in rawDtcs) {
          if (rawItem.isEmpty) continue;

          final code = rawItem[0];
          final dtcStatus = rawItem[1];

          DtcCode dtcModel = DtcCode(code: code);
          dtcModel.statusActivation = dtcStatus;

          // Assign Colors based on status
          // Assign Colors based on status
          if (dtcStatus.contains("Active")) {
            dtcModel.statusColor = Colors.red;
          } else if (dtcStatus.contains("History")) {
            dtcModel.statusColor = Colors.green;
          } else if (dtcStatus.contains("Pending")) {
            dtcModel.statusColor = Colors.orange;
          } else {
            // ✅ FIX: fallback for Stored or any unrecognized status
            dtcModel.statusColor = Colors.green;
          }

          dtcModel.isFreezeFrame = true;
          dtcModel.isGd = App.isGd;

          // 3. Match Description from Server Dataset
          if (dtcServerList.isNotEmpty) {
            final serverDef =
                dtcServerList.firstWhereOrNull((x) => x.code == code);
            if (serverDef != null) {
              dtcModel.description = serverDef.description;
              dtcModel.environmentSnapshot = serverDef.environmentSnapshot;
            } else {
              dtcModel.description = "Definition not found in dataset";
            }
          } else {
            dtcModel.description = "Local dataset empty";
          }

          // J1939 Special Formatting
          if (ecu.readDtcIndex == "UDS_J1939") {
            dtcModel.code = "SPN ${dtcModel.code}";
            final fmi = rawItem.length > 2 ? rawItem[2] : "N/A";
            final fmiDesc = fmiDescriptions[fmi] ?? "Unknown FMI";
            dtcModel.description =
                "${dtcModel.description}\nFMI $fmi: $fmiDesc";
          }

          // ✅ CRITICAL FIX: Always add to the list, even if description is null
          processedList.add(dtcModel);
        }

        // 4. Deduplicate and Sort
        if (processedList.isNotEmpty) {
          dtcEcusModel.dtcList = processedList
              .fold<Map<String, DtcCode>>({}, (map, item) {
                map[item.code!] = item;
                return map;
              })
              .values
              .toList()
            ..sort((a, b) => _getStatusRank(a).compareTo(_getStatusRank(b)));

          emptyViewText.value = ""; // Clear error text on success
        } else {
          emptyViewText.value = "No DTCs found.";
        }
      } else {
        // 5. Handle Error Status
        emptyViewText.value =
            status.isNotEmpty ? status : "COMMUNICATION_ERROR";
      }

      return dtcEcusModel;
    } catch (e) {
      print("🔥 getDtc Exception: $e");
      emptyViewText.value = "DECODING_ERROR";
      return dtcEcusModel;
    }
  }

  int _getStatusRank(DtcCode d) {
    final s = d.statusActivation ?? "";
    if (s.contains("Active")) return 0;
    if (s.contains("Pending")) return 1;
    if (s.contains("History")) return 2;
    // ✅ FIX: Stored falls after History
    return 3;
  }

  // ── 3. TAB CLICKED ────────────────────────────────────────────────────────
  Future<void> tabClicked(DtcEcusModel tappedEcu) async {
    if (ecusList.length <= 1) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      selectedEcu.value = tappedEcu;
      dtcList.clear();
      emptyViewText.value = "Loading...";

      // Update opacity
      for (var i = 0; i < ecusList.length; i++) {
        ecusList[i].opacity =
            ecusList[i].ecuName == tappedEcu.ecuName ? 1.0 : 0.5;
      }
      ecusList.refresh();

      final ecuData = StaticData.ecuInfo
          .firstWhereOrNull((x) => x.ecuName == tappedEcu.ecuName);
      if (ecuData == null) return;

      final dtc = await getDtc(tappedEcu, ecuData);
      dtcList.assignAll(dtc.dtcList ?? []);
      isRunning.value = false;

      final status = readDtc.value?.status ?? "";
      if (status.isNotEmpty && status != "NO_ERROR") {
        emptyViewText.value = status;
      } else if (status == "NO_ERROR") {
        emptyViewText.value = (selectedEcu.value?.dtcList?.isNotEmpty == true)
            ? ""
            : "Dtc not found.";
      } else {
        emptyViewText.value = "ECU_COMMUNICATION_ERROR";
      }
    } catch (e) {
      debugPrint("tabClicked error: $e");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 4. REFRESH ────────────────────────────────────────────────────────────
  Future<void> dtcRefresh() async {
    if (selectedEcu.value == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final ecuData = StaticData.ecuInfo
          .firstWhereOrNull((x) => x.ecuName == selectedEcu.value!.ecuName);
      if (ecuData == null) return;

      final dtc = await getDtc(selectedEcu.value!, ecuData);
      dtcList.assignAll(dtc.dtcList ?? []);

      if (dtc.dtcList != null && dtc.dtcList!.isNotEmpty) {
        await _postDtcRecord(dtc.dtcList!, "read_dtc");
      }
    } catch (e) {
      debugPrint("dtcRefresh error: $e");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 5. CLEAR ──────────────────────────────────────────────────────────────
  Future<void> dtcClear() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      for (var item in StaticData.ecuInfo) {
        if (item.ecuName != selectedEcu.value?.ecuName) continue;

        String clearResult = "";
        if (App.connectedVia == "USB") {
          clearResult = await App.usbConnectorService!.clearDtc(
              item.clearDtcIndex ?? '',
              item.seedKeyIndex ?? '',
              item.writePidIndex ?? '');
        } else if (App.connectedVia == "WIFI") {
          clearResult = (await App.wifiConnectorService!.clearDtc(
              item.clearDtcIndex ?? '',
              item.seedKeyIndex ?? '',
              item.writePidIndex ?? ''))!;
        }

        if (clearResult.isEmpty) continue;

        if (clearResult.contains("NOERROR")) {
          final dtc = await getDtc(selectedEcu.value!, item);
          dtcList.assignAll(dtc.dtcList ?? []);

          if (Get.isDialogOpen == true) Get.back();
          Get.snackbar("Alert", "DTC Cleared");

          if (dtc.dtcList != null && dtc.dtcList!.isNotEmpty) {
            await _postDtcRecord(dtc.dtcList!, "clear_dtc");
          }
        } else if (clearResult == "Communication Error") {
          if (Get.isDialogOpen == true) Get.back();
          final resp = await Get.dialog<bool>(
            AlertDialog(
              title: Text(clearResult),
              content: const Text("Do you want to reconnect?"),
              actions: [
                TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text("No")),
              ],
            ),
          );
          if (resp == true) {
            // ReconnectService().reconnectDongle();
          }
        } else {
          if (Get.isDialogOpen == true) Get.back();
          Get.snackbar("Alert", clearResult);
        }
      }
    } catch (e) {
      debugPrint("dtcClear error: $e");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  Future<void> gdClicked(DtcCode dtcCode) async {
  try {
    // 1. Check Internet Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    if (!hasInternet) {
      Get.snackbar(
        "Alert!",
        "Please connect to internet.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return;
    }

    // 2. Show Loading Dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    // 3. Call API
    final res = await _services.getGd(
      App.jwtToken,
      dtcCode.code ?? "",
      App.subModelId,
    );

    // 4. Dismiss Loading
    if (Get.isDialogOpen == true) Get.back();

    // 5. Handle Response
    if (res != null && res.results != null && res.results!.isNotEmpty) {
      // ── Navigate to InfoPage ───────────────────────────────────
      Get.toNamed(Routes.infoPage, arguments: {
        'gdData'       : res.results,
        'sessionModel' : sessionModel.value,
        'vehicleModels': vehicleModels,
      });
    } else {
      // ── No Results Found ───────────────────────────────────────
      Get.dialog(
        AlertDialog(
          title: const Text("Alert!"),
          content: const Text(
              "Troubleshoot details not found for this DTC"),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  } catch (ex) {
    // 6. Dismiss Loading if still open
    if (Get.isDialogOpen == true) Get.back();

    // 7. Show Exception Dialog
    Get.dialog(
      AlertDialog(
        title: const Text("Exception"),
        content: Text(ex.toString()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    debugPrint("🔥 gdClicked Exception: $ex");
  }
}

 void freezeFrameClicked(DtcCode dtcCode) {
  if (selectedEcu.value == null) return;
  Get.toNamed(Routes.freezeFrame, arguments: {
    'dtc'          : dtcCode,
    'ffSet'        : selectedEcu.value!.ffSet,
    'ecuId'        : selectedEcu.value!.ecuId,
    'sessionModel' : sessionModel.value,   // ✅ .value unwraps Rxn<SessionModel>
  });
}

  // ── HELPER: Post DTC Record (online/offline) ──────────────────────────────
  Future<void> _postDtcRecord(List<DtcCode> dtcCodes, String type) async {
    try {
      final pdr = dtcCodes
          .map((item) => PostDtcRecord(
                value: item.code,
                status: item.statusActivation,
              ))
          .toList();

      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet = connectivity != ConnectivityResult.none;

      if (hasInternet && sessionModel.value!.id != 0) {
        if (type == "clear_dtc") {
          await _services.clearDtcRecord1(
              pdr,
              App.jwtToken,
              sessionModel.value!.id ?? 0,
              DateTime.now().toUtc().toIso8601String());
        } else {
          await _services.dtcRecord(
              pdr,
              App.jwtToken,
              sessionModel.value!.id ?? 0,
              DateTime.now().toUtc().toIso8601String());
        }
      } else {
        // Offline save
        final key = type == "clear_dtc"
            ? "OfflineAnalyze_ClearDtc"
            : "OfflineAnalyze_ReadDtc";

        final offlineEntry = ReadDtcOfflineAnalyze(
          type: type,
          pdr: pdr,
          srnId: sessionModel.value!.id,
          srNumber: sessionModel.value!.srNumber,
          datetime: DateTime.now().toUtc().toIso8601String(),
        );

        final existing = await AndroidOperationsService.getData(key);
        List<ReadDtcOfflineAnalyze> data = [];
        if (existing != null && existing.isNotEmpty) {
          data = (jsonDecode(existing) as List)
              .map((e) => ReadDtcOfflineAnalyze.fromJson(e))
              .toList();
        }
        data.add(offlineEntry);
        await AndroidOperationsService.saveData(key, jsonEncode(data));
      }
    } catch (e) {
      debugPrint("_postDtcRecord error: $e");
    }
  }
}
