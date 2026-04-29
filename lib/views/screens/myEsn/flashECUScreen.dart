import 'package:autopeepal/logic/controller/myEsn/srnController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import your controller path here

class FlashEcuPage extends StatelessWidget {
  FlashEcuPage({super.key});

  final controller = Get.find<SrnController>();
  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Flash ECU',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/new/ic_ikonnect.jpg', width: 100),
          ),
        ],
      ),
      body: Column(
        children: [
          // Teal Header Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: themeColor,
            child: const Text(
              'BS5-MD1868',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          
          // The Version Item List
          _buildVersionItem('4R1190THT-VD1'),
        ],
      ),
    );
  }

  Widget _buildVersionItem(String versionId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Version Text
          Expanded(
            child: Text(
              versionId,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          
          // Info Icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline, color: themeColor, size: 38),
          ),
          
          const SizedBox(width: 8),

          // Reactive Download Icon
          Obx(() {
            bool isDownloaded = controller.downloadedItems.contains(versionId);
            
            return InkWell(
              onTap: () => controller.toggleDownload(versionId),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: themeColor, width: 1.5),
                    ),
                  ),
                  // Inner Icon
                  Icon(
                    isDownloaded ? Icons.done : Icons.arrow_downward,
                    color: themeColor,
                    size: 24,
                  ),
                  // Small Checkmark Overlay (for the "Downloaded" look in your image)
                  if (isDownloaded)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: Colors.green, size: 14),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}