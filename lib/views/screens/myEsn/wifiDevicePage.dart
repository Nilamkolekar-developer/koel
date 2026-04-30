// import 'package:autopeepal/logic/controller/myEsn/wifiDevicesController.dart';
// import 'package:autopeepal/models/wifiDevice_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // Import your controller path

// class WifiDevicesPage extends StatelessWidget {
//   WifiDevicesPage({super.key});

//   final controller = Get.put(
//       WifiDevicesController()); // Success: It creates the controller and saves it
//   static const Color themeColor = Color(0xFF309F93);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Wifi Devices',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Image.asset('assets/new/ic_ikonnect.jpg', width: 100),
//           ),
//         ],
//       ),
//       body: Obx(() => ListView.separated(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             itemCount: controller.wifiDevicesList.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final device = controller.wifiDevicesList[index];
//               return _buildDeviceTile(device);
//             },
//           )),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: themeColor,
//         onPressed: () {
//           // Logic to scan for new Wi-Fi devices
//           controller.startNewScan();
//         },
//         child: const Icon(Icons.add, color: Colors.white, size: 30),
//       ),
//     );
//   }

//   Widget _buildDeviceTile(WifiDevicesModel device) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 4,
//             blurRadius: 2,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             // Left side: Device Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     device.name ?? 'Unknown Device',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     device.ip ?? '0.0.0.0',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Right side: Interactive Image Asset
//             Obx(() {

//               return GestureDetector(
//                 onTap: () => controller.connectToDevice(device),
//                 child: Obx(() {
//                   // Check connection status from controller
//                   bool isLinked = controller.linkedDeviceIp.value == device.ip;

//                   return Container(
//                     // Padding determines the size of the circle relative to the image
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       // Fills the circle with themeColor when linked, otherwise a light grey
//                       color: isLinked ? themeColor : Colors.grey.shade100,
//                       border: Border.all(
//                         color: isLinked ? themeColor : Colors.grey.shade300,
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Image.asset(
//                       'assets/new/ic_link.png',
//                       // Icon turns white when the background is filled with themeColor
//                       color: isLinked ? Colors.white : themeColor,
//                       width: 24, // Optional: keeps the icon scale consistent
//                       height: 24,
//                       errorBuilder: (context, error, stackTrace) => Icon(
//                         Icons.link,
//                         color: isLinked ? Colors.white : themeColor,
//                       ),
//                     ),
//                   );
//                 }),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:autopeepal/logic/controller/myEsn/wifiDevicesController.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WifiDevicesPage extends StatelessWidget {
  WifiDevicesPage({super.key});

  final controller = Get.put(WifiDevicesController());
  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly off-white for better card contrast
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Subtle shadow for Windows depth
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
          tooltip: 'Back', // Friendly for desktop users
        ),
        title: const Text(
          'Wifi Devices',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/new/ic_ikonnect.jpg', width: 100, fit: BoxFit.contain),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.wifiDevicesList.isEmpty) {
          return const Center(child: Text("No devices found. Click '+' to scan."));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.wifiDevicesList.length,
          itemBuilder: (context, index) => _buildDeviceCard(controller.wifiDevicesList[index]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        tooltip: 'Scan for devices',
        onPressed: () => controller.startNewScan(),
        child: const Icon(Icons.refresh, color: Colors.white, size: 28), // 'Refresh' is clearer than '+' for scanning
      ),
    );
  }

  Widget _buildDeviceCard(WifiDevicesModel device) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left side: Device Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name ?? 'VCI Device',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.wifi, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        device.ip ?? '192.168.1.1',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side: Interactive Link Button
            Obx(() {
              bool isLinked = controller.linkedDeviceIp.value == device.ip;
              return Tooltip(
                message: isLinked ? 'Connected' : 'Click to Connect',
                child: InkWell(
                  onTap: () => controller.connectToDevice(device),
                  borderRadius: BorderRadius.circular(50), // Ensures ripple is circular
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLinked ? themeColor : Colors.grey.shade100,
                      border: Border.all(
                        color: isLinked ? themeColor : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Image.asset(
                      'assets/new/ic_link.png',
                      color: isLinked ? Colors.white : themeColor,
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        isLinked ? Icons.link_off : Icons.link,
                        color: isLinked ? Colors.white : themeColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}