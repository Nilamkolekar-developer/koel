import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/logic/controller/LocalFlshFile/localFlashFileController.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';

class LocalFlashingPage extends StatelessWidget {
  const LocalFlashingPage({super.key});

  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DownloadFlashFileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Flash ECU",
            style: TextStyle(color: Colors.black)),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40),
              child: Image.asset(
                'assets/new/ic_iKonnect.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 1. ECU TABS ───────────────────────────────────────────
          Obx(() => Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: controller.ecusList.map((ecu) {
                    final isSelected =
                        controller.selectedEcu.value?.id == ecu.id;
                    return Expanded(
                      child: InkWell(
                        onTap: () => controller.ecuTabCommand(ecu),
                        child: Container(
                          alignment: Alignment.center,
                          color: themeColor
                              .withOpacity(isSelected ? 1.0 : 0.5),
                          child: Text(
                            ecu.ecuName ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),

          // ── 2. CONTENT AREA ───────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isDwnlViewVisible.value) {
                return _buildDownloadProgressView(controller);
              }
              return _buildFileListView(controller);
            }),
          ),
        ],
      ),
    );
  }

  // ── FILE LIST ───────────────────────────────────────────────────
  Widget _buildFileListView(DownloadFlashFileController controller) {
    if (controller.dataFileListRx.isEmpty) {
      return const Center(child: Text("No data files available."));
    }
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: controller.dataFileListRx.length,
          itemBuilder: (context, index) {
            final item = controller.dataFileListRx[index];
            return _buildFileCard(item, controller);
          },
        ));
  }

  // ── DOWNLOAD PROGRESS VIEW ──────────────────────────────────────
  Widget _buildDownloadProgressView(DownloadFlashFileController controller) {
    return Obx(() => Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/new/gifcloud.gif", height: 160),
              const SizedBox(height: 10),
              Image.asset("assets/new/gifphone.gif", height: 100),
              const SizedBox(height: 30),
              Text(
                controller.dwnldPercent.value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Downloading Flash File...",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ));
  }

  // ── FILE CARD ───────────────────────────────────────────────────
  Widget _buildFileCard(
      LocalVariantEcuEcu item, DownloadFlashFileController controller) {
    final isDownloaded = item.isEnable == false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      color: item.backgroundColor ?? Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Text(
              item.productionSwId?.swPartNo ?? "-",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDownloaded ? Colors.white : Colors.black,
              ),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                // Info button
                _circleBtn(
                  icon: Icons.info_outline,
                  iconColor: isDownloaded ? Colors.white : themeColor,
                  onPressed: () => controller.infoCommand(item),
                ),
                // Download/Downloaded button
                _circleBtn(
                  imagePath: item.imgDownload,
                  isEnabled: item.isEnable ?? true,
                  iconColor: isDownloaded ? Colors.white : themeColor,
                  onPressed: () => controller.downloadCommand1(item),
                ),
              ],
            ),
          ),

          // ✅ FIXED — check not assign
          if (item.isDescVisible == true)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              color: Colors.grey.shade50,
              child: Text(
                item.productionSwId?.description ??
                    "No description available",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  // ── CIRCLE BUTTON ───────────────────────────────────────────────
  Widget _circleBtn({
    IconData? icon,
    String? imagePath,
    required VoidCallback onPressed,
    bool isEnabled = true,
    Color iconColor = themeColor,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: themeColor, width: 1.5),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: imagePath != null
              ? Image.asset(
                  imagePath,
                  height: 24,
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.download, color: iconColor),
                )
              : Icon(icon, color: iconColor, size: 22),
          onPressed: onPressed,
        ),
      ),
    );
  }
}