// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MappedPidSelectPage extends StatelessWidget {
//   const MappedPidSelectPage({super.key});

//   static const Color themeColor = Color(0xFF309F93); // StaticResource theme_color
//   static const Color pageBgColor = Color(0xFFF5F5F5);

//   @override
//   Widget build(BuildContext context) {
//     // Controller handling the search logic and list management
//     final controller = Get.put(MappedPidSelectController());

//     return Scaffold(
//       backgroundColor: pageBgColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 "Parameter Select",
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
//             // 1. Search Bar (Grid Row 0)
//             _buildSearchBar(controller),

//             // 2. Horizontal ECU Tabs (Grid Row 1)
//             _buildEcuTabs(controller),

//             // 3. PID Collection List (Grid Row 2)
//             Expanded(child: _buildPidList(controller)),

//             // 4. Continue Button (Grid Row 3)
//             _buildContinueButton(controller),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(MappedPidSelectController controller) {
//     return Container(
//       margin: const EdgeInsets.all(2),
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       height: 55,
//       decoration: BoxDecoration(
//         border: Border.all(color: themeColor),
//         borderRadius: BorderRadius.circular(2),
//       ),
//       child: TextField(
//         onChanged: (val) => controller.searchKey.value = val,
//         decoration: const InputDecoration(
//           hintText: "Search",
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   Widget _buildEcuTabs(MappedPidSelectController controller) {
//     return SizedBox(
//       height: 55,
//       child: Obx(() => ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: controller.ecuList.length,
//             itemBuilder: (context, index) {
//               var ecu = controller.ecuList[index];
//               return Expanded(
//                 // In a horizontal list, we manually manage width or use intrinsic
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 1),
//                   child: Opacity(
//                     opacity: ecu.opacity ?? 1.0,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: themeColor,
//                         shape: const RoundedRectangleBorder(), // CornerRadius 0
//                       ),
//                       onPressed: () => controller.switchTab(ecu),
//                       child: Text(
//                         ecu.ecuName ?? "",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: context.isTablet ? 18 : 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           )),
//     );
//   }

//   Widget _buildPidList(MappedPidSelectController controller) {
//     return Obx(() => ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//           itemCount: controller.mappedPidList.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 15),
//           itemBuilder: (context, index) {
//             var pid = controller.mappedPidList[index];
//             return Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     pid.code ?? "",
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Checkbox(
//                   value: pid.selected,
//                   activeColor: themeColor,
//                   onChanged: (val) {
//                     pid.selected = val ?? false;
//                     controller.onCheckBoxChanged(pid);
//                   },
//                 ),
//               ],
//             );
//           },
//         ));
//   }

//   Widget _buildContinueButton(MappedPidSelectController controller) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red, // Style RedBtnStyle
//           padding: const EdgeInsets.symmetric(vertical: 15),
//         ),
//         onPressed: () => controller.onContinue(),
//         child: const Text(
//           "Continue",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }