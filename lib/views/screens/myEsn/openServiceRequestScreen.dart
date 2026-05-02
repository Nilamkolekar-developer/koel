// import 'package:autopeepal/logic/controller/myEsn/serviceRequestController.dart';
// import 'package:autopeepal/models/sessionList_model.dart';
// import 'package:autopeepal/routes/routes_string.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class OpenServiceRequestListPage extends StatelessWidget {
//   const OpenServiceRequestListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ServiceRequestListController());
//     const Color themeColor = Color(0xFF309F93);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "My SRN",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxHeight: 40),
//               child: Image.asset(
//                 'assets/new/ic_ikonnect.jpg',
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),

//       body: Column(
//         children: [
//           /// SEARCH BAR
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: TextFormField(
//               onChanged: (val) => controller.searchQuery.value = val,
//               decoration: InputDecoration(
//                 hintText: "Search SRN or ESN...",
//                 prefixIcon: const Icon(Icons.search, color: themeColor),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: themeColor),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: themeColor, width: 2),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//           ),

//           /// LIST
//           Expanded(
//             child: Obx(() {
//               if (controller.filteredRequests.isEmpty) {
//                 return const Center(
//                   child: Text("No Service Requests Found"),
//                 );
//               }

//               return ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 itemCount: controller.filteredRequests.length,
//                 itemBuilder: (context, index) {
//                   final data = controller.filteredRequests[index];

//                   return _buildRequestCard(
//                     data,
//                     themeColor,
//                     onTap: () => Get.toNamed(Routes.srnpage),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),

//       /// FLOATING BUTTON
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: themeColor,
//         shape: const CircleBorder(),
//         onPressed: () => Get.toNamed(Routes.addServiceForm),
//         child: const Icon(Icons.add, color: Colors.white, size: 28),
//       ),
//     );
//   }

//   /// =========================
//   /// CARD UI (FIXED)
//   /// =========================
//   Widget _buildRequestCard(
//     SessionModel data,
//     Color themeColor, {
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: themeColor.withOpacity(0.4)),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// HEADER
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               color: themeColor.withOpacity(0.05),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       data.srNumber ?? '',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 32,
//                     height: 32,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF309F93),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       padding: EdgeInsets.zero,
//                       icon: const Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                       onPressed: () => _showCloseDialog(data.srNumber ?? ''),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// BODY
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _detailRow("SRN Type", data.srType ?? ''),
//                   _detailRow("ESN", data.esn ?? ''),
//                   _detailRow("Genset", data.genset ?? ''),
//                   _detailRow("Date", data.date ?? ''),

//                   const SizedBox(height: 10),

//                   const Text(
//                     "Complaint Details:",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black54,
//                       fontSize: 13,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     data.complaint ?? '',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// =========================
//   /// DETAIL ROW
//   /// =========================
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               "$label:",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF309F93),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// =========================
//   /// DIALOG
//   /// =========================
//   void _showCloseDialog(String srTitle) {
//     Get.defaultDialog(
//       title: "Close Session",
//       content: Text("Do you want to close this SR?\n($srTitle)"),
//       cancel: OutlinedButton(
//         onPressed: () => Get.back(),
//         child: const Text("Cancel"),
//       ),
//       confirm: ElevatedButton(
//         onPressed: () {
//           Get.back();
//           Get.snackbar("Closed", "SR closed successfully");
//         },
//         child: const Text("OK"),
//       ),
//     );
//   }
// }
import 'package:autopeepal/logic/controller/myEsn/serviceRequestController.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenServiceRequestListPage extends StatelessWidget {
  const OpenServiceRequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceRequestListController());
    const Color themeColor = Color(0xFF309F93);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My SRN",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40),
              child: Image.asset(
                'assets/new/ic_ikonnect.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              onChanged: (val) => controller.searchSession(val), // ✅ FIXED
              decoration: InputDecoration(
                hintText: "Search SRN or ESN...",
                prefixIcon: const Icon(Icons.search, color: themeColor),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: themeColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: themeColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          /// LIST
         
         Expanded(
  child: Obx(() {
    if (controller.sessionList.isEmpty) {
      return const Center(
        child: Text("No Service Requests Found"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: controller.sessionList.length,
      itemBuilder: (context, index) {
        final data = controller.sessionList[index];

        return _buildRequestCard(
          data,
          themeColor,
          onTap: () => Get.toNamed(Routes.srnpage),

          // IMPORTANT FIX
          onClose: () => controller.closeSessionCommand(data),
        );
      },
    );
  }),
),
        ],
      ),

      /// FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed(Routes.addServiceForm),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  /// =========================
  /// CARD UI
  /// =========================
  Widget _buildRequestCard(
    SessionModel data,
    Color themeColor, {
    required VoidCallback onTap,
    required VoidCallback onClose,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: themeColor.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: themeColor.withOpacity(0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      data.srNumber ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  /// CLOSE BUTTON
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF309F93),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: onClose, // ✅ FIXED
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("SRN Type", data.srType ?? ''),
                  _detailRow("ESN", data.esn ?? ''),
                  _detailRow("Genset", data.genset ?? ''),
                  _detailRow("Date", data.date ?? ''),

                  const SizedBox(height: 10),

                  const Text(
                    "Complaint Details:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    data.complaint ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DETAIL ROW
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF309F93),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}