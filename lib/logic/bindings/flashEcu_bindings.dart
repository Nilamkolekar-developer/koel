import 'package:autopeepal/logic/controller/appFeature/flashEcuPageController.dart';
import 'package:autopeepal/logic/controller/myEsn/srnController.dart';
import 'package:get/get.dart';

class FlashEcuBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(FlashEcuController());
    Get.put(SrnController(),permanent: true);
  }
}
