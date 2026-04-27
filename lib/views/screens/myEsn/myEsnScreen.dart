import 'package:autopeepal/common_widgets/custom_drawer.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX

class MyESNPage extends StatelessWidget {
  const MyESNPage({super.key});

  final Color themeColor = const Color(0xFF309F93); // Teal theme
  final Color alertColor = Colors.red; // Red for the cross

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyESNDrawer(),

      // --- Added Floating Action Button here ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigates to your GetX Stateless form page
          Get.toNamed(Routes.addServiceForm);
        },
        backgroundColor: themeColor,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      // -----------------------------------------

      body: Column(
        children: [
          // 1. Header: Menu (Left) | Logo (Right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Button (Left)
                  Builder(
                    builder: (context) => IconButton(
                      icon:
                          const Icon(Icons.menu, size: 40, color: Colors.black),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),

                  // iKonnect Logo (Right) - Constrained to prevent over-scaling
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 45, maxWidth: 120),
                    child: Image.asset(
                      'assets/new/ic_ikonnect.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Center Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    text: "Open Service Request",
                    icon: Icons.close_outlined,
                    iconColor: alertColor,
                    onTap: (){
                      Get.toNamed(Routes.openServiceRequest);
                    },
                  ),
                  const SizedBox(height: 25),
                  _buildActionButton(
                    text: "Close Service Request",
                    icon: Icons.check_circle_outline,
                    iconColor: themeColor,
                    onTap: () => print("Close SRN"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required String text,
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: themeColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(icon, color: iconColor, size: 28),
          ],
        ),
      ),
    );
  }
}
