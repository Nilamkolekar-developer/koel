import 'package:autopeepal/models/iorTest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PreconditionScreen extends StatelessWidget {
  const PreconditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data (replace with API)
    final List<PreCondition> list = [
      PreCondition(preConditionType: "static"),
      PreCondition(preConditionType: "manual_confirm"),
      PreCondition(preConditionType: "pid"),
      PreCondition(preConditionType: "other"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Precondition Template")),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return PreconditionTemplateSelector.selectTemplate(item);
        },
      ),
    );
  }
}

// ---------------- TEMPLATE SELECTOR ----------------

class PreconditionTemplateSelector {
  static Widget selectTemplate(PreCondition? item) {
    try {
      if (item != null) {
        switch (item.preConditionType) {
          case "static":
            return _staticTemplate(item);
          case "manual_confirm":
            return _manualTemplate(item);
          case "pid":
            return _dynamicTemplate(item);
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

  static Widget _staticTemplate(PreCondition item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Static Data Template"),
    );
  }

  static Widget _manualTemplate(PreCondition item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.touch_app),
          SizedBox(width: 10),
          Text("Manual पुष्टि (Confirm) Template"),
        ],
      ),
    );
  }

  static Widget _dynamicTemplate(PreCondition item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("Dynamic (PID) Data Template"),
    );
  }

  static Widget _defaultTemplate(PreCondition item) {
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