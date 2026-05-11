// import 'dart:convert';
// import 'dart:io';
// import 'package:autopeepal/app.dart';
// import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
// import 'package:autopeepal/models/bluetoothDevices_model.dart';
// import 'package:autopeepal/models/connectionCondition_model.dart';
// import 'package:autopeepal/models/parameter_model.dart';
// import 'package:autopeepal/models/registerDongle_model.dart';
// import 'package:autopeepal/models/sessionList_model.dart';
// import 'package:autopeepal/models/staticData.dart';
// import 'package:autopeepal/models/uploadEngineHr_model.dart';
// import 'package:autopeepal/models/wifiDevice_model.dart';
// import 'package:autopeepal/routes/routes_string.dart';
// import 'package:autopeepal/services/androidOperationservice.dart';
// import 'package:autopeepal/services/api_services.dart';
// import 'package:autopeepal/themes/app_textstyles.dart';
// import 'package:autopeepal/utils/controls/windows_usb.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../models/all_models.dart';

// class ConnectionController extends GetxController {
//   ModelResult? model;
//   SessionModel? session;

//   final channelList = <ChannelModel>[].obs;
//   final selectedChannel = Rxn<ChannelModel>();
//   RxBool channelListVisible = true.obs;

//   RxBool channelPopupVisible = false.obs;
//   RxString bottomMessage = 'Download Flash Dataset'.obs;

//   void openPopup() => channelPopupVisible.value = true;
//   void closePopup() => channelPopupVisible.value = false;
//   final channelViewVisible = false.obs;
//   final otherPropertiesVisible = false.obs;
//   final selectChannelVisible = false.obs;
//   final AuthApiService services = AuthApiService();
//   // UI strings
//   String title = "";
//   String applicationCode = "";
//   String engineSerialNo = "";
//   String type = "";
//   String rating = "";
//   String assembly = "";
//   String rpm = "";
//   String applicationName = "";
//   String yom = "";
//   String noOfInjector = "";
//   String noOfFuelPump = "";
//   String noOfEcu = "";
//   String calibration = "";

//   @override
//   void onInit() {
//     super.onInit();

//     final args = Get.arguments;

//     session = args?['session'];
//     model = args?['model'];

//     if (session == null || model == null) {
//       print("❌ Missing session/model in arguments");
//       return;
//     }
//     sessionModel.value = session;
//     _mapSessionData();
//     initChannelData();
//   }

//   // ---------------- SAFE MAPPING ----------------
//   void _mapSessionData() {
//     final variant = session?.variant;

//     title = session?.srNumber ?? "";

//     applicationCode = "Application Code : ${variant?.variantCode ?? "-"}";
//     engineSerialNo = "Engine serial No : ${session?.esn ?? "-"}";

//     type = "Type : ${variant?.typeName ?? "-"}";
//     rating = "Rating : ${variant?.rating ?? "-"}";
//     assembly = "Assembly : ${variant?.assemblyNo ?? "-"}";
//     rpm = "RPM : ${variant?.rpm ?? "-"}";

//     applicationName = "Application : ${variant?.applicationName ?? "-"}";

//     yom = "YOM : ${yom}";

//     noOfInjector = "No of Injector : ${variant?.noOfInjectors ?? "-"}";
//     noOfFuelPump = "No of Fuel Pump : ${variant?.noOfFip ?? "-"}";

//     noOfEcu = "No of ECU : ${variant?.subModel?.ecus?.length ?? 0}";

//     calibration =
//         "Calibration : ${variant?.calibration?.isNotEmpty == true ? variant!.calibration : "NA"}";
//   }

//   // ---------------- CHANNEL BUILD (FIXED) ----------------
//   void initChannelData() {
//     try {
//       final subModels = model?.subModels ?? [];

//       final List<ChannelModel> temp = [];

//       for (final sub in subModels) {
//         final ecus = sub.ecus ?? [];

//         if (ecus.isEmpty) {
//           print("❌ Skipping SubModel ${sub.id} (no ECUs)");
//           continue;
//         }

//         final Map<String, List<Ecu>> grouped = {};

//         for (final ecu in ecus) {
//           final key = ecu.channel ?? "UNKNOWN";
//           grouped.putIfAbsent(key, () => []);
//           grouped[key]!.add(ecu);
//         }

//         grouped.forEach((key, list) {
//           temp.add(ChannelModel(itemName: key, ecus: list));
//         });
//       }

//       temp.sort((a, b) => (a.itemName ?? "").compareTo(b.itemName ?? ""));

//       channelList.value = temp;

//       print("👉 CHANNEL COUNT: ${channelList.length}");

//       selectChannelVisible.value = channelList.length > 1;
//       otherPropertiesVisible.value = channelList.length <= 1;
//     } catch (e) {
//       print("❌ initChannelData error: $e");
//     }
//   }

//   // ---------------- SELECT CHANNEL ----------------
//   void selectChannel(ChannelModel channel) {
//     selectedChannel.value = channel;

//     final sModelId = session?.variant?.sModelId;

//     final subModel = model?.subModels?.firstWhere(
//       (x) => x.id == sModelId,
//       orElse: () => model!.subModels!.first,
//     );

//     if (subModel == null) {
//       print("❌ SubModel not found");
//       return;
//     }

//     subModel.ecus = List<Ecu>.from(channel.ecus ?? []);

//     print("👉 CHANNEL SELECTED: ${channel.itemName}");
//     print("👉 ECU AFTER FILTER: ${subModel.ecus?.length}");

//     initStaticData();
//   }

//   // ---------------- STATIC DATA (SAFE) ----------------
//   void initStaticData() {
//     try {
//       print("🚀 initStaticData started");

//       StaticData.ecuInfo = [];

//       final sModelId = session?.variant?.sModelId;

//       final subModels = model?.subModels;

//       if (subModels == null || subModels.isEmpty) {
//         print("❌ subModels empty");
//         return;
//       }

//       final subModel = subModels.firstWhere(
//         (x) => x.id == sModelId,
//         orElse: () {
//           print("⚠️ sModelId not found, using first subModel");
//           return subModels.first;
//         },
//       );

//       final ecus = subModel.ecus ?? [];

//       print("📦 Total ECUs found: ${ecus.length}");

//       for (final ecu in ecus) {
//         try {
//           if (ecu.pidDatasets == null || ecu.pidDatasets!.isEmpty) {
//             print("⚠️ PID dataset missing for ECU: ${ecu.id}");
//             continue;
//           }

//           final ecuData = EcuDataSet(
//             ecuId: ecu.id,
//             ecuName: ecu.name,
//             txHeader: ecu.txHeader,
//             rxHeader: ecu.rxHeader,
//             protocol: ecu.protocol,
//             pidDatasetId: ecu.pidDatasets!.first.id,
//             dtcDatasetId: ecu.datasets?.isNotEmpty == true
//                 ? ecu.datasets!.first.id
//                 : null,
//             clearDtcIndex: ecu.clearDtcFnIndex?.value,
//             readDtcIndex: ecu.readDtcFnIndex?.value,
//           );

