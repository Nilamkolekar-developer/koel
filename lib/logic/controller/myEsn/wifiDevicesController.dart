import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/bluetoothDevices_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart';
import 'package:autopeepal/models/parameter_model.dart';
import 'package:autopeepal/models/registerDongle_model.dart';
import 'package:autopeepal/models/reportLocationModel.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/uploadEngineHr_model.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WifiDevicesController extends GetxController {
  // ── Observables ───────────────────────────────────────────────────────────
  var wifiDevicesList = <WifiDevicesModel>[].obs;
  var isLoading = false.obs;

  // ── Local state ───────────────────────────────────────────────────────────
  SessionModel? sessionModel;
  ModelResult? vehicleModels;
  WifiDevicesModel? selectedDevice;
  String firmwareVersion = "";
  String localDataJson = "";
  bool returnValue = false;

  List<RegDongleRespons> localRegisterDongleResponse = [];
  RegDongleRespons? registerDongleResponse;
  var scanComplete = false.obs;

  final AuthApiService _services = AuthApiService();

  // @override
  // void onInit() {
  //   super.onInit();

  //   final args = Get.arguments;
  //   bool isManual = false; // Default to false

  //   if (args != null) {
  //     // 1. Check if this is a manual addition
  //     isManual = args['isManual'] ?? false;

  //     final raw = args['sessionModel'];
  //     sessionModel = raw is SessionModel ? raw : null;
  //     vehicleModels = args['vehicleModels'] as ModelResult?;

  //     final dongles = args['wifiConnector'];
  //     if (dongles is List) {
  //       wifiDevicesList.assignAll(
  //         dongles.whereType<WifiDevicesModel>().toList(),
  //       );
  //     }
  //   }

  //   // 2. Only trigger the scanning loader if NOT manual
  //   if (!isManual) {
  //     refreshDeviceList();
  //   } else {
  //     // If manual, ensure the loader is definitely off
  //     isLoading.value = false;
  //   }
  // }
  @override
void onInit() {
  super.onInit();

  final args = Get.arguments;
  bool isManual = false;

  if (args != null) {
    isManual = args['isManual'] ?? false;

    final raw = args['sessionModel'];
    sessionModel = raw is SessionModel ? raw : null;
    vehicleModels = args['vehicleModels'] as ModelResult?;

    final dongles = args['wifiConnector'];
    if (dongles is List) {
      wifiDevicesList.assignAll(
        dongles.whereType<WifiDevicesModel>().toList(),
      );
    }
  }

  if (isManual) {
    isLoading.value = false;
  } else if (wifiDevicesList.isNotEmpty) {
    // ✅ Already have devices — skip scanning entirely
    isLoading.value = false;
    scanComplete.value = true;
  } else {
    // ✅ Only scan if no devices were passed
    refreshDeviceList();
  }
}

  Future<void> refreshDeviceList() async {
    try {
      isLoading.value = true;
      scanComplete.value = false; // ✅ Reset before scan
      wifiDevicesList.clear();

      if (App.wifiConnectorService != null) {
        final List<BluetoothDevicesModel>? discovered =
            await App.wifiConnectorService!.getDeviceList();

        if (discovered != null && discovered.isNotEmpty) {
          for (var item in discovered) {
            wifiDevicesList.add(WifiDevicesModel(name: item.name, ip: item.ip));
          }
          debugPrint("✅ Found ${wifiDevicesList.length} devices");
        } else {
          debugPrint("❌ No devices found");
        }
      }
    } catch (e) {
      debugPrint("Error updating list: $e");
    } finally {
      isLoading.value = false;
      scanComplete.value = true; // ✅ Mark scan as done
    }

    // ✅ Show popup AFTER scan completes with no results
    if (wifiDevicesList.isEmpty) {
      _showNoDeviceDialog();
    }
  }

  void _showNoDeviceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Failed"),
        content: const Text("No VCI dongle found on the network."),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              refreshDeviceList(); // Scan again
            },
            child: Text(
              "Scan Again",
              style: TextStyles.labelStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              addDevice(); // Add manually
            },
            child: Text(
              "Add Manually",
              style: TextStyles.labelStyle,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void addDiscoveredDevice(String? name, String? host) {
    // This jump to the Main Thread is mandatory for discovery plugins
    Get.asap(() {
      final cleanHost = host?.replaceAll('.local', '') ?? '';

      if (cleanHost.isNotEmpty &&
          !wifiDevicesList.any((d) => d.ip == cleanHost)) {
        wifiDevicesList.add(WifiDevicesModel(name: name, ip: cleanHost));
        debugPrint("✅ Main Thread: Added $name ($cleanHost)");
      }
    });
  }

  // ── 1. Connect Dongle Clicked ─────────────────────────────────────────────
  Future<void> connectDongleClicked(WifiDevicesModel device) async {
    selectedDevice = device;
    returnValue = false;
    await wifiConnect(device);
  }

  // ── 2. WiFiConnect ────────────────────────────────────────────────────────
  // Future<void> wifiConnect(WifiDevicesModel device) async {
  //   if (App.wifiConnectorService == null) {
  //     Get.snackbar("Error", "WiFi service not initialized",
  //         backgroundColor: Colors.red, colorText: Colors.white);
  //     return;
  //   }

  //   Get.dialog(
  //     const Center(child: CircularProgressIndicator()),
  //     barrierDismissible: false,
  //   );

  //   bool isConnected = false;

  //   try {
  //     await Future.delayed(const Duration(milliseconds: 10));

  //     // 1. Get Dongle Mac ID
  //     final macId = await App.wifiConnectorService!.getDongleMacID(
  //       device.ip ?? '',
  //       true,
  //       true,
  //       "00",
  //     );

  //     if (macId == null || macId.isEmpty) {
  //       if (Get.isDialogOpen == true) Get.back();
  //       Get.defaultDialog(
  //         title: "Failed",
  //         middleText: "WIFI Dongle connection not established",
  //         textConfirm: "OK",
  //         onConfirm: () => Get.back(),
  //       );
  //       return;
  //     }

  //     isConnected = true;

  //     // 2. Set Dongle Properties
  //     firmwareVersion = await App.wifiConnectorService!.setDongleProperties(
  //           protocolName: "",
  //           txHeaderTemp: "",
  //           rxHeaderTemp: "",
  //         ) ??
  //         "";
  //     App.firmwareVersion = firmwareVersion;
  //     App.connectedVia = "WIFI";

  //     debugPrint("Dongle Mac ID: $macId");

  //     // 3. Register Dongle
  //     if (localDataJson.isEmpty) {
  //       returnValue = false;
  //       returnValue = await _registerDongleToServer(macId);
  //     } else {
  //       localRegisterDongleResponse = (jsonDecode(localDataJson) as List)
  //           .map((e) => RegDongleRespons.fromJson(e as Map<String, dynamic>))
  //           .toList();

  //       if (localRegisterDongleResponse.isNotEmpty) {
  //         returnValue = true;
  //         registerDongleResponse = localRegisterDongleResponse
  //             .firstWhereOrNull((x) => x.macId == macId);

  //         if (registerDongleResponse == null) {
  //           returnValue = false;
  //           returnValue = await _registerDongleToServer(macId);
  //         }
  //       }
  //     }

  //     // 4. Set properties again + post-connection tasks
  //     firmwareVersion = await App.wifiConnectorService!.setDongleProperties(
  //           protocolName: "",
  //           txHeaderTemp: "",
  //           rxHeaderTemp: "",
  //         ) ??
  //         "";
  //     App.firmwareVersion = firmwareVersion;
  //     App.connectedVia = "WIFI";

  //     await _getEngineHours();
  //     await _reportLocation();
  //   } catch (e) {
  //     debugPrint("WifiConnect error: $e");
  //   } finally {
  //     if (Get.isDialogOpen == true) Get.back();
  //   }

  //   // 5. Navigate
  //   if (isConnected && firmwareVersion.isNotEmpty) {
  //     App.ipAddress = device.ip ?? '';
  //     Get.toNamed(Routes.appFeaturePage, arguments: {
  //       'sessionModel': sessionModel,
  //       'vehicleModels': vehicleModels,
  //       'firmwareVersion': firmwareVersion,
  //       'ip': device.ip,
  //     });
  //   } else {
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Firmware version not found.",
  //       textConfirm: "OK",
  //       onConfirm: () => Get.back(),
  //     );
  //   }
  // }

  Future<void> wifiConnect(WifiDevicesModel device) async {
  if (App.wifiConnectorService == null) {
    //_showSnackBar("Error", "WiFi service not initialized");
    return;
  }

  // Show loading
  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

  try {
    // Step 1: Get Mac ID
    String macId = await App.wifiConnectorService!.getDongleMacID(
      device.ip ?? '',
      true, 
      true, 
      "00", 
    );

    if (macId.isEmpty || macId.contains("disconnected")) {
      if (Get.isDialogOpen == true) Get.back();
      _showErrorDialog("WiFi Dongle connection not established.");
      return;
    }

    debugPrint("✅ MAC ID: $macId");

    // Step 2 & 3 COMBINED: Set properties AND get firmware in one call
    // Your logs show this function is working perfectly and returning "04.00.02"
    String? firmware = await App.wifiConnectorService!.setDongleProperties1();

    if (firmware == null || firmware.isEmpty) {
      if (Get.isDialogOpen == true) Get.back();
      _showErrorDialog("Could not set dongle properties or retrieve firmware.");
      return;
    }

    debugPrint("✅ Firmware retrieved successfully: $firmware");

    // Step 4: Store global state
    firmwareVersion = firmware;
    App.firmwareVersion = firmware;
    App.connectedVia = "WIFI";
    App.ipAddress = device.ip ?? '';

    // Step 5: Background tasks
    await _registerDongleToServer(macId);
    await _getEngineHours();
    await _reportLocation();

    // Step 6: Finalize
    if (Get.isDialogOpen == true) Get.back();

    Get.toNamed(Routes.appFeaturePage, arguments: {
      'sessionModel': sessionModel,
      'vehicleModels': vehicleModels,
      'firmwareVersion': firmwareVersion,
      'ip': device.ip,
    });
  } catch (e, stack) {
    debugPrint("WifiConnect error: $e\n$stack");
    if (Get.isDialogOpen == true) Get.back();
    _showErrorDialog("An unexpected error occurred: $e");
  }
}
  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: "Connection Failed",
      middleText: message,
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }

  // ── 3. Register Dongle To Server ──────────────────────────────────────────
  Future<bool> _registerDongleToServer(String macId) async {
    try {
      returnValue = false;

      final hasInternet = await _isInternetAvailable();

      if (hasInternet) {
        registerDongleResponse = await _services.registerDongle(
          // Create the model instance here
          RegisterDongleModel(
            macId: macId,
            deviceType: "obd_dongle_wifie",
          ),
          App.jwtToken,
        );

        if (registerDongleResponse == null) return false;

        if (registerDongleResponse!.status != "success") {
          Get.defaultDialog(
            title: "Alert!",
            middleText: registerDongleResponse!.message ?? "",
            textConfirm: "OK",
            onConfirm: () => Get.back(),
          );
          return false;
        }

        if (registerDongleResponse!.status == "success" &&
            registerDongleResponse!.isActive == false &&
            (registerDongleResponse!.error?.isNotEmpty == true)) {
          Get.defaultDialog(
            title: "Alert",
            middleText: registerDongleResponse!.error ?? "",
            textConfirm: "OK",
            onConfirm: () => Get.back(),
          );
          return false;
        }

        if (registerDongleResponse!.status == "success" &&
            registerDongleResponse!.isActive == true) {
          localRegisterDongleResponse.add(registerDongleResponse!);
          localDataJson = jsonEncode(
            localRegisterDongleResponse.map((e) => e.toJson()).toList(),
          );
          await AndroidOperationsService.saveData(
              "RegisteresDongle_LocalData", localDataJson);
          return true;
        }
      } else {
        // Offline — allow connection
        return true;
      }

      return false;
    } catch (e) {
      Get.defaultDialog(
        title: "Error",
        middleText: e.toString(),
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
      return false;
    }
  }

  // ── 4. Get Engine Hours ───────────────────────────────────────────────────
  Future<void> _getEngineHours() async {
    try {
      final paramListData =
          await AndroidOperationsService.getData("Parameter_LocalList");
      if (paramListData == null || paramListData.isEmpty) return;

      final res = ParameterModel.fromJson(jsonDecode(paramListData));
      if (res.message != "success") return;

      final engHrsParameter =
          res.results?.firstWhereOrNull((x) => x.parameter == "Engine Hours");
      if (engHrsParameter == null) return;

      // Find matching ECU
      ParameterId? engHrsMapped;
      EcuDataSet? ecuInfo;

      for (var ecu in StaticData.ecuInfo) {
        engHrsMapped = engHrsParameter.parameterIds
            ?.firstWhereOrNull((x) => x.ecu == ecu.ecuId);
        if (engHrsMapped != null) {
          ecuInfo = ecu;
          break;
        }
      }

      if (engHrsMapped == null || ecuInfo == null) return;

      final pidCode = ecuInfo.pidList?.firstWhereOrNull(
        (x) =>
            x.piCodeVariable?.any((y) => y.id == engHrsMapped!.pidCode) == true,
      );
      if (pidCode == null) return;

      // Set dongle properties for this ECU
      await App.wifiConnectorService!.setDongleProperties(
        protocolName: ecuInfo.protocol?.autopeepal ?? "",
        txHeaderTemp: ecuInfo.txHeader ?? "",
        rxHeaderTemp: ecuInfo.rxHeader ?? "",
      );

      // Read PID
      final readPidResp = await App.wifiConnectorService!
          .readPid(pidList: [pidCode], pidByAddrSeq: "");

      if (readPidResp == null || readPidResp.isEmpty) return;
      if (readPidResp.first?.status != "NOERROR") return;

      final ecuEngineHours =
          readPidResp.first?.variables?.first?.responseValue ?? "";

      final engineHrsModel = UploadEngineHrsModel(
        hrs: ecuEngineHours,
        session: sessionModel?.id,
        date: DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateTime.now()),
      );

      final hasInternet = await _isInternetAvailable();

      if (hasInternet) {
        await _services.uploadEngineHrs(engineHrsModel);
      } else {
        // Save offline
        final key = "OfflineAnalyze_EngineHrs";
        final existing = await AndroidOperationsService.getData(key);

        List<EngineHrsOfflineAnalyze> data = [];
        if (existing != null && existing.isNotEmpty) {
          data = (jsonDecode(existing) as List)
              .map((e) => EngineHrsOfflineAnalyze.fromJson(e))
              .toList();
        }

        data.add(EngineHrsOfflineAnalyze(
          engineHours: engineHrsModel,
          srnId: sessionModel?.id,
          srNumber: sessionModel?.srNumber,
        ));

        await AndroidOperationsService.saveData(key, jsonEncode(data));
      }
    } catch (e) {
      debugPrint("GetEngineHours error: $e");
    }
  }

  // ── 5. Report Location ────────────────────────────────────────────────────
  Future<void> _reportLocation() async {
    try {
      final address = await AndroidOperationsService.getCurrentAddress();
      if (address == null || address.trim().isEmpty) return;

      final locationModel = ReportLocationModel(
        session: sessionModel?.id,
        location: address,
        date: DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateTime.now()),
      );

      final hasInternet = await _isInternetAvailable();

      if (hasInternet) {
        await _services.postApi(
          "/api/v1/analyze/srsession-location/create/",
          jsonEncode(locationModel.toJson()),
        );
      } else {
        // Save offline
        final key = "OfflineAnalyze_Location";
        final existing = await AndroidOperationsService.getData(key);

        List<LocationOfflineAnalyze> data = [];
        if (existing != null && existing.isNotEmpty) {
          data = (jsonDecode(existing) as List)
              .map((e) => LocationOfflineAnalyze.fromJson(e))
              .toList();
        }

        data.add(LocationOfflineAnalyze(
          location: locationModel,
          srnId: sessionModel?.id,
          srNumber: sessionModel?.srNumber,
        ));

        await AndroidOperationsService.saveData(key, jsonEncode(data));
      }
    } catch (e) {
      debugPrint("ReportLocation error: $e");
    }
  }

  // ── 6. Add Device Manually ────────────────────────────────────────────────
  void addDevice() {
    final ipController = TextEditingController();

    Get.defaultDialog(
      title: "IP Address",
      content: TextField(
        controller: ipController,
        decoration:
            const InputDecoration(hintText: "Enter IP address of device"),
        keyboardType: TextInputType.number,
      ),
      textConfirm: "Confirm",
      textCancel: "Cancel",
      onConfirm: () {
        final input = ipController.text.trim();
        if (input.isNotEmpty) {
          wifiDevicesList.add(WifiDevicesModel(
            name: "obd2",
            ip: input,
            macAddress: input,
          ));
          Get.back();
        }
      },
    );
  }

  // ── 7. Enable Hotspot ─────────────────────────────────────────────────────
  Future<void> enableHotspot() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Alert"),
        content: const Text(
          "This step will write the SSID and Password of the internet hotspot into your WIFI Dongle. "
          "Put your dongle in hotspot mode and connect phone to the dongle (OBD2_....) ?",
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Get.back(result: true), child: const Text("OK")),
        ],
      ),
    );

    if (result == true) {
      await App.wifiConnectorService!.connectDongle();
      //Get.toNamed(Routes.configureWifiDongle);
    }
  }

  // ── Helper: Internet check ────────────────────────────────────────────────
  Future<bool> _isInternetAvailable() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
