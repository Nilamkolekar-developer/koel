import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/appFeature/treeListController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TreeListPage extends StatelessWidget {
  const TreeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TreeListController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(controller.code),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/new/ic_gdimage.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              // controller.onImageIconPressed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 40),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Please Select From Below Tree",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            C15(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: controller.gdData.length,
                itemBuilder: (context, index) {
                  final item = controller.gdData[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: OutlinedButton(
                      onPressed: () => controller.onGdClicked(item),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF309F93), // ✅ text color
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF309F93),
                            width: 2), // ✅ border color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        alignment: Alignment.center, // ✅ center text
                      ),
                      child: Text(
                        item.model ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF309F93), // ✅ explicit text color
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center, // ✅ center align
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
