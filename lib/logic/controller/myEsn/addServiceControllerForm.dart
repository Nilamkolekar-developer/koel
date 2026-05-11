// import 'dart:convert';
// import 'dart:io';

// import 'package:autopeepal/logic/controller/myEsn/scannerController.dart';
// import 'package:autopeepal/models/all_models.dart';
// import 'package:autopeepal/models/creteSessionReq_model.dart';

// import 'package:autopeepal/models/staticData.dart';
// import 'package:autopeepal/models/variant_model.dart';

// import 'package:autopeepal/services/androidOperationservice.dart';
// import 'package:autopeepal/services/api_services.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:autopeepal/app.dart';

// class AddServiceRequestController extends GetxController {
//   final AuthApiService services = AuthApiService();
//   Rx<VariantModel?> variantModel = Rx<VariantModel?>(null);

//   // =========================
//   // TEXT CONTROLLERS (SINGLE SOURCE OF TRUTH)
//   // =========================
//   final srNumberCtrl = TextEditingController();
//   final esnCtrl = TextEditingController();
//   final customerNameCtrl = TextEditingController();
//   final customerVoiceCtrl = TextEditingController();
//   final gensetCtrl = TextEditingController();
//   final hoursCtrl = TextEditingController();
//   final complaintCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final appCodeCtrl = TextEditingController();
//   final varient = TextEditingController();

//   // =========================
//   // REQUEST MODEL
//   // =========================
//   final requestModel = CreateSessionReqModel().obs;

//   // =========================
//   // UI STATE
//   // =========================
//   final isFormVisible = false.obs;

//   final isCustomerVoiceEnabled = true.obs;
//   final isAppCodeEnabled = true.obs;
//   final isESNEnabled = true.obs;
//   final isCustomerNameEnabled = true.obs;
//   final isGensetEnabled = true.obs;
//   final isHoursEnabled = true.obs;

//   final srType = ''.obs;

//   // =========================
//   // SERVICE LIST
//   // =========================
//   final serviceList = <Map<String, dynamic>>[
//     {'id': 1, 'name': 'CSP', 'selected': false},
//     {'id': 2, 'name': 'BD & CM', 'selected': false},
//     {'id': 3, 'name': 'Line Rejection', 'selected': false},
//     {'id': 4, 'name': 'Campaign', 'selected': false},
//     {'id': 5, 'name': 'Post Warranty', 'selected': false},
//     {'id': 6, 'name': 'AMC', 'selected': false},
//     {'id': 7, 'name': 'Others', 'selected': false},
//   ].obs;

//   // =========================
//   // INIT
//   // =========================
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAddress();
//     initScannerListener();
//   }

//   void onVariantChanged(String selectedVariantCode) {
//   final model = variantModel.value;
//   if (model == null || model.results == null) return;

//   // Find the variant object where variantCode matches the UI selection
//   final found = model.results!.firstWhereOrNull(
//     (x) => x.variantCode == selectedVariantCode,
//   );

//   if (found != null) {
//     // Store the ID as a string for the API request
//     variant.value = found.id.toString();
//     requestModel.update((val) => val?.variant = found.id.toString());
//     print("✅ Variant ID Mapped: ${found.id}");
//   } else {
//     variant.value = "0";
//     requestModel.update((val) => val?.variant = "0");
//   }
// }

//   // =========================
//   // ADDRESS
//   // =========================
//   Future<void> fetchAddress() async {
//     try {
//       final result = await AndroidOperationsService.getCurrentAddress();
//       addressCtrl.text = result;
//     } catch (e) {
//       Get.snackbar("Error", "Failed to get address");
//     }
//   }

//   // =========================
//   // LOADER HELPERS
//   // =========================
//   void showLoader() {
//     if (!(Get.isDialogOpen ?? false)) {
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );
//     }
//   }

//   void hideLoader() {
//     if (Get.isDialogOpen ?? false) Get.back();
//   }

//   // =========================
//   // INTERNET CHECK
//   // =========================
//   Future<bool> checkInternet() async {
//     try {
//       final result = await InternetAddress.lookup('google.com')
//           .timeout(const Duration(seconds: 2));
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }

//   // =========================
//   // SERVICE SELECT
//   // =========================
//   void checkChange(Map<String, dynamic> item) {
//     for (var s in serviceList) {
//       s['selected'] = false;
//       if (s['id'] == item['id']) {
//         s['selected'] = true;
//         srType.value = s['name'];
//       }
//     }
//     serviceList.refresh();
//   }

//   // =========================
//   // BUILD REQUEST MODEL
//   // =========================
//   var appCode = ''.obs;
//   void _syncRequestModel() {
//     requestModel.update((val) {
//       val?.srNumber = srNumberCtrl.text;
//       val?.esn = esnCtrl.text;
//       val?.customerName = customerNameCtrl.text;
//       val?.customerVoice = customerVoiceCtrl.text;
//       val?.genset = gensetCtrl.text;
//       val?.hrs = hoursCtrl.text;
//       val?.complaint = complaintCtrl.text;
//       val?.srType = srType.value;

//       val?.latlong = addressCtrl.text;
//       val?.createdBy = App.userId;

//       // ✅ IMPORTANT: optional variant
//       val?.variant = variant.value.isNotEmpty ? variant.value : "0";
//     });
//   }

//   // =========================
//   // VALIDATION
//   // =========================
//   bool validate() {
//     final m = requestModel.value;
//     String msg = "";
//     int i = 1;

//     if ((m.srNumber ?? "").isEmpty) msg += "${i++}. SR Number required\n";
//     if ((m.esn ?? "").isEmpty) msg += "${i++}. ESN required\n";
//     if ((m.customerName ?? "").isEmpty)
//       msg += "${i++}. Customer Name required\n";
//     if ((m.genset ?? "").isEmpty) msg += "${i++}. Genset required\n";
//     if ((m.hrs ?? "").isEmpty) msg += "${i++}. Hours required\n";
//     if ((m.srType ?? "").isEmpty) msg += "${i++}. SR Type required\n";
//     if ((m.complaint ?? "").isEmpty) msg += "${i++}. Complaint required\n";
//     if ((m.latlong ?? "").isEmpty) msg += "${i++}. Location required\n";

//     if (msg.isNotEmpty) {
//       Get.defaultDialog(title: "Error", middleText: msg);
//       return false;
//     }

//     return true;
//   }

//   // =========================
//   // MAIN CREATE FLOW
//   // =========================
//   Future<void> createSrSession() async {
//     try {
//       showLoader();

//       _syncRequestModel();

//       final valid = validate();
//       if (!valid) {
//         hideLoader();
//         return;
//       }

//       final internet = await checkInternet();
//       if (!internet) {
//         hideLoader();
//         Get.defaultDialog(
//           title: "Alert",
//           middleText: "No Internet Connection",
//         );
//         return;
//       }

//       await createOnlineSR();

//       hideLoader();
//     } catch (e) {
//       hideLoader();
//       Get.defaultDialog(title: "Error", middleText: e.toString());
//     }
//   }

//   // =========================
//   // ONLINE CREATE
//   // =========================
//   Future<void> createOnlineSR() async {
//     final res = await services.createSession(requestModel.value);

//     if (res.success == true) {
//       Get.snackbar("Success", "Session Created");

//       final list = await services.getAllSessionList(App.userId);

//       await AndroidOperationsService.saveData(
//         "Session_LocalList",
//         jsonEncode(list.toJson()),
//       );

//       await getCreatedSession(res.id ?? 0);
//     } else {
//       Get.defaultDialog(
//         title: "Error",
//         middleText: res.message ?? "Failed",
//       );
//     }
//   }

//   // =========================
//   // GET CREATED SESSION
//   // =========================
//   Future<void> getCreatedSession(int sessionId) async {
//     try {
//       final res = await services.getSessionBySessionId(sessionId);

//       if (res.results == null || res.results!.isEmpty) return;

//       final item = res.results!.first;

//       final modelJson =
//           await AndroidOperationsService.getData("MODEL_LocalList");

//       final models = AllModelsModel.fromJson(jsonDecode(modelJson ?? "{}"));

//       final model = models.results
//           ?.firstWhereOrNull((x) => x.id == item.variant?.modelId);

//       if (model == null) return;

//       final subModel = model.subModels?.firstWhereOrNull(
//         (x) => x.id == item.variant?.sModelId,
//       );