//           StaticData.ecuInfo.add(ecuData);

//           print("✅ Added ECU: ${ecu.name}");
//         } catch (e) {
//           print("❌ ECU mapping error (${ecu.id}): $e");
//         }
//       }

//       print("🎉 FINAL ECU COUNT: ${StaticData.ecuInfo.length}");
//     } catch (e) {
//       print("❌ initStaticData global error: $e");
//     }
//   }

//   RxString imgDownload = "ic_download.png".obs;
//   RxString downloadMessage = "Download Flash Dataset".obs;
//   Rx<Color> downloadBgColor = const Color(0xFFFFFFFF).obs;

//   Future<void> checkLocalDataFile() async {
//     try {
//       showLoading("Loading...");

//       await Future.delayed(const Duration(milliseconds: 100));

//       // =========================
//       // GET LOCAL DATA
//       // =========================
//       final jsonListData =
//           await AndroidOperationsService.getData("Dataset_LocalList");

//       // =========================
//       // CASE 1: NO LOCAL DATA
//       // =========================
//       if (jsonListData == null || jsonListData.isEmpty) {
//         imgDownload.value = "ic_download.png";
//         downloadBgColor.value = const Color(0xFFFFFFFF);
//         downloadMessage.value = "Download Flash Dataset";

//         hideLoading();

//         final res = await Get.defaultDialog<bool>(
//           title: "Alert",
//           middleText:
//               "Flash files are available for download.\nDo you want to review the available flash files for downloading?",
//           textConfirm: "OK",
//           textCancel: "Cancel",
//         );

//         if (res == true) {
//           Get.toNamed(
//             Routes.localFlashing,
//             arguments: session,
//           );
//         }

//         return;
//       }

//       // =========================
//       // CASE 2: DATA EXISTS
//       // =========================
//       bool allFileDownloaded = true;

//       final List<VariantEcu> dataFileList = (jsonDecode(jsonListData) as List)
//           .map((e) => VariantEcu.fromJson(e))
//           .toList();

//       if (dataFileList.isNotEmpty) {
//         final variantEcuList = session?.variant?.variantEcu ?? [];

//         for (final ecu in variantEcuList) {
//           try {
//             final localEcu = dataFileList.firstWhere(
//               (x) =>
//                   x.ecuId == ecu.ecu!.id &&
//                   x.productionSwId?.id == ecu.productionSwId?.id &&
//                   (x.productionSwId?.dataFileLocal?.isNotEmpty ?? false),
//               orElse: () => VariantEcu(),
//             );

//             // =========================
//             // NOT DOWNLOADED
//             // =========================
//             if (localEcu.ecuId == null) {
//               imgDownload.value = "ic_download.png";
//               downloadBgColor.value = const Color(0xFFFFFFFF);
//               downloadMessage.value = "Download Flash Dataset";

//               if (ecu.isLatest == true) {
//                 allFileDownloaded = false;
//               }

//               break;
//             }

//             // =========================
//             // ALREADY DOWNLOADED
//             // =========================
//             else {
//               imgDownload.value = "ic_downloaded.png";
//               downloadBgColor.value = const Color(0xFF309F93);
//               downloadMessage.value = "Flashing file already downloaded";
//             }
//           } catch (e) {
//             print("ECU check error: $e");
//           }
//         }
//       }

//       hideLoading();

//       // =========================
//       // ASK USER IF NOT ALL FILES DOWNLOADED
//       // =========================
//       if (!allFileDownloaded) {
//         final res = await Get.defaultDialog<bool>(
//           title: "Alert",
//           middleText:
//               "Flash files are available for download.\nDo you want to review the available flash files for downloading?",
//           textConfirm: "OK",
//           textCancel: "Cancel",
//         );

//         if (res == true) {
//           Get.toNamed(
//             Routes.localDatasetFiles,
//             arguments: session,
//           );
//         }
//       }
//     } catch (e) {
//       hideLoading();
//       print("CheckLocalDatafile error: $e");
//     }
//   }

//   void showLoading([String msg = "Loading..."]) {
//     Get.dialog(
//       const Center(child: CircularProgressIndicator()),
//       barrierDismissible: false,
//     );
//   }

//   void hideLoading() {
//     if (Get.isDialogOpen ?? false) {
//       Get.back();
//     }
//   }

//   Future<List<SessionModel>?> getSessionList() async {
//     try {
//       final jsonListData =
//           await AndroidOperationsService.getData("Session_LocalList");

//       if (jsonListData == null || jsonListData.isEmpty) {
//         return null;
//       }

//       final res = SessionListModel.fromJson(jsonDecode(jsonListData));

//       if (res.message == "success") {
//         if (res.results.isNotEmpty) {
//           final sortedList = res.results
//             ..sort((a, b) => b.id!.compareTo(a.id!));

//           return List<SessionModel>.from(sortedList);
//         } else {
//           await Get.dialog(
//             const AlertDialog(
//               title: Text("Failed"),
//               content: Text("Session list not found."),
//             ),
//           );
//           return null;
//         }
//       } else {
//         await Get.dialog(
//           AlertDialog(
//             title: const Text("Error"),
//             content: Text(res.message ?? "Unknown error"),
//           ),
//         );
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   var returnValue = false.obs;

//   Future<void> connVaiUsbClicked() async {
//     final connectionCondition = ConnectionCondition(
//       isLengthFFF: true,
//       isChannels: true,
//       isObdCharger: false,
//       channelId: "00",
//     );

//     returnValue.value = false;

//     usbConnect(connectionCondition, false);
//   }

//   Future<void> connVaiWifiClicked() async {
//     Get.dialog(
//       const Center(child: CircularProgressIndicator()),
//       barrierDismissible: false,
//     );

//     try {
//       await Future.delayed(const Duration(milliseconds: 100));
//       App.connectedVia = "WIFI";

//       if (App.wifiConnectorService == null) {
//         if (Get.isDialogOpen == true) Get.back();
//         return;
//       }

//       final List<BluetoothDevicesModel>? wifiDevices =
//           await App.wifiConnectorService!.getDeviceList();

//       if (Get.isDialogOpen == true) Get.back();

//       if (wifiDevices != null && wifiDevices.isNotEmpty) {
//         // ✅ Convert BluetoothDevicesModel → WifiDevicesModel HERE
//         final List<WifiDevicesModel> converted = wifiDevices
//             .map((d) => WifiDevicesModel(name: d.name, ip: d.ip))
//             .toList();

