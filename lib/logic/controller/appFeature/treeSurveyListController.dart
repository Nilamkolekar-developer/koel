// // import 'dart:convert';

// // import 'package:autopeepal/models/all_models.dart';
// // import 'package:autopeepal/models/gd_model.dart';
// // import 'package:autopeepal/models/offlineAnalyze_model.dart';
// // import 'package:autopeepal/models/sessionList_model.dart';
// // import 'package:autopeepal/models/treeList_model.dart';
// // import 'package:autopeepal/routes/routes_string.dart';
// // import 'package:autopeepal/services/api_services.dart';
// // import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class TreeSurveyController extends GetxController {

// //   // ── Dependencies ──────────────────────────────────────────
// //   final AuthApiService _apiServices = AuthApiService();

// //   // ── Arguments ─────────────────────────────────────────────
// //   late ResultGD resultGD;
// //   late String loadDescription;
// //   late String loadCode;
// //   late SessionModel sessionModel;
// //   late ModelResult vehicleModels;

// //   // ── Reactive tree list ────────────────────────────────────
// //   final RxList<TreeListModel> treeList = <TreeListModel>[].obs;
// //   final RxBool isLoading = false.obs;

// //   // ── Navigation state (matches C# fields) ─────────────────
// //   int _firstItem      = 0;
// //   int _currentPageId  = -1;
// //   int _nextPageId     = -1;
// //   int _continuePageId = -1;
// //   int _gdDecision     = -1;
// //   String _currentPageType = '';

// //   // ── Screen sizing ─────────────────────────────────────────
// //   double screenHeight = 700;
// //   int _lessHeight     = 82;

// //   // ─────────────────────────────────────────────────────────
// //   // onInit
// //   // ─────────────────────────────────────────────────────────
// //   @override
// //   void onInit() {
// //     super.onInit();

// //     final args = Get.arguments as Map<String, dynamic>?;
// //     if (args != null) {
// //       resultGD        = args['gdData']        as ResultGD;
// //       loadDescription = args['description']   as String? ?? '';
// //       loadCode        = args['code']          as String? ?? '';
// //       sessionModel    = args['sessionModel']  as SessionModel;
// //       vehicleModels   = args['vehicleModels'] as ModelResult;
// //     }

// //     // Detect screen height
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       final view = WidgetsBinding.instance.platformDispatcher.views.first;
// //       screenHeight = view.physicalSize.height / view.devicePixelRatio;
// //       _lessHeight  = screenHeight < 900 ? 82 : 89;
// //       _startGD(resultGD.treeSet?[0].treeData ?? []);
// //     });
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // StartGD — mirrors C# StartGD exactly
// //   // ─────────────────────────────────────────────────────────
// //   void _startGD(List<TreeDataGD> gdList) {
// //     try {
// //       _firstItem       = 0;
// //       _currentPageId   = -1;
// //       _nextPageId      = -1;
// //       _gdDecision      = -1;
// //       _continuePageId  = -1;
// //       _currentPageType = '';
// //       treeList.clear();

// //       for (final item in gdList) {
// //         final data = item.data;
// //         if (data == null) continue;

// //         final listModel = TreeListModel();
// //         listModel.id          = item.id ?? 0;
// //         listModel.description = data.description ?? '';
// //         listModel.topic       = data.typeForm?.topic ?? '';

// //         // ── Background / text color ────────────────────────
// //         final topic = data.typeForm?.topic ?? '';
// //         if (topic.contains("Root Cause")) {
// //           listModel.descriptionBackgroundColor = '#FF0000';
// //           listModel.descriptionTextColor       = '#FFFFFF';
// //         } else {
// //           listModel.descriptionBackgroundColor = '#FFFFFF';
// //           listModel.descriptionTextColor       = '#4d4d4d';
// //         }

// //         // ── Build decision list ────────────────────────────
// //         final decisionData = data.decisions?.data ?? [];
// //         for (int i = 0; i < decisionData.length; i++) {
// //           final d = decisionData[i];
// //           final dm = DecissionModel();
// //           dm.isCheck      = false;
// //           dm.newTextValue = d.textVal ?? '';
// //           dm.nextNode     = d.node ?? 0;
// //           dm.type         = d.type ?? '';
// //           dm.id           = item.id ?? 0;
// //           dm.textValue    = _resolveTextValue(d.textVal, i);
// //           listModel.decissionList!.add(dm);
// //         }

// //         // ── Group name + ok/notok node ids ─────────────────
// //         final decisionsType = data.decisions?.type ?? '';

// //         if (decisionsType.isEmpty) {
// //           if (decisionData.isNotEmpty) {
// //             final firstType = decisionData[0].type ?? '';
// //             listModel.groupName       = _getGroupName(firstType.isEmpty ? decisionsType : firstType);
// //             listModel.okPageNodeId    = decisionData[0].node ?? -1;
// //             listModel.notOkPageNodeId = decisionData.length > 1 ? (decisionData[1].node ?? -1) : -1;

// //             if (listModel.groupName == 'GroupData') {
// //               _populateGroupList(listModel, data);
// //             }
// //           } else {
// //             // LastData
// //             listModel.groupName       = _getGroupName('LastData');
// //             listModel.okPageNodeId    = -1;
// //             listModel.notOkPageNodeId = -1;
// //             listModel.lastQuestionList!.assignAll(
// //               _buildLastQuestionList(
// //                 isAllOk: topic.contains("All Ok") ||
// //                     gdList.length == (item.id ?? 0),
// //               ),
// //             );
// //           }
// //         } else {
// //           if (decisionData.isNotEmpty) {
// //             listModel.okPageNodeId    = decisionData[0].node ?? -1;
// //             listModel.notOkPageNodeId = decisionData.length > 1 ? (decisionData[1].node ?? -1) : -1;
// //             listModel.groupName       = _getGroupName(decisionsType);
// //           } else {
// //             listModel.okPageNodeId    = -1;
// //             listModel.notOkPageNodeId = -1;
// //             listModel.groupName       = _getGroupName('LastData');
// //             listModel.lastQuestionList!.assignAll(
// //               _buildLastQuestionList(
// //                 isAllOk: topic.contains("All Ok") ||
// //                     gdList.length == (item.id ?? 0),
// //               ),
// //             );
// //           }
// //         }

// //         // ── Visibility: only first item visible ────────────
// //         _firstItem++;
// //         if (_firstItem == 1) {
// //           listModel.pageVisible    = true;
// //           listModel.viewHeight     = screenHeight - _lessHeight;
// //           _currentPageType         = listModel.groupName??'';
// //           _currentPageId           = listModel.id??0;
// //         } else {
// //           listModel.pageVisible = false;
// //           listModel.viewHeight  = 0;
// //         }

