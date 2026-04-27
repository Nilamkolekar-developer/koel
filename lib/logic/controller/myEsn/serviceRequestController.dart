import 'package:get/get.dart';

class ServiceRequestListController extends GetxController {
  // Mock data matching your fields
  var requests = [
    {
      'title': 'Test DTC Version 2.0',
      'appCode': 'AC-8829',
      'esn': 'ESN-100293',
      'srnType': 'Post Warranty',
      'complaint': 'Low engine oil pressure detected.',
      'date': '2026-04-27',
    },
    {
      'title': 'Test DTC Version 1.1',
      'appCode': 'AC-4410',
      'esn': 'ESN-992811',
      'srnType': 'AMC',
      'complaint': 'Standard periodic maintenance check.',
      'date': '2026-03-15',
    },
  ].obs;

  var searchQuery = ''.obs;

  // Filtered list based on search
  List<Map<String, String>> get filteredRequests => requests
      .where((req) =>
          req['title']!.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          req['esn']!.toLowerCase().contains(searchQuery.value.toLowerCase()))
      .toList();
}