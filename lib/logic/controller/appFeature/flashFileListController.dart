import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashListController extends GetxController {
  // ── State ─────────────────────────────────────────────────────────────────
  var sessionModel = Rxn<SessionModel>();
  ModelResult? vehicleModels;

  // ── Observables ───────────────────────────────────────────────────────────
  var ecusList = <FlashEcusModel>[].obs;
  var flashFileList = <LocalVariantEcuEcu>[].obs;
  var staticFlashFileList = <LocalVariantEcuEcu>[].obs;
  var selectedEcu = Rxn<FlashEcusModel>();
  var selectedFlashFile = Rxn<LocalVariantEcuEcu>();
  var searchKey = "".obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args == null) {
      print("⚠️ WriteParameterController: No arguments received");
      return;
    }

    try {
      sessionModel.value = args['sessionModel'] as SessionModel?;
      vehicleModels = args['vehicleModels'] as ModelResult?;

      print("✅ sessionModel: ${sessionModel.value?.id}");
      print("✅ vehicleModels: ${vehicleModels?.id}");

      if (sessionModel.value == null || vehicleModels == null) {
        print("⚠️ Required data missing");
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        getFlashFileList();
      });
      // React to search key changes
      debounce(searchKey, (_) => searchFile(),
          time: const Duration(milliseconds: 300));
    } catch (e) {
      print("🔥 WriteParameterController onInit error: $e");
    }
  }

 Future<void> getFlashFileList() async {
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    await Future.delayed(const Duration(milliseconds: 50));
    ecusList.clear();
    int count = 0;

    print("📋 StaticData.ecuInfo count: ${StaticData.ecuInfo.length}");
    print("📋 vehicleModels.subModels: ${vehicleModels?.subModels?.length}");
    print("📋 sessionModel.variant: ${sessionModel.value?.variant}");
    print("📋 variantEcu count: ${sessionModel.value?.variant?.variantEcu?.length}");

    for (var ecu in StaticData.ecuInfo) {
      count++;
      Ecu? ecu1;

      if (vehicleModels?.subModels?.isNotEmpty == true) {
        final subModel = vehicleModels!.subModels
            ?.firstWhereOrNull((x) => x.id == App.subModelId);

        print("🔍 subModel found: ${subModel?.id} for App.subModelId: ${App.subModelId}");

        if (subModel?.ecus?.isNotEmpty == true) {
          // C# matches by name — confirm your field is also 'name' not 'ecuName'
          ecu1 = subModel!.ecus!
              .firstWhereOrNull((x) => x.name == ecu.ecuName);
          print("🔍 ecu1 match for '${ecu.ecuName}': ${ecu1?.name}");
        }
      }

      if (ecu1 != null) {
        final flashEcusModel = FlashEcusModel(
          ecuName: ecu.ecuName,
          id: ecu.ecuId,
          opacity: count == 1 ? 1.0 : 0.5,
          seedkeyalgoFnIndexValues: ecu1.seedkeyalgoFnIndex,
          ecu1: ecu1,
        );

        // Match session variant ECUs
        if (sessionModel.value?.variant?.variantEcu?.isNotEmpty == true) {
          final sessionEcu = sessionModel.value!.variant!.variantEcu!
              .where((x) => x.ecu?.id == ecu.ecuId)
              .toList();

          print("📦 sessionEcu for ecuId ${ecu.ecuId}: ${sessionEcu.length} items");
          flashEcusModel.flashFileLocalList = sessionEcu;
        } else {
          print("⚠️ variantEcu is empty or null for ecu: ${ecu.ecuName}");
        }

        // Set ECU map file and ecu2
        if (ecu1.ecu?.isNotEmpty == true) {
          flashEcusModel.ecuMapFile = ecu1.ecu!.first.ecuMapFile;
          flashEcusModel.ecu2 = ecu1.ecu!.first;
        }

        ecusList.add(flashEcusModel);
        print("✅ Added to ecusList: ${flashEcusModel.ecuName}, files: ${flashEcusModel.flashFileLocalList?.length}");
      } else {
        print("⚠️ ecu1 is null for ecu: ${ecu.ecuName} — skipped");
      }
    }

    print("📋 ecusList final count: ${ecusList.length}");

    if (ecusList.isNotEmpty) {
      selectedEcu.value = ecusList.first;
      print("✅ selectedEcu: ${selectedEcu.value?.ecuName}, flashFileLocalList: ${selectedEcu.value?.flashFileLocalList?.length}");
      await checkLocalDatafile();
    } else {
      print("⚠️ ecusList is empty — nothing to show");
    }
  } catch (e) {
    print("❌ getFlashFileList error: $e");
    Get.defaultDialog(title: "Error", middleText: e.toString());
  } finally {
    if (Get.isDialogOpen == true) Get.back();
  }
}
  // ── 2. CHECK LOCAL DATA FILE ──────────────────────────────────────────────
  Future<void> checkLocalDatafile() async {
    try {
      final jsonListData =
          await AndroidOperationsService.getData("Dataset_LocalList");

      List<LocalVariantEcuEcu> dummyList = [];
      final flashLocalList = selectedEcu.value?.flashFileLocalList ?? [];

      if (jsonListData != null && jsonListData.isNotEmpty) {
        List<VariantEcu> dataFileList = [];
        try {
          dataFileList = (jsonDecode(jsonListData) as List)
              .map((e) => VariantEcu.fromJson(e))
              .toList();
        } catch (_) {}

        if (dataFileList.isNotEmpty) {
          for (var item in flashLocalList) {
            final isExist = dataFileList.firstWhereOrNull((x) =>
                x.ecuId == selectedEcu.value?.id &&
                x.productionSwId?.id == item.productionSwId?.id &&
                (x.productionSwId?.dataFileLocal?.isNotEmpty == true));

            if (isExist != null) {
              // File already downloaded — green
              dummyList.add(LocalVariantEcuEcu(
                backgroundColor: const Color(0xFF309F93),
                productionSwId: item.productionSwId,
                ecuId: selectedEcu.value?.id,
                ecuName: selectedEcu.value?.ecuName,
                isActive: item.isActive,
                isLatest: item.isLatest,
                isEnable: false,
                imgDownload: "ic_charge.png",
                localDatasetFile: isExist.productionSwId?.dataFileLocal,
              ));
            } else {
              // Not downloaded — white
              dummyList.add(LocalVariantEcuEcu(
                backgroundColor: Colors.white,
                productionSwId: item.productionSwId,
                ecuId: selectedEcu.value?.id,
                ecuName: selectedEcu.value?.ecuName,
                isActive: item.isActive,
                isLatest: item.isLatest,
                isEnable: true,
                imgDownload: "ic_download.png",
                localDatasetFile: "",
              ));
            }
          }
        } else {
          // DataFileList empty — all need download
          dummyList = _buildAllDownloadList(flashLocalList);
        }
      } else {
        // No local data at all — all need download
        dummyList = _buildAllDownloadList(flashLocalList);
      }

      staticFlashFileList.value = flashFileList.value = dummyList;
    } catch (e) {
      print("checkLocalDatafile error: $e");
    }
  }

  List<LocalVariantEcuEcu> _buildAllDownloadList(List<dynamic> flashLocalList) {
    return flashLocalList
        .map((item) => LocalVariantEcuEcu(
              backgroundColor: Colors.white,
              productionSwId: item.productionSwId,
              ecuId: selectedEcu.value?.id,
              ecuName: selectedEcu.value?.ecuName,
              isActive: item.isActive,
              isLatest: item.isLatest,
              isEnable: true,
              imgDownload: "ic_download.png",
              localDatasetFile: "",
            ))
        .toList();
  }

  // ── 3. SWITCH TAB ─────────────────────────────────────────────────────────
  Future<void> switchTab(FlashEcusModel tappedEcu) async {
    if (ecusList.length <= 1) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      selectedEcu.value = tappedEcu;
      selectedEcu.value!.opacity = 1.0;

      for (var ecu in ecusList) {
        if (ecu.ecuName != tappedEcu.ecuName) {
          ecu.opacity = 0.5;
        }
      }

      flashFileList.clear();
      ecusList.refresh();
      checkLocalDatafile();
    } catch (e) {
      print("switchTab error: $e");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 4. DATASET SELECT ─────────────────────────────────────────────────────
  Future<void> datasetSelectClicked(LocalVariantEcuEcu file) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await Future.delayed(const Duration(milliseconds: 50));
      selectedFlashFile.value = file;

      if (selectedFlashFile.value != null) {
        await setDongleProperties();
        if (Get.isDialogOpen == true) Get.back();

        Get.toNamed(Routes.flashEcuPage, arguments: {
          'sessionModel': sessionModel.value,
          'selectedFlashFile': selectedFlashFile.value,
          'selectedEcu': selectedEcu.value,
        });
      }
    } catch (e) {
      print("datasetSelectClicked error: $e");
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 5. DATASET INFO TOGGLE ────────────────────────────────────────────────
  void datasetInfoClicked(LocalVariantEcuEcu file) {
    file.isDescVisible = !(file.isDescVisible ?? false);
    flashFileList.refresh();
  }

  // ── 6. SET DONGLE PROPERTIES ──────────────────────────────────────────────
  Future<void> setDongleProperties() async {
    try {
      final protocol = selectedEcu.value?.ecu1?.protocol?.autopeepal ?? "";
      final txHeader = selectedEcu.value?.ecu1?.txHeader ?? "";
      final rxHeader = selectedEcu.value?.ecu1?.rxHeader ?? "";

      if (App.connectedVia == "USB") {
        await App.usbConnectorService?.setDongleProperties(
          protocolName: protocol,
          txHeaderTemp: txHeader,
          rxHeaderTemp: rxHeader,
        );
      } else if (App.connectedVia == "WIFI") {
        await App.wifiConnectorService?.setDongleProperties(
          protocolName: protocol,
          txHeaderTemp: txHeader,
          rxHeaderTemp: rxHeader,
        );
      }
    } catch (e) {
      print("setDongleProperties error: $e");
    }
  }

  // ── 7. SEARCH ─────────────────────────────────────────────────────────────
  void searchFile() {
    try {
      if (staticFlashFileList.isEmpty) return;

      if (searchKey.value.trim().isNotEmpty) {
        flashFileList.value = staticFlashFileList
            .where((x) =>
                x.productionSwId?.swPartNo
                    ?.toLowerCase()
                    .contains(searchKey.value.toLowerCase()) ==
                true)
            .toList();
      } else {
        flashFileList.value = List.from(staticFlashFileList);
      }
    } catch (e) {
      print("searchFile error: $e");
    }
  }
}
