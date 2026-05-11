import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/services/api_services.dart';

class ServiceRequestListController extends GetxController {
  final AuthApiService services = AuthApiService();

  /// =====================
  /// OBSERVABLES
  /// =====================
  RxList<SessionModel> sessionList = <SessionModel>[].obs;
  RxList<SessionModel> staticSessionList = <SessionModel>[].obs;

  var filteredRequests = <SessionModel>[].obs;
  var searchQuery = "".obs;
  RxString searchText = ''.obs;
  RxBool btnStatus = false.obs;

  bool isOpenSr = true;

  /// =====================
  /// INIT
  /// =====================
  @override
  void onInit() {
    super.onInit();
    // ✅ Get the list passed from Myesncontroller
    if (Get.arguments != null && Get.arguments['sessionList'] != null) {
      sessionList.assignAll(Get.arguments['sessionList']);
      filteredRequests.assignAll(sessionList);
    }

    // Setup search listener
    ever(searchQuery, (query) {
      searchSession(query);
    });
  }

  /// =====================
  /// LOAD SESSION LIST
  /// =====================
  Future<void> getSessionList() async {
    try {
      String? jsonData =
          await AndroidOperationsService.getData("Session_LocalList");

      if (jsonData == null || jsonData.isEmpty) return;

      final res = SessionListModel.fromJson(jsonDecode(jsonData));

      if (res.message == "success" && res.results.isNotEmpty) {
        staticSessionList.value = res.results;
        sessionList.value = res.results..sort((a, b) => b.id!.compareTo(a.id!));
      }
    } catch (e) {
      debugPrint("Session list error: $e");
    }
  }

  /// =====================
  /// SEARCH
  /// =====================
  void searchSession(String value) {
    searchText.value = value;

    if (value.isEmpty) {
      sessionList.value = List.from(staticSessionList);
    } else {
      sessionList.value = staticSessionList
          .where((s) =>
              (s.srNumber ?? "").toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
  }

  /// =====================
  /// OPEN SESSION
  /// =====================
  Future<void> selectSession(SessionModel item) async {
    if (!isOpenSr) return;

    try {
      showLoading("Loading...");

      await Future.delayed(const Duration(milliseconds: 10));

      final jsonListData =
          await AndroidOperationsService.getData("MODEL_LocalList");

      if (jsonListData == null || jsonListData.isEmpty) {
        await alertMessage("Model not found in local database.", "Failed");
        return;
      }

      final AllModelsModel models =
          AllModelsModel.fromJson(jsonDecode(jsonListData));

      if (models.results == null || models.results!.isEmpty) {
        await alertMessage("Model not found in local database.", "Failed");
        return;
      }

      StaticData.ecuInfo = [];

      final model = models.results!.firstWhere(
        (x) => x.id == item.variant?.modelId,
        orElse: () => models.results!.first,
      );

      App.modelId = item.variant?.modelId ?? 0;

      final subModel = model.subModels?.firstWhere(
        (x) => x.id == item.variant?.sModelId,
        orElse: () => model.subModels!.first,
      );

      if (subModel == null) {
        await alertMessage("Sub model not found.", "Failed");
        return;
      }

      App.subModelId = item.variant?.sModelId ?? 0;

      for (var variantEcu in item.variant?.subModel?.ecus ?? []) {
        // final ecu = subModel.ecus?.firstWhere(
        //   (x) => x.id == variantEcu.id,
        //   orElse: () => variantEcu,
        // );
        final ecu = subModel.ecus?.firstWhereOrNull(
  (x) => x.id == variantEcu.id,
);

        if (ecu != null) {
          final pidLocal = await AndroidOperationsService.getData(
            "PidDataset_${ecu.pidDatasets?.first.id}",
          );

          final pidDataset = (pidLocal != null && pidLocal.isNotEmpty)
              ? Root.fromJson(jsonDecode(pidLocal))
              : null;

          StaticData.ecuInfo.add(
            EcuDataSet(
              readDtcIndex: ecu.readDtcFnIndex?.value,
              pidDatasetId: ecu.pidDatasets?.first.id,
              mappedPidDatasetId: ecu.mappedPidDatasets?.isNotEmpty == true
                  ? ecu.mappedPidDatasets!.first.id
                  : null,
              clearDtcIndex: ecu.clearDtcFnIndex?.value,
              dtcDatasetId: ecu.datasets?.first.id,
              ecuName: ecu.name,
              seedKeyIndex: ecu.seedkeyalgoFnIndex?.value,
              writePidIndex: ecu.writeDataFnIndex?.value,
              txHeader: ecu.txHeader,
              rxHeader: ecu.rxHeader,
              protocol: ecu.protocol,
              ecuId: ecu.id,
              iorTestFnIndex: ecu.iorTestFnIndex?.value,
              versionDataset: ecu.versionDataset,
              swVerPid: ecu.swVerPid,
              pidList: pidDataset?.results?.firstOrNull?.codes,
            ),
          );
        }
      }

      hideLoading();

      Get.toNamed(Routes.ConnectionPage, arguments: {"session": item, "model": model});
    } catch (e) {
      hideLoading();
      await alertMessage(e.toString(), "Failed");
    }
  }

  Future<void> alertMessage(String message, [String title = "Alert"]) async {
    Get.defaultDialog(
      title: title,
      middleText: message,
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }

  void showLoading([String msg = "Loading..."]) {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// =====================
  /// CLOSE SESSION
  /// =====================
  Future<void> closeSessionCommand(SessionModel item) async {
    try {
      // show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // confirm dialog (like UserDialogs.ConfirmAsync)
      final bool? confirm = await Get.defaultDialog<bool>(
        title: "Alert",
        middleText: "Do you want to close this SR Session?",
        textConfirm: "OK",
        textCancel: "Cancel",
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );

      if (confirm != true) {
        Get.back(); // close loader
        return;
      }

      // API call
      final result = await services.closeSession(
        item.id!,
        CloseSessionRequest(status: "closed"),
      );

      if (result.message == "success") {
        if (result.status == "closed") {
          Get.back(); // close loader

          Get.snackbar("Success", "Session closed.");

          // refresh list
          final res = await services.getAllSessionList(App.userId);

          if (res.message == "success") {
            if (res.results.isNotEmpty) {
              final jsonData = jsonEncode(res.toJson());
              await AndroidOperationsService.saveData(
                  "Session_LocalList", jsonData);

              sessionList.value = res.results;
              staticSessionList.value = res.results;
            } else {
              Get.snackbar("Failed", "Session list not found.");
            }
          } else {
            Get.snackbar("Error", res.message ?? "Unknown error");
          }
        } else {
          Get.snackbar("Error", "Session not closed");
        }
      } else {
        Get.snackbar("Error", result.message ?? "Unknown error");
      }

      Get.back(); // close loader if still open
    } catch (ex) {
      Get.back(); // close loader
      Get.snackbar("Failed", ex.toString());
    }
  }

  /// =====================
  /// CREATE SESSION NAVIGATION
  /// =====================
  Future<void> createNewSession() async {
    try {
      final jsonData =
          await AndroidOperationsService.getData("Variant_LocalList");

      if (jsonData == null || jsonData.isEmpty) {
        Get.snackbar("Error", "Variants not found");
        return;
      }

      final variantModel = jsonDecode(jsonData);

      Get.toNamed(Routes.addServiceForm, arguments: {
        "sessionList": sessionList,
        "variant": variantModel,
      });
    } catch (e) {
      debugPrint("Create session error: $e");
    }
  }
}
