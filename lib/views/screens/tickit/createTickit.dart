// import 'package:autopeepal/common_widgets/customDropdown.dart';
// import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
// import 'package:autopeepal/logic/controller/tickit/createTickitController.dart';
// import 'package:autopeepal/routes/routes_string.dart';
// import 'package:autopeepal/themes/app_colors.dart';
// import 'package:autopeepal/themes/app_textstyles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TickitScreen extends StatelessWidget {
//   TickitScreen({super.key});
//   final CreateTicketController controller =
//       Get.put(CreateTicketController(isAuthenticated: true));
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.themeColor,
//         // Change this line in your AppBar:
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context);
//             } else {
//               // If there is no back stack, go to a specific route
//               Get.offAllNamed(Routes.loginScreen);
//             }
//           },
//         ),
//         title: Text('Create Ticket', style: TextStyles.appBarTitle),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                       _buildFieldWithLabel(
//                       "Email Id",
//                       hint: "Enter email id",
//                       onChanged: (v) => controller.createModel.update((val) {
//                         val?.emailId = v;
//                       }),
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Location",
//                       hint: "Enter location",
//                       onChanged: (v) => controller.createModel.update((val) {
//                         val?.location = v;
//                       }),
//                     ),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedIssueName,
//                           items: controller.issueList
//                               .map((e) => e.issueRelated ?? "")
//                               .toList(),
//                           label: "Issue",
//                           dialogTitle: "Select Issue",
//                           hint: "Select Issue",
//                           onItemSelected: (name) {
//                             final selected = controller.issueList
//                                 .firstWhere((e) => e.issueRelated == name);

//                             controller.selectIssue(selected);
//                             controller.selectedIssueName.value = name;
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedRelatedIssueName,
//                           items: controller.relatedIssueList
//                               .map((e) => e.issue ?? "")
//                               .toList(),
//                           label: "Related Issue",
//                           dialogTitle: "Select Related Issue",
//                           hint: "Select Related Issue",
//                           onItemSelected: (name) {
//                             final selected = controller.relatedIssueList
//                                 .firstWhere((e) => e.issue == name);

//                             controller.selectRelatedIssue(selected);
//                             controller.selectedRelatedIssueName.value = name;
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Dongle SSID",
//                       hint: "Enter Dongle SSID",
//                       onChanged: (v) => controller.createModel.update((val) {
//                         val?.serialNumber = v;
//                       }),
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Invoice Number",
//                       hint: "Enter invoice number",
//                       onChanged: (v) => controller.createModel.update((val) {
//                         val?.invoiceNo = v;
//                       }),
//                     ),
//                     C15(),
//                     Obx(() => InkWell(
//                           onTap: () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               initialDate: controller.invoiceDate.value,
//                               firstDate: DateTime(2000),
//                               lastDate: DateTime(2100),
//                             );

