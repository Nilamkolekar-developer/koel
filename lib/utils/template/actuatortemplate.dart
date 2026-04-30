import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ActuatorScreen extends StatelessWidget {
  const ActuatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data (replace with your API data)
    final List<PiCodeVariable> list = [
      PiCodeVariable(messageType: "ENUMRATED"),
      PiCodeVariable(messageType: "OTHER"),
      PiCodeVariable(messageType: "ENUMRATED"),
      PiCodeVariable(messageType: "XYZ"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Actuator Template")),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return ActuatorTemplateSelector.selectTemplate(item);
        },
      ),
    );
  }
}

// ---------------- TEMPLATE SELECTOR ----------------

class ActuatorTemplateSelector {
  static Widget selectTemplate(PiCodeVariable? item) {
    try {
      if (item != null) {
        if (item.messageType == "ENUMRATED") {
          return _enumeratedTemplate(item);
        } else {
          return _otherTemplate(item);
        }
      }
      return const SizedBox();
    } catch (e) {
      return _otherTemplate(item!);
    }
  }

  // ENUMRATED TEMPLATE
  static Widget _enumeratedTemplate(PiCodeVariable item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "ENUMRATED TEMPLATE: ${item.messageType}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // OTHER TEMPLATE
  static Widget _otherTemplate(PiCodeVariable item) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "OTHER TEMPLATE: ${item.messageType}",
      ),
    );
  }
}