import 'package:autopeepal/logic/controller/myEsn/wifiDevicesController.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WifiDevicesPage extends StatelessWidget {
  WifiDevicesPage({super.key});

  final controller = Get.put(WifiDevicesController());

  static const Color themeColor = Color(0xFF309F93);
  static const Color pageBgColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Expanded(
                child: Text("Wifi Devices",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: Get.context!.isTablet ? 24 : 16))),
            Image.asset('assets/new/ic_iKonnect.jpg',
                height: Get.context!.isTablet ? 44 : 30),
          ],
        ),
      ),
      // body:
      // Obx(() {
      //   // --- ADDED THIS CHECK ---
      //   if (controller.wifiDevicesList.isEmpty) {
      //     return Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           const CircularProgressIndicator(color: themeColor),
      //           const SizedBox(height: 15),
      //           Text("Searching for VCI devices...", style: TextStyle(color: Colors.grey[600])),
      //         ],
      //       ),
      //     );
      //   }

      //   return ListView.separated(
      //     padding: const EdgeInsets.only(bottom: 80),
      //     itemCount: controller.wifiDevicesList.length,
      //     separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
      //     itemBuilder: (context, index) => _buildViewCell(controller.wifiDevicesList[index]),
      //   );
      // }),
      body: Obx(() {
        // ── State 1: Scanning in progress ──────────────────────────────
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: themeColor),
                SizedBox(height: 15),
                Text(
                  "Searching for VCI devices...",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // ── State 2: Scan done but no devices (popup handles it, show hint) ──
        if (controller.scanComplete.value &&
            controller.wifiDevicesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  "No devices found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                  onPressed: () => controller.refreshDeviceList(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Scan Again",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        // ── State 3: Devices found ──────────────────────────────────────
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: controller.wifiDevicesList.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Colors.grey),
          itemBuilder: (_, index) =>
              _buildViewCell(controller.wifiDevicesList[index]),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pageBgColor,
        onPressed: () => controller.addDevice(),
        child: Image.asset('assets/new/ic_add.png'),
      ),
    );
  }

  Widget _buildViewCell(WifiDevicesModel device) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name ?? "Unknown Device",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(device.ip ?? "0.0.0.0",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => controller.connectDongleClicked(device),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor, width: 2),
                ),
                child: Image.asset('assets/new/ic_link.png',
                    height: 25, width: 25, color: themeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
