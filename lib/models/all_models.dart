import 'package:autopeepal/models/flashRecord_model.dart';
import 'package:autopeepal/models/variant_model.dart';

class AllModelsModel {
  int? count;
  dynamic next; // Using dynamic for C# 'object'
  dynamic previous; // Using dynamic for C# 'object'
  String? message;
  List<ModelResult>? results;

  AllModelsModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory AllModelsModel.fromJson(Map<String, dynamic> json) {
    return AllModelsModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => ModelResult.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'message': message,
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }
}

class Dataset {
  int? id;
  String? code;

  Dataset({
    this.id,
    this.code,
  });

  // JSON -> Object (Deserialization)
  factory Dataset.fromJson(Map<String, dynamic> json) {
    return Dataset(
      id: json['id'],
      code: json['code'],
    );
  }

  // Object -> JSON (Serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

class PidDataset {
  int? id;
  String? code;

  PidDataset({
    this.id,
    this.code,
  });

  // JSON -> Object
  factory PidDataset.fromJson(Map<String, dynamic> json) {
    return PidDataset(
      id: json['id'],
      code: json['code'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

class MappedPidDataset {
  int? id;
  String? code;

  MappedPidDataset({
    this.id,
    this.code,
  });

  // JSON -> Object
  factory MappedPidDataset.fromJson(Map<String, dynamic> json) {
    return MappedPidDataset(
      id: json['id'],
      code: json['code'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

class IvnDtcDataset {
  int? id;
  String? code;

  IvnDtcDataset({
    this.id,
    this.code,
  });

  // JSON -> Object
  factory IvnDtcDataset.fromJson(Map<String, dynamic> json) {
    return IvnDtcDataset(
      id: json['id'],
      code: json['code'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

class IvnPidDataset {
  int? id;
  String? code;

  IvnPidDataset({
    this.id,
    this.code,
  });

  // JSON -> Object
  factory IvnPidDataset.fromJson(Map<String, dynamic> json) {
    return IvnPidDataset(
      id: json['id'],
      code: json['code'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

class Protocol {
  String? name;
  String? elm;
  String? autopeepal;

  Protocol({
    this.name,
    this.elm,
    this.autopeepal,
  });

  // JSON -> Object
  factory Protocol.fromJson(Map<String, dynamic> json) {
    return Protocol(
      name: json['name'],
      elm: json['elm'],
      autopeepal: json['autopeepal'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'elm': elm,
      'autopeepal': autopeepal,
    };
  }
}

class ReadDtcFnIndex {
  String? value;

  ReadDtcFnIndex({
    this.value,
  });

  // JSON -> Object
  factory ReadDtcFnIndex.fromJson(Map<String, dynamic> json) {
    return ReadDtcFnIndex(
      value: json['value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class ClearDtcFnIndex {
  String? value;

  ClearDtcFnIndex({
    this.value,
  });

  // JSON -> Object
  factory ClearDtcFnIndex.fromJson(Map<String, dynamic> json) {
    return ClearDtcFnIndex(
      value: json['value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class ReadDataFnIndex {
  String? value;

  ReadDataFnIndex({
    this.value,
  });

  // JSON -> Object
  factory ReadDataFnIndex.fromJson(Map<String, dynamic> json) {
    return ReadDataFnIndex(
      value: json['value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class WriteDataFnIndex {
  String? value;

  WriteDataFnIndex({
    this.value,
  });

  // JSON -> Object
  factory WriteDataFnIndex.fromJson(Map<String, dynamic> json) {
    return WriteDataFnIndex(
      value: json['value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class SeedkeyalgoFnIndex {
  String? value;

  SeedkeyalgoFnIndex({
    this.value,
  });

  // JSON -> Object
  factory SeedkeyalgoFnIndex.fromJson(Map<String, dynamic> json) {
    return SeedkeyalgoFnIndex(
      value: json['value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class IORTestFnIndexModel {
  String? value;

  IORTestFnIndexModel({
    this.value,
  });

  // JSON -> Object
  factory IORTestFnIndexModel.fromJson(Map<String, dynamic> json) {
    return IORTestFnIndexModel(
      value: json['value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class FileModel {
  int? id;
  String? dataFileName;
  String? swPartNo;
  int? sequenceFileName;
  String? dataFile;

  FileModel({
    this.id,
    this.dataFileName,
    this.swPartNo,
    this.sequenceFileName,
    this.dataFile,
  });

  // JSON -> Object
  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      dataFileName: json['data_file_name'],
      swPartNo: json['sw_part_no'],
      sequenceFileName: json['sequence_file_name'],
      dataFile: json['data_file'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_file_name': dataFileName,
      'sw_part_no': swPartNo,
      'sequence_file_name': sequenceFileName,
      'data_file': dataFile,
    };
  }
}

class EcuMapFile {
  int? id;
  String? endAddress;
  int? endAddr; // Dart uses int for C# uint
  String? sectorName;
  String? startAddress;
  int? startAddr;
  int? priority;

  EcuMapFile({
    this.id,
    this.endAddress,
    this.endAddr,
    this.sectorName,
    this.startAddress,
    this.startAddr,
    this.priority,
  });

  // JSON -> Object
  factory EcuMapFile.fromJson(Map<String, dynamic> json) {
    return EcuMapFile(
      id: json['id'],
      endAddress: json['end_address'],
      // Standardizing to int; ensure value is within range
      endAddr: json['end_addr'],
      sectorName: json['sector_name'],
      startAddress: json['start_address'],
      startAddr: json['start_addr'],
      priority: json['priority'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'end_address': endAddress,
      'end_addr': endAddr,
      'sector_name': sectorName,
      'start_address': startAddress,
      'start_addr': startAddr,
      'priority': priority,
    };
  }
}

class Ecu2 {
  int? id;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;
  String? sequenceFileName;
  String? flashsepTime;
  String? flashAddressDataFormat;
  String? flashCheckSumType;
  String? flashDiagnosticMode;
  String? flashEraseType;
  String? flashFraseByte;
  String? flashNaxBlkseqcntr;
  String? flashSeedKeyLength;
  String? flashStatus;
  String? sequenceFile;
  List<FileModel>? file;
  String? sectorframetransferlen;
  String? sendseedbyte;
  List<EcuMapFile>? ecuMapFile;

  Ecu2({
    this.id,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    this.sequenceFileName,
    this.flashsepTime,
    this.flashAddressDataFormat,
    this.flashCheckSumType,
    this.flashDiagnosticMode,
    this.flashEraseType,
    this.flashFraseByte,
    this.flashNaxBlkseqcntr,
    this.flashSeedKeyLength,
    this.flashStatus,
    this.sequenceFile,
    this.file,
    this.sectorframetransferlen,
    this.sendseedbyte,
    this.ecuMapFile,
  });

  // JSON -> Object
  factory Ecu2.fromJson(Map<String, dynamic> json) {
    return Ecu2(
      id: json['id'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      protocol:
          json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
      sequenceFileName: json['sequence_file_name'],
      flashsepTime: json['flashsep_time'],
      flashAddressDataFormat: json['flash_address_data_format'],
      flashCheckSumType: json['flash_check_sum_type'],
      flashDiagnosticMode: json['flash_diagnostic_mode'],
      flashEraseType: json['flash_erase_type'],
      flashFraseByte: json['flash_frase_byte'],
      flashNaxBlkseqcntr: json['flash_nax_blkseqcntr'],
      flashSeedKeyLength: json['flash_seed_key_length'],
      flashStatus: json['flash_status'],
      sequenceFile: json['sequence_file'],
      file: json['file'] != null
          ? (json['file'] as List).map((i) => FileModel.fromJson(i)).toList()
          : null,
      sectorframetransferlen: json['sectorframetransferlen'],
      sendseedbyte: json['sendseedbyte'],
      ecuMapFile: json['ecu_map_file'] != null
          ? (json['ecu_map_file'] as List)
              .map((i) => EcuMapFile.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tx_header': txHeader,
      'rx_header': rxHeader,
      'protocol': protocol?.toJson(),
      'sequence_file_name': sequenceFileName,
      'flashsep_time': flashsepTime,
      'flash_address_data_format': flashAddressDataFormat,
      'flash_check_sum_type': flashCheckSumType,
      'flash_diagnostic_mode': flashDiagnosticMode,
      'flash_erase_type': flashEraseType,
      'flash_frase_byte': flashFraseByte,
      'flash_nax_blkseqcntr': flashNaxBlkseqcntr,
      'flash_seed_key_length': flashSeedKeyLength,
      'flash_status': flashStatus,
      'sequence_file': sequenceFile,
      'file': file?.map((v) => v.toJson()).toList(),
      'sectorframetransferlen': sectorframetransferlen,
      'sendseedbyte': sendseedbyte,
      'ecu_map_file': ecuMapFile?.map((v) => v.toJson()).toList(),
    };
  }
}

// Note: If you need ViewModel behavior, extend ChangeNotifier
class Ecu {
  int? id;
  String? _name;
  String? txHeader;
  String? rxHeader;
  String? channel;
  String? readWritePidByAddr;
  List<Dataset>? datasets;
  List<DtcDataset>? dtcDatasets;
  List<PidDataset>? pidDatasets;
  List<MappedPidDataset>? mappedPidDatasets;
  List<PidPidDataset>? pidPidDatasets;
  List<IvnDtcDataset>? ivnDtcDatasets;
  List<IvnPidDataset>? ivnPidDatasets;
  Protocol? protocol;
  ReadDtcFnIndex? readDtcFnIndex;
  ClearDtcFnIndex? clearDtcFnIndex;
  ReadDataFnIndex? readDataFnIndex;
  WriteDataFnIndex? writeDataFnIndex;
  SeedkeyalgoFnIndex? seedkeyalgoFnIndex;
  IORTestFnIndexModel? iorTestFnIndex;
  int? ffSet;
  List<Ecu2>? ecu;
  double? _opacity;
  String? swVerPid;
  List<VersionDataset>? versionDataset;

  Ecu({
    this.id,
    String? name,
    this.txHeader,
    this.rxHeader,
    this.channel,
    this.readWritePidByAddr,
    this.datasets,
    this.dtcDatasets,
    this.pidDatasets,
    this.mappedPidDatasets,
    this.pidPidDatasets,
    this.ivnDtcDatasets,
    this.ivnPidDatasets,
    this.protocol,
    this.readDtcFnIndex,
    this.clearDtcFnIndex,
    this.readDataFnIndex,
    this.writeDataFnIndex,
    this.seedkeyalgoFnIndex,
    this.iorTestFnIndex,
    this.ffSet,
    this.ecu,
    double? opacity,
    this.swVerPid,
    this.versionDataset,
  }) {
    _name = name;
    _opacity = opacity;
  }

  // Getters and Setters for ViewModel behavior
  String? get name => _name;
  set name(String? value) {
    _name = value;
    // notifyListeners(); // If using ChangeNotifier
  }

  double? get opacity => _opacity;
  set opacity(double? value) {
    _opacity = value;
    // notifyListeners(); // If using ChangeNotifier
  }

  factory Ecu.fromJson(Map<String, dynamic> json) {
    return Ecu(
      id: json['id'],
      name: json['name'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      channel: json['channel'],
      readWritePidByAddr: json['read_write_pid_by_addr'],
      datasets: json['datasets'] != null
          ? (json['datasets'] as List).map((i) => Dataset.fromJson(i)).toList()
          : null,
      dtcDatasets: json['dtc_datasets'] != null
          ? (json['dtc_datasets'] as List)
              .map((i) => DtcDataset.fromJson(i))
              .toList()
          : null,
      pidDatasets: json['pid_datasets'] != null
          ? (json['pid_datasets'] as List)
              .map((i) => PidDataset.fromJson(i))
              .toList()
          : null,
      mappedPidDatasets: json['mapped_pid_datasets'] != null
          ? (json['mapped_pid_datasets'] as List)
              .map((i) => MappedPidDataset.fromJson(i))
              .toList()
          : null,
      pidPidDatasets: json['pid_pid_datasets'] != null
          ? (json['pid_pid_datasets'] as List)
              .map((i) => PidPidDataset.fromJson(i))
              .toList()
          : null,
      ivnDtcDatasets: json['ivn_dtc_datasets'] != null
          ? (json['ivn_dtc_datasets'] as List)
              .map((i) => IvnDtcDataset.fromJson(i))
              .toList()
          : null,
      ivnPidDatasets: json['ivn_pid_datasets'] != null
          ? (json['ivn_pid_datasets'] as List)
              .map((i) => IvnPidDataset.fromJson(i))
              .toList()
          : null,
      protocol:
          json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
      readDtcFnIndex: json['read_dtc_fn_index'] != null
          ? ReadDtcFnIndex.fromJson(json['read_dtc_fn_index'])
          : null,
      clearDtcFnIndex: json['clear_dtc_fn_index'] != null
          ? ClearDtcFnIndex.fromJson(json['clear_dtc_fn_index'])
          : null,
      readDataFnIndex: json['read_data_fn_index'] != null
          ? ReadDataFnIndex.fromJson(json['read_data_fn_index'])
          : null,
      writeDataFnIndex: json['write_data_fn_index'] != null
          ? WriteDataFnIndex.fromJson(json['write_data_fn_index'])
          : null,
      seedkeyalgoFnIndex: json['seedkeyalgo_fn_index'] != null
          ? SeedkeyalgoFnIndex.fromJson(json['seedkeyalgo_fn_index'])
          : null,
      iorTestFnIndex: json['ior_test_fn_index'] != null
          ? IORTestFnIndexModel.fromJson(json['ior_test_fn_index'])
          : null,
      ffSet: json['ff_set'],
      ecu: json['ecu'] != null
          ? (json['ecu'] as List).map((i) => Ecu2.fromJson(i)).toList()
          : null,
      opacity: json['opacity']?.toDouble(),
      swVerPid: json['sw_ver_pid'],
      versionDataset: json['version_dataset'] != null
          ? (json['version_dataset'] as List)
              .map((i) => VersionDataset.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': _name,
      'tx_header': txHeader,
      'rx_header': rxHeader,
      'channel': channel,
      'read_write_pid_by_addr': readWritePidByAddr,
      'datasets': datasets?.map((v) => v.toJson()).toList(),
      'dtc_datasets': dtcDatasets?.map((v) => v.toJson()).toList(),
      'pid_datasets': pidDatasets?.map((v) => v.toJson()).toList(),
      
      // Changed mapped_pid_datasets to mappedPidDatasets
      'mapped_pid_datasets': 
          mappedPidDatasets?.map((v) => v.toJson()).toList(), 
          
      'pid_pid_datasets': pidPidDatasets?.map((v) => v.toJson()).toList(),
      'ivn_dtc_datasets': ivnDtcDatasets?.map((v) => v.toJson()).toList(),
      'ivn_pid_datasets': ivnPidDatasets?.map((v) => v.toJson()).toList(),
      'protocol': protocol?.toJson(),
      'read_dtc_fn_index': readDtcFnIndex?.toJson(),
      'clear_dtc_fn_index': clearDtcFnIndex?.toJson(),
      'read_data_fn_index': readDataFnIndex?.toJson(),
      'write_data_fn_index': writeDataFnIndex?.toJson(),
      'seedkeyalgo_fn_index': seedkeyalgoFnIndex?.toJson(),
      'ior_test_fn_index': iorTestFnIndex?.toJson(),
      'ff_set': ffSet,
      'ecu': ecu?.map((v) => v.toJson()).toList(),
      'opacity': _opacity,
      'sw_ver_pid': swVerPid,
      'version_dataset': versionDataset?.map((v) => v.toJson()).toList(),
    };
}
}

class VersionDataset {
  int? dataset;
  String? version;

  VersionDataset({
    this.dataset,
    this.version,
  });

  // JSON -> Object
  factory VersionDataset.fromJson(Map<String, dynamic> json) {
    return VersionDataset(
      dataset: json['dataset'],
      version: json['version'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'dataset': dataset,
      'version': version,
    };
  }
}

class DtcDataset {
  int? id;
  String? code;
  String? description;

  DtcDataset({
    this.id,
    this.code,
    this.description,
  });

  // JSON -> Object
  factory DtcDataset.fromJson(Map<String, dynamic> json) {
    return DtcDataset(
      id: json['id'],
      code: json['code'],
      description: json['description'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
    };
  }
}

class PidPidDataset {
  int? id;
  String? code;
  String? description;

  PidPidDataset({
    this.id,
    this.code,
    this.description,
  });

  // JSON -> Object
  factory PidPidDataset.fromJson(Map<String, dynamic> json) {
    return PidPidDataset(
      id: json['id'],
      code: json['code'],
      description: json['description'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
    };
  }
}

class SubModel {
  int? id;
  String? name;
  String? modelYear;
  List<Ecu>? ecus;

  SubModel({
    this.id,
    this.name,
    this.modelYear,
    this.ecus,
  });

  // JSON -> Object
  factory SubModel.fromJson(Map<String, dynamic> json) {
    return SubModel(
      id: json['id'],
      name: json['name'],
      // Mapping snake_case from C# to camelCase in Dart
      modelYear: json['model_year'],
      ecus: json['ecus'] != null
          ? (json['ecus'] as List).map((i) => Ecu.fromJson(i)).toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model_year': modelYear,
      // Ensure the nested list is also converted to JSON maps
      'ecus': ecus?.map((v) => v.toJson()).toList(),
    };
  }
}


class ModelResult {
  int? id;
  int? oem;
  String? name;
  String? _modelName;
  List<SubModel>? subModels;

  ModelResult({
    this.id,
    this.oem,
    this.name,
    String? modelName,
    this.subModels,
  }) {
    _modelName = modelName;
  }

  // Getter and Setter for modelName (ViewModel logic)
  String? get modelName => _modelName;
  set modelName(String? value) {
    _modelName = value;
    // notifyListeners(); // Equivalent to OnPropertyChanged
  }

  // JSON -> Object
  factory ModelResult.fromJson(Map<String, dynamic> json) {
    return ModelResult(
      id: json['id'],
      oem: json['oem'],
      name: json['name'],
      modelName: json['model_name'],
      subModels: json['sub_models'] != null
          ? (json['sub_models'] as List)
              .map((i) => SubModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oem': oem,
      'name': name,
      'model_name': _modelName,
      'sub_models': subModels?.map((v) => v.toJson()).toList(),
    };
  }
}


class FlashEcusModel {
  int? id;
  String? ecuName;
  double? _opacity;
  List<VariantEcuEcu>? flashFileLocalList;
  List<EcuMapFile>? ecuMapFile;
  SeedkeyalgoFnIndex? seedkeyalgoFnIndexValues;
  Ecu2? ecu2;
  Ecu? ecu1;

  FlashEcusModel({
    this.id,
    this.ecuName,
    double? opacity,
    this.flashFileLocalList,
    this.ecuMapFile,
    this.seedkeyalgoFnIndexValues,
    this.ecu2,
    this.ecu1,
  }) {
    _opacity = opacity;
  }

  // Getter and Setter for opacity (ViewModel logic)
  double? get opacity => _opacity;
  set opacity(double? value) {
    _opacity = value;
    // notifyListeners(); // If using ChangeNotifier/Provider
  }

  // JSON -> Object
  factory FlashEcusModel.fromJson(Map<String, dynamic> json) {
    return FlashEcusModel(
      id: json['id'],
      ecuName: json['ecu_name'],
      opacity: json['opacity']?.toDouble(),
      flashFileLocalList: json['flash_file_local_list'] != null
          ? (json['flash_file_local_list'] as List)
              .map((i) => VariantEcuEcu.fromJson(i))
              .toList()
          : null,
      ecuMapFile: json['ecu_map_file'] != null
          ? (json['ecu_map_file'] as List)
              .map((i) => EcuMapFile.fromJson(i))
              .toList()
          : null,
      seedkeyalgoFnIndexValues: json['SeedkeyalgoFnIndex_Values'] != null
          ? SeedkeyalgoFnIndex.fromJson(json['SeedkeyalgoFnIndex_Values'])
          : null,
      ecu2: json['ecu2'] != null ? Ecu2.fromJson(json['ecu2']) : null,
      ecu1: json['ecu1'] != null ? Ecu.fromJson(json['ecu1']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecu_name': ecuName,
      'opacity': _opacity,
      'flash_file_local_list': flashFileLocalList?.map((v) => v.toJson()).toList(),
      'ecu_map_file': ecuMapFile?.map((v) => v.toJson()).toList(),
      'SeedkeyalgoFnIndex_Values': seedkeyalgoFnIndexValues?.toJson(),
      'ecu2': ecu2?.toJson(),
      'ecu1': ecu1?.toJson(),
    };
  }
}


class UnlockModel {
  String? ecuName;
  double? _opacity;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;
  Ecu2? ecu2;

  UnlockModel({
    this.ecuName,
    double? opacity,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    this.ecu2,
  }) {
    _opacity = opacity;
  }

  // Getter and Setter for opacity (to mirror OnPropertyChanged logic)
  double? get opacity => _opacity;
  set opacity(double? value) {
    _opacity = value;
    // notifyListeners(); // If using Flutter's ChangeNotifier
  }

  // JSON -> Object
  factory UnlockModel.fromJson(Map<String, dynamic> json) {
    return UnlockModel(
      ecuName: json['ecu_name'],
      opacity: json['opacity']?.toDouble(),
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      protocol: json['protocol'] != null 
          ? Protocol.fromJson(json['protocol']) 
          : null,
      ecu2: json['ecu2'] != null 
          ? Ecu2.fromJson(json['ecu2']) 
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecu_name': ecuName,
      'opacity': _opacity,
      'tx_header': txHeader,
      'rx_header': rxHeader,
      'protocol': protocol?.toJson(),
      'ecu2': ecu2?.toJson(),
    };
  }
}


class ChannelModel {
  String? itemName;
  List<Ecu>? ecus;

  ChannelModel({
    this.itemName,
    this.ecus,
  });

  // JSON -> Object
  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      itemName: json['ItemName'],
      ecus: json['ecus'] != null
          ? (json['ecus'] as List).map((i) => Ecu.fromJson(i)).toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ItemName': itemName,
      'ecus': ecus?.map((v) => v.toJson()).toList(),
    };
  }
}

class FlashData {
  Ecu2? ecu2;
  FileModel? file;
  String? seqFileUrl;
  SeedkeyalgoFnIndex? seedkeyalgoFnIndexValues;
  List<EcuMapFile>? ecuMapFile;

  FlashData({
    this.ecu2,
    this.file,
    this.seqFileUrl,
    this.seedkeyalgoFnIndexValues,
    this.ecuMapFile,
  });

  // JSON -> Object
  factory FlashData.fromJson(Map<String, dynamic> json) {
    return FlashData(
      ecu2: json['ecu2'] != null ? Ecu2.fromJson(json['ecu2']) : null,
      file: json['file'] != null ? FileModel.fromJson(json['file']) : null,
      seqFileUrl: json['seqFileUrl'],
      seedkeyalgoFnIndexValues: json['SeedkeyalgoFnIndex_Values'] != null
          ? SeedkeyalgoFnIndex.fromJson(json['SeedkeyalgoFnIndex_Values'])
          : null,
      ecuMapFile: json['ecu_map_file'] != null
          ? (json['ecu_map_file'] as List)
              .map((i) => EcuMapFile.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
  return {
    'ecu2': ecu2?.toJson(),
    'file': file?.toJson(),
    'seqFileUrl': seqFileUrl,
    'SeedkeyalgoFnIndex_Values': seedkeyalgoFnIndexValues?.toJson(),
    
    // The key (left) stays as the API expects it ('ecu_map_file')
    // The variable (right) must match your class declaration (ecuMapFile)
    'ecu_map_file': ecuMapFile?.map((v) => v.toJson()).toList(),
  };
}
}