//         Get.toNamed(
//           Routes.wifiDevicePage,
//           arguments: {
//             "sessionModel": sessionModel.value,
//             "vehicleModels": model,
//             "wifiConnector": converted, // ✅ Now WifiDevicesModel list
//             "isManual": false,
//           },
//         );
//       } else {
//         final bool? resp = await Get.dialog<bool>(
//           AlertDialog(
//             title: const Text("Failed"),
//             content: const Text("Dongle not found"),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(result: true),
//                 child: Text("Add Manually", style: TextStyles.labelStyle),
//               ),
//               TextButton(
//                 onPressed: () => Get.back(result: false),
//                 child: Text("Scan again", style: TextStyles.labelStyle),
//               ),
//             ],
//           ),
//         );

//         if (resp == true) {
//           Get.toNamed(
//             Routes.wifiDevicePage,
//             arguments: {
//               "sessionModel": sessionModel.value,
//               "vehicleModels": model,
//               "wifiConnector": <WifiDevicesModel>[], // ✅ typed empty list
//               "isManual": true,
//             },
//           );
//         } else if (resp == false) {
//           Future.delayed(const Duration(milliseconds: 100), connVaiWifiClicked);
//         }
//       }
//     } catch (ex) {
//       if (Get.isDialogOpen == true) Get.back();
//       debugPrint("Error in WiFi Connection: $ex");
//     }
//   }

//   Future<void> connVaiWifiClicked1() async {
//     // 1. Show Loading Dialog
//     Get.dialog(
//       const Center(child: CircularProgressIndicator()),
//       barrierDismissible: false,
//     );

//     try {
//       // Small delay to allow the UI to render the loader
//       await Future.delayed(const Duration(milliseconds: 100));

//       App.connectedVia = "WIFI";

//       if (App.wifiConnectorService == null) {
//         if (Get.isDialogOpen == true) Get.back();
//         return;
//       }

//       final List<BluetoothDevicesModel>? wifiDevices =
//           await App.wifiConnectorService!.getDeviceList();

//       // ALWAYS close the loader as soon as the data is fetched
//       if (Get.isDialogOpen == true) Get.back();

//       if (wifiDevices != null && wifiDevices.isNotEmpty) {
//         // Success: Navigate to device list
//         Get.toNamed(
//           Routes.wifiDevicePage,
//           arguments: {
//             "sessionModel": sessionModel.value,
//             "vehicleModels": model,
//             "wifiConnector": wifiDevices,
//             "isManual": false,
//           },
//         );
//       } else {
//         // Failure: Show Dialog
//         final bool? resp = await Get.dialog<bool>(
//           AlertDialog(
//             title: const Text("Failed"),
//             content: const Text("Dongle not found"),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(result: true), // Add Manually
//                 child: Text("Add Manually", style: TextStyles.labelStyle),
//               ),
//               TextButton(
//                 onPressed: () => Get.back(result: false), // Scan again
//                 child: Text("Scan again", style: TextStyles.labelStyle),
//               ),
//             ],
//           ),
//         );

//         if (resp == true) {
//           // Navigate for manual entry
//           Get.toNamed(
//             Routes.wifiDevicePage,
//             arguments: {
//               "sessionModel": sessionModel.value,
//               "vehicleModels": model,
//               "wifiConnector": [],
//               "isManual": true,
//             },
//           );
//         } else if (resp == false) {
//           // Use a slight delay before retrying to prevent UI flickering
//           Future.delayed(const Duration(milliseconds: 100), () {
//             connVaiWifiClicked();
//           });
//         }
//       }
//     } catch (ex) {
//       if (Get.isDialogOpen == true) Get.back();
//       debugPrint("Error in WiFi Connection: $ex");
//     }
//   }

//   String firmwareVersion = "";
//   String localDataJson = "";

//   Future<void> usbConnect(ConnectionCondition condition, bool write) async {
//     bool isConnected = false;
//     String firmwareVersion = "";

//     try {
//       Get.dialog(const Center(child: CircularProgressIndicator()),
//           barrierDismissible: false);
//       await Future.delayed(const Duration(milliseconds: 10));

//       App.usbConnectorService ??= UsbWindows();

//       print("🔍 Calling GetDongleMacID...");
//       var macId = await App.usbConnectorService!.getDongleMacID(
//         condition.isLengthFFF ?? false,
//         condition.isChannels ?? false,
//         condition.channelId ?? '',
//         condition.isObdCharger ?? false,
//       );

//       // ✅ REMOVED the "00:00..." check. As long as we get a response, we move forward.
//       if (macId.isNotEmpty) {
//         print("✅ Handshake Success. MacID: $macId");
//         isConnected = true;

//         print("🔍 Calling setDongleProperties1 to fetch firmware...");
//         firmwareVersion = await App.usbConnectorService!.setDongleProperties1();

//         print("📊 DEBUG: firmwareVersion received: '$firmwareVersion'");

//         App.firmwareVersion = firmwareVersion;
//         App.connectedVia = "USB";

//         await getEngineHours();
//         await reportLocation();
//       }

//       if (Get.isDialogOpen ?? false) Get.back();

//       // ── NAVIGATION LOGIC ──
//       if (isConnected && firmwareVersion.isNotEmpty) {
//         if (write) {
//           Get.toNamed(Routes.writeSSIDPASS);
//         }
//         Get.toNamed(Routes.appFeaturePage, arguments: {
//           "sessionModel": sessionModel.value,
//           "vehicleModels": model, // ✅ FIXED
//           "firmwareVersion": firmwareVersion, // ✅ also fix this
//           "extra": "",
//         });
//       } else if (isConnected && firmwareVersion.isEmpty) {
//         // Hardware responded to MacID but NOT to Firmware command
//         print(
//             "❌ Error: MacID was found, but setDongleProperties1 returned an empty string.");
//         await Get.defaultDialog(
//           title: "Communication Error",
//           middleText:
//               "Dongle connected, but failed to retrieve Firmware Version. Please retry.",
//           textConfirm: "OK",
//           onConfirm: () => Get.back(),
//         );
//       } else {
//         await Get.defaultDialog(
//           title: "Failed",
//           middleText: "Dongle connection not established.",
//           textConfirm: "OK",
//           onConfirm: () => Get.back(),
//         );
//       }
//     } catch (ex) {
//       if (Get.isDialogOpen ?? false) Get.back();
//       print("❌ Exception in usbConnect: $ex");
//     }
//   }

//   List<RegDongleRespons> localRegisterDongleResponse = [];
//   RegisterDongleModel registerDongleRequest = RegisterDongleModel();
//   Future<bool> registerDongleToServer() async {
//     bool returnValue = false;

