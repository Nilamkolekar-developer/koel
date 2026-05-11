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


class LocalVariantEcuEcu {
  int? ecuId;
  String? ecuName;
  ProductionSwId? productionSwId;
  bool? isLatest;
  bool? isActive;
  String? localDatasetFile;
  int? sequenceFileId;
  String? imgDownload;       // ImageSource → asset path string in Flutter
  Color? backgroundColor;
  bool? isEnable;
  bool? isDescVisible;

  LocalVariantEcuEcu({
    this.ecuId,
    this.ecuName,
    this.productionSwId,
    this.isLatest,
    this.isActive,
    this.localDatasetFile,
    this.sequenceFileId,
    this.imgDownload,
    this.backgroundColor,
    this.isEnable,
    this.isDescVisible,
  });

  factory LocalVariantEcuEcu.fromJson(Map<String, dynamic> json) {
    return LocalVariantEcuEcu(
      ecuId: json['ecu_id'] as int?,
      ecuName: json['ecu_name'] as String?,
      productionSwId: json['production_sw_id'] != null
          ? ProductionSwId.fromJson(json['production_sw_id'])
          : null,
      isLatest: json['is_latest'] as bool?,
      isActive: json['is_active'] as bool?,
      localDatasetFile: json['local_dataset_file'] as String?,
      sequenceFileId: json['sequence_file_id'] as int?,
      isEnable: json['is_enable'] as bool?,
      isDescVisible: json['isDescVisible'] as bool?,
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
      'is_enable': isEnable,
      'isDescVisible': isDescVisible,
    };
  }
}