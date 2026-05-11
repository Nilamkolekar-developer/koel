import 'package:autopeepal/logic/controller/appFeature/dtcController.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DtcListPage extends StatelessWidget {
  final Color themeColor = const Color(0xFF309F93);

  final DtcController controller = Get.put(DtcController());

  DtcListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Expanded(
              child: Text("DTC List",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
            Image.asset('assets/new/ic_iKonnect.jpg', height: 30),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── 1. ECU Tabs ──────────────────────────────────────────────────
          Obx(() => SizedBox(
                height: 50,
                child: Row(
                  children:
                      List.generate(controller.ecusList.length, (index) {
                    final ecu = controller.ecusList[index];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Opacity(
                          opacity: ecu.opacity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            onPressed: () => controller.tabClicked(ecu),
                            child: Text(
                              ecu.ecuName ?? "",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              )),

          // ── 2. DTC List ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isRunning.value) {
                return _buildLoadingView();
              }
              if (controller.dtcList.isEmpty) {
                return _buildEmptyView();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: controller.dtcList.length,
                itemBuilder: (context, index) =>
                    _buildDtcCard(controller.dtcList[index]),
              );
            }),
          ),

          // ── 3. Bottom Buttons ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
            child: Row(
              children: [
                Expanded(
                    child: _buildBottomButton(
                        "Refresh", () => controller.dtcRefresh())),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildBottomButton(
                        "Clear", () => controller.dtcClear())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDtcCard(DtcCode item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.code ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  item.statusActivation ?? "",
                  style: TextStyle(
                      color: item.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Row(
              children: [
                Text(item.description ?? "No description available",
                    style:
                        const TextStyle(color: Colors.black87, fontSize: 14)),
                        
              ],
            ),
            const SizedBox(height: 12),

            // Action Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // GD / Trouble Shooting — only if is_gd is true
                if (item.isGd == true) ...[
                  _buildActionLabel("Trouble Shooting Data",
                      () => controller.gdClicked(item)),
                  const SizedBox(width: 20),
                ],
                // Freeze Frame — only if is_freeze_frame is true
                if (item.isFreezeFrame == true)
                  _buildActionLabel("Freeze Frame Data",
                      () => controller.freezeFrameClicked(item)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionLabel(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text,
          style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }

  Widget _buildBottomButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: themeColor),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: themeColor),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.emptyViewText.value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Obx(() => Text(
            controller.emptyViewText.value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          )),
    );
  }
}