//     try {
//       // 1. Check Internet Connectivity
//       // Note: 'isReachable.InternetNetwork()' looks like a custom extension in your C# code.
//       // In Flutter, we usually use the 'connectivity_plus' package or a custom utility.
//       bool isReachable = await InternetChecker.hasInternet();

//       if (isReachable) {
//         // 2. API Call (Equivalent to service.RegisterDongle)
//         // App.JwtToken should be retrieved from your secure storage or global state
//         var response = await services.registerDongle(
//           registerDongleRequest,
//           App.jwtToken,
//         );

//         // 3. Handle Status != "success"
//         if (response.status != "success") {
//           await _displayAlert(
//               "Alert!", response.message ?? "Registration failed");
//           return false;
//         }

//         // 4. Handle success but Inactive with Error
//         if (response.status == "success" &&
//             response.isActive == false &&
//             (response.error?.isNotEmpty ?? false)) {
//           await _displayAlert("Alert", response.error!);
//           return false;
//         }

//         // 5. Handle Final Success
//         if (response.status == "success" && response.isActive == true) {
//           // Initialize local list if null

//           localRegisterDongleResponse.add(response);

//           // Serialize to JSON (JsonConvert.SerializeObject)
//           String localDataJson = jsonEncode(localRegisterDongleResponse);

//           // Save to local storage (Equivalent to SaveData extension)
//           await AndroidOperationsService.saveData(
//             "RegisteresDongle_LocalData",
//             localDataJson,
//           );

//           returnValue = true;
//         }
//       } else {
//         // 6. Handle No Internet
//         await _displayAlert(
//           "Error",
//           "Please turn ON internet of mobile.\nWe need to approve dongle Dongle.",
//         );
//         returnValue = false;
//       }

//       return returnValue;
//     } catch (ex) {
//       // 7. Handle Exceptions
//       debugPrint("💥 Registration Error: $ex");
//       await _displayAlert("Error", ex.toString());
//       return false;
//     }
//   }

// // Helper to mimic Xamarin.Forms DisplayAlert
//   Future<void> _displayAlert(String title, String message) async {
//     return await Get.defaultDialog(
//       title: title,
//       middleText: message,
//       textConfirm: "OK",
//       onConfirm: () => Get.back(),
//     );
//   }

//   // Add this method to your class

//   var sessionModel = Rxn<SessionModel>();

//   Future<void> onDownloadFilesClicked() async {
//     try {
//       print("🚀 onDownloadFilesClicked STARTED");

//       print("📦 sessionModel before navigation: ${sessionModel.value}");

//       // 🔹 Show loader (MAUI: UserDialogs.Loading)
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );

//       print("⏳ Loader shown");

//       await Future.delayed(const Duration(milliseconds: 200));

//       print("📤 Navigating to localFlashing with arguments:");
//       print({
//         "sessionModel": sessionModel.value,
//       });

//       // 🔹 Navigate FIRST
//       await Get.toNamed(
//         Routes.localFlashing,
//         arguments: {
//           "sessionModel": sessionModel.value,
//         },
//       );

//       print("✅ Navigation completed");
//     } catch (ex) {
//       print("❌ ERROR in onDownloadFilesClicked: $ex");

//       Get.defaultDialog(
//         title: "Error",
//         middleText: ex.toString(),
//         textConfirm: "OK",
//         onConfirm: () => Get.back(),
//       );
//     } finally {
//       print("🧹 finally block executed");

//       // 🔹 ALWAYS close loader after navigation
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//         print("🔒 Loader closed");
//       } else {
//         print("⚠️ Loader was already closed");
//       }
//     }
//   }

//   Future<void> onWriteClicked() async {
//     try {
//       // 1. Initialize Condition (Equivalent to C# object initialization)
//       ConnectionCondition connectionCondition = ConnectionCondition(
//         isLengthFFF: true,
//         isChannels: true,
//         isObdCharger: false,
//         channelId: "00",
//       );

//       // 2. Set Observable State (Equivalent to C# property change)
//       returnValue.value = false;

//       // 3. Background Execution Logic
//       // In Flutter, async MethodChannels run on the platform thread automatically.
//       // We don't manually spawn a Thread; we call the method and handle the result.
//       print("📢 Initiating USB Handshake...");

//       // We don't 'await' here if you want it to run strictly in the background
//       // without waiting for the result to finish the UI function.
//       usbConnect(connectionCondition, true).catchError((error) {
//         print("💥 USB Background Error: $error");
//       });
//     } catch (e) {
//       print("❌ Setup Error: $e");
//     }
//   }

//   Future<void> getEngineHours() async {
//     try {
//       // 1. Fetch Local Parameter Data
//       String? parameterListData =
//           await AndroidOperationsService.getData("Parameter_LocalList");

//       if (parameterListData == null || parameterListData.isEmpty) return;

//       // 2. Parse JSON (JsonConvert.DeserializeObject equivalent)
//       var resMap = jsonDecode(parameterListData);
//       ParameterModel res = ParameterModel.fromJson(resMap);

//       if (res.message == "success") {
//         // Find "Engine Hours" parameter
//         var engHrsParameter = res.results?.firstWhereOrNull(
//           (x) => x.parameter == "Engine Hours",
//         );

//         if (engHrsParameter != null) {
//           ParameterId? engHrsParameterMapped;
//           EcuDataSet? ecuInfo;

//           // 3. Match Parameter with Active ECU Info
//           for (var ecu in StaticData.ecuInfo) {
//             engHrsParameterMapped =
//                 engHrsParameter.parameterIds?.firstWhereOrNull(
//               (x) => x.ecu == ecu.ecuId,
//             );

//             if (engHrsParameterMapped != null) {
//               ecuInfo = ecu;
//               break;
//             }
//           }

//           if (engHrsParameterMapped != null && ecuInfo != null) {
//             // 4. Find the specific PID Code
//             var pidCode = ecuInfo.pidList?.firstWhereOrNull(
//               (x) =>
//                   x.piCodeVariable
//                       ?.any((y) => y.id == engHrsParameterMapped?.pidCode) ??
//                   false,
//             );

//             if (pidCode != null) {
//               // 5. Setup Dongle and Read PID
//               await App.usbConnectorService!.setDongleProperties(
//                 protocolName: ecuInfo.protocol?.autopeepal,
//                 txHeaderTemp: ecuInfo.txHeader ?? '',
//                 rxHeaderTemp: ecuInfo
//                     .rxHeader, // Ensure this matches your model (String?)
//               );
//               // Equivalent to calling ReadPid
//               // Correct way to call the named parameters
//               var readPidResp = await App.usbConnectorService!.readPid(
//                 pidList: [
//                   pidCode
//                 ], // Passes your List<PidCode> to the pidList parameter
//                 pidByAddrSeq:
//                     null, // Optional, can be omitted since it's nullable
//               );

