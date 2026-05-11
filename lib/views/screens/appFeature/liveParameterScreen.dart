import 'package:autopeepal/logic/controller/appFeature/liveParameterController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveParameterSelectPage extends StatelessWidget {
  const LiveParameterSelectPage({super.key});

  static const Color themeColor = Color(0xFF309F93); // theme_color
  static const Color pageBgColor = Color(0xFFF5F5F5); // page_bg_color

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveParameterSelectController());

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Parameter Select",
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
          // MAIN CONTENT LAYER
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                // 1. Search Bar & Filter Button (Grid Row 0)
                _buildSearchAndFilter(controller),

                // 2. ECU Tab Bar (Grid Row 1)
                _buildEcuTabs(controller),

                // 3. CollectionView / PID List (Grid Row 2)
                Expanded(child: _buildPidList(controller)),

                // 4. Continue Button (Grid Row 3)
                _buildContinueButton(controller),
              ],
            ),
          ),

          // OVERLAY LAYER: Group By View (TranslationY logic equivalent)
          Obx(() => controller.isGroupViewVisible.value
              ? _buildGroupPopup(controller)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---

  // Widget _buildSearchAndFilter(controller) {
  //   return Padding(
  //     padding: const EdgeInsets.all(2.0),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Container(
  //             height: 55,
  //             decoration: BoxDecoration(
  //               border: Border.all(color: themeColor),
  //               borderRadius: BorderRadius.circular(2),
  //             ),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     onChanged: (val) => controller.searchKey.value = val,
  //                     decoration: const InputDecoration(
  //                       hintText: "Search",
  //                       contentPadding: EdgeInsets.symmetric(horizontal: 10),
  //                       border: InputBorder.none,
  //                     ),
  //                   ),
  //                 ),
  //                 const Padding(
  //                   padding: EdgeInsets.all(9.0),
  //                   child: Icon(Icons.close, color: Colors.grey), // ic_close
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         IconButton(
  //           icon: const Icon(Icons.filter_list, color: themeColor), // ic_filter
  //           onPressed: () => controller.groupPidClicked(),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildSearchAndFilter(LiveParameterSelectController controller) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              border: Border.all(color: themeColor),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      controller.searchKey.value = val;
                      controller.searchParameter(val); // ✅ call search
                    },
                    decoration: const InputDecoration(
                      hintText: "Search",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // ── Clear button ─────────────────────────
                Obx(() => controller.searchKey.value.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.searchKey.value = '';
                          controller.searchParameter(''); // ✅ clear search
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(9.0),
                          child: Icon(Icons.close, color: Colors.grey),
                        ),
                      )
                    : const SizedBox(width: 36)),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: themeColor),
          onPressed: () => controller.groupPidClicked(),
        ),
      ],
    ),
  );
}

  // Widget _buildEcuTabs(controller) {
  //   return SizedBox(
  //     height: 55,
  //     child: Obx(() => ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           itemCount: controller.ecusList.length,
  //           itemBuilder: (context, index) {
  //             var ecu = controller.ecusList[index];
  //             return Opacity(
  //               opacity: ecu.opacity ?? 1.0,
  //               child: Container(
  //                 margin: const EdgeInsets.symmetric(horizontal: 1),
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: themeColor,
  //                     shape: const RoundedRectangleBorder(),
  //                   ),
  //                   onPressed: () => controller.tabClicked(ecu),
  //                   child: Text(ecu.ecuName ?? "",
  //                       style: const TextStyle(color: Colors.white)),
  //                 ),
  //               ),
  //             );
  //           },
  //         )),
  //   );
  // }
  Widget _buildEcuTabs(controller) {
    return Obx(() {
      if (controller.ecusList.isEmpty) return const SizedBox.shrink();

      return SizedBox(
          height: 50,
          child: Row(
            children: List.generate(controller.ecusList.length, (index) {
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ));
    });
  }

  Widget _buildPidList(controller) {
    return Obx(() {
      if (controller.loaderVisible.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: themeColor),
              const SizedBox(height: 10),
              Text(controller.msg.value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: controller.pidList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          var pidGroup = controller.pidList[index];
          // Maps to the nested BindableLayout in MAUI
          return Column(
            children: pidGroup.piCodeVariable.map<Widget>((variable) {
              return Row(
                children: [
                  Expanded(
                    child: Text(variable.shortName ?? "",
                        style: const TextStyle(fontSize: 15)),
                  ),
                  Checkbox(
                    value: variable.selected,
                    activeColor: themeColor,
                    onChanged: (val) =>
                        controller.checkBoxChanged(variable), // just drop `val`
                  ),
                ],
              );
            }).toList(),
          );
        },
      );
    });
  }

  Widget _buildContinueButton(controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: themeColor), // RedBtnStyle
        onPressed: () => controller.continueClicked(),
        child: const Text("Continue", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Widget _buildGroupPopup(controller) {
  //   return Stack(
  //     children: [
  //       GestureDetector(
  //         onTap: () => controller.isGroupViewVisible.value = false,
  //         child: Container(color: Colors.black.withOpacity(0.5)),
  //       ),
  //       Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Container(
  //           height: Get.context!.isTablet ? 330 : 220,
  //           color: Colors.white,
  //           padding: const EdgeInsets.all(15),
  //           child: Column(
  //             children: [
  //               const Text("Group By List",
  //                   style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       color: themeColor,
  //                       fontSize: 18)),
  //               Expanded(
  //                 child: ListView.builder(
  //                   itemCount: controller.groupList.length,
  //                   itemBuilder: (context, index) {
  //                     var group = controller.groupList[index];
  //                     return Row(
  //                       children: [
  //                         Checkbox(
  //                           value: group.isSelected,
  //                           activeColor: themeColor,
  //                           onChanged: (val) =>
  //                               controller.groupCheckBoxChanged(group, val),
  //                         ),
  //                         Text(group.groupName ?? ""),
  //                       ],
  //                     );
  //                   },
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.blue,
  //                     minimumSize: const Size(150, 40)),
  //                 onPressed: () => controller.okGroupByClicked(),
  //                 child:
  //                     const Text("OK", style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildGroupPopup(LiveParameterSelectController controller) {
  return Stack(
    children: [
      GestureDetector(
        onTap: () => controller.isGroupViewVisible.value = false,
        child: Container(color: Colors.black.withOpacity(0.5)),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: Get.context!.isTablet ? 330 : 220,
          color: Colors.white,
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text(
                "Group By List",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                    fontSize: 18),
              ),
              Expanded(
                child: Obx(() => ListView.builder(
                  itemCount: controller.groupList.length,
                  itemBuilder: (context, index) {
                    final group = controller.groupList[index];
                    return Row(
                      children: [
                        Checkbox(
                          value: group.isSelected,
                          activeColor: themeColor,
                          // ✅ FIX — controller takes only 1 param, remove val
                          onChanged: (_) =>
                              controller.groupCheckBoxChanged(group),
                        ),
                        Expanded(
                          child: GestureDetector(
                            // ✅ also allow tap on text
                            onTap: () =>
                                controller.groupCheckBoxChanged(group),
                            child: Text(group.groupName ?? ''),
                          ),
                        ),
                      ],
                    );
                  },
                )),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(150, 40)),
                onPressed: () => controller.okGroupByClicked(),
                child: const Text(
                    "OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
}