// //         treeList.add(listModel);
// //       }
// //     } catch (ex) {
// //       debugPrint("_startGD error: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Decision Check Tapped  ← Decission_Check_Tapped
// //   // ─────────────────────────────────────────────────────────
// //   void onDecisionCheckTapped(DecissionModel selected, DecissionModel decision) {
// //     try {
// //       for (final item in treeList) {
// //         final found = item.decissionList!.any((x) => x.id == selected.id);
// //         if (found) {
// //           for (final d in item.decissionList??[]) {
// //             if (d.textValue == selected.textValue) {
// //               d.isCheck   = !d.isCheck;
// //               _nextPageId = d.nextNode;
// //               _currentPageId = selected.id??0;
// //               if (selected.textValue == 'NOT OK') {
// //                 _continuePageId = d.nextNode - 1;
// //               }
// //               item.isCommentBoxVisible =
// //                   selected.newTextValue!.toUpperCase().contains('NOT OK') ||
// //                   selected.newTextValue!.toUpperCase().contains('FALSE');
// //             } else {
// //               d.isCheck = false;
// //             }
// //           }
// //         }
// //       }
// //       treeList.refresh();
// //     } catch (ex) {
// //       debugPrint("onDecisionCheckTapped: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Next Button  ← btnNext_Clicked
// //   // ─────────────────────────────────────────────────────────
// //   Future<void> onNextPressed() async {
// //   isLoading.value = true;
// //   await Future.delayed(const Duration(milliseconds: 50));

// //   try {
// //     if (_nextPageId < 0) {
// //       _showAlert("Please select OK or NOT OK checkbox");
// //       isLoading.value = false;
// //       return;
// //     }

// //     if (_currentPageId == _nextPageId) {
// //       _showAlert("Please select OK or NOT OK checkbox");
// //       isLoading.value = false;
// //       return;
// //     }

// //     // ── Hide current page ──────────────────────────────────
// //     final currModel = treeList.firstWhereOrNull(
// //         (x) => x.id == _currentPageId);

// //     if (currModel != null) {
// //       currModel.pageVisible = false;
// //       currModel.viewHeight  = 0;

// //       // ✅ FIX — read bool into a local variable first
// //       final bool commentVisible = currModel.isCommentBoxVisible??false;
// //       if (commentVisible) {
// //         final String comment = currModel.comment??'';
// //         if (comment.isEmpty) {
// //           _showAlert("Please enter comment");
// //           isLoading.value = false;
// //           return;
// //         }
// //         await _postGdComment(currModel);
// //       }
// //     }

// //     // ── Show next page ─────────────────────────────────────
// //     final nextPage = treeList.firstWhereOrNull(
// //         (x) => x.id == _nextPageId);

// //     if (nextPage != null) {
// //       nextPage.pageVisible = true;
// //       nextPage.viewHeight  = screenHeight - _lessHeight;
// //       _currentPageType     = nextPage.groupName??'';
// //     }

// //     _currentPageId = _nextPageId;
// //     treeList.refresh();

// //     await Future.delayed(const Duration(milliseconds: 500));
// //   } catch (ex) {
// //     _showAlert("Error: ${ex.toString()}");
// //   } finally {
// //     isLoading.value = false;
// //   }
// // }
// //   // ─────────────────────────────────────────────────────────
// //   // Group Next Button  ← btnGroupNext_Clicked
// //   // ─────────────────────────────────────────────────────────
// //   Future<void> onGroupNextPressed() async {
// //     try {
// //       if (_currentPageType != 'GroupData') return;

// //       final groupNode = treeList.firstWhereOrNull(
// //           (x) => x.id == _currentPageId);
// //       if (groupNode == null) return;

// //       // ── Check all fields filled ──────────────────────────
// //       final hasEmpty = groupNode.groupList!
// //           .any((g) => g.currentLimit!.isEmpty);

// //       if (hasEmpty) {
// //         _showAlert("Please fill all fields");
// //         return;
// //       }

// //       // ── Validate values ──────────────────────────────────
// //       for (final g in groupNode.groupList??[]) {
// //         final current = double.tryParse(g.currentLimit);
// //         final upper   = double.tryParse(g.upperLimit);
// //         final lower   = double.tryParse(g.lowerLimit);

// //         if (current != null && upper != null && lower != null) {
// //           if (upper >= current && lower <= current) {
// //             g.statusColor = '#00b800';
// //           } else {
// //             g.statusColor = '#FF0000';
// //           }
// //         }
// //         g.upperLowerValueVisible = true;
// //       }

// //       // ── Decide next page ─────────────────────────────────
// //       final hasFailed = groupNode.groupList!
// //           .any((g) => g.statusColor == '#FF0000');

// //       if (hasFailed) {
// //         _nextPageId     = groupNode.notOkPageNodeId??0;
// //         _continuePageId = groupNode.okPageNodeId??0;
// //       } else {
// //         _nextPageId      = groupNode.okPageNodeId??0;
// //         _currentPageType = groupNode.groupName??'';
// //       }

// //       treeList.refresh();

// //       // ── Delay 4s (matches C# await Task.Delay(4000)) ─────
// //       await Future.delayed(const Duration(seconds: 4));

// //       // ── Update visibility ────────────────────────────────
// //       for (final item in treeList) {
// //         if (item.id == _nextPageId) {
// //           item.pageVisible = true;
// //           item.viewHeight  = screenHeight - _lessHeight;
// //         } else {
// //           item.pageVisible = false;
// //           item.viewHeight  = 0;
// //         }
// //       }

// //       _currentPageId = _nextPageId;
// //       treeList.refresh();
// //     } catch (ex) {
// //       debugPrint("onGroupNextPressed: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Last Page Next Button  ← btnLastPageNext_Clicked
// //   // ─────────────────────────────────────────────────────────
// //   Future<void> onLastPageNextPressed() async {
// //     try {
// //       if (_gdDecision == 1) {
// //         // ── Continue to next step ────────────────────────
// //         final nextPage = treeList.firstWhereOrNull(
// //             (x) => x.id == _continuePageId);

// //         if (nextPage == null) return;

// //         if (_continuePageId == _currentPageId) {
// //           _showAlert("This is last page");
// //           return;
// //         }

// //         // Show next, hide current
// //         nextPage.pageVisible = true;
// //         nextPage.viewHeight  = screenHeight - _lessHeight;
// //         _currentPageType     = nextPage.groupName??'';
// //         _currentPageId       = _nextPageId;

// //         final list = treeList.firstWhereOrNull(
// //             (x) => x.id == _currentPageId);
// //         if (list != null) {
// //           list.pageVisible = false;
// //           list.viewHeight  = 0;
// //         }

// //         _nextPageId = _currentPageId = nextPage.id??0;
// //         treeList.refresh();

// //       } else if (_gdDecision == 2) {
// //         // ── Restart GD ───────────────────────────────────
// //          Get.back();

// //       } else if (_gdDecision == 3) {
// //         // ── Quit GD → DtcListPage ────────────────────────
// //         Get.to(Routes.dtcScreen
// //           ,
// //           arguments: {
// //             'sessionModel' : sessionModel,
// //             'vehicleModels': vehicleModels,
// //           },
// //         );
// //       }
// //     } catch (ex) {
// //       debugPrint("onLastPageNextPressed: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Last Checkbox Tapped  ← Check_Tapped
// //   // ─────────────────────────────────────────────────────────
// //   void onLastCheckTapped(LastQueCheckModel selected) {
// //     try {
// //       final groupNode = treeList.firstWhereOrNull(
// //           (x) => x.id == _currentPageId);
// //       if (groupNode == null) return;

