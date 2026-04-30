// import 'package:autopeepal/models/Tickit_model.dart';
// import 'package:flutter/material.dart';

// class TicketsListPage extends StatelessWidget {
//   const TicketsListPage({super.key});

//   static const Color themeColor = Color(0xFF309F93);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         toolbarHeight: 70,
//         leading: const Icon(Icons.menu, color: Colors.black),
//         title: const Text(
//           "Tickets",
//           style: TextStyle(
//             color: Colors.black, 
//             fontSize: 22, 
//             fontWeight: FontWeight.w500
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 24),
//             child: Image.asset('assets/new/ic_ikonnect.jpg', width: 110),
//           ),
//         ],
//       ),
//       body: Scrollbar(
//         thumbVisibility: true,
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//           itemCount: 10,
//          separatorBuilder: (context, index) => Divider(
//           height: 10, 
//           thickness: 1, 
//           color: Colors.grey.shade400,
//         ),
//           itemBuilder: (context, index) {
//             return _buildTicketItem(
//               TicketModel(
//                 ticketNumber: "TCK-KOEL-100000000${9 - index}",
//                 status: "Open",
//                 createdDate: "17/06/2025 10:31:49 pm",
//               ),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: themeColor,
//         child: const Icon(Icons.add, color: Colors.white, size: 30),
//       ),
//     );
//   }

//   Widget _buildTicketItem(TicketModel ticket) {
//     const TextStyle labelStyle = TextStyle(
//       color: Colors.black54,
//       fontSize: 16,
//       fontWeight: FontWeight.w500,
//     );
//     const TextStyle valueStyle = TextStyle(
//       color: Colors.black87,
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//     );

//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: InkWell(
//         onTap: () {},
//         hoverColor: themeColor.withOpacity(0.02),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- Left Side: Icon and Main Info ---
//               const Icon(Icons.confirmation_number_outlined, color: themeColor, size: 28),
//               const SizedBox(width: 20),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildDataRow("Ticket Number : ", ticket.ticketNumber, labelStyle, valueStyle),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                         const SizedBox(width: 8),
//                         Text("Created Date : ", style: labelStyle),
//                         Text(ticket.createdDate, style: const TextStyle(color: Colors.black87, fontSize: 16)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // --- Right Side: Status and History ---
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _buildStatusBadge(ticket.status),
//                   const SizedBox(height: 15),
//                   const Text(
//                     "Ticket History",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
                     
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDataRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(label, style: labelStyle),
//         Text(value, style: valueStyle),
//       ],
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         color: status == "Open" ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: status == "Open" ? Colors.green : Colors.orange),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: status == "Open" ? Colors.green : Colors.orange,
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }
import 'package:autopeepal/models/Tickit_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/common_widgets/custom_drawer.dart';

class TicketsListPage extends StatelessWidget {
  const TicketsListPage({super.key});

  static const Color themeColor = Color(0xFF309F93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       drawer: const MyESNDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
     onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          "Tickets",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Image.asset('assets/new/ic_ikonnect.jpg', width: 110),
          ),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          itemCount: 10,
          separatorBuilder: (context, index) => Divider(
            height: 1, // Reduced height for a tighter list
            thickness: 1,
            color: Colors.grey.shade300, // Even softer gray
          ),
          itemBuilder: (context, index) {
            return _buildTicketItem(
              TicketModel(
                ticketNumber: "TCK-KOEL-100000000${9 - index}",
                status: index % 2 == 0 ? "Open" : "In Progress",
                createdDate: "17/06/2025 10:31:49 pm",
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(Routes.tickitScreen);
        },
        backgroundColor: themeColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Ticket", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTicketItem(TicketModel ticket) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {},
        hoverColor: themeColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Center aligned for better symmetry
            children: [
              // --- Left Side: Leading Icon ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.confirmation_number_outlined, color: themeColor, size: 26),
              ),
              const SizedBox(width: 20),
              
              // --- Middle: Info Column ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.ticketNumber,
                      style: const TextStyle(
                        color: Colors.black, 
                        fontSize: 17, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          "Created: ${ticket.createdDate}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Right Side: Status and History ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(ticket.status),
                  const SizedBox(height: 12),
                  const Text(
                    "View History",
                    style: TextStyle(
                      color: themeColor, // Use theme color for the link
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                     // decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isOpen = status == "Open";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen ? Colors.green.shade200 : Colors.orange.shade200
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isOpen ? Colors.green.shade700 : Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}