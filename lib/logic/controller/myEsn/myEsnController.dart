import 'dart:convert';
import 'dart:io';

import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/creteSessionReq_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/variant_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Myesncontroller extends GetxController {
  var checkboxValues = <String, bool>{}.obs;
  final AuthApiService services = AuthApiService();
  RxList<SessionModel> sessionList = <SessionModel>[].obs;

  RxBool isOpenMode = false.obs;
  @override
  void onInit() {
    super.onInit();
    //getSessionList(); // 🔥 load once
  }

  // =========================
  // OPEN SRN
  // =========================
 Future<void> openSrnCommand() async {
  print("👉 Open SRN CLICKED");

  try {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    // 🔥 ADD THIS
    print("👉 SESSION LIST BEFORE LOAD: ${sessionList.length}");
    await getSessionList();
    print("👉 SESSION LIST AFTER LOAD: ${sessionList.length}");

    if (sessionList.isEmpty) {
      print("⚠️ Empty session list after API/local load");
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar("Alert", "SRN list not found.");
      return;
    }

    final list = sessionList.where((x) => x.status == "open").toList();

    print("👉 OPEN COUNT: ${list.length}");

    if (Get.isDialogOpen == true) Get.back();

    Get.toNamed(
      Routes.openServiceRequest,
      arguments: {
        "sessionList": list,
        "isOpenMode": true,
      },
    );

    print("✅ OPEN SRN NAVIGATION DONE");
  } catch (e) {
    print("❌ OPEN ERROR: $e");

    if (Get.isDialogOpen == true) Get.back();
    Get.snackbar("Failed", e.toString());
  }
}

  // =========================
  // CLOSE SRN
  // =========================
  Future<void> closeSrnCommand() async {
    print("👉 Close SRN CLICKED");

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      if (sessionList.isEmpty) {
        print("⚠️ Empty session list");
        if (Get.isDialogOpen == true) Get.back();
        Get.snackbar("Alert", "SRN list not found.");
        return;
      }

      final closedList =
          sessionList.where((x) => x.status == "closed").toList();

      print("👉 CLOSED COUNT: ${closedList.length}");

      if (closedList.isEmpty) {
        if (Get.isDialogOpen == true) Get.back();
        Get.snackbar("Alert", "SRN list not found.");
        return;
      }

      if (Get.isDialogOpen == true) Get.back();

      // ✅ FIXED NAVIGATION (named route style)
      Get.toNamed(
        Routes.openServiceRequest,
        arguments: {
          "sessionList": closedList,
          "isOpenMode": false,
        },
      );

      print("✅ CLOSED SRN NAVIGATION DONE");
    } catch (e) {
      print("❌ CLOSE ERROR: $e");

      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar("Failed", e.toString());
    }
  }

  Future<void> createNewSessionCommand() async {
    print("👉 Create New Session CLICKED");

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      // =========================
      // GET LOCAL VARIANT DATA
      // =========================
      final jsonListData =
          await AndroidOperationsService.getData("Variant_LocalList");

      print("👉 RAW VARIANT DATA: $jsonListData");

      if (jsonListData == null || jsonListData.isEmpty) {
        if (Get.isDialogOpen == true) Get.back();

        Get.snackbar(
          "Error",
          "Variants not found.\nPlease update local data.",
        );

        return;
      }

      // =========================
      // PARSE JSON
      // =========================
      final variantModel = VariantModel.fromJson(
        jsonDecode(jsonListData),
      );

      print("👉 VARIANT STATUS: ${variantModel.message}");

      List<Variant> validVariantList = [];

      if (variantModel.message == "success") {
        if (variantModel.results == null || variantModel.results!.isEmpty) {
          if (Get.isDialogOpen == true) Get.back();

          Get.snackbar(
            "Error",
            "Variants not found.\nPlease update local data.",
          );
          return;
        }

        // =========================
        // FILTER VARIANTS
        // =========================
        for (var variant in variantModel.results!) {
          bool matchWorkshopGroup =
              variant.workshopGroup?.any((x) => x.id == App.workshopGrp) ??
                  false;

          bool matchWorkshop =
              variant.workshop?.any((x) => x.id == App.workshop) ?? false;

          if (matchWorkshopGroup || matchWorkshop) {
            validVariantList.add(variant);
          }
        }

        print("👉 VALID VARIANTS: ${validVariantList.length}");

        variantModel.results = validVariantList;
      }

      // =========================
      // CLOSE LOADER
      // =========================
      if (Get.isDialogOpen == true) Get.back();

      // =========================
      // NAVIGATION
      // =========================
      Get.toNamed(
        Routes.addServiceForm,
        arguments: {
          "sessionList": sessionList,
          "variantModel": variantModel,
        },
      );

      print("✅ NAVIGATION DONE");
    } catch (e) {
      print("❌ CREATE SESSION ERROR: $e");

      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> getSessionList() async {
    print("👉 GET SESSION LIST START");

    try {
      SessionListModel? res;

      bool isOnline = await _checkInternet();

      print("👉 INTERNET STATUS: $isOnline");

      // =========================
      // ONLINE MODE
      // =========================
      if (isOnline) {
        res = await services.getAllSessionList(App.userId);

        print("👉 API RESPONSE MESSAGE: ${res.message}");

        if (res.message != "success") {
          print("⚠️ API FAILED, TRY LOCAL STORAGE");

          final jsonListData =
              await AndroidOperationsService.getData("Session_LocalList");

          if (jsonListData == null || jsonListData.isEmpty) {
            print("❌ NO LOCAL SESSION DATA");
            return;
          }

          res = SessionListModel.fromJson(jsonDecode(jsonListData));
        }
      }

      // =========================
      // OFFLINE MODE
      // =========================
      else {
        print("📴 OFFLINE MODE - loading local data");

        final jsonListData =
            await AndroidOperationsService.getData("Session_LocalList");

        if (jsonListData == null || jsonListData.isEmpty) {
          print("❌ NO LOCAL SESSION DATA");
          return;
        }

        res = SessionListModel.fromJson(jsonDecode(jsonListData));
      }

      // =========================
      // PROCESS RESULT
      // =========================
      if (res.message == "success") {
        if (res.results != null && res.results!.isNotEmpty) {
          sessionList.assignAll(
            res.results!..sort((a, b) => b.id!.compareTo(a.id!)),
          );

          print("✅ SESSION LIST LOADED: ${sessionList.length}");
        } else {
          Get.snackbar("Failed", "Session list not found.");
        }
      } else {
        Get.snackbar("Error", res.message ?? "Unknown error");
      }
    } catch (e) {
      print("❌ GET SESSION LIST ERROR: $e");
      Get.snackbar("Error", e.toString());
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print("❌ Internet check failed: $e");
      return false;
    }
  }

  Future<void> checkOfflineAnalyzeDataAvailable() async {
    print("👉 OFFLINE SYNC STARTED");

    try {
      // LOADER (replace with your UI loader)
      showLoading("Loading...");

      await Future.delayed(const Duration(milliseconds: 10));

      await getSessionList();

      bool isReachable = await isInternetAvailable(); // implement this

      if (isReachable) {
        try {
          // =========================
          // GET LOCAL DATA
          // =========================
          String? createSRJsonData =
              await AndroidOperationsService.getData("OfflineCreate_SR");
          String? readDtcJsonData =
              await AndroidOperationsService.getData("OfflineAnalyze_ReadDtc");
          String? clearDtcJsonData =
              await AndroidOperationsService.getData("OfflineAnalyze_ClearDtc");
          String? pidRecordingJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_PidRecording");
          String? pidSnapshotJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_PidSnapshot");
          String? writeParameterJsonData =
              await AndroidOperationsService.getData(
                  "OfflineAnalyze_WriteParameter");
          String? flashRecordJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_FlashRecord");
          String? ecuReplacementJsonData =
              await AndroidOperationsService.getData(
                  "OfflineAnalyze_PartReplacementEcu");
          String? fipReplacementJsonData =
              await AndroidOperationsService.getData(
                  "OfflineAnalyze_PartReplacementFip");
          String? injectorReplacementJsonData =
              await AndroidOperationsService.getData(
                  "OfflineAnalyze_PartReplacementInjectors");
          String? otherReplacementJsonData =
              await AndroidOperationsService.getData(
                  "OfflineAnalyze_PartReplacementOther");
          String? freezeFrameJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_FreezeFrame");
          String? routineTestJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_RoutineTestRecord");
          String? actuatorTestJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_ActuatorRecord");
          String? engineHrsJsonData = await AndroidOperationsService.getData(
              "OfflineAnalyze_EngineHrs");
          String? locationJsonData =
              await AndroidOperationsService.getData("OfflineAnalyze_Location");
          String? gdJsonData =
              await AndroidOperationsService.getData("OfflineAnalyze_GD");

          // =========================
          // CREATE SESSION
          // =========================
          if (createSRJsonData!.isNotEmpty) {
            List<CreateSessionReqModel> list =
                (jsonDecode(createSRJsonData) as List)
                    .map((e) => CreateSessionReqModel.fromJson(e))
                    .toList();

            for (var item in list) {
              await services.createSession(item);
            }

            var res1 = await services.getAllSessionList(App.userId);

            if (res1.message == "success") {
              await AndroidOperationsService.saveData(
                  "Session_LocalList", jsonEncode(res1));
            }

            await AndroidOperationsService.saveData("OfflineCreate_SR", "");
          }

          // =========================
          // DTC READ
          // =========================
          if (readDtcJsonData!.isNotEmpty) {
            List<ReadDtcOfflineAnalyze> list =
                (jsonDecode(readDtcJsonData) as List)
                    .map((e) => ReadDtcOfflineAnalyze.fromJson(e))
                    .toList();

            for (var item in list) {
              int sessionId = item.srnId ?? 0;

              if (sessionId == 0) {
                var res = await services
                    .getSessionBySrNumber(item.srNumber as GetSrModel);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              if (item.pdr != null) {
                await services.dtcRecord(
                    item.pdr!, App.jwtToken, sessionId, item.datetime!);
              }
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_ReadDtc", "");
          }

          // =========================
          // CLEAR DTC
          // =========================
          if (clearDtcJsonData!.isNotEmpty) {
            List<ReadDtcOfflineAnalyze> list =
                (jsonDecode(clearDtcJsonData) as List)
                    .map((e) => ReadDtcOfflineAnalyze.fromJson(e))
                    .toList();

            for (var item in list) {
              int sessionId = item.srnId ?? 0;

              if (sessionId == 0) {
                var res = await services
                    .getSessionBySrNumber(item.srNumber as GetSrModel);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.clearDtcRecord(
                  item.pdr!.cast<ClearDtcRecord>(), App.jwtToken, sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_ClearDtc", "");
          }

          // =========================
          // PID RECORDING
          // =========================
          if (pidRecordingJsonData!.isNotEmpty) {
            List<PidRecordingOfflineAnalyze> list =
                (jsonDecode(pidRecordingJsonData) as List)
                    .map((e) => PidRecordingOfflineAnalyze.fromJson(e))
                    .toList();

            for (var item in list) {
              int sessionId = item.srnId ?? 0;

              if (sessionId == 0) {
                var res = await services
                    .getSessionBySrNumber(item.srNumber as GetSrModel);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.pidLiveRecord(
                  item.liveRecord!, App.jwtToken, sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_PidRecording", "");
          }

          // =========================
          // PID SNAPSHOT
          // =========================
          if (pidSnapshotJsonData!.isNotEmpty) {
            List<PidSnapshotOfflineAnalyze> list =
                (jsonDecode(pidSnapshotJsonData) as List)
                    .map((e) => PidSnapshotOfflineAnalyze.fromJson(e))
                    .toList();

            for (var item in list) {
              int sessionId = item.srnId ?? 0;

              if (sessionId == 0) {
                var res = await services
                    .getSessionBySrNumber(item.srNumber as GetSrModel);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.pidSnapshotRecord(
                item.snapshot!,
                App.jwtToken,
                sessionId,
                item.datetime!,
              );
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_PidSnapshot", "");
          }

          // =========================
          // WRITE PARAMETER
          // =========================
          if (writeParameterJsonData!.isNotEmpty) {
            List<WriteParameterOfflineAnalyze> list =
                (jsonDecode(writeParameterJsonData) as List)
                    .map((e) => WriteParameterOfflineAnalyze.fromJson(e))
                    .toList();

            for (var item in list) {
              int sessionId = item.srnId ?? 0;

              if (sessionId == 0) {
                var res = await services
                    .getSessionBySrNumber(item.srNumber as GetSrModel);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.pidWriteRecord(
                  item.pidWriteRecord!.cast<PidWriteRecordItem>(),
                  App.jwtToken,
                  sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_WriteParameter", "");
          }

          // =========================
          // FLASH RECORD
          // =========================
          if (flashRecordJsonData!.isNotEmpty) {
            List<FlashOfflineAnalyze> list =
                (jsonDecode(flashRecordJsonData) as List)
                    .map((e) => FlashOfflineAnalyze.fromJson(e))
                    .toList();

            for (var item in list) {
              int sessionId = item.srnId ?? 0;

              if (sessionId == 0) {
                var res = await services
                    .getSessionBySrNumber(item.srNumber as GetSrModel);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.flashRecord(
                  item.flashRecord!, App.jwtToken, sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_FlashRecord", "");
          }

          // =========================
          // PART REPLACEMENTS (same pattern)
          // =========================
          if (ecuReplacementJsonData!.isNotEmpty) {
            List list = jsonDecode(ecuReplacementJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                sessionId = res.results!.first.id ?? 0;
              }

              await services.partReplacementEcu(item["data"], sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_PartReplacementEcu", "");
          }

          if (fipReplacementJsonData!.isNotEmpty) {
            List list = jsonDecode(fipReplacementJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.partReplacementFip(item["data"], sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_PartReplacementFip", "");
          }

          if (injectorReplacementJsonData!.isNotEmpty) {
            List list = jsonDecode(injectorReplacementJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.partReplacementInjectors(item["data"], sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_PartReplacementInjectors", "");
          }

          if (otherReplacementJsonData!.isNotEmpty) {
            List list = jsonDecode(otherReplacementJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.partReplacementOther(item["data"], sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_PartReplacementOther", "");
          }

          if (routineTestJsonData!.isNotEmpty) {
            List list = jsonDecode(routineTestJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.routineTestRecord(
                item["data"],
                App.jwtToken,
                sessionId,
              );
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_RoutineTestRecord", "");
          }

          if (freezeFrameJsonData!.isNotEmpty) {
            List list = jsonDecode(freezeFrameJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.analyzeFreezeFrame(
                  item["freeze_frame"], sessionId);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_FreezeFrame", "");
          }

          if (actuatorTestJsonData!.isNotEmpty) {
            List list = jsonDecode(actuatorTestJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.postActuatorTestResult(
                item["data"],
                sessionId,
              );
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_ActuatorRecord", "");
          }

          if (engineHrsJsonData!.isNotEmpty) {
            List list = jsonDecode(engineHrsJsonData);

            for (var item in list) {
              await services.uploadEngineHrs(item["data"]);
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_EngineHrs", "");
          }
          if (locationJsonData!.isNotEmpty) {
            List list = jsonDecode(locationJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.postApi(
                "/api/v1/analyze/srsession-location/create/",
                jsonEncode(item["data"]),
              );
            }

            await AndroidOperationsService.saveData(
                "OfflineAnalyze_Location", "");
          }
          if (gdJsonData!.isNotEmpty) {
            List list = jsonDecode(gdJsonData);

            for (var item in list) {
              int sessionId = item["srn_id"];

              if (sessionId == 0) {
                var res =
                    await services.getSessionBySrNumber(item["sr_number"]);
                if (res.message == "success") {
                  sessionId = res.results!.first.id ?? 0;
                }
              }

              await services.postGdComment(
                item["data"],
                sessionId,
              );
            }

            await AndroidOperationsService.saveData("OfflineAnalyze_GD", "");
          }

          hideLoading();
        } catch (e) {
          print("SYNC ERROR: $e");
          hideLoading();
        }
      }
    } catch (e) {
      print("OUTER ERROR: $e");
      hideLoading();
    }
  }

  Future<bool> isInternetAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    return connectivityResult != ConnectivityResult.none;
  }

  void showLoading(String msg) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  msg,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
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
}