// //       for (final item in groupNode.lastQuestionList??[]) {
// //         if (item.id != selected.id) {
// //           item.isCheck = false;
// //         } else {
// //           item.isCheck = !item.isCheck;
// //           _gdDecision  = item.id;
// //         }
// //       }
// //       treeList.refresh();
// //     } catch (ex) {
// //       debugPrint("onLastCheckTapped: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Group text changed  ← Current_TextChanged
// //   // ─────────────────────────────────────────────────────────
// //   void onGroupTextChanged(GroupListModel group, String value) {
// //     group.currentLimit = value; // setter validates digits only
// //     treeList.refresh();
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Toolbar Image Icon  ← MenuItem1_Clicked
// //   // ─────────────────────────────────────────────────────────
// //   // void onImageIconPressed() {
// //   //   try {
// //   //     Get.to(
// //   //       () => GdImagePage(),
// //   //       arguments: {
// //   //         'gdImages'     : resultGD.gdImages ?? [],
// //   //         'title'        : loadCode,
// //   //         'sessionModel' : sessionModel,
// //   //         'vehicleModels': vehicleModels,
// //   //       },
// //   //     );
// //   //   } catch (ex) {
// //   //     debugPrint("onImageIconPressed: $ex");
// //   //   }
// //   // }

// //   // ─────────────────────────────────────────────────────────
// //   // Post GD Comment  ← apiServices.PostGdComment
// //   // ─────────────────────────────────────────────────────────
// //   Future<void> _postGdComment(TreeListModel currModel) async {
// //     try {
// //       final model = GdCommentModel(
// //         gd: [
// //           Gd(
// //             comment:     currModel.comment,
// //             description: currModel.description,
// //             name:        loadCode,
// //             status:      'NOT OK',
// //             created:     DateTime.now()
// //                 .toUtc()
// //                 .toIso8601String()
// //                 .replaceAll(RegExp(r'\.\d+'), ''),
// //           ),
// //         ],
// //       );

// //       // ── Check connectivity ───────────────────────────────
// //       final connectivity = await Connectivity().checkConnectivity();
// //       final hasInternet  = connectivity.contains(ConnectivityResult.mobile) ||
// //                            connectivity.contains(ConnectivityResult.wifi);

// //       if (hasInternet) {
// //         await _apiServices.postGdComment(model, sessionModel.id ?? 0);
// //       } else {
// //         // ── Save offline ─────────────────────────────────
// //         await _saveOfflineGdComment(model);
// //       }
// //     } catch (ex) {
// //       debugPrint("_postGdComment: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Save GD comment offline  ← ("OfflineAnalyze_GD").SaveData
// //   // ─────────────────────────────────────────────────────────
// //   Future<void> _saveOfflineGdComment(GdCommentModel model) async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final key   = 'OfflineAnalyze_GD';

// //       List<GdOfflineAnalyze> data = [];
// //       final existing = prefs.getString(key);
// //       if (existing != null && existing.isNotEmpty) {
// //         final decoded = jsonDecode(existing) as List;
// //         data = decoded.map((e) => GdOfflineAnalyze.fromJson(e)).toList();
// //       }

// //       data.add(GdOfflineAnalyze(
// //         gdCommentModel: model,
// //         srnId:          sessionModel.id,
// //         srNumber:       sessionModel.srNumber,
// //       ));

// //       await prefs.setString(key, jsonEncode(data.map((e) => e!.toJson()).toList()));
// //     } catch (ex) {
// //       debugPrint("_saveOfflineGdComment: $ex");
// //     }
// //   }

// //   // ─────────────────────────────────────────────────────────
// //   // Helpers
// //   // ─────────────────────────────────────────────────────────

// //   /// Matches C# GetGroupName()
// //   String _getGroupName(String type) {
// //     switch (type) {
// //       case 'radio':    return 'RadioData';
// //       case 'static':   return 'GroupData';
// //       case '':         return 'SimpleData';
// //       case 'LastData': return 'LastData';
// //       default:         return '';
// //     }
// //   }

// //   /// Matches C# text_val → text_value resolution
// //   String _resolveTextValue(String? textVal, int index) {
// //     final val = (textVal ?? '').toLowerCase().trim();
// //     if (val == 'ok' || val == 'true' || val == 'ok ') return 'OK';
// //     if (val.contains('not ok') || val.contains('false')) return 'NOT OK';
// //     return index == 0 ? 'OK' : 'NOT OK';
// //   }

// //   /// Populate group_list from type_form.groups
// //   void _populateGroupList(TreeListModel listModel, DataGD data) {
// //     final groups = data.typeForm?.groups ?? [];
// //     for (final g in groups) {
// //       final gm = GroupListModel();
// //       gm.entryDescription = g.entryDescription ?? '';
// //       gm.groupName        = g.groupName ?? '';
// //       gm.lowerLimit       = g.lowerLimit ?? '';
// //       gm.upperLimit       = g.upperLimit ?? '';
// //       gm.unit             = g.unit ?? '';
// //       listModel.groupList!.add(gm);
// //     }
// //   }

// //   /// Build last_question_list  ← ObservableCollection<LastQueCheckModel>
// //   List<LastQueCheckModel> _buildLastQuestionList({required bool isAllOk}) {
// //     if (isAllOk) {
// //       return [
// //         LastQueCheckModel()
// //           ..id      = 2
// //           ..describe = 'Restart GD'
// //           ..isCheck  = false,
// //         LastQueCheckModel()
// //           ..id      = 3
// //           ..describe = 'Quit GD'
// //           ..isCheck  = false,
// //       ];
// //     } else {
// //       return [
// //         LastQueCheckModel()
// //           ..id      = 1
// //           ..describe = 'Continue to next step'
// //           ..isCheck  = false,
// //         LastQueCheckModel()
// //           ..id      = 2
// //           ..describe = 'Restart GD'
// //           ..isCheck  = false,
// //         LastQueCheckModel()
// //           ..id      = 3
// //           ..describe = 'Quit GD'
// //           ..isCheck  = false,
// //       ];
// //     }
// //   }

// //   /// Alert helper  ← DisplayAlert
// //   void _showAlert(String message) {
// //     Get.dialog(
// //       AlertDialog(
// //         title: const Text("Alert"),
// //         content: Text(message),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Get.back(),
// //             child: const Text("OK"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   /// Back button disabled  ← OnBackButtonPressed() → false
// //   Future<bool> onWillPop() async => false;
// // }
// import 'dart:convert';

// import 'package:autopeepal/models/all_models.dart';
// import 'package:autopeepal/models/gd_model.dart';
// import 'package:autopeepal/models/offlineAnalyze_model.dart';
// import 'package:autopeepal/models/sessionList_model.dart';
// import 'package:autopeepal/models/treeList_model.dart';
// import 'package:autopeepal/routes/routes_string.dart';
// import 'package:autopeepal/services/api_services.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TreeSurveyController extends GetxController {

//   // ── Dependencies ──────────────────────────────────────────
//   final AuthApiService _apiServices = AuthApiService();

//   // ── Arguments ─────────────────────────────────────────────
//   late ResultGD resultGD;
//   late String loadDescription;
//   late String loadCode;
//   late SessionModel sessionModel;
//   late ModelResult vehicleModels;

