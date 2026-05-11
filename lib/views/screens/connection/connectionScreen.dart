// // import 'package:autopeepal/logic/controller/connection/connectionController.dart';
// // import 'package:autopeepal/routes/routes_string.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';

// // class ConnectionPage extends StatelessWidget {
// //   ConnectionPage({super.key});

// //   static const Color themeColor = Color(0xFF309F93);

// //   // IMPORTANT: do NOT create controller here again
// //   final controller = Get.put(ConnectionController());

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: _appBar(),
// //       body: Obx(() {
// //         final session = controller.session;
// //         final model = controller.model;

// //         // SAFE GUARD (prevents crash)
// //         if (session == null || model == null) {
// //           return const Center(
// //             child: CircularProgressIndicator(),
// //           );
// //         }

// //         final variant = session.variant;

// //         return SingleChildScrollView(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // ================= HEADER =================
// //               Text(
// //                 'Application Code : ${variant?.variantCode ?? "-"}',
// //                 style: const TextStyle(fontSize: 16),
// //               ),
// //               const SizedBox(height: 6),

// //               Text(
// //                 'Engine Serial No : ${session.esn ?? "-"}',
// //                 style: const TextStyle(fontSize: 16),
// //               ),

// //               const SizedBox(height: 20),

// //               // ================= INFO GRID =================
// //               _infoGrid(variant),

// //               const SizedBox(height: 20),

// //               // ================= CHANNEL DROPDOWN =================
// //               _channelDropdown(),

// //               const SizedBox(height: 25),

// //               // ================= DIAGNOSTIC SECTION =================
// //               if (controller.selectedChannel.value != null)
// //                 _diagnosticSection(),
// //             ],
// //           ),
// //         );
// //       }),
// //     );
// //   }

// //   // ================= APP BAR =================
// //   AppBar _appBar() {
// //     return AppBar(
// //       backgroundColor: Colors.white,
// //       elevation: 0,
// //       leading: IconButton(
// //         icon: const Icon(Icons.arrow_back, color: Colors.black),
// //         onPressed: () => Get.back(),
// //       ),
// //       title: const Text(
// //         "Connection",
// //         style: TextStyle(color: Colors.black),
// //       ),
// //       actions: [
// //         Padding(
// //           padding: const EdgeInsets.only(right: 20),
// //           child: ConstrainedBox(
// //             constraints: const BoxConstraints(maxHeight: 40),
// //             child: Image.asset(
// //               'assets/new/ic_ikonnect.jpg',
// //               fit: BoxFit.contain,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ================= INFO GRID =================
// //   Widget _infoGrid(variant) {
// //     final items = [
// //       ("Type", variant?.typeName),
// //       ("Rating", variant?.rating),
// //       ("Assembly", variant?.assemblyNo),
// //       ("RPM", variant?.rpm),

// //       ("Application", variant?.applicationName),
// //       ("YOM","" ),
// //       ("No of Injector", variant?.noOfInjectors),
// //       ("No of Fuel Pump", variant?.noOfFip),
// //       ("No of ECU", variant?.subModel?.ecus?.length),
// //       ("Calibration", variant?.calibration),
// //     ];

// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       itemCount: items.length,
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 2,
// //         mainAxisExtent: 55,
// //         crossAxisSpacing: 10,
// //         mainAxisSpacing: 10,
// //       ),
// //       itemBuilder: (context, index) {
// //         final item = items[index];

// //         return Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 10),
// //           alignment: Alignment.centerLeft,
// //           decoration: BoxDecoration(
// //             border: Border.all(color: themeColor.withOpacity(0.6)),
// //             borderRadius: BorderRadius.circular(5),
// //           ),
// //           child: Text(
// //             "${item.$1} : ${item.$2 ?? "-"}",
// //             style: const TextStyle(
// //               fontSize: 13,
// //               color: themeColor,
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // ================= CHANNEL DROPDOWN =================
// //   Widget _channelDropdown() {
// //     return Obx(() {
// //       if (controller.channelList.isEmpty) {
// //         return const Text(
// //           "No Channels Available",
// //           style: TextStyle(color: Colors.red),
// //         );
// //       }

// //       return Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: themeColor),
// //           borderRadius: BorderRadius.circular(5),
// //         ),
// //         child: DropdownButtonHideUnderline(
// //           child: DropdownButton<String>(
// //             value: controller.selectedChannel.value?.itemName,
// //             isExpanded: true,
// //             hint: const Text("Select Channel"),
// //             items: controller.channelList.map((channel) {
// //               return DropdownMenuItem(
// //                 value: channel.itemName,
// //                 child: Text(channel.itemName ?? "-"),
// //               );
// //             }).toList(),
// //             onChanged: (value) {
// //               if (value == null) return;

// //               final selected = controller.channelList.firstWhere(
// //                 (e) => e.itemName == value,
// //               );

// //               controller.selectChannel(selected);
// //             },
// //           ),
// //         ),
// //       );
// //     });
// //   }

