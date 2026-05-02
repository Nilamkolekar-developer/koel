import 'package:autopeepal/logic/controller/dataSync/dataSyncController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyESNDrawer extends StatelessWidget {
   MyESNDrawer({super.key});
final DataSyncController dataSyncController = Get.find();
  // Updated theme color to #309f93
  final Color themeColor = const Color(0xFF309F93); 

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 1. Header Section (Profile info)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              bottom: 20
            ),
            color: themeColor, // Background uses #309f93
            child: Column(
              children: [
                // Circular User Image
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const ClipOval(
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                // User Labels
                const Text(
                  "User Name",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Text(
                  "Software Developer",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Text(
                  "UID: 12345",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // 2. Menu List Section
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem("My SRN", () => Get.toNamed(Routes.esnScreen)),
                _buildMenuItem("Flash File", () => Get.toNamed(Routes.localDatasetFiles)),
                _buildMenuItem("Change Password", () => Get.toNamed('/password')),
                _buildMenuItem("Data Sync", () =>   dataSyncController.btnDataSyncClicked(context)),
                _buildMenuItem("Help & Support", () => Get.toNamed(Routes.tickitList)),
                _buildMenuItem("Logout", () => _handleLogout()),
              ],
            ),
          ),

          // 3. Footer Section (App Version)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "App Version X1.0.1",
              style: TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold, 
                fontSize: 16
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          title: Text(
            title,
            style: TextStyle(
              color: themeColor, // Text uses #309f93
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: Colors.grey),
      ],
    );
  }

  void _handleLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      buttonColor: themeColor, // Dialog button also matches #309f93
      confirmTextColor: Colors.white,
      onConfirm: () => Get.offAllNamed(Routes.loginScreen),
      onCancel: () {Get.back();},
    );
  }
}