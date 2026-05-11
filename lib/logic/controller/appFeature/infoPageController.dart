import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class InfoController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  var gdData = <ResultGD>[].obs;
  var sessionModel = Rxn<SessionModel>();
  var vehicleModels = Rxn<ModelResult>();

  // ── Computed Getters ───────────────────────────────────────────────────────
  ResultGD? get first => gdData.isNotEmpty ? gdData.first : null;

  String get title        => first?.gdId          ?? "";
  String get description  => first?.gdDescription ?? "";
  String get causes       => first?.causes        ?? "";
  String get effectsOnVehicle => first?.effectsOnVehicle ?? "";

  bool get hasTreeSet =>
      first?.treeSet != null && (first!.treeSet?.isNotEmpty ?? false);

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args == null) {
      debugPrint("⚠️ InfoController: No arguments received");
      return;
    }

    try {
      final data = args['gdData'] as List<ResultGD>?;
      if (data != null) gdData.assignAll(data);

      sessionModel.value  = args['sessionModel'] as SessionModel?;
      vehicleModels.value = args['vehicleModels'] as ModelResult?;

      debugPrint("✅ InfoController initialized — gdId: $title");
    } catch (e) {
      debugPrint("🔥 InfoController onInit error: $e");
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void onStartPressed() {
    if (!hasTreeSet) return;

    Get.toNamed(Routes.treeListPage, arguments: {
      'gdData'       : gdData.toList(),
      'description'  : description,
      'title'        : title,
      'sessionModel' : sessionModel.value,
      'vehicleModels': vehicleModels.value,
    });
  }
}