//                             if (picked != null) {
//                               controller.invoiceDate.value = picked;
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: AppColors.themeColor),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Text(
//                               controller.invoiceDate.value
//                                   .toIso8601String()
//                                   .split("T")
//                                   .first,
//                             ),
//                           ),
//                         )),
//                     C15(),
//                     Obx(() => InkWell(
//                           onTap: () => controller.pickFile(),
//                           child: Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: AppColors.themeColor),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     controller.fileName.value.isEmpty
//                                         ? "Choose File"
//                                         : controller.fileName.value,
//                                   ),
//                                 ),
//                                 const Icon(Icons.attach_file),
//                               ],
//                             ),
//                           ),
//                         )),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Comment",
//                       hint: "Enter comment",
//                       onChanged: (v) => controller.createModel.update((val) {
//                         val?.comment = v;
//                       }),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Center(
//               child: Obx(() => ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.themeColor,
//                       padding: const EdgeInsets.symmetric(horizontal: 60),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6)),
//                     ),
//                     onPressed: () {
//                       controller.addTicket();
//                     },
//                     child: controller.isBusy.value
//                         ? const CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2)
//                         : const Text(
//                             'Create Tickit',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontFamily: "OpenSans-SemiBold",
//                               color: Colors.black,
//                             ),
//                           ),
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFieldWithLabel(
//     String label, {
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//     String hint = "",
//     required void Function(String) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 14,
//             color: Colors.black,
//             fontFamily: "OpenSans-Regular",
//           ),
//         ),
//         C2(),
//         TextField(
//           style: TextStyles.textfieldTextStyle2,
//           cursorColor: Colors.black,
//           keyboardType: keyboardType,
//           obscureText: obscureText,
//           onChanged: onChanged,
//          decoration: InputDecoration(
//   hintText: hint,
//   hintStyle: TextStyles.hintStyle1,
//   border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5),
//     borderSide: BorderSide(color: AppColors.themeColor),
//   ),
//   enabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5),
//     borderSide: BorderSide(color: AppColors.themeColor),
//   ),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5),
//     borderSide: BorderSide(color: AppColors.themeColor, width: 2),
//   ),
//   disabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5),
//     borderSide: BorderSide(color: AppColors.themeColor),
//   ),
//   errorBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5),
//     borderSide: const BorderSide(color: Colors.red),
//   ),
//   focusedErrorBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(5),
//     borderSide: const BorderSide(color: Colors.red, width: 2),
//   ),
//   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
// ),
//         ),
//       ],
//     );
//   }
// }
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

  // ─── Shared border helper ───────────────────
  OutlineInputBorder _border({Color? color, double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            color: color ?? AppColors.themeColor, width: width),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyles.hintStyle1,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _border(),
        enabledBorder: _border(color: Colors.grey.shade300),
        focusedBorder: _border(width: 2),
        disabledBorder: _border(color: Colors.grey.shade200),
        errorBorder: _border(color: Colors.red),
        focusedErrorBorder: _border(color: Colors.red, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.offAllNamed(Routes.loginScreen);
            }
          },
        ),
        title: Text('Create Ticket', style: TextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress indicator strip ──
            Container(
              height: 4,
              color: AppColors.themeColor.withOpacity(0.15),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.6,
                child: Container(color: AppColors.themeColor),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section: Contact Info ──
                    _sectionHeader('Contact Info', Icons.person_outline),
                    const SizedBox(height: 12),

                    _buildFieldWithLabel(
                      'Email Id',
                      hint: 'Enter email id',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.emailId = v;
                      }),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldWithLabel(
                      'Location',
                      hint: 'Enter location',
                      icon: Icons.location_on_outlined,
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.location = v;
                      }),
                    ),

                    const SizedBox(height: 22),

                    // ── Section: Issue Details ──
                    _sectionHeader('Issue Details', Icons.bug_report_outlined),
                    const SizedBox(height: 12),

                    Obx(() => _dropdownField(
                          label: 'Issue',
                          icon: Icons.category_outlined,
                          child: CustomDropdownTextField1(
                            selectedValue: controller.selectedIssueName,
                            items: controller.issueList
                                .map((e) => e.issueRelated ?? '')
                                .toList(),
                            label: 'Issue',
                            dialogTitle: 'Select Issue',
                            hint: 'Select Issue',
                            onItemSelected: (name) {
                              final selected = controller.issueList
                                  .firstWhere((e) => e.issueRelated == name);
                              controller.selectIssue(selected);
                              controller.selectedIssueName.value = name;
                            },
                            title: '',
                          ),
                        )),
                    const SizedBox(height: 14),

                    Obx(() => _dropdownField(
                          label: 'Related Issue',
                          icon: Icons.link_outlined,
                          child: CustomDropdownTextField1(
                            selectedValue:
                                controller.selectedRelatedIssueName,
                            items: controller.relatedIssueList
                                .map((e) => e.issue ?? '')
                                .toList(),
                            label: 'Related Issue',
                            dialogTitle: 'Select Related Issue',
                            hint: 'Select Related Issue',
                            onItemSelected: (name) {
                              final selected = controller.relatedIssueList
                                  .firstWhere((e) => e.issue == name);
                              controller.selectRelatedIssue(selected);
                              controller.selectedRelatedIssueName.value = name;
                            },
                            title: '',
                          ),
                        )),

                    const SizedBox(height: 22),

                    // ── Section: Device Info ──
                    _sectionHeader('Device Info', Icons.devices_outlined),
                    const SizedBox(height: 12),

                    _buildFieldWithLabel(
                      'Dongle SSID',
                      hint: 'Enter Dongle SSID',
                      icon: Icons.wifi_outlined,
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.serialNumber = v;
                      }),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldWithLabel(
                      'Invoice Number',
                      hint: 'Enter invoice number',
                      icon: Icons.receipt_outlined,
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.invoiceNo = v;
                      }),
                    ),
                    const SizedBox(height: 14),

                    // ── Invoice Date ──
                    _fieldLabel('Invoice Date', Icons.calendar_today_outlined),
                    const SizedBox(height: 6),
                    Obx(() => InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.invoiceDate.value,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.themeColor,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              controller.invoiceDate.value = picked;
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event,
                                    color: AppColors.themeColor, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  controller.invoiceDate.value
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  style: TextStyles.textfieldTextStyle2,
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_drop_down,
                                    color: Colors.grey.shade500),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 14),

                    // ── File Picker ──
                    _fieldLabel('Attachment', Icons.attach_file),
                    const SizedBox(height: 6),
                    Obx(() => InkWell(
                          onTap: () => controller.pickFile(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: controller.fileName.value.isEmpty
                                  ? Colors.grey.shade50
                                  : AppColors.themeColor.withOpacity(0.05),
                              border: Border.all(
                                color: controller.fileName.value.isEmpty
                                    ? Colors.grey.shade300
                                    : AppColors.themeColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  controller.fileName.value.isEmpty
                                      ? Icons.upload_file_outlined
                                      : Icons.insert_drive_file_outlined,
                                  color: AppColors.themeColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    controller.fileName.value.isEmpty
                                        ? 'Choose File'
                                        : controller.fileName.value,
                                    style: controller.fileName.value.isEmpty
                                        ? TextStyles.hintStyle1
                                        : TextStyles.textfieldTextStyle2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        )),

                    const SizedBox(height: 22),

                    // ── Section: Comment ──
                    _sectionHeader('Additional Info', Icons.comment_outlined),
                    const SizedBox(height: 12),

                    _fieldLabel('Comment', Icons.edit_note_outlined),
                    const SizedBox(height: 6),
                    TextFormField(
                      maxLines: 4,
                      style: TextStyles.textfieldTextStyle2,
                      cursorColor: AppColors.themeColor,
                      onChanged: (v) => controller.createModel.update((val) {
                        val?.comment = v;
                      }),
                      decoration: _inputDecoration('Enter comment...'),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Submit Button ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          controller.isBusy.value ? null : controller.addTicket,
                      child: controller.isBusy.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Submit Ticket',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'OpenSans-SemiBold',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ─────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.themeColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.themeColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: AppColors.themeColor.withOpacity(0.2)),
        ),
      ],
    );
  }

  // ─── Field Label ────────────────────────────
  Widget _fieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey.shade700,
            fontFamily: 'OpenSans-Regular',
          ),
        ),
      ],
    );
  }

  // ─── Text Field with Label ───────────────────
  Widget _buildFieldWithLabel(
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String hint = '',
    IconData? icon,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, icon ?? Icons.edit_outlined),
        const SizedBox(height: 6),
        TextField(
          style: TextStyles.textfieldTextStyle2,
          cursorColor: AppColors.themeColor,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  // ─── Dropdown wrapper with label ────────────
  Widget _dropdownField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, icon),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
