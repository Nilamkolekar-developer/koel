import 'package:autopeepal/logic/controller/myEsn/myEsnController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/common_widgets/custom_drawer.dart';

class SrnTypeSelectionPage extends StatelessWidget {
  SrnTypeSelectionPage({super.key});
  final controller = Get.put(Myesncontroller());
  final Color themeColor = const Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // Drawer (like MAUI navigation drawer)
      drawer: MyESNDrawer(),

      // Floating ADD button (same as ImageButton in MAUI)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.addServiceForm),
        backgroundColor: themeColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // TITLE BAR (My SRN + Logo)
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My SRN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Image.asset(
                    'assets/new/ic_ikonnect.jpg',
                    height: 30,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // =========================
            // CENTER BUTTONS
            // =========================
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
                        }
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
  // FRAME STYLE BUTTON (MAUI Frame equivalent)
  // =========================
  Widget _buildFrameButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Center(
      child: InkWell(
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
      ),
    );
  }
}
