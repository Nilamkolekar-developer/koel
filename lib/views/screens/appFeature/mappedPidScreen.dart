// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MappedPidPage extends StatelessWidget {
//   const MappedPidPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Assuming you have a controller managing your table data
//     final controller = Get.put(MappedPidController());

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5), // page_bg_color
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: Row(
//           children: [
//             Expanded(
//               child: Obx(() => Text(
//                 controller.mappedPidCode.value,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: context.isTablet ? 24 : 16,
//                 ),
//               )),
//             ),
//             Image.asset(
//               'assets/new/ic_iKonnect.jpg',
//               height: context.isTablet ? 44 : 30,
//             ),
//           ],
//         ),
//       ),
//       body: _buildScrollableTable(controller),
//     );
//   }

//   Widget _buildScrollableTable(MappedPidController controller) {
//     const double cellWidth = 80.0;
//     const double cellHeight = 50.0;

//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Obx(() => Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- HEADER ROW (Empty Corner + Column Headers) ---
//             Row(
//               children: [
//                 // Empty corner with UnitRow and UnitColumn labels
//                 Container(
//                   width: cellWidth,
//                   height: cellHeight,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black),
//                     color: Colors.white,
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         bottom: 2, left: 5,
//                         child: Text(controller.unitRow.value, style: const TextStyle(fontSize: 12)),
//                       ),
//                       Positioned(
//                         top: 2, right: 5,
//                         child: Text(controller.unitColumn.value, style: const TextStyle(fontSize: 12)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Column Headers
//                 ...controller.columnHeaders.map((header) => _buildCell(
//                       text: header,
//                       width: cellWidth,
//                       height: cellHeight,
//                       isHeader: true,
//                     )),
//               ],
//             ),

//             // --- DATA ROWS (Row Header + Cells) ---
//             ...controller.rows.map((row) => Row(
//               children: [
//                 // Row Header
//                 _buildCell(
//                   text: row.header,
//                   width: cellWidth,
//                   height: cellHeight,
//                   isHeader: true,
//                 ),
//                 // Data Cells
//                 ...row.cells.map((cellValue) => _buildCell(
//                       text: cellValue,
//                       width: cellWidth,
//                       height: cellHeight,
//                       isHeader: false,
//                     )),
//               ],
//             )),
//           ],
//         )),
//       ),
//     );
//   }

//   Widget _buildCell({
//     required String text,
//     required double width,
//     required double height,
//     required bool isHeader,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black, width: 0.5),
//         color: isHeader ? Colors.grey[300] : Colors.white,
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.black,
//           fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }