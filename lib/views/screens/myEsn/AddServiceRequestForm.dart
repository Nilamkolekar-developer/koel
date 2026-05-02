// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:autopeepal/logic/controller/myEsn/addServiceControllerForm.dart';
// import 'package:autopeepal/common_widgets/customForm_widgets.dart';

// class AddServiceRequestPage extends StatelessWidget {
//   const AddServiceRequestPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(AddServiceRequestController());
//     const themeColor = Color(0xFF309F93);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Create SRN Session",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Container(
//         margin: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: themeColor, width: 1.5),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
//           child: Obx(() {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// =========================
//                 /// SR NUMBER + SEARCH (MAUI MATCH)
//                 /// =========================
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomFormField(
//                         label: "SR Number",
//                         hint: "Enter SR Number",
//                         onChanged: (v) => controller.srNumber.value = v,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     IconButton(
//                       icon: const Icon(Icons.search),
//                       onPressed: () => controller.searchSR(),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 /// =========================
//                 /// FORM VISIBILITY (IMPORTANT FIX)
//                 /// =========================

//                 CustomFormField(
//                   label: "Customer Voice",
//                   hint: "Enter Customer Voice",
//                   maxLines: 2,
//                   onChanged: (v) => controller.customerVoice.value = v,
//                 ),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomFormField(
//                         label: "Application Code",
//                         hint: "Enter Application Code",
//                         onChanged: (v) => controller.appCode.value = v,
//                         enabled: controller.isAppCodeEnabled.value,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: CustomFormField(
//                         label: "ESN",
//                         hint: "Enter ESN",
//                         onChanged: (v) => controller.esn.value = v,
//                         enabled: controller.isESNEnabled.value,
//                       ),
//                     ),
//                   ],
//                 ),

//                 CustomFormField(
//                   label: "Customer Name",
//                   hint: "Enter Customer Name",
//                   onChanged: (v) => controller.customerName.value = v,
//                   enabled: controller.isCustomerNameEnabled.value,
//                 ),

//                 CustomFormField(
//                   label: "Genset / Machine No",
//                   hint: "Enter number",
//                   onChanged: (v) => controller.genset.value = v,
//                   enabled: controller.isGensetEnabled.value,
//                 ),

//                 CustomFormField(
//                   label: "Hours",
//                   hint: "Enter hours",
//                   onChanged: (v) => controller.hours.value = v,
//                   enabled: controller.isHoursEnabled.value,
//                 ),

//                 const SizedBox(height: 20),

//                 /// =========================
//                 /// CHECKBOX LIST (MAUI CollectionView)
//                 /// =========================
//                 Wrap(
//                   spacing: 20,
//                   runSpacing: 10,
//                   children: controller.serviceList.map((item) {
//                     return Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Checkbox(
//                           value: item['selected'],
//                           onChanged: (val) => controller.checkChange(item),
//                         ),
//                         Text(item['name']),
//                       ],
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 20),

//                 // CustomFormField(
//                 //   label: "Address",
//                 //   hint: "Enter Address",
//                 //   maxLines: 3,
//                 //   onChanged: (v) => controller.address.value = v,
//                 // ),
//                 CustomFormField(
//                   label: "Address",
//                   hint: "Fetching current location...",
//                   maxLines: 3,
//                   controller: controller.addressController, // 👈 THIS IS KEY
//                   onChanged: (v) => controller.address.value = v,
//                 ),

//                 const SizedBox(height: 20),

//                 TextFormField(
//                   maxLines: 5,
//                   onChanged: (v) => controller.complaint.value = v,
//                   decoration: InputDecoration(
//                     hintText: "Complaint details...",
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide(color: themeColor),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 Center(
//                   child: SizedBox(
//                     width: 300,
//                     height: 55,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: themeColor,
//                       ),
//                       onPressed: () => controller.createSrSession(),
//                       child: const Text(
//                         "CREATE",
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/logic/controller/myEsn/addServiceControllerForm.dart';
import 'package:autopeepal/common_widgets/customForm_widgets.dart';

class AddServiceRequestPage extends StatelessWidget {
  const AddServiceRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceRequestController());
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
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: themeColor, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // SR NUMBER + SEARCH
                // =========================
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
                    // IconButton(
                    //   icon: const Icon(Icons.search),
                    //  // onPressed: controller.searchSR,
                    // ),
                  ],
                ),

                const SizedBox(height: 20),

                // =========================
                // CUSTOMER VOICE
                // =========================
                CustomFormField(
                  label: "Customer Voice",
                  hint: "Enter Customer Voice",
                  maxLines: 2,
                  controller: controller.customerVoiceCtrl,
                ),

                const SizedBox(height: 10),

                // =========================
                // APP CODE + ESN
                // =========================
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

                // =========================
                // CUSTOMER NAME
                // =========================
                CustomFormField(
                  label: "Customer Name",
                  hint: "Enter Customer Name",
                  enabled: controller.isCustomerNameEnabled.value,
                 controller: controller.customerNameCtrl,
                ),

                const SizedBox(height: 10),

                // =========================
                // GENSET
                // =========================
                CustomFormField(
                  label: "Genset / Machine No",
                  hint: "Enter number",
                  enabled: controller.isGensetEnabled.value,
                  controller: controller.gensetCtrl,
                ),

                const SizedBox(height: 10),

                // =========================
                // HOURS
                // =========================
                CustomFormField(
                  label: "Hours",
                  hint: "Enter hours",
                  enabled: controller.isHoursEnabled.value,
                  controller: controller.hoursCtrl,
                ),

                const SizedBox(height: 20),

                // =========================
                // SERVICE CHECKBOX LIST
                // =========================
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: controller.serviceList.map((item) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: item['selected'] ?? false,
                          onChanged: (_) => controller.checkChange(item),
                          activeColor: themeColor,
                        ),
                        Text(item['name']),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // =========================
                // ADDRESS (CONTROLLED)
                // =========================
                CustomFormField(
                  label: "Address",
                  hint: "Fetching current location...",
                  maxLines: 3,
                  controller: controller.addressCtrl,
                ),

                const SizedBox(height: 20),

                // =========================
                // COMPLAINT
                // =========================
                TextFormField(
                  maxLines: 5,
                  controller: controller.complaintCtrl,
                  decoration: InputDecoration(
                    hintText: "Complaint details...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: themeColor),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================
                // CREATE BUTTON
                // =========================
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
              ],
            );
          }),
        ),
      ),
    );
  }
}
