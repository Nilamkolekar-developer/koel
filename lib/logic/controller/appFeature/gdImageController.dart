// gd_image_controller.dart

import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/all_models.dart';


class GdImageController extends GetxController {

  // ── Arguments ─────────────────────────────────────────────
  List<GdImageGD> gdImages    = [];
  String title                = '';
  late SessionModel sessionModel;
  late ModelResult vehicleModels;

  // ── State ─────────────────────────────────────────────────
  final RxList<GdImageGD> imageList = <GdImageGD>[].obs;
  final RxBool isLoading            = false.obs;

  // ─────────────────────────────────────────────────────────
  // onInit
  // ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      gdImages      = args['gdImages']      as List<GdImageGD>? ?? [];
      title         = args['title']         as String?          ?? '';
      sessionModel  = args['sessionModel']  as SessionModel;
      vehicleModels = args['vehicleModels'] as ModelResult;
    }

    _loadImages();
  }

  // ─────────────────────────────────────────────────────────
  // LoadImageAsync
  // ─────────────────────────────────────────────────────────
  Future<void> _loadImages() async {
    try {
      isLoading.value = true;

      final valid = gdImages
          .where((img) => img.gdImage != null && img.gdImage!.isNotEmpty)
          .toList();

      imageList.assignAll(valid.isNotEmpty ? valid : gdImages);
    } catch (ex) {
      debugPrint("_loadImages error: $ex");
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // TapGestureRecognizer_Tapped
  // ← this.Navigation.PushAsync(new ImageZoomingPage(selectedItem, Title))
  // ─────────────────────────────────────────────────────────
  void onImageTapped(int index) {       // ✅ accepts int index
    try {
      final GdImageGD selectedItem = imageList[index];  // ✅ get item by index
      Get.toNamed(
       Routes.imageZoomingPage,
        arguments: {
          'image': selectedItem,
          'code' : title,
        },
      );
    } catch (ex) {
      debugPrint("onImageTapped: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // images_SelectionChanged — no-op
  // ─────────────────────────────────────────────────────────
  void onSelectionChanged(GdImageGD? item) {}
}