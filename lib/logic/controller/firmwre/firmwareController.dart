import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/firmwareUpdate_model.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmwareUpdateController extends GetxController {
  final AuthApiService _services = AuthApiService();

  // Observables — mirrors C# properties
  final RxString newFV = "".obs;
  final RxString currFV = "".obs;
  final RxString message = "".obs;
  final RxString url = "".obs;
  final RxBool btnEnable = false.obs;
  final Rx<FirmwareManagerPartition?> selectedFirmware =
      Rx<FirmwareManagerPartition?>(null);

  @override
void onInit() {
  super.onInit();

  // Read the firmwareVersion passed from navigation
  final args = Get.arguments;
  if (args != null && args is String) {
    currFV.value = args; // pre-fill current version from caller
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => _init());
}

  // ── INIT ─────────────────────────────────────────────────────────────────
  Future<void> _init() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final connected = await _checkDongleConnection();
      if (!connected) {
        _closeLoader();
        Get.defaultDialog(title: "Error", middleText: "Dongle not connected.");
        return;
      }

      // Get current firmware from dongle
      currFV.value = await App.wifiConnectorService!.getFirmware1();

      if (currFV.value.isEmpty) {
        _closeLoader();
        Get.defaultDialog(
            title: "Error", middleText: "Dongle firmware version not found.");
        return;
      }

      // Get latest firmware from API
      final result = await _services.getLatestFirmwareVersion("apklwu001");

      if (result.message != "success") {
        _closeLoader();
        Get.defaultDialog(
            title: "Error", middleText: result.message ?? "Unknown error");
        return;
      }

      if (result.results == null || result.results!.isEmpty) {
        _closeLoader();
        Get.defaultDialog(
            title: "Error", middleText: "Firmware list not found.");
        return;
      }

      final item = result.results!
          .firstWhereOrNull((x) => x.partNo?.partNumber == "apklwu001");

      if (item == null) {
        _closeLoader();
        Get.defaultDialog(title: "Error", middleText: "Firmware not found.");
        return;
      }

      if (item.firmwareManagerPartition == null ||
          item.firmwareManagerPartition!.isEmpty) {
        _closeLoader();
        Get.defaultDialog(
            title: "Error", middleText: "Latest firmware list not found.");
        return;
      }

      selectedFirmware.value = item.firmwareManagerPartition!
          .firstWhereOrNull((x) => x.startAddr == "10000");

      if (selectedFirmware.value == null) {
        _closeLoader();
        Get.defaultDialog(
            title: "Error", middleText: "Latest firmware not found.");
        return;
      }

      newFV.value = selectedFirmware.value!.version ?? "";

      // Enable update button only if versions differ
      btnEnable.value = currFV.value != newFV.value;
    } catch (e) {
      debugPrint("FirmwareUpdateController _init error: $e");
      Get.defaultDialog(title: "Alert", middleText: e.toString());
    } finally {
      _closeLoader();
    }
  }

  // ── UPDATE COMMAND ────────────────────────────────────────────────────────
  Future<void> updateClicked() async {
    if (selectedFirmware.value == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final success = await App.wifiConnectorService!
          .updateFirmware(selectedFirmware.value!.firmware ?? "");

      _closeLoader();

      if (success) {
        await Get.defaultDialog(
          title: "Updating new firmware..",
          middleText: "- Please wait till Dongle lights stop blinking."
              "\n- Please do not disconnect dongle.",
          textConfirm: "OK",
          onConfirm: () {
            Get.back(); // close dialog
            Get.offAllNamed('/'); // PopToRoot equivalent
          },
        );
      } else {
        Get.defaultDialog(
          title: "Failed",
          middleText: "Failed to update new firmware.",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      _closeLoader();
      debugPrint("updateClicked error: $e");
    }
  }

  // ── CHECK DONGLE CONNECTION ───────────────────────────────────────────────
  Future<bool> _checkDongleConnection() async {
    try {
      if (App.connectedVia == "WIFI") {
        return await App.wifiConnectorService!.checkConnection();
      } else if (App.connectedVia == "USB") {
        return App.usbConnectorService != null;
      }
      return false;
    } catch (e) {
      debugPrint("_checkDongleConnection error: $e");
      return false;
    }
  }

  // ── HELPER ────────────────────────────────────────────────────────────────
  void _closeLoader() {
    if (Get.isDialogOpen == true) Get.back();
  }
}
