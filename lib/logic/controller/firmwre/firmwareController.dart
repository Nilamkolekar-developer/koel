import 'package:get/get.dart';

class FirmwareUpdateController extends GetxController {
  // -------- STATE --------
  RxString currFV = "1.0.0".obs;
  RxString newFV = "1.1.0".obs;
  RxString message = "Ready to update".obs;

  RxBool btnEnable = true.obs;

  // -------- COMMAND --------
  Future<void> updateFirmware() async {
    message.value = "Updating firmware...";
    btnEnable.value = false;

    await Future.delayed(const Duration(seconds: 2));

    message.value = "Firmware Updated Successfully";
    currFV.value = newFV.value;
  }
}
