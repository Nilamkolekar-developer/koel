import 'dart:convert';

import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/koel_LocalDataFlash_model.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/pidByAddrReqLocal_model.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataSyncController extends GetxController {
  var isLoading = false.obs;
  final AuthApiService services = AuthApiService();

  Future<void> btnDataSyncClicked(BuildContext context) async {
    isLoading.value = true;

    print("👉 Data Sync STARTED");

    bool isLoaderOpen = false;

    try {
      print("👉 Showing LOADING dialog");

      final loader = CommonLoader(message: "Updating Local Data...");

      Get.dialog(loader, barrierDismissible: false);
      isLoaderOpen = true;

      await Future.delayed(const Duration(milliseconds: 200));

      print("👉 Calling updateModelToLocal()");
      bool result = await updateModelToLocal();

      print("👉 updateModelToLocal RESULT: $result");

      // ✅ SAFE CLOSE LOADER
      if (isLoaderOpen) {
        Get.back();
        isLoaderOpen = false;
        print("👉 Loading dialog closed");
      }

      // ✅ RESULT POPUP
      Get.dialog(
        CustomPopup(
          title: result ? "Success" : "Error",
          message: result
              ? "Local data updated successfully."
              : "Local data not updated.",
          onButtonPressed: () {
            Get.back(); // close popup

            if (result) {
              Get.back(); // close page/drawer
            }
          },
        ),
        barrierDismissible: false,
      );

      print(result ? "✅ SYNC SUCCESS" : "❌ SYNC FAILED");
    } catch (e) {
      print("❌ EXCEPTION in Data Sync: $e");

      // ✅ SAFE CLOSE LOADER
      if (isLoaderOpen) {
        Get.back();
        isLoaderOpen = false;
      }

      Get.dialog(
        CustomPopup(
          title: "Error",
          message: e.toString(),
          onButtonPressed: () {
            Get.back();
          },
        ),
        barrierDismissible: false,
      );
    } finally {
      isLoading.value = false;
      print("👉 Data Sync FINISHED");
    }
  }

  Future<bool> updateModelToLocal() async {
    bool returnValue = false;

    try {
      /// -------------------------------
      /// STEP 1: Clear / Save old local data
      /// -------------------------------
      await AndroidOperationsService.saveData("Parameter_LocalList");
      await AndroidOperationsService.saveData("MODEL_LocalList");
      await AndroidOperationsService.saveData("KOEL_LocalList");
      await AndroidOperationsService.saveData("PidByAddrSeqData");
      await AndroidOperationsService.saveData("Session_LocalList");
      await AndroidOperationsService.saveData("Variant_LocalList");
      await AndroidOperationsService.saveData("FreezeFrame_LocalList");
      await AndroidOperationsService.saveData("IOR_LocalList");
      await AndroidOperationsService.saveData("Parameter_LocalList");

      /// -------------------------------
      /// STEP 2: API CALL
      /// -------------------------------
      final resp = await services.getApiResponse(
        "/api/v1/models/get-models/?oem=${App.oemId}",
      );

      if (resp.success == true) {
        final result = AllModelsModel.fromJson(
          jsonDecode(resp.data ?? ''),
        );

        returnValue = true;

        await AndroidOperationsService.saveData(
          "MODEL_LocalList",
          resp.data ?? '',
        );

        /// -------------------------------
        /// STEP 3: Sequential Sync Chain
        /// -------------------------------
        if (returnValue) {
          returnValue = await downloadPidDtcToLocal(result.results);
        }

        if (returnValue) {
          returnValue = await downloadMappedPidToLocal();
        }

        if (returnValue) {
          returnValue = await downloadSequenceFileToLocal(result.results);
        }

        if (returnValue) {
          returnValue =
              await downloadPidByAddrSequenceFileToLocal(result.results);
        }

        if (returnValue) {
          returnValue = await updateSessionListToLocal();
        }

        if (returnValue) {
          returnValue = await updateIorListToLocal();
        }

        if (returnValue) {
          returnValue = await updateActuatorListToLocal();
        }

        if (returnValue) {
          returnValue = await updateFreezeFrameListToLocal();
        }

        if (returnValue) {
          returnValue = await updateEnvSetListToLocal(result.results);
        }

        if (returnValue) {
          returnValue = await updateVariantListToLocal();
        }

        if (returnValue) {
          returnValue = await getTicketList(App.userId);
        }

        if (returnValue) {
          returnValue = await updateParameterListToLocal();
        }
      } else {
        Get.snackbar(
          "Error in Saving Models List",
          resp.data.toString(),
        );
        returnValue = false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateModelToLocal()",
        ex.toString(),
      );
      returnValue = false;
    }

    return returnValue;
  }

  Future<bool> downloadPidDtcToLocal(List<ModelResult>? models) async {
    try {
      bool result = false;

      List<Dataset> dtcDatasetList = [];
      List<PidDataset> pidDatasetList = [];

      if (models != null) {
        for (var model in models) {
          if (model.subModels != null) {
            for (var subModel in model.subModels!) {
              if (subModel.ecus != null) {
                for (var ecu in subModel.ecus!) {
                  /// ---------------- DTC DATASETS ----------------
                  if (ecu.datasets != null) {
                    for (var dtcDataset in ecu.datasets!) {
                      dtcDatasetList.add(dtcDataset);
                    }
                  }

                  /// ---------------- VERSION DATASETS ----------------
                  if (ecu.versionDataset != null) {
                    for (var versionDataset in ecu.versionDataset!) {
                      dtcDatasetList.add(
                        Dataset(id: versionDataset.dataset),
                      );
                    }
                  }

                  /// ---------------- PID DATASETS ----------------
                  if (ecu.pidDatasets != null) {
                    for (var pidDataset in ecu.pidDatasets!) {
                      pidDatasetList.add(pidDataset);
                    }
                  }
                }
              }
            }
          }
        }
      }

      /// ---------------- DOWNLOAD CHAIN ----------------
      result = await downloadPidToLocal(pidDatasetList);

      if (result) {
        result = await downloadDtcToLocal(dtcDatasetList);
      }

      return result;
    } catch (ex) {
      Get.snackbar(
        "Exception in DownloadPidDtcToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> downloadPidToLocal(List<PidDataset>? pidDatasets) async {
    bool returnValue = false;

    try {
      if (pidDatasets != null && pidDatasets.isNotEmpty) {
        /// -------------------------------
        /// GROUP BY ID (same as C# GroupBy)
        /// -------------------------------
        final Map<dynamic, List<PidDataset>> grouped = {};

        for (var item in pidDatasets) {
          final key = item.id;

          if (!grouped.containsKey(key)) {
            grouped[key] = [];
          }
          grouped[key]!.add(item);
        }

        /// -------------------------------
        /// LOOP GROUPS
        /// -------------------------------
        for (var entry in grouped.entries) {
          final key = entry.key;

          final resp = await services.getApiResponse(
            "/api/v1/datasets/get-pid-datasets/?id=$key",
          );

          if (resp.success == true) {
            await AndroidOperationsService.saveData(
              "PidDataset_$key",
              resp.data ?? '',
            );

            returnValue = true;
          } else {
            Get.snackbar(
              "Error in Saving PID Data",
              resp.data.toString(),
            );

            return false;
          }
        }
      }

      return returnValue;
    } catch (ex) {
      Get.snackbar(
        "Exception in DownloadPidToLocal()",
        ex.toString(),
      );

      return false;
    }
  }

  Future<bool> downloadDtcToLocal(List<Dataset>? datasets) async {
    bool returnValue = false;

    try {
      if (datasets != null && datasets.isNotEmpty) {
        /// -------------------------------
        /// GROUP BY ID (same as C# GroupBy)
        /// -------------------------------
        final Map<dynamic, List<Dataset>> grouped = {};

        for (var item in datasets) {
          final key = item.id;

          if (!grouped.containsKey(key)) {
            grouped[key] = [];
          }
          grouped[key]!.add(item);
        }

        /// -------------------------------
        /// API CALL FOR EACH GROUP
        /// -------------------------------
        for (var entry in grouped.entries) {
          final key = entry.key;

          final resp = await services.getApiResponse(
            "/api/v1/datasets/get-dtc-datasets/?id=$key",
          );

          if (resp.success == true) {
            await AndroidOperationsService.saveData(
              "DtcDataset_$key",
              resp.data ?? '',
            );

            returnValue = true;
          } else {
            Get.snackbar(
              "Error in Saving DTC Data",
              resp.data.toString(),
            );

            return false;
          }
        }
      }

      return returnValue;
    } catch (ex) {
      Get.snackbar(
        "Exception in DownloadDtcToLocal()",
        ex.toString(),
      );

      return false;
    }
  }

  Future<bool> downloadMappedPidToLocal() async {
    try {
      final mappedPidResponse = await services.getApiResponse(
        "/api/v1/datasets/get-mapped-pid-datasets/",
      );

      if (mappedPidResponse.success == true) {
        await AndroidOperationsService.saveData(
          "MappedPidDataset",
          mappedPidResponse.data ?? '',
        );

        return true;
      } else {
        Get.snackbar(
          "Error in Saving Mapped PID Data",
          mappedPidResponse.data.toString(),
        );

        return false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in DownloadMappedPidToLocal()",
        ex.toString(),
      );

      return false;
    }
  }

  Future<bool> downloadSequenceFileToLocal(List<ModelResult>? models) async {
    try {
      bool returnValue = false;
      List<RootKoelocalModel> rootKoelocalModelList = [];

      if (models != null && models.isNotEmpty) {
        for (var model in models) {
          RootKoelocalModel rootKoelocalModel = RootKoelocalModel();

          rootKoelocalModel.modelDetail = LocalModel(
            modelName: model.modelName,
            modelId: model.id,
            oemId: model.oem,
            subModelList: [],
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
                      Ecu2LocalModel ecu2LocalModel = Ecu2LocalModel(
                        sequenceId: ecu2.id,
                        sequenceFileName: ecu2.sequenceFileName,
                        sequenceUrl: ecu2.sequenceFile,
                        sequenceLocalFile: await services.readJsonFile(
                          ecu2.sequenceFile ?? '',
                        ),
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

      // Save to local storage
      final koelLocalListJson = jsonEncode(
        rootKoelocalModelList.map((e) => e.toJson()).toList(),
      );

      await AndroidOperationsService.saveData(
        "KOEL_LocalList",
        koelLocalListJson,
      );

      returnValue = true;
      return returnValue;
    } catch (ex) {
      Get.snackbar(
        "Exception in DownloadSequenceFileToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> downloadPidByAddrSequenceFileToLocal(
    List<ModelResult>? models,
  ) async {
    try {
      bool returnValue = false;
      List<PidByAddrSeqLocalModel> pidByAddrSeqList = [];

      if (models != null && models.isNotEmpty) {
        for (var model in models) {
          if (model.subModels != null && model.subModels!.isNotEmpty) {
            for (var subModel in model.subModels!) {
              if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                for (var ecu in subModel.ecus!) {
                  PidByAddrSeqLocalModel pidByAddrSeqLocalModel =
                      PidByAddrSeqLocalModel();

                  pidByAddrSeqLocalModel.ecuId = ecu.id;

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

      final pidByAddrSeqData = jsonEncode(
        pidByAddrSeqList.map((e) => e.toJson()).toList(),
      );

      await AndroidOperationsService.saveData(
        "PidByAddrSeqData",
        pidByAddrSeqData,
      );

      returnValue = true;
      return returnValue;
    } catch (ex) {
      Get.snackbar(
        "Exception in DownloadPidByAddrSequenceFileToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> updateSessionListToLocal() async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/analyze/srsession-list/?created_by=${App.userId}",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
          "Session_LocalList",
          resp.data.toString(),
        );
        return true;
      } else {
        Get.snackbar(
          "Alert!",
          resp.data.toString(),
        );
        return false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateSessionListToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> updateFreezeFrameListToLocal() async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/datasets/get-freeze-frames/",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
          "FreezeFrame_LocalList",
          resp.data.toString(),
        );
        return true;
      } else {
        Get.snackbar(
          "Error in Saving Freeze Frame List",
          resp.data.toString(),
        );
        return false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateFreezeFrameListToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> updateEnvSetListToLocal(List<ModelResult>? models) async {
    try {
      bool returnValue = false;

      if (models != null && models.isNotEmpty) {
        for (var model in models) {
          if (model.subModels != null && model.subModels!.isNotEmpty) {
            for (var subModel in model.subModels!) {
              if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                for (var ecu in subModel.ecus!) {
                  final resp = await services.getApiResponse(
                    "/api/v1/datasets/get-environment-snapshot/?ecu=${ecu.id}",
                  );

                  if (resp.success == true) {
                    await AndroidOperationsService.saveData(
                      "EnvSet_LocalList_forEcu_${ecu.id}",
                      resp.data.toString(),
                    );

                    returnValue = true;
                  } else {
                    Get.snackbar(
                      "Error in Saving Environment Snapshot",
                      resp.data.toString(),
                    );
                    return false;
                  }
                }
              }
            }
          }
        }
      }

      return returnValue;
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateEnvSetListToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> updateVariantListToLocal() async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/variant/list/?oem=${App.oemId}",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
          "Variant_LocalList",
          resp.data.toString(),
        );
        return true;
      } else {
        Get.snackbar(
          "Error in Saving Variant List",
          resp.data.toString(),
        );
        return false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateVariantListToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> updateIorListToLocal() async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/ior-test/ior-test-list/",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
          "IOR_LocalList",
          resp.data.toString(),
        );
        return true;
      } else {
        Get.snackbar(
          "Error in Saving Routine List",
          resp.data.toString(),
        );
        return false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateIorListToLocal()",
        ex.toString(),
      );
      return false;
    }
  }

  Future<bool> updateActuatorListToLocal() async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/ior-test/actuator-test-list/",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
          "Actuator_LocalList",
          resp.data.toString(),
        );
        return true;
      } else {
        Get.snackbar(
          "Error in Saving Actuator List",
          resp.data.toString(),
        );
        return false;
      }
    } catch (ex) {
      Get.snackbar(
        "Exception in UpdateActuatorListToLocal()",
        ex.toString(),
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
          "GetTicketList",
          resp.data ?? '',
        );
        return true;
      } else {
        Get.snackbar(
          "Error in Saving Ticket List",
          resp.data.toString(),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Exception in GetTicketList()",
        e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateParameterListToLocal() async {
    try {
      final resp = await services.getApiResponse(
        "/api/v1/parameter/list/",
      );

      if (resp.success == true) {
        await AndroidOperationsService.saveData(
          "Parameter_LocalList",
          resp.data ?? '',
        );

        // Save last update date (like Preferences in Xamarin)
        final date = DateTime.now();
        await AppPreferences.setString(
          "last_update",
          "${date.day.toString().padLeft(2, '0')}-"
              "${date.month.toString().padLeft(2, '0')}-"
              "${date.year}",
        );

        return true;
      } else {
        Get.snackbar(
          "Error in Saving Parameter List",
          resp.data.toString(),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Exception in UpdateParameterListToLocal()",
        e.toString(),
      );
      return false;
    }
  }
}
