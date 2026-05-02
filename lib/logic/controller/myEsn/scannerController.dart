import 'dart:async';
import 'dart:convert';
import 'package:autopeepal/models/variant_model.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:get/get.dart';

class ScannerController extends GetxController {
  // ======================
  // SERVICES / DATA
  // ======================
  final AuthApiService services = AuthApiService();

  final StreamController<String> _scanStreamController =
      StreamController<String>.broadcast();

  Stream<String> get scanStream => _scanStreamController.stream;

  void addScan(String value) {
    _scanStreamController.add(value);
  }
  // ======================
  // INPUT PROPS
  // ======================
  var variantNumber = ''.obs;
  var engineSerialNumber = ''.obs;
  var slNumber = ''.obs;
  var comment = ''.obs;

  var title = ''.obs;
  var placeHolder = ''.obs;

  var isScanning = true.obs;
  var isAnalyzing = true.obs;

  late VariantPart variantPart;


  

  // ======================
  // VALIDATE COMMAND
  // ======================
  Future<void> validate() async {
    if (variantNumber.value.isEmpty) {
      Get.defaultDialog(
        title: "Error",
        middleText: "Please enter VIN Number and Engine Serial Number.",
      );
      return;
    }

    await validateVariantCode(variantNumber.value);
  }

  // ======================
  // REPLACE COMMAND
  // ======================
  Future<void> replace() async {
    if ((variantPart!.slNumber ?? '').isEmpty) {
      Get.defaultDialog(
        title: "Error",
        middleText: "Please enter Sl Number.",
      );
      isAnalyzing.value = true;
      isScanning.value = true;
      return;
    }

    if ((variantPart!.comment ?? '').isEmpty) {
      Get.defaultDialog(
        title: "Error",
        middleText: "Please enter comment.",
      );
      isAnalyzing.value = true;
      isScanning.value = true;
      return;
    }

    // 👇 Equivalent to MessagingCenter.Send<ScannerViewModel, VariantPart>
    Get.back(result: variantPart);
  }

  // ======================
  // VALIDATE VARIANT CODE
  // ======================
  Future<void> validateVariantCode(String vin) async {
    try {
      isAnalyzing.value = true;
      isScanning.value = true;

      variantNumber.value = vin;

      List<String> split = vin.split('/');

      if (split.length < 2) {
        Get.defaultDialog(
          title: "Error",
          middleText: "Please enter Engine Serial Number.",
        );
        return;
      }

      String variantCode = split[0];
      String engineNumber = split[1];

      String? jsonData =
          await AndroidOperationsService.getData("Variant_LocalList");

      if (jsonData!.isEmpty) {
        Get.defaultDialog(
          title: "Error",
          middleText: "Please update local data.",
        );
        return;
      }

      VariantModel model = VariantModel.fromJson(jsonDecode(jsonData));

      if (model.message != "success") {
        Get.defaultDialog(title: "Error", middleText: model.message ?? '');
        return;
      }

      if (model.results!.isEmpty) {
        Get.defaultDialog(
            title: "Error", middleText: "Variant list not found.");
        return;
      }

      final variant = model.results!.firstWhereOrNull(
        (x) => x.variantCode == variantCode,
      );

      if (variant == null) {
        Get.defaultDialog(
          title: "Error",
          middleText:
              "Variant number not matching inside variant list\nPlease check entered variant number",
        );
        return;
      }

      // ======================
      // MessagingCenter.Send replacement
      // ======================
      Get.back(result: {
        "variantCode": variantCode,
        "variantId": variant.id.toString(),
        "engineNumber": engineNumber,
      });
    } catch (e) {
      isAnalyzing.value = true;
      isScanning.value = true;
    }
  }

  // ======================
  // SL NUMBER UPDATE
  // ======================
  Future<void> validateVariantPartCode(String vin) async {
    variantPart!.slNumber = vin;
  }
}