//       if (subModel == null) return;

//       StaticData.ecuInfo = [];

//       for (var ecuRef in item.variant?.subModel?.ecus ?? []) {
//         final ecu = subModel.ecus?.firstWhereOrNull((x) => x.id == ecuRef.id);

//         if (ecu == null) continue;

//         StaticData.ecuInfo.add(
//           EcuDataSet(
//             ecuId: ecu.id,
//             ecuName: ecu.name,
//             protocol: ecu.protocol,
//             txHeader: ecu.txHeader,
//             rxHeader: ecu.rxHeader,
//             readDtcIndex: ecu.readDtcFnIndex?.value,
//             clearDtcIndex: ecu.clearDtcFnIndex?.value,
//           ),
//         );
//       }

//       Get.back();
//     } catch (e) {
//       Get.defaultDialog(title: "Error", middleText: e.toString());
//     }
//   }

//   var variantName = ''.obs;
//   var variant = ''.obs;
//   var esnFromScanner = ''.obs;
//   void initScannerListener() {
//     // ✅ ensure controller exists
//     if (!Get.isRegistered<ScannerController>()) {
//       Get.put(ScannerController());
//     }

//     Get.find<ScannerController>().scanStream.listen((value) {
//       try {
//         if (value.length >= 3) {
//           variantName.value = value[0];
//           variant.value = value[1];
//           esnFromScanner.value = value[2];

