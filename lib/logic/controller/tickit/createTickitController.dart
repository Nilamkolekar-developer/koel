import 'dart:convert';
import 'dart:typed_data';

import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/createTickit_model.dart';
import 'package:autopeepal/models/user_model.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/filePicker_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTicketController extends GetxController {
  final AuthApiService services = AuthApiService();
  final FilePickerService filePicker = FilePickerService();

  /// ===================== STATE =====================

  RxBool isAuth = false.obs;

  Rx<CreateTicketModel> createModel = CreateTicketModel().obs;

  RxList<RegionModel> regionList = <RegionModel>[].obs;
  Rx<RegionModel?> selectedRegion = Rx<RegionModel?>(null);

  RxList<IssueResultModel> issueList = <IssueResultModel>[].obs;
  Rx<IssueResultModel?> selectedIssue = Rx<IssueResultModel?>(null);

  RxList<RelatedIssueResultModel> relatedIssueList =
      <RelatedIssueResultModel>[].obs;
  Rx<RelatedIssueResultModel?> selectedRelatedIssue =
      Rx<RelatedIssueResultModel?>(null);

  Rx<DateTime> invoiceDate = DateTime.now().obs;
RxBool otherViewVisible = false.obs;
  RxString fileName = "".obs;

  /// UI FLAGS
  RxBool showRelatedIssue = false.obs;
  RxBool showApkField = false.obs;
  RxBool showDongleField = false.obs;

  /// ===================== CONSTRUCTOR =====================

  CreateTicketController({required bool isAuthenticated}) {
    isAuth.value = isAuthenticated;

    regionList.assignAll([
      RegionModel(name: "NORTH"),
      RegionModel(name: "SOUTH"),
      RegionModel(name: "EAST"),
      RegionModel(name: "WEST"),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    getIssueList();
  }

  /// ===================== USER DATA =====================

  Future<void> loadUserData() async {
    try {
      final userdata =
          await AndroidOperationsService.getData("UserDetailL_LocalData");

      if (userdata == null || userdata.isEmpty) return;

      final userDetail = UserResModel.fromJson(jsonDecode(userdata));

      createModel.value = CreateTicketModel(
        applicationType: "Windows",
        workshop: userDetail.profile?.workshopName ?? '',
        region: userDetail.profile?.workshopRegion ?? '',
      );
    } catch (e) {
      debugPrint("User load error: $e");
    }
  }

  /// ===================== REGION =====================

  void selectRegion(RegionModel model) {
    selectedRegion.value = model;

    createModel.update((val) {
      val?.region = model.name;
    });
  }

  /// ===================== ISSUE =====================

  void selectIssue(IssueResultModel model) {
    selectedIssue.value = model;

    createModel.update((val) {
      val?.ticketIssue = model.id;
    });

    /// Fetch related issues
    getRelatedIssueList(model.id ?? '');

    /// Reset UI
    showRelatedIssue.value = true;
    selectedRelatedIssue.value = null;
    fileName.value = "";

    /// Safe checks
    final issueType = model.issueRelated ?? "";

    showApkField.value = issueType.contains("Application");
    showDongleField.value = issueType.contains("Dongle");

    /// Reset dependent fields
    createModel.update((val) {
      val?.ticketIssueChoicesUuid = null;
      val?.invoiceDate = null;
      val?.invoiceNo = null;
      val?.attachment = null;
      val?.fileName = null;
      val?.serialNumber = null;
      val?.comment = null;
    });
  }

  /// ===================== RELATED ISSUE =====================

  void selectRelatedIssue(RelatedIssueResultModel model) {
    selectedRelatedIssue.value = model;

    createModel.update((val) {
      val?.ticketIssueChoicesUuid = model.id;
    });
  }

  /// ===================== FILE PICK =====================

  Future<void> pickFile() async {
    try {
      final result = await filePicker.pickFileAsync();

      if (result == null) return;

      fileName.value = result.fileName;

      createModel.update((val) {
        val?.fileName = result.fileName;
        val?.attachment = result.fileContent as Uint8List?;
      });
    } catch (e) {
      debugPrint("File pick error: $e");
    }
  }

  /// ===================== CREATE TICKET =====================

  Future<void> addTicket() async {
    final model = createModel.value;

    /// VALIDATION
    if ((model.comment ?? "").isEmpty ||
        (model.ticketIssueChoicesUuid ?? "").isEmpty) {
      Get.snackbar("Alert", "Please fill all required fields");
      return;
    }

    if (!isAuth.value && (model.emailId ?? "").isEmpty) {
      Get.snackbar("Alert", "Email ID is required");
      return;
    }

    try {
      /// LOADER
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      /// PREPARE DATA
      model.marketPlace = "e69a8d32-8411-4e25-9996-a5a28f435456";
      model.user = App.userId.toString();
      model.levelStatus = "Level1";
      model.invoiceDate =
          invoiceDate.value.toIso8601String().split("T").first;

      /// API CALL
      final response = isAuth.value
          ? await services.createTicket(model)
          : await services.createTicketWithoutAuthentication(model);

      Get.back(); // close loader

      /// RESPONSE HANDLING
      if (response.message == "success") {
        await getTicketList();

        Get.snackbar("Success", "Ticket Created");

        Get.back(); // go back
      } else {
        Get.snackbar("Error", response.message ?? "Failed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  /// ===================== API =====================

  Future<void> getIssueList() async {
    try {
      final res = await services.getIssueList();

      if (res.message == "success") {
        issueList.assignAll(res.results ?? []);
      } else {
        Get.snackbar("Error", res.message ?? "Failed");
      }
    } catch (e) {
      debugPrint("Issue API error: $e");
    }
  }

  Future<void> getRelatedIssueList(String type) async {
    try {
      final res = await services.getRelatedIssueList(type);

      if (res.message == "success") {
        relatedIssueList.assignAll(res.results ?? []);
      } else {
        Get.snackbar("Error", res.message ?? "Failed");
      }
    } catch (e) {
      debugPrint("Related issue API error: $e");
    }
  }

  Future<void> getTicketList() async {
    try {
      final res = await services.getTicketList(App.userId);

      if (res.message == "success") {
        await AndroidOperationsService.saveData(
          "GetTicketList",
          jsonEncode(res.toJson()),
        );
      } else {
        Get.snackbar("Error", res.message ?? "Failed");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
