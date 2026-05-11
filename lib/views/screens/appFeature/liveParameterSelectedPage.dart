import 'package:autopeepal/logic/controller/appFeature/liveParameterSelectedpageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveParameterSelectedPage extends StatelessWidget {
  const LiveParameterSelectedPage({super.key});

  static const Color themeColor = Color(0xFF309F93); // theme_color
  static const Color pageBgColor = Color(0xFFF5F5F5); // page_bg_color
  static const Color borderColor = Color(0xFF1C273A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveParameterSelectedController());

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Live Parameters",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.isTablet ? 24 : 16,
                ),
              ),
            ),
            Image.asset(
              'assets/new/ic_iKonnect.jpg',
              height: context.isTablet ? 44 : 30,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. MAIN CONTENT (Table and Buttons)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 45),
            child: Column(
              children: [
                // DATA TABLE
                Expanded(
                  child: Column(
                    children: [
                      _buildTableHeader(context),
                      Expanded(child: _buildParameterList(controller)),
                    ],
                  ),
                ),

                // BOTTOM CONTROL BUTTONS (Row 1)
                _buildControlBar(context, controller),
              ],
            ),
          ),

          // 2. SAVE FILE POPUP (IsVisible="{Binding IsSavePopupVisible}")
          Obx(() => controller.isSavePopupVisible.value
              ? _buildSavePopup(context, controller)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _tableCell("Parameter", flex: 4, isHeader: true),
            _verticalDivider(),
            _tableCell("Value", width: context.isTablet ? 100 : 40, isHeader: true),
            _verticalDivider(),
            _tableCell("Unit", width: context.isTablet ? 100 : 35, isHeader: true),
            _verticalDivider(),
            _tableCell("Min", width: context.isTablet ? 100 : 45, isHeader: true),
            _verticalDivider(),
            _tableCell("Max", width: context.isTablet ? 100 : 40, isHeader: true),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterList(LiveParameterSelectedController controller) {
    return Obx(() => ListView.builder(
          itemCount: controller.selectedParameterList.length,
          itemBuilder: (context, index) {
            final group = controller.selectedParameterList[index];
            return Column(
              children: group.piCodeVariable!.map<Widget>((item) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(color: borderColor),
                      right: BorderSide(color: borderColor),
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _tableCell(item.shortName ?? "", flex: 4),
                        _verticalDivider(),
                        _tableCell(item.showResolution ?? "", width: context.isTablet ? 100 : 40),
                        _verticalDivider(),
                        _tableCell(item.unit ?? "", width: context.isTablet ? 100 : 35),
                        _verticalDivider(),
                        _tableCell(item.minVal ?? "", width: context.isTablet ? 100 : 45),
                        _verticalDivider(),
                        _tableCell(item.maxVal ?? "", width: context.isTablet ? 100 : 40),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ));
  }

  Widget _buildControlBar(BuildContext context, LiveParameterSelectedController controller) {
    return Container(
      height: context.isTablet ? 150 : 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _iconButton(context, "Play", "ic_play", controller.pidPlayPauseClicked),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text(controller.recordingTimerText.value, style: const TextStyle(fontSize: 12))),
              _iconButton(context, "Record", "ic_recording", controller.pidRecordingClicked),
            ],
          ),
          _iconButton(context, "Snapshot", "ic_snapshot", controller.pidSnapshotClicked),
        ],
      ),
    );
  }

  // Widget _buildSavePopup(BuildContext context, LiveParameterSelectedController controller) {
  //   return Stack(
  //     children: [
  //       Container(color: Colors.black.withOpacity(0.6)),
  //       Center(
  //         child: Container(
  //           margin: EdgeInsets.symmetric(horizontal: context.isTablet ? 80 : 30),
  //           color: Colors.white,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 height: 45,
  //                 width: double.infinity,
  //                 color: themeColor,
  //                 alignment: Alignment.center,
  //                 child: const Text("File Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   children: [
  //                     const Text("Save recording as", style: TextStyle(fontSize: 17, color: Colors.black)),
  //                     const SizedBox(height: 10),
  //                     TextField(
  //                       textAlign: TextAlign.center,
  //                       decoration: const InputDecoration(
  //                         hintText: "Name your recording",
  //                         focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor, width: 2)),
  //                       ),
  //                       onChanged: (val) => controller.fileName.value = val,
  //                     ),
  //                     const SizedBox(height: 25),
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(backgroundColor: themeColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10)),
  //                       onPressed: () => controller.saveFile(),
  //                       child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildSavePopup(BuildContext context, LiveParameterSelectedController controller) {
  final textController = TextEditingController(text: controller.fileName.value);
  
  return Stack(
    children: [
      Container(color: Colors.black.withOpacity(0.6)),
      Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.isTablet ? 80 : 30),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 45,
                width: double.infinity,
                color: themeColor,
                alignment: Alignment.center,
                child: const Text("File Name",
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Save recording as",
                        style: TextStyle(fontSize: 17, color: Colors.black)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: textController,  // ← pre-filled
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "Name your recording",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 2)),
                      ),
                      onChanged: (val) => controller.fileName.value = val,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10)),
                      onPressed: () => controller.saveFile(),
                      child: const Text("Save",
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ],
  );
}

  // --- HELPERS ---

  Widget _tableCell(String text, {int? flex, double? width, bool isHeader = false}) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );

    return flex != null ? Expanded(flex: flex, child: content) : SizedBox(width: width, child: content);
  }

  Widget _verticalDivider() => const VerticalDivider(color: borderColor, width: 1, thickness: 1);

  Widget _iconButton(BuildContext context, String label, String iconName, VoidCallback onTap) {
    double size = context.isTablet ? 80 : 60;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: size,
            width: size,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: themeColor, shape: BoxShape.circle),
            child: Image.asset('assets/new/$iconName.png'),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}