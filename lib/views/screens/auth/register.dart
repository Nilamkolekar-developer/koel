import 'package:autopeepal/logic/controller/auth/registerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class RegisterScreen extends StatelessWidget {
//   RegisterScreen({super.key});
//   final controller = Get.put(RegistrationController());

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
//         title: Text('Register', style: TextStyles.appBarTitle),
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
//                       "Enter First Name",
//                       hint: "Enter first name",
//                       onChanged: (v) => controller.firstName.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Last Name",
//                       hint: "Enter last name",
//                       onChanged: (v) => controller.lastName.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Email ID",
//                       keyboardType: TextInputType.emailAddress,
//                       hint: "Enter email Id",
//                       onChanged: (v) => controller.email.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Mobile Number",
//                       keyboardType: TextInputType.phone,
//                       hint: "Enter mobile number",
//                       onChanged: (v) => controller.mobileNumber.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Enter Password",
//                       obscureText: true,
//                       hint: "Enter password",
//                       onChanged: (v) => controller.password.value = v,
//                     ),
//                     C15(),
//                     _buildFieldWithLabel(
//                       "Confirm Password",
//                       obscureText: true,
//                       hint: "Confirm Password",
//                       onChanged: (v) => controller.confirmPassword.value = v,
//                     ),
//                     C15(),
//                       _buildFieldWithLabel(
//                       "Enter Employee Code/Pulse ID",
//                       keyboardType: TextInputType.emailAddress,
//                       hint: "Enter email Code",
//                       onChanged: (v) => controller.email.value = v,
//                     ),
//                     C15(),
//                       _buildFieldWithLabel(
//                       "Enter Mobile IMEI Number",
//                       keyboardType: TextInputType.emailAddress,
//                       hint: "Enter email Code",
//                       onChanged: (v) => controller.email.value = v,
//                     ),
//                     C15(),
//                     Obx(() => CustomDropdownTextField1(
//                           selectedValue: controller.selectedOem,
//                           items: controller.oemList
//                               .map((e) => e.name ?? "")
//                               .toList(),
//                           label: "Category Of User",
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
//                     C25(),
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
//                         controller.isBusy.value ? null : controller.submit,
//                     child: controller.isBusy.value
//                         ? const CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2)
//                         : const Text(
//                             'Submit',
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
class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final controller = Get.put(UserRegistrationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [

                    _field("First Name", controller.firstNameController),
                    _field("Last Name", controller.lastNameController),
                    _field("Email", controller.emailController),
                    _field("Mobile", controller.mobileController),
                    _field("Password", controller.passwordController, isPassword: true),
                    _field("Confirm Password", controller.confirmPasswordController, isPassword: true),

                    const SizedBox(height: 15),

                    // -------- DROPDOWN --------
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedOem.value?.name,
                          hint: const Text("Select Category"),
                          items: controller.oemList
                              .map((e) => DropdownMenuItem(
                                    value: e.name,
                                    child: Text(e.name ?? ""),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            final selected = controller.oemList
                                .firstWhere((e) => e.name == val);
                            controller.selectOem(selected);
                          },
                        )),

                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: controller.submit,
                      child: const Text("Submit"),
                    )
                  ],
                ),
              );
      }),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
