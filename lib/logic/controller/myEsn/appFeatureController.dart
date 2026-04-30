import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFeatureController extends GetxController {
  // Observables
  var firmwareVersion = "V1.0.2".obs; // Mock data
  var connectorImage = "assets/new/ic_usb_white.png".obs;
  var connectedVia = "WiFi".obs;

  // Feature List
  var featureList = <FeatureItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    initRunTimeList();
    initConnectorImage();
  }

  void initConnectorImage() {
    // Logic based on global app state
    if (connectedVia.value == "USB") {
      connectorImage.value = "assets/new/ic_usb_white.png";
    } else {
      connectorImage.value = "assets/new/ic_wifi_white.png";
    }
  }

  void initRunTimeList() {
    // Mimicking the logic from your C# InitRunTimeList()
    var baseFeatures = [
      FeatureItem(name: "DTC", image: Icons.error_outline),
      FeatureItem(name: "Live Parameter", image: Icons.show_chart),
      FeatureItem(name: "Write Parameter", image: Icons.edit_note),
      FeatureItem(name: "Flash", image: Icons.system_update_alt),
      FeatureItem(name: "Routine Test", image: Icons.build),
      FeatureItem(name: "Part Replacement", image: Icons.error_outline),
   
    ];

    featureList.assignAll(baseFeatures);

    if (connectedVia.value == "WiFi") {
      featureList.add(FeatureItem(name: "Settings", image: Icons.settings));
    }
  }

  void onFeatureTap(FeatureItem item) {
    // Navigation logic matching your C# switch statement
    switch (item.name) {
      case "DTC":
        Get.toNamed('/dtc_list');
        break;
      case "Live Parameter":
        Get.toNamed('/live_parameter');
        break;
      case "Flash":
        Get.toNamed('/flash_ecu');
        break;
      default:
        Get.snackbar("Alert", "Function ${item.name} under development");
    }
  }

  void disconnectDongle() {
    Get.defaultDialog(
      title: "Alert",
      middleText: "Do you want to disconnect dongle?",
      textConfirm: "Ok",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF309F93),
      onConfirm: () {
        Get.back(); // Close dialog
        Get.back(); // Go back to previous screen
      },
    );
  }
}

class FeatureItem {
  final String name;
  final IconData
      image; // Using IconData for convenience, can use String for assets
  FeatureItem({required this.name, required this.image});
}
