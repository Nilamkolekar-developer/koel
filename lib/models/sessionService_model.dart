import 'package:flutter/foundation.dart';

class SessionServicesModel extends ChangeNotifier {
  int? id;
  String? name;
  bool _selected = false;
  bool _isEnabled = true;

  SessionServicesModel({
    this.id,
    this.name,
    bool selected = false,
    bool isEnabled = true,
  })  : _selected = selected,
        _isEnabled = isEnabled;

  // Getter and Setter for selected
  bool get selected => _selected;
  set selected(bool value) {
    if (_selected != value) {
      _selected = value;
      notifyListeners(); // Equivalent to OnPropertyChanged
    }
  }

  // Getter and Setter for isEnabled
  bool get isEnabled => _isEnabled;
  set isEnabled(bool value) {
    if (_isEnabled != value) {
      _isEnabled = value;
      notifyListeners(); // Equivalent to OnPropertyChanged
    }
  }

  // JSON -> Object
  factory SessionServicesModel.fromJson(Map<String, dynamic> json) {
    return SessionServicesModel(
      id: json['id'],
      name: json['name'],
      selected: json['selected'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'selected': selected,
      'isEnabled': isEnabled,
    };
  }
}