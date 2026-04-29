import 'package:autopeepal/logic/controller/myEsn/serviceRequestController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CloseServiceRequest extends StatelessWidget {
  const CloseServiceRequest({super.key});

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
              child: Image.asset('assets/new/ic_ikonnect.jpg',
                  fit: BoxFit.contain),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: "Search Title or ESN...",
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

          // List of Service Requests
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.filteredRequests.length,
                  itemBuilder: (context, index) {
                    final data = controller.filteredRequests[index];
                    return _buildRequestCard(data, themeColor);
                  },
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        shape: const CircleBorder(),
        onPressed: () {
           Get.toNamed(Routes.addServiceForm);
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildRequestCard(Map<String, String> data, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: themeColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title, Date, and Close Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: themeColor.withOpacity(0.05),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const Spacer(),
                // Close Symbol at Right Side
                // Replace this:

// With this:
              ],
            ),
          ),

          // Body of Card: Details
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("App Code", data['appCode']!),
                _detailRow("ESN", data['esn']!),
                _detailRow("SRN Type", data['srnType']!),
                _detailRow("Date", data['date']!),
                const SizedBox(height: 10),
                const Text("Complaint Details:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  data['complaint']!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF309F93))),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Confirmation Popup Logic
  void _showCloseDialog(String srTitle) {
    Get.defaultDialog(
      title: "Close Session",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Text(
          "Do you want to close this SR session?\n($srTitle)",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      radius: 8,
      // CANCEL Button
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () => Get.back(),
        child: const Text("CANCEL", style: TextStyle(color: Colors.black54)),
      ),
      // OK Button
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF309F93),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          elevation: 0,
        ),
        onPressed: () {
          // Add your close session logic here
          Get.back();
          Get.snackbar(
            "Session Closed",
            "The SR session has been closed successfully.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF309F93),
            colorText: Colors.white,
          );
        },
        child: const Text("OK", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
