// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:autopeepal/app.dart';
// import 'package:autopeepal/models/KOEL_LocalDataFlash/koel_LocalDataFlash_model.dart';
// import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
// import 'package:autopeepal/models/all_models.dart' hide EcuMapFile;
// import 'package:autopeepal/models/flashRecord_model.dart' hide FlashData;
// import 'package:autopeepal/models/jobCard_model.dart';
// import 'package:autopeepal/models/liveParameter_model.dart';
// import 'package:autopeepal/models/offlineAnalyze_model.dart';
// import 'package:autopeepal/models/parameter_model.dart';
// import 'package:autopeepal/models/sessionList_model.dart';
// import 'package:autopeepal/models/staticData.dart';
// import 'package:autopeepal/services/androidOperationservice.dart';
// import 'package:autopeepal/services/api_services.dart';
// import 'package:autopeepal/services/getJson_service.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class FlashEcuController extends GetxController {
//   final AuthApiService _services = AuthApiService();

//   // ── State ─────────────────────────────────────────────────────────────────
//   SessionModel? sessionModel;
//   LocalVariantEcuEcu? selectedFlashFile;  // ✅ nullable
// FlashEcusModel? selectedEcu;

//   FlashData? flashData;
//   String readInterpreterFile = "";
//   String flashDatasetFile = "";
//   String flashingResult = "";
//   // In FlashEcuController:

//   // ── Observables ───────────────────────────────────────────────────────────
//   final RxString fileName = "".obs;
//   final RxString fileDesc = "".obs;
//   final RxString selectDataset = "".obs;
//   final RxBool isFlashBtnVisible = true.obs;
//   final RxBool extraViewVisible = false.obs;
//   final RxBool timerVisible = false.obs;
//   final RxBool flashProgressVisible = false.obs;
//   final RxString flashTimer = "00 : 00".obs;
//   final RxString flashPercent = "".obs;
//   final RxDouble progressValue = 0.0.obs;

//   // ── Timer ─────────────────────────────────────────────────────────────────
//   Stopwatch stopwatch = Stopwatch();
//   Timer? _timerTicker;
//   Timer? _percentTicker;
//   bool timerStatus = false;

//  @override
// void onInit() {
//   super.onInit();
//   final args = Get.arguments;
//   print("🚀 FlashEcuController onInit — args: $args");
//   if (args == null) {
//     print("❌ args is null");
//     return;
//   }

//   try {
//     sessionModel = args['sessionModel'] as SessionModel?;
//     selectedFlashFile = args['selectedFlashFile'] as LocalVariantEcuEcu?;
//     selectedEcu = args['selectedEcu'] as FlashEcusModel?;

//     print("✅ sessionModel: ${sessionModel?.id}");
//     print("✅ selectedFlashFile: ${selectedFlashFile?.productionSwId?.swPartNo}");
//     print("✅ selectedEcu: ${selectedEcu?.ecuName}");

//     fileName.value = selectedFlashFile?.productionSwId?.swPartNo ?? "";
//     fileDesc.value = selectedFlashFile?.productionSwId?.description ?? "";
//     selectDataset.value = selectedFlashFile?.productionSwId?.swPartNo ?? "";
//   } catch (e) {
//     print("❌ FlashEcuController onInit error: $e");
//   }
// }

//   @override
//   void onClose() {
//     _timerTicker?.cancel();
//     _percentTicker?.cancel();
//     stopwatch.stop();
//     super.onClose();
//   }

//   // ── 1. DATASET CLICKED ────────────────────────────────────────────────────
// Future<void> datasetClicked() async {
//   print("🚀 datasetClicked START");
//   print("📋 selectedFlashFile: ${selectedFlashFile!.productionSwId?.swPartNo}");
//   print("📋 isEnable: ${selectedFlashFile!.isEnable}");
//   print("📋 localDatasetFile: ${selectedFlashFile!.localDatasetFile}");
//   print("📋 selectedEcu: ${selectedEcu!.ecuName}");

//   isFlashBtnVisible.value = false;

//   try {
//     // ── STEP 1: Download if is_enable == true ────────────────────────────
//     if (selectedFlashFile!.isEnable == true) {
//       print("📥 STEP 1: File needs download");
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );
//       await Future.delayed(const Duration(milliseconds: 200));

//       try {
//         final connectivity = await Connectivity().checkConnectivity();
//         final hasInternet = connectivity != ConnectivityResult.none;
//         print("🌐 hasInternet: $hasInternet");

//         if (hasInternet) {
//           final jsonListData =
//               await AndroidOperationsService.getData("Dataset_LocalList");
//           print("📂 Dataset_LocalList exists: ${jsonListData != null && jsonListData.isNotEmpty}");

//           List<VariantEcu> ecuVariantList = [];
//           if (jsonListData != null && jsonListData.isNotEmpty) {
//             ecuVariantList = (jsonDecode(jsonListData) as List)
//                 .map((e) => VariantEcu.fromJson(e))
//                 .toList();
//           }
//           print("📂 ecuVariantList count: ${ecuVariantList.length}");

//           print("🔗 Downloading from URL: ${selectedFlashFile!.productionSwId?.hexSrecFile}");
//           final dataFileLocal = await _services.readStringFromUrl(
//               selectedFlashFile!.productionSwId?.hexSrecFile ?? "");
//           print("📥 dataFileLocal length: ${dataFileLocal.length ?? 0}");

//           if (dataFileLocal == null || dataFileLocal.isEmpty) {
//             print("❌ File download failed — empty response");
//             _closeLoader();
//             Get.defaultDialog(
//                 title: "Error",
//                 middleText: "File not downloaded.\nPlease try again");
//             isFlashBtnVisible.value = true;
//             return;
//           }

//           final ecuVariant = VariantEcu(
//             date: DateTime.now()
//                 .toLocal()
//                 .toString()
//                 .substring(0, 10)
//                 .split('-')
//                 .reversed
//                 .join('-'),
//             ecuId: selectedFlashFile!.ecuId,
//             ecuName: selectedFlashFile!.ecuName,
//             productionSwId: ProductionSW(
//               dataFile: selectedFlashFile!.productionSwId?.dataFile,
//               dataFileLocal: dataFileLocal,
//               hexSrecFile: selectedFlashFile!.productionSwId?.hexSrecFile,
//               swPartNo: selectedFlashFile!.productionSwId?.swPartNo,
//               id: selectedFlashFile!.productionSwId?.id,
//             ),
//           );
//           ecuVariantList.add(ecuVariant);

//           await AndroidOperationsService.saveData(
//               "Dataset_LocalList", jsonEncode(ecuVariantList));
//           print("✅ Dataset_LocalList saved with ${ecuVariantList.length} entries");

