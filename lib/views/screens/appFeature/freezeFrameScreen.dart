// freeze_frame_page.dart

import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/logic/controller/appFeature/freezeFrameController.dart';

class FreezeFramePage extends StatelessWidget {
  const FreezeFramePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FreezeFrameController());
    final bool isTablet =
        MediaQuery.of(context).size.shortestSide >= 600;

    final double fontSize      = isTablet ? 16 : 13;
    final double titleFontSize = isTablet ? 20 : 16;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      // ── AppBar ← NavigationPage.TitleView ─────────────────
      appBar: AppBar(
        title: Row(
          children: [
            // ← Label Text="{Binding Title}"
            Expanded(
              child: Obx(() => Text(
                controller.title.value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isTablet ? 24 : 16,
                ),
                overflow: TextOverflow.ellipsis,
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset(
                'assets/images/ic_iKonnect.png',
                height: isTablet ? 44 : 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(width: 30),
              ),
            ),
          ],
        ),
      ),

      // ── Body ──────────────────────────────────────────────
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Row 0: DTC Description ─────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                controller.dtc.description ?? '',
                style: TextStyle(fontSize: fontSize, color: Colors.black),
              ),
            ),

            // ── Row 1: List or Loading or Empty ────────────
            Expanded(
              child: Obx(() {

                // ── Loading ──────────────────────────────
                if (controller.isLoading.value == true) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ── Empty View ← CollectionView.EmptyView ─
                if (controller.freezeFrameList.isEmpty) {
                  return Center(
                    child: Text(
                      controller.error.value.isNotEmpty
                          ? controller.error.value
                          : 'No data available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                // ── List ← LinearItemsLayout ItemSpacing=8 ─
                return ListView.separated(
                  itemCount: controller.freezeFrameList.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = controller.freezeFrameList[index];
                    return _FreezeFrameCard(
                      item:     item,
                      fontSize: fontSize,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card  ← DataTemplate Frame
// ─────────────────────────────────────────────────────────────
class _FreezeFrameCard extends StatelessWidget {
  final FreezeFrameUIModel item;
  final double fontSize;

  const _FreezeFrameCard({
    required this.item,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            // ── desc ─────────────────────────────────────
            Expanded(
              child: Text(
                item.desc??'',
                style: TextStyle(fontSize: fontSize, color: textColor),
              ),
            ),
            // ── value ────────────────────────────────────
            Text(
              item.value??'',
              style: TextStyle(fontSize: fontSize, color: textColor),
              textAlign: TextAlign.end,
            ),
            const SizedBox(width: 6),
            // ── unit ─────────────────────────────────────
            Text(
              item.unit??'',
              style: TextStyle(fontSize: fontSize, color: textColor),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}