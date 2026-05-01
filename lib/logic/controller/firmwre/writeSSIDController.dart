import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WriteSsidPassController extends GetxController {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  void submit() {
    final ssid = ssidController.text.trim();
    final password = passwordController.text.trim();

    if (ssid.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter SSID and Password");
      return;
    }

    // 👉 Replace with actual API / BLE / device write logic
    Get.snackbar("Success", "SSID & Password submitted");

    print("SSID: $ssid");
    print("Password: $password");
  }

  @override
  void onClose() {
    ssidController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