// //   // ================= DIAGNOSTIC SECTION =================
// //   Widget _diagnosticSection() {
// //     return Column(
// //       children: [
// //         const SizedBox(height: 40),
// //         const Text(
// //           "Start Diagnosis",
// //           style: TextStyle(
// //             fontSize: 18,
// //             fontWeight: FontWeight.w500,
// //             color: Colors.black87,
// //           ),
// //         ),
// //         const SizedBox(height: 30),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //           children: [
// //             _icon(Icons.usb, "USB",onTap: (){
// //               controller.connVaiUsbClicked();
// //             }),
// //             _icon(Icons.wifi, "WiFi", onTap: () {
// //              controller.connVaiWifiClicked();
// //             }),
// //             _icon(Icons.download, "Flash", onTap: () {
// //               controller.onDownloadFilesClicked();
// //             }),
// //             _icon(Icons.edit, "logs",onTap: (){
// //               controller.onWriteClicked();
// //             }),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   // ================= ICON WIDGET =================
// //   Widget _icon(IconData icon, String label, {VoidCallback? onTap}) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Column(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(18),
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               border: Border.all(color: themeColor),
// //             ),
// //             child: Icon(
// //               icon,
// //               color: themeColor,
// //               size: 35,
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           // Text(label),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:autopeepal/logic/controller/connection/connectionController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ConnectionPage extends StatelessWidget {
//   ConnectionPage({super.key});

//   static const Color themeColor = Color(0xFF309F93);

//   // Use Get.put if this is the first time the controller is initialized
//   final controller = Get.put(ConnectionController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _appBar(),
//       body: Obx(() {
//         final session = controller.session;
//         final model = controller.model;

//         // SAFE GUARD
//         if (session == null || model == null) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final variant = session.variant;

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ================= HEADER INFO =================
//               Text(
//                 'Application Code : ${variant?.variantCode ?? "-"}',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Engine Serial No : ${session.esn ?? "-"}',
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 20),

//               // ================= INFO GRID =================
//               _infoGrid(variant),
//               const SizedBox(height: 30),

//               // ================= CHANNEL SELECTION =================
//               const Text(
//                 "Select Communication Channel",
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
//               ),
//               const SizedBox(height: 8),
//               _channelDropdown(),

//               const SizedBox(height: 25),

//               // ================= CONDITIONAL DIAGNOSTIC SECTION =================
//               // LOGIC: Show icons ONLY IF selectedChannel is NULL
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 400),
//                 child: controller.selectedChannel.value == null
//                     ? _diagnosticSection()
//                     : _selectedChannelMessage(), // Shows message when icons disappear
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   // ================= APP BAR =================
//   AppBar _appBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Get.back(),
//       ),
//       title: const Text("Connection", style: TextStyle(color: Colors.black)),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 20),
//           child: Image.asset('assets/new/ic_ikonnect.jpg', width: 80, fit: BoxFit.contain),
//         ),
//       ],
//     );
//   }

//   // ================= INFO GRID =================
//   Widget _infoGrid(variant) {
//     final items = [
//       ("Type", variant?.typeName),
//       ("Rating", variant?.rating),
//       ("Assembly", variant?.assemblyNo),
//       ("RPM", variant?.rpm),
//       ("Application", variant?.applicationName),
//       ("YOM", "-"),
//       ("No of Injector", variant?.noOfInjectors),
//       ("No of Fuel Pump", variant?.noOfFip),
//       ("No of ECU", variant?.subModel?.ecus?.length?.toString()),
//       ("Calibration", variant?.calibration),
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisExtent: 50,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//       ),
//       itemBuilder: (context, index) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           decoration: BoxDecoration(
//             border: Border.all(color: themeColor.withOpacity(0.3)),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               "${items[index].$1}: ${items[index].$2 ?? "-"}",
//               style: const TextStyle(fontSize: 12, color: themeColor, fontWeight: FontWeight.w600),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ================= CHANNEL DROPDOWN =================
//   Widget _channelDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         border: Border.all(color: themeColor),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: controller.selectedChannel.value?.itemName,
//           isExpanded: true,
//           hint: const Text("Tap to select channel..."),
//           items: controller.channelList.map((channel) {
//             return DropdownMenuItem(
//               value: channel.itemName,
//               child: Text(channel.itemName ?? "-"),
//             );
//           }).toList(),
//           onChanged: (value) {
//             final selected = controller.channelList.firstWhere((e) => e.itemName == value);
//             controller.selectChannel(selected);
//           },
//         ),
//       ),
//     );
//   }

//   // ================= DIAGNOSTIC SECTION (ICONS) =================
//   Widget _diagnosticSection() {
//     return Column(
//       key: const ValueKey("diagnostic_icons"),
//       children: [
//         const Divider(),
//         const SizedBox(height: 20),
//         const Text(
//           "Quick Diagnostics",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 25),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _icon(Icons.usb, "USB", onTap: () => controller.connVaiUsbClicked()),
//             _icon(Icons.wifi, "WiFi", onTap: () => controller.connVaiWifiClicked()),
//             _icon(Icons.download, "Flash", onTap: () => controller.onDownloadFilesClicked()),
//             _icon(Icons.history_edu, "Logs", onTap: () => controller.onWriteClicked()),
//           ],
//         ),
//       ],
//     );
//   }

