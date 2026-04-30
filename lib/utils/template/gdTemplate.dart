import 'package:autopeepal/models/treeList_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GdScreen extends StatelessWidget {
  const GdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data (replace with your real data)
    final List<TreeListModel> list = [
      TreeListModel(groupName: "SimpleData"),
      TreeListModel(groupName: "RadioData"),
      TreeListModel(groupName: "GroupData"),
      TreeListModel(groupName: "LastData"),
      TreeListModel(groupName: "Other"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("GD Template")),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return GdTemplateSelector.selectTemplate(item);
        },
      ),
    );
  }
}

// ---------------- TEMPLATE SELECTOR ----------------

class GdTemplateSelector {
  static Widget selectTemplate(TreeListModel? item) {
    try {
      if (item != null) {
        switch (item.groupName) {
          case "SimpleData":
            return _simpleTemplate(item);
          case "RadioData":
            return _radioTemplate(item);
          case "GroupData":
            return _groupTemplate(item);
          case "LastData":
            return _lastTemplate(item);
          default:
            return _defaultTemplate(item);
        }
      }
      return const SizedBox();
    } catch (e) {
      return const SizedBox();
    }
  }

  // ---------------- TEMPLATES ----------------

  static Widget _simpleTemplate(TreeListModel item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text("Simple Data Template"),
    );
  }

  static Widget _radioTemplate(TreeListModel item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.radio_button_checked),
          SizedBox(width: 10),
          Text("Radio Data Template"),
        ],
      ),
    );
  }

  static Widget _groupTemplate(TreeListModel item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Group Data Template"),
    );
  }

  static Widget _lastTemplate(TreeListModel item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Last Data Template"),
    );
  }

  static Widget _defaultTemplate(TreeListModel item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Default Template"),
    );
  }
}