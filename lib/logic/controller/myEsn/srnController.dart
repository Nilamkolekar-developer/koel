import 'package:get/get.dart';

class SrnController extends GetxController {
  var selectedChannel = Rxn<String>();
  var isChannelSelected = false.obs;

  void updateChannel(String? value) {
    selectedChannel.value = value;
    isChannelSelected.value = true;
  }
  var downloadedItems = <String>{}.obs;

  void toggleDownload(String versionId) {
    // Simulate a download process
    if (!downloadedItems.contains(versionId)) {
      downloadedItems.add(versionId);
    }
  }
}