import 'dart:convert';

import 'package:autopeepal/models/tickitList_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketListViewController extends GetxController {
  var ticketList = <TicketResult>[].obs;

  @override
  void onInit() {
    super.onInit();
    getTicketList();
  }

  Future<void> createTicket() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      await Future.delayed(const Duration(milliseconds: 100));

      Get.back(); // close loader
      Get.toNamed(Routes.tickitScreen, arguments: {'isNew': true});
    } else {
      Get.snackbar("Alert", "Internet required");
    }
  }

  Future<void> getTicketList() async {
    try {
      String? jsonData =
          await AndroidOperationsService.getData("GetTicketList");

      if (jsonData == null || jsonData.isEmpty) return;

      final res = TicketListModel.fromJson(json.decode(jsonData));

      if (res.message == "success") {
        if (res.results != null && res.results!.isNotEmpty) {
          ticketList.value = res.results!
            ..sort((a, b) =>
                (b.created ?? DateTime(1970))
                    .compareTo(a.created ?? DateTime(1970)));
        } else {
          Get.snackbar("Failed", "Ticket list not found");
        }
      } else {
        Get.snackbar("Error", res.message ?? "Unknown error");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
