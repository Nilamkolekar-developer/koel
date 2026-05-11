import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/parameter_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFeatureController extends GetxController {
  // Observables
  var firmwareVersion = "".obs; // Mock data
  var connectorImage = "assets/new/ic_usb_white.png".obs;
  var connectedVia = "WiFi".obs;
  final AuthApiService services = AuthApiService();
  // Feature List
  var featureList = <FeatureItem>[].obs;
  var sessionModel = Rxn<SessionModel>();
  ModelResult? vehicleModels;
  late String extra;
  SessionModel? session;

  // @override
  // void onInit() {
  //   super.onInit();

  //   // ── RETRIEVE ARGUMENTS HERE ──
  //   if (Get.arguments != null) {
  //     sessionModel = Get.arguments['sessionModel'];
  //     firmwareVersion.value = Get.arguments['firmwareVersion'] ?? '';
  //     extra = Get.arguments['extra'] ?? '';

  //     print("✅ Controller received Firmware: $firmwareVersion");
  //   } else {
  //     print("⚠️ No arguments received in AppFeatureController");
  //   }

  //   // Your existing init methods
  //   initRunTimeList();
  //   initConnectorImage();
  // }
  // @override
  // void onInit() {
  //   super.onInit();

  //   final args = Get.arguments;
  //   if (args != null) {
  //     sessionModel.value = args['sessionModel'] as SessionModel?;
  //     vehicleModels = args['vehicleModels'] as ModelResult?;
  //     firmwareVersion.value = args['firmwareVersion'] ?? '';
  //   }

  //   initRunTimeList();
  //   initConnectorImage();

  // }
  @override
  void onInit() {
    super.onInit();

    print("🚀 onInit called");

    final args = Get.arguments;
    print("📦 Raw arguments: $args");

    if (args != null) {
      sessionModel.value = args['sessionModel'] as SessionModel?;
      vehicleModels = args['vehicleModels'] as ModelResult?;
      firmwareVersion.value = args['firmwareVersion'] ?? '';

      print("✅ sessionModel: ${sessionModel.value}");
      print("🚗 vehicleModels: $vehicleModels");
      print("🔢 firmwareVersion: ${firmwareVersion.value}");
    } else {
      print("⚠️ No arguments received");
    }

    initRunTimeList();
    print("🛠 initRunTimeList called");

    initConnectorImage();
    print("🖼 initConnectorImage called");
  }

  Future<void> initConnectorImage() async {
    // We use the global App.connectedVia variable to determine the image
    if (App.connectedVia == "USB") {
      connectorImage.value = "assets/new/ic_usb_white.png";
      connectedVia.value = "USB"; // Updating the text label as well
    } else if (App.connectedVia == "WIFI") {
      connectorImage.value = "assets/new/ic_wifi_white.png";
      connectedVia.value = "WiFi";
    }

    print("🔗 Connector UI updated for: ${App.connectedVia}");
  }

  // void initRunTimeList1() {
  //   // Mimicking the logic from your C# InitRunTimeList()
  //   var baseFeatures = [
  //     FeatureItem(name: "DTC", image: Icons.error_outline),
  //     FeatureItem(name: "Live Parameter", image: Icons.show_chart),
  //     FeatureItem(name: "Write Parameter", image: Icons.edit_note),
  //     FeatureItem(name: "Flash", image: Icons.system_update_alt),
  //     FeatureItem(name: "Routine Test", image: Icons.build),
  //     FeatureItem(name: "Part Replacement", image: Icons.error_outline),
  //   ];

  //   featureList.assignAll(baseFeatures);

  //   if (connectedVia.value == "WiFi") {
  //     featureList.add(FeatureItem(name: "Settings", image: Icons.settings));
  //   }
  // }

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

  RxBool returnValue = false.obs;
  // Future<void> onFeatureItemSelected(dynamic arg) async {
  //   try {
  //     // 1. Show Loading (Equivalent to UserDialogs.Instance.ShowLoading)
  //     Get.dialog(
  //       const Center(child: CircularProgressIndicator()),
  //       barrierDismissible: false,
  //     );

  //     final item = arg;
  //     if (item == null) {
  //       if (Get.isDialogOpen!) Get.back();
  //       return;
  //     }

  //     // Small delay equivalent to Task.Delay(50)
  //     await Future.delayed(const Duration(milliseconds: 50));

  //     switch (item.name) {
  //       case "DTC":
  //         Get.toNamed(Routes.dtcScreen,
  //             arguments: (session: sessionModel, models: vehicleModels));
  //         break;

  //       case "Live Parameter":
  //         //  Get.to(() => LiveParameterSelectPage(session: sessionModel, models: vehicleModels));
  //         break;

  //       case "Write Parameter":
  //         // Get.to(() => WriteParameterPage(session: sessionModel, models: vehicleModels));
  //         break;

  //       case "Flash":
  //         //Get.to(() => FlashFileListPage(session: sessionModel, models: vehicleModels));
  //         break;

  //       case "Actuator Test":
  //         //  Get.to(() => ActuatorListPage(session: sessionModel));
  //         break;

  //       case "Routine Test":
  //         // Get.to(() => IorTestPage(session: sessionModel, models: vehicleModels));
  //         break;

  //       case "Settings":
  //         if (App.connectedVia == "WIFI") {
  //           // Get.to(() => FirmwareUpdatePage(version: firmwareVersion.value));
  //         } else {
  //           Get.defaultDialog(
  //               title: "Alert!",
  //               middleText: "Please connect dongle in WIFI mode");
  //         }
  //         break;

  //       case "Part Replacement":
  //         await _handlePartReplacement();
  //         break;

  //       case "Mapped Live Parameter":
  //         await _handleMappedLiveParameter();
  //         break;
  //     }
  //   } catch (e) {
  //     debugPrint("Error in FeatureCommand: $e");
  //   } finally {
  //     // Hide Loading (Equivalent to HideHud)
  //     if (Get.isDialogOpen!) Get.back();
  //   }
  // }
  Future<void> onFeatureItemSelected(dynamic arg) async {
    try {
      // 1. Show Loading (Industrial style loader)
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.blue)),
        barrierDismissible: false,
      );

      final item = arg;
      if (item == null) {
        if (Get.isDialogOpen ?? false) Get.back();
        return;
      }

      // Small delay to allow the VCI bridge to clear any pending buffers
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. DISMISS DIALOG HERE - Before navigating or performing heavy logic
      if (Get.isDialogOpen ?? false) Get.back();

      switch (item.name) {
        case "DTC":
          debugPrint("📦 Passing sessionModel: ${sessionModel.value?.id}");
          debugPrint("📦 Passing vehicleModels: ${vehicleModels?.id}");

          Get.toNamed(
            Routes.dtcScreen,
            arguments: {
              'sessionModel': sessionModel.value, // ✅ SessionModel (not Rxn)
              'vehicleModels': vehicleModels, // ✅ ModelResult?
            },
          );

          break;
        case "Live Parameter":
          Get.toNamed(
            Routes.liveParameter,
            arguments: {
              'sessionModel': sessionModel.value, // ✅ SessionModel (not Rxn)
              'vehicleModels': vehicleModels, // ✅ ModelResult?
            },
          );
          break;

        case "Write Parameter":
          Get.toNamed(
            Routes.writeParameter,
            arguments: {
              'sessionModel': sessionModel.value, // ✅ SessionModel (not Rxn)
              'vehicleModels': vehicleModels, // ✅ ModelResult?
            },
          );
          break;

        case "Flash":
          Get.toNamed(
            Routes.flashListPage,
            arguments: {
              'sessionModel': sessionModel.value, // ✅ SessionModel (not Rxn)
              'vehicleModels': vehicleModels, // ✅ ModelResult?
            },
          );
          break;

        case "Settings":
          if (App.connectedVia == "WIFI") {
            Get.toNamed(Routes.firmwareUpdateScreen,
                arguments: firmwareVersion.value);
          } else {
            Get.snackbar(
              "Connection Alert",
              "Please switch dongle to WIFI mode for firmware updates.",
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          break;

        case "Part Replacement":
          // Handle logic first, then navigate if successful
          // bool success = await _handlePartReplacement();
          // if (success) Get.toNamed(Routes.partReplacementStatus);
          break;
      }
    } catch (e) {
      debugPrint("🔥 Navigation Error: $e");
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  // Helper for "Part Replacement" complex logic

  // Helper for "Mapped Live Parameter" complex logic

  var parameterEcuList = <ParameterEcuModel>[].obs;
  var selectedParameterEcu = Rxn<ParameterEcuModel>();

  void onSelectedParameterEcu(dynamic arg) {
    try {
      // Show Loading (Equivalent to UserDialogs.Instance.Loading)
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Casting the argument
      final selected = arg as ParameterEcuModel;
      selectedParameterEcu.value = selected;

      // Loop through the observable list to update opacity
      // .refresh() or simply updating the property inside the loop works
      // if the model properties are also observable or if you call refresh()
      for (var parameter in parameterEcuList) {
        if (selected == parameter) {
          parameter.opacity = 1.0;
        } else {
          parameter.opacity = 0.5;
        }
      }

      // Notify GetX that the list has changed to trigger UI rebuild
      parameterEcuList.refresh();
    } catch (e) {
      debugPrint("Error selecting ECU: $e");
    } finally {
      // Hide Loading (Equivalent to using block in C#)
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  Future<void> onDisconnectCommand() async {
    try {
      // 1. Show Loading (Equivalent to UserDialogs.Instance.Loading)
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Equivalent to Task.Delay(200)
      await Future.delayed(const Duration(milliseconds: 200));

      // Close the loading dialog before showing the confirmation alert
      if (Get.isDialogOpen ?? false) Get.back();

      // 2. Display Confirmation (Equivalent to DisplayAlert)
      bool? shouldDisconnect = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Alert"),
          content: const Text("Do you want to disconnect dongle?"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true), // Ok
              child: const Text("Ok"),
            ),
          ],
        ),
      );

      if (shouldDisconnect == true) {
        // 3. Stack Manipulation Logic
        // Your C# code removes the second-to-last page and then pops the current one.
        // In Flutter/GetX, if you want to jump back past the previous page:

        // Option A: Pop current and previous (Pop 2 pages)
        Get.close(2);

        // Option B: If you want to go to a specific page and clear history (Cleaner)
        // Get.offAllNamed(Routes.connectionPage);
      }
    } catch (e) {
      debugPrint("Error during disconnect: $e");
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<void> onReconnectCommand() async {
    try {
      // 1. Show Loading (Equivalent to ShowLoading with MaskType.Black)
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // Small delay equivalent to Task.Delay(50)
      await Future.delayed(const Duration(milliseconds: 50));

      String resp = "";

      // 2. WiFi Reconnection Logic
      if (App.connectedVia == "WIFI") {
        // Assuming App.IPAddress was stored during the initial connection
        resp = await App.wifiConnectorService!
            .getDongleMacID(App.ipAddress, true, true, "00");

        _showResultAlert(resp);
      }

      // 3. USB Reconnection Logic
      else if (App.connectedVia == "USB") {
        // In Flutter, we call the disconnect/cleanup logic directly instead of MessagingCenter
        await App.usbConnectorService!.disconnectUSB();

        // Attempt handshake again
        resp = await App.usbConnectorService!.getDongleMacID(
          true, // isLengthFFF
          true, // isChannels
          "00", // channelId
          false, // isObdCharger
        );

        _showResultAlert(resp);
      }
    } catch (e) {
      debugPrint("Reconnect Error: $e");
      if (App.connectedVia == "USB") {
        Get.defaultDialog(
          title: "Failed!",
          middleText: "Please Try Once Again.",
          textConfirm: "Ok",
          onConfirm: () => Get.back(),
        );
      }
    } finally {
      // 4. Hide Loading (Equivalent to HideHud)
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

// Helper to show Success/Alert dialogs to keep the code clean
  void _showResultAlert(String response) {
    if (response.isNotEmpty) {
      Get.defaultDialog(
        title: "Success",
        middleText: "Dongle reconnected successfully",
        textConfirm: "Ok",
        onConfirm: () => Get.back(),
      );
    } else {
      Get.defaultDialog(
        title: "Alert",
        middleText: "Failed to connect with dongle.",
        textConfirm: "Ok",
        onConfirm: () => Get.back(),
      );
    }
  }

  // Future<void> initRunTimeList() async {
  //   try {
  //     // 1. Initialize the list from your StaticData
  //     // .assignAll is the GetX way to refresh an RxList
  //     featureList
  //         .assignAll(StaticData.runTimeLicenceList as Iterable<FeatureItem>);

  //     // 2. Add Settings if connected via WIFI
  //     if (App.connectedVia == "WIFI") {
  //       featureList.add(FeatureItem(
  //         name: "Settings",
  //         image: "assets/new/ic_settings.png",
  //       ));
  //     }

  //     // 3. Logic for Mapped Live Parameter
  //     // Check if any ECU has a mapped_pid_dataset_id
  //     bool hasMappedPid =
  //         StaticData.ecuInfo.any((x) => (x.mappedPidDatasetId ?? 0) != 0);

  //     if (hasMappedPid) {
  //       // Find the index of "Live Parameter"
  //       int index =
  //           featureList.indexWhere((item) => item.name == "Live Parameter");

  //       if (index != -1) {
  //         // Insert right after "Live Parameter"
  //         featureList.insert(
  //           index + 1,
  //           FeatureItem(
  //             name: "Mapped Live Parameter",
  //             image: "assets/new/ic_live_parameter.png",
  //           ),
  //         );
  //       }
  //     }

  //     // 4. Calculate Height (Equivalent to FeatureListHeight)
  //     if (featureList.isNotEmpty) {
  //       // Use Get.context to check device type/size or simple MediaQuery
  //       bool isTablet = Get.width > 600; // Common breakpoint for tablets

  //       if (isTablet) {
  //         // Using double for height in Flutter
  //         featureListHeight.value = 122.0 * featureList.length;
  //       } else {
  //         featureListHeight.value = 82.0 * featureList.length;
  //       }
  //     }

  //     // Notify UI (optional if using RxList, but good practice after multiple changes)
  //     featureList.refresh();
  //   } catch (e) {
  //     debugPrint("Error initializing feature list: $e");
  //   }
  // }
  Future<void> initRunTimeList() async {
    try {
      // Clear and rebuild or assign from static data
      List<FeatureItem> tempItems = [
        FeatureItem(name: "DTC", icon: Icons.warning_amber_rounded),
        FeatureItem(name: "Live Parameter", icon: Icons.show_chart),
        FeatureItem(name: "Write Parameter", icon: Icons.edit_note),
        FeatureItem(name: "Flash", icon: Icons.system_update_alt),
        FeatureItem(name: "Routine Test", icon: Icons.build),
        FeatureItem(name: "Part Replacement", icon: Icons.error_outline),
      ];

      featureList.assignAll(tempItems);

      // Add Settings if connected via WIFI
      if (App.connectedVia == "WIFI") {
        featureList.add(FeatureItem(
          name: "Settings",
          icon: Icons.settings,
        ));
      }

      // Insert Mapped Live Parameter logic
      bool hasMappedPid =
          StaticData.ecuInfo.any((x) => (x.mappedPidDatasetId ?? 0) != 0);
      if (hasMappedPid) {
        int index =
            featureList.indexWhere((item) => item.name == "Live Parameter");
        if (index != -1) {
          featureList.insert(
            index + 1,
            FeatureItem(
                name: "Mapped Live Parameter", icon: Icons.account_tree),
          );
        }
      }

      featureList.refresh();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<bool> isInternetAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    return connectivityResult != ConnectivityResult.none;
  }
}

class FeatureItem {
  final String name;
  final IconData icon; // Keep it non-nullable
  final String? assetPath;

  FeatureItem({
    required this.name,
    // Provide a fallback icon in the constructor if you want,
    // but usually, it's better to ensure it's passed.
    this.icon = Icons.device_unknown,
    this.assetPath,
  });
}
