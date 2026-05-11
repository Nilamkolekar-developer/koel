// reconnect_service.dart

import 'package:autopeepal/models/staticData.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/app.dart';

class ReconnectService {

  // ─────────────────────────────────────────────────────────
  // ReconnectDongle  ← exact mirror of C# ReconnectDongle()
  // ─────────────────────────────────────────────────────────
  Future<void> reconnectDongle() async {

    // ← UserDialogs.Instance.ShowLoading("Reconnecting...", MaskType.Black)
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Reconnecting..."),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // ← await Task.Delay(50)
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      String resp = '';

      if (App.connectedVia == "WIFI") {
        // ─────────────────────────────────────────────────
        // WIFI reconnect
        // ← App.WificonnectorService.GetDongleMacID(App.IPAddress, true, true, "00")
        // ─────────────────────────────────────────────────
        resp = await App.wifiConnectorService!.getDongleMacID(
          App.ipAddress,
          true,
          true,
          "00",
        );

        if (resp.isNotEmpty) {
          // ← App.WificonnectorService.SetDongleProperties(...)
          await App.wifiConnectorService!.setDongleProperties(
           protocolName:  StaticData.ecuInfo[0].protocol!.autopeepal,
           txHeaderTemp:  StaticData.ecuInfo[0].txHeader,
           rxHeaderTemp:  StaticData.ecuInfo[0].rxHeader,
          );

          // ← UserDialogs.Instance.AlertAsync("Dongle reconnected successfully", "Success", "Ok")
          _dismissLoading();
          await _showAlert(
            title:   "Success",
            message: "Dongle reconnected successfully",
          );
        } else {
          // ← UserDialogs.Instance.AlertAsync("Failed to connect with dongle.", "Alert", "Ok")
          _dismissLoading();
          await _showAlert(
            title:   "Alert",
            message: "Failed to connect with dongle.",
          );
        }

      } else if (App.connectedVia == "USB") {
        // ─────────────────────────────────────────────────
        // USB reconnect
        // ← MessagingCenter.Send<object, string>(this, "connect_usb", "connection")
        // In Flutter we use GetX event bus or a stream
        // ─────────────────────────────────────────────────
        _sendUsbConnectEvent();

        // ← await App.USBconnectorService.DisconnectUSB()
        await App.usbConnectorService!.disconnectUSB();

        // ← App.USBconnectorService.GetDongleMacID(true, true, "00", false)
        resp = await App.usbConnectorService!.getDongleMacID(
          true,
          true,
          "00",
          false,
        );

        if (resp.isNotEmpty) {
          // ← App.USBconnectorService.SetDongleProperties(...)
          await App.usbConnectorService!.setDongleProperties(
          protocolName:   StaticData.ecuInfo[0].protocol!.autopeepal,
           txHeaderTemp:  StaticData.ecuInfo[0].txHeader,
           rxHeaderTemp:  StaticData.ecuInfo[0].rxHeader,
          );

          // ← UserDialogs.Instance.AlertAsync("Dongle reconnected successfully", "Success", "Ok")
          _dismissLoading();
          await _showAlert(
            title:   "Success",
            message: "Dongle reconnected successfully",
          );
        } else {
          // ← UserDialogs.Instance.AlertAsync("Failed to connect with dongle.", "Alert", "Ok")
          _dismissLoading();
          await _showAlert(
            title:   "Alert",
            message: "Failed to connect with dongle.",
          );
        }
      }

    } catch (ex) {
      debugPrint("ReconnectDongle error: $ex");

      // ← catch: if USB show retry message
      if (App.connectedVia == "USB") {
        _dismissLoading();
        await _showAlert(
          title:   "Failed!",
          message: "Please Try Once Again.",
        );
      }

    } finally {
      // ← UserDialogs.Instance.HideHud()
      _dismissLoading();
    }
  }

  // ─────────────────────────────────────────────────────────
  // MessagingCenter.Send  ← "connect_usb" event
  // In Flutter use GetX event bus
  // ─────────────────────────────────────────────────────────
  void _sendUsbConnectEvent() {
    // Option 1: GetX simple bus
    Get.find<UsbEventBus>().sendConnectUsb("connection");

    // Option 2: If you don't have a bus, just call the service directly
    // App.usbConnectorService.onConnectUsb("connection");
  }

  // ─────────────────────────────────────────────────────────
  // Dismiss loading dialog  ← UserDialogs.Instance.HideHud()
  // ─────────────────────────────────────────────────────────
  void _dismissLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // ─────────────────────────────────────────────────────────
  // Alert  ← UserDialogs.Instance.AlertAsync(msg, title, "Ok")
  // ─────────────────────────────────────────────────────────
  Future<void> _showAlert({
    required String title,
    required String message,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// UsbEventBus  ← MessagingCenter replacement
// Register in main.dart: Get.put(UsbEventBus())
// ─────────────────────────────────────────────────────────────
class UsbEventBus extends GetxController {
  final RxString usbEvent = ''.obs;

  void sendConnectUsb(String message) {
    usbEvent.value = message;
  }
}