//   // ── Reactive tree list ────────────────────────────────────
//   final RxList<TreeListModel> treeList = <TreeListModel>[].obs;
//   final RxBool isLoading = false.obs;

//   // ── Navigation state ──────────────────────────────────────
//   int _firstItem      = 0;
//   int _currentPageId  = -1;
//   int _nextPageId     = -1;
//   int _continuePageId = -1;
//   int _gdDecision     = -1;
//   String _currentPageType = '';

//   // ── Screen sizing ─────────────────────────────────────────
//   double screenHeight = 700;
//   int _lessHeight     = 82;

//   // ─────────────────────────────────────────────────────────
//   // onInit
//   // ─────────────────────────────────────────────────────────
//   @override
//   void onInit() {
//     super.onInit();

//     final args = Get.arguments as Map<String, dynamic>?;
//     if (args != null) {
//       resultGD        = args['gdData']        as ResultGD;
//       loadDescription = args['description']   as String? ?? '';
//       loadCode        = args['code']          as String? ?? '';
//       sessionModel    = args['sessionModel']  as SessionModel;
//       vehicleModels   = args['vehicleModels'] as ModelResult;
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final view = WidgetsBinding
//           .instance.platformDispatcher.views.first;
//       screenHeight = view.physicalSize.height / view.devicePixelRatio;
//       _lessHeight  = screenHeight < 900 ? 82 : 89;
//       _startGD(resultGD.treeSet?[0].treeData ?? []);
//     });
//   }

//   // ─────────────────────────────────────────────────────────
//   // StartGD
//   // ─────────────────────────────────────────────────────────
//   void _startGD(List<TreeDataGD> gdList) {
//     try {
//       _firstItem       = 0;
//       _currentPageId   = -1;
//       _nextPageId      = -1;
//       _gdDecision      = -1;
//       _continuePageId  = -1;
//       _currentPageType = '';
//       treeList.clear();

//       for (final item in gdList) {
//         final data = item.data;
//         if (data == null) continue;

//         final listModel = TreeListModel();
//         listModel.id          = item.id ?? 0;
//         listModel.description = data.description ?? '';
//         listModel.topic       = data.typeForm?.topic ?? '';

//         // ── Background / text color ────────────────────────
//         final topic = data.typeForm?.topic ?? '';
//         if (topic.contains("Root Cause")) {
//           listModel.descriptionBackgroundColor = '#FF0000';
//           listModel.descriptionTextColor       = '#FFFFFF';
//         } else {
//           listModel.descriptionBackgroundColor = '#FFFFFF';
//           listModel.descriptionTextColor       = '#4d4d4d';
//         }

//         // ── Build decision list ────────────────────────────
//         final decisionData = data.decisions?.data ?? [];
//         for (int i = 0; i < decisionData.length; i++) {
//           final d  = decisionData[i];
//           final dm = DecissionModel();
//           dm.isCheck      = false;
//           dm.newTextValue = d.textVal ?? '';
//           dm.nextNode     = d.node ?? 0;
//           dm.type         = d.type ?? '';
//           dm.id           = item.id ?? 0;
//           dm.textValue    = _resolveTextValue(d.textVal, i);
//           listModel.decissionList!.add(dm);   // ✅ no !
//         }

//         // ── Group name + node ids ──────────────────────────
//         final decisionsType = data.decisions?.type ?? '';

//         if (decisionsType.isEmpty) {
//           if (decisionData.isNotEmpty) {
//             final firstType = decisionData[0].type ?? '';
//             listModel.groupName =
//                 _getGroupName(firstType.isEmpty ? decisionsType : firstType);
//             listModel.okPageNodeId =
//                 decisionData[0].node ?? -1;
//             listModel.notOkPageNodeId =
//                 decisionData.length > 1 ? (decisionData[1].node ?? -1) : -1;

//             if (listModel.groupName == 'GroupData') {
//               _populateGroupList(listModel, data);
//             }
//           } else {
//             listModel.groupName       = _getGroupName('LastData');
//             listModel.okPageNodeId    = -1;
//             listModel.notOkPageNodeId = -1;
//             listModel.lastQuestionList!.assignAll(  // ✅ no !
//               _buildLastQuestionList(
//                 isAllOk: topic.contains("All Ok") ||
//                     gdList.length == (item.id ?? 0),
//               ),
//             );
//           }
//         } else {
//           if (decisionData.isNotEmpty) {
//             listModel.okPageNodeId =
//                 decisionData[0].node ?? -1;
//             listModel.notOkPageNodeId =
//                 decisionData.length > 1 ? (decisionData[1].node ?? -1) : -1;
//             listModel.groupName = _getGroupName(decisionsType);
//           } else {
//             listModel.okPageNodeId    = -1;
//             listModel.notOkPageNodeId = -1;
//             listModel.groupName       = _getGroupName('LastData');
//             listModel.lastQuestionList!.assignAll(  // ✅ no !
//               _buildLastQuestionList(
//                 isAllOk: topic.contains("All Ok") ||
//                     gdList.length == (item.id ?? 0),
//               ),
//             );
//           }
//         }

//         // ── Visibility: only first item visible ────────────
//         _firstItem++;
//         if (_firstItem == 1) {
//           listModel.pageVisible = true;
//           listModel.viewHeight  = screenHeight - _lessHeight;
//           _currentPageType      = listModel.groupName??'';  // ✅ no ??
//           _currentPageId        = listModel.id??0;          // ✅ no ??
//         } else {
//           listModel.pageVisible = false;
//           listModel.viewHeight  = 0;
//         }

//         treeList.add(listModel);
//       }
//     } catch (ex) {
//       debugPrint("_startGD error: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Decision Check Tapped
//   // ─────────────────────────────────────────────────────────
//   void onDecisionCheckTapped(
//       TreeListModel node, DecissionModel selected) {  // ✅ correct params
//     try {
//       for (final item in treeList) {
//         final found =
//             item.decissionList!.any((x) => x.id == selected.id); // ✅ no !
//         if (found) {
//           for (final d in item.decissionList??[]) {  // ✅ no ??
//             if (d.textValue == selected.textValue) {
//               d.isCheck      = !d.isCheck;
//               _nextPageId    = d.nextNode;
//               _currentPageId = selected.id??0;     // ✅ no ??
//               if (selected.textValue == 'NOT OK') {
//                 _continuePageId = d.nextNode - 1;
//               }
//               item.isCommentBoxVisible =
//                   selected.newTextValue!.toUpperCase().contains('NOT OK') ||
//                   selected.newTextValue!.toUpperCase().contains('FALSE');
//                                                  // ✅ no !
//             } else {
//               d.isCheck = false;
//             }
//           }
//         }
//       }
//       treeList.refresh();
//     } catch (ex) {
//       debugPrint("onDecisionCheckTapped: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Next Button
//   // ─────────────────────────────────────────────────────────
//   Future<void> onNextPressed(TreeListModel node) async {  // ✅ node param
//     isLoading.value = true;
//     await Future.delayed(const Duration(milliseconds: 50));

//     try {
//       if (_nextPageId < 0) {
//         _showAlert("Please select OK or NOT OK checkbox");
//         isLoading.value = false;
//         return;
//       }

