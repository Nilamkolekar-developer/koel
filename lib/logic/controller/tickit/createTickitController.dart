import 'dart:convert';
import 'dart:typed_data';

import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/createTickit_model.dart';
import 'package:autopeepal/models/user_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/filePicker_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTicketController extends GetxController {
  final AuthApiService services = AuthApiService();
  final FilePickerService filePicker = FilePickerService();

  /// ===================== STATE =====================
var issueViewVisible = false.obs;
var isBusy = false.obs;
var relatedIssueViewVisible = false.obs;

var selectedIssueName = ''.obs;
var selectedRelatedIssueName = ''.obs;
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
    //getTicketList();
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
  isBusy.value = true;

  try {
    final model = createModel.value;

    if ((model.comment ?? "").isEmpty ||
        (model.ticketIssueChoicesUuid ?? "").isEmpty) {
      Get.snackbar("Alert", "Please fill all required fields");
      return;
    }

    if (!isAuth.value && (model.emailId ?? "").isEmpty) {
      Get.snackbar("Alert", "Email ID is required");
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    model.marketPlace = "e69a8d32-8411-4e25-9996-a5a28f435456";
    model.user = App.userId.toString();
    model.levelStatus = "Level1";
    model.invoiceDate =
        invoiceDate.value.toIso8601String().split("T").first;

    final response = isAuth.value
        ? await services.createTicketWithoutAuthentication(model)
        : await services.createTicket(model);

    Get.back();

    if (response.message == "success") {
      await getTicketList();
      Get.snackbar("Success", "Ticket Created");
      Get.offAllNamed(Routes.tickitList);
    } else {
      Get.snackbar("Error", response.message ?? "Failed");
    }
  } catch (e) {
    Get.back();
    Get.snackbar("Error", e.toString());
  } finally {
    isBusy.value = false;
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
    print("👉 getTicketList() STARTED");

    print("👉 Calling API getTicketList with userId: ${App.userId}");

    final res = await services.getTicketList(App.userId);

    print("👉 API RESPONSE RECEIVED");
    print("👉 Message: ${res.message}");
    print("👉 Count: ${res.count}");
    print("👉 Results length: ${res.results?.length ?? 0}");

    if (res.results != null && res.results!.isNotEmpty) {
      print("👉 First Ticket ID: ${res.results!.first.id}");
      print("👉 First Ticket No: ${res.results!.first.ticketNo}");
    } else {
      print("⚠️ Results is empty");
    }

    if (res.message == "success") {
      print("✔ Saving ticket list to local storage");

      await AndroidOperationsService.saveData(
        "GetTicketList",
        jsonEncode(res.toJson()),
      );

      print("✔ Ticket list saved successfully");
    } else {
      print("❌ API returned error");
      print("👉 Error Message: ${res.message}");

      Get.snackbar("Error", res.message ?? "Failed");
    }
  } catch (e, st) {
    print("❌ Exception in getTicketList()");
    print("👉 Error: $e");
    print("STACKTRACE: $st");

    Get.snackbar("Error", e.toString());
  }
}
}
