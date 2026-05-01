import 'package:autopeepal/logic/controller/firmwre/firmwareController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmwareUpdatePage extends StatelessWidget {
  FirmwareUpdatePage({super.key});

  final controller = Get.put(FirmwareUpdateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Firmware Update",
              style: TextStyle(color: Colors.black),
            ),
            Image.asset(
              "assets/ic_iKonnect.png",
              height: 30,
            )
          ],
        ),
      ),

      // ---------- BODY ----------
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // -------- TOP SECTION --------
              Column(
                children: [
                  Text(
                    "Current Firmware Version : ${controller.currFV.value}",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "New Firmware Version : ${controller.newFV.value}",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // -------- MESSAGE --------
              Text(
                controller.message.value,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              // -------- BUTTON --------
              controller.btnEnable.value
                  ? ElevatedButton(
                      onPressed: controller.updateFirmware,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        "Update Version",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      }),
    );
  }
}
