import 'package:autopeepal/logic/controller/loacaldatasetFileFlash/localDatasetController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalDatasetFilePage extends StatelessWidget {
  final controller = Get.put(LocalDatasetFileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Local Dataset Files',style: TextStyles.labelStyle,),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset('assets/new/ic_iKonnect.jpg', height: 30),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.dataFileList.isEmpty) {
          return const Center(
            child: Text(
              'Dataset files are not available in local database',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 40),
          itemCount: controller.dataFileList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            final item = controller.dataFileList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.swPartNo??'',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        side: BorderSide(color: AppColors.themeColor),
                        padding: const EdgeInsets.all(5),
                      ),
                      onPressed: () => controller.deleteFile(item),
                      child: Image.asset('assets/ic_delete.png', width: 24),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}