import 'package:autopeepal/logic/controller/appFeature/writeParameterController.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WriteParameterPage extends StatelessWidget {
  const WriteParameterPage({super.key});

  static const Color themeColor = Color(0xFF309F93);
  static const Color pageBgColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WriteParameterController());

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Write Parameters",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Get.context!.isTablet ? 24 : 16,
                ),
              ),
            ),
            Image.asset(
              'assets/new/ic_iKonnect.jpg',
              height: Get.context!.isTablet ? 44 : 30,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildEcuTabs(controller),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildParameterSelector(controller),
                      const SizedBox(height: 20),
                      _buildVariableList(controller),
                    ],
                  ),
                ),
              ),
              _buildWriteButton(controller),
            ],
          ),
          Obx(() => controller.pidViewVisible.value
              ? _buildPidPopup(controller)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ── ECU TABS ──────────────────────────────────────────────────────────────
  Widget _buildEcuTabs(WriteParameterController controller) {
  return Container(
    height: Get.context!.isTablet ? 60 : 45,
    color: Colors.white,
    child: Obx(() {
      final list = controller.ecusList;

      // ── Single item → fill full width ─────────────────
      if (list.length == 1) {
        final ecu = list[0];
        return InkWell(
          onTap: () => controller.tabClicked(ecu),
          child: Container(
            width: double.infinity,      // ✅ full width
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(ecu.opacity),
              border: const Border(
                  right: BorderSide(color: Colors.white, width: 1)),
            ),
            child: Text(
              ecu.ecuName ?? '',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      // ── Multiple items → horizontal scroll ─────────────
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final ecu = list[index];
          return InkWell(
            onTap: () => controller.tabClicked(ecu),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(ecu.opacity),
                border: const Border(
                    right: BorderSide(color: Colors.white, width: 1)),
              ),
              child: Text(
                ecu.ecuName ?? '',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    }),
  );
}

  // ── PARAMETER SELECTOR ────────────────────────────────────────────────────
  Widget _buildParameterSelector(WriteParameterController controller) {
    return GestureDetector(
      onTap: () => controller.showPidPopup(),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: themeColor),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() => Text(
                      controller.title.value,
                      style: const TextStyle(color: Colors.grey),
                    )),
              ),
            ),
            Container(width: 1.5, color: themeColor),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_drop_down, color: themeColor, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  // ── VARIABLE LIST ─────────────────────────────────────────────────────────
  Widget _buildVariableList(WriteParameterController controller) {
    return Obx(() {
      final variables = controller.selectedPidList.value?.piCodeVariable;

      print("🔍 UI rebuild — variables count: ${variables?.length ?? 0}");
      if (variables != null && variables.isNotEmpty) {
        for (int i = 0; i < variables.length; i++) {
          print(
              "🔍   [$i] shortName: '${variables[i].shortName}' | writeValue: '${variables[i].writeValue}' | showResolution: '${variables[i].showResolution}'");
        }
      }

      if (variables == null || variables.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: variables.length,
        itemBuilder: (context, index) {
          final item = variables[index];
          if (item.isVisible == false) return const SizedBox.shrink();

          final showRes = item.showResolution ?? "";
          final writeVal = item.writeValue ?? "";

          print(
              "🔍 building row[$index] showRes='$showRes' writeVal='$writeVal'");

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.shortName ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // ── Left: read-only current value ─────────────
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: const Color(0xFF309F93).withOpacity(0.1),
                          child: Text(
                            showRes,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ── Right: input or enum picker ───────────────
                      Expanded(
                        child: controller.isEnumVisible.value
                            ? _buildEnumPicker(item, controller)
                            : TextFormField(
                                key: ValueKey(
                                    '${controller.selectedPidList.value?.code}_${index}_$writeVal'),
                                initialValue: writeVal,
                                decoration: const InputDecoration(
                                  hintText: "Enter new value",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  print(
                                      "✏️ user typed: '$val' for index $index");
                                  item.writeValue = val;
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // ── ENUM PICKER ───────────────────────────────────────────────────────────
  Widget _buildEnumPicker(
      PiCodeVariable item, WriteParameterController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text("Select Value to Write",
            style: TextStyle(color: Colors.red)),
        value: item.selectedEnum?.code,
        items: (item.messages ?? [])
            .map((e) => DropdownMenuItem<String>(
                  value: e.code ?? "",
                  child: Text(e.message ?? ""),
                ))
            .toList(),
        onChanged: (val) {
          item.selectedEnum =
              item.messages?.firstWhereOrNull((m) => m.code == val);
          item.selected = item.selectedEnum != null;
          controller.selectedPidList.refresh();
        },
      ),
    );
  }

  // ── WRITE BUTTON ──────────────────────────────────────────────────────────
  Widget _buildWriteButton(WriteParameterController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: themeColor),
          onPressed: () => controller.writeParameter(),
          child: const Text("WRITE", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // ── PID POPUP ─────────────────────────────────────────────────────────────
  Widget _buildPidPopup(WriteParameterController controller) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: () => controller.closePopupClicked(),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: themeColor,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                      onChanged: (val) => controller.searchKey.value = val,
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: Obx(() {
                      final allVariables = controller.pidList
                          .expand((pid) => pid.piCodeVariable ?? [])
                          .toList();

                      if (allVariables.isEmpty) {
                        return const Center(
                            child: Text("No parameters available"));
                      }

                      return ListView.builder(
                        itemCount: allVariables.length,
                        itemBuilder: (context, index) {
                          final variable = allVariables[index];
                          return GestureDetector(
                            onTap: () => controller.selectPid(variable),
                            child: Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  variable.shortName ?? "",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
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
