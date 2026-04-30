import 'package:autopeepal/logic/controller/myEsn/srnController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SrnNumberPage extends StatelessWidget {
  SrnNumberPage({super.key});

  // Theme constants
  static const Color themeColor = Color(0xFF309F93);

  // Dependency Injection
  final controller = Get.put(SrnController());

  final List<_InfoItem> _items = const [
    _InfoItem(label: 'Type', value: 'Water-cooled'),
    _InfoItem(label: 'Rating', value: '250hp'),
    _InfoItem(label: 'Assembly', value: 'NA'),
    _InfoItem(label: 'RPM', value: '1500'),
    _InfoItem(label: 'Application', value: 'PG'),
    _InfoItem(label: 'YOM', value: ''),
    _InfoItem(label: 'No of Injector', value: '6'),
    _InfoItem(label: 'No of Fuel Pump', value: '1'),
    _InfoItem(label: 'No of ECU', value: '2'),
    _InfoItem(label: 'Calibration', value: 'Locked'),
  ];

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
          'SRN Number',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/new/ic_ikonnect.jpg',
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.bolt, color: themeColor),
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Application Code : 6H.8435',
                  style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 6),
              const Text('Engine serial No : 12345678',
                  style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 20),

              // ── 2-Column Grid ──
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 50,
                ),
                itemBuilder: (context, index) => _buildInfoBox(_items[index]),
              ),

              const SizedBox(height: 20),
              _buildDropdown(),

              // ── Reactive Bottom Section ──
              Obx(() => controller.isChannelSelected.value
                  ? _buildDiagnosticSection()
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(_InfoItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: themeColor.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('${item.label} : ${item.value}',
          style: const TextStyle(color: themeColor, fontSize: 14)),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          border: Border.all(color: themeColor),
          borderRadius: BorderRadius.circular(4)),
      child: DropdownButtonHideUnderline(
        child: Obx(() => DropdownButton<String>(
              value: controller.selectedChannel.value,
              isExpanded: true,
              hint: const Text('Select channel'),
              icon: const Icon(Icons.arrow_drop_down,
                  color: themeColor, size: 35),
              items: const [
                DropdownMenuItem(value: 'CAN1(ECU)', child: Text('CAN1(ECU)')),
                DropdownMenuItem(value: 'CAN2(ECU)', child: Text('CAN2(ECU)')),
              ],
              onChanged: (val) => controller.updateChannel(val),
            )),
      ),
    );
  }

  Widget _buildDiagnosticSection() {
    return Column(
      children: [
        const SizedBox(height: 80),
        const Center(
          child: Column(
            children: [
              Text(
                'Start Diagnosis',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'by connecting Dongle via',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),

        // Single Horizontal Line of Icons
        Center(
          child: SingleChildScrollView(
            // Added scroll just in case window is resized very small
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularIcon(Icons.usb, "USB", onTap: () {}),
                const SizedBox(width: 30), // Spacing between icons
                _buildCircularIcon(Icons.wifi, "Wi-Fi", onTap: () {
                  Get.toNamed(Routes.wifiDevicePage);
                }),
                const SizedBox(width: 30),
                _buildCircularIcon(Icons.file_download_outlined, "Flash",
                    onTap: () {
                  Get.toNamed(Routes.flashEcuPage);
                }),
                const SizedBox(width: 30),
                _buildCircularIcon(Icons.edit_outlined, "Logs", onTap: () {}),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),
        const Center(
          child: Text(
            'Download Flash Dataset',
            style: TextStyle(
              color: Colors.black54,
              //  decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIcon(IconData icon, String label,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, // Dynamic navigation
      borderRadius:
          BorderRadius.circular(50), // Visual feedback stays within the circle
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Space around the clickable area
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Prevents taking unnecessary vertical space
          children: [
            Container(
              padding:
                  const EdgeInsets.all(20), // Padding instead of width/height
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 1.5),
              ),
              child: Icon(icon,
                  color: themeColor, size: 30), // Icon size stays consistent
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}
