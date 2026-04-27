import 'package:get/get.dart';

class AddServiceRequestController extends GetxController {
  // Reactive Map for checkboxes
  var checkStates = {
    'CSP': false,
    'Line Rejection': false,
    'BD & CM': false,
    'Post Warranty': false,
    'AMC': false,
    'Others': false,
  }.obs;

  void toggleCheckbox(String key, bool value) {
    checkStates[key] = value;
  }

  void saveRequest() {
    // Implement your save logic here (e.g., API call or local DB)
    print("Saving Service Request...");
    print("Selected Types: ${checkStates.entries.where((e) => e.value).map((e) => e.key).toList()}");
  }
}