//       if (_currentPageId == _nextPageId) {
//         _showAlert("Please select OK or NOT OK checkbox");
//         isLoading.value = false;
//         return;
//       }

//       // ── Hide current page ────────────────────────────────
//       final currModel = treeList.firstWhereOrNull(
//           (x) => x.id == _currentPageId);

//       if (currModel != null) {
//         currModel.pageVisible = false;
//         currModel.viewHeight  = 0;

//         final bool commentVisible = currModel.isCommentBoxVisible??false; // ✅ no ??
//         if (commentVisible) {
//           final String comment = currModel.comment??'';  // ✅ no ??
//           if (comment.isEmpty) {
//             _showAlert("Please enter comment");
//             isLoading.value = false;
//             return;
//           }
//           await _postGdComment(currModel);
//         }
//       }

//       // ── Show next page ───────────────────────────────────
//       final nextPage = treeList.firstWhereOrNull(
//           (x) => x.id == _nextPageId);

//       if (nextPage != null) {
//         nextPage.pageVisible = true;
//         nextPage.viewHeight  = screenHeight - _lessHeight;
//         _currentPageType     = nextPage.groupName??'';  // ✅ no ??
//       }

//       _currentPageId = _nextPageId;
//       treeList.refresh();

//       await Future.delayed(const Duration(milliseconds: 500));
//     } catch (ex) {
//       _showAlert("Error: ${ex.toString()}");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Group Next Button
//   // ─────────────────────────────────────────────────────────
//   Future<void> onGroupNextPressed(TreeListModel node) async {  // ✅ node param
//     try {
//       if (_currentPageType != 'GroupData') return;

//       final groupNode = treeList.firstWhereOrNull(
//           (x) => x.id == _currentPageId);
//       if (groupNode == null) return;

//       // ── Check all fields filled ──────────────────────────
//       final hasEmpty = groupNode.groupList !  // ✅ no !
//           .any((g) => g.currentLimit!.isEmpty);  // ✅ no !

//       if (hasEmpty) {
//         _showAlert("Please fill all fields");
//         return;
//       }

//       // ── Validate values ──────────────────────────────────
//       for (final g in groupNode.groupList??[]) {  // ✅ no ??
//         final current = double.tryParse(g.currentLimit);
//         final upper   = double.tryParse(g.upperLimit);
//         final lower   = double.tryParse(g.lowerLimit);

//         if (current != null && upper != null && lower != null) {
//           g.statusColor = (upper >= current && lower <= current)
//               ? '#00b800'
//               : '#FF0000';
//         }
//         g.upperLowerValueVisible = true;
//       }

//       // ── Decide next page ─────────────────────────────────
//       final hasFailed = groupNode.groupList!  // ✅ no !
//           .any((g) => g.statusColor == '#FF0000');

//       if (hasFailed) {
//         _nextPageId     = groupNode.notOkPageNodeId??0;  // ✅ no ??
//         _continuePageId = groupNode.okPageNodeId??0;      // ✅ no ??
//       } else {
//         _nextPageId      = groupNode.okPageNodeId??0;     // ✅ no ??
//         _currentPageType = groupNode.groupName??'';         // ✅ no ??
//       }

//       treeList.refresh();
//       await Future.delayed(const Duration(seconds: 4));

//       // ── Update visibility ────────────────────────────────
//       for (final item in treeList) {
//         if (item.id == _nextPageId) {
//           item.pageVisible = true;
//           item.viewHeight  = screenHeight - _lessHeight;
//         } else {
//           item.pageVisible = false;
//           item.viewHeight  = 0;
//         }
//       }

//       _currentPageId = _nextPageId;
//       treeList.refresh();
//     } catch (ex) {
//       debugPrint("onGroupNextPressed: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Last Page Next Button
//   // ─────────────────────────────────────────────────────────
//   Future<void> onLastPageNextPressed(TreeListModel node) async {  // ✅ node param
//     try {
//       if (_gdDecision == 1) {
//         // ── Continue to next step ──────────────────────────
//         final nextPage = treeList.firstWhereOrNull(
//             (x) => x.id == _continuePageId);

//         if (nextPage == null) return;

//         if (_continuePageId == _currentPageId) {
//           _showAlert("This is last page");
//           return;
//         }

//         nextPage.pageVisible = true;
//         nextPage.viewHeight  = screenHeight - _lessHeight;
//         _currentPageType     = nextPage.groupName??'';  // ✅ no ??
//         _currentPageId       = _nextPageId;

//         final list = treeList.firstWhereOrNull(
//             (x) => x.id == _currentPageId);
//         if (list != null) {
//           list.pageVisible = false;
//           list.viewHeight  = 0;
//         }

//         _nextPageId = _currentPageId = nextPage.id??0;  // ✅ no ??
//         treeList.refresh();

//       } else if (_gdDecision == 2) {
//         // ── Restart GD ────────────────────────────────────
//         Get.back();  // ✅ no await

//       } else if (_gdDecision == 3) {
//         // ── Quit GD ───────────────────────────────────────
//         Get.toNamed(  // ✅ toNamed not to
//           Routes.dtcScreen,
//           arguments: {
//             'sessionModel' : sessionModel,
//             'vehicleModels': vehicleModels,
//           },
//         );
//       }
//     } catch (ex) {
//       debugPrint("onLastPageNextPressed: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Last Checkbox Tapped
//   // ─────────────────────────────────────────────────────────
//   void onLastCheckTapped(
//       TreeListModel node, LastQueCheckModel selected) {  // ✅ correct params
//     try {
//       final groupNode = treeList.firstWhereOrNull(
//           (x) => x.id == _currentPageId);
//       if (groupNode == null) return;

//       for (final item in groupNode.lastQuestionList??[]) {  // ✅ no ??
//         if (item.id != selected.id) {
//           item.isCheck = false;
//         } else {
//           item.isCheck = !item.isCheck;
//           _gdDecision  = item.id;
//         }
//       }
//       treeList.refresh();
//     } catch (ex) {
//       debugPrint("onLastCheckTapped: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Group Text Changed
//   // ─────────────────────────────────────────────────────────
//   void onGroupTextChanged(GroupListModel group, String value) {
//     group.currentLimit = value;
//     treeList.refresh();
//   }

//   // ─────────────────────────────────────────────────────────
//   // Image Icon Pressed
//   // ─────────────────────────────────────────────────────────
//   void onImageIconPressed() {
//     try {
//       // Uncomment when GdImagePage is ready
//       // Get.to(
//       //   () => GdImagePage(),
//       //   arguments: {
//       //     'gdImages'     : resultGD.gdImages ?? [],
//       //     'title'        : loadCode,
//       //     'sessionModel' : sessionModel,
//       //     'vehicleModels': vehicleModels,
//       //   },
//       // );
//     } catch (ex) {
//       debugPrint("onImageIconPressed: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Post GD Comment
//   // ─────────────────────────────────────────────────────────
//   Future<void> _postGdComment(TreeListModel currModel) async {
//     try {
//       final model = GdCommentModel(
//         gd: [
//           Gd(
//             comment:     currModel.comment,      // ✅ no ??
//             description: currModel.description,  // ✅ no ??
//             name:        loadCode,
//             status:      'NOT OK',
//             created:     DateTime.now()
//                 .toUtc()
//                 .toIso8601String()
//                 .replaceAll(RegExp(r'\.\d+'), ''),
//           ),
//         ],
//       );