//   // ================= SELECTED MESSAGE =================
//   Widget _selectedChannelMessage() {
//     return Container(
//       key: const ValueKey("selected_msg"),
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: themeColor.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.check_circle, color: themeColor),
//           SizedBox(width: 10),
//           Text(
//             "Channel Fixed. Ready to connect.",
//             style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= ICON WIDGET =================
//   Widget _icon(IconData icon, String label, {VoidCallback? onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(50),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: themeColor.withOpacity(0.1),
//               border: Border.all(color: themeColor),
//             ),
//             child: Icon(icon, color: themeColor, size: 30),
//           ),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
// }
import 'package:autopeepal/logic/controller/connection/connectionController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionPage extends StatelessWidget {
  ConnectionPage({super.key});

  final controller = Get.put(ConnectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: _appBar(),
      body: Obx(() {
        final session = controller.session;
        final model = controller.model;

        if (session == null || model == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final variant = session.variant;

        return Stack(
          children: [
            // ── Main scrollable content ──
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header labels ──
                  Text(
                    'Application Code : ${variant?.variantCode ?? "-"}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Engine Serial No : ${session.esn ?? "-"}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  // ── Info Grid ──
                  _infoGrid(variant),
                  const SizedBox(height: 12),

                  // ── Channel Dropdown ──
                  if (controller.channelListVisible.value) _channelDropdown(),

                  const SizedBox(height: 20),

                  // ── Diagnostic Section ──
                  if (controller.otherPropertiesVisible.value)
                    _diagnosticSection(),
                ],
              ),
            ),

            // ── Channel Popup Overlay ──
            if (controller.channelPopupVisible.value) _channelPopup(),
          ],
        );
      }),
    );
  }

  // ═══════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════
  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.pagebgColor,
      elevation: 0,
      title: const Text(
        'SRN Number',
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Image.asset(
            'assets/new/ic_iKonnect.jpg',
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // INFO GRID (2 columns, 5 rows)
  // ═══════════════════════════════════════════
  Widget _infoGrid(variant) {
    final items = [
      ("Type", variant?.typeName),
      ("Rating", variant?.rating),
      ("Assembly No", variant?.assemblyNo),
      ("RPM", variant?.rpm),
      ("Application", variant?.applicationName),
      ("YOM", "-"),
      ("No of Injectors", variant?.noOfInjectors),
      ("No of Fuel Pump", variant?.noOfFip),
      ("No of ECU", variant?.subModel?.ecus?.length?.toString()),
      ("Calibration", variant?.calibration),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 42,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.themeColor),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            "${items[index].$1} : ${items[index].$2 ?? "-"}",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.themeColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // CHANNEL DROPDOWN (tappable row)
  // ═══════════════════════════════════════════
  Widget _channelDropdown() {
    return Obx(() => GestureDetector(
          onTap: () => controller.openPopup(),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.themeColor),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.selectedChannel.value?.itemName ??
                        'Select channel',
                    style: TextStyle(
                      color: controller.selectedChannel.value != null
                          ? Colors.black87
                          : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: AppColors.themeColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                const SizedBox(width: 8),
                Image.asset('assets/new/ic_drop_down.png',
                    width: 20, height: 20),
              ],
            ),
          ),
        ));
  }

  // ═══════════════════════════════════════════
  // DIAGNOSTIC SECTION
  // ═══════════════════════════════════════════
  Widget _diagnosticSection() {
    return Column(
      children: [
        // "Start Diagnosis" label
        const Text(
          'Start Diagnosis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Text(
          'by connecting Dongle via',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),

        // USB / WiFi row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _circleIcon('assets/new/ic_usb.png',
                onTap: controller.connVaiUsbClicked),
            _circleIcon('assets/new/ic_wifi.png',
                onTap: controller.connVaiWifiClicked),
          ],
        ),
        const SizedBox(height: 16),

        // Download / Edit row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _circleIcon('assets/new/ic_download.png',
                onTap: controller.onDownloadFilesClicked),
            _circleIcon('assets/new/ic_edit.png',
                onTap: controller.onWriteClicked),
          ],
        ),
        const SizedBox(height: 16),

        // Bottom message label
        Obx(() => Text(
              controller.bottomMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.themeColor,
                fontWeight: FontWeight.w500,
              ),
            )),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // CIRCLE ICON BUTTON
  // ═══════════════════════════════════════════
  Widget _circleIcon(String asset, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.themeColor, width: 1.5),
        ),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // CHANNEL POPUP OVERLAY
  // ═══════════════════════════════════════════
  Widget _channelPopup() {
    return GestureDetector(
      onTap: () => controller.closePopup(),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent dismiss when tapping inside
            child: Container(
              width: 250,
              constraints: const BoxConstraints(maxHeight: 350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.themeColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Select Channel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Channel list
                  Flexible(
                    child: Obx(() => ListView.separated(
                          shrinkWrap: true,
                          itemCount: controller.channelList.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final channel = controller.channelList[index];
                            return InkWell(
                              onTap: () => controller.selectChannel(channel),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Text(
                                  channel.itemName ?? '-',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
