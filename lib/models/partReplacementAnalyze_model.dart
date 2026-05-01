class PartReplacementAnalyzeModel {
  List<PartReplacementAnalyze>? partReplacement;

  PartReplacementAnalyzeModel({
    this.partReplacement,
  });

  // JSON -> Object
  factory PartReplacementAnalyzeModel.fromJson(Map<String, dynamic> json) {
    return PartReplacementAnalyzeModel(
      partReplacement: json['part_replacement'] != null
          ? (json['part_replacement'] as List)
              .map((i) => PartReplacementAnalyze.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'part_replacement': partReplacement?.map((v) => v.toJson()).toList(),
    };
  }
}

class PartReplacementAnalyze {
  String? partNo;
  String? partDesc;
  String? slNo;
  String? position;
  String? comments;

  PartReplacementAnalyze({
    this.partNo,
    this.partDesc,
    this.slNo,
    this.position,
    this.comments,
  });

  // JSON -> Object
  factory PartReplacementAnalyze.fromJson(Map<String, dynamic> json) {
    return PartReplacementAnalyze(
      partNo: json['part_no'],
      partDesc: json['part_desc'],
      slNo: json['sl_no'],
      position: json['position'],
      comments: json['comments'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'part_no': partNo,
      'part_desc': partDesc,
      'sl_no': slNo,
      'position': position,
      'comments': comments,
    };
  }
}

class PartReplacementAnalyzeRes {
  String? message;
  List<PartReplacementAnalyzeResponse>? result;

  PartReplacementAnalyzeRes({
    this.message,
    this.result,
  });

  // JSON -> Object
  factory PartReplacementAnalyzeRes.fromJson(Map<String, dynamic> json) {
    return PartReplacementAnalyzeRes(
      message: json['message'],
      result: json['result'] != null
          ? (json['result'] as List)
              .map((i) => PartReplacementAnalyzeResponse.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'result': result?.map((v) => v.toJson()).toList(),
    };
  }
}

class PartReplacementAnalyzeResponse {
  int? id;
  int? session;
  String? partNo;
  String? partDesc;
  String? slNo;
  String? position;
  String? comments;
  DateTime? created;
  DateTime? modified;

  PartReplacementAnalyzeResponse({
    this.id,
    this.session,
    this.partNo,
    this.partDesc,
    this.slNo,
    this.position,
    this.comments,
    this.created,
    this.modified,
  });

  // JSON -> Object
  factory PartReplacementAnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return PartReplacementAnalyzeResponse(
      id: json['id'],
      session: json['session'],
      partNo: json['part_no'],
      partDesc: json['part_desc'],
      slNo: json['sl_no'],
      position: json['position'],
      comments: json['comments'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': session,
      'part_no': partNo,
      'part_desc': partDesc,
      'sl_no': slNo,
      'position': position,
      'comments': comments,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
    };
  }
}

class ValidateVariantRequestModel {
  String? engSlno;
  String? engCode;

  ValidateVariantRequestModel({
    this.engSlno,
    this.engCode,
  });

  // JSON -> Object
  factory ValidateVariantRequestModel.fromJson(Map<String, dynamic> json) {
    return ValidateVariantRequestModel(
      engSlno: json['eng_slno'],
      engCode: json['eng_code'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'eng_slno': engSlno,
      'eng_code': engCode,
    };
  }
}

class ValidateVariantResponseModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  String? result;
  List<ValidateVariantModel>? results;

  ValidateVariantResponseModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.result,
    this.results,
  });

  // JSON -> Object
  factory ValidateVariantResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateVariantResponseModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      result: json['result'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => ValidateVariantModel.fromJson(i))
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
      'result': result,
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }
}

class AssemblyEcu {
  int? id;
  AssemEcu? ecu;
  String? partNo;
  String? slNo;
  String? station;

  AssemblyEcu({
    this.id,
    this.ecu,
    this.partNo,
    this.slNo,
    this.station,
  });

  // JSON -> Object
  factory AssemblyEcu.fromJson(Map<String, dynamic> json) {
    return AssemblyEcu(
      id: json['id'],
      ecu: json['ecu'] != null ? AssemEcu.fromJson(json['ecu']) : null,
      partNo: json['part_no'],
      slNo: json['sl_no'],
      station: json['station'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ecu': ecu?.toJson(),
      'part_no': partNo,
      'sl_no': slNo,
      'station': station,
    };
  }
}

class AssemEcu {
  int? id;
  String? name;