//           selectedFlashFile!.isEnable = false;
//           selectedFlashFile!.localDatasetFile =
//               ecuVariant.productionSwId?.dataFileLocal;
//           print("✅ selectedFlashFile.isEnable → false");
//           print("✅ localDatasetFile set, length: ${selectedFlashFile!.localDatasetFile?.length ?? 0}");
//         } else {
//           print("❌ No internet connection");
//           _closeLoader();
//           Get.defaultDialog(
//               title: "Alert!",
//               middleText: "Please check Internet Connection");
//           isFlashBtnVisible.value = true;
//           return;
//         }
//       } catch (e) {
//         print("❌ STEP 1 download error: $e");
//         _closeLoader();
//         Get.defaultDialog(title: "Error", middleText: e.toString());
//         isFlashBtnVisible.value = true;
//         return;
//       }

//       _closeLoader();
//       print("✅ STEP 1 complete — loader closed");
//     } else {
//       print("⏭ STEP 1 skipped — file already downloaded");
//     }

//     // ── STEP 2: Start flashing ────────────────────────────────────────────
//     print("🔧 STEP 2: Checking if ready to flash");
//     print("📋 isEnable after step1: ${selectedFlashFile!.isEnable}");

//     if (selectedFlashFile!.isEnable == false) {
//       try {
//         final jsonListData =
//             await AndroidOperationsService.getData("KOEL_LocalList");
//         print("📂 KOEL_LocalList exists: ${jsonListData != null && jsonListData.isNotEmpty}");

//         if (jsonListData == null || jsonListData.isEmpty) {
//           print("❌ KOEL_LocalList not found");
//           Get.defaultDialog(title: "Error", middleText: "FSQ file not found");
//           isFlashBtnVisible.value = true;
//           return;
//         }

//         final rootKoelList = (jsonDecode(jsonListData) as List)
//             .map((e) => RootKoelocalModel.fromJson(e))
//             .toList();
//         print("📂 rootKoelList count: ${rootKoelList.length}");

//         if (rootKoelList.isNotEmpty) {
//           print("🔧 Building KoelLocalDataFlashModel");
//           print("   dataFile: ${selectedFlashFile!.productionSwId?.dataFile}");
//           print("   swPartNo: ${selectedFlashFile!.productionSwId?.swPartNo}");
//           print("   localDatasetFile length: ${selectedFlashFile!.localDatasetFile?.length ?? 0}");
//           print("   ecuId: ${selectedEcu!.id}");
//           print("   sequenceFileName: ${selectedEcu!.ecu2?.file?.first.sequenceFileName}");

//           final selectedFlashLocalFile = KoelLocalDataFlashModel(
//             dataFile: selectedFlashFile!.productionSwId?.dataFile,
//             dataFileName: selectedFlashFile!.productionSwId?.swPartNo,
//             flashFileId: selectedFlashFile!.productionSwId?.id,
//             ecuName: selectedFlashFile!.ecuName,
//             localFile: selectedFlashFile!.localDatasetFile,
//             ecuId: selectedEcu!.id,
//             sequenceFileId: selectedEcu!.ecu2?.file?.first.sequenceFileName,
//             sequenceFileName: selectedEcu!.ecu2?.file?.first.dataFileName,
//           );
//           print("✅ selectedFlashLocalFile built");
//           print("   localFile length: ${selectedFlashLocalFile.localFile?.length ?? 0}");
//           print("   sequenceFileId: ${selectedFlashLocalFile.sequenceFileId}");

//           flashData = FlashData(
//             ecu2: selectedEcu!.ecu2,
//             file: FileModel(
//               dataFile: selectedFlashLocalFile.dataFile,
//               dataFileName: selectedFlashLocalFile.dataFileName,
//               id: selectedFlashLocalFile.flashFileId,
//             ),
//             seedkeyalgoFnIndexValues: selectedEcu!.seedkeyalgoFnIndexValues,
//             ecuMapFile: selectedEcu!.ecuMapFile,
//           );
//           print("✅ flashData built");

//           // Find interpreter file
//           readInterpreterFile = "";
//           for (var item in rootKoelList) {
//             if (item.modelDetail?.subModelList?.isNotEmpty == true) {
//               for (var subModel in item.modelDetail!.subModelList!) {
//                 print("🔍 Checking subModel.subModelId: ${subModel.subModelId} vs App.subModelId: ${App.subModelId}");
//                 if (subModel.subModelId == App.subModelId) {
//                   for (var ecu in subModel.ecuList ?? []) {
//                     print("🔍 Checking ecu.ecuId: ${ecu.ecuId} vs selectedEcu.id: ${selectedEcu!.id}");
//                     if (ecu.ecuId == selectedEcu!.id) {
//                       for (var ecu2 in ecu.ecu2LocalModels ?? []) {
//                         print("🔍 Checking ecu2.sequenceId: ${ecu2.sequenceId} vs sequenceFileId: ${selectedFlashLocalFile.sequenceFileId}");
//                         if (ecu2.sequenceId == selectedFlashLocalFile.sequenceFileId) {
//                           readInterpreterFile = ecu2.sequenceLocalFile ?? "";
//                           print("✅ readInterpreterFile found, length: ${readInterpreterFile.length}");
//                         }
//                       }
//                     }
//                   }
//                 }
//               }
//             }
//           }

//           print("📋 readInterpreterFile length: ${readInterpreterFile.length}");
//           if (readInterpreterFile.isEmpty) {
//             print("⚠️ readInterpreterFile is EMPTY — sequence not matched");
//           }

//           print("🔧 Processing flash dataset via _readJson...");
//           flashDatasetFile = await _readJson(
//             readInterpreterFile,
//             selectedFlashLocalFile.localFile ?? "",
//           );
//           print("✅ flashDatasetFile length: ${flashDatasetFile.length}");

//           print("🔧 Getting CAL ID...");
//           final calId = await _getCalId();
//           print("✅ calId: $calId");

//           print("⏱ Starting timer...");
//           _startTimer();
//           print("------Started ECU Flashing------");
//           _startFlashing(calId, selectedFlashLocalFile);
//         } else {
//           print("⚠️ rootKoelList is empty");
//           isFlashBtnVisible.value = true;
//         }
//       } catch (e) {
//         isFlashBtnVisible.value = true;
//         print("❌ STEP 2 error: $e");
//       }
//     } else {
//       print("⚠️ File still not ready — isEnable is still true");
//       isFlashBtnVisible.value = true;
//     }
//   } catch (e) {
//     isFlashBtnVisible.value = true;
//     print("❌ datasetClicked outer error: $e");
//   }

//   print("🏁 datasetClicked END");
// }
//   // ── 2. TIMER ──────────────────────────────────────────────────────────────
//   void _startTimer() {
//     stopwatch = Stopwatch()..start();
//     timerStatus = true;
//     timerVisible.value = true;
//     flashProgressVisible.value = true;
//     flashTimer.value = "00 : 00";
//     flashPercent.value = "";
//     progressValue.value = 0.0;

//     // Reset percentage on dongle
//     if (App.connectedVia == "USB") {
//       App.usbConnectorService?.resetPercentage();
//     } else if (App.connectedVia == "WIFI") {
//       App.wifiConnectorService?.resetPercentage();
//     }

//     // Tick every second — update timer display
//     _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!timerStatus) {
//         _timerTicker?.cancel();
//         return;
//       }
//       final m = stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
//       final s = (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
//       flashTimer.value = "$m : $s";
//     });

//     // Tick every 5 seconds — update flash percentage
//     _percentTicker = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (!timerStatus) {
//         _percentTicker?.cancel();
//         return;
//       }
//       double percent = 0.0;
//       try {
//         if (App.connectedVia == "USB") {
//           percent = await App.usbConnectorService?.flashingData() ?? 0.0;
//         } else if (App.connectedVia == "WIFI") {
//           percent = await App.wifiConnectorService?.flashingData() ?? 0.0;
//         }

//         if (!percent.isNaN) {
//           flashPercent.value = "${(percent * 100).toStringAsFixed(1)}%";
//           progressValue.value = percent;
//         }
//       } catch (e) {
//         print("percent tick error: $e");
//       }
//     });
//   }

//   // ── 3. START FLASHING ─────────────────────────────────────────────────────
//  Future<void> _startFlashing(
//     String calId, KoelLocalDataFlashModel selectedFlashLocalFile) async {
//   try {
//     List<FlashRecord> flashRecordList = [];
//     String serverMessage = "";
//     String messageTitle = "";
//     String message = "";
//     String status = "";
//     final cvnBeforeFlash = calId;
//     final cvnAfterFlash = selectedFlashLocalFile.dataFileName ?? "";

//     extraViewVisible.value = true;
//     await Future.delayed(const Duration(seconds: 1));

//     // ── Run flashing ──────────────────────────────────────────────────
//     if (App.connectedVia == "USB") {
//       flashingResult = await App.usbConnectorService!.startECUFlashing(
//             flashDatasetFile,
//             readInterpreterFile,
//             flashData?.seedkeyalgoFnIndexValues ?? SeedkeyalgoFnIndex(),
//             selectedEcu!.ecuMapFile ?? [],
//           ) ?? "";
//     } else if (App.connectedVia == "WIFI") {
//       flashingResult = await App.wifiConnectorService!.startECUFlashing(
//             flashDatasetFile,
//             readInterpreterFile,
//             flashData?.seedkeyalgoFnIndexValues ?? SeedkeyalgoFnIndex(),
//             selectedEcu!.ecuMapFile ?? [],
//           ) ?? "";
//     }

//     print("📋 flashingResult: '$flashingResult'");

//     stopwatch.stop();
//     timerStatus = false;

//     // ✅ Ensure we're on main thread for all UI operations
//     // Close timer visuals
//     timerVisible.value = false;
//     flashProgressVisible.value = false;

//     // ── Build flash record ────────────────────────────────────────────
//     if (flashingResult.isEmpty) {
//       messageTitle = "ERROR";
//       message = "Flashing Stopped with following error";
//       status = "";
//       flashRecordList.add(FlashRecord(
//         flashDuration: flashTimer.value,
//         status: "fail",
//         cvnAfterFlash: cvnAfterFlash,
//         cvnBeforeFlash: cvnBeforeFlash,
//         created: DateTime.now().toUtc().toIso8601String(),
//       ));
//     } else if (flashingResult != "NOERROR") {
//       messageTitle = "ERROR";
//       message = "Flashing Stopped with following error";
//       status = flashingResult;
//       flashRecordList.add(FlashRecord(
//         flashDuration: flashTimer.value,
//         status: "fail",
//         cvnAfterFlash: cvnAfterFlash,
//         cvnBeforeFlash: cvnBeforeFlash,
//         created: DateTime.now().toUtc().toIso8601String(),
//       ));
//     } else {
//       messageTitle = "Successful";
//       message = "Flashing Successful";
//       status = "";
//       flashRecordList.add(FlashRecord(
//         flashDuration: flashTimer.value,
//         status: "pass",
//         cvnAfterFlash: cvnAfterFlash,
//         cvnBeforeFlash: cvnBeforeFlash,
//         created: DateTime.now().toUtc().toIso8601String(),
//       ));
//     }

//     // ── Save flash record ─────────────────────────────────────────────
//     if (flashRecordList.isNotEmpty) {
//       final connectivity = await Connectivity().checkConnectivity();
//       final hasInternet = connectivity != ConnectivityResult.none;

//       if (hasInternet && (sessionModel?.id ?? 0) != 0) {
//         final saved = await _services.flashRecord(
//             flashRecordList, App.jwtToken, sessionModel!.id!);
//         serverMessage =
//             saved ? "Parameter data saved" : "Parameter data not saved";
//         print("📋 serverMessage: $serverMessage");
//       } else {
//         await _saveFlashOffline(flashRecordList);
//       }
//     }

//     // ✅ All UI work after this point must be on main thread
//     // Use addPostFrameCallback to guarantee main thread execution
//     extraViewVisible.value = false;
//     isFlashBtnVisible.value = true;

//     final String finalTitle = messageTitle;
//     final String finalMiddle = "$message\n$status\n$serverMessage".trim();
//     final String finalStatus = status;

//     // ✅ Schedule dialog on next frame — avoids _debugLocked
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Future.delayed(const Duration(milliseconds: 200));

//       if (finalStatus == "Communication Error") {
//         final reconnect = await Get.defaultDialog<bool>(
//           title: finalStatus,
//           middleText: "Do you want to reconnect?",
//           textConfirm: "Yes",
//           textCancel: "No",
//           onConfirm: () => Get.back(result: true),
//           onCancel: () => Get.back(result: false),
//         );
//         if (reconnect == true) {
//           // ReconnectService().reconnectDongle();
//         }
//       } else {
//         await Get.defaultDialog(
//           title: finalTitle,
//           middleText: finalMiddle,
//           textConfirm: "OK",
//           onConfirm: () => Get.back(),
//         );
//       }

//       await Future.delayed(const Duration(milliseconds: 200));
//       Get.back(); // Pop flash page
//     });

//   } catch (e) {
//     extraViewVisible.value = false;
//     isFlashBtnVisible.value = true;
//     print("❌ _startFlashing error: $e");

