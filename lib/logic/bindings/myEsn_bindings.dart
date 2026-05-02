
import 'package:autopeepal/logic/controller/myEsn/myEsnController.dart';
import 'package:get/get.dart';

class MyesnBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(Myesncontroller());
  }
  
}