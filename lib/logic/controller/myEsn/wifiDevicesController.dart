import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import your WifiDevicesModel path

class WifiDevicesController extends GetxController {
  // Observable list of discovered devices
  var wifiDevicesList = <WifiDevicesModel>[].obs;

  // Track if we are currently scanning for new VCIs
  var isScanning = false.obs;

  // Track the IP of the currently linked device
  var linkedDeviceIp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load some mock data for initial testing on your Windows laptop
    fetchWifiDevices();
  }

  // Method to simulate discovery or fetch from your VCI API
  void fetchWifiDevices() {
    isScanning.value = true;

    // Simulating a network delay
    Future.delayed(const Duration(seconds: 1), () {
      var mockData = [
        WifiDevicesModel(
            name: 'apidwu001',
            ip: '192.168.254.87',
            macAddress: '00:1A:2B:3C:4D:5E'),
      ];
      wifiDevicesList.assignAll(mockData);
      isScanning.value = false;
    });
  }

  // Logic for the 'Link' button on the UI
  void connectToDevice(WifiDevicesModel device) {
    if (device.ip != null) {
      linkedDeviceIp.value = device.ip!;
      Get.toNamed(Routes.appFeaturePage);
      // Add your actual TCP/UDP handshake logic here
      Get.snackbar(
        'VCI Connection',
        'Successfully linked to ${device.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF309F93),
        colorText: Colors.white,
      );
    }
  }

  // Logic for the Floating Action Button (+)
  void startNewScan() {
    wifiDevicesList.clear();
    fetchWifiDevices();
  }
}