//       final connectivity = await Connectivity().checkConnectivity();
//       final hasInternet  =
//           connectivity.contains(ConnectivityResult.mobile) ||
//           connectivity.contains(ConnectivityResult.wifi);

//       if (hasInternet) {
//         await _apiServices.postGdComment(model, sessionModel.id ?? 0);
//       } else {
//         await _saveOfflineGdComment(model);
//       }
//     } catch (ex) {
//       debugPrint("_postGdComment: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Save GD Comment Offline
//   // ─────────────────────────────────────────────────────────
//   Future<void> _saveOfflineGdComment(GdCommentModel model) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       const key   = 'OfflineAnalyze_GD';

//       List<GdOfflineAnalyze> data = [];
//       final existing = prefs.getString(key);
//       if (existing != null && existing.isNotEmpty) {
//         final decoded = jsonDecode(existing) as List;
//         data = decoded
//             .map((e) => GdOfflineAnalyze.fromJson(e))
//             .toList();
//       }

//       data.add(GdOfflineAnalyze(
//         gdCommentModel: model,
//         srnId:          sessionModel.id,
//         srNumber:       sessionModel.srNumber,
//       ));

//       await prefs.setString(
//         key,
//         jsonEncode(data.map((e) => e.toJson()).toList()),  // ✅ no !
//       );
//     } catch (ex) {
//       debugPrint("_saveOfflineGdComment: $ex");
//     }
//   }

//   // ─────────────────────────────────────────────────────────
//   // Helpers
//   // ─────────────────────────────────────────────────────────
//   String _getGroupName(String type) {
//     switch (type) {
//       case 'radio':    return 'RadioData';
//       case 'static':   return 'GroupData';
//       case '':         return 'SimpleData';
//       case 'LastData': return 'LastData';
//       default:         return '';
//     }
//   }

//   String _resolveTextValue(String? textVal, int index) {
//     final val = (textVal ?? '').toLowerCase().trim();
//     if (val == 'ok' || val == 'true' || val == 'ok ') return 'OK';
//     if (val.contains('not ok') || val.contains('false')) return 'NOT OK';
//     return index == 0 ? 'OK' : 'NOT OK';
//   }

//   void _populateGroupList(TreeListModel listModel, DataGD data) {
//     final groups = data.typeForm?.groups ?? [];
//     for (final g in groups) {
//       final gm = GroupListModel();
//       gm.entryDescription = g.entryDescription ?? '';
//       gm.groupName        = g.groupName ?? '';
//       gm.lowerLimit       = g.lowerLimit ?? '';
//       gm.upperLimit       = g.upperLimit ?? '';
//       gm.unit             = g.unit ?? '';
//       listModel.groupList!.add(gm);  // ✅ no !
//     }
//   }

//   List<LastQueCheckModel> _buildLastQuestionList({required bool isAllOk}) {
//     if (isAllOk) {
//       return [
//         LastQueCheckModel()
//           ..id      = 2
//           ..describe = 'Restart GD'
//           ..isCheck  = false,
//         LastQueCheckModel()
//           ..id      = 3
//           ..describe = 'Quit GD'
//           ..isCheck  = false,
//       ];
//     } else {
//       return [
//         LastQueCheckModel()
//           ..id      = 1
//           ..describe = 'Continue to next step'
//           ..isCheck  = false,
//         LastQueCheckModel()
//           ..id      = 2
//           ..describe = 'Restart GD'
//           ..isCheck  = false,
//         LastQueCheckModel()
//           ..id      = 3
//           ..describe = 'Quit GD'
//           ..isCheck  = false,
//       ];
//     }
//   }

//   void _showAlert(String message) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text("Alert"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> onWillPop() async => false;
// }

// tree_survey_controller.dart

import 'dart:convert';

