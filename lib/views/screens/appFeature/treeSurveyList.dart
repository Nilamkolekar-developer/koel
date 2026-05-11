// // tree_survey_page.dart

// import 'package:autopeepal/logic/controller/appFeature/treeListModel.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:autopeepal/logic/controller/appFeature/treeSurveyListController.dart';

// // ── Hex to Color helper ───────────────────────────────────────
// Color _hexToColor(String hex) {
//   try {
//     final h = hex.replaceAll('#', '');
//     return Color(int.parse('FF$h', radix: 16));
//   } catch (_) {
//     return Colors.white;
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // TreeSurveyPage
// // ─────────────────────────────────────────────────────────────
// class TreeSurveyPage extends StatelessWidget {
//   const TreeSurveyPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(TreeSurveyController());
//     final themeColor = Theme.of(context).primaryColor;

//     return WillPopScope(
//       onWillPop: controller.onWillPop,
//       child: Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.background,
//         appBar: AppBar(
//           title: Text(controller.loadCode),
//           automaticallyImplyLeading: false,
//           actions: [
//             IconButton(
//               icon: Image.asset(
//                 'assets/new/ic_gdimage.png',
//                 width: 24,
//                 height: 24,
//               ),
//               onPressed: controller.onImageIconPressed,
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.only(bottom: 40),
//           child: Obx(() => ListView.builder(
//             itemCount: controller.treeList.length,
//             itemBuilder: (context, index) {
//               final TreeListModel node = controller.treeList[index];
//               return Obx(() {
//                 final bool isVisible = node.pageVisible; // ✅ local bool
//                 final double height  = node.viewHeight;   // ✅ local double
//                 if (!isVisible) return const SizedBox.shrink();
//                 return SizedBox(
//                   height: height,
//                   child: _buildTemplate(
//                       context, controller, node, themeColor),
//                 );
//               });
//             },
//           )),
//         ),
//       ),
//     );
//   }

//   Widget _buildTemplate(
//     BuildContext context,
//     TreeSurveyController controller,
//     TreeListModel node,
//     Color themeColor,
//   ) {
//     switch (node.groupName) {
//       case 'GroupData':
//         return _GroupTemplate(
//             controller: controller, node: node, themeColor: themeColor);
//       case 'LastData':
//         return _LastTemplate(
//             controller: controller, node: node, themeColor: themeColor);
//       default:
//         return _SimpleRadioTemplate(
//             controller: controller, node: node, themeColor: themeColor);
//     }
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Shared: Description Card
// // ─────────────────────────────────────────────────────────────
// class _DescriptionCard extends StatelessWidget {
//   final TreeListModel node;
//   const _DescriptionCard({required this.node});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
//       margin: const EdgeInsets.all(1),
//       color: _hexToColor(node.descriptionBackgroundColor), // ✅ no ??
//       child: Padding(
//         padding: const EdgeInsets.all(5),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 40,
//               child: Text(
//                 node.topic,                               // ✅ no ??
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: _hexToColor(node.descriptionTextColor), // ✅ no ??
//                 ),
//               ),
//             ),
//             const Divider(color: Colors.grey, height: 1, thickness: 1),
//             const SizedBox(height: 4),
//             Text(
//               node.description,                           // ✅ no ??
//               style: TextStyle(
//                 color: _hexToColor(node.descriptionTextColor), // ✅ no ??
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Shared: Next Button
// // ─────────────────────────────────────────────────────────────
// class _NextButton extends StatelessWidget {
//   final String label;
//   final Color themeColor;
//   final VoidCallback onPressed;

//   const _NextButton({
//     // ignore: unused_element_parameter
//     this.label = 'Next',
//     required this.themeColor,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
//     final double hMargin = isTablet ? 160.0 : 100.0;

//     return Padding(
//       padding: EdgeInsets.fromLTRB(hMargin, 0, hMargin, 5),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: themeColor,
//           foregroundColor: Colors.white,
//           minimumSize: const Size(double.infinity, 48),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         child: Text(label),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Template 1 & 2: SimpleData + RadioData
// // ─────────────────────────────────────────────────────────────
// class _SimpleRadioTemplate extends StatelessWidget {
//   final TreeSurveyController controller;
//   final TreeListModel node;
//   final Color themeColor;

//   const _SimpleRadioTemplate({
//     required this.controller,
//     required this.node,
//     required this.themeColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _DescriptionCard(node: node),
//                 const SizedBox(height: 20),

