import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/pidByAddrReqLocal_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveParameterSelectController extends GetxController {
  // Observables
  var ecusList = <EcuModel>[].obs;
  var pidList = <PidCode>[].obs;
  var staticPidList = <PidCode>[].obs;
  var selectedPidList = <PidCode>[].obs;
  var groupList = <PidGroupModel>[].obs;
  var selectedEcu = Rxn<EcuModel>();
  var checkChangedPid = Rxn<PiCodeVariable>();
  var searchKey = "".obs;
  var isRunning = false.obs;
  final RxBool loaderVisible = false.obs;
  final RxString msg = ''.obs;

   var sessionModel = Rxn<SessionModel>();
  ModelResult? vehicleModels;

  RxBool isGroupViewVisible=false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args == null) {
      debugPrint("⚠️ WriteParameterController: No arguments received");
      return;
    }

    try {
      sessionModel.value = args['sessionModel'] as SessionModel?;
      vehicleModels = args['vehicleModels'] as ModelResult?;

      debugPrint("✅ sessionModel: ${sessionModel.value?.id}");
      debugPrint("✅ vehicleModels: ${vehicleModels?.id}");

      if (sessionModel.value == null || vehicleModels == null) {
        debugPrint("⚠️ Required data missing");
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        getPidList();
      });
    } catch (e) {
      debugPrint("🔥 WriteParameterController onInit error: $e");
    }
  }

  void groupPidClicked() {
  isGroupViewVisible.value = true;
}

