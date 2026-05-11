import 'package:autopeepal/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WriteSsidPassController extends GetxController {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> submitCommand() async {
    String ssid = ssidController.text.trim();
    String password = passwordController.text.trim();

    // 1. Validation (Equivalent to string.IsNullOrEmpty check)
    if (ssid.isEmpty) {
      await Get.defaultDialog(
        title: "Alert",
        middleText: "Enter SSID",
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
      return;
    }

    if (password.isEmpty) {
      await Get.defaultDialog(
        title: "Alert",
        middleText: "Enter Password",
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
      return;
    }

    try {
      // 2. Show Loading (Equivalent to UserDialogs.Instance.Loading)
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 3. Write SSID (Equivalent to App.USBconnectorService.Write_SSID)
      // Note: Reusing your static App service pattern from previous context
      bool resSsid = await App.usbConnectorService!.writeSSID(ssid);

      if (!resSsid) {
        if (Get.isDialogOpen ?? false) Get.back(); // Close loader
        await Get.defaultDialog(
          title: "Alert",
          middleText: "Writing not success",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
        return;
      }

      // 4. Write Password (Equivalent to App.USBconnectorService.Write_Password)
      bool resPass = await App.usbConnectorService!.writePassword(password);

      if (!resPass) {
        if (Get.isDialogOpen ?? false) Get.back(); // Close loader
        await Get.defaultDialog(
          title: "Alert",
          middleText: "Writing not success",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
        return;
      }

      // 5. Final Success and Navigation
      if (Get.isDialogOpen ?? false) Get.back(); // Close loader

      await Get.defaultDialog(
        title: "Alert",
        middleText: "Writing successfully",
        textConfirm: "OK",
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Equivalent to Navigation.PopAsync()
        },
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false)
        Get.back(); // Ensure loader closes on crash
      debugPrint("💥 Submit Error: $e");
      Get.snackbar("Error", "An unexpected error occurred");
    }
  }

  @override
  void onClose() {
    ssidController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