//                 // ── Decision List ──────────────────────────
//                 Obx(() => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Column(
//                     children: node.decissionList   // ✅ no ! no ??
//                         .map((DecissionModel decision) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 30),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: 40,
//                               child: Stack(
//                                 children: [
//                                   Checkbox(
//                                     value: decision.isCheck,  // ✅ non-null
//                                     activeColor: themeColor,
//                                     onChanged: (bool? val) {
//                                       controller.onDecisionCheckTapped(
//                                           node, decision);
//                                     },
//                                   ),
//                                   Positioned.fill(
//                                     child: GestureDetector(
//                                       onTap: () =>
//                                           controller.onDecisionCheckTapped(
//                                               node, decision),
//                                       behavior: HitTestBehavior.translucent,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               child: Text(
//                                 decision.newTextValue,   // ✅ no ??
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 )),

//                 const SizedBox(height: 10),

//                 // ── Comment Box ────────────────────────────
//                 Obx(() {
//                   final bool visible = node.isCommentBoxVisible; // ✅ local bool
//                   if (!visible) return const SizedBox.shrink();
//                   return Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: themeColor),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 5),
//                     child: TextField(
//                       maxLines: 4,
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         hintText: 'Enter Comment',
//                       ),
//                       onChanged: (val) => node.comment = val,
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),

//         _NextButton(
//           themeColor: themeColor,
//           onPressed: () => controller.onNextPressed(node),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Template 3: GroupData
// // ─────────────────────────────────────────────────────────────
// class _GroupTemplate extends StatelessWidget {
//   final TreeSurveyController controller;
//   final TreeListModel node;
//   final Color themeColor;

//   const _GroupTemplate({
//     required this.controller,
//     required this.node,
//     required this.themeColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _DescriptionCard(node: node),
//                 const SizedBox(height: 20),

//                 // ── Group List ─────────────────────────────
//                 Obx(() => Column(
//                   children: node.groupList   // ✅ no ! no ??
//                       .map((GroupListModel group) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // entry_description
//                           SizedBox(
//                             height: isTablet ? 35 : 28,
//                             child: Text(
//                               group.entryDescription,   // ✅ no ??
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),

//                           // Input + Max/Min row
//                           SizedBox(
//                             height: isTablet ? 45 : 42,
//                             child: Row(
//                               children: [
//                                 // Input field
//                                 Expanded(
//                                   flex: isTablet ? 40 : 45,
//                                   child: Obx(() => Container(
//                                     color: _hexToColor(
//                                         group.statusColor), // ✅ no ??
//                                     child: TextField(
//                                       keyboardType: TextInputType.number,
//                                       decoration: InputDecoration(
//                                         hintText: group.unit, // ✅ no ??
//                                         contentPadding:
//                                             const EdgeInsets.all(8),
//                                         border: const OutlineInputBorder(),
//                                       ),
//                                       onChanged: (val) =>
//                                           controller.onGroupTextChanged(
//                                               group, val),
//                                     ),
//                                   )),
//                                 ),

//                                 // Spacer tablet only
//                                 if (isTablet)
//                                   const Expanded(
//                                       flex: 10, child: SizedBox()),

//                                 // Max / Min values
//                                 Obx(() {
//                                   final bool show =
//                                       group.upperLowerValueVisible; // ✅ local bool
//                                   if (!show) return const SizedBox.shrink();
//                                   return Expanded(
//                                     flex: isTablet ? 50 : 55,
//                                     child: Row(
//                                       children: [
//                                         // Max
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text("Max Value",
//                                                   style: TextStyle(
//                                                       fontSize: isTablet
//                                                           ? 15
//                                                           : 13)),
//                                               Text(group.upperLimit, // ✅ no ??
//                                                   style: TextStyle(
//                                                       fontSize: isTablet
//                                                           ? 15
//                                                           : 13)),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(width: 15),
//                                         // Min
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text("Min Value",
//                                                   style: TextStyle(
//                                                       fontSize: isTablet
//                                                           ? 15
//                                                           : 13)),
//                                               Text(group.lowerLimit, // ✅ no ??
//                                                   style: TextStyle(
//                                                       fontSize: isTablet
//                                                           ? 15
//                                                           : 13)),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 )),
//               ],
//             ),
//           ),
//         ),

//         _NextButton(
//           themeColor: themeColor,
//           onPressed: () => controller.onGroupNextPressed(node),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Template 4: LastData
// // ─────────────────────────────────────────────────────────────
// class _LastTemplate extends StatelessWidget {
//   final TreeSurveyController controller;
//   final TreeListModel node;
//   final Color themeColor;

//   const _LastTemplate({
//     required this.controller,
//     required this.node,
//     required this.themeColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _DescriptionCard(node: node),
//                 const SizedBox(height: 20),

//                 // ── Last Question List ─────────────────────
//                 Obx(() => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Column(
//                     children: node.lastQuestionList   // ✅ no ! no ??
//                         .map((LastQueCheckModel question) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 30),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: 40,
//                               child: Stack(
//                                 children: [
//                                   Checkbox(
//                                     value: question.isCheck, // ✅ non-null
//                                     activeColor: themeColor,
//                                     onChanged: (bool? val) {
//                                       controller.onLastCheckTapped(
//                                           node, question);
//                                     },
//                                   ),
//                                   Positioned.fill(
//                                     child: GestureDetector(
//                                       onTap: () =>
//                                           controller.onLastCheckTapped(
//                                               node, question),
//                                       behavior: HitTestBehavior.translucent,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               child: Text(
//                                 question.describe,   // ✅ no ??
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 )),
//               ],
//             ),
//           ),
//         ),