  AssemEcu({
    this.id,
    this.name,
  });

  // JSON -> Object
  factory AssemEcu.fromJson(Map<String, dynamic> json) {
    return AssemEcu(
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

class AssemblyFip {
  int? id;
  String? partNo;
  String? slNo;
  String? position;

  AssemblyFip({
    this.id,
    this.partNo,
    this.slNo,
    this.position,
  });

  // JSON -> Object
  factory AssemblyFip.fromJson(Map<String, dynamic> json) {
    return AssemblyFip(
      id: json['id'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      position: json['position'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_no': partNo,
      'sl_no': slNo,
      'position': position,
    };
  }
}

class AssemblyInjector {
  int? id;
  String? partNo;
  String? slNo;
  String? iqa;
  String? position;

  AssemblyInjector({
    this.id,
    this.partNo,
    this.slNo,
    this.iqa,
    this.position,
  });

  // JSON -> Object
  factory AssemblyInjector.fromJson(Map<String, dynamic> json) {
    return AssemblyInjector(
      id: json['id'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      iqa: json['iqa'],
      position: json['position'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_no': partNo,
      'sl_no': slNo,
      'iqa': iqa,
      'position': position,
    };
  }
}

class EngSlno {
  String? engSlno;
  String? variant;

  EngSlno({
    this.engSlno,
    this.variant,
  });

  // JSON -> Object
  factory EngSlno.fromJson(Map<String, dynamic> json) {
    return EngSlno(
      engSlno: json['eng_slno'],
      variant: json['variant'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'eng_slno': engSlno,
      'variant': variant,
    };
  }
}

class ValidateVariantModel {
  int? id;
  EngSlno? engSlno;
  DateTime? date;
  int? user;
  String? comment;
  List<AssemblyEcu>? assemblyEcu;
  List<AssemblyFip>? assemblyFip;
  List<AssemblyInjector>? assemblyInjectors;

  ValidateVariantModel({
    this.id,
    this.engSlno,
    this.date,
    this.user,
    this.comment,
    this.assemblyEcu,
    this.assemblyFip,
    this.assemblyInjectors,
  });

  // JSON -> Object
  factory ValidateVariantModel.fromJson(Map<String, dynamic> json) {
    return ValidateVariantModel(
      id: json['id'],
      engSlno:
          json['eng_slno'] != null ? EngSlno.fromJson(json['eng_slno']) : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      user: json['user'],
      comment: json['comment'],
      assemblyEcu: json['assembly_ecu'] != null
          ? (json['assembly_ecu'] as List)
              .map((i) => AssemblyEcu.fromJson(i))
              .toList()
          : null,
      assemblyFip: json['assembly_fip'] != null
          ? (json['assembly_fip'] as List)
              .map((i) => AssemblyFip.fromJson(i))
              .toList()
          : null,
      assemblyInjectors: json['assembly_injectors'] != null
          ? (json['assembly_injectors'] as List)
              .map((i) => AssemblyInjector.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eng_slno': engSlno?.toJson(),
      'date': date?.toIso8601String(),
      'user': user,
      'comment': comment,
      'assembly_ecu': assemblyEcu?.map((v) => v.toJson()).toList(),
      'assembly_fip': assemblyFip?.map((v) => v.toJson()).toList(),
      'assembly_injectors': assemblyInjectors?.map((v) => v.toJson()).toList(),
    };
  }
}

class VariantPartReplacementEcuRequest {
  String? position;
  String? partNo;
  String? slNo;

  VariantPartReplacementEcuRequest({
    this.position,
    this.partNo,
    this.slNo,
  });

  // JSON -> Object
  factory VariantPartReplacementEcuRequest.fromJson(Map<String, dynamic> json) {
    return VariantPartReplacementEcuRequest(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
    };
  }
}

class VariantPartReplacementEcuResponse {
  String? ecu;
  String? partNo;
  String? slNo;
  String? message;
  String? status;
  bool? success;

  VariantPartReplacementEcuResponse({
    this.ecu,
    this.partNo,
    this.slNo,
    this.message,
    this.status,
    this.success,
  });

  // JSON -> Object
  factory VariantPartReplacementEcuResponse.fromJson(
      Map<String, dynamic> json) {
    return VariantPartReplacementEcuResponse(
      ecu: json['ecu'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      message: json['message'],
      status: json['status'],
      success: json['success'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecu': ecu,
      'part_no': partNo,
      'sl_no': slNo,
      'message': message,
      'status': status,
      'success': success,
    };
  }
}

class VariantPartReplacementFipRequest {
  String? position;
  String? partNo;
  String? slNo;

  VariantPartReplacementFipRequest({
    this.position,
    this.partNo,
    this.slNo,
  });

  // JSON -> Object
  factory VariantPartReplacementFipRequest.fromJson(Map<String, dynamic> json) {
    return VariantPartReplacementFipRequest(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
    };
  }
}

class VariantPartReplacementFipResponse {
  String? position;
  String? partNo;
  String? slNo;
  String? message;
  String? status;
  bool? success;

  VariantPartReplacementFipResponse({
    this.position,
    this.partNo,
    this.slNo,
    this.message,
    this.status,
    this.success,
  });

  // JSON -> Object
  factory VariantPartReplacementFipResponse.fromJson(
      Map<String, dynamic> json) {
    return VariantPartReplacementFipResponse(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      message: json['message'],
      status: json['status'],
      success: json['success'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
      'message': message,
      'status': status,
      'success': success,
    };
  }
}

class VariantPartReplacementInjectorRequest {
  String? position;
  String? partNo;
  String? slNo;

  VariantPartReplacementInjectorRequest({
    this.position,
    this.partNo,
    this.slNo,
  });

  // JSON -> Object
  factory VariantPartReplacementInjectorRequest.fromJson(
      Map<String, dynamic> json) {
    return VariantPartReplacementInjectorRequest(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
    };
  }
}

class VariantPartReplacementInjectorResponse {
  String? position;
  String? partNo;
  String? slNo;
  String? message;
  String? status;
  bool? success;

  VariantPartReplacementInjectorResponse({
    this.position,
    this.partNo,
    this.slNo,
    this.message,
    this.status,
    this.success,
  });

  // JSON -> Object
  factory VariantPartReplacementInjectorResponse.fromJson(
      Map<String, dynamic> json) {
    return VariantPartReplacementInjectorResponse(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      message: json['message'],
      status: json['status'],
      success: json['success'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
      'message': message,
      'status': status,
      'success': success,
    };
  }
}

class VariantPartReplacementOtherRequest {
  String? position;
  String? partNo;
  String? slNo;

  VariantPartReplacementOtherRequest({
    this.position,
    this.partNo,
    this.slNo,
  });

  // JSON -> Object
  factory VariantPartReplacementOtherRequest.fromJson(
      Map<String, dynamic> json) {
    return VariantPartReplacementOtherRequest(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
    };
  }
}

class VariantPartReplacementOtherResponse {
  String? position;
  String? partNo;
  String? slNo;
  String? message;

  VariantPartReplacementOtherResponse({
    this.position,
    this.partNo,
    this.slNo,
    this.message,
  });

  // JSON -> Object
  factory VariantPartReplacementOtherResponse.fromJson(
      Map<String, dynamic> json) {
    return VariantPartReplacementOtherResponse(
      position: json['position'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      message: json['message'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'part_no': partNo,
      'sl_no': slNo,
      'message': message,
    };
  }
}

class VariantPartRoot {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<VariantPartResult>? results;

  VariantPartRoot({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory VariantPartRoot.fromJson(Map<String, dynamic> json) {
    return VariantPartRoot(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => VariantPartResult.fromJson(i))
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

class VariantPartResult {
  int? id;
  String? srNumber;
  String? srType;
  String? latlong;
  String? esn;
  String? genset;
  String? hrs;
  String? complaint;
  int? variant;
  String? customerName;
  int? createdBy;
  String? status;
  String? date;
  List<SrsessionEcu>? srsessionEcu;
  List<SrsessionFip>? srsessionFip;
  List<SrsessionInjector>? srsessionInjectors;
  List<SrsessionOtherPart>? srsessionOtherPart;

  VariantPartResult({
    this.id,
    this.srNumber,
    this.srType,
    this.latlong,
    this.esn,
    this.genset,
    this.hrs,
    this.complaint,
    this.variant,
    this.customerName,
    this.createdBy,
    this.status,
    this.date,
    this.srsessionEcu,
    this.srsessionFip,
    this.srsessionInjectors,
    this.srsessionOtherPart,
  });

  // JSON -> Object
  factory VariantPartResult.fromJson(Map<String, dynamic> json) {
    return VariantPartResult(
      id: json['id'],
      srNumber: json['sr_number'],
      srType: json['sr_type'],
      latlong: json['latlong'],
      esn: json['esn'],
      genset: json['genset'],
      hrs: json['hrs'],
      complaint: json['complaint'],
      variant: json['variant'],
      customerName: json['customer_name'],
      createdBy: json['created_by'],
      status: json['status'],
      date: json['date'],
      srsessionEcu: json['srsession_ecu'] != null
          ? (json['srsession_ecu'] as List)
              .map((i) => SrsessionEcu.fromJson(i))
              .toList()
          : null,
      srsessionFip: json['srsession_fip'] != null
          ? (json['srsession_fip'] as List)
              .map((i) => SrsessionFip.fromJson(i))
              .toList()
          : null,
      srsessionInjectors: json['srsession_injectors'] != null
          ? (json['srsession_injectors'] as List)
              .map((i) => SrsessionInjector.fromJson(i))
              .toList()
          : null,
      srsessionOtherPart: json['srsession_other_part'] != null
          ? (json['srsession_other_part'] as List)
              .map((i) => SrsessionOtherPart.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sr_number': srNumber,
      'sr_type': srType,
      'latlong': latlong,
      'esn': esn,
      'genset': genset,
      'hrs': hrs,
      'complaint': complaint,
      'variant': variant,
      'customer_name': customerName,
      'created_by': createdBy,
      'status': status,
      'date': date,
      'srsession_ecu': srsessionEcu?.map((v) => v.toJson()).toList(),
      'srsession_fip': srsessionFip?.map((v) => v.toJson()).toList(),
      'srsession_injectors':
          srsessionInjectors?.map((v) => v.toJson()).toList(),
      'srsession_other_part':
          srsessionOtherPart?.map((v) => v.toJson()).toList(),
    };
  }
}

class SrsessionEcu {
  int? id;
  dynamic variantPart;
  String? partNo;
  String? slNo;
  String? position;
  DateTime? created;

  SrsessionEcu({
    this.id,
    this.variantPart,
    this.partNo,
    this.slNo,
    this.position,
    this.created,
  });

  // JSON -> Object
  factory SrsessionEcu.fromJson(Map<String, dynamic> json) {
    return SrsessionEcu(
      id: json['id'],
      variantPart: json['variant_part'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      position: json['position'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant_part': variantPart,
      'part_no': partNo,
      'sl_no': slNo,
      'position': position,
      'created': created?.toIso8601String(),
    };
  }
}

class SrsessionFip {
  int? id;
  String? partNo;
  String? slNo;
  String? position;
  DateTime? created;

  SrsessionFip({
    this.id,
    this.partNo,
    this.slNo,
    this.position,
    this.created,
  });

  // JSON -> Object
  factory SrsessionFip.fromJson(Map<String, dynamic> json) {
    return SrsessionFip(
      id: json['id'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      position: json['position'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_no': partNo,
      'sl_no': slNo,
      'position': position,
      'created': created?.toIso8601String(),
    };
  }
}

class SrsessionInjector {
  int? id;
  String? partNo;
  String? slNo;
  String? position;
  dynamic iqa;
  DateTime? created;

  SrsessionInjector({
    this.id,
    this.partNo,
    this.slNo,
    this.position,
    this.iqa,
    this.created,
  });

  // JSON -> Object
  factory SrsessionInjector.fromJson(Map<String, dynamic> json) {
    return SrsessionInjector(
      id: json['id'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      position: json['position'],
      iqa: json['iqa'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_no': partNo,
      'sl_no': slNo,
      'position': position,
      'iqa': iqa,
      'created': created?.toIso8601String(),
    };
  }
}

class SrsessionOtherPart {
  int? id;
  String? partNo;
  String? slNo;
  String? position;
  DateTime? created;

  SrsessionOtherPart({
    this.id,
    this.partNo,
    this.slNo,
    this.position,
    this.created,
  });

  // JSON -> Object
  factory SrsessionOtherPart.fromJson(Map<String, dynamic> json) {
    return SrsessionOtherPart(
      id: json['id'],
      partNo: json['part_no'],
      slNo: json['sl_no'],
      position: json['position'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_no': partNo,
      'sl_no': slNo,
      'position': position,
      'created': created?.toIso8601String(),
    };
  }
}
