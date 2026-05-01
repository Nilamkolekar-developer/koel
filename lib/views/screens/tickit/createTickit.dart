import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/auth/registerController.dart';
import 'package:autopeepal/logic/controller/tickit/createTickitController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class TickitScreen extends StatelessWidget {
//   TickitScreen({super.key});
 

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
//                     _buildFieldWithLabel(
//                       "Location",
//                       hint: "Enter location",
//                       onChanged: (v) => controller.firstName.value = v,
//                     ),
//                     C15(),
//                    Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedOem,
//                           items: controller.oemList
//                               .map((e) => e.name ?? "")
//                               .toList(),
//                           label: " Isssue",
//                           dialogTitle: "Select OEM",
//                           hint: "Select OEM",
//                           onItemSelected: (name) {
//                             // Find the full object and trigger the command logic
//                             final selected = controller.oemList
//                                 .firstWhere((e) => e.name == name);
//                             controller.oemListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                       Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedOem,
//                           items: controller.oemList
//                               .map((e) => e.name ?? "")
//                               .toList(),
//                           label: "Related Isssue",
//                           dialogTitle: "Select OEM",
//                           hint: "Select OEM",
//                           onItemSelected: (name) {
//                             // Find the full object and trigger the command logic
//                             final selected = controller.oemList
//                                 .firstWhere((e) => e.name == name);
//                             controller.oemListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Dongle SSID",
//                       keyboardType: TextInputType.emailAddress,
//                       hint: "Enter Dongle SSID",
//                       onChanged: (v) => controller.email.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Invoice Number",
//                       keyboardType: TextInputType.phone,
//                       hint: "Enter invoice number",
//                       onChanged: (v) => controller.mobileNumber.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Invoice Date",
//                       obscureText: true,
//                       hint: "Enter invoice date",
//                       onChanged: (v) => controller.password.value = v,
//                     ),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedOem,
//                           items: controller.oemList
//                               .map((e) => e.name ?? "")
//                               .toList(),
//                           label: "Attach File",
//                           dialogTitle: "Select OEM",
//                           hint: "Select OEM",
//                           onItemSelected: (name) {
//                             // Find the full object and trigger the command logic
//                             final selected = controller.oemList
//                                 .firstWhere((e) => e.name == name);
//                             controller.oemListCommand(selected);
//                           },
//                           title: '',
//                         )),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Comment",
//                       obscureText: true,
//                       hint: "Enter comment",
//                       onChanged: (v) => controller.confirmPassword.value = v,
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
//                     onPressed:
//                       (){
// Get.toNamed(Routes.tickitList);
//                       },
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
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyles.hintStyle1,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(color: AppColors.themeColor),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(color: AppColors.themeColor),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(color: AppColors.themeColor),
//             ),
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//           ),
//         ),
//       ],
//     );
//   }
// }
class TickitScreen extends StatelessWidget {
  TickitScreen({super.key});

  final CreateTicketController controller =
      Get.put(CreateTicketController(isAuthenticated: true));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Create Ticket"),
      ),

      body: Obx(() => controller.issueList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// ISSUE DROPDOWN
                  DropdownButtonFormField<String>(
                    value: controller.selectedIssue.value?.issueRelated,
                    hint: const Text("Select Issue"),
                    items: controller.issueList
                        .map((e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.issueRelated ?? ""),
                            ))
                        .toList(),
                    onChanged: (value) {
                      final selected = controller.issueList
                          .firstWhere((e) => e.issueRelated == value);
                      controller.selectIssue(selected);
                    },
                  ),

                  const SizedBox(height: 15),

                  /// RELATED ISSUE
                  if (controller.otherViewVisible.value)
                    DropdownButtonFormField<String>(
                      value:
                          controller.selectedRelatedIssue.value?.issue,
                      hint: const Text("Select Related Issue"),
                      items: controller.relatedIssueList
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.issue ?? ""),
                              ))
                          .toList(),
                      onChanged: (value) {
                        final selected = controller.relatedIssueList
                            .firstWhere((e) => e.issue == value);
                        controller.selectRelatedIssue(selected);
                      },
                    ),

                  const SizedBox(height: 15),

                  /// COMMENT
                  TextField(
                    decoration:
                        const InputDecoration(labelText: "Comment"),
                    onChanged: (v) {
                      controller.createModel.update((val) {
                        val?.comment = v;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// FILE PICK
                  ElevatedButton(
                    onPressed: controller.pickFile,
                    child: const Text("Attach File"),
                  ),

                  Obx(() => Text(controller.fileName.value)),

                  const SizedBox(height: 30),

                  /// SUBMIT BUTTON
                  ElevatedButton(
                    onPressed: controller.addTicket,
                    child: const Text("Create Ticket"),
                  )
                ],
              ),
            )),
    );
  }
}
