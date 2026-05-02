import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/tickit/createTickitController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TickitScreen extends StatelessWidget {
  TickitScreen({super.key});
  final CreateTicketController controller =
      Get.put(CreateTicketController(isAuthenticated: true));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        // Change this line in your AppBar:
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If there is no back stack, go to a specific route
              Get.offAllNamed(Routes.loginScreen);
            }
          },
        ),
        title: Text('Create Ticket', style: TextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      _buildFieldWithLabel(
                      "Email Id",
                      hint: "Enter email id",
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.emailId = v;
                      }),
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Location",
                      hint: "Enter location",
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.location = v;
                      }),
                    ),
                    C15(),
                    Obx(() => CustomDropdownTextField1(
                          selectedValue: controller.selectedIssueName,
                          items: controller.issueList
                              .map((e) => e.issueRelated ?? "")
                              .toList(),
                          label: "Issue",
                          dialogTitle: "Select Issue",
                          hint: "Select Issue",
                          onItemSelected: (name) {
                            final selected = controller.issueList
                                .firstWhere((e) => e.issueRelated == name);

                            controller.selectIssue(selected);
                            controller.selectedIssueName.value = name;
                          },
                          title: '',
                        )),
                    C15(),
                    Obx(() => CustomDropdownTextField1(
                          selectedValue: controller.selectedRelatedIssueName,
                          items: controller.relatedIssueList
                              .map((e) => e.issue ?? "")
                              .toList(),
                          label: "Related Issue",
                          dialogTitle: "Select Related Issue",
                          hint: "Select Related Issue",
                          onItemSelected: (name) {
                            final selected = controller.relatedIssueList
                                .firstWhere((e) => e.issue == name);

                            controller.selectRelatedIssue(selected);
                            controller.selectedRelatedIssueName.value = name;
                          },
                          title: '',
                        )),
                    C15(),
                    _buildFieldWithLabel(
                      "Dongle SSID",
                      hint: "Enter Dongle SSID",
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.serialNumber = v;
                      }),
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Invoice Number",
                      hint: "Enter invoice number",
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.invoiceNo = v;
                      }),
                    ),
                    C15(),
                    Obx(() => InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.invoiceDate.value,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              controller.invoiceDate.value = picked;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.themeColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              controller.invoiceDate.value
                                  .toIso8601String()
                                  .split("T")
                                  .first,
                            ),
                          ),
                        )),
                    C15(),
                    Obx(() => InkWell(
                          onTap: () => controller.pickFile(),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.themeColor),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.fileName.value.isEmpty
                                        ? "Choose File"
                                        : controller.fileName.value,
                                  ),
                                ),
                                const Icon(Icons.attach_file),
                              ],
                            ),
                          ),
                        )),
                    C15(),
                    _buildFieldWithLabel(
                      "Comment",
                      hint: "Enter comment",
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.comment = v;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themeColor,
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      controller.addTicket();
                    },
                    child: controller.isBusy.value
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text(
                            'Create Tickit',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "OpenSans-SemiBold",
                              color: Colors.black,
                            ),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWithLabel(
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String hint = "",
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
            fontFamily: "OpenSans-Regular",
          ),
        ),
        C2(),
        TextField(
          style: TextStyles.textfieldTextStyle2,
          cursorColor: Colors.black,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyles.hintStyle1,
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
              borderSide: BorderSide(color: AppColors.themeColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
