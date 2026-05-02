import 'package:autopeepal/logic/controller/myEsn/addServiceControllerForm.dart';
import 'package:autopeepal/logic/controller/myEsn/scannerController.dart';
import 'package:get/get.dart';

class AddServiceRequestBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AddServiceRequestController());
    Get.lazyPut(()=>ScannerController());
  }
}
