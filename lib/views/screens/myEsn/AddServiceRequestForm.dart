import 'package:autopeepal/common_widgets/customForm_widgets.dart';
import 'package:autopeepal/logic/controller/myEsn/addServiceControllerForm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddServiceRequestPage extends StatelessWidget {
  const AddServiceRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceRequestController());
    const Color themeColor = Color(0xFF309F93);
    bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: false,
  title: const Text(
    "Create SRN Session",
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 45, maxWidth: 120),
        child: Image.asset(
          'assets/new/ic_ikonnect.jpg',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
    ),
  ],
),
      body: SingleChildScrollView(
        // Increased top padding to 50 for "little distance after appbar"
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: const CustomFormField(label: "Sr Number", hint: "Enter Sr Number")),
                  const SizedBox(width: 30),
                  Expanded(child: const CustomFormField(label: "ESN", hint: "Enter ESN")),
                ],
              )
            else ...[
              const CustomFormField(label: "Sr Number", hint: "Enter Sr Number"),
              const CustomFormField(label: "ESN", hint: "Enter ESN"),
            ],

            const CustomFormField(label: "Customer Name", hint: "Enter Customer Name"),
            const CustomFormField(label: "Customer Voice", hint: "Enter Customer Voice", maxLines: 2),

            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: const CustomFormField(label: "Application Code", hint: "Enter Application Code")),
                  const SizedBox(width: 30),
                  Expanded(child: const CustomFormField(label: "Hours", hint: "Enter hours")),
                ],
              )
            else ...[
              const CustomFormField(label: "Application Code", hint: "Enter Application Code"),
              const CustomFormField(label: "Hours", hint: "Enter hours"),
            ],

            const CustomFormField(
              label: "Gense No / Machine Serial No / Chassis No",
              hint: "Enter identification number",
            ),

            const SizedBox(height: 20),

            Obx(() => Wrap(
                  spacing: 35,
                  runSpacing: 20,
                  children: controller.checkStates.keys.map((String key) {
                    return CustomCheckbox(
                      label: key,
                      value: controller.checkStates[key]!,
                      onChanged: (val) => controller.toggleCheckbox(key, val!),
                    );
                  }).toList(),
                )),

            const SizedBox(height: 40),
            const CustomFormField(label: "Address", hint: "Enter full address", maxLines: 3),

            // Complaint Details field - styled bigger
            TextFormField(
              maxLines: 5, // Increased height
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Complaint details or other notes...",
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: themeColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: themeColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                // Increased content padding for "little big" feel
                contentPadding: const EdgeInsets.all(20), 
              ),
            ),

            const SizedBox(height: 70),

            Center(
              child: SizedBox(
                width: 320,
                height: 60, // Bigger button to match bigger fields
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  onPressed: () => controller.saveRequest(),
                  child: const Text(
                    "CREATE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}