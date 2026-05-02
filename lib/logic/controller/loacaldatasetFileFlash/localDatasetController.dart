import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
import 'package:autopeepal/services/androidOperationservice.dart';

class LocalDatasetFileController extends GetxController {
  RxList<VariantEcu> dataFileList = <VariantEcu>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("👉 Controller INIT");
    getLocalDatasetFile();
  }

  Future<void> getLocalDatasetFile() async {
    print("👉 getLocalDatasetFile START");

    try {
      isLoading.value = true;

      final rawData =
          await AndroidOperationsService.getData("Dataset_LocalList");

      print("👉 RAW DATA FROM STORAGE: $rawData");

      // ❌ EMPTY CHECK
      if (rawData == null || rawData.isEmpty || rawData == "null") {
        print("⚠️ No local data found (EMPTY)");
        dataFileList.clear();
        return;
      }

      // ❌ JSON PARSE
      List<dynamic> decoded;
      try {
        decoded = jsonDecode(rawData);
        print("👉 JSON DECODE SUCCESS: ${decoded.length} items");
      } catch (e) {
        print("❌ JSON PARSE ERROR: $e");
        dataFileList.clear();
        return;
      }

      List<VariantEcu> list =
          decoded.map((e) => VariantEcu.fromJson(e)).toList();

      print("👉 MODEL CONVERTED LIST: ${list.length}");

      // ❌ FILTER OLD DATA
      List<VariantEcu> filtered = List.from(list);

      for (var item in List.from(filtered)) {
        try {
          if (item.date == null || item.date!.isEmpty) {
            print("⚠️ SKIP ITEM (NO DATE)");
            continue;
          }

          DateTime myDate =
              DateFormat("dd-MM-yyyy").parse(item.date!);

          int days = DateTime.now().difference(myDate).inDays;

          print("👉 ITEM DATE: ${item.date} | DAYS: $days");

          if (days > 60) {
            print("🗑️ REMOVING OLD ITEM: ${item.swPartNo}");
            filtered.remove(item);
          }
        } catch (e) {
          print("❌ DATE PARSE ERROR: $e");
        }
      }

      print("👉 FINAL FILTERED LIST: ${filtered.length}");

      // ❌ SAVE BACK
      await AndroidOperationsService.saveData(
        "Dataset_LocalList",
        jsonEncode(filtered),
      );

      print("👉 DATA SAVED BACK TO LOCAL STORAGE");

      // ✅ UPDATE UI
      dataFileList.assignAll(filtered);

      print("✅ UI UPDATED SUCCESSFULLY");
    } catch (e) {
      print("❌ CONTROLLER ERROR: $e");
      dataFileList.clear();
    } finally {
      isLoading.value = false;
      print("👉 LOADING FINISHED");
    }
  }

  Future<void> deleteFile(VariantEcu item) async {
    print("🗑️ DELETE CLICKED: ${item.swPartNo}");

    try {
      dataFileList.remove(item);

      await AndroidOperationsService.saveData(
        "Dataset_LocalList",
        jsonEncode(dataFileList),
      );

      print("✅ FILE DELETED + SAVED");

      Get.snackbar("Success", "File deleted successfully");
    } catch (e) {
      print("❌ DELETE ERROR: $e");
      Get.snackbar("Error", e.toString());
    }
  }
}