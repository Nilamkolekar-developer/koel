import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/auth/registerController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final controller = Get.put(RegistrationController());

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
        title: Text('Register', style: TextStyles.appBarTitle),
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
                      "Enter First Name",
                      hint: "Enter first name",
                      onChanged: (v) => controller.firstName.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Enter Last Name",
                      hint: "Enter last name",
                      onChanged: (v) => controller.lastName.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Enter Email ID",
                      keyboardType: TextInputType.emailAddress,
                      hint: "Enter email Id",
                      onChanged: (v) => controller.email.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Enter Mobile Number",
                      keyboardType: TextInputType.phone,
                      hint: "Enter mobile number",
                      onChanged: (v) => controller.mobileNumber.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Enter Password",
                      obscureText: true,
                      hint: "Enter password",
                      onChanged: (v) => controller.password.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Confirm Password",
                      obscureText: true,
                      hint: "Confirm Password",
                      onChanged: (v) => controller.confirmPassword.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Enter Employee Code/Pulse ID",
                      keyboardType: TextInputType.emailAddress,
                      hint: "Enter email Code",
                      onChanged: (v) => controller.email.value = v,
                    ),
                    C15(),
                    _buildFieldWithLabel(
                      "Enter Mobile IMEI Number",
                      keyboardType: TextInputType.emailAddress,
                      hint: "Enter email Code",
                      onChanged: (v) => controller.email.value = v,
                    ),
                    C15(),
                    Obx(() => CustomDropdownTextField1(
      selectedValue: controller.selectedCategoryName, // ✅ RxString
      items: controller.categoryList
          .map((e) => e.name ?? "")
          .toList(),
      label: "Select Category",
      dialogTitle: "Select Category",
      hint: "Select Category",
      onItemSelected: (name) {
        final selected = controller.categoryList
            .firstWhere((e) => e.name == name);
        controller.selectCategory(selected);
      },
      title: '',
)),
//                     C25(),
// Obx(() => CustomDropdownTextField1(
//       selectedValue: controller.selectedWorkshop?.name ?? '',
//       items: controller.selectedCity?.workshops
//               .map((e) => e.name ?? "")
//               .toList() ??
//           [],
//       label: controller.workshopDisplayName.value,
//       dialogTitle: controller.workshopDisplayName.value,
//       hint: "Select ${controller.workshopDisplayName.value}",
//       onItemSelected: (name) {
//         final selected = controller.selectedCity!.workshops
//             .firstWhere((e) => e.name == name);

//         controller.selectWorkshop(selected);
//       },
//       title: '',
//     ))
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
                    onPressed:
                        controller.isBusy.value ? null : controller.submit,
                    child: controller.isBusy.value
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text(
                            'Submit',
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
