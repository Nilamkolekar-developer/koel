import 'package:autopeepal/models/actuatorTest_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/iorTest_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/partReplacementAnalyze_model.dart';
import 'package:autopeepal/models/pidLiveRecord_model.dart';
import 'package:autopeepal/models/reportLocationModel.dart';
import 'package:autopeepal/models/uploadEngineHr_model.dart';

class ClearDtcOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<ClearDtcRecord>? cdr;

  ClearDtcOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.cdr,
  });

  // JSON -> Object
  factory ClearDtcOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return ClearDtcOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      cdr: json['CDR'] != null
          ? (json['CDR'] as List)
              .map((i) => ClearDtcRecord.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'CDR': cdr?.map((v) => v.toJson()).toList(),
    };
  }
}

class ReadDtcOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<PostDtcRecord>? pdr;
  String? datetime;

  ReadDtcOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.pdr,
    this.datetime,
  });

  // JSON -> Object
  factory ReadDtcOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return ReadDtcOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      pdr: json['PDR'] != null
          ? (json['PDR'] as List).map((i) => PostDtcRecord.fromJson(i)).toList()
          : null,
      datetime: json['datetime'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PDR': pdr?.map((v) => v.toJson()).toList(),
      'datetime': datetime,
    };
  }
}

class PidRecordingOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<PIDLiveRecord>? liveRecord;

  PidRecordingOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.liveRecord,
  });

  // JSON -> Object
  factory PidRecordingOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return PidRecordingOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      liveRecord: json['LiveRecord'] != null
          ? (json['LiveRecord'] as List)
              .map((i) => PIDLiveRecord.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'LiveRecord': liveRecord?.map((v) => v.toJson()).toList(),
    };
  }
}

// class PidSnapshotOfflineAnalyze {
//   String? type;
//   int? srnId;
//   String? srNumber;
//   List<SnapshotRecord>? snapshot;
//   String? datetime;

//   PidSnapshotOfflineAnalyze({
//     this.type,
//     this.srnId,
//     this.srNumber,
//     this.snapshot,
//     this.datetime,
//   });

//   // JSON -> Object
//   factory PidSnapshotOfflineAnalyze.fromJson(Map<String, dynamic> json) {
//     return PidSnapshotOfflineAnalyze(
//       type: json['type'],
//       srnId: json['srn_id'],
//       srNumber: json['sr_number'],
//       snapshot: json['Snapshot'] != null
//           ? (json['Snapshot'] as List)
//               .map((i) => SnapshotRecord.fromJson(i))
//               .toList()
//           : null,
//       datetime: json['datetime'],
//     );
//   }

//   // Object -> JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'type': type,
//       'srn_id': srnId,
//       'sr_number': srNumber,
//       'Snapshot': snapshot?.map((v) => v.toJson()).toList(),
//       'datetime': datetime,
//     };
//   }
// }

class PidSnapshotOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<SnapshotRecord>? snapshotData;
  String? datetime;

  PidSnapshotOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.snapshotData,
    this.datetime,
  });

  factory PidSnapshotOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return PidSnapshotOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      snapshotData: json['Snapshot'] != null
          ? (json['Snapshot'] as List)
              .map((e) => SnapshotRecord.fromJson(e))
              .toList()
          : null,
      datetime: json['datetime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'Snapshot': snapshotData?.map((e) => e.toJson()).toList(),
      'datetime': datetime,
    };
  }
}

class SnapshotRecord {
  String? code;
  String? value;

  SnapshotRecord({
    this.code,
    this.value,
  });

  factory SnapshotRecord.fromJson(Map<String, dynamic> json) {
    return SnapshotRecord(
      code: json['code'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'value': value,
    };
  }
}

class WriteParameterOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<PidWriteRecord>? pidWriteRecord;

  WriteParameterOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.pidWriteRecord,
  });

  // JSON -> Object
  factory WriteParameterOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return WriteParameterOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      pidWriteRecord: json['PidWriteRecord'] != null
          ? (json['PidWriteRecord'] as List)
              .map((i) => PidWriteRecord.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PidWriteRecord': pidWriteRecord?.map((v) => v.toJson()).toList(),
    };
  }
}

class FlashOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<FlashRecord>? flashRecord;

  FlashOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.flashRecord,
  });

  // JSON -> Object
  factory FlashOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return FlashOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      flashRecord: json['FlashRecord'] != null
          ? (json['FlashRecord'] as List)
              .map((i) => FlashRecord.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'FlashRecord': flashRecord?.map((v) => v.toJson()).toList(),
    };
  }
}

class RoutineTestOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  List<RoutineTestAnalyzeModel>? routineTestRecord;

  RoutineTestOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.routineTestRecord,
  });

  // JSON -> Object
  factory RoutineTestOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return RoutineTestOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      routineTestRecord: json['RoutineTestRecord'] != null
          ? (json['RoutineTestRecord'] as List)
              .map((i) => RoutineTestAnalyzeModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'RoutineTestRecord': routineTestRecord?.map((v) => v.toJson()).toList(),
    };
  }
}

class ActuatorOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  ActuatorTestAnalyzeModel? actuatorRecord;

  ActuatorOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.actuatorRecord,
  });

  // JSON -> Object
  factory ActuatorOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return ActuatorOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      actuatorRecord: json['ActuatorRecord'] != null
          ? ActuatorTestAnalyzeModel.fromJson(json['ActuatorRecord'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'ActuatorRecord': actuatorRecord?.toJson(),
    };
  }
}

class PartReplacementOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  PartReplacementAnalyzeModel? partReplacement;

  PartReplacementOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.partReplacement,
  });

  // JSON -> Object
  factory PartReplacementOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return PartReplacementOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      partReplacement: json['PartReplacement'] != null
          ? PartReplacementAnalyzeModel.fromJson(json['PartReplacement'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PartReplacement': partReplacement?.toJson(),
    };
  }
}

class PartReplacementEcuOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  VariantPartReplacementEcuRequest? partReplacementEcu;

  PartReplacementEcuOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.partReplacementEcu,
  });

  // JSON -> Object
  factory PartReplacementEcuOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return PartReplacementEcuOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      partReplacementEcu: json['PartReplacementEcu'] != null
          ? VariantPartReplacementEcuRequest.fromJson(
              json['PartReplacementEcu'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PartReplacementEcu': partReplacementEcu?.toJson(),
    };
  }
}

class PartReplacementFipOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  VariantPartReplacementFipRequest? partReplacementFip;

  PartReplacementFipOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.partReplacementFip,
  });

  // JSON -> Object
  factory PartReplacementFipOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return PartReplacementFipOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      partReplacementFip: json['PartReplacementFip'] != null
          ? VariantPartReplacementFipRequest.fromJson(
              json['PartReplacementFip'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PartReplacementFip': partReplacementFip?.toJson(),
    };
  }
}

class PartReplacementInjectorsOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  VariantPartReplacementInjectorRequest? partReplacementInjectors;

  PartReplacementInjectorsOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.partReplacementInjectors,
  });

  // JSON -> Object
  factory PartReplacementInjectorsOfflineAnalyze.fromJson(
      Map<String, dynamic> json) {
    return PartReplacementInjectorsOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      partReplacementInjectors: json['PartReplacementInjectors'] != null
          ? VariantPartReplacementInjectorRequest.fromJson(
              json['PartReplacementInjectors'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PartReplacementInjectors': partReplacementInjectors?.toJson(),
    };
  }
}

class PartReplacementOtherOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  VariantPartReplacementOtherRequest? partReplacementOther;

  PartReplacementOtherOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.partReplacementOther,
  });

  // JSON -> Object
  factory PartReplacementOtherOfflineAnalyze.fromJson(
      Map<String, dynamic> json) {
    return PartReplacementOtherOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      partReplacementOther: json['PartReplacementOther'] != null
          ? VariantPartReplacementOtherRequest.fromJson(
              json['PartReplacementOther'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'PartReplacementOther': partReplacementOther?.toJson(),
    };
  }
}

class FreezeFrameOfflineAnalyze {
  String? type;
  int? srnId;
  String? srNumber;
  FreezeFrameAnalyze? freezeFrame;

  FreezeFrameOfflineAnalyze({
    this.type,
    this.srnId,
    this.srNumber,
    this.freezeFrame,
  });

  // JSON -> Object
  factory FreezeFrameOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return FreezeFrameOfflineAnalyze(
      type: json['type'],
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      freezeFrame: json['freeze_frame'] != null
          ? FreezeFrameAnalyze.fromJson(json['freeze_frame'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'srn_id': srnId,
      'sr_number': srNumber,
      'freeze_frame': freezeFrame?.toJson(),
    };
  }
}

class EngineHrsOfflineAnalyze {
  int? srnId;
  String? srNumber;
  UploadEngineHrsModel? engineHours;

  EngineHrsOfflineAnalyze({
    this.srnId,
    this.srNumber,
    this.engineHours,
  });

  // JSON -> Object
  factory EngineHrsOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return EngineHrsOfflineAnalyze(
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      engineHours: json['EngineHours'] != null
          ? UploadEngineHrsModel.fromJson(json['EngineHours'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'srn_id': srnId,
      'sr_number': srNumber,
      'EngineHours': engineHours?.toJson(),
    };
  }
}

class LocationOfflineAnalyze {
  int? srnId;
  String? srNumber;
  ReportLocationModel? location;

  LocationOfflineAnalyze({
    this.srnId,
    this.srNumber,
    this.location,
  });

  // JSON -> Object
  factory LocationOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return LocationOfflineAnalyze(
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      location: json['Location'] != null
          ? ReportLocationModel.fromJson(json['Location'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'srn_id': srnId,
      'sr_number': srNumber,
      'Location': location?.toJson(),
    };
  }
}

class GdOfflineAnalyze {
  int? srnId;
  String? srNumber;
  GdCommentModel? gdCommentModel;

  GdOfflineAnalyze({
    this.srnId,
    this.srNumber,
    this.gdCommentModel,
  });

  // JSON -> Object
  factory GdOfflineAnalyze.fromJson(Map<String, dynamic> json) {
    return GdOfflineAnalyze(
      srnId: json['srn_id'],
      srNumber: json['sr_number'],
      gdCommentModel: json['GdCommentModel'] != null
          ? GdCommentModel.fromJson(json['GdCommentModel'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'srn_id': srnId,
      'sr_number': srNumber,
      'GdCommentModel': gdCommentModel?.toJson(),
    };
  }
}
