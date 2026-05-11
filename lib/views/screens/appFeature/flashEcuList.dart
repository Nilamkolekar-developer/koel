import 'package:autopeepal/logic/controller/appFeature/flashFileListController.dart';
import 'package:autopeepal/models/KOEL_LocalDataFlash/localDataFile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashEcuListPage extends StatelessWidget {
  const FlashEcuListPage({super.key});

  static const Color themeColor = Color(0xFF309F93);
  static const Color pageBgColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FlashListController());

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Flash ECU", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (val) => controller.searchKey.value = val,
              decoration: InputDecoration(
                hintText: "Search file...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: themeColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: themeColor, width: 2),
                ),
              ),
            ),
          ),

          // ── ECU Tab Bar ─────────────────────────────────────────────────
          SizedBox(
  height: Get.context!.isTablet ? 60 : 45,  // ✅ explicit height
  child: Obx(() {
    final list = controller.ecusList;
    if (list.isEmpty) return const SizedBox.shrink();

    // ── Single item → fill full width ─────────────────
    if (list.length == 1) {
      final ecu = list[0];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: InkWell(
          onTap: () => controller.switchTab(ecu),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(ecu.opacity ?? 1.0),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              ecu.ecuName ?? '',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // ── Multiple items → horizontal scroll ─────────────
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ecu = list[index];
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: InkWell(
            onTap: () => controller.switchTab(ecu),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(ecu.opacity ?? 1.0),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                ecu.ecuName ?? '',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }),
),
          const SizedBox(height: 8),

          // ── Flash File List ─────────────────────────────────────────────
          Expanded(
            child: Obx(() => controller.flashFileList.isEmpty
                ? const Center(child: Text("No files found."))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: controller.flashFileList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final file = controller.flashFileList[index];
                      return _buildFileCard(context, file, controller);
                    },
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, LocalVariantEcuEcu file,
      FlashListController controller) {
    final isDownloaded = file.isEnable == false;

    return Container(
      decoration: BoxDecoration(
        color: isDownloaded ? const Color(0xFF309F93) : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              file.productionSwId?.swPartNo ?? "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDownloaded ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              file.productionSwId?.description ?? "",
              style: TextStyle(
                color: isDownloaded ? Colors.white70 : Colors.grey,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info toggle button
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: isDownloaded ? Colors.white : themeColor,
                  ),
                  onPressed: () => controller.datasetInfoClicked(file),
                ),
                // Download/Flash button
                IconButton(
                  icon: Image.asset(
                    'assets/new/${file.imgDownload ?? "ic_download.png"}',
                    width: 24,
                    color: isDownloaded ? Colors.white : themeColor,
                  ),
                  onPressed: () => controller.datasetSelectClicked(file),
                ),
              ],
            ),
          ),

          // Description expand (isDescVisible toggle)
          if (file.isDescVisible == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                file.productionSwId?.description ?? "No description.",
                style: TextStyle(
                  color: isDownloaded ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
