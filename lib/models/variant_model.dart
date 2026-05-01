class VariantModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<Variant>? results;

  VariantModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List).map((i) => Variant.fromJson(i)).toList()
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

class Variant {
  int? id;
  String? variantCode;
  String? description;
  int? oem;
  String? vinNo;
  String? isActive;
  String? vehicleModel;
  int? modelId;
  VariantSubModel? subModel;
  int? sModelId;
  String? modelYear;
  int? mYearId;
  String? noOfInjectors;
  String? firingSequence;
  String? noOfFip;
  String? typeName;
  String? applicationName;
  String? type;
  String? rating;
  String? assemblyNo;
  String? rpm;
  int? application;
  String? calibration;
  List<dynamic>? vinDecodings;
  List<VariantPart>? variantPart;
  List<VariantEcuEcu>? variantEcu;
  List<VariantWorkshop>? workshop;
  List<VariantWorkshopGroup>? workshopGroup;

  Variant({
    this.id,
    this.variantCode,
    this.description,
    this.oem,
    this.vinNo,
    this.isActive,
    this.vehicleModel,
    this.modelId,
    this.subModel,
    this.sModelId,
    this.modelYear,
    this.mYearId,
    this.noOfInjectors,
    this.firingSequence,
    this.noOfFip,
    this.typeName,
    this.applicationName,
    this.type,
    this.rating,
    this.assemblyNo,
    this.rpm,
    this.application,
    this.calibration,
    this.vinDecodings,
    this.variantPart,
    this.variantEcu,
    this.workshop,
    this.workshopGroup,
  });

  // JSON -> Object
  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      id: json['id'],
      variantCode: json['variant_code'],
      description: json['description'],
      oem: json['oem'],
      vinNo: json['vin_no'],
      isActive: json['is_active'],
      vehicleModel: json['vehicle_model'],
      modelId: json['model_id'],
      subModel: json['sub_model'] != null
          ? VariantSubModel.fromJson(json['sub_model'])
          : null,
      sModelId: json['s_model_id'],
      modelYear: json['model_year'],
      mYearId: json['m_year_id'],
      noOfInjectors: json['no_of_injectors'],
      firingSequence: json['firing_sequence'],
      noOfFip: json['no_of_fip'],
      typeName: json['type_name'],
      applicationName: json['application_name'],
      type: json['type'],
      rating: json['rating'],
      assemblyNo: json['assembly_no'],
      rpm: json['rpm'],
      application: json['application'],
      calibration: json['calibration'],
      vinDecodings: json['vin_decodings'] != null
          ? List<dynamic>.from(json['vin_decodings'])
          : null,
      variantPart: json['variant_part'] != null
          ? (json['variant_part'] as List)
              .map((i) => VariantPart.fromJson(i))
              .toList()
          : null,
      variantEcu: json['variant_ecu'] != null
          ? (json['variant_ecu'] as List)
              .map((i) => VariantEcuEcu.fromJson(i))
              .toList()
          : null,
      workshop: json['workshop'] != null
          ? (json['workshop'] as List)
              .map((i) => VariantWorkshop.fromJson(i))
              .toList()
          : null,
      workshopGroup: json['workshop_group'] != null
          ? (json['workshop_group'] as List)
              .map((i) => VariantWorkshopGroup.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant_code': variantCode,
      'description': description,
      'oem': oem,
      'vin_no': vinNo,
      'is_active': isActive,
      'vehicle_model': vehicleModel,
      'model_id': modelId,
      'sub_model': subModel?.toJson(),
      's_model_id': sModelId,
      'model_year': modelYear,
      'm_year_id': mYearId,
      'no_of_injectors': noOfInjectors,
      'firing_sequence': firingSequence,
      'no_of_fip': noOfFip,
      'type_name': typeName,
      'application_name': applicationName,
      'type': type,
      'rating': rating,
      'assembly_no': assemblyNo,
      'rpm': rpm,
      'application': application,
      'calibration': calibration,
      'vin_decodings': vinDecodings,
      'variant_part': variantPart?.map((v) => v.toJson()).toList(),
      'variant_ecu': variantEcu?.map((v) => v.toJson()).toList(),
      'workshop': workshop?.map((v) => v.toJson()).toList(),
      'workshop_group': workshopGroup?.map((v) => v.toJson()).toList(),
    };
  }
}

class VariantWorkshop {
  int? id;
  String? name;

