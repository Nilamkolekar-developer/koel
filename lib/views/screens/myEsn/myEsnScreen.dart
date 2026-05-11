import 'package:autopeepal/logic/controller/myEsn/myEsnController.dart';
import 'package:autopeepal/common_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SrnTypeSelectionPage extends StatelessWidget {
  SrnTypeSelectionPage({super.key});

  final controller = Get.put(Myesncontroller());
  final Color themeColor = const Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // =========================
      // DRAWER
      // =========================
      drawer: MyESNDrawer(),

      // =========================
      // APP BAR (MENU ICON FIXED)
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "My SRN",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/new/ic_ikonnect.jpg',
              height: 28,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
        ],
      ),

      // =========================
      // FLOATING BUTTON
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.createNewSessionCommand();
        },
        backgroundColor: themeColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      // =========================
      // BODY
      // =========================
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: isTablet ? 500 : double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFrameButton(
                        text: "Open Service Request",
                        icon: Icons.close,
                        onTap: () {
                          controller.openSrnCommand();
                        },
                      ),
                      const SizedBox(height: 40),
                      _buildFrameButton(
                        text: "Closed Service Request",
                        icon: Icons.check_circle,
                        onTap: () {
                          controller.closeSrnCommand();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BUTTON WIDGET
  // =========================
  Widget _buildFrameButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: themeColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(icon, color: themeColor, size: 28),
          ],
        ),
      ),
    );
  }
}
