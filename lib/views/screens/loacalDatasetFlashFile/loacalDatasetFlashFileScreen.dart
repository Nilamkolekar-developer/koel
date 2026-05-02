import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:autopeepal/logic/controller/loacaldatasetFileFlash/localDatasetController.dart';

class LocalDatasetFilePage extends StatelessWidget {
  LocalDatasetFilePage({super.key});

  final controller = Get.put(LocalDatasetFileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Local Dataset Files"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Obx(() {
        // 🔵 LOADING STATE
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 🔴 EMPTY VIEW
        if (controller.dataFileList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Dataset files are not available in local database",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        // 🟢 LIST VIEW
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 40),
          itemCount: controller.dataFileList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            final item = controller.dataFileList[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              elevation: 3,
              child: ListTile(
                title: Text(
                  item.swPartNo ?? "N/A",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    controller.deleteFile(item);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}