//     // ✅ Schedule error dialog on next frame too
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Future.delayed(const Duration(milliseconds: 200));
//       Get.defaultDialog(title: "Alert", middleText: e.toString());
//     });
//   }
// }
//   // ── 4. READ JSON ──────────────────────────────────────────────────────────
//   Future<String> _readJson(String interpreterFile, String flashFile) async {
//     Get.dialog(
//       const Center(
//           child: Text("Processing Dataset...",
//               style: TextStyle(color: Colors.white))),
//       barrierDismissible: false,
//     );
//     await Future.delayed(const Duration(milliseconds: 100));

//     try {
//       List<EcuMapFile> ecuMapFiles = [];
//       bool isWordFormat = false;

//       if (interpreterFile.isNotEmpty &&
//           interpreterFile.contains("EcuMapFile")) {
//         final lines = interpreterFile.split('\n');

//         for (var line in lines) {
//           final formatted = line.replaceAll('\r', '').trim();
//           if (formatted.startsWith('//') || formatted.isEmpty) continue;

//           final command =
//               formatted.contains(':') ? formatted.split(':')[0] : formatted;
//           final info = formatted.contains(':') ? formatted.split(':')[1] : '';

//           if (command == "EcuMapFile") {
//             final ecuMap = EcuMapFile();
//             final parts = info.split('+');
//             for (var part in parts) {
//               final endIndex = part.indexOf('>');
//               if (endIndex < 1) continue;
//               final bracketString = part.substring(1, endIndex);
//               final reference = bracketString.split(',')[0];

//               if (reference.contains("start_address")) {
//                 ecuMap.startAddress = bracketString.split(',')[1];
//                 ecuMap.startAddr =
//                     int.tryParse(ecuMap.startAddress ?? "", radix: 16) ?? 0;
//               } else if (reference.contains("end_address")) {
//                 ecuMap.endAddress = bracketString.split(',')[1];
//                 ecuMap.endAddr =
//                     int.tryParse(ecuMap.endAddress ?? "", radix: 16) ?? 0;
//               }
//             }
//             ecuMapFiles.add(ecuMap);
//           } else if (command.trim() == "hexfileformat" &&
//               info.trim() == "word") {
//             isWordFormat = true;
//           }
//         }
//       }

//       // Convert flash file to JSON using GetJson equivalent
//       final flashJson = await GetJson().convertToJson(
//         Uint8List.fromList(utf8.encode(flashFile)),
//         ecuMapFiles.cast<EcuMapFile>(),
//         (selectedEcu!.seedkeyalgoFnIndexValues ?? "")
//             .toString(), // ✅ Object → String
//       );
//       _closeLoader();
//       return flashJson;
//     } catch (e) {
//       _closeLoader();
//       print("_readJson error: $e");
//       return "";
//     }
//   }

//   // ── 5. GET CAL ID ─────────────────────────────────────────────────────────
//   Future<String> _getCalId() async {
//     Get.dialog(
//       const Center(
//           child:
//               Text("Reading CAL Id...", style: TextStyle(color: Colors.white))),
//       barrierDismissible: false,
//     );
//     await Future.delayed(const Duration(milliseconds: 50));

//     String calIdValue = "NA";
//     try {
//       final paramData =
//           await AndroidOperationsService.getData("Parameter_LocalList");
//       if (paramData == null || paramData.isEmpty) {
//         _closeLoader();
//         return calIdValue;
//       }

//       final res = ParameterModel.fromJson(jsonDecode(paramData));
//       final calIdParam =
//           res.results?.firstWhereOrNull((x) => x.parameter == "CAL ID");

//       if (calIdParam != null) {
//         for (var ecu in StaticData.ecuInfo) {
//           final mapped = calIdParam.parameterIds
//               ?.firstWhereOrNull((x) => x.ecu == ecu.ecuId);

//           if (mapped != null) {
//             final pidCode = ecu.pidList?.firstWhereOrNull((x) =>
//                 x.piCodeVariable?.any((y) => y.id == mapped.pidCode) == true);

//             if (pidCode != null) {
//               final pidList = [pidCode];
//               List<ReadPidResponseModel>? resp;

//               if (App.connectedVia == "USB") {
//                 final raw = await App.usbConnectorService
//                     ?.readPid(pidList: pidList.obs, pidByAddrSeq: "");
//                 resp = raw?.whereType<ReadPidResponseModel>().toList();
//               } else {
//                 final raw = await App.wifiConnectorService
//                     ?.readPid(pidList: pidList.obs, pidByAddrSeq: "");
//                 resp = raw?.whereType<ReadPidResponseModel>().toList();
//               }

//               if (resp != null && resp.isNotEmpty) {
//                 calIdValue = resp.first.status == "NOERROR"
//                     ? resp.first.variables?.first.responseValue ?? "NA"
//                     : resp.first.status ?? "NA";
//               }
//               break;
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print("_getCalId error: $e");
//     }

//     _closeLoader();
//     return calIdValue;
//   }

//   // ── 6. SAVE OFFLINE ───────────────────────────────────────────────────────
//   Future<void> _saveFlashOffline(List<FlashRecord> records) async {
//     try {
//       const key = "OfflineAnalyze_FlashRecord";
//       final existing = await AndroidOperationsService.getData(key);
//       List<FlashOfflineAnalyze> data = [];

//       if (existing != null && existing.isNotEmpty) {
//         data = (jsonDecode(existing) as List)
//             .map((e) => FlashOfflineAnalyze.fromJson(e))
//             .toList();
//       }

//       data.add(FlashOfflineAnalyze(
//         type: "flash_record",
//         flashRecord: records,
//         srnId: sessionModel!.id,
//         srNumber: sessionModel!.srNumber,
//       ));

//       await AndroidOperationsService.saveData(key, jsonEncode(data));
//     } catch (e) {
//       print("_saveFlashOffline error: $e");
//     }
//   }

