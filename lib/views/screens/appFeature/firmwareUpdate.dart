// import 'package:autopeepal/logic/controller/firmwre/firmwareController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class FirmwareUpdatePage extends StatelessWidget {
//   const FirmwareUpdatePage({super.key});

//   static const Color pageBgColor = Color(0xFFF5F5F5); // page_bg_color

//   @override
//   Widget build(BuildContext context) {
//     // Assuming your controller handles the logic and state
//     final controller = Get.put(FirmwareUpdateController());

//     return Scaffold(
//       backgroundColor: pageBgColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         // NavigationPage.TitleView equivalent
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 "Firmware Update",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: context.isTablet ? 24 : 16,
//                 ),
//               ),
//             ),
//             Image.asset(
//               'assets/new/ic_iKonnect.jpg',
//               height: context.isTablet ? 44 : 30,
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(bottom: 40),
//         child: Column(
//           children: [
//             // Row 0: Firmware Versions (30*)
//             Expanded(
//               flex: 30,
//               child: Obx(() => Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Current Firmware Version : ${controller.currFV.value}",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: context.isTablet ? 20 : 16, // StaticResource equivalent
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "New Firmware Version : ${controller.newFV.value}",
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: context.isTablet ? 20 : 16,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   )),
//             ),

//             // Row 1: Message (30*)
//             Expanded(
//               flex: 30,
//               child: Center(
//                 child: Obx(() => Text(
//                       controller.message.value,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: context.isTablet ? 20 : 16,
//                       ),
//                       textAlign: TextAlign.center,
//                     )),
//               ),
//             ),

//             // Row 2: Update Button (40*)
//             Expanded(
//               flex: 40,
//               child: Center(
//                 child: Obx(() => Visibility(
//                       visible: controller.btnEnable.value,
//                       child: SizedBox(
//                         width: context.isTablet ? 300 : 200,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2196F3), // BlueBtnStyle
//                             padding: const EdgeInsets.symmetric(vertical: 15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           onPressed: () => controller.onUpdateCommand(),
//                           child: Text(
//                             "Update Version",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: context.isTablet ? 20 : 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     )),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:autopeepal/logic/controller/firmwre/firmwareController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmwareUpdatePage extends StatelessWidget {
  const FirmwareUpdatePage({super.key});

  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FirmwareUpdateController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Firmware Update",
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current firmware version
            _infoRow("Current Version", controller.currFV.value),
            const SizedBox(height: 16),

            // Latest firmware version
            _infoRow("Latest Version", controller.newFV.value),
            const SizedBox(height: 16),

            // Status message
            if (controller.message.value.isNotEmpty) ...[
              Text(
                controller.message.value,
                style: TextStyle(
                  color: controller.btnEnable.value
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Spacer(),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: controller.btnEnable.value
                    ? controller.updateClicked
                    : null,
                child: const Text(
                  "Update Firmware",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          Text(value.isEmpty ? "—" : value,
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}