//               if (readPidResp.isNotEmpty) {
//                 if (readPidResp[0]!.status == "NOERROR") {
//                   String ecuEngineHours =
//                       readPidResp[0]!.variables?[0].responseValue ?? "";

//                   // 6. Build Upload Model
//                   var engineHrsModel = {
//                     "hrs": ecuEngineHours,
//                     "session": sessionModel.value!.id,
//                     "date": DateTime.now().toUtc().toIso8601String(),
//                   };

//                   // 7. Connectivity Check & Upload/Save
//                   bool isReachable = await InternetChecker.hasInternet();

//                   if (isReachable) {
//                     await services.uploadEngineHrs(
//                         engineHrsModel as UploadEngineHrsModel);
//                   } else {
//                     // Handle Offline Data saving
//                     List<dynamic> data = [];
//                     var engineHrsOfflineAnalyze = {
//                       "engine_hours": engineHrsModel,
//                       "srn_id": sessionModel.value!.id,
//                       "sr_number": sessionModel.value!.srNumber,
//                     };

//                     String? jsonData = await AndroidOperationsService.getData(
//                         "OfflineAnalyze_EngineHrs");

//                     if (jsonData != null && jsonData.isNotEmpty) {
//                       data = jsonDecode(jsonData);
//                     }

//                     data.add(engineHrsOfflineAnalyze);

//                     // Save back to local storage
//                     await AndroidOperationsService.saveData(
//                       "OfflineAnalyze_EngineHrs",
//                       jsonEncode(data),
//                     );
//                   }
//                 }
//               }
//             }
//           }
//         }
//       }
//     } catch (ex) {
//       debugPrint("💥 Error in getEngineHours: $ex");
//     }
//   }

//   Future<void> reportLocation() async {
//     try {
//       // 1. Get current address from native service
//       final String? address =
//           await AndroidOperationsService.getCurrentAddress();

//       if (address != null && address.trim().isNotEmpty) {
//         // 2. Prepare the location model
//         // Using a Map for simple JSON creation or your model's toJson()
//         Map<String, dynamic> locationModel = {
//           "session": sessionModel.value!.id,
//           "location": address,
//           // toUtc().toIso8601String() is the closest to C# Z format
//           "date": DateTime.now().toUtc().toIso8601String(),
//         };

//         // 3. Internet Connectivity Check
//         bool isReachable = await InternetChecker.hasInternet();

//         if (isReachable) {
//           // Upload via API
//           await services.postApi(
//             "/api/v1/analyze/srsession-location/create/",
//             jsonEncode(locationModel),
//           );
//         } else {
//           // 4. Handle Offline Storage
//           List<dynamic> data = [];

//           Map<String, dynamic> locationOfflineAnalyze = {
//             "Location": locationModel,
//             "srn_id": sessionModel.value!.id,
//             "sr_number": sessionModel.value!.srNumber,
//           };

//           // Fetch existing offline data
//           String? jsonData =
//               await AndroidOperationsService.getData("OfflineAnalyze_Location");

//           if (jsonData != null && jsonData.isNotEmpty) {
//             try {
//               data = jsonDecode(jsonData);
//             } catch (e) {
//               debugPrint("Error decoding offline location data: $e");
//               data = [];
//             }
//           }

//           // Add new entry and save back to Android local storage
//           data.add(locationOfflineAnalyze);

//           String updatedJson = jsonEncode(data);
//           await AndroidOperationsService.saveData(
//               "OfflineAnalyze_Location", updatedJson);
//         }
//       }
//     } catch (ex) {
//       debugPrint("💥 Exception in reportLocation: $ex");
//     }
//   }
// }

// class InternetChecker {
//   static Future<bool> hasInternet() async {
//     try {
//       // We try to lookup google's DNS. If it fails, there's no internet.
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }
// }

// class User {
//   String? email;
//   dynamic workshop;
//   dynamic role;

//   User({
//     this.email,
//     this.workshop,
//     this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       email: json['email'],
//       workshop: json['workshop'],
//       role: json['role'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'email': email,
//         'workshop': workshop,
//         'role': role,
//       };
// }

// class CloseJobCard {
//   String? id;
//   String? source;
//   String? sessionId;
//   String? jobCard;
//   DateTime? startDate;
//   DateTime? endDate;
//   User? user;
//   String? sessionType;
//   String? status;

//   CloseJobCard({
//     this.id,
//     this.source,
//     this.sessionId,
//     this.jobCard,
//     this.startDate,
//     this.endDate,
//     this.user,
//     this.sessionType,
//     this.status,
//   });

//   factory CloseJobCard.fromJson(Map<String, dynamic> json) {
//     return CloseJobCard(
//       id: json['id'],
//       source: json['source'],
//       sessionId: json['session_id'],
//       jobCard: json['job_card'],
//       startDate: json['start_date'] != null
//           ? DateTime.parse(json['start_date'])
//           : null,
//       endDate:
//           json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
//       user: json['user'] != null ? User.fromJson(json['user']) : null,
//       sessionType: json['session_type'],
//       status: json['status'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'source': source,
//         'session_id': sessionId,
//         'job_card': jobCard,
//         'start_date': startDate?.toIso8601String(),
//         'end_date': endDate?.toIso8601String(),
//         'user': user?.toJson(),
//         'session_type': sessionType,
//         'status': status,
//       };
// }
import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
import 'package:autopeepal/models/bluetoothDevices_model.dart';
import 'package:autopeepal/models/connectionCondition_model.dart';
import 'package:autopeepal/models/parameter_model.dart';
import 'package:autopeepal/models/registerDongle_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/uploadEngineHr_model.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:autopeepal/utils/controls/windows_usb.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/all_models.dart';

class ConnectionController extends GetxController {
  ModelResult? model;
  SessionModel? session;

  final channelList = <ChannelModel>[].obs;
  final selectedChannel = Rxn<ChannelModel>();

  final channelPopupVisible = false.obs;
  final channelListVisible = true.obs;
  final selectChannelVisible = false.obs;

  // ✅ FIX #5 — starts false, shown only after channel selected
  final otherPropertiesVisible = false.obs;

  RxString bottomMessage = 'Download Flash Dataset'.obs;
  RxString imgDownload = 'ic_download.png'.obs;
  RxString downloadMessage = 'Download Flash Dataset'.obs;
  Rx<Color> downloadBgColor = const Color(0xFFFFFFFF).obs;

  void openPopup() => channelPopupVisible.value = true;
  void closePopup() => channelPopupVisible.value = false;

  final AuthApiService services = AuthApiService();
  var sessionModel = Rxn<SessionModel>();
  var returnValue = false.obs;

  String firmwareVersion = '';
  String localDataJson = '';

