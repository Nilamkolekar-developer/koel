import 'package:autopeepal/logic/controller/appFeature/flashEcuPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashEcuPage extends StatelessWidget {
  const FlashEcuPage({super.key});

  static const Color themeColor = Color(0xFF309F93);
  static const Color pageBgColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    // Use Get.find if it was already put in a previous screen, 
    // or keep Get.put if this is where the lifecycle starts.
    final controller = Get.put(FlashEcuController()); 

    return PopScope(
      canPop: false, // We control the pop logic manually
      onPopInvokedWithResult: (didPop, result) {
        // didPop is true if the system already handled the pop
        if (didPop) return;

        // Only allow back if flashing isn't in progress
        if (!controller.timerStatus) {
          // Use WidgetsBinding to avoid '!_debugLocked' error 
          // by scheduling the pop for the next frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Get.back();
            }
          });
        } else {
          // Optional: Show a "Cannot go back during flashing" snackbar
          print("🚫 Back navigation blocked: Flashing in progress");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Row(
            children: [
              const Expanded(
                child: Text("Flash ECU", style: TextStyle(color: Colors.black)),
              ),
              Image.asset(
                'assets/new/ic_iKonnect.jpg',
                height: context.isTablet ? 44 : 30,
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Obx(() => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ECU Name header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: themeColor,
                      alignment: Alignment.center,
                      child: Text(
                        controller.selectedEcu?.ecuName ?? "Unknown ECU",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // File info
                    _infoCard(
                      controller.fileName.value,
                      controller.fileDesc.value,
                    ),
                    const SizedBox(height: 20),

                    // Timer
                    if (controller.timerVisible.value) ...[
                      Center(
                        child: Text(
                          controller.flashTimer.value,
                          style: TextStyle(
                            fontSize: context.isTablet ? 45 : 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Progress
                    if (controller.flashProgressVisible.value) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: controller.progressValue.value,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          controller.flashPercent.value,
                          style: TextStyle(
                            fontSize: context.isTablet ? 35 : 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Animation GIFs
                    if (controller.timerVisible.value) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Image.asset('assets/new/gifPhone.gif', height: 100),
                            Image.asset('assets/new/gifDownArrow.gif', height: 30),
                            Image.asset('assets/new/ic_engine.png', height: 100),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Flash button — pinned at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Visibility(
                visible: controller.isFlashBtnVisible.value,
                child: Container(
                  color: pageBgColor,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      print("🔴 FLASH button tapped");
                      controller.datasetClicked();
                    },
                    child: const Text(
                      "FLASH",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _infoCard(String fileName, String fileDesc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: themeColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(fileName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(fileDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}