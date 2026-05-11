import 'package:autopeepal/logic/controller/appFeature/infoPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class InfoPage extends StatelessWidget {
  static const Color themeColor = Color(0xFF309F93);

  final InfoController controller = Get.put(InfoController());

  InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Obx(() => Text(
                    controller.title,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  )),
            ),
            Image.asset('assets/new/ic_iKonnect.jpg', height: 30),
          ],
        ),
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 45),
        child: Column(
          children: [

            // ── Scrollable Content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() => Column(
                      children: [

                        // Description
                        SizedBox(
                          height: 70,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Engine Reaction
                        _buildInfoCard(
                          title: "Engine Reaction",
                          content: controller.effectsOnVehicle,
                        ),

                        const SizedBox(height: 10),

                        // Reason for Failure
                        _buildInfoCard(
                          title: "Reason for the Failure",
                          content: controller.causes,
                        ),
                      ],
                    )),
              ),
            ),

            // ── Start Button ───────────────────────────────────────────────
            Obx(() => controller.hasTreeSet
                ? SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: controller.onStartPressed,
                      child: const Text(
                        "Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  // ── Reusable Info Card ─────────────────────────────────────────────────────
  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 25,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1, thickness: 1),
            const SizedBox(height: 6),
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}