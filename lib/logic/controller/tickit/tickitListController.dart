import 'dart:convert';
import 'package:autopeepal/models/tickitList_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/androidOperationservice.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class TicketListViewController extends ChangeNotifier {
   BuildContext? context;

 

  List<TicketResult> _ticketList = [];
  List<TicketResult> get ticketList => _ticketList;

  // Create Ticket (Command equivalent)
  Future<void> createTicket() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      _showLoading();

      await Future.delayed(const Duration(milliseconds: 100));

      Get.toNamed(Routes.tickitScreen, arguments: {'isNew': true});


      Navigator.pop(context!); // remove loading
    } else {
      _showAlert("Alert", "Internet required");
    }
  }

  // Get Ticket List
  Future<void> getTicketList() async {
    try {
      String? jsonData = await AndroidOperationsService. getData("GetTicketList");

      if (jsonData!.isEmpty) return;

      final res = TicketListModel.fromJson(json.decode(jsonData));

      if (res.message == "success") {
        if (res.results != null && res.results!.isNotEmpty) {
          _ticketList = res.results!
            ..sort((a, b) => b.created!.compareTo(a.created!));

          notifyListeners();
        } else {
          _showAlert("Failed", "Ticket list not found.");
        }
      } else {
        _showAlert("Error", res.message ?? "Unknown error");
      }
    } catch (e) {
      print(e);
    }
  }

  // Helpers
  void _showLoading() {
    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context!,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context!),
          )
        ],
      ),
    );
  }
}
