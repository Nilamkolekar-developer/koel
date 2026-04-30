import 'package:autopeepal/models/tickitList_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data (replace with API response)
    final List<TicketResult> list = [
      TicketResult(ticketIssue: TicketIssue(issueRelated: "Application")),
      TicketResult(ticketIssue: TicketIssue(issueRelated: "Dongle")),
      TicketResult(ticketIssue: TicketIssue(issueRelated: "Application")),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Ticket Template")),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return TicketTemplateSelector.selectTemplate(item);
        },
      ),
    );
  }
}

// ---------------- TEMPLATE SELECTOR ----------------

class TicketTemplateSelector {
  static Widget selectTemplate(TicketResult? item) {
    try {
      if (item != null) {
        if (item.ticketIssue?.issueRelated == "Application") {
          return _applicationTemplate(item);
        } else {
          return _dongleTemplate(item);
        }
      }
      return const SizedBox();
    } catch (e) {
      return const SizedBox();
    }
  }

  // ---------------- TEMPLATES ----------------

  static Widget _applicationTemplate(TicketResult item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Application Issue Template",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _dongleTemplate(TicketResult item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Dongle Issue Template",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}