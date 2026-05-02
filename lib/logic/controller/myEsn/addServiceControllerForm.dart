import 'dart:convert';
import 'dart:io';

import 'package:autopeepal/logic/controller/myEsn/scannerController.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/creteSessionReq_model.dart';

import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/variant_model.dart';

import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/app.dart';

class AddServiceRequestController extends GetxController {
  final AuthApiService services = AuthApiService();
  Rx<VariantModel?> variantModel = Rx<VariantModel?>(null);

  // =========================
  // TEXT CONTROLLERS (SINGLE SOURCE OF TRUTH)
  // =========================
  final srNumberCtrl = TextEditingController();
  final esnCtrl = TextEditingController();
  final customerNameCtrl = TextEditingController();
  final customerVoiceCtrl = TextEditingController();
  final gensetCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final complaintCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final appCodeCtrl = TextEditingController();
  final varient = TextEditingController();

  // =========================
  // REQUEST MODEL
  // =========================
  final requestModel = CreateSessionReqModel().obs;

  // =========================
  // UI STATE
  // =========================
  final isFormVisible = false.obs;

  final isCustomerVoiceEnabled = true.obs;
  final isAppCodeEnabled = true.obs;
  final isESNEnabled = true.obs;
  final isCustomerNameEnabled = true.obs;
  final isGensetEnabled = true.obs;
  final isHoursEnabled = true.obs;

  final srType = ''.obs;