  List<RegDongleRespons> localRegisterDongleResponse = [];
  RegisterDongleModel registerDongleRequest = RegisterDongleModel();

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────
  @override
void onInit() {
  super.onInit();

  final args = Get.arguments;
  session = args?['session'];
  model = args?['model'];

  if (session == null || model == null) {
    print('❌ Missing session/model in arguments');
    return;
  }

  sessionModel.value = session;
  _mapSessionData();
  initChannelData();

  // ✅ FIX — wait for build to finish before showing any dialog
  WidgetsBinding.instance.addPostFrameCallback((_) {
    checkLocalDataFile();
  });
}

  // ─────────────────────────────────────────────
  // SESSION DATA MAPPING
  // ─────────────────────────────────────────────
  void _mapSessionData() {
    final variant = session?.variant;

    bottomMessage.value = 'Download Flash Dataset';
    imgDownload.value = 'ic_download.png';
    downloadBgColor.value = const Color(0xFFFFFFFF);
  }

  // ─────────────────────────────────────────────
  // CHANNEL INIT
  // ─────────────────────────────────────────────
  void initChannelData() {
    try {
      final subModels = model?.subModels ?? [];
      final List<ChannelModel> temp = [];

      for (final sub in subModels) {
        final ecus = sub.ecus ?? [];
        if (ecus.isEmpty) {
          print('❌ Skipping SubModel ${sub.id} (no ECUs)');
          continue;
        }

        final Map<String, List<Ecu>> grouped = {};
        for (final ecu in ecus) {
          final key = ecu.channel ?? 'UNKNOWN';
          grouped.putIfAbsent(key, () => []);
          grouped[key]!.add(ecu);
        }

        grouped.forEach((key, list) {
          temp.add(ChannelModel(itemName: key, ecus: list));
        });
      }

      temp.sort((a, b) => (a.itemName ?? '').compareTo(b.itemName ?? ''));
      channelList.value = temp;

      print('👉 CHANNEL COUNT: ${channelList.length}');

      selectChannelVisible.value = channelList.length > 1;

      // ✅ FIX #5 — if only one channel, auto-select and show diagnostic section
      if (channelList.length == 1) {
        selectChannel(channelList.first);
      } else {
        otherPropertiesVisible.value = false;
      }
    } catch (e) {
      print('❌ initChannelData error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SELECT CHANNEL
  // ─────────────────────────────────────────────
  void selectChannel(ChannelModel channel) {
    selectedChannel.value = channel;
    channelPopupVisible.value = false; // close popup

    // ✅ FIX #6 — show diagnostic section after channel selected
    otherPropertiesVisible.value = true;

    final sModelId = session?.variant?.sModelId;
    final subModel = model?.subModels?.firstWhere(
      (x) => x.id == sModelId,
      orElse: () => model!.subModels!.first,
    );

    if (subModel == null) {
      print('❌ SubModel not found');
      return;
    }

    subModel.ecus = List<Ecu>.from(channel.ecus ?? []);

    print('👉 CHANNEL SELECTED: ${channel.itemName}');
    print('👉 ECU AFTER FILTER: ${subModel.ecus?.length}');

    initStaticData();
  }

  // ─────────────────────────────────────────────
  // STATIC DATA
  // ─────────────────────────────────────────────
  void initStaticData() {
    try {
      print('🚀 initStaticData started');
      StaticData.ecuInfo = [];

      final sModelId = session?.variant?.sModelId;
      final subModels = model?.subModels;

      if (subModels == null || subModels.isEmpty) {
        print('❌ subModels empty');
        return;
      }

      final subModel = subModels.firstWhere(
        (x) => x.id == sModelId,
        orElse: () {
          print('⚠️ sModelId not found, using first subModel');
          return subModels.first;
        },
      );

      final ecus = subModel.ecus ?? [];
      print('📦 Total ECUs found: ${ecus.length}');

      for (final ecu in ecus) {
        try {
          if (ecu.pidDatasets == null || ecu.pidDatasets!.isEmpty) {
            print('⚠️ PID dataset missing for ECU: ${ecu.id}');
            continue;
          }

          final ecuData = EcuDataSet(
            ecuId: ecu.id,
            ecuName: ecu.name,
            txHeader: ecu.txHeader,
            rxHeader: ecu.rxHeader,
            protocol: ecu.protocol,
            pidDatasetId: ecu.pidDatasets!.first.id,
            dtcDatasetId: ecu.datasets?.isNotEmpty == true
                ? ecu.datasets!.first.id
                : null,
            clearDtcIndex: ecu.clearDtcFnIndex?.value,
            readDtcIndex: ecu.readDtcFnIndex?.value,
          );

          StaticData.ecuInfo.add(ecuData);
          print('✅ Added ECU: ${ecu.name}');
        } catch (e) {
          print('❌ ECU mapping error (${ecu.id}): $e');
        }
      }

      print('🎉 FINAL ECU COUNT: ${StaticData.ecuInfo.length}');
    } catch (e) {
      print('❌ initStaticData global error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // CHECK LOCAL DATA FILE
  // ─────────────────────────────────────────────
  Future<void> checkLocalDataFile() async {
    try {
      showLoading('Loading...');
      await Future.delayed(const Duration(milliseconds: 100));

      final jsonListData =
          await AndroidOperationsService.getData('Dataset_LocalList');

      // ✅ FIX #2 — also handle '[]'
      if (jsonListData == null ||
          jsonListData.isEmpty ||
          jsonListData.trim() == '[]') {
        imgDownload.value = 'ic_download.png';
        downloadBgColor.value = const Color(0xFFFFFFFF);
        downloadMessage.value = 'Download Flash Dataset';
        bottomMessage.value = 'Download Flash Dataset';

        hideLoading();

        final res = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Alert'),
            content: const Text(
              'Flash files are available for download.\nDo you want to review the available flash files for downloading?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child:  Text('Cancel',style: TextStyles.labelStyle,),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child:  Text('OK',style: TextStyles.labelStyle,),
              ),
            ],
          ),
        );

        if (res == true) {
          Get.toNamed(Routes.localFlashing, arguments: {'sessionModel': session});
        }
        return;
      }

      // ── Data exists ──
      bool allFileDownloaded = true;

      final List<VariantEcu> dataFileList = (jsonDecode(jsonListData) as List)
          .map((e) => VariantEcu.fromJson(e))
          .toList();

      if (dataFileList.isNotEmpty) {
        final variantEcuList = session?.variant?.variantEcu ?? [];

        for (final ecu in variantEcuList) {
          try {
            final localEcu = dataFileList.firstWhere(
              (x) =>
                  x.ecuId == ecu.ecu?.id &&
                  x.productionSwId?.id == ecu.productionSwId?.id &&
                  (x.productionSwId?.dataFileLocal?.isNotEmpty ?? false),
              orElse: () => VariantEcu(),
            );

            if (localEcu.ecuId == null) {
              // Not downloaded
              imgDownload.value = 'ic_download.png';
              downloadBgColor.value = const Color(0xFFFFFFFF);
              downloadMessage.value = 'Download Flash Dataset';
              bottomMessage.value = 'Download Flash Dataset';

              if (ecu.isLatest == true) {
                allFileDownloaded = false;
              }
              break;
            } else {
              // Already downloaded
              imgDownload.value = 'ic_downloaded.png';
              downloadBgColor.value = const Color(0xFF309F93);
              downloadMessage.value = 'Flashing file already downloaded';
              bottomMessage.value = 'Flashing file already downloaded';
            }
          } catch (e) {
            print('ECU check error: $e');
          }
        }
      }

      hideLoading();

      if (!allFileDownloaded) {
        final res = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Alert'),
            content: const Text(
              'Flash files are available for download.\nDo you want to review the available flash files for downloading?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (res == true) {
          Get.toNamed(
            Routes.localDatasetFiles,
            arguments: {'sessionModel': session},
          );
        }
      }
    } catch (e) {
      hideLoading();
      print('CheckLocalDatafile error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // DOWNLOAD FILES CLICKED
  // ─────────────────────────────────────────────
  Future<void> onDownloadFilesClicked() async {
    try {
      showLoading('File downloading...');
      await Future.delayed(const Duration(milliseconds: 200));

      // ✅ FIX #3 — close loader BEFORE navigating
      hideLoading();

      await Get.toNamed(
        Routes.localFlashing,
        arguments: {'sessionModel': sessionModel.value},
      );
    } catch (ex) {
      hideLoading();
      print('❌ ERROR in onDownloadFilesClicked: $ex');
      await _displayAlert('Error', ex.toString());
    }
  }

  // ─────────────────────────────────────────────
  // USB CONNECT
  // ─────────────────────────────────────────────
  Future<void> connVaiUsbClicked() async {
    final connectionCondition = ConnectionCondition(
      isLengthFFF: true,
      isChannels: true,
      isObdCharger: false,
      channelId: '00',
    );
    returnValue.value = false;
    usbConnect(connectionCondition, false);
  }

  Future<void> usbConnect(ConnectionCondition condition, bool write) async {
    bool isConnected = false;
    String firmwareVersion = '';

    try {
      showLoading('Loading...');
      await Future.delayed(const Duration(milliseconds: 10));

      App.usbConnectorService ??= UsbWindows();

      print('🔍 Calling GetDongleMacID...');
      var macId = await App.usbConnectorService!.getDongleMacID(
        condition.isLengthFFF ?? false,
        condition.isChannels ?? false,
        condition.channelId ?? '',
        condition.isObdCharger ?? false,
      );

      if (macId.isNotEmpty) {
        print('✅ Handshake Success. MacID: $macId');
        isConnected = true;

        firmwareVersion =
            await App.usbConnectorService!.setDongleProperties1();
        print('📊 firmwareVersion: $firmwareVersion');

        App.firmwareVersion = firmwareVersion;
        App.connectedVia = 'USB';

        await getEngineHours();
        await reportLocation();
      }

      hideLoading();

      // ✅ FIX #4 — return after write navigation, don't fall through
      if (isConnected && firmwareVersion.isNotEmpty) {
        if (write) {
          Get.toNamed(Routes.writeSSIDPASS);
          return; // ✅ stop here
        }
        Get.toNamed(Routes.appFeaturePage, arguments: {
          'sessionModel': sessionModel.value,
          'vehicleModels': model,
          'firmwareVersion': firmwareVersion,
          'extra': '',
        });
      } else if (isConnected && firmwareVersion.isEmpty) {
        await _displayAlert(
          'Communication Error',
          'Dongle connected, but failed to retrieve Firmware Version. Please retry.',
        );
      } else {
        await _displayAlert('Failed', 'Dongle connection not established.');
      }
    } catch (ex) {
      hideLoading();
      print('❌ Exception in usbConnect: $ex');
    }
  }

  // ─────────────────────────────────────────────
  // WIFI CONNECT
  // ─────────────────────────────────────────────
  Future<void> connVaiWifiClicked() async {
    showLoading('Loading...');

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      App.connectedVia = 'WIFI';

      if (App.wifiConnectorService == null) {
        hideLoading();
        return;
      }

      final List<BluetoothDevicesModel>? wifiDevices =
          await App.wifiConnectorService!.getDeviceList();

      hideLoading();

      if (wifiDevices != null && wifiDevices.isNotEmpty) {
        final List<WifiDevicesModel> converted = wifiDevices
            .map((d) => WifiDevicesModel(name: d.name, ip: d.ip))
            .toList();

        Get.toNamed(Routes.wifiDevicePage, arguments: {
          'sessionModel': sessionModel.value,
          'vehicleModels': model,
          'wifiConnector': converted,
          'isManual': false,
        });
      } else {
        final bool? resp = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Failed'),
            content: const Text('Dongle not found'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Add Manually', style: TextStyles.labelStyle),
              ),
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Scan again', style: TextStyles.labelStyle),
              ),
            ],
          ),
        );

        if (resp == true) {
          Get.toNamed(Routes.wifiDevicePage, arguments: {
            'sessionModel': sessionModel.value,
            'vehicleModels': model,
            'wifiConnector': <WifiDevicesModel>[],
            'isManual': true,
          });
        } else if (resp == false) {
          Future.delayed(
              const Duration(milliseconds: 100), connVaiWifiClicked);
        }
      }
    } catch (ex) {
      hideLoading();
      debugPrint('Error in WiFi Connection: $ex');
    }
  }

  // ─────────────────────────────────────────────
  // WRITE CLICKED
  // ─────────────────────────────────────────────
  Future<void> onWriteClicked() async {
    try {
      final connectionCondition = ConnectionCondition(
        isLengthFFF: true,
        isChannels: true,
        isObdCharger: false,
        channelId: '00',
      );
      returnValue.value = false;
      usbConnect(connectionCondition, true);
    } catch (e) {
      print('❌ Setup Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // SESSION LIST
  // ─────────────────────────────────────────────
  Future<List<SessionModel>?> getSessionList() async {
    try {
      final jsonListData =
          await AndroidOperationsService.getData('Session_LocalList');

      if (jsonListData == null ||
          jsonListData.isEmpty ||
          jsonListData.trim() == '[]') return null;

      final res = SessionListModel.fromJson(jsonDecode(jsonListData));

      if (res.message == 'success') {
        if (res.results.isNotEmpty) {
          return res.results..sort((a, b) => b.id!.compareTo(a.id!));
        } else {
          await _displayAlert('Failed', 'Session list not found.');
          return null;
        }
      } else {
        await _displayAlert('Error', res.message ?? 'Unknown error');
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER DONGLE
  // ─────────────────────────────────────────────
  Future<bool> registerDongleToServer() async {
    try {
      bool isReachable = await InternetChecker.hasInternet();

      if (isReachable) {
        var response =
            await services.registerDongle(registerDongleRequest, App.jwtToken);

        if (response.status != 'success') {
          await _displayAlert('Alert!', response.message ?? 'Registration failed');
          return false;
        }

        if (response.status == 'success' &&
            response.isActive == false &&
            (response.error?.isNotEmpty ?? false)) {
          await _displayAlert('Alert', response.error!);
          return false;
        }

        if (response.status == 'success' && response.isActive == true) {
          localRegisterDongleResponse.add(response);
          await AndroidOperationsService.saveData(
            'RegisteresDongle_LocalData',
            jsonEncode(localRegisterDongleResponse),
          );
          return true;
        }
      } else {
        await _displayAlert(
          'Error',
          'Please turn ON internet of mobile.\nWe need to approve dongle.',
        );
      }
      return false;
    } catch (ex) {
      await _displayAlert('Error', ex.toString());
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // ENGINE HOURS
  // ─────────────────────────────────────────────
  Future<void> getEngineHours() async {
    try {
      final parameterListData =
          await AndroidOperationsService.getData('Parameter_LocalList');

      if (parameterListData == null || parameterListData.isEmpty) return;

      final res = ParameterModel.fromJson(jsonDecode(parameterListData));

      if (res.message == 'success') {
        final engHrsParameter = res.results?.firstWhereOrNull(
          (x) => x.parameter == 'Engine Hours',
        );

        if (engHrsParameter != null) {
          ParameterId? engHrsParameterMapped;
          EcuDataSet? ecuInfo;

          for (var ecu in StaticData.ecuInfo) {
            engHrsParameterMapped =
                engHrsParameter.parameterIds?.firstWhereOrNull(
              (x) => x.ecu == ecu.ecuId,
            );
            if (engHrsParameterMapped != null) {
              ecuInfo = ecu;
              break;
            }
          }

          if (engHrsParameterMapped != null && ecuInfo != null) {
            final pidCode = ecuInfo.pidList?.firstWhereOrNull(
              (x) =>
                  x.piCodeVariable?.any(
                      (y) => y.id == engHrsParameterMapped?.pidCode) ??
                  false,
            );

            if (pidCode != null) {
              await App.usbConnectorService!.setDongleProperties(
                protocolName: ecuInfo.protocol?.autopeepal,
                txHeaderTemp: ecuInfo.txHeader ?? '',
                rxHeaderTemp: ecuInfo.rxHeader,
              );

              final readPidResp = await App.usbConnectorService!.readPid(
                pidList: [pidCode],
                pidByAddrSeq: null,
              );

              if (readPidResp.isNotEmpty && readPidResp[0]?.status == 'NOERROR') {
                final ecuEngineHours =
                    readPidResp[0]?.variables?[0].responseValue ?? '';

                final engineHrsModel = UploadEngineHrsModel(
                  hrs: ecuEngineHours,
                  session: sessionModel.value!.id,
                  date: DateTime.now().toUtc().toIso8601String(),
                );

                final isReachable = await InternetChecker.hasInternet();

                if (isReachable) {
                  await services.uploadEngineHrs(engineHrsModel);
                } else {
                  List<dynamic> data = [];
                  final offlineEntry = {
                    'engine_hours': engineHrsModel,
                    'srn_id': sessionModel.value!.id,
                    'sr_number': sessionModel.value!.srNumber,
                  };

                  final jsonData = await AndroidOperationsService.getData(
                      'OfflineAnalyze_EngineHrs');
                  if (jsonData != null && jsonData.isNotEmpty) {
                    data = jsonDecode(jsonData);
                  }
                  data.add(offlineEntry);
                  await AndroidOperationsService.saveData(
                    'OfflineAnalyze_EngineHrs',
                    jsonEncode(data),
                  );
                }
              }
            }
          }
        }
      }
    } catch (ex) {
      debugPrint('💥 Error in getEngineHours: $ex');
    }
  }

  // ─────────────────────────────────────────────
  // REPORT LOCATION
  // ─────────────────────────────────────────────
  Future<void> reportLocation() async {
    try {
      final address = await AndroidOperationsService.getCurrentAddress();

      if (address.trim().isNotEmpty) {
        final locationModel = {
          'session': sessionModel.value!.id,
          'location': address,
          'date': DateTime.now().toUtc().toIso8601String(),
        };

        final isReachable = await InternetChecker.hasInternet();

        if (isReachable) {
          await services.postApi(
            '/api/v1/analyze/srsession-location/create/',
            jsonEncode(locationModel),
          );
        } else {
          List<dynamic> data = [];
          final offlineEntry = {
            'Location': locationModel,
            'srn_id': sessionModel.value!.id,
            'sr_number': sessionModel.value!.srNumber,
          };

          final jsonData =
              await AndroidOperationsService.getData('OfflineAnalyze_Location');
          if (jsonData != null && jsonData.isNotEmpty) {
            try {
              data = jsonDecode(jsonData);
            } catch (_) {
              data = [];
            }
          }
          data.add(offlineEntry);
          await AndroidOperationsService.saveData(
            'OfflineAnalyze_Location',
            jsonEncode(data),
          );
        }
      }
    } catch (ex) {
      debugPrint('💥 Exception in reportLocation: $ex');
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  void showLoading([String msg = 'Loading...']) {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen == true) Get.back();
  }

  Future<void> _displayAlert(String title, String message) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:  Text('OK',style: TextStyles.labelStyle,),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INTERNET CHECKER
// ─────────────────────────────────────────────
class InternetChecker {
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class User {
  String? email;
  dynamic workshop;
  dynamic role;

  User({this.email, this.workshop, this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'],
        workshop: json['workshop'],
        role: json['role'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'workshop': workshop,
        'role': role,
      };
}

class CloseJobCard {
  String? id;
  String? source;
  String? sessionId;
  String? jobCard;
  DateTime? startDate;
  DateTime? endDate;
  User? user;
  String? sessionType;
  String? status;

  CloseJobCard({
    this.id,
    this.source,
    this.sessionId,
    this.jobCard,
    this.startDate,
    this.endDate,
    this.user,
    this.sessionType,
    this.status,
  });

  factory CloseJobCard.fromJson(Map<String, dynamic> json) => CloseJobCard(
        id: json['id'],
        source: json['source'],
        sessionId: json['session_id'],
        jobCard: json['job_card'],
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'])
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'])
            : null,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        sessionType: json['session_type'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'session_id': sessionId,
        'job_card': jobCard,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'user': user?.toJson(),
        'session_type': sessionType,
        'status': status,
      };
}
