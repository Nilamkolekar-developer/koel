import 'package:autopeepal/models/variant_model.dart';
import 'package:flutter/material.dart';

class LocalDatafileModel {
  List<VariantEcu>? variantEcu;

  LocalDatafileModel({this.variantEcu});

  // JSON -> Object
  factory LocalDatafileModel.fromJson(Map<String, dynamic> json) {
    return LocalDatafileModel(
      variantEcu: json['variant_ecu'] != null
          ? (json['variant_ecu'] as List)
              .map((i) => VariantEcu.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'variant_ecu': variantEcu?.map((v) => v.toJson()).toList(),
    };
  }
}

class VariantEcu {
  int? ecuId;
  String? ecuName;
  String? date;
  ProductionSW? productionSwId;

  VariantEcu({
    this.ecuId,
    this.ecuName,
    this.date,
    this.productionSwId,
  });

  // Replicating the C# getter logic
  String? get swPartNo => productionSwId?.swPartNo;

  // JSON -> Object
  factory VariantEcu.fromJson(Map<String, dynamic> json) {
    return VariantEcu(
      ecuId: json['ecu_id'],
      ecuName: json['ecu_name'],
      date: json['date'],
      productionSwId: json['production_sw_id'] != null
          ? ProductionSW.fromJson(json['production_sw_id'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecu_id': ecuId,
      'ecu_name': ecuName,
      'date': date,
      'production_sw_id': productionSwId?.toJson(),
      // We usually don't include the getter in toJson
      // unless your API explicitly expects sw_part_no as a field
      'sw_part_no': swPartNo,
    };
  }
}

class ProductionSW {
  int? id;
  String? swPartNo;
  String? hexSrecFile;
  String? dataFile;
  String? dataFileLocal;

  ProductionSW({
    this.id,
    this.swPartNo,
    this.hexSrecFile,
    this.dataFile,
    this.dataFileLocal,
  });

  // JSON -> Object (Deserialization)
  factory ProductionSW.fromJson(Map<String, dynamic> json) {
    return ProductionSW(
      id: json['id'],
      swPartNo: json['sw_part_no'],
      hexSrecFile: json['hex_srec_file'],
      dataFile: json['data_file'],
      dataFileLocal: json['data_file_local'],
    );
  }

  // Object -> JSON (Serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sw_part_no': swPartNo,
      'hex_srec_file': hexSrecFile,
      'data_file': dataFile,
      'data_file_local': dataFileLocal,
    };
  }
}


class LocalVariantEcuEcu extends ChangeNotifier {
  // Data Properties
  int? ecuId;
  String? ecuName;
  ProductionSwId? productionSwId;
  bool? isLatest;
  bool? isActive;
  String? localDatasetFile;
  int? sequenceFileId;

  // Private backing fields for UI properties
  String? _imgDownload; // Represented as a path or URL string
  Color _backgroundColor = Colors.transparent;
  bool _isEnable = true;
  bool _isDescVisible = false;

  LocalVariantEcuEcu({
    this.ecuId,
    this.ecuName,
    this.productionSwId,
    this.isLatest,
    this.isActive,
    this.localDatasetFile,
    this.sequenceFileId,
  });

  // --- Getters and Setters (Equivalent to OnPropertyChanged) ---

  String? get imgDownload => _imgDownload;
  set imgDownload(String? value) {
    _imgDownload = value;
    notifyListeners(); // This triggers the UI to rebuild
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
    notifyListeners();
  }

  bool get isEnable => _isEnable;
  set isEnable(bool value) {
    _isEnable = value;
    notifyListeners();
  }

  bool get isDescVisible => _isDescVisible;
  set isDescVisible(bool value) {
    _isDescVisible = value;
    notifyListeners();
  }

  // --- JSON Mapping ---

  factory LocalVariantEcuEcu.fromJson(Map<String, dynamic> json) {
    return LocalVariantEcuEcu(
      ecuId: json['ecu_id'],
      ecuName: json['ecu_name'],
      productionSwId: json['production_sw_id'] != null
          ? ProductionSwId.fromJson(json['production_sw_id'])
          : null,
      isLatest: json['is_latest'],
      isActive: json['is_active'],
      localDatasetFile: json['local_dataset_file'],
      sequenceFileId: json['sequence_file_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ecu_id': ecuId,
      'ecu_name': ecuName,
      'production_sw_id': productionSwId?.toJson(),
      'is_latest': isLatest,
      'is_active': isActive,
      'local_dataset_file': localDatasetFile,
      'sequence_file_id': sequenceFileId,
      // Typically, internal UI state like backgroundColor isn't serialized
    };
  }
}