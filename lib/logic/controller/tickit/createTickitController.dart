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

  UserModel userRequestModel = UserModel();
  UserResModel userResModel = UserResModel();
  // Context-like navigation (optional)
  BuildContext? context;

  CreateTicketViewModel({required bool isAuthenticated}) {
    isAuth.value = isAuthenticated;

    regionList.assignAll([
      RegionModel(name: "NORTH"),
      RegionModel(name: "SOUTH"),
      RegionModel(name: "EAST"),
      RegionModel(name: "WEST"),
    ]);

    invoiceDate.value = DateTime.now();
    fileName.value = "";

    otherViewVisible.value = false;
    apkViewVisible.value = false;
    dongleViewVisible.value = false;

    getIssueList();
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final userdata =
          await AndroidOperationsService.getData("UserDetailL_LocalData");

      if (userdata == null || userdata.isEmpty) {
        return;
      }

      final userDetail = UserResModel.fromJson(jsonDecode(userdata));

      createModel.value = CreateTicketModel(
        applicationType: "Windows",
        workshop: userDetail.profile?.workshopName ?? '',
        region: userDetail.profile?.workshopRegion,
      );
    } catch (e) {
      print("Error loading user data: $e");
    }
  }
  // ===================== OBSERVABLES =====================

  RxBool isAuth = false.obs;

  Rx<CreateTicketModel> createModel = CreateTicketModel().obs;

  RxList<RegionModel> regionList = <RegionModel>[].obs;
  Rx<RegionModel?> selectedRegion = Rx<RegionModel?>(null);

  RxList<IssueResultModel> issueList = <IssueResultModel>[].obs;
  Rx<IssueResultModel?> selectedIssue = Rx<IssueResultModel?>(null);

  Rx<DateTime> invoiceDate = DateTime.now().obs;

  RxList<RelatedIssueResultModel> relatedIssueList =
      <RelatedIssueResultModel>[].obs;
  Rx<RelatedIssueResultModel?> selectedRelatedIssue =
      Rx<RelatedIssueResultModel?>(null);

  RxString fileName = "".obs;

  RxBool regionViewVisible = false.obs;
  RxBool issueViewVisible = false.obs;
  RxBool relatedIssueViewVisible = false.obs;
  RxBool otherViewVisible = false.obs;
  RxBool apkViewVisible = false.obs;
  RxBool dongleViewVisible = false.obs;

  // ===================== REGION =====================

  void selectRegion(RegionModel model) {
    selectedRegion.value = model;
    createModel.update((val) {
      val?.region = model.name;
    });
    regionViewVisible.value = false;
  }

  // ===================== ISSUE =====================

  void selectIssue(IssueResultModel model) {
    selectedIssue.value = model;

    createModel.update((val) {
      val?.ticketIssue = model.id;
    });

    getRelatedIssueList(model.id ?? '');

    if (model.issueRelated!.contains("Application")) {
      apkViewVisible.value = true;
      dongleViewVisible.value = false;
    } else if (model.issueRelated!.contains("Dongle")) {
      apkViewVisible.value = false;
      dongleViewVisible.value = true;
    }

    createModel.update((val) {
      val?.ticketIssueChoicesUuid = "";
      val?.invoiceDate = "";
      val?.invoiceNo = "";
      val?.attachment = null;
      val?.fileName = "";
      val?.serialNumber = "";
      val?.comment = "";
    });

    selectedRelatedIssue.value = null;
    fileName.value = "";
    otherViewVisible.value = true;
    issueViewVisible.value = false;
  }

  // ===================== RELATED ISSUE =====================

  void selectRelatedIssue(RelatedIssueResultModel model) {
    selectedRelatedIssue.value = model;

    createModel.update((val) {
      val?.ticketIssueChoicesUuid = model.id;
    });

    relatedIssueViewVisible.value = false;
  }

  // ===================== FILE PICK =====================

  Future<void> pickFile() async {
    try {
      final result = await filePicker.pickFileAsync();

      fileName.value = result!.fileName;
      createModel.update((val) {
        val?.fileName = result.fileName;
        val?.attachment = result.fileContent as Uint8List?;
      });
        } catch (e) {
      print("File pick error: $e");
    }
  }

  // ===================== ADD TICKET =====================

  Future<void> addTicket() async {
    final model = createModel.value;

    if (model.comment == null ||
        model.comment!.isEmpty ||
        model.ticketIssueChoicesUuid == null ||
        model.ticketIssueChoicesUuid!.isEmpty) {
      Get.snackbar("Alert", "Please enter all details");
      return;
    }

    if (!isAuth.value && (model.emailId == null || model.emailId!.isEmpty)) {
      Get.snackbar("Alert", "Email ID is required");
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      model.marketPlace = "e69a8d32-8411-4e25-9996-a5a28f435456";
      model.user = App.userId.toString();
      model.levelStatus = "Level1";
      model.invoiceDate = invoiceDate.value.toIso8601String().split("T").first;

      CreateTicketResponseModel response;

      if (isAuth.value) {
        response = await services.createTicket(model);
      } else {
        response = await services.createTicketWithoutAuthentication(model);
      }

      Get.back(); // close loader

      if (response.message == "success") {
        if (isAuth.value) {
          await getTicketList();
        }

        Get.snackbar("Success", "Ticket Created");
        Get.back(); // navigate back
      } else {
        Get.snackbar("Error", response.message ?? "Failed");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  // ===================== API CALLS =====================

  Future<void> getIssueList() async {
    try {
      final res = await services.getIssueList();

      if (res.message == "success") {
        issueList.assignAll(res.results ?? []);
      } else {
        Get.snackbar("Error", res.message ?? "Failed");
      }
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint(e.toString());
    }
  }

  Future<bool> getTicketList() async {
    try {
      final res = await services.getTicketList(App.userId);

      if (res.message == "success") {
        AndroidOperationsService.saveData(
            "GetTicketList", jsonEncode(res.toJson()));
        return true;
      } else {
        Get.snackbar("Error", res.message ?? "Failed");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }
}
