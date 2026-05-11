import 'package:autopeepal/logic/controller/appFeature/appfeatureController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFeaturePage extends StatelessWidget {
  AppFeaturePage({super.key});

  final controller = Get.put(AppFeatureController());
  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWindows = screenWidth > 700;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Matches HasBackButton="False"
        title: const Text(
          "Select Function",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset('assets/new/ic_ikonnect.jpg', width: 100),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Dongle Connected Via",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 15),

              // Connected Via Circle (Frame in MAUI)
              GestureDetector(
                onTap: () => controller.disconnectDongle(),
                child: Obx(() => Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.connectedVia.value == "USB"
                            ? Icons.usb
                            : Icons.wifi,
                        color: Colors.white,
                        size: 40,
                      ),
                    )),
              ),

              const SizedBox(height: 10),
              Obx(() => Text(
                    controller.firmwareVersion.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),

              const SizedBox(height: 30),

              // Feature List (CollectionView in MAUI)
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.featureList.length,
                    itemBuilder: (context, index) {
                      final item = controller.featureList[index];
                      return _buildFeatureRow(item, isWindows);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

//   Widget _buildFeatureRow(FeatureItem item, bool isWindows) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: isWindows ? 20 : 12),
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click, // Essential for Windows users
//         child: InkWell(
//           onTap: () => controller.onFeatureTap(item),
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           hoverColor: Colors.transparent,

//           borderRadius: BorderRadius.circular(12),
//           // Visual feedback on hover
//           child: Container(
//             padding: EdgeInsets.all(isWindows ? 8 : 4),
//             child: Row(
//               children: [
//                 // Square Icon Box - EXACT ALIGNMENT, just bigger on Windows
//                 Container(
//                   height: isWindows ? 85 : 62,
//                   width: isWindows ? 85 : 62,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(isWindows ? 12 : 6),
//                     border: Border.all(
//                         color: themeColor, width: isWindows ? 2.0 : 1.2),
//                   ),
//                   // inside your ListView / Row
// child: Container(
//   padding: const EdgeInsets.all(8),
//   decoration: BoxDecoration(
//     color: themeColor.withOpacity(0.1),
//     shape: BoxShape.circle,
//   ),
//   child: Icon(
//     item.image, // item.image is the IconData
//     color: themeColor, 
//     // Responsive sizing based on platform
//     size: isWindows ? 40.0 : 28.0, 
//   ),
// ),
//                 ),
//                 SizedBox(width: isWindows ? 30 : 20),
//                 Expanded(
//                   child: Text(
//                     item.name,
//                     style: TextStyle(
//                       fontSize: isWindows ? 20 : 16,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 // Subtle arrow to fill horizontal space and guide the eye
//                 Icon(Icons.arrow_forward_ios,
//                     color: Colors.black12, size: isWindows ? 20 : 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
Widget _buildFeatureRow(FeatureItem item, bool isWindows) {
  return Padding(
    padding: EdgeInsets.only(bottom: isWindows ? 20 : 12),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => controller.onFeatureItemSelected(item), // Fixed to use onFeatureItemSelected
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isWindows ? 8 : 4),
          child: Row(
            children: [
              // Square Icon Box
              Container(
                height: isWindows ? 85 : 62,
                width: isWindows ? 85 : 62,
                alignment: Alignment.center, // Center the circle inside the square
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isWindows ? 12 : 6),
                  border: Border.all(
                    color: themeColor, 
                    width: isWindows ? 2.0 : 1.2,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon, // FIXED: Changed 'image' to 'icon'
                    color: themeColor,
                    size: isWindows ? 40.0 : 28.0,
                  ),
                ),
              ),
              SizedBox(width: isWindows ? 30 : 20),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: isWindows ? 20 : 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black12,
                size: isWindows ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
