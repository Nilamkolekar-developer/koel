import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/variant_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SessionListController extends GetxController {
  final AuthApiService services = AuthApiService();

  // 🔹 Inputs
  bool isOpenSr;

  SessionListController({
    required List<SessionModel> sessionList,
    required this.isOpenSr,
  }) {
    this.sessionList.assignAll(sessionList);
    staticSessionList.assignAll(sessionList);

    if (App.workshopGrp == 6) {
      btnStatus.value = false;
    } else if (sessionList.isNotEmpty &&
        sessionList.first.status == "open") {
      btnStatus.value = true;
    } else {
      btnStatus.value = false;
    }
  }

  // -------------------------------
  // 🔹 State
  // -------------------------------

  var sessionList = <SessionModel>[].obs;
  var staticSessionList = <SessionModel>[].obs;

  var searchText = ''.obs;
  var btnStatus = false.obs;

  // -------------------------------
  // 🔹 Actions
  // -------------------------------

  Future<void> selectSession(SessionModel item) async {
    if (!isOpenSr) return;

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final jsonData = await AndroidOperationsService.getData("MODEL_LocalList");
      if (jsonData!.isEmpty) {
        Get.snackbar("Failed", "Model not found in local database");
        Get.back();
        return;
      }

      final models = AllModelsModel.fromJson(json.decode(jsonData));

      if (models.results!.isEmpty) {
        Get.snackbar("Failed", "Model not found");
        Get.back();
        return;
      }

      StaticData.ecuInfo = [];

      final model = models.results!.firstWhereOrNull(
          (x) => x.id == item.variant!.modelId);

      if (model == null) {
        Get.snackbar("Failed", "Model not found");
        Get.back();
        return;
      }

      App.modelId = item.variant!.modelId!;

      final subModel = model.subModels!.firstWhereOrNull(
          (x) => x.id == item.variant!.sModelId);

      if (subModel == null) {
        Get.snackbar("Failed", "Sub model not found");
        Get.back();
        return;
      }

      App.subModelId = item.variant!.sModelId!;

//       for (var variantEcu in item.variant?.subModel?.ecus ?? []) {
//   final ecu = subModel.ecus
//       ?.firstWhereOrNull((x) => x.id == variantEcu.id);

//   if (ecu != null) {
//     final pidLocal = await AndroidOperationsService
//         .getData("PidDataset_${ecu.pidDatasets?[0].id}");

//     final pidDataset = (pidLocal != null && pidLocal.isNotEmpty)
//         ? Root.fromJson(json.decode(pidLocal))
//         : Root();

//     StaticData.ecuInfo.add(EcuDataSet(
//       readDtcIndex: ecu.read_dtc_fn_index.value,
//       pidDatasetId: ecu.pidDatasets?[0].id,
//       mappedPidDatasetId:
//           ecu.mapped_pid_datasets?.firstOrNull?.id,
//       clearDtcIndex: ecu.clear_dtc_fn_index.value,
//       dtcDatasetId: ecu.datasets?[0].id,
//       ecuName: ecu.name,
//       seedKeyIndex: ecu.seedkeyalgo_fn_index.value,
//       writePidIndex: ecu.write_data_fn_index.value,
//       txHeader: ecu.tx_header,
//       rxHeader: ecu.rx_header,
//       protocol: ecu.protocol,
//       ecuId: ecu.id,
//       iorTestFnIndex: ecu.ior_test_fn_index.value,
//       versionDataset: ecu.version_dataset,
//       swVerPid: ecu.sw_ver_pid,
//       pidList: pidDataset.results?.firstOrNull?.codes,
//     ));
//   }
// }


      Get.back(); // close loader

      // Get.toNamed(
      //   Routes.connection,
      //   arguments: {"item": item, "model": model},
      // );
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  // -------------------------------
  // 🔹 Close Session
  // -------------------------------

  Future<void> closeSession(SessionModel item) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Alert"),
        content: const Text("Do you want to close this SR Session?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
          TextButton(onPressed: () => Get.back(result: true), child: const Text("OK")),
        ],
      ),
    );

    if (confirm != true) return;

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final result = await services.closeSession(
        item.id??0,
        CloseSession(status: "closed"),
      );

      if (result.message == "success" &&
          result.status == "closed") {
        Get.snackbar("Success", "Session closed");

        final res = await services.getAllSessionList(App.userId);

        if (res.message == "success" && res.results!.isNotEmpty) {
          sessionList.assignAll(
              res.results!..sort((a, b) => b.id!.compareTo(a.id!)));

          staticSessionList.assignAll(sessionList);

          await AndroidOperationsService. saveData("Session_LocalList", json.encode(res));
        } else {
          Get.snackbar("Failed", "Session list not found");
        }
      } else {
        Get.snackbar("Error", result.message ?? "Session not closed");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }

    Get.back();
  }

  // -------------------------------
  // 🔹 Create Session
  // -------------------------------

  Future<void> createNewSession() async {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      final jsonData = await AndroidOperationsService. getData("Variant_LocalList");

      if (jsonData!.isEmpty) {
        Get.snackbar("Error", "Variants not found. Update local data.");
        Get.back();
        return;
      }

      final variantModel =
          VariantModel.fromJson(json.decode(jsonData));

      if (variantModel.results!.isEmpty) {
        Get.snackbar("Error", "Variants not found");
      } else {
        final validList = variantModel.results!.where((v) {
          return (v.workshopGroup
                      ?.any((x) => x.id == App.workshopGrp) ??
                  false) ||
              (v.workshop?.any((x) => x.id == App.workshop) ??
                  false);
        }).toList();

        variantModel.results = validList;
      }

      Get.back();

      Get.toNamed(
        Routes.SessionScreen,
        arguments: {
          "sessionList": sessionList,
          "variantModel": variantModel,
        },
      );
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  // -------------------------------
  // 🔹 Load Session List
  // -------------------------------

  Future<void> getSessionList() async {
    try {
      final jsonData = await AndroidOperationsService. getData("Session_LocalList");

      if (jsonData!.isEmpty) return;

      final res =
          SessionListModel.fromJson(json.decode(jsonData));

      if (res.message == "success" && res.results!.isNotEmpty) {
        sessionList.assignAll(
            res.results!..sort((a, b) => b.id!.compareTo(a.id!)));

        staticSessionList.assignAll(sessionList);
      } else {
        Get.snackbar("Failed", "Session list not found");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // -------------------------------
  // 🔹 Search
  // -------------------------------

  void searchSession(String value) {
    searchText.value = value;

    if (value.isEmpty) {
      sessionList.assignAll(staticSessionList);
    } else {
      sessionList.assignAll(staticSessionList.where((s) =>
          s.srNumber!.toLowerCase().contains(value.toLowerCase())));
    }
  }
}
