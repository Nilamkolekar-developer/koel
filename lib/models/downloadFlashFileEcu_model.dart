import 'package:autopeepal/models/variant_model.dart';

class DownloadFlashFileEcuModel {
  int? id;
  String? ecuName;
  List<VariantEcuEcu>? variantEcu;
  double? _opacity;

  DownloadFlashFileEcuModel({
    this.id,
    this.ecuName,
    this.variantEcu,
    double? opacity,
  }) {
    _opacity = opacity;
  }

  // Getter and Setter for opacity (OnPropertyChanged logic)
  double? get opacity => _opacity;
  set opacity(double? value) {
    _opacity = value;
    // notifyListeners(); // If using Provider/ChangeNotifier
  }

  // JSON -> Object
  factory DownloadFlashFileEcuModel.fromJson(Map<String, dynamic> json) {
    return DownloadFlashFileEcuModel(
      id: json['id'],
      ecuName: json['ecu_name'],
      variantEcu: json['variant_ecu'] != null
          ? (json['variant_ecu'] as List)
              .map((i) => VariantEcuEcu.fromJson(i))
              .toList()
          : null,
      opacity: (json['opacity'] as num?)?.toDouble(),
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecu_name': ecuName,
      'variant_ecu': variantEcu?.map((v) => v.toJson()).toList(),
      'opacity': _opacity,
    };
  }
}
