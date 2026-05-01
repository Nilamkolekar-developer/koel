import 'package:autopeepal/logic/controller/firmwre/writeSSIDController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WriteSsidPassPage extends StatelessWidget {
  WriteSsidPassPage({super.key});

  final controller = Get.put(WriteSsidPassController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // -------- APP BAR --------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Write SSID & Password",
              style: TextStyle(color: Colors.black),
            ),
            Image.asset(
              "assets/ic_iKonnect.png",
              height: 30,
            )
          ],
        ),
      ),

      // -------- BODY --------
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // -------- SSID FIELD --------
            _inputBox(
              controller: controller.ssidController,
              hint: "Enter SSID",
            ),

            const SizedBox(height: 12),

            // -------- PASSWORD FIELD --------
            _inputBox(
              controller: controller.passwordController,
              hint: "Enter Password",
              isPassword: true,
            ),

            const SizedBox(height: 30),

            // -------- SUBMIT BUTTON --------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF309F93), // theme color
                ),
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
    );
  }

  // -------- COMMON INPUT BOX --------
  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF309F93)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
