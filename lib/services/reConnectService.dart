import 'dart:async';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:flutter/material.dart';

class ReconnectService {
  Future<void> reconnectDongle(BuildContext context) async {
    try {
      // Show loading dialog
      _showLoading(context, "Reconnecting...");

      await Future.delayed(const Duration(milliseconds: 50));

      String resp = "";

      if (App.connectedVia == "WIFI") {
        resp = await App.wifiConnectorService!.getDongleMacID(
          App.ipAddress,
          true,
          true,
          "00",
        );

        if (resp.isNotEmpty) {
          await App.wifiConnectorService!.setDongleProperties(
            StaticData.ecuInfo[0].protocol!.autopeepal,
            StaticData.ecuInfo[0].txHeader,
            StaticData.ecuInfo[0].rxHeader,
          );

          _showAlert(context, "Success", "Dongle reconnected successfully");
        } else {
          _showAlert(context, "Alert", "Failed to connect with dongle.");
        }
      } else if (App.connectedVia == "USB") {
        // Simulating MessagingCenter
       // EventBus.instance.fire("connect_usb");

      //  await App.usbConnectorService.disconnectUSB();

        // resp = await App.usbConnectorService.getDongleMacID(
        //   true,
        //   true,
        //   "00",
        //   false,
        // );

        if (resp.isNotEmpty) {
          // await App.usbConnectorService.setDongleProperties(
          //   StaticData.ecuInfo[0].protocol!.autopeepal,
          //   StaticData.ecuInfo[0].txHeader,
          //   StaticData.ecuInfo[0].rxHeader,
          // );

          _showAlert(context, "Success", "Dongle reconnected successfully");
        } else {
          _showAlert(context, "Alert", "Failed to connect with dongle.");
        }
      }
    } catch (e) {
      if (App.connectedVia == "USB") {
        _showAlert(context, "Failed!", "Please Try Once Again.");
      }
    } finally {
      Navigator.pop(context); // Hide loading
    }
  }

  // ---------------- UI Helpers ----------------

  void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}