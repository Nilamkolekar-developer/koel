// import 'package:flutter/material.dart';

// class SessionLogsModel {
//   String? header;
//   String? message;
//   String? status;
//   Color? color;

//   SessionLogsModel({
//     this.header,
//     this.message,
//     this.status,
//     this.color,
//   });

//   /// Convert HEX string (e.g. #FF4CAF50) to Color
//   static Color? _colorFromHex(String? hex) {
//     if (hex == null || hex.isEmpty) return null;
//     final buffer = StringBuffer();
//     if (hex.length == 7) buffer.write('FF'); // add alpha if missing
//     buffer.write(hex.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }

//   /// Convert Color to HEX string
//   static String? _colorToHex(Color? color) {
//     if (color == null) return null;
//     return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
//   }

//   factory SessionLogsModel.fromJson(Map<String, dynamic> json) =>
//       SessionLogsModel(
//         header: json['header'],
//         message: json['message'],
//         status: json['status'],
//         color: _colorFromHex(json['color']),
//       );

//   Map<String, dynamic> toJson() => {
//         'header': header,
//         'message': message,
//         'status': status,
//         'color': _colorToHex(color),
//       };
// }

import 'package:autopeepal/models/variant_model.dart';

class SessionListModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<SessionModel>? results;

  SessionListModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory SessionListModel.fromJson(Map<String, dynamic> json) {
    return SessionListModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => SessionModel.fromJson(i))
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

class SessionModel {
  int? id;
  String? srNumber;
  String? srType;
  String? latlong;
  String? esn;
  String? genset;
  String? hrs;
  String? complaint;
  Variant? variant;
  String? customerName;
  String? macId;
  int? createdBy;
  String? date;
  String? status;

  SessionModel({
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
    this.macId,
    this.createdBy,
    this.date,
    this.status,
  });

  // JSON -> Object
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      srNumber: json['sr_number'],
      srType: json['sr_type'],
      latlong: json['latlong'],
      esn: json['esn'],
      genset: json['genset'],
      hrs: json['hrs'],
      complaint: json['complaint'],
      variant:
          json['variant'] != null ? Variant.fromJson(json['variant']) : null,
      customerName: json['customer_name'],
      macId: json['mac_id'],
      createdBy: json['created_by'],
      date: json['date'],
      status: json['status'],
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
      'variant': variant?.toJson(),
      'customer_name': customerName,
      'mac_id': macId,
      'created_by': createdBy,
      'date': date,
      'status': status,
    };
  }
}

class CloseSessionRequest {
  String? status;

  CloseSessionRequest({
    this.status,
  });

  // JSON -> Object
  factory CloseSessionRequest.fromJson(Map<String, dynamic> json) {
    return CloseSessionRequest(
      status: json['status'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class CloseSessionResponse {
  int? id;
  String? srNumber;
  String? latlong;
  String? esn;
  String? genset;
  String? hrs;
  String? complaint;
  String? customerName;
  int? variant;
  String? macId;
  int? createdBy;
  String? srType;
  String? date;
  String? status;
  String? message;

  CloseSessionResponse({
    this.id,
    this.srNumber,
    this.latlong,
    this.esn,
    this.genset,
    this.hrs,
    this.complaint,
    this.customerName,
    this.variant,
    this.macId,
    this.createdBy,
    this.srType,
    this.date,
    this.status,
    this.message,
  });

  // JSON -> Object
  factory CloseSessionResponse.fromJson(Map<String, dynamic> json) {
    return CloseSessionResponse(
      id: json['id'],
      srNumber: json['sr_number'],
      latlong: json['latlong'],
      esn: json['esn'],
      genset: json['genset'],
      hrs: json['hrs'],
      complaint: json['complaint'],
      customerName: json['customer_name'],
      variant: json['variant'],
      macId: json['mac_id'],
      createdBy: json['created_by'],
      srType: json['sr_type'],
      date: json['date'],
      status: json['status'],
      message: json['message'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sr_number': srNumber,
      'latlong': latlong,
      'esn': esn,
      'genset': genset,
      'hrs': hrs,
      'complaint': complaint,
      'customer_name': customerName,
      'variant': variant,
      'mac_id': macId,
      'created_by': createdBy,
      'sr_type': srType,
      'date': date,
      'status': status,
      'message': message,
    };
  }
}