  // =========================
  // SERVICE LIST
  // =========================
  final serviceList = <Map<String, dynamic>>[
    {'id': 1, 'name': 'CSP', 'selected': false},
    {'id': 2, 'name': 'BD & CM', 'selected': false},
    {'id': 3, 'name': 'Line Rejection', 'selected': false},
    {'id': 4, 'name': 'Campaign', 'selected': false},
    {'id': 5, 'name': 'Post Warranty', 'selected': false},
    {'id': 6, 'name': 'AMC', 'selected': false},
    {'id': 7, 'name': 'Others', 'selected': false},
  ].obs;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    fetchAddress();
    initScannerListener();
  }

  void onVariantChanged(String value) {
    if (variantModel.value == null) return;

    final variant = variantModel.value!.results!.firstWhereOrNull(
      (x) => x.variantCode == value,
    );

    if (variant != null) {
      requestModel.value.variant = value;
    }
  }

  // =========================
  // ADDRESS
  // =========================
  Future<void> fetchAddress() async {
    try {
      final result = await AndroidOperationsService.getCurrentAddress();
      addressCtrl.text = result;
    } catch (e) {
      Get.snackbar("Error", "Failed to get address");
    }
  }

  // =========================
  // LOADER HELPERS
  // =========================
  void showLoader() {
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
    }
  }

  void hideLoader() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // =========================
  // INTERNET CHECK
  // =========================
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // SERVICE SELECT
  // =========================
  void checkChange(Map<String, dynamic> item) {
    for (var s in serviceList) {
      s['selected'] = false;
      if (s['id'] == item['id']) {
        s['selected'] = true;
        srType.value = s['name'];
      }
    }
    serviceList.refresh();
  }

  // =========================
  // BUILD REQUEST MODEL
  // =========================
  var appCode = ''.obs;
  void _syncRequestModel() {
    requestModel.update((val) {
      val?.srNumber = srNumberCtrl.text;
      val?.esn = esnCtrl.text;
      val?.customerName = customerNameCtrl.text;
      val?.customerVoice = customerVoiceCtrl.text;
      val?.genset = gensetCtrl.text;
      val?.hrs = hoursCtrl.text;
      val?.complaint = complaintCtrl.text;
      val?.srType = srType.value;
      //val?.appCode = appCodeCtrl.text;
      val?.latlong = addressCtrl.text;
      val?.createdBy = App.userId;
      val?.variant = "1123";
    });
  }

  // =========================
  // VALIDATION
  // =========================
  bool validate() {
    final m = requestModel.value;
    String msg = "";
    int i = 1;

    if ((m.srNumber ?? "").isEmpty) msg += "${i++}. SR Number required\n";
    if ((m.esn ?? "").isEmpty) msg += "${i++}. ESN required\n";
    if ((m.customerName ?? "").isEmpty)
      msg += "${i++}. Customer Name required\n";
    if ((m.genset ?? "").isEmpty) msg += "${i++}. Genset required\n";
    if ((m.hrs ?? "").isEmpty) msg += "${i++}. Hours required\n";
    if ((m.srType ?? "").isEmpty) msg += "${i++}. SR Type required\n";
    if ((m.complaint ?? "").isEmpty) msg += "${i++}. Complaint required\n";
    if ((m.latlong ?? "").isEmpty) msg += "${i++}. Location required\n";

    if (msg.isNotEmpty) {
      Get.defaultDialog(title: "Error", middleText: msg);
      return false;
    }

    return true;
  }

  // =========================
  // MAIN CREATE FLOW
  // =========================
  Future<void> createSrSession() async {
    try {
      showLoader();

      _syncRequestModel();

      final valid = validate();
      if (!valid) {
        hideLoader();
        return;
      }

      final internet = await checkInternet();
      if (!internet) {
        hideLoader();
        Get.defaultDialog(
          title: "Alert",
          middleText: "No Internet Connection",
        );
        return;
      }

      await createOnlineSR();

      hideLoader();
    } catch (e) {
      hideLoader();
      Get.defaultDialog(title: "Error", middleText: e.toString());
    }
  }

  // =========================
  // ONLINE CREATE
  // =========================
  Future<void> createOnlineSR() async {
    final res = await services.createSession(requestModel.value);

    if (res.success == true) {
      Get.snackbar("Success", "Session Created");

      final list = await services.getAllSessionList(App.userId);

      await AndroidOperationsService.saveData(
        "Session_LocalList",
        jsonEncode(list.toJson()),
      );

      await getCreatedSession(res.id ?? 0);
    } else {
      Get.defaultDialog(
        title: "Error",
        middleText: res.message ?? "Failed",
      );
    }
  }

  // =========================
  // GET CREATED SESSION
  // =========================
  Future<void> getCreatedSession(int sessionId) async {
    try {
      final res = await services.getSessionBySessionId(sessionId);

      if (res.results == null || res.results!.isEmpty) return;

      final item = res.results!.first;

      final modelJson =
          await AndroidOperationsService.getData("MODEL_LocalList");

      final models = AllModelsModel.fromJson(jsonDecode(modelJson ?? "{}"));

      final model = models.results
          ?.firstWhereOrNull((x) => x.id == item.variant?.modelId);

      if (model == null) return;

      final subModel = model.subModels?.firstWhereOrNull(
        (x) => x.id == item.variant?.sModelId,
      );

      if (subModel == null) return;

      StaticData.ecuInfo = [];

      for (var ecuRef in item.variant?.subModel?.ecus ?? []) {
        final ecu = subModel.ecus?.firstWhereOrNull((x) => x.id == ecuRef.id);

        if (ecu == null) continue;

        StaticData.ecuInfo.add(
          EcuDataSet(
            ecuId: ecu.id,
            ecuName: ecu.name,
            protocol: ecu.protocol,
            txHeader: ecu.txHeader,
            rxHeader: ecu.rxHeader,
            readDtcIndex: ecu.readDtcFnIndex?.value,
            clearDtcIndex: ecu.clearDtcFnIndex?.value,
          ),
        );
      }

      Get.back();
    } catch (e) {
      Get.defaultDialog(title: "Error", middleText: e.toString());
    }
  }

  var variantName = ''.obs;
  var variant = ''.obs;
  var esnFromScanner = ''.obs;
  void initScannerListener() {
    Get.find<ScannerController>().scanStream.listen((value) {
      try {
        variantName.value = value[0];
        variant.value = value[1];
        esnFromScanner.value = value[2];

        // 🔥 map to request model also
        requestModel.update((val) {
          val?.variant = value[1];
          val?.esn = value[2];
        });
      } catch (e) {
        Get.snackbar("Error", e.toString());
      }
    });
  }
}
