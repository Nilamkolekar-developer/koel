import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';

class TreeListController extends GetxController {

  // ── Injected Arguments ────────────────────────────────────
  late List<ResultGD> gdData;
  late String description;
  late String code;
  late SessionModel sessionModel;
  late ModelResult vehicleModels;

  // ── Derived State ─────────────────────────────────────────
  ResultGD? get firstGd => gdData.isNotEmpty ? gdData.first : null;

  List<GdImageGD> get gdImages => firstGd?.gdImages ?? [];

  bool get hasTreeSet =>
      firstGd?.treeSet != null && firstGd!.treeSet!.isNotEmpty;

  // ── Init ──────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    // Read arguments passed via Get.to(arguments: {...})
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      gdData        = args['gdData']        as List<ResultGD>;
      description   = args['description']   as String? ?? '';
      code          = args['code']          as String? ?? '';
      sessionModel  = args['sessionModel']  as SessionModel;
      vehicleModels = args['vehicleModels'] as ModelResult;
    }
  }

  // ── Toolbar Icon Pressed ──────────────────────────────────
  void onImageIconPressed() {
    try {
      if (hasTreeSet) {
        Get.toNamed(Routes.
          gdImagePage,
          arguments: {
            'gdImages'     : gdImages,
            'title'        : code,
            'sessionModel' : sessionModel,
            'vehicleModels': vehicleModels,
          },
        );
      } else {
        _showAlert("Tree not found.");
      }
    } catch (ex) {
      debugPrint("onImageIconPressed error: $ex");
    }
  }

  // ── List Item Button Pressed ──────────────────────────────
  void onGdClicked(ResultGD selectedItem) {
    try {
      if (firstGd == null) return;

      if (hasTreeSet) {
        Get.toNamed(
         Routes.treeListSurveyPage,
          arguments: {
            'gdData'       : firstGd,
            'description'  : '',
            'code'         : code,
            'sessionModel' : sessionModel,
            'vehicleModels': vehicleModels,
          },
        );
      } else {
        _showAlert("Tree not found.");
      }
    } catch (ex) {
      debugPrint("onGdClicked error: $ex");
    }
  }

  // ── Alert Helper ──────────────────────────────────────────
  void _showAlert(String message) {
    Get.dialog(
      AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}