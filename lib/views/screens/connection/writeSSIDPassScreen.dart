
import 'package:autopeepal/logic/controller/connection/writeSSidPssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class WriteSsidPassPage extends StatelessWidget {
  const WriteSsidPassPage({super.key});

  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(WriteSsidPassController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // page_bg_color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Write SSID & Password",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18, // Adjust based on Phone/Tablet logic
              ),
            ),
           
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // VerticalOptions CenterAndExpand
            children: [
              // SSID ENTRY
              _buildCustomEntry(
                label: "Enter SSID",
                controller: controller.ssidController,
              ),
              const SizedBox(height: 10), // Spacing
              
              // PASSWORD ENTRY
              _buildCustomEntry(
                label: "Enter Password",
                controller: controller.passwordController,
                isPassword: true,
              ),
              
              const SizedBox(height: 30), // Empty row height logic

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // CornerRadius 0 logic
                    ),
                  ),
                  onPressed: () => controller.submitCommand(),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Replicates the 'frame' style in MAUI
  Widget _buildCustomEntry({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: themeColor, width: 1),
      ),
      child: TextField(
        cursorColor: Colors.black,
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}