// ── 9. OK GROUP BY CLICKED ───────────────────────────────────────────────
void okGroupByClicked() {
  isGroupViewVisible.value = false;
}

  // ── 1. GET PID LIST ──────────────────────────────────────────────────────
  Future<void> getPidList() async {
    isRunning.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final pidByAddrSeqStr =
          await AndroidOperationsService.getData("PidByAddrSeqData");
      List<PidByAddrSeqLocalModel> pidByAddrSeqList = [];
      if (pidByAddrSeqStr != null && pidByAddrSeqStr.isNotEmpty) {
        pidByAddrSeqList = (jsonDecode(pidByAddrSeqStr) as List)
            .map((e) => PidByAddrSeqLocalModel.fromJson(e))
            .toList();
      }

      ecusList.clear();
      int count = 0;

      for (var ecu in StaticData.ecuInfo) {
        count++;
        Ecu modelEcu = Ecu();

        final subModel = vehicleModels?.subModels
            ?.firstWhereOrNull((x) => x.id == App.subModelId);
        if (subModel != null) {
          final found =
              subModel.ecus?.firstWhereOrNull((x) => x.id == ecu.ecuId);
          if (found != null) modelEcu = found;
        }

        // Filter pid list based on user role
        List<PidCode> accessPidList = [];
        if (App.userRole == "technician") {
          accessPidList = ecu.pidList
                  ?.where((x) =>
                      x.read == true &&
                      x.isActive == true &&
                      x.access == "SERVICE")
                  .toList() ?? [];
        } else {
          accessPidList = ecu.pidList
                  ?.where((x) => x.read == true && x.isActive == true)
                  .toList() ?? [];
        }

        // Reset all selections
        for (var pid in accessPidList) {
          for (var variable in pid.piCodeVariable ?? []) {
            variable.selected = false;
          }
        }

        final pidByAddr = pidByAddrSeqList
                .firstWhereOrNull((x) => x.ecuId == ecu.ecuId)
                ?.pidByAddrFsq ?? "";

        ecusList.add(EcuModel(
          pidByAddrSeq: pidByAddr,
          ecuName: ecu.ecuName,
          opacity: count == 1 ? 1.0 : 0.5,
          protocol: modelEcu.protocol,
          txHeader: modelEcu.txHeader ?? "",
          rxHeader: modelEcu.rxHeader ?? "",
          pidList: accessPidList,
        ));
      }

      if (ecusList.isNotEmpty) {
        staticPidList.value =
            pidList.value = List<PidCode>.from(ecusList.first.pidList ?? []);
        selectedEcu.value = ecusList.first;
      }

      // Build group list
      if (StaticData.pidGroups.isEmpty) {
        try {
          for (var pid in pidList) {
            for (var vari in pid.piCodeVariable ?? []) {
              for (var group in vari.group ?? []) {
                final exists = StaticData.pidGroups
                    .firstWhereOrNull((x) => x.id == group.id);
                if (exists == null) {
                  StaticData.pidGroups.add(PidGroupModel(
                    id: group.id,
                    groupName: group.value,
                    isSelected: false,
                  ));
                }
              }
            }
          }
        } catch (e) {
          debugPrint("Group build error: $e");
        }
      }

      // Add Select All group if not present
      if (!StaticData.pidGroups.any((x) => x.id == 1000)) {
        StaticData.pidGroups.add(PidGroupModel(
          id: 1000,
          groupName: "Select All",
          isSelected: false,
        ));
      }

      groupList.value = List<PidGroupModel>.from(StaticData.pidGroups);
    } catch (e) {
      debugPrint("getPidList error: $e");
    } finally {
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 2. CHECKBOX CHANGED ──────────────────────────────────────────────────
  void checkBoxChanged(PiCodeVariable pid, {String groupType = ""}) {
    checkChangedPid.value = pid;
    _processCheckBoxChanged(groupType);
  }

  void _processCheckBoxChanged(String groupType) {
    if (checkChangedPid.value == null) return;

    if (groupType != "ByGroup") {
      checkChangedPid.value!.selected = !checkChangedPid.value!.selected;
    }

    for (var item in pidList) {
      if (item.piCodeVariable?.isNotEmpty == true) {
        final vari = item.piCodeVariable?.firstWhereOrNull((y) =>
            y.selected == checkChangedPid.value!.selected &&
            y.id == checkChangedPid.value!.id);

        if (vari != null) {
          PidCode? selectedPid =
              selectedPidList.firstWhereOrNull((x) => x.id == item.id);

          if (checkChangedPid.value!.selected) {
            if (selectedPid == null) {
              selectedPid = PidCode(
                code: item.code,
                resetValue: item.resetValue,
                reset: item.reset,
                id: item.id,
                read: item.read,
                write: item.write,
                writePid: item.writePid,
                totalLen: item.totalLen,
                ioCtrl: item.ioCtrl,
                ioCtrlPid: item.ioCtrlPid,
                isActive: item.isActive,
                memoryAddress: item.memoryAddress,
                piCodeVariable: item.piCodeVariable
                        ?.where((x) => x.selected)
                        .toList() ?? [],
              );
              selectedPidList.add(selectedPid);
            } else {
              selectedPid.piCodeVariable = item.piCodeVariable
                      ?.where((x) => x.selected)
                      .toList() ?? [];
            }
          } else {
            try {
              if (selectedPid != null) {
                selectedPid.piCodeVariable?.removeWhere((y) =>
                    !y.selected && y.id == checkChangedPid.value!.id);

                if (selectedPid.piCodeVariable?.isEmpty == true) {
                  selectedPidList.remove(selectedPid);
                }
              }
            } catch (e) {
              debugPrint("checkBoxChanged remove error: $e");
            }
          }
          break;
        }
      }
    }

    selectedPidList.refresh();
    pidList.refresh();
  }

  // ── 3. GROUP CHECKBOX CHANGED ────────────────────────────────────────────
  Future<void> groupCheckBoxChanged(PidGroupModel grp) async {
    isRunning.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      grp.isSelected = (!grp.isSelected);

      if (grp.id == 1000) {
        grp.groupName = grp.isSelected ? "Unselect All" : "Select All";
      }

      StaticData.pidGroups = List<PidGroupModel>.from(groupList).cast<PidGroupModel>();

      for (var x in pidList) {
        for (var y in x.piCodeVariable ?? []) {
          if (grp.id == 1000) {
            checkChangedPid.value = y;
            checkChangedPid.value!.selected = grp.isSelected;
            _processCheckBoxChanged("ByGroup");
          } else {
            for (var z in y.group ?? []) {
              if (z.id == grp.id) {
                checkChangedPid.value = y;
                checkChangedPid.value!.selected = grp.isSelected;
                _processCheckBoxChanged("ByGroup");
              }
            }
          }
        }
      }

      groupList.refresh();
    } catch (e) {
      debugPrint("groupCheckBoxChanged error: $e");
    } finally {
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 4. TAB CLICKED ───────────────────────────────────────────────────────
  Future<void> tabClicked(EcuModel tappedEcu) async {
    isRunning.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      selectedEcu.value = tappedEcu;
      pidList.value = [];

      for (var ecu in ecusList) {
        ecu.opacity = 0.5;
        if (tappedEcu.ecuName == ecu.ecuName) {
          ecu.opacity = 1.0;
          staticPidList.value =
              pidList.value = List<PidCode>.from(ecu.pidList ?? []);
        } else {
          // Deselect all pids from other ECUs and remove from selected list
          for (var y in ecu.pidList ?? []) {
            for (var z in y.piCodeVariable ?? []) {
              z.selected = false;
              final item =
                  selectedPidList.firstWhereOrNull((x) => x.id == y.id);
              if (item != null) {
                selectedPidList.remove(item);
              }
            }
          }
        }
      }

      ecusList.refresh();
      selectedPidList.refresh();
    } catch (e) {
      debugPrint("tabClicked error: $e");
    } finally {
      isRunning.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // ── 5. CONTINUE ──────────────────────────────────────────────────────────
  Future<void> continueClicked() async {
    if (selectedPidList.isEmpty) {
      Get.snackbar("Alert", "Please select any parameter");
      return;
    }

    await setDongleProperties();

    Get.toNamed(Routes.liveParameterSelected, arguments: {
      'selectedPidList': List<PidCode>.from(selectedPidList),
      'sessionModel': sessionModel.value,
      'pidByAddrSeq': selectedEcu.value?.pidByAddrSeq ?? "",
    });
  }

  // ── 6. SET DONGLE PROPERTIES ─────────────────────────────────────────────
  Future<void> setDongleProperties() async {
    try {
      if (App.connectedVia == "USB") {
        await App.usbConnectorService!.setDongleProperties(
          protocolName: selectedEcu.value?.protocol?.autopeepal ?? "",
          txHeaderTemp: selectedEcu.value?.txHeader ?? "",
          rxHeaderTemp: selectedEcu.value?.rxHeader ?? "",
        );
      } else if (App.connectedVia == "WIFI") {
        await App.wifiConnectorService!.setDongleProperties(
          protocolName: selectedEcu.value?.protocol?.autopeepal ?? "",
          txHeaderTemp: selectedEcu.value?.txHeader ?? "",
          rxHeaderTemp: selectedEcu.value?.rxHeader ?? "",
        );
      }
    } catch (e) {
      debugPrint("setDongleProperties error: $e");
    }
  }

  // ── 7. SEARCH ────────────────────────────────────────────────────────────
  void searchParameter(String query) {
    searchKey.value = query;
    if (query.isEmpty) {
      pidList.value = List<PidCode>.from(staticPidList);
    } else {
      pidList.value = staticPidList
          .where((x) =>
              x.code?.toLowerCase().contains(query.toLowerCase()) == true ||
              x.piCodeVariable?.any((v) =>
                      v.shortName
                          ?.toLowerCase()
                          .contains(query.toLowerCase()) ==
                      true) ==
                  true)
          .toList();
    }
  }
}

// ── PidGroupModel ────────────────────────────────────────────────────────────