  VariantWorkshop({
    this.id,
    this.name,
  });

  // JSON -> Object
  factory VariantWorkshop.fromJson(Map<String, dynamic> json) {
    return VariantWorkshop(
      id: json['id'],
      name: json['name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class VariantWorkshopGroup {
  int? id;
  String? groupName;

  VariantWorkshopGroup({
    this.id,
    this.groupName,
  });

  // JSON -> Object
  factory VariantWorkshopGroup.fromJson(Map<String, dynamic> json) {
    return VariantWorkshopGroup(
      id: json['id'],
      groupName: json['group_name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': groupName,
    };
  }
}

class VariantSubModel {
  int? id;
  String? name;
  String? modelYear;
  List<VariantEcus>? ecus;

  VariantSubModel({
    this.id,
    this.name,
    this.modelYear,
    this.ecus,
  });

  // JSON -> Object
  factory VariantSubModel.fromJson(Map<String, dynamic> json) {
    return VariantSubModel(
      id: json['id'],
      name: json['name'],
      modelYear: json['model_year'],
      ecus: json['ecus'] != null
          ? (json['ecus'] as List).map((i) => VariantEcus.fromJson(i)).toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model_year': modelYear,
      'ecus': ecus?.map((v) => v.toJson()).toList(),
    };
  }
}

class VariantEcus {
  int? id;
  String? name;

  VariantEcus({
    this.id,
    this.name,
  });

  // JSON -> Object
  factory VariantEcus.fromJson(Map<String, dynamic> json) {
    return VariantEcus(
      id: json['id'],
      name: json['name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class VariantEcuEcu {
  int? id;
  VariantEcus? ecu;
  ProductionSwId? productionSwId;
  bool? isLatest;
  bool? isActive;

  VariantEcuEcu({
    this.id,
    this.ecu,
    this.productionSwId,
    this.isLatest,
    this.isActive,
  });

  // JSON -> Object
  factory VariantEcuEcu.fromJson(Map<String, dynamic> json) {
    return VariantEcuEcu(
      id: json['id'],
      ecu: json['ecu'] != null ? VariantEcus.fromJson(json['ecu']) : null,
      productionSwId: json['production_sw_id'] != null
          ? ProductionSwId.fromJson(json['production_sw_id'])
          : null,
      isLatest: json['is_latest'] is bool
          ? json['is_latest']
          : json['is_latest'] ==
              1, // Handles cases where 1/0 is sent instead of true/false
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active'] == 1,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecu': ecu?.toJson(),
      'production_sw_id': productionSwId?.toJson(),
      'is_latest': isLatest,
      'is_active': isActive,
    };
  }
}

class ProductionSwId {
  int? id;
  String? swPartNo;
  String? dataFile;
  String? hexSrecFile;
  String? description;

  ProductionSwId({
    this.id,
    this.swPartNo,
    this.dataFile,
    this.hexSrecFile,
    this.description,
  });

  // JSON -> Object
  factory ProductionSwId.fromJson(Map<String, dynamic> json) {
    return ProductionSwId(
      id: json['id'],
      swPartNo: json['sw_part_no'],
      dataFile: json['data_file'],
      hexSrecFile: json['hex_srec_file'],
      description: json['description'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sw_part_no': swPartNo,
      'data_file': dataFile,
      'hex_srec_file': hexSrecFile,
      'description': description,
    };
  }
}

class VariantPart {
  int? id;
  int? ecuId;
  String? partNo;
  String? description;
  String? partCategory;
  String? position;
  bool? isActive;
  String? value;
  String? slNumber;
  String? comment;

  VariantPart({
    this.id,
    this.ecuId,
    this.partNo,
    this.description,
    this.partCategory,
    this.position,
    this.isActive,
    this.value,
    this.slNumber,
    this.comment,
  });

  // JSON -> Object
  factory VariantPart.fromJson(Map<String, dynamic> json) {
    return VariantPart(
      id: json['id'],
      ecuId: json['ecu_id'],
      partNo: json['part_no'],
      description: json['description'],
      partCategory: json['part_category'],
      position: json['position'],
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active'] == 1,
      value: json['value'],
      slNumber: json['sl_number'],
      comment: json['comment'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecu_id': ecuId,
      'part_no': partNo,
      'description': description,
      'part_category': partCategory,
      'position': position,
      'is_active': isActive,
      'value': value,
      'sl_number': slNumber,
      'comment': comment,
    };
  }
}