//   void _closeLoader() {
//     if (Get.isDialogOpen == true) Get.back();
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/koel_LocalDataFlash_model.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
import 'package:autopeepal/models/all_models.dart' hide EcuMapFile;
import 'package:autopeepal/models/flashRecord_model.dart' hide FlashData;
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart';
import 'package:autopeepal/models/parameter_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/getJson_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashEcuController extends GetxController {
  final AuthApiService _services = AuthApiService();

  // ── State ─────────────────────────────────────────────────────────────────
  SessionModel? sessionModel;
  LocalVariantEcuEcu? selectedFlashFile; // ✅ nullable
  FlashEcusModel? selectedEcu;

  FlashData? flashData;
  String readInterpreterFile = "";
  String flashDatasetFile = "";
  String flashingResult = "";

  // ── Observables ───────────────────────────────────────────────────────────
  final RxString fileName = "".obs;
  final RxString fileDesc = "".obs;
  final RxString selectDataset = "".obs;
  final RxBool isFlashBtnVisible = true.obs;
  final RxBool extraViewVisible = false.obs;
  final RxBool timerVisible = false.obs;
  final RxBool flashProgressVisible = false.obs;
  final RxString flashTimer = "00 : 00".obs;
  final RxString flashPercent = "".obs;
  final RxDouble progressValue = 0.0.obs;

  // ── Timer ─────────────────────────────────────────────────────────────────
  Stopwatch stopwatch = Stopwatch();
  Timer? _timerTicker;
  Timer? _percentTicker;
  bool timerStatus = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    print("🚀 FlashEcuController onInit — args: $args");
    if (args == null) {
      print("❌ args is null");
      return;
    }

    try {
      sessionModel = args['sessionModel'] as SessionModel?;
      selectedFlashFile = args['selectedFlashFile'] as LocalVariantEcuEcu?;
      selectedEcu = args['selectedEcu'] as FlashEcusModel?;

      print("✅ sessionModel: ${sessionModel?.id}");
      print(
        "✅ selectedFlashFile: ${selectedFlashFile?.productionSwId?.swPartNo}",
      );
      print("✅ selectedEcu: ${selectedEcu?.ecuName}");

      fileName.value = selectedFlashFile?.productionSwId?.swPartNo ?? "";
      fileDesc.value = selectedFlashFile?.productionSwId?.description ?? "";
      selectDataset.value = selectedFlashFile?.productionSwId?.swPartNo ?? "";
    } catch (e) {
      print("❌ FlashEcuController onInit error: $e");
    }
  }

  @override
  void onClose() {
    _timerTicker?.cancel();
    _percentTicker?.cancel();
    stopwatch.stop();
    super.onClose();
  }

  // ── 1. DATASET CLICKED ────────────────────────────────────────────────────
  Future<void> datasetClicked() async {
    print("🚀 datasetClicked START");
    print(
      "📋 selectedFlashFile: ${selectedFlashFile!.productionSwId?.swPartNo}",
    );
    print("📋 isEnable: ${selectedFlashFile!.isEnable}");
    print("📋 localDatasetFile: ${selectedFlashFile!.localDatasetFile}");
    print("📋 selectedEcu: ${selectedEcu!.ecuName}");

    isFlashBtnVisible.value = false;

    try {
      // ── STEP 1: Download if is_enable == true ────────────────────────────
      if (selectedFlashFile!.isEnable == true) {
        print("📥 STEP 1: File needs download");
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        await Future.delayed(const Duration(milliseconds: 200));

        try {
          final connectivity = await Connectivity().checkConnectivity();
          final hasInternet = connectivity != ConnectivityResult.none;
          print("🌐 hasInternet: $hasInternet");

          if (hasInternet) {
            final jsonListData =
                await AndroidOperationsService.getData("Dataset_LocalList");
            print(
              "📂 Dataset_LocalList exists: ${jsonListData != null && jsonListData.isNotEmpty}",
            );

            List<VariantEcu> ecuVariantList = [];
            if (jsonListData != null && jsonListData.isNotEmpty) {
              ecuVariantList = (jsonDecode(jsonListData) as List)
                  .map((e) => VariantEcu.fromJson(e))
                  .toList();
            }
            print("📂 ecuVariantList count: ${ecuVariantList.length}");

            print(
              "🔗 Downloading from URL: ${selectedFlashFile!.productionSwId?.hexSrecFile}",
            );
            final dataFileLocal = await _services.readStringFromUrl(
              selectedFlashFile!.productionSwId?.hexSrecFile ?? "",
            );
            print(
              "📥 dataFileLocal length: ${dataFileLocal.length}",
            );

            if (dataFileLocal.isEmpty) {
              print("❌ File download failed — empty response");
              _closeLoader();
              Get.defaultDialog(
                title: "Error",
                middleText: "File not downloaded.\nPlease try again",
              );
              isFlashBtnVisible.value = true;
              return;
            }

            final ecuVariant = VariantEcu(
              date: DateTime.now()
                  .toLocal()
                  .toString()
                  .substring(0, 10)
                  .split('-')
                  .reversed
                  .join('-'),
              ecuId: selectedFlashFile!.ecuId,
              ecuName: selectedFlashFile!.ecuName,
              productionSwId: ProductionSW(
                dataFile: selectedFlashFile!.productionSwId?.dataFile,
                dataFileLocal: dataFileLocal,
                hexSrecFile: selectedFlashFile!.productionSwId?.hexSrecFile,
                swPartNo: selectedFlashFile!.productionSwId?.swPartNo,
                id: selectedFlashFile!.productionSwId?.id,
              ),
            );
            ecuVariantList.add(ecuVariant);

            await AndroidOperationsService.saveData(
              "Dataset_LocalList",
              jsonEncode(ecuVariantList),
            );
            print(
              "✅ Dataset_LocalList saved with ${ecuVariantList.length} entries",
            );

            selectedFlashFile!.isEnable = false;
            selectedFlashFile!.localDatasetFile =
                ecuVariant.productionSwId?.dataFileLocal;
            print("✅ selectedFlashFile.isEnable → false");
            print(
              "✅ localDatasetFile set, length: ${selectedFlashFile!.localDatasetFile?.length ?? 0}",
            );
          } else {
            print("❌ No internet connection");
            _closeLoader();
            Get.defaultDialog(
              title: "Alert!",
              middleText: "Please check Internet Connection",
            );
            isFlashBtnVisible.value = true;
            return;
          }
        } catch (e) {
          print("❌ STEP 1 download error: $e");
          _closeLoader();
          Get.defaultDialog(title: "Error", middleText: e.toString());
          isFlashBtnVisible.value = true;
          return;
        }

        _closeLoader();
        print("✅ STEP 1 complete — loader closed");
      } else {
        print("⏭ STEP 1 skipped — file already downloaded");
      }

      // ── STEP 2: Start flashing ────────────────────────────────────────────
      print("🔧 STEP 2: Checking if ready to flash");
      print("📋 isEnable after step1: ${selectedFlashFile!.isEnable}");

      if (selectedFlashFile!.isEnable == false) {
        try {
          final jsonListData =
              await AndroidOperationsService.getData("KOEL_LocalList");
          print(
            "📂 KOEL_LocalList exists: ${jsonListData != null && jsonListData.isNotEmpty}",
          );

          if (jsonListData == null || jsonListData.isEmpty) {
            print("❌ KOEL_LocalList not found");
            Get.defaultDialog(
              title: "Error",
              middleText: "FSQ file not found",
            );
            isFlashBtnVisible.value = true;
            return;
          }

          final rootKoelList = (jsonDecode(jsonListData) as List)
              .map((e) => RootKoelocalModel.fromJson(e))
              .toList();
          print("📂 rootKoelList count: ${rootKoelList.length}");

          if (rootKoelList.isNotEmpty) {
            // ✅ FIX: Guard .first calls on file list
            final fileList = selectedEcu!.ecu2?.file;
            final firstFile = (fileList != null && fileList.isNotEmpty)
                ? fileList.first
                : null;

            print("🔧 Building KoelLocalDataFlashModel");
            print(
                "   dataFile: ${selectedFlashFile!.productionSwId?.dataFile}");
            print(
                "   swPartNo: ${selectedFlashFile!.productionSwId?.swPartNo}");
            print(
              "   localDatasetFile length: ${selectedFlashFile!.localDatasetFile?.length ?? 0}",
            );
            print("   ecuId: ${selectedEcu!.id}");
            print(
              "   sequenceFileName: ${firstFile?.sequenceFileName ?? 'NULL — file list empty'}",
            );

            final selectedFlashLocalFile = KoelLocalDataFlashModel(
              dataFile: selectedFlashFile!.productionSwId?.dataFile,
              dataFileName: selectedFlashFile!.productionSwId?.swPartNo,
              flashFileId: selectedFlashFile!.productionSwId?.id,
              ecuName: selectedFlashFile!.ecuName,
              localFile: selectedFlashFile!.localDatasetFile,
              ecuId: selectedEcu!.id,
              sequenceFileId: firstFile?.sequenceFileName,
              sequenceFileName: firstFile?.dataFileName,
            );
            print("✅ selectedFlashLocalFile built");
            print(
              "   localFile length: ${selectedFlashLocalFile.localFile?.length ?? 0}",
            );
            print(
              "   sequenceFileId: ${selectedFlashLocalFile.sequenceFileId}",
            );

            flashData = FlashData(
              ecu2: selectedEcu!.ecu2,
              file: FileModel(
                dataFile: selectedFlashLocalFile.dataFile,
                dataFileName: selectedFlashLocalFile.dataFileName,
                id: selectedFlashLocalFile.flashFileId,
              ),
              seedkeyalgoFnIndexValues: selectedEcu!.seedkeyalgoFnIndexValues,
              ecuMapFile: selectedEcu!.ecuMapFile,
            );
            print("✅ flashData built");

            // Find interpreter file
            readInterpreterFile = "";
            for (var item in rootKoelList) {
              if (item.modelDetail?.subModelList?.isNotEmpty == true) {
                for (var subModel in item.modelDetail!.subModelList!) {
                  print(
                    "🔍 Checking subModel.subModelId: ${subModel.subModelId} vs App.subModelId: ${App.subModelId}",
                  );
                  if (subModel.subModelId == App.subModelId) {
                    for (var ecu in subModel.ecuList ?? []) {
                      print(
                        "🔍 Checking ecu.ecuId: ${ecu.ecuId} vs selectedEcu.id: ${selectedEcu!.id}",
                      );
                      if (ecu.ecuId == selectedEcu!.id) {
                        for (var ecu2 in ecu.ecu2LocalModels ?? []) {
                          print(
                            "🔍 Checking ecu2.sequenceId: ${ecu2.sequenceId} vs sequenceFileId: ${selectedFlashLocalFile.sequenceFileId}",
                          );
                          if (ecu2.sequenceId ==
                              selectedFlashLocalFile.sequenceFileId) {
                            readInterpreterFile = ecu2.sequenceLocalFile ?? "";
                            print(
                              "✅ readInterpreterFile found, length: ${readInterpreterFile.length}",
                            );
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            print(
              "📋 readInterpreterFile length: ${readInterpreterFile.length}",
            );
            if (readInterpreterFile.isEmpty) {
              print(
                "⚠️ readInterpreterFile is EMPTY — sequence not matched",
              );
            }

            print("🔧 Processing flash dataset via _readJson...");
            flashDatasetFile = await _readJson(
              readInterpreterFile,
              selectedFlashLocalFile.localFile ?? "",
            );
            print("✅ flashDatasetFile length: ${flashDatasetFile.length}");

            print("🔧 Getting CAL ID...");
            final calId = await _getCalId();
            print("✅ calId: $calId");

            print("⏱ Starting timer...");
            _startTimer();
            print("------Started ECU Flashing------");
            _startFlashing(calId, selectedFlashLocalFile);
          } else {
            print("⚠️ rootKoelList is empty");
            isFlashBtnVisible.value = true;
          }
        } catch (e) {
          isFlashBtnVisible.value = true;
          print("❌ STEP 2 error: $e");
        }
      } else {
        print("⚠️ File still not ready — isEnable is still true");
        isFlashBtnVisible.value = true;
      }
    } catch (e) {
      isFlashBtnVisible.value = true;
      print("❌ datasetClicked outer error: $e");
    }

    print("🏁 datasetClicked END");
  }

  // ── 2. TIMER ──────────────────────────────────────────────────────────────
  void _startTimer() {
    stopwatch = Stopwatch()..start();
    timerStatus = true;
    timerVisible.value = true;
    flashProgressVisible.value = true;
    flashTimer.value = "00 : 00";
    flashPercent.value = "";
    progressValue.value = 0.0;

    // Reset percentage on dongle
    if (App.connectedVia == "USB") {
      App.usbConnectorService?.resetPercentage();
    } else if (App.connectedVia == "WIFI") {
      App.wifiConnectorService?.resetPercentage();
    }

    // Tick every second — update timer display
    _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!timerStatus) {
        _timerTicker?.cancel();
        return;
      }
      final m = stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
      final s = (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
      flashTimer.value = "$m : $s";
    });

    // Tick every 5 seconds — update flash percentage
    _percentTicker = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!timerStatus) {
        _percentTicker?.cancel();
        return;
      }
      double percent = 0.0;
      try {
        if (App.connectedVia == "USB") {
          percent = await App.usbConnectorService?.flashingData() ?? 0.0;
        } else if (App.connectedVia == "WIFI") {
          percent = await App.wifiConnectorService?.flashingData() ?? 0.0;
        }

        if (!percent.isNaN) {
          flashPercent.value = "${(percent * 100).toStringAsFixed(1)}%";
          progressValue.value = percent;
        }
      } catch (e) {
        print("percent tick error: $e");
      }
    });
  }

  // ── 3. START FLASHING ─────────────────────────────────────────────────────
  Future<void> _startFlashing(
    String calId,
    KoelLocalDataFlashModel selectedFlashLocalFile,
  ) async {
    try {
      print("🚀 _startFlashing START");
      print("📋 calId: '$calId'");
      print(
          "📋 cvnAfterFlash (dataFileName): '${selectedFlashLocalFile.dataFileName}'");
      print("📋 flashDatasetFile length: ${flashDatasetFile.length}");
      print(
          "📋 flashDatasetFile preview: ${flashDatasetFile.length > 200 ? flashDatasetFile.substring(0, 200) : flashDatasetFile}");
      print("📋 readInterpreterFile length: ${readInterpreterFile.length}");
      print(
          "📋 readInterpreterFile preview: ${readInterpreterFile.length > 200 ? readInterpreterFile.substring(0, 200) : readInterpreterFile}");
      print("📋 flashData: ${flashData == null ? 'NULL ❌' : 'OK ✅'}");
      print(
          "📋 flashData?.seedkeyalgoFnIndexValues: '${flashData?.seedkeyalgoFnIndexValues}'");
      print(
          "📋 selectedEcu: ${selectedEcu == null ? 'NULL ❌' : selectedEcu!.ecuName}");
      print(
          "📋 selectedEcu?.ecuMapFile count: ${selectedEcu?.ecuMapFile?.length ?? 0}");
      print("📋 App.connectedVia: '${App.connectedVia}'");
      print(
          "📋 App.usbConnectorService: ${App.usbConnectorService == null ? 'NULL ❌' : 'OK ✅'}");
      print(
          "📋 App.wifiConnectorService: ${App.wifiConnectorService == null ? 'NULL ❌' : 'OK ✅'}");

      List<FlashRecord> flashRecordList = [];
      String serverMessage = "";
      String messageTitle = "";
      String message = "";
      String status = "";
      final cvnBeforeFlash = calId;
      final cvnAfterFlash = selectedFlashLocalFile.dataFileName ?? "";

      extraViewVisible.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // ── Pre-flash validation ──────────────────────────────────────────────
      if (flashDatasetFile.isEmpty) {
        print("❌ flashDatasetFile is EMPTY — aborting flash");
        flashingResult = "ERROR : flash dataset file is empty";
      } else if (readInterpreterFile.isEmpty) {
        print("❌ readInterpreterFile is EMPTY — aborting flash");
        flashingResult = "ERROR : interpreter file is empty";
      } else {
        // ── Run flashing ────────────────────────────────────────────────────
        print("▶️ Starting ECU flash via '${App.connectedVia}'...");

        if (App.connectedVia == "USB") {
          if (App.usbConnectorService == null) {
            print("❌ usbConnectorService is NULL");
            flashingResult = "ERROR : USB service not initialized";
          } else {
            print("▶️ Calling usbConnectorService.startECUFlashing...");
            flashingResult = await App.usbConnectorService!.startECUFlashing(
              flashDatasetFile,
              readInterpreterFile,
              flashData?.seedkeyalgoFnIndexValues ?? SeedkeyalgoFnIndex(),
              selectedEcu!.ecuMapFile ?? [],
            );
          }
        } else if (App.connectedVia == "WIFI") {
          if (App.wifiConnectorService == null) {
            print("❌ wifiConnectorService is NULL");
            flashingResult = "ERROR : WiFi service not initialized";
          } else {
            print("▶️ Calling wifiConnectorService.startECUFlashing...");
            flashingResult = await App.wifiConnectorService!.startECUFlashing(
              flashDatasetFile,
              readInterpreterFile,
              flashData?.seedkeyalgoFnIndexValues ?? SeedkeyalgoFnIndex(),
              selectedEcu!.ecuMapFile ?? [],
            );
          }
        } else {
          print("❌ Unknown connectedVia: '${App.connectedVia}'");
          flashingResult =
              "ERROR : unknown connection type '${App.connectedVia}'";
        }
      }

      print("📋 flashingResult: '$flashingResult'");

      stopwatch.stop();
      timerStatus = false;
      timerVisible.value = false;
      flashProgressVisible.value = false;

      // ── Build flash record ──────────────────────────────────────────────
      print("🔧 Building flash record...");
      if (flashingResult.isEmpty) {
        print("⚠️ flashingResult is EMPTY — treating as error");
        messageTitle = "ERROR";
        message = "Flashing Stopped with following error";
        status = "";
        flashRecordList.add(FlashRecord(
          flashDuration: flashTimer.value,
          status: "fail",
          cvnAfterFlash: cvnAfterFlash,
          cvnBeforeFlash: cvnBeforeFlash,
          created: DateTime.now().toUtc().toIso8601String(),
        ));
      } else if (flashingResult != "NOERROR") {
        print("❌ flashingResult is error: '$flashingResult'");
        messageTitle = "ERROR";
        message = "Flashing Stopped with following error";
        status = flashingResult;
        flashRecordList.add(FlashRecord(
          flashDuration: flashTimer.value,
          status: "fail",
          cvnAfterFlash: cvnAfterFlash,
          cvnBeforeFlash: cvnBeforeFlash,
          created: DateTime.now().toUtc().toIso8601String(),
        ));
      } else {
        print("✅ flashingResult is NOERROR — flash successful");
        messageTitle = "Successful";
        message = "Flashing Successful";
        status = "";
        flashRecordList.add(FlashRecord(
          flashDuration: flashTimer.value,
          status: "pass",
          cvnAfterFlash: cvnAfterFlash,
          cvnBeforeFlash: cvnBeforeFlash,
          created: DateTime.now().toUtc().toIso8601String(),
        ));
      }

      // ── Save flash record ───────────────────────────────────────────────
      print("💾 Saving flash record (${flashRecordList.length} records)...");
      if (flashRecordList.isNotEmpty) {
        final connectivity = await Connectivity().checkConnectivity();
        final hasInternet = connectivity != ConnectivityResult.none;
        print(
            "🌐 hasInternet: $hasInternet | sessionModel?.id: ${sessionModel?.id}");

        if (hasInternet && (sessionModel?.id ?? 0) != 0) {
          print("☁️ Saving flash record to server...");
          final saved = await _services.flashRecord(
            flashRecordList,
            App.jwtToken,
            sessionModel!.id!,
          );
          serverMessage =
              saved ? "Parameter data saved" : "Parameter data not saved";
          print("📋 serverMessage: $serverMessage");
        } else {
          print(
              "💾 Saving flash record offline (hasInternet=$hasInternet sessionId=${sessionModel?.id})");
          await _saveFlashOffline(flashRecordList);
        }
      }

      extraViewVisible.value = false;
      isFlashBtnVisible.value = true;

      final String finalTitle = messageTitle;
      final String finalMiddle = "$message\n$status\n$serverMessage".trim();
      final String finalStatus = status;

      print("📣 Showing dialog — title='$finalTitle' middle='$finalMiddle'");

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));

        if (finalStatus == "Communication Error") {
          print("🔌 Showing reconnect dialog");
          final reconnect = await Get.defaultDialog<bool>(
            title: finalStatus,
            middleText: "Do you want to reconnect?",
            textConfirm: "Yes",
            textCancel: "No",
            onConfirm: () => Get.back(result: true),
            onCancel: () => Get.back(result: false),
          );
          if (reconnect == true) {
            print("🔌 User chose to reconnect");
            // ReconnectService().reconnectDongle();
          }
        } else {
          await Get.defaultDialog(
            title: finalTitle,
            middleText: finalMiddle,
            textConfirm: "OK",
            onConfirm: () => Get.back(),
          );
        }

        await Future.delayed(const Duration(milliseconds: 200));
        print("🏁 _startFlashing END — popping flash page");
        Get.back();
      });
    } catch (e, stack) {
      extraViewVisible.value = false;
      isFlashBtnVisible.value = true;
      print("❌ _startFlashing EXCEPTION: $e");
      print("❌ StackTrace: $stack");

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        Get.defaultDialog(title: "Alert", middleText: e.toString());
      });
    }
  }

  RxBool isLoaderOpen = false.obs;
  // ── 4. READ JSON ──────────────────────────────────────────────────────────
  Future<String> _readJson(
    String interpreterFile,
    String flashFile,
  ) async {
    final loader = CommonLoader(message: "Processing Dataset...");

    Get.dialog(loader, barrierDismissible: false);
    isLoaderOpen.value = true;

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      List<EcuMapFile> ecuMapFiles = [];

      if (interpreterFile.isNotEmpty &&
          interpreterFile.contains("EcuMapFile")) {
        final lines = interpreterFile.split('\n');

        for (var line in lines) {
          final formatted = line.replaceAll('\r', '').trim();
          if (formatted.startsWith('//') || formatted.isEmpty) continue;

          final command =
              formatted.contains(':') ? formatted.split(':')[0] : formatted;
          final info = formatted.contains(':') ? formatted.split(':')[1] : '';

          if (command == "EcuMapFile") {
            final ecuMap = EcuMapFile();
            final parts = info.split('+');
            for (var part in parts) {
              final endIndex = part.indexOf('>');
              if (endIndex < 1) continue;
              final bracketString = part.substring(1, endIndex);
              final reference = bracketString.split(',')[0];

              if (reference.contains("start_address")) {
                ecuMap.startAddress = bracketString.split(',')[1];
                ecuMap.startAddr =
                    int.tryParse(ecuMap.startAddress ?? "", radix: 16) ?? 0;
              } else if (reference.contains("end_address")) {
                ecuMap.endAddress = bracketString.split(',')[1];
                ecuMap.endAddr =
                    int.tryParse(ecuMap.endAddress ?? "", radix: 16) ?? 0;
              }
            }
            ecuMapFiles.add(ecuMap);
          }
        }
      }

      // Convert flash file to JSON using GetJson equivalent
      final flashJson = await GetJson().convertToJson(
        Uint8List.fromList(utf8.encode(flashFile)),
        ecuMapFiles.cast<EcuMapFile>(),
        (selectedEcu!.seedkeyalgoFnIndexValues ?? "").toString(),
      );
      _closeLoader();
      return flashJson;
    } catch (e) {
      _closeLoader();
      print("_readJson error: $e");
      return "";
    }
  }

  // ── 5. GET CAL ID ─────────────────────────────────────────────────────────
  Future<String> _getCalId() async {
    Get.dialog(
      const Center(
        child: Text(
          "Reading CAL Id...",
          style: TextStyle(color: Colors.white),
        ),
      ),
      barrierDismissible: false,
    );
    await Future.delayed(const Duration(milliseconds: 50));

    String calIdValue = "NA";
    try {
      final paramData =
          await AndroidOperationsService.getData("Parameter_LocalList");
      if (paramData == null || paramData.isEmpty) {
        _closeLoader();
        return calIdValue;
      }

      final res = ParameterModel.fromJson(jsonDecode(paramData));
      final calIdParam =
          res.results?.firstWhereOrNull((x) => x.parameter == "CAL ID");

      if (calIdParam != null) {
        for (var ecu in StaticData.ecuInfo) {
          final mapped = calIdParam.parameterIds
              ?.firstWhereOrNull((x) => x.ecu == ecu.ecuId);

          if (mapped != null) {
            final pidCode = ecu.pidList?.firstWhereOrNull(
              (x) =>
                  x.piCodeVariable?.any((y) => y.id == mapped.pidCode) == true,
            );

            if (pidCode != null) {
              final pidList = [pidCode];
              List<ReadPidResponseModel>? resp;

              if (App.connectedVia == "USB") {
                final raw = await App.usbConnectorService
                    ?.readPid(pidList: pidList.obs, pidByAddrSeq: "");
                resp = raw?.whereType<ReadPidResponseModel>().toList();
              } else {
                final raw = await App.wifiConnectorService
                    ?.readPid(pidList: pidList.obs, pidByAddrSeq: "");
                resp = raw?.whereType<ReadPidResponseModel>().toList();
              }

              if (resp != null && resp.isNotEmpty) {
                calIdValue = resp.first.status == "NOERROR"
                    ? resp.first.variables?.first.responseValue ?? "NA"
                    : resp.first.status ?? "NA";
              }
              break;
            }
          }
        }
      }
    } catch (e) {
      print("_getCalId error: $e");
    }

    _closeLoader();
    return calIdValue;
  }

  // ── 6. SAVE OFFLINE ───────────────────────────────────────────────────────
  Future<void> _saveFlashOffline(List<FlashRecord> records) async {
    try {
      const key = "OfflineAnalyze_FlashRecord";
      final existing = await AndroidOperationsService.getData(key);
      List<FlashOfflineAnalyze> data = [];

      if (existing != null && existing.isNotEmpty) {
        data = (jsonDecode(existing) as List)
            .map((e) => FlashOfflineAnalyze.fromJson(e))
            .toList();
      }

      data.add(
        FlashOfflineAnalyze(
          type: "flash_record",
          flashRecord: records,
          srnId: sessionModel!.id,
          srNumber: sessionModel!.srNumber,
        ),
      );

      await AndroidOperationsService.saveData(key, jsonEncode(data));
    } catch (e) {
      print("_saveFlashOffline error: $e");
    }
  }

  void _closeLoader() {
    if (Get.isDialogOpen == true) Get.back();
  }
}