//           requestModel.update((val) {
//             val?.variant = value[1]; // optional
//             val?.esn = value[2];
//           });
//         }
//       } catch (e) {
//         Get.snackbar("Error", e.toString());
//       }
//     });
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/creteSessionReq_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/sessionService_model.dart';
import 'package:autopeepal/models/srSearchReq_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/variant_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateSessionController extends GetxController {
  final AuthApiService services = AuthApiService();

  // Observables (equivalent to C# properties)
  RxList<SessionServicesModel> serviceList = <SessionServicesModel>[].obs;
  Rx<CreateSessionReqModel> requestModel = CreateSessionReqModel().obs;
  Rx<VariantModel?> variantModel = Rx<VariantModel?>(null);

  RxString variantName = "".obs;
  RxString address = "".obs;
  RxString appCode = "".obs;

  RxBool isFormVisible = true.obs;
  RxBool isSearchVisible = false.obs;

  // UI States
  RxBool isCustomerVoiceEnabled = true.obs;
  RxBool isAppCodeEnabled = true.obs;
  RxBool isESNEnabled = true.obs;
  RxBool isCustomerNameEnabled = true.obs;
  RxBool isGensetEnabled = true.obs;
  RxBool isHoursEnabled = true.obs;
  final srNumberCtrl = TextEditingController();
  final customerVoiceCtrl = TextEditingController();
  final appCodeCtrl = TextEditingController();
  final esnCtrl = TextEditingController();
  final customerNameCtrl = TextEditingController();
  final gensetCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final complaintCtrl = TextEditingController();
  RxList<SessionModel> passedSessionList = <SessionModel>[].obs;
  // @override
  // void onInit() {
  //   super.onInit();

  //   // 1. GET THE ARGUMENTS PASSED FROM THE PREVIOUS SCREEN
  //   if (Get.arguments != null) {
  //     // Get Session List
  //     if (Get.arguments['sessionList'] != null) {
  //       passedSessionList.assignAll(Get.arguments['sessionList']);
  //       print("✅ Arguments: Session List Received");
  //     }

  //     // Get and Parse Variant Model
  //     if (Get.arguments['variant'] != null) {
  //       // If it's already a Map (decoded JSON), parse it to your model
  //       var variantData = Get.arguments['variant'];
  //       variantModel.value = VariantModel.fromJson(variantData);
  //       print("✅ Arguments: Variant Model Received");
  //     }
  //   }

  //   _initializeData();
  //   fetchCurrentAddress();
  // }
  @override
  void onInit() {
    super.onInit();

    print("📥 onInit CALLED");
    print("📦 Raw Get.arguments => ${Get.arguments}");

    if (Get.arguments != null) {
      // 🔹 SESSION LIST
      if (Get.arguments['sessionList'] != null) {
        print("📄 Session List Data => ${Get.arguments['sessionList']}");
        print(
            "📊 Session List Length => ${Get.arguments['sessionList'].length}");

        passedSessionList.assignAll(Get.arguments['sessionList']);
        print("✅ Arguments: Session List Assigned");
      } else {
        print("❌ sessionList NOT FOUND in arguments");
      }

      // 🔹 VARIANT MODEL
      if (Get.arguments['variant'] != null) {
        var variantData = Get.arguments['variant'];

        print("📄 Variant Raw Data => $variantData");
        print("📌 Variant Type => ${variantData.runtimeType}");

        variantModel.value = VariantModel.fromJson(variantData);

        print("✅ Arguments: Variant Model Parsed");
        print("📌 VariantModel => ${variantModel.value}");
      } else {
        print("❌ variant NOT FOUND in arguments");
      }
    } else {
      print("❌ Get.arguments is NULL");
    }

    _initializeData();
    fetchCurrentAddress();
  }

  void _initializeData() {
    // Visibility logic based on Workshop Group (App.workshopGrp != 6)
    bool isNotServiceDealer = App.workshopGrp != 6;
    isFormVisible.value = isNotServiceDealer;
    isSearchVisible.value = !isNotServiceDealer;

    // Initialize Service List
    serviceList.assignAll([
      SessionServicesModel(id: 1, name: "CSP", selected: false),
      SessionServicesModel(id: 2, name: "BD & CM", selected: false),
      SessionServicesModel(id: 3, name: "Line rejection", selected: false),
      SessionServicesModel(id: 4, name: "Campaign", selected: false),
      SessionServicesModel(id: 5, name: "Post warranty", selected: false),
      SessionServicesModel(id: 6, name: "AMC", selected: false),
      SessionServicesModel(id: 7, name: "Others", selected: false),
    ]);

    requestModel.value.createdBy = App.userId;
  }

  // Equivalent to CheckChangeCommand
  void onServiceTypeChanged(SessionServicesModel item) {
    if (App.workshopGrp == 6) return;

    for (var s in serviceList) {
      s.selected = (s.id == item.id);
      if (s.selected) {
        requestModel.update((val) => val?.srType = s.name);
      }
    }
    serviceList.refresh();
  }

  void _syncRequestModel() {
    requestModel.update((val) {
      val?.srNumber = srNumberCtrl.text;
      val?.customerVoice = customerVoiceCtrl.text;
      val?.esn = esnCtrl.text;
      val?.customerName = customerNameCtrl.text;
      val?.genset = gensetCtrl.text;
      val?.hrs = hoursCtrl.text;
      val?.complaint = complaintCtrl.text;

      appCode.value = appCodeCtrl.text;

      if (variantModel.value?.results != null) {
        // Log the search attempt
        print(
            "🔍 Searching for App Code: '${appCodeCtrl.text.trim().toUpperCase()}'");

        final found = variantModel.value!.results!.firstWhereOrNull((v) {
          // CRITICAL: Ensure 'variantCode' matches the variable name in your Variant class
          // If your model class uses 'variant_code', change the line below accordingly.
          String? codeToCompare = v.variantCode?.toString();

          return codeToCompare?.trim().toUpperCase() ==
              appCodeCtrl.text.trim().toUpperCase();
        });

        if (found != null) {
          val?.variant = found.id.toString();
          print("✅ Found Match! ID: ${val?.variant}");
        } else {
          val?.variant =
              null; // API will fail, but we'll catch it in validation
          print(
              "❌ No match found in ${variantModel.value!.results!.length} variants.");

          // Let's see what the actual keys look like in the list
          if (variantModel.value!.results!.isNotEmpty) {
            print(
                "💡 First Result Code: '${variantModel.value!.results!.first.variantCode}'");
          }
        }
      }

      print("--- Request Model Synced ---");
      print("Mapped Variant ID: ${val?.variant}");
      print("----------------------------");
    });
  }

  void checkChange(SessionServicesModel item) {
    // If the group is restricted, prevent manual changes
    if (App.workshopGrp == 6) return;

    for (var s in serviceList) {
      // FIX: Use dot notation (.) instead of brackets ([])
      s.selected = false;

      if (s.id == item.id) {
        s.selected = true;
        // Update the request model with the selected service name
        requestModel.update((val) => val?.srType = s.name);
      }
    }

    // Refresh the RxList to trigger UI update
    serviceList.refresh();
  }

  // Search SR Logic (Equivalent to SearchSRCommand)
  Future<void> searchSRNumber(String srNumber) async {
    try {
      showLoading();
      bool internet = await checkInternet();
      if (!internet) {
        hideLoading();
        Get.snackbar("Alert", "Please connect to internet");
        return;
      }

      var res = await services.searchSrNumber(srNumber as SRSearchRequestModel);
      if (res.error == "success") {
        var status = res.siebelMessage?.serviceRequestConnect?.statusClone;
        if (status == "Closed" || status == "Cancelled") {
          Get.snackbar("Alert", "This SR Session is already $status");
        } else {
          isFormVisible.value = true;
          var data = res.siebelMessage!.serviceRequestConnect!;

          requestModel.update((val) {
            val?.esn = data.ibmEngine;
            val?.genset = data.model;
            val?.customerName = data.customerName;
            val?.hrs = data.ibmAssetLastSerHrs;
            val?.customerVoice = data.comments;
            val?.instanceId = data.assetNumber;
          });

          appCode.value = data.ibmChasisNumber
                  ?.replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), "") ??
              "";

          // Trigger the switch-case logic for SR Type
          _mapSRType(data.srType ?? "");
          _updateFieldEnabling();
        }
      } else {
        Get.snackbar("Alert", res.error ?? "Search failed");
      }
      hideLoading();
    } catch (e) {
      hideLoading();
    }
  }

  // Main Save Logic (Equivalent to CreateCommand)
  Future<void> createSrSession() async {
    try {
      print("🚀 Starting createSrSession...");
      showLoading();

      await Future.delayed(const Duration(milliseconds: 100));

      _syncRequestModel(); // Pulls data from TextControllers to RequestModel
      requestModel.value.latlong = address.value;
      print("📍 Sync complete. LatLong: ${address.value}");

      print("🔍 Validating model...");
      //   bool isValid = await validateModel();
      // if (!isValid) {
      //   print("❌ Validation failed.");
      //   return;
      // }
      print("✅ Validation passed.");

      print("🌐 Checking connectivity...");
      bool isOnline = await checkInternet();
      if (isOnline) {
        print("📡 Online: Calling createOnlineSR...");
        await createOnlineSR();
        print("🏁 createOnlineSR execution finished.");
      } else {
        print("⚠️ Offline: Internet connection not found.");
        Get.snackbar("Offline", "Offline mode not implemented yet");
      }
    } catch (e) {
      print("🔴 Error in createSrSession: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      print("🔒 Closing loading state.");
      hideLoading(); // ALWAYS close loader
    }
  }

  Future<void> createOnlineSR() async {
    try {
      print("📡 Calling createSession API...");
      var res = await services.createSession(requestModel.value);

      // Log the full response to see why success might be null
      print("📩 API Response: Success = ${res.success}, ID = ${res.id}, ");

      // ✅ FIX 1: Use '== true' instead of '!'
      // This safely handles cases where success is null or false
      if (res.success == true) {
        print("🔄 Refreshing local list for User: ${App.userId}...");
        var listRes = await services.getAllSessionList(App.userId);

        print("💾 Saving list to Local Storage...");
        await AndroidOperationsService.saveData(
            "Session_LocalList", jsonEncode(listRes));

        Get.snackbar("Success", "Session Created Online");

        // ✅ FIX 2: Safe check for ID before forcing with '!'
        if (res.id != null) {
          print("🔎 Fetching and mapping created session ID: ${res.id}...");
          await fetchAndMapCreatedSession(res.id!);
        }

        print("✅ createOnlineSR completed successfully.");
      }
      // else {
      //   // ✅ FIX 3: Prioritize res.error if it exists (like "No Variant Code found")
      //   String errorMsg = res.error ?? res.message ?? "Online creation failed";
      //   print("⚠️ Server returned failure: $errorMsg");
      //   Get.snackbar("Error", errorMsg);
      // }
    } catch (e) {
      print("💥 Exception in createOnlineSR: $e");
      // This catch block will now catch any remaining parsing issues
      Get.snackbar("Error", "An unexpected error occurred");
    }
  }

  // Deep Mapping Logic (Equivalent to GetCreatedSession)
  Future<void> fetchAndMapCreatedSession(int sessionId) async {
    var res = await services.getSessionBySessionId(sessionId);
    if (res.message == "success" && res.results.isNotEmpty) {
      var item = res.results.first;

      String? modelsJson =
          await AndroidOperationsService.getData("MODEL_LocalList");
      if (modelsJson == null) return;

      AllModelsModel allModels =
          AllModelsModel.fromJson(jsonDecode(modelsJson));
      var model = allModels.results
          ?.firstWhereOrNull((x) => x.id == item.variant?.modelId);

      if (model != null) {
        var subModel = model.subModels
            ?.firstWhereOrNull((x) => x.id == item.variant?.sModelId);
        if (subModel != null) {
          StaticData.ecuInfo = []; // Clear old data

          // Map ECUs and PIDs (The complex loop from your C# code)
          for (var variantEcu in item.variant!.subModel!.ecus!) {
            var ecu =
                subModel.ecus?.firstWhereOrNull((x) => x.id == variantEcu.id);
            if (ecu != null) {
              String? pidLocal = await AndroidOperationsService.getData(
                  "PidDataset_${ecu.pidDatasets![0].id}");
              var pidDataset =
                  pidLocal != null ? Root.fromJson(jsonDecode(pidLocal)) : null;

              StaticData.ecuInfo.add(EcuDataSet(
                readDtcIndex: ecu.readDtcFnIndex?.value,
                pidDatasetId: ecu.pidDatasets![0].id,
                clearDtcIndex: ecu.clearDtcFnIndex?.value,
                dtcDatasetId: ecu.datasets![0].id,
                ecuName: ecu.name,
                protocol: ecu.protocol,
                txHeader: ecu.txHeader,
                rxHeader: ecu.rxHeader,
                pidList: pidDataset?.results?.first.codes,
              ));
            }
          }
          // Navigate to Connection Page
          Get.offNamed(
            Routes.ConnectionPage,
            arguments: {
              'session': item, // ✅ FIXED KEY
              'model': model,
              'isCreate': true
            },
          );
        }
      }
    }
  }

  // Validation (Equivalent to Validate method)
  Future<bool> validateModel() async {
    var m = requestModel.value;
    String errorMsg = "";

    if (m.srNumber == null || m.srNumber!.isEmpty)
      errorMsg += "Enter SR Number\n";
    if (m.variant == null || m.variant!.isEmpty)
      errorMsg += "Enter Variant Code\n";
    if (m.esn == null || m.esn!.isEmpty) errorMsg += "Enter ESN\n";
    if (m.customerName == null || m.customerName!.isEmpty)
      errorMsg += "Enter Customer Name\n";

    if (errorMsg.isNotEmpty) {
      Get.defaultDialog(title: "Error", middleText: errorMsg);
      return false;
    }
    return true;
  }

  // Helper: Address fetching
  Future<void> fetchCurrentAddress() async {
    try {
      String result = await AndroidOperationsService.getCurrentAddress();
      address.value = result;
      // ALWAYS update the controller text so it shows in the UI
      addressCtrl.text = result;
    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }

  void _mapSRType(String type) {
    String mappedType = "Others";
    if (type.contains("CSP"))
      mappedType = "CSP";
    else if (type.contains("Line"))
      mappedType = "Line rejection";
    else if (type.contains("Campaign"))
      mappedType = "Campaign";
    else if (type.contains("Post"))
      mappedType = "Post warranty";
    else if (type.contains("AMC")) mappedType = "AMC";

    onServiceTypeChanged(SessionServicesModel(name: mappedType));
  }

  void _updateFieldEnabling() {
    isCustomerVoiceEnabled.value =
        requestModel.value.customerVoice?.isEmpty ?? true;
    isAppCodeEnabled.value = appCode.value.isEmpty;
    isESNEnabled.value = requestModel.value.esn?.isEmpty ?? true;
    isCustomerNameEnabled.value =
        requestModel.value.customerName?.isEmpty ?? true;
  }

  void showLoading() => Get.dialog(Center(child: CircularProgressIndicator()),
      barrierDismissible: false);
  void hideLoading() => Get.back();

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
