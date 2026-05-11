import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/logic/controller/myEsn/addServiceControllerForm.dart';
import 'package:autopeepal/common_widgets/customForm_widgets.dart';

class AddServiceRequestPage extends StatelessWidget {
  const AddServiceRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure we are using the correct controller name from your previous snippets
    final controller = Get.put(CreateSessionController());
    const themeColor = Color(0xFF309F93);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create SRN Session",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40),
              child: Image.asset(
                'assets/new/ic_ikonnect.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: themeColor, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // SR NUMBER + SEARCH ICON (MAUI SearchSRCommand)
                // ==========================================
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        label: "SR Number",
                        hint: "Enter SR Number",
                        controller: controller.srNumberCtrl,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Only show search if logic requires it (Workshop group 6)
                    Visibility(
                      visible: controller.isSearchVisible.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            controller
                                .searchSRNumber(controller.srNumberCtrl.text);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==========================================
                // CONDITIONAL FORM VISIBILITY
                // ==========================================
                if (controller.isFormVisible.value) ...[
                  // CUSTOMER VOICE
                  CustomFormField(
                    label: "Customer Voice",
                    hint: "Enter Customer Voice",
                    maxLines: 2,
                    enabled: controller.isCustomerVoiceEnabled.value,
                    controller: controller.customerVoiceCtrl,
                  ),

                  const SizedBox(height: 10),

                  // APP CODE + ESN
                  Row(
                    children: [
                      Expanded(
                        child: CustomFormField(
                          label: "Application Code",
                          hint: "Enter Application Code",
                          enabled: controller.isAppCodeEnabled.value,
                          controller: controller.appCodeCtrl,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomFormField(
                          label: "ESN",
                          hint: "Enter ESN",
                          enabled: controller.isESNEnabled.value,
                          controller: controller.esnCtrl,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // CUSTOMER NAME
                  CustomFormField(
                    label: "Customer Name",
                    hint: "Enter Customer Name",
                    enabled: controller.isCustomerNameEnabled.value,
                    controller: controller.customerNameCtrl,
                  ),

                  const SizedBox(height: 10),

                  // GENSET
                  CustomFormField(
                    label: "Genset / Machine No",
                    hint: "Enter number",
                    enabled: controller.isGensetEnabled.value,
                    controller: controller.gensetCtrl,
                  ),

                  const SizedBox(height: 10),

                  // HOURS
                  CustomFormField(
                    label: "Hours",
                    hint: "Enter hours",
                    enabled: controller.isHoursEnabled.value,
                    controller: controller.hoursCtrl,
                  ),

                  const SizedBox(height: 20),

                  const Text("Service Type",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // SERVICE CHECKBOX LIST
                  Wrap(
                    spacing: 10,
                    children: controller.serviceList.map((item) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            // FIX: Access property directly
                            value: item.selected,
                            onChanged: (val) => controller
                                .checkChange(item), // Pass 'item' object
                            activeColor: themeColor,
                          ),
                          Text(item.name ?? ""),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ADDRESS
                  CustomFormField(
                    label: "Address",
                    hint: "Fetching current location...",
                    maxLines: 3,
                    controller: controller.addressCtrl,
                  ),

                  const SizedBox(height: 20),

                  // COMPLAINT
                  TextFormField(
                    maxLines: 5,
                    controller: controller.complaintCtrl,
                    style: const TextStyle(fontSize: 16),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "Complaint details...",
                      //hintStyle: TextStyles.hintStyle1,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: AppColors.themeColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: AppColors.themeColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(color: AppColors.themeColor, width: 2),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: AppColors.themeColor),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // CREATE BUTTON
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                        ),
                        onPressed: controller.createSrSession,
                        child: const Text(
                          "CREATE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child:
                          Text("Please search for an SR Number to continue."),
                    ),
                  )
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
