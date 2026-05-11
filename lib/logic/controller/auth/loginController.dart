import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/koel_LocalDataFlash_model.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/pidByAddrReqLocal_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/user_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/utils/get_device_unique_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoginController extends GetxController {
  final GetDeviceUniqueId getDeviceUniqueId = GetDeviceUniqueId();
  final AuthApiService services = AuthApiService();

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  var hidePassword = true.obs;
  var isRememberMeChecked = false.obs;

  var usernameController = TextEditingController().obs;
  var passwordController = TextEditingController().obs;
  UserModel userRequestModel = UserModel();
  UserResModel userResModel = UserResModel();

  var isPassword = true.obs;
  var isHelpPopupVisible = false.obs;

  var imgPassword = "ic_password.png".obs;
  var appVersion = "".obs;
  //Rx<UserResModel> user = UserResModel().obs;

  Future<void> initData() async {
    try {
      String isRemember =
          await AndroidOperationsService.getData("is_remember") ?? "false";

      if (isRemember == "true") {
        String email =
            await AndroidOperationsService.getData("user_email") ?? "";
        String pass =
            await AndroidOperationsService.getData("user_password") ?? "";

        // Set UI fields
        usernameController.value.text = email;
        passwordController.value.text = pass;

        // Set model
        userRequestModel.username = email;
        userRequestModel.password = pass;

        isRememberMeChecked.value = true;

        print("✅ Loaded Email: $email");
        print("✅ Loaded Password: $pass");
      } else {
        isRememberMeChecked.value = false;
      }

      // Device info
      var device = await AndroidOperationsService.getDeviceUniqueId();
      userRequestModel.macId = device.toString();
      userRequestModel.deviceType = "windows";
    } catch (e) {
      print("❌ initData error: $e");
    }
  }
  // ---------------- LOGIN ----------------

  Future<void> loginMethod() async {
    final username = usernameController.value.text.trim();
    final password = passwordController.value.text.trim();

    // IMPORTANT: assign to model
    userRequestModel.username = username;
    userRequestModel.password = password;

    if (username.isEmpty && password.isEmpty) {
      await alertMessage("Enter user name and password.");
      return;
    }

    if (username.isEmpty) {
      await alertMessage("Enter user name.");
      return;
    }

    if (password.isEmpty) {
      await alertMessage("Enter user password.");
      return;
    }

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      final isLogin = connectivityResult != ConnectivityResult.none
          ? await loginOnline()
          : await loginOffline();

      if (isLogin) {
        if (isRememberMeChecked.value) {
          await AndroidOperationsService.saveData(
              "user_email", userResModel.user ?? '');
          await AndroidOperationsService.saveData("user_password", password);
          await AndroidOperationsService.saveData("is_remember", "true");
        } else {
          await AndroidOperationsService.saveData("user_email", "");
          await AndroidOperationsService.saveData("user_password", "");
          await AndroidOperationsService.saveData("is_remember", "false");
        }

        App.userResModel = userResModel;

        Get.offAllNamed(Routes.esnScreen);
      }
    } catch (e, st) {
      await alertMessage("$e\n$st", "Exception in LoginMethod()");
    }
  }

  bool isLoaderOpen = false;
  // ---------------- API METHODS ----------------
  Future<bool> loginOnline() async {
    try {
      print("👉 loginOnline() STARTED");
      final loader = CommonLoader(message: "Loggin...");

      Get.dialog(loader, barrierDismissible: false);
      isLoaderOpen = true;

      await Future.delayed(const Duration(milliseconds: 200));

      print("👉 Calling API login");

      userResModel = await AuthApiService.login(userRequestModel);

      print("👉 API RESPONSE RECEIVED");
      print("Message: ${userResModel.message}");
      print("User: ${userResModel.user}");
      print("Error: ${userResModel.error}");
      print("Detail: ${userResModel.detail}");

      // ❌ FAILURE CASE
      if (userResModel.message != "success") {
        print("❌ LOGIN FAILED");
        await alertMessage(userResModel.message ?? "Login failed");
        return false;
      }

      // ❌ INACTIVE USER CASE
      if (userResModel.isActive == false) {
        print("❌ USER NOT ACTIVE");
        await alertMessage(
          "${userResModel.error ?? ''}\n${userResModel.detail ?? ''}",
        );
        return false;
      }

      // ✅ SUCCESS CASE
      print("✅ LOGIN SUCCESS BLOCK");

      App.oemId = userResModel.profile?.oem?.id ?? 0;
      App.userId = userResModel.userId ?? 0;
      App.userEmail = userResModel.user ?? '';
      App.jwtToken = userResModel.token?.access ?? '';
      App.userRole = userResModel.role ?? '';

      print("👉 User assigned to App");

      if (userResModel.licences != null) {
        print("👉 Init runtime licence");
        initRuntimeLicence(userResModel.licences!);
      }

      // 🔹 Load previous user
      String? previousUserDetail =
          await AndroidOperationsService.getData("UserDetailL_LocalData");

      if (previousUserDetail != null && previousUserDetail.isNotEmpty) {
        var prev = UserResModel.fromJson(jsonDecode(previousUserDetail));

        if (userResModel.userId != prev.userId) {
          print("👉 Different user detected, clearing parameter list");
          await AndroidOperationsService.saveData("Parameter_LocalList", "");
        }
      }

      // 🔹 Save user data
      print("👉 Saving user data locally");

      await AndroidOperationsService.saveData(
        "UserDetailL_LocalData",
        jsonEncode(userResModel.toJson()),
      );

      await AndroidOperationsService.saveData(
        "UserRequest_LocalData",
        jsonEncode(userRequestModel.toJson()),
      );

      // 🔹 Check local data
      print("👉 Checking local data");

      String? modelLocalList =
          await AndroidOperationsService.getData("MODEL_LocalList");
      String? koelLocalList =
          await AndroidOperationsService.getData("KOEL_LocalList");
      String? pidByAddrSeqData =
          await AndroidOperationsService.getData("PidByAddrSeqData");
      String? sessionLocalList =
          await AndroidOperationsService.getData("Session_LocalList");
      String? variantLocalList =
          await AndroidOperationsService.getData("Variant_LocalList");
      String? freezeFrameLocalList =
          await AndroidOperationsService.getData("FreezeFrame_LocalList");
      String? iorLocalList =
          await AndroidOperationsService.getData("IOR_LocalList");
      String? actuatorLocalList =
          await AndroidOperationsService.getData("Actuator_LocalList");
      String? parameterLocalList =
          await AndroidOperationsService.getData("Parameter_LocalList");

      print("👉 Local check done");

      double totalDays = 0;

      String? date = await AndroidOperationsService.getData("last_update");
      print("👉 Last update date: $date");

      if (date != null && date.toString().isNotEmpty) {
        try {
          DateTime lastUpdateDate = DateFormat("dd-MM-yyyy").parse(date);

          totalDays =
              DateTime.now().difference(lastUpdateDate).inDays.toDouble();

          print("👉 Total days since update: $totalDays");
        } catch (e) {
          print("❌ Date parse error: $e");
        }
      }

      // 🔹 Decide flow
      bool needsUpdate = modelLocalList == null ||
          koelLocalList == null ||
          pidByAddrSeqData == null ||
          sessionLocalList == null ||
          variantLocalList == null ||
          freezeFrameLocalList == null ||
          iorLocalList == null ||
          actuatorLocalList == null ||
          parameterLocalList == null ||
          totalDays > 7;

      bool result;

      if (needsUpdate) {
        print("👉 Updating LOCAL DATA required");
        final loader = CommonLoader(
            message:
                "Updating Local Data...\nPlease Wait...\nThis may take few minutes");

        Get.dialog(loader, barrierDismissible: false);
        isLoaderOpen = true;

        await Future.delayed(const Duration(milliseconds: 200));

        result = await updateModelToLocal(totalDays > 7);
      } else {
        print("👉 Local data is up to date, skipping update");

        result = true; // IMPORTANT FIX
      }
      print("👉 loginOnline RETURN: $result");
      return result;
    } catch (ex, st) {
      print("❌ EXCEPTION loginOnline: $ex");
      print("STACK: $st");

      await alertMessage("$ex", "Exception in loginOnline()");
      return false;
    } finally {
      print("👉 HIDE LOADING");
      hideLoading();
    }
  }

  void initRuntimeLicence(Licences licences) {
    try {
      StaticData.runTimeLicenceList = [];

      if (licences.readClearDTC == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "DTC",
            image: "assets/images/ic_dtc.png",
          ),
        );
      }

      if (licences.readPID == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "Live Parameter",
            image: "assets/images/ic_live_parameter.png",
          ),
        );
      }

      if (licences.writePID == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "Write Parameter",
            image: "assets/images/ic_edit.png",
          ),
        );
      }

      if (licences.flash == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "Flash",
            image: "assets/images/ic_charge.png",
          ),
        );
      }

      if (licences.actTest == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "Actuator Test",
            image: "assets/images/ic_actuator_test.png",
          ),
        );
      }

      if (licences.routineTest == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "Routine Test",
            image: "assets/images/ic_ss.png",
          ),
        );
      }

      if (licences.partReplacement == true) {
        StaticData.runTimeLicenceList.add(
          StaticRunTimeLicence(
            name: "Part Replacement",
            image: "assets/images/ic_part_replacement.png",
          ),
        );
      }

      App.isGd = licences.dtcGuidedDiagnostics ?? false;
    } catch (e) {
      // ignore or log
      print("InitRuntimeLicence error: $e");
    }
  }

  Future<bool> loginOffline() async {
    try {
      bool returnValue = true;

      String lastUpdate = await AppPreferences.getString("last_update") ?? "";

      if (lastUpdate.isNotEmpty) {
        DateTime lastUpdateDate = DateFormat("dd-MM-yyyy").parse(lastUpdate);

        double totalDays =
            DateTime.now().difference(lastUpdateDate).inDays.toDouble();

        if (totalDays > 7) {
          await alertMessage(
            "You need to update your local database.\nTry to login with internet.",
          );
          return false;
        }
      } else {
        await alertMessage(
          "You need to update your local database.\nTry to login with internet.",
        );
        return false;
      }

      if (returnValue) {
        String? modelLocalList =
            await AndroidOperationsService.getData("MODEL_LocalList");
        String? koelLocalList =
            await AndroidOperationsService.getData("KOEL_LocalList");
        String? pidByAddrSeqData =
            await AndroidOperationsService.getData("PidByAddrSeqData");
        String? sessionLocalList =
            await AndroidOperationsService.getData("Session_LocalList");
        String? variantLocalList =
            await AndroidOperationsService.getData("Variant_LocalList");
        String? freezeFrameLocalList =
            await AndroidOperationsService.getData("FreezeFrame_LocalList");
        String? iorLocalList =
            await AndroidOperationsService.getData("IOR_LocalList");
        String? parameterLocalList =
            await AndroidOperationsService.getData("Parameter_LocalList");

        if (modelLocalList == null ||
            koelLocalList == null ||
            pidByAddrSeqData == null ||
            sessionLocalList == null ||
            variantLocalList == null ||
            freezeFrameLocalList == null ||
            iorLocalList == null ||
            parameterLocalList == null) {
          await alertMessage(
            "Local data not completely updated.\nTry to login with internet.",
          );
          return false;
        }

        String? responseData =
            await AndroidOperationsService.getData("UserDetailL_LocalData");

        if (responseData == null || responseData.isEmpty) {
          await alertMessage("Try to login with internet.");
          return false;
        }

        UserResModel userResModel =
            UserResModel.fromJson(jsonDecode(responseData));

        if (userResModel.user != userRequestModel.username) {
          await alertMessage("Different user login\nTry with internet");
          return false;
        }

        // Device type
        userRequestModel.deviceType =
            Platform.isAndroid ? "android" : "windows";

        if (userResModel.message == "success" &&
            (userResModel.error?.isNotEmpty ?? false) &&
            userResModel.isActive == false) {
          await alertMessage(userResModel.error ?? "");
          return false;
        } else if (userResModel.message == "success") {
          App.oemId = userResModel.profile?.oem?.id ?? 0;
          App.userId = userResModel.userId ?? 0;
          App.userEmail = userResModel.user ?? '';
          App.jwtToken = userResModel.token?.access ?? '';
          App.userRole = userResModel.role ?? '';
          App.workshop = userResModel.profile?.workshop;
          App.workshopGrp = userResModel.profile?.workshopGroup;

          if (userResModel.licences != null) {
            initRuntimeLicence(userResModel.licences!);
          }

          return true;
        }
      }

      return returnValue;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkLatestAppVersion() async {
    try {
      var result = await services.checkLatestAppVersion();

      if (result.message == "success") {
        String appVersion = await AndroidOperationsService.getVersionNumber();

        String savedVersion =
            await AppPreferences.getString("LatestAppVersion") ?? "";

        if (savedVersion.isEmpty) {
          await AppPreferences.setString("LatestAppVersion", appVersion);
          await AppPreferences.setString("LatestDatabseVersion", "");
        } else if (savedVersion != appVersion) {
          await AppPreferences.setString("LatestAppVersion", appVersion);
          await AppPreferences.setString("LatestDatabseVersion", "");
        }

        return true;
      } else {
        alertMessage(result.message ?? "Error");
        return false;
      }
    } catch (e) {
      alertMessage("Something went wrong");
      return false;
    }
  }

  Future<bool> checkLatestDbVersion() async {
    bool returnValue = false;

    try {
      var result = await services.checkLatestDbVersion();

      if (result.message == "success") {
        String savedDbVersion =
            await AppPreferences.getString("LatestDatabseVersion") ?? "";

        String apiDbVersion = result.results?[0].dbVersion ?? "";

        if (savedDbVersion.isEmpty) {
          await AppPreferences.setString("LatestDatabseVersion", apiDbVersion);
          returnValue = true;
        } else if (apiDbVersion != savedDbVersion) {
          await AppPreferences.setString("LatestDatabseVersion", apiDbVersion);
          returnValue = true;
        } else {
          returnValue = false;
        }

        // last update check
        String lastUpdate = await AppPreferences.getString("last_update") ?? "";

        if (lastUpdate.isNotEmpty) {
          DateTime lastUpdateDate = DateFormat("dd-MM-yyyy").parse(lastUpdate);

          double totalDays =
              DateTime.now().difference(lastUpdateDate).inDays.toDouble();

          if (totalDays > 7) {
            returnValue = true;
          }
        }

        // local parameter check
        if (!returnValue) {
          String? jsonListData =
              await AndroidOperationsService.getData("Parameter_LocalList");

          if (jsonListData == null || jsonListData.isEmpty) {
            returnValue = true;
          }
        }

        return returnValue;
      } else {
        alertMessage(result.message ?? "Error");
        return false;
      }
    } catch (e) {
      alertMessage("Something went wrong");
      return false;
    }
  }

  Future<bool> updateModelToLocal(bool isExpired) async {
    try {
      print("👉 updateModelToLocal START");

      await AndroidOperationsService.saveData("Parameter_LocalList", "");
      print("✔ Parameter_LocalList cleared");

      bool returnValue = false;

      String? localData =
          await AndroidOperationsService.getData("MODEL_LocalList");

      print("👉 MODEL_LocalList fetched: ${localData != null}");

      AllModelsModel? result;

      // STEP 1: LOAD MODEL DATA
      if (localData == null || localData.isEmpty || isExpired) {
        print("👉 Fetching models from API (isExpired=$isExpired)");

        var resp = await services.getApiResponse(
          "/api/v1/models/get-models/?oem=${userResModel.profile?.oem?.id}",
        );

        print("👉 Model API response success: ${resp.success}");

        if (resp.success == true) {
          result = AllModelsModel.fromJson(jsonDecode(resp.data ?? ''));

          print("✔ Models parsed from API");

          await AndroidOperationsService.saveData(
              "MODEL_LocalList", resp.data ?? '');

          print("✔ MODEL_LocalList saved");
        } else {
          print("❌ Model API failed: ${resp.data}");
          await alertMessage("Error in Saving Models List: ${resp.data}");
          return false;
        }
      } else {
        print("👉 Loading models from LOCAL storage");

        result = AllModelsModel.fromJson(jsonDecode(localData));

        print("✔ Models parsed from LOCAL");
      }

      // Safety check
      if (result.results == null) {
        print("❌ result or result.results is NULL");
        return false;
      }

      print("👉 Total models: ${result.results!.length}");

      // STEP 2: CHAIN OPERATIONS
      print("👉 Starting PID/DTC download");

      if (await downloadPidDtcToLocal(result.results, isExpired)) {
        print("✔ PID/DTC DONE");

        returnValue =
            await downloadSequenceFileToLocal(result.results!, isExpired);

        print("👉 Sequence file result: $returnValue");

        if (returnValue) {
          returnValue = await downloadPidByAddrSequenceFileToLocal(
              result.results!, isExpired);

          print("👉 PID By Addr result: $returnValue");
        }

        if (returnValue) {
          returnValue = await downloadMappedPidToLocal(isExpired);
          print("👉 Mapped PID result: $returnValue");
        }

        if (returnValue) {
          returnValue = await updateSessionListToLocal(isExpired);
          print("👉 Session list result: $returnValue");
        }

        if (returnValue) {
          returnValue = await updateIorListToLocal(isExpired);
          print("👉 IOR list result: $returnValue");
        }

        if (returnValue) {
          returnValue = await updateActuatorListToLocal(isExpired);
          print("👉 Actuator list result: $returnValue");
        }

        if (returnValue) {
          returnValue = await updateVariantListToLocal(isExpired);
          print("👉 Variant list result: $returnValue");
        }

        if (returnValue) {
          returnValue = await updateFreezeFrameListToLocal(isExpired);
          print("👉 Freeze frame result: $returnValue");
        }

        if (returnValue) {
          print("👉 Updating ENV SET LIST");
          returnValue = await updateEnvSetListToLocal(result.results ?? []);
          print("👉 EnvSet result: $returnValue");
        }

        if (returnValue) {
          print("👉 Fetching ticket list");
          returnValue = await getTicketList(App.userId);
          print("👉 Ticket list result: $returnValue");
        }

        if (returnValue) {
          returnValue = await updateParameterListToLocal(isExpired);
          print("👉 Parameter list result: $returnValue");
        }
      } else {
        print("❌ PID/DTC FAILED");
      }

      print("👉 FINAL RETURN VALUE: $returnValue");

      return returnValue;
    } catch (e, st) {
      print("❌ EXCEPTION in updateModelToLocal: $e");
      print("STACKTRACE: $st");

      await alertMessage("Exception in UpdateModelToLocal(): $e");
      return false;
    }
  }

  Future<bool> downloadPidDtcToLocal(
    List<ModelResult>? models,
    bool isExpired,
  ) async {
    try {
      print("👉 downloadPidDtcToLocal START");
      print("👉 isExpired: $isExpired");

      bool result = false;

      List<Dataset> dtcDatasetList = [];
      List<PidDataset> pidDatasetList = [];
      List<MappedPidDataset> mappedPidDatasetList = [];

      if (models != null && models.isNotEmpty) {
        print("👉 Total models: ${models.length}");

        for (var model in models) {
          print("👉 Model: ${model.modelName} (ID: ${model.id})");

          if (model.subModels != null && model.subModels!.isNotEmpty) {
            for (var subModel in model.subModels!) {
              print("   👉 SubModel: ${subModel.name} (ID: ${subModel.id})");

              if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                for (var ecu in subModel.ecus!) {
                  print("      👉 ECU: ${ecu.name} (ID: ${ecu.id})");

                  // DTC datasets
                  if (ecu.datasets != null && ecu.datasets!.isNotEmpty) {
                    print("         ✔ DTC datasets: ${ecu.datasets!.length}");

                    for (var dtcDataset in ecu.datasets!) {
                      dtcDatasetList.add(dtcDataset);
                    }

                    // version datasets → convert to Dataset
                    if (ecu.versionDataset != null &&
                        ecu.versionDataset!.isNotEmpty) {
                      print(
                          "         ✔ Version datasets: ${ecu.versionDataset!.length}");

                      for (var versionDataset in ecu.versionDataset!) {
                        dtcDatasetList.add(
                          Dataset(id: versionDataset.dataset),
                        );
                      }
                    }
                  }

                  // PID datasets
                  if (ecu.pidDatasets != null && ecu.pidDatasets!.isNotEmpty) {
                    print(
                        "         ✔ PID datasets: ${ecu.pidDatasets!.length}");

                    for (var pidDataset in ecu.pidDatasets!) {
                      pidDatasetList.add(pidDataset);
                    }
                  }

                  // Mapped PID datasets
                  if (ecu.mappedPidDatasets != null &&
                      ecu.mappedPidDatasets!.isNotEmpty) {
                    print(
                        "         ✔ Mapped PID datasets: ${ecu.mappedPidDatasets!.length}");

                    for (var mappedPidDataset in ecu.mappedPidDatasets!) {
                      mappedPidDatasetList.add(mappedPidDataset);
                    }
                  }
                }
              }
            }
          }
        }
      } else {
        print("❌ Models list is NULL or EMPTY");
      }

      print("👉 FINAL PID dataset count: ${pidDatasetList.length}");
      print("👉 FINAL DTC dataset count: ${dtcDatasetList.length}");
      print(
          "👉 FINAL Mapped PID dataset count: ${mappedPidDatasetList.length}");

      // STEP 1: download PID
      print("👉 Starting PID download...");
      result = await downloadPidToLocal(pidDatasetList, isExpired);
      print("👉 PID download result: $result");

      // STEP 2: download DTC if PID success
      if (result) {
        print("👉 Starting DTC download...");
        result = await downloadDtcToLocal(dtcDatasetList, isExpired);
        print("👉 DTC download result: $result");
      } else {
        print("❌ PID download failed, skipping DTC");
      }

      print("👉 downloadPidDtcToLocal FINAL RESULT: $result");

      return result;
    } catch (e, st) {
      print("❌ Exception in DownloadPidDtcToLocal: $e");
      print("STACKTRACE: $st");

      await alertMessage("Exception in DownloadPidDtcToLocal(): $e");
      return false;
    }
  }

  Future<bool> downloadPidToLocal(
    List<PidDataset> pidDatasets,
    bool isExpired,
  ) async {
    bool returnValue = false;

    try {
      if (pidDatasets.isNotEmpty) {
        // Group by id (LINQ equivalent)
        Map<int, List<PidDataset>> grouped = {};

        for (var p in pidDatasets) {
          grouped.putIfAbsent(p.id!, () => []);
          grouped[p.id!]!.add(p);
        }

        for (var entry in grouped.entries) {
          int key = entry.key;

          var resp = await services.getApiResponse(
            "/api/v1/datasets/get-pid-datasets/?id=$key",
          );

          if (resp.success == true) {
            await AndroidOperationsService.saveData(
                "PidDataset_$key", resp.data ?? '');
            returnValue = true;
          } else {
            alertMessage("Error in Saving PID Data: ${resp.data}");
            return false;
          }
        }
      }

      return returnValue;
    } catch (e) {
      alertMessage("Exception in DownloadPidToLocal(): $e");
      return false;
    }
  }

  Future<bool> downloadMappedPidToLocal(bool isExpired) async {
    try {
      String? localData =
          await AndroidOperationsService.getData("MappedPidDataset");

      // If no local data OR expired → fetch from API
      if (localData == null || localData.isEmpty || isExpired) {
        var mappedPidResponse = await services.getApiResponse(
          "/api/v1/datasets/get-mapped-pid-datasets/",
        );

        if (mappedPidResponse.success == true) {
          await AndroidOperationsService.saveData(
              "MappedPidDataset", mappedPidResponse.data ?? '');
          return true;
        } else {
          alertMessage(
            "Error in Saving Mapped PID Data: ${mappedPidResponse.data}",
          );
          return false;
        }
      }

      // Already available locally
      return true;
    } catch (e) {
      alertMessage("Exception in DownloadMappedPidToLocal(): $e");
      return false;
    }
  }

  Future<bool> downloadDtcToLocal(
    List<Dataset> datasets,
    bool isExpired,
  ) async {
    bool returnValue = false;

    try {
      if (datasets.isNotEmpty) {
        // Group by id (LINQ equivalent)
        Map<int, List<Dataset>> grouped = {};

        for (var d in datasets) {
          grouped.putIfAbsent(d.id!, () => []);
          grouped[d.id!]!.add(d);
        }

        // API call per group
        for (var entry in grouped.entries) {
          int key = entry.key;

          var resp = await services.getApiResponse(
            "/api/v1/datasets/get-dtc-datasets/?id=$key",
          );

          if (resp.success == true) {
            await AndroidOperationsService.saveData(
                "DtcDataset_$key", resp.data ?? '');
            returnValue = true;
          } else {
            alertMessage("Error in Saving DTC Data: ${resp.data}");
            return false;
          }
        }
      }

      return returnValue;
    } catch (e) {
      alertMessage("Exception in DownloadDtcToLocal(): $e");
      return false;
    }
  }

  Future<bool> downloadSequenceFileToLocal(
    List<ModelResult> models,
    bool isExpired,
  ) async {
    try {
      String? localData =
          await AndroidOperationsService.getData("KOEL_LocalList");

      if (localData == null || localData.isEmpty || isExpired) {
        List<RootKoelocalModel> rootKoelocalModelList = [];

        if (models.isNotEmpty) {
          for (var model in models) {
            RootKoelocalModel rootKoelocalModel = RootKoelocalModel(
              modelDetail: LocalModel(
                modelName: model.modelName,
                modelId: model.id,
                oemId: model.oem,
                subModelList: [],
              ),
            );

            if (model.subModels != null && model.subModels!.isNotEmpty) {
              for (var subModel in model.subModels!) {
                SubModelLocalModel subModelLocalModel = SubModelLocalModel(
                  subModelId: subModel.id,
                  subModelName: subModel.name,
                  ecuList: [],
                );

                if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                  for (var ecu in subModel.ecus!) {
                    EcuLocalModel ecuLocalModel = EcuLocalModel(
                      ecuId: ecu.id,
                      ecuName: ecu.name,
                      ecu2LocalModels: [],
                    );

                    if (ecu.ecu != null && ecu.ecu!.isNotEmpty) {
                      for (var ecu2 in ecu.ecu!) {
                        String sequenceFile = await services.readJsonFile(
                          ecu2.sequenceFile ?? '',
                        );

                        Ecu2LocalModel ecu2LocalModel = Ecu2LocalModel(
                          sequenceId: ecu2.id,
                          sequenceFileName: ecu2.sequenceFileName,
                          sequenceUrl: ecu2.sequenceFile,
                          sequenceLocalFile: sequenceFile,
                        );

                        ecuLocalModel.ecu2LocalModels!.add(ecu2LocalModel);
                      }
                    }

                    subModelLocalModel.ecuList!.add(ecuLocalModel);
                  }
                }

                rootKoelocalModel.modelDetail!.subModelList!
                    .add(subModelLocalModel);
              }
            }

            rootKoelocalModelList.add(rootKoelocalModel);
          }
        }

        // SAVE LOCAL DATA
        String jsonData = jsonEncode(
          rootKoelocalModelList.map((e) => e.toJson()).toList(),
        );

        await AndroidOperationsService.saveData("KOEL_LocalList", jsonData);

        return true;
      }

      return true;
    } catch (e) {
      alertMessage("Exception in DownloadSequenceFileToLocal(): $e");
      return false;
    }
  }

  Future<bool> downloadPidByAddrSequenceFileToLocal(
    List<ModelResult> models,
    bool isExpired,
  ) async {
    try {
      String? localData =
          await AndroidOperationsService.getData("PidByAddrSeqData");

      if (localData == null || localData.isEmpty || isExpired) {
        List<PidByAddrSeqLocalModel> pidByAddrSeqList = [];

        if (models.isNotEmpty) {
          for (var model in models) {
            if (model.subModels != null && model.subModels!.isNotEmpty) {
              for (var subModel in model.subModels!) {
                if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                  for (var ecu in subModel.ecus!) {
                    PidByAddrSeqLocalModel pidByAddrSeqLocalModel =
                        PidByAddrSeqLocalModel(
                      ecuId: ecu.id,
                    );

                    if (ecu.readWritePidByAddr != null &&
                        ecu.readWritePidByAddr!.isNotEmpty) {
                      pidByAddrSeqLocalModel.pidByAddrFsq =
                          await services.readJsonFile(
                        ecu.readWritePidByAddr!,
                      );
                    }

                    pidByAddrSeqList.add(pidByAddrSeqLocalModel);
                  }
                }
              }
            }
          }
        }

        // SAVE LOCAL DATA
        String jsonData = jsonEncode(
          pidByAddrSeqList.map((e) => e.toJson()).toList(),
        );

        await AndroidOperationsService.saveData("PidByAddrSeqData", jsonData);

        return true;
      }

      return true;
    } catch (e) {
      alertMessage(
        "Exception in DownloadPidByAddrSequenceFileToLocal(): $e",
      );
      return false;
    }
  }

  Future<bool> updateSessionListToLocal(bool isExpired) async {
    try {
      print("👉 updateSessionListToLocal START");
      print("👉 isExpired: $isExpired");

      String? localData =
          await AndroidOperationsService.getData("Session_LocalList");

      print(
          "👉 Local Session data exists: ${localData != null && localData.isNotEmpty}");

      // If no local data OR expired → fetch from API
      if (localData == null || localData.isEmpty || isExpired) {
        print("👉 Fetching Session List from API");

        print(
            "👉 API URL: /api/v1/analyze/srsession-list/?created_by=${App.userId}");

        var resp = await services.getApiResponse(
          "/api/v1/analyze/srsession-list/?created_by=${App.userId}",
        );

        print("👉 Session API response success: ${resp.success}");

        if (resp.success == true) {
          print("✔ Session API SUCCESS");

          await AndroidOperationsService.saveData(
            "Session_LocalList",
            resp.data ?? '',
          );

          print("✔ Session data saved locally");

          return true;
        } else {
          print("❌ Session API FAILED: ${resp.data}");

          alertMessage("Error in Saving Session List: ${resp.data}");
          return false;
        }
      }

      print("👉 Using existing local Session data (no API call)");
      return true;
    } catch (e, st) {
      print("❌ Exception in UpdateSessionListToLocal: $e");
      print("STACKTRACE: $st");

      alertMessage("Exception in UpdateSessionListToLocal(): $e");
      return false;
    }
  }

  Future<bool> updateVariantListToLocal(bool isExpired) async {
    try {
      String? localData =
          await AndroidOperationsService.getData("Variant_LocalList");

      // If no local data OR expired → fetch from API
      if (localData == null || localData.isEmpty || isExpired) {
        var resp = await services.getApiResponse(
          "/api/v1/variant/list/?oem=${App.oemId}",
        );

        if (resp.success == true) {
          await AndroidOperationsService.saveData(
              "Variant_LocalList", resp.data ?? '');
          return true;
        } else {
          alertMessage("Error in Saving Variant List: ${resp.data}");
          return false;
        }
      }

      // Already available locally
      return true;
    } catch (e) {
      alertMessage("Exception in UpdateVariantListToLocal(): $e");
      return false;
    }
  }

  Future<bool> updateFreezeFrameListToLocal(bool isExpired) async {
    try {
      String? localData =
          await AndroidOperationsService.getData("FreezeFrame_LocalList");

      // If no local data OR expired → fetch from API
      if (localData == null || localData.isEmpty || isExpired) {
        var resp = await services.getApiResponse(
          "/api/v1/datasets/get-freeze-frames/",
        );

        if (resp.success == true) {
          await AndroidOperationsService.saveData(
              "FreezeFrame_LocalList", resp.data ?? '');
          return true;
        } else {
          alertMessage("Error in Saving Freeze Frame List: ${resp.data}");
          return false;
        }
      }

      // Already available locally
      return true;
    } catch (e) {
      alertMessage("Exception in UpdateFreezeFrameListToLocal(): $e");
      return false;
    }
  }

  Future<bool> updateEnvSetListToLocal(List<ModelResult>? models) async {
    try {
      if (models == null || models.isEmpty) return true;

      for (var model in models) {
        if (model.subModels == null) continue;

        for (var subModel in model.subModels!) {
          if (subModel.ecus == null) continue;

          for (var ecu in subModel.ecus!) {
            var resp = await services.getApiResponse(
              "/api/v1/datasets/get-environment-snapshot/?ecu=${ecu.id}",
            );

            if (resp.success == true) {
              await AndroidOperationsService.saveData(
                "EnvSet_LocalList_forEcu_${ecu.id}",
                resp.data ?? '',
              );
            } else {
              await alertMessage(
                "Error in Saving Environment Snapshot: ${resp.data}",
              );
              return false;
            }
          }
        }
      }

      return true;
    } catch (e) {
      await alertMessage("Exception in UpdateEnvSetListToLocal(): $e");
      return false;
    }
  }

  Future<bool> updateIorListToLocal(bool isExpired) async {
    try {
      final localData = await AndroidOperationsService.getData("IOR_LocalList");

      if (localData == null || localData.toString().isEmpty || isExpired) {
        final resp = await services.getApiResponse(
          "/api/v1/ior-test/ior-test-list/",
        );

        if (resp.success == true) {
          await AndroidOperationsService.saveData(
              "IOR_LocalList", resp.data ?? '');
          return true;
        } else {
          await alertMessage("Error in Saving Routine List\n${resp.data}");
          return false;
        }
      }

      return true;
    } catch (e, st) {
      await alertMessage("$e\n$st", "Exception in UpdateIorListToLocal()");
      return false;
    }
  }

  Future<bool> updateActuatorListToLocal(bool isExpired) async {
    try {
      final localData =
          await AndroidOperationsService.getData("Actuator_LocalList");

      if (localData == null || localData.toString().isEmpty || isExpired) {
        final resp = await services.getApiResponse(
          "/api/v1/ior-test/actuator-test-list/",
        );

        if (resp.success == true) {
          await AndroidOperationsService.saveData(
              "Actuator_LocalList", resp.data ?? '');
          return true;
        } else {
          await alertMessage(
            "Error in Saving Actuator List\n${resp.data}",
          );
          return false;
        }
      }

      return true;
    } catch (e, st) {
      await alertMessage(
        "$e\n$st",
        "Exception in UpdateActuatorListToLocal()",
      );
      return false;
    }
  }

  Future<bool> updateParameterListToLocal(bool isExpired) async {
    try {
      final localData =
          await AndroidOperationsService.getData("Parameter_LocalList");

      if (localData == null || localData.toString().isEmpty || isExpired) {
        final resp = await services.getApiResponse(
          "/api/v1/parameter/list/",
        );

        if (resp.success == true) {
          await AndroidOperationsService.saveData(
              "Parameter_LocalList", resp.data ?? '');

          final date = DateTime.now();
          final formattedDate = "${date.day.toString().padLeft(2, '0')}-"
              "${date.month.toString().padLeft(2, '0')}-"
              "${date.year}";

          await AndroidOperationsService.saveData("last_update", formattedDate);

          return true;
        } else {
          await alertMessage(
            "Error in Saving Parameter List\n${resp.data}",
          );
          return false;
        }
      }

      return true;
    } catch (e, st) {
      await alertMessage(
        "$e\n$st",
        "Exception in UpdateParameterListToLocal()",
      );
      return false;
    }
  }

  Future<bool> getTicketList(int userId) async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/workshop/get/ticket/?user=$userId",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
            "GetTicketList", resp.data ?? '');
        return true;
      } else {
        await alertMessage(
          "Error in Saving Ticket List\n${resp.data}",
        );
        return false;
      }
    } catch (e, st) {
      await alertMessage(
        "$e\n$st",
        "Exception in GetTicketList()",
      );
      return false;
    }
  }
  // ---------------- UI HELPERS ----------------

  void togglePassword() {
    isPassword.value = !isPassword.value;
    imgPassword.value = isPassword.value ? "ic_password.png" : "ic_visible.png";
  }

  void showAlert(String message) {
    Get.snackbar("Alert", message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> alertMessage(String message, [String? title]) async {
    await Get.dialog(
      CustomPopup(
        title: title ?? "Alert",
        message: message,
        confirmText: "OK",
        onConfirm: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }

  void showLoading([String message = "Loading..."]) {
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  final String _supportMessage =
      "Please reach out to KOEL HO team in case of any assistance with the app.";
  void forgotPasswordTapped(BuildContext context) => showDialog(
        context: context,
        builder: (_) => CustomPopup1(
          title: "Forgot Password",
          message: _supportMessage,
        ),
      );

  void needHelpClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: "Need Help",
        message: "$_supportMessage\n\n(${userRequestModel.macId})",
      ),
    );
  }
}