import 'package:autopeepal/logic/controller/appFeature/treeListModel.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/offlineAnalyze_model.dart';
import 'package:autopeepal/models/sessionList_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TreeSurveyController extends GetxController {

  // ── Dependencies ──────────────────────────────────────────
  final AuthApiService _apiServices = AuthApiService();

  // ── Arguments ─────────────────────────────────────────────
  late ResultGD resultGD;
  late String loadDescription;
  late String loadCode;
  late SessionModel sessionModel;
  late ModelResult vehicleModels;

  // ── Reactive tree list ────────────────────────────────────
  final RxList<TreeListModel> treeList = <TreeListModel>[].obs;
  final RxBool isLoading = false.obs;

  // ── Navigation state ──────────────────────────────────────
  int _firstItem      = 0;
  int _currentPageId  = -1;
  int _nextPageId     = -1;
  int _continuePageId = -1;
  int _gdDecision     = -1;
  String _currentPageType = '';

  // ── Screen sizing ─────────────────────────────────────────
  double screenHeight = 700;
  int _lessHeight     = 82;

  // ─────────────────────────────────────────────────────────
  // onInit
  // ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      resultGD        = args['gdData']        as ResultGD;
      loadDescription = args['description']   as String? ?? '';
      loadCode        = args['code']          as String? ?? '';
      sessionModel    = args['sessionModel']  as SessionModel;
      vehicleModels   = args['vehicleModels'] as ModelResult;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final view   = WidgetsBinding.instance.platformDispatcher.views.first;
      screenHeight = view.physicalSize.height / view.devicePixelRatio;
      _lessHeight  = screenHeight < 900 ? 82 : 89;
      _startGD(resultGD.treeSet?[0].treeData ?? []);
    });
  }

  // ─────────────────────────────────────────────────────────
  // StartGD  ← C# StartGD()
  // ─────────────────────────────────────────────────────────
 void _startGD(List<TreeDataGD> gdList) {
  try {
    _firstItem       = 0;
    _currentPageId   = -1;
    _nextPageId      = -1;
    _gdDecision      = -1;
    _continuePageId  = -1;
    _currentPageType = '';
    treeList.clear();

    for (final item in gdList) {
      final data = item.data;
      if (data == null) continue;

      final listModel = TreeListModel();
      listModel.id          = item.id ?? 0;
      listModel.description = data.description ?? '';
      listModel.topic       = data.typeForm?.topic ?? '';

      // ── Background / text color ──────────────────────────
      final topic = data.typeForm?.topic ?? '';
      if (topic.contains("Root Cause")) {
        listModel.descriptionBackgroundColor = '#FF0000';
        listModel.descriptionTextColor       = '#FFFFFF';
      } else {
        listModel.descriptionBackgroundColor = '#FFFFFF';
        listModel.descriptionTextColor       = '#4d4d4d';
      }

      // ── Build decision list ──────────────────────────────
      final decisionData = data.decisions?.data ?? [];
      for (int i = 0; i < decisionData.length; i++) {
        final d  = decisionData[i];
        final dm = DecissionModel();
        dm.isCheck      = false;
        dm.newTextValue = d.textVal ?? '';
        dm.nextNode     = d.node ?? 0;
        dm.type         = d.type ?? '';
        dm.id           = item.id ?? 0;
        dm.textValue    = _resolveTextValue(d.textVal, i);
        listModel.decissionList.add(dm);  // ✅ FIXED: removed !
      }

      // ── Group name + node ids ────────────────────────────
      final decisionsType = data.decisions?.type ?? '';

      if (decisionsType.isEmpty) {
        if (decisionData.isNotEmpty) {
          final firstType = decisionData[0].type ?? '';
          listModel.groupName =
              _getGroupName(firstType.isEmpty ? decisionsType : firstType);
          listModel.okPageNodeId =
              decisionData[0].node ?? -1;
          listModel.notOkPageNodeId =
              decisionData.length > 1 ? (decisionData[1].node ?? -1) : -1;

          if (listModel.groupName == 'GroupData') {
            _populateGroupList(listModel, data);
          }
        } else {
          listModel.groupName       = _getGroupName('LastData');
          listModel.okPageNodeId    = -1;
          listModel.notOkPageNodeId = -1;
          listModel.lastQuestionList.assignAll(  // ✅ FIXED: removed !
            _buildLastQuestionList(
              isAllOk: topic.contains("All Ok") ||
                  gdList.length == (item.id ?? 0),
            ),
          );
        }
      } else {
        if (decisionData.isNotEmpty) {
          listModel.okPageNodeId =
              decisionData[0].node ?? -1;
          listModel.notOkPageNodeId =
              decisionData.length > 1 ? (decisionData[1].node ?? -1) : -1;
          listModel.groupName = _getGroupName(decisionsType);
        } else {
          listModel.okPageNodeId    = -1;
          listModel.notOkPageNodeId = -1;
          listModel.groupName       = _getGroupName('LastData');
          listModel.lastQuestionList.assignAll(  // ✅ FIXED: removed !
            _buildLastQuestionList(
              isAllOk: topic.contains("All Ok") ||
                  gdList.length == (item.id ?? 0),
            ),
          );
        }
      }

      // ── Visibility: only first item visible ──────────────
      _firstItem++;
      if (_firstItem == 1) {
        listModel.pageVisible = true;
        listModel.viewHeight  = screenHeight - _lessHeight;
        _currentPageType      = listModel.groupName;  // ✅ FIXED: removed ??
        _currentPageId        = listModel.id;          // ✅ FIXED: removed ??
      } else {
        listModel.pageVisible = false;
        listModel.viewHeight  = 0;
      }

      treeList.add(listModel);
    }
  } catch (ex, stackTrace) {
    debugPrint("_startGD error: $ex");
    debugPrint("_startGD trace: $stackTrace");  // ✅ shows exact line
  }
}
  // ─────────────────────────────────────────────────────────
  // Decision Check Tapped  ← Decission_Check_Tapped
  // ─────────────────────────────────────────────────────────
  void onDecisionCheckTapped(
      TreeListModel node, DecissionModel selected) {
    try {
      for (final item in treeList) {
        final found = item.decissionList.any(  // ✅ no !
            (x) => x.id == selected.id);
        if (found) {
          for (final d in item.decissionList) {  // ✅ no ??
            if (d.textValue == selected.textValue) {
              d.isCheck      = !d.isCheck;
              _nextPageId    = d.nextNode;
              _currentPageId = selected.id;       // ✅ int — no ??
              if (selected.textValue == 'NOT OK') {
                _continuePageId = d.nextNode - 1;
              }
              item.isCommentBoxVisible =
                  selected.newTextValue.toUpperCase().contains('NOT OK') ||
                  selected.newTextValue.toUpperCase().contains('FALSE');
                  // ✅ String — no !
            } else {
              d.isCheck = false;
            }
          }
        }
      }
      treeList.refresh();
    } catch (ex) {
      debugPrint("onDecisionCheckTapped: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Next Button  ← btnNext_Clicked
  // ─────────────────────────────────────────────────────────
  Future<void> onNextPressed(TreeListModel node) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      if (_nextPageId < 0) {
        _showAlert("Please select OK or NOT OK checkbox");
        isLoading.value = false;
        return;
      }

      if (_currentPageId == _nextPageId) {
        _showAlert("Please select OK or NOT OK checkbox");
        isLoading.value = false;
        return;
      }

      // ── Hide current page ──────────────────────────────
      final currModel = treeList.firstWhereOrNull(
          (x) => x.id == _currentPageId);

      if (currModel != null) {
        currModel.pageVisible = false;
        currModel.viewHeight  = 0;

        final bool commentVisible = currModel.isCommentBoxVisible;  // ✅ bool — no ??
        if (commentVisible) {
          final String comment = currModel.comment;  // ✅ String — no ??
          if (comment.isEmpty) {
            _showAlert("Please enter comment");
            isLoading.value = false;
            return;
          }
          await _postGdComment(currModel);
        }
      }

      // ── Show next page ─────────────────────────────────
      final nextPage = treeList.firstWhereOrNull(
          (x) => x.id == _nextPageId);

      if (nextPage != null) {
        nextPage.pageVisible = true;
        nextPage.viewHeight  = screenHeight - _lessHeight;
        _currentPageType     = nextPage.groupName;  // ✅ String — no ??
      }

      _currentPageId = _nextPageId;
      treeList.refresh();

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (ex) {
      _showAlert("Error: ${ex.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Group Next Button  ← btnGroupNext_Clicked
  // ─────────────────────────────────────────────────────────
  Future<void> onGroupNextPressed(TreeListModel node) async {
    try {
      if (_currentPageType != 'GroupData') return;

      final groupNode = treeList.firstWhereOrNull(
          (x) => x.id == _currentPageId);
      if (groupNode == null) return;

      // ── Check all fields filled ────────────────────────
      final hasEmpty = groupNode.groupList  // ✅ RxList — no !
          .any((g) => g.currentLimit.isEmpty);  // ✅ String — no !

      if (hasEmpty) {
        _showAlert("Please fill all fields");
        return;
      }

      // ── Validate values ────────────────────────────────
      for (final g in groupNode.groupList) {  // ✅ RxList — no ??
        final current = double.tryParse(g.currentLimit);
        final upper   = double.tryParse(g.upperLimit);
        final lower   = double.tryParse(g.lowerLimit);

        if (current != null && upper != null && lower != null) {
          g.statusColor = (upper >= current && lower <= current)
              ? '#00b800'
              : '#FF0000';
        }
        g.upperLowerValueVisible = true;
      }

      // ── Decide next page ───────────────────────────────
      final hasFailed = groupNode.groupList  // ✅ no !
          .any((g) => g.statusColor == '#FF0000');

      if (hasFailed) {
        _nextPageId     = groupNode.notOkPageNodeId;  // ✅ int — no ??
        _continuePageId = groupNode.okPageNodeId;
      } else {
        _nextPageId      = groupNode.okPageNodeId;
        _currentPageType = groupNode.groupName;
      }

      treeList.refresh();

      // ── Delay 4s  ← C# await Task.Delay(4000) ─────────
      await Future.delayed(const Duration(seconds: 4));

      // ── Update visibility ──────────────────────────────
      for (final item in treeList) {
        if (item.id == _nextPageId) {
          item.pageVisible = true;
          item.viewHeight  = screenHeight - _lessHeight;
        } else {
          item.pageVisible = false;
          item.viewHeight  = 0;
        }
      }

      _currentPageId = _nextPageId;
      treeList.refresh();
    } catch (ex) {
      debugPrint("onGroupNextPressed: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Last Page Next Button  ← btnLastPageNext_Clicked
  // ─────────────────────────────────────────────────────────
  Future<void> onLastPageNextPressed(TreeListModel node) async {
    try {
      if (_gdDecision == 1) {
        // ── Continue to next step ────────────────────────
        final nextPage = treeList.firstWhereOrNull(
            (x) => x.id == _continuePageId);

        if (nextPage == null) return;

        if (_continuePageId == _currentPageId) {
          _showAlert("This is last page");
          return;
        }

        nextPage.pageVisible = true;
        nextPage.viewHeight  = screenHeight - _lessHeight;
        _currentPageType     = nextPage.groupName;  // ✅ no ??
        _currentPageId       = _nextPageId;

        final list = treeList.firstWhereOrNull(
            (x) => x.id == _currentPageId);
        if (list != null) {
          list.pageVisible = false;
          list.viewHeight  = 0;
        }

        _nextPageId = _currentPageId = nextPage.id;  // ✅ int — no ??
        treeList.refresh();

      } else if (_gdDecision == 2) {
        // ── Restart GD ─────────────────────────────────
        Get.back();  // ✅ no await

      } else if (_gdDecision == 3) {
        // ── Quit GD ────────────────────────────────────
        Get.toNamed(  // ✅ toNamed for String route
          Routes.dtcScreen,
          arguments: {
            'sessionModel' : sessionModel,
            'vehicleModels': vehicleModels,
          },
        );
      }
    } catch (ex) {
      debugPrint("onLastPageNextPressed: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Last Checkbox Tapped  ← Check_Tapped
  // ─────────────────────────────────────────────────────────
  void onLastCheckTapped(
      TreeListModel node, LastQueCheckModel selected) {
    try {
      final groupNode = treeList.firstWhereOrNull(
          (x) => x.id == _currentPageId);
      if (groupNode == null) return;

      for (final item in groupNode.lastQuestionList) {  // ✅ RxList — no ??
        if (item.id != selected.id) {
          item.isCheck = false;
        } else {
          item.isCheck = !item.isCheck;
          _gdDecision  = item.id;
        }
      }
      treeList.refresh();
    } catch (ex) {
      debugPrint("onLastCheckTapped: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Group Text Changed  ← Current_TextChanged
  // ─────────────────────────────────────────────────────────
  void onGroupTextChanged(GroupListModel group, String value) {
    group.currentLimit = value;  // setter validates digits only
    treeList.refresh();
  }

  // ─────────────────────────────────────────────────────────
  // Image Icon Pressed  ← MenuItem1_Clicked
  // ─────────────────────────────────────────────────────────
  void onImageIconPressed() {
    try {
      Get.toNamed(
        Routes.gdImagePage,
        arguments: {
          'gdImages'     : resultGD.gdImages ?? [],
          'title'        : loadCode,
          'sessionModel' : sessionModel,
          'vehicleModels': vehicleModels,
        },
      );
    } catch (ex) {
      debugPrint("onImageIconPressed: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Post GD Comment  ← apiServices.PostGdComment
  // ─────────────────────────────────────────────────────────
  Future<void> _postGdComment(TreeListModel currModel) async {
    try {
      final model = GdCommentModel(
        gd: [
          Gd(
            comment:     currModel.comment,      // ✅ String — no ??
            description: currModel.description,  // ✅ String — no ??
            name:        loadCode,
            status:      'NOT OK',
            created:     DateTime.now()
                .toUtc()
                .toIso8601String()
                .replaceAll(RegExp(r'\.\d+'), ''),
          ),
        ],
      );

      final connectivity = await Connectivity().checkConnectivity();
      final hasInternet  =
          connectivity.contains(ConnectivityResult.mobile) ||
          connectivity.contains(ConnectivityResult.wifi);

      if (hasInternet) {
        await _apiServices.postGdComment(model, sessionModel.id ?? 0);
      } else {
        await _saveOfflineGdComment(model);
      }
    } catch (ex) {
      debugPrint("_postGdComment: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Save GD Comment Offline
  // ─────────────────────────────────────────────────────────
  Future<void> _saveOfflineGdComment(GdCommentModel model) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      const key     = 'OfflineAnalyze_GD';

      List<GdOfflineAnalyze> data = [];
      final existing = prefs.getString(key);
      if (existing != null && existing.isNotEmpty) {
        final decoded = jsonDecode(existing) as List;
        data = decoded.map((e) => GdOfflineAnalyze.fromJson(e)).toList();
      }

      data.add(GdOfflineAnalyze(
        gdCommentModel: model,
        srnId:          sessionModel.id,
        srNumber:       sessionModel.srNumber,
      ));

      await prefs.setString(
        key,
        jsonEncode(data.map((e) => e.toJson()).toList()),  // ✅ no !
      );
    } catch (ex) {
      debugPrint("_saveOfflineGdComment: $ex");
    }
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────

  /// GetGroupName  ← C# GetGroupName()
  String _getGroupName(String type) {
    switch (type) {
      case 'radio':    return 'RadioData';
      case 'static':   return 'GroupData';
      case '':         return 'SimpleData';
      case 'LastData': return 'LastData';
      default:         return '';
    }
  }

  /// text_val → text_value
  String _resolveTextValue(String? textVal, int index) {
    final val = (textVal ?? '').toLowerCase().trim();
    if (val == 'ok' || val == 'true' || val == 'ok ') return 'OK';
    if (val.contains('not ok') || val.contains('false')) return 'NOT OK';
    return index == 0 ? 'OK' : 'NOT OK';
  }
void _populateGroupList(TreeListModel listModel, DataGD data) {
  final groups = data.typeForm?.groups ?? [];
  for (final g in groups) {
    final gm        = GroupListModel();
    gm.entryDescription = g.entryDescription ?? '';
    gm.groupName        = g.groupName        ?? '';
    gm.lowerLimit       = g.lowerLimit        ?? '';
    gm.upperLimit       = g.upperLimit        ?? '';
    gm.unit             = g.unit              ?? '';
    listModel.groupList.add(gm);  // ✅ FIXED: removed !
  }
}

  /// Build last_question_list
  List<LastQueCheckModel> _buildLastQuestionList({required bool isAllOk}) {
    if (isAllOk) {
      return [
        LastQueCheckModel()
          ..id       = 2
          ..describe = 'Restart GD'
          ..isCheck  = false,
        LastQueCheckModel()
          ..id       = 3
          ..describe = 'Quit GD'
          ..isCheck  = false,
      ];
    } else {
      return [
        LastQueCheckModel()
          ..id       = 1
          ..describe = 'Continue to next step'
          ..isCheck  = false,
        LastQueCheckModel()
          ..id       = 2
          ..describe = 'Restart GD'
          ..isCheck  = false,
        LastQueCheckModel()
          ..id       = 3
          ..describe = 'Quit GD'
          ..isCheck  = false,
      ];
    }
  }

  /// Alert helper  ← DisplayAlert
  void _showAlert(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text("Alert"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Back button disabled  ← OnBackButtonPressed() → false
  Future<bool> onWillPop() async => false;
}