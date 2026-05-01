class KoelLocalDataFlashModel {
  int? flashFileId;
  String? dataFileName;
  String? dataFile;
  String? ecuName;
  int? ecuId;
  String? localFile;
  String? sequenceFileName;
  int? sequenceFileId;

  KoelLocalDataFlashModel({
    this.flashFileId,
    this.dataFileName,
    this.dataFile,
    this.ecuName,
    this.ecuId,
    this.localFile,
    this.sequenceFileName,
    this.sequenceFileId,
  });

  // Map (JSON) to Object
  factory KoelLocalDataFlashModel.fromJson(Map<String, dynamic> json) {
    return KoelLocalDataFlashModel(
      flashFileId: json['flash_file_id'],
      dataFileName: json['data_file_name'],
      dataFile: json['data_file'],
      ecuName: json['ecu_name'],
      ecuId: json['ecu_id'],
      localFile: json['local_file'],
      sequenceFileName: json['sequence_file_name'],
      sequenceFileId: json['sequence_file_id'],
    );
  }

  // Object to Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'flash_file_id': flashFileId,
      'data_file_name': dataFileName,
      'data_file': dataFile,
      'ecu_name': ecuName,
      'ecu_id': ecuId,
      'local_file': localFile,
      'sequence_file_name': sequenceFileName,
      'sequence_file_id': sequenceFileId,
    };
  }
}

class RootKoelocalModel {
  LocalModel? modelDetail;

  RootKoelocalModel({this.modelDetail});

  // Map -> Object
  factory RootKoelocalModel.fromJson(Map<String, dynamic> json) {
    return RootKoelocalModel(
      modelDetail: json['model_detail'] != null
          ? LocalModel.fromJson(json['model_detail'])
          : null,
    );
  }

  // Object -> Map
  Map<String, dynamic> toJson() {
    return {
      'model_detail': modelDetail?.toJson(),
    };
  }
}

class LocalModel {
  int? modelId;
  int? oemId;
  String? modelName;
  List<SubModelLocalModel>? subModelList;

  LocalModel({
    this.modelId,
    this.oemId,
    this.modelName,
    this.subModelList,
  });

  // JSON to Object Mapping
  factory LocalModel.fromJson(Map<String, dynamic> json) {
    return LocalModel(
      modelId: json['model_id'],
      oemId: json['oem_id'],
      modelName: json['model_name'],
      // Map the list of sub-models
      subModelList: json['sub_model_list'] != null
          ? (json['sub_model_list'] as List)
              .map((i) => SubModelLocalModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object to JSON Mapping
  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      'oem_id': oemId,
      'model_name': modelName,
      'sub_model_list': subModelList?.map((v) => v.toJson()).toList(),
    };
  }
}

class SubModelLocalModel {
  int? subModelId;
  String? subModelName;
  List<EcuLocalModel>? ecuList;

  SubModelLocalModel({
    this.subModelId,
    this.subModelName,
    this.ecuList,
  });

  // JSON -> Object
  factory SubModelLocalModel.fromJson(Map<String, dynamic> json) {
    return SubModelLocalModel(
      subModelId: json['sub_model_id'],
      subModelName: json['sub_model_name'],
      // Logic to map the nested list of ECUs
      ecuList: json['ecu_list'] != null
          ? (json['ecu_list'] as List)
              .map((i) => EcuLocalModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'sub_model_id': subModelId,
      'sub_model_name': subModelName,
      'ecu_list': ecuList?.map((v) => v.toJson()).toList(),
    };
  }
}

class EcuLocalModel {
  int? ecuId;
  String? ecuName;
  List<Ecu2LocalModel>? ecu2LocalModels;

  EcuLocalModel({
    this.ecuId,
    this.ecuName,
    this.ecu2LocalModels,
  });

  // JSON -> Object
  factory EcuLocalModel.fromJson(Map<String, dynamic> json) {
    return EcuLocalModel(
      ecuId: json['ecu_id'],
      ecuName: json['ecu_name'],
      // Logic to parse the nested list of Ecu2LocalModels
      ecu2LocalModels: json['ecu2LocalModels'] != null
          ? (json['ecu2LocalModels'] as List)
              .map((i) => Ecu2LocalModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecu_id': ecuId,
      'ecu_name': ecuName,
      'ecu2LocalModels': ecu2LocalModels?.map((v) => v.toJson()).toList(),
    };
  }
}

class Ecu2LocalModel {
  int? sequenceId;
  String? sequenceFileName;
  String? sequenceUrl;
  String? sequenceLocalFile;

  Ecu2LocalModel({
    this.sequenceId,
    this.sequenceFileName,
    this.sequenceUrl,
    this.sequenceLocalFile,
  });

  // JSON -> Object (Map to Object)
  factory Ecu2LocalModel.fromJson(Map<String, dynamic> json) {
    return Ecu2LocalModel(
      sequenceId: json['sequence_id'],
      sequenceFileName: json['sequence_file_name'],
      sequenceUrl: json['sequence_url'],
      sequenceLocalFile: json['sequence_local_file'],
    );
  }

  // Object -> JSON (Object to Map)
  Map<String, dynamic> toJson() {
    return {
      'sequence_id': sequenceId,
      'sequence_file_name': sequenceFileName,
      'sequence_url': sequenceUrl,
      'sequence_local_file': sequenceLocalFile,
    };
  }
}