//         _NextButton(
//           themeColor: themeColor,
//           onPressed: () => controller.onLastPageNextPressed(node),
//         ),
//       ],
//     );
//   }
// }
// tree_survey_page.dart

import 'package:autopeepal/logic/controller/appFeature/treeListModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/logic/controller/appFeature/treeSurveyListController.dart';

// ── Constants ─────────────────────────────────────────────────
const Color _kThemeColor   = Color(0xFF309F93);
const Color _kPageBgColor  = Color(0xFFF5F5F5);
const Color _kCardColor    = Colors.white;

// ── Hex to Color ──────────────────────────────────────────────
Color _hexToColor(String hex) {
  try {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return Colors.white;
  }
}

// ─────────────────────────────────────────────────────────────
// TreeSurveyPage
// ─────────────────────────────────────────────────────────────
class TreeSurveyPage extends StatelessWidget {
  const TreeSurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TreeSurveyController());

    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: Scaffold(
        backgroundColor: _kPageBgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            controller.loadCode,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/new/ic_gdimage.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image, color: Colors.black),
              ),
              onPressed: controller.onImageIconPressed,
            ),
          ],
        ),
        body: Obx(() => ListView.builder(
          padding: const EdgeInsets.only(bottom: 40),
          itemCount: controller.treeList.length,
          itemBuilder: (context, index) {
            final TreeListModel node = controller.treeList[index];
            return Obx(() {
              if (node.pageVisible != true) return const SizedBox.shrink();
              return SizedBox(
                height: node.viewHeight,
                child: _buildTemplate(context, controller, node),
              );
            });
          },
        )),
      ),
    );
  }

  Widget _buildTemplate(
    BuildContext context,
    TreeSurveyController controller,
    TreeListModel node,
  ) {
    switch (node.groupName) {
      case 'GroupData':
        return _GroupTemplate(controller: controller, node: node);
      case 'LastData':
        return _LastTemplate(controller: controller, node: node);
      default:
        return _SimpleRadioTemplate(controller: controller, node: node);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Description Card
// ─────────────────────────────────────────────────────────────
class _DescriptionCard extends StatelessWidget {
  final TreeListModel node;
  const _DescriptionCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final bgColor   = _hexToColor(node.descriptionBackgroundColor);
    final textColor = _hexToColor(node.descriptionTextColor);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(1),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Topic ───────────────────────────────────────
            Text(
              node.topic,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Divider(color: textColor.withOpacity(0.3), height: 1),
            const SizedBox(height: 8),
            // ── Description ─────────────────────────────────
            Text(
              node.description,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Next Button  — user friendly
// ─────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NextButton({
    this.label = 'Next',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 80 : 20,
        8,
        isTablet ? 80 : 20,
        12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? 52 : 46,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kThemeColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Decision Item  — checkbox row
// ─────────────────────────────────────────────────────────────
class _DecisionItem extends StatelessWidget {
  final DecissionModel decision;
  final VoidCallback onTap;

  const _DecisionItem({required this.decision, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: decision.isCheck == true
              ? _kThemeColor.withOpacity(0.08)
              : Colors.white,
          border: Border.all(
            color: decision.isCheck == true
                ? _kThemeColor
                : Colors.grey.shade300,
            width: decision.isCheck == true ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // ── Checkbox ──────────────────────────────────
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: decision.isCheck,
                activeColor: _kThemeColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (_) => onTap(),
              ),
            ),
            const SizedBox(width: 10),
            // ── Label ─────────────────────────────────────
            Expanded(
              child: Text(
                decision.newTextValue,
                style: TextStyle(
                  fontSize: 14,
                  color: decision.isCheck == true
                      ? _kThemeColor
                      : Colors.black87,
                  fontWeight: decision.isCheck == true
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            // ── Selected indicator ─────────────────────────
            if (decision.isCheck == true)
              const Icon(Icons.check_circle,
                  color: _kThemeColor, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Template 1 & 2: SimpleData + RadioData
// ─────────────────────────────────────────────────────────────
class _SimpleRadioTemplate extends StatelessWidget {
  final TreeSurveyController controller;
  final TreeListModel node;

  const _SimpleRadioTemplate({
    required this.controller,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DescriptionCard(node: node),
                const SizedBox(height: 16),

                // ── Decision List ──────────────────────────
                Obx(() => Column(
                  children: node.decissionList
                      .map((decision) => _DecisionItem(
                            decision: decision,
                            onTap: () => controller
                                .onDecisionCheckTapped(node, decision),
                          ))
                      .toList(),
                )),

                const SizedBox(height: 10),

                // ── Comment Box ────────────────────────────
                Obx(() {
                  if (node.isCommentBoxVisible != true) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _kThemeColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Comment',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) => node.comment = val,
                    ),
                  );
                }),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // ── Next Button ────────────────────────────────────
        _NextButton(
          onPressed: () => controller.onNextPressed(node),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Template 3: GroupData
// ─────────────────────────────────────────────────────────────
class _GroupTemplate extends StatelessWidget {
  final TreeSurveyController controller;
  final TreeListModel node;

  const _GroupTemplate({
    required this.controller,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DescriptionCard(node: node),
                const SizedBox(height: 16),

                Obx(() => Column(
                  children: node.groupList.map((group) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Entry Description ──────────
                            Text(
                              group.entryDescription,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Input Field ────────────
                                Expanded(
                                  flex: isTablet ? 40 : 45,
                                  child: Obx(() => Container(
                                    decoration: BoxDecoration(
                                      color: _hexToColor(group.statusColor),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: group.unit,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 10),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (val) => controller
                                          .onGroupTextChanged(group, val),
                                    ),
                                  )),
                                ),

                                if (isTablet)
                                  const SizedBox(width: 10),

                                // ── Max / Min ──────────────
                                Obx(() {
                                  if (group.upperLowerValueVisible != true) {
                                    return const SizedBox.shrink();
                                  }
                                  return Expanded(
                                    flex: isTablet ? 55 : 55,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _LimitLabel(
                                            label: "Max",
                                            value: group.upperLimit,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _LimitLabel(
                                            label: "Min",
                                            value: group.lowerLimit,
                                            color: Colors.orange.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),

        _NextButton(
          onPressed: () => controller.onGroupNextPressed(node),
        ),
      ],
    );
  }
}

// ── Limit Label helper ────────────────────────────────────────
class _LimitLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LimitLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Template 4: LastData
// ─────────────────────────────────────────────────────────────
class _LastTemplate extends StatelessWidget {
  final TreeSurveyController controller;
  final TreeListModel node;

  const _LastTemplate({
    required this.controller,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DescriptionCard(node: node),
                const SizedBox(height: 16),

                // ── Last Question List ─────────────────────
                Obx(() => Column(
                  children: node.lastQuestionList
                      .map((question) {
                    return GestureDetector(
                      onTap: () => controller
                          .onLastCheckTapped(node, question),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: question.isCheck == true
                              ? _kThemeColor.withOpacity(0.08)
                              : Colors.white,
                          border: Border.all(
                            color: question.isCheck == true
                                ? _kThemeColor
                                : Colors.grey.shade300,
                            width: question.isCheck == true ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: question.isCheck,
                              activeColor: _kThemeColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (_) => controller
                                  .onLastCheckTapped(node, question),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                question.describe,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: question.isCheck == true
                                      ? _kThemeColor
                                      : Colors.black87,
                                  fontWeight: question.isCheck == true
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (question.isCheck == true)
                              const Icon(Icons.check_circle,
                                  color: _kThemeColor, size: 18),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),

        _NextButton(
          onPressed: () => controller.onLastPageNextPressed(node),
        ),
      ],
    );
  }
}