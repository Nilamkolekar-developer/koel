import 'dart:async';
import 'dart:convert';
import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
import 'package:autopeepal/models/downloadFlashFileEcu_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/models/variant_model.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadFlashFileController extends GetxController {
  final AuthApiService services = AuthApiService();

  SessionModel? session;

  // ── Observables ──────────────────────────────────────────────
  var ecusList = <DownloadFlashFileEcuModel>[].obs;
  var selectedEcu = Rxn<DownloadFlashFileEcuModel>();
  RxList<LocalVariantEcuEcu> dataFileListRx = <LocalVariantEcuEcu>[].obs;
  var selectedDataFile = Rxn<LocalVariantEcuEcu>();

  var flashFileViewVisible = false.obs;
  var isDwnlViewVisible = false.obs;
  var dwnldPercent = "0.0%".obs;

  // ── Init ─────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    print("🟢 onInit STARTED");
    print("📥 Get.arguments received: ${Get.arguments}");

    final args = Get.arguments;

    if (args != null) {
      session = args["sessionModel"];
      print("✅ Session assigned successfully");
      print("📦 Session data: $session");
    } else {
      print("❌ Get.arguments is NULL");
    }

    // ❌ DO NOT call initEcu directly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("⏳ PostFrameCallback triggered -> calling initEcu()");
      initEcu();
    });

    print("🟢 onInit COMPLETED");
  }

  // ── InitEcu ──────────────────────────────────────────────────
  Future<void> initEcu() async {
    try {
      print("🚀 initEcu STARTED");

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      ecusList.clear();
      print("🧹 ecusList cleared");

      final ecus = session?.variant?.subModel?.ecus ?? [];
      final variantEcuList = session?.variant?.variantEcu ?? [];

      print("📦 Total ECUs from session: ${ecus.length}");
      print("📦 Total Variant ECU list: ${variantEcuList.length}");

      for (int i = 0; i < ecus.length; i++) {
        final ecu = ecus[i];

        print("➡️ Processing ECU: ${ecu.name}, id: ${ecu.id}");

        final flashEcu = DownloadFlashFileEcuModel(
          ecuName: ecu.name,
          id: ecu.id,
          opacity: (i == 0) ? 1.0 : 0.5,
        );

        flashEcu.variantEcu =
            variantEcuList.where((x) => x.ecu?.id == ecu.id).toList();

        print(
            "🔗 Mapped variantECU count for ${ecu.name}: ${flashEcu.variantEcu?.length ?? 0}");

        ecusList.add(flashEcu);
      }

      print("✅ Final ECUs loaded: ${ecusList.length}");

      if (ecusList.isNotEmpty) {
        selectedEcu.value = ecusList.first;
        print("🎯 Selected ECU: ${selectedEcu.value?.ecuName}");

        final firstVariant = ecusList.first.variantEcu;

        print("📂 First ECU variant count: ${firstVariant?.length ?? 0}");

        if (firstVariant != null && firstVariant.isNotEmpty) {
          print("🔍 Checking file existence for first ECU...");
          await checkFileIsExist(firstVariant);
        } else {
          print("⚠️ No variant ECU found for first ECU");
        }
      } else {
        print("⚠️ No ECUs found in session");
      }

      print("🏁 initEcu COMPLETED");
    } catch (e) {
      print("❌ initEcu ERROR: $e");

      Get.defaultDialog(
        title: "Error",
        middleText: e.toString(),
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
        print("🔒 Loader closed in finally");
      }
    }
  }

  Future<void> checkFileIsExist(List<VariantEcuEcu> list) async {
    try {
      final List<LocalVariantEcuEcu> updatedList = [];

      String? jsonData =
          await AndroidOperationsService.getData("Dataset_LocalList");
      List<VariantEcu> localData = [];

      if (jsonData != null && jsonData.isNotEmpty) {
        final decoded = jsonDecode(jsonData) as List;
        localData = decoded.map((e) => VariantEcu.fromJson(e)).toList();
      }

      for (var item in list) {
        // Look for match in local storage
        final exists = localData.any((x) =>
            x.ecuId == selectedEcu.value?.id &&
            x.productionSwId?.id == item.productionSwId?.id);

        updatedList.add(
          LocalVariantEcuEcu(
            ecuId: item.id,
            productionSwId: item.productionSwId,
            isActive: item.isActive,
            isLatest: item.isLatest,
          )
            ..backgroundColor = exists ? const Color(0xFF309F93) : Colors.white
            ..isEnable = true // ⬅️ MATCH C#: Always true so button is clickable
            ..imgDownload = exists
                ? "assets/new/ic_downloaded.png"
                : "assets/new/ic_download.png",
        );
      }

      dataFileListRx.value = updatedList;
    } catch (e) {
      debugPrint("❌ checkFileIsExist error: $e");
    }
  }

  Future<void> downloadCommand(LocalVariantEcuEcu arg) async {
    Timer? timer;
    try {
      // 1. Guard Clause: Prevent double-tapping while a download is active
      if (isDwnlViewVisible.value) return;

      print("\n================ DOWNLOAD START ================");
      print("👉 SW Part No: ${arg.productionSwId?.swPartNo}");

      // 2. Setup UI State for Download View
      isDwnlViewVisible.value = true;
      dwnldPercent.value = "0.0%";
      selectedDataFile.value = arg;

      // 3. Start Progress Timer (Matches C# Device.StartTimer)
      timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
        final progress = services.downloadProgress;
        // Handle NaN or Infinite cases safely
        double safeProgress =
            (progress.isNaN || progress.isInfinite) ? 0.0 : progress;

        // Clamp between 0.0 and 1.0, then convert to percentage
        double percent = (safeProgress * 100).clamp(0.0, 100.0);
        dwnldPercent.value = "${percent.toStringAsFixed(1)}%";

        if (!isDwnlViewVisible.value) {
          t.cancel();
        }
      });

      // 4. Download File API Call
      String dataFileLocal = await services.readDataFile(
        arg.productionSwId?.hexSrecFile ?? "",
      );

      // 5. Check if download failed
      if (dataFileLocal.isEmpty) {
        isDwnlViewVisible.value = false;
        timer.cancel();
        Get.snackbar(
          "Error",
          "File not downloaded.\nPlease check your connection and try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      // 6. Load and Update Local Dataset (Matches C# Dataset_LocalList logic)
      print("💾 Saving file to local storage...");
      String? jsonData =
          await AndroidOperationsService.getData("Dataset_LocalList");
      List<VariantEcu> ecuVariantList = [];

      if (jsonData != null && jsonData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonData);
        ecuVariantList = decoded.map((e) => VariantEcu.fromJson(e)).toList();
      }

      // Optional: Remove existing entry for this specific SW ID to prevent duplicates
      ecuVariantList.removeWhere((x) =>
          x.ecuId == selectedEcu.value?.id &&
          x.productionSwId?.id == arg.productionSwId?.id);

      // Create new record
      final newEntry = VariantEcu(
        date: DateTime.now().toString(),
        ecuId: selectedEcu.value?.id,
        ecuName: selectedEcu.value?.ecuName,
        productionSwId: ProductionSW(
          dataFile: arg.productionSwId?.dataFile,
          dataFileLocal: dataFileLocal, // The actual downloaded content
          hexSrecFile: arg.productionSwId?.hexSrecFile,
          swPartNo: arg.productionSwId?.swPartNo,
          id: arg.productionSwId?.id,
        ),
      );

      ecuVariantList.add(newEntry);

      // Persist to Android/iOS storage
      await AndroidOperationsService.saveData(
        "Dataset_LocalList",
        jsonEncode(ecuVariantList.map((e) => e.toJson()).toList()),
      );

      // 7. Update UI Card State
      arg.backgroundColor = const Color(0xFF309F93);
      arg.imgDownload = "assets/new/ic_downloaded.png";
      arg.isEnable =
          true; // Set to true if you want the button to be clickable for flashing

      // Refresh the RxList to notify Obx in the UI
      dataFileListRx.refresh();

      // 8. Stop Loading View
      isDwnlViewVisible.value = false;
      timer.cancel();

      // 9. Success Dialog (Matches C# await page.DisplayAlert)
      await Get.dialog(
        AlertDialog(
          title: const Text("Success"),
          content: const Text("Data File downloaded successfully."),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "OK",
                style: TextStyle(
                    color: Color(0xFF309F93), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      print("🎉 DOWNLOAD AND SAVE COMPLETE");
    } catch (e, stacktrace) {
      isDwnlViewVisible.value = false;
      timer?.cancel();
      debugPrint("❌ Download Error: $e");
      debugPrint("Stacktrace: $stacktrace");

      Get.snackbar("Error", "An unexpected error occurred: $e");
    } finally {
      // Final cleanup safety
      timer?.cancel();
      isDwnlViewVisible.value = false;
    }
  }

  // ── EcuTabCommand ────────────────────────────────────────────
  Future<void> ecuTabCommand(DownloadFlashFileEcuModel ecu) async {
    try {
      if (isDwnlViewVisible.value) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      selectedEcu.value = ecu;

      ecusList.value = ecusList.map((e) {
        e.opacity = (e.id == ecu.id) ? 1.0 : 0.5;
        return e;
      }).toList();

      if (ecu.variantEcu != null && ecu.variantEcu!.isNotEmpty) {
        await checkFileIsExist(ecu.variantEcu!);
      }
    } catch (e) {
      debugPrint("❌ ecuTabCommand error: $e");
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  Future<void> downloadCommand1(LocalVariantEcuEcu arg) async {
    Timer? timer;

    try {
      if (isDwnlViewVisible.value) {
        print("⛔ Download already running");
        return;
      }

      print("\n================ DOWNLOAD START ================");
      print("👉 FILE: ${arg.productionSwId?.swPartNo}");
      print("👉 FILE ID: ${arg.productionSwId?.id}");
      print("👉 ECU ID: ${selectedEcu.value?.id}");

      // ================= UI STATE =================
      isDwnlViewVisible.value = true;
      dwnldPercent.value = "0.0%";
      selectedDataFile.value = arg;

      // ================= LOADER (SAFE) =================
      if (!(Get.isDialogOpen ?? false)) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
      }

      await Future.delayed(const Duration(milliseconds: 150));

      // ================= LOAD LOCAL DATA =================
      print("📦 Loading local dataset...");

      String? jsonData =
          await AndroidOperationsService.getData("Dataset_LocalList");

      final List<VariantEcu> ecuVariantList =
          jsonData != null && jsonData.isNotEmpty
              ? (jsonDecode(jsonData) as List)
                  .map((e) => VariantEcu.fromJson(e))
                  .toList()
              : [];

      print("📦 Local records: ${ecuVariantList.length}");

      // ================= TIMER (SAFE SINGLE INSTANCE) =================
      // ignore: dead_code
      timer?.cancel();

      timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
        final progress = services.downloadProgress;

        final safeProgress =
            (progress.isNaN || progress.isInfinite) ? 0.0 : progress;

        final percent = (safeProgress * 100).clamp(0, 100);

        dwnldPercent.value = "${percent.toStringAsFixed(1)}%";

        print("⬇️ Progress: ${dwnldPercent.value}");

        if (!isDwnlViewVisible.value) {
          print("🛑 Timer stopped");
          t.cancel();
        }
      });

      // ================= DOWNLOAD =================
      print("⬇️ Download API call started...");

      final dataFileLocal = await services.readDataFile(
        arg.productionSwId?.hexSrecFile ?? "",
      );

      print("📄 File size: ${dataFileLocal.length}");

      if (dataFileLocal.isEmpty) {
        timer.cancel();

        if (Get.isDialogOpen ?? false) Get.back();

        await Get.dialog(
          const AlertDialog(
            title: Text("Error"),
            content: Text("File not downloaded"),
          ),
        );
        return;
      }

      // ================= CLOSE LOADER ONCE =================
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      await Future.delayed(const Duration(milliseconds: 150));

      // ================= SAVE DATA =================
      print("💾 Saving data...");

      final newEcu = VariantEcu(
        date: DateTime.now().toString(),
        ecuId: selectedEcu.value?.id,
        ecuName: selectedEcu.value?.ecuName,
        productionSwId: ProductionSW(
          dataFile: arg.productionSwId?.dataFile,
          dataFileLocal: dataFileLocal,
          hexSrecFile: arg.productionSwId?.hexSrecFile,
          swPartNo: arg.productionSwId?.swPartNo,
          id: arg.productionSwId?.id,
        ),
      );

      ecuVariantList.add(newEcu);

      await AndroidOperationsService.saveData(
        "Dataset_LocalList",
        jsonEncode(ecuVariantList.map((e) => e.toJson()).toList()),
      );

      // ================= UI UPDATE (SAFE REPLACE) =================
      print("🔄 Updating UI...");

      final index = dataFileListRx.indexWhere(
        (e) => e.productionSwId?.id == arg.productionSwId?.id,
      );

      if (index != -1) {
        final old = dataFileListRx[index];

        dataFileListRx[index] = LocalVariantEcuEcu(
          ecuId: old.ecuId,
          productionSwId: old.productionSwId,
          isActive: old.isActive,
          isLatest: old.isLatest,
        )
          ..backgroundColor = const Color(0xFF309F93)
          ..isEnable = false
          ..imgDownload = "assets/new/ic_downloaded.png";
      }

      dataFileListRx.refresh();

      print("✅ UI refreshed");

      // ================= SUCCESS =================
      await Get.dialog(
        AlertDialog(
          title: const Text("Success"),
          content: const Text("Data File downloaded successfully."),
          actions: [
            TextButton(
              onPressed: () => Get.back(), // Closes the dialog
              child: const Text("OK",
                  style: TextStyle(
                      color: AppColors.themeColor,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      print("🎉 DOWNLOAD COMPLETE");
      print("================ END ================");
    } catch (e, s) {
      print("❌ ERROR: $e");
      print(s);

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } finally {
      timer?.cancel();
      isDwnlViewVisible.value = false;

      print("🧹 CLEANUP DONE");

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  // ── InfoCommand ──────────────────────────────────────────────
  void infoCommand(LocalVariantEcuEcu item) {
    try {
      // Toggle the boolean just like in C#
      item.isDescVisible = item.isDescVisible;

      // CRITICAL: Notify GetX that an item inside the list has changed
      dataFileListRx.refresh();
    } catch (e) {
      debugPrint("Error in InfoCommand: $e");
    }
  }

  // ── Helpers ──────────────────────────────────────────────────
}
