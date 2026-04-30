import 'dart:convert';

class ExcelStructure {
  List<String> headers;
  List<List<String>> values;

  ExcelStructure({
    List<String>? headers,
    List<List<String>>? values,
  })  : headers = headers ?? [],
        values = values ?? [];

  // JSON -> Object
  factory ExcelStructure.fromJson(Map<String, dynamic> json) {
    return ExcelStructure(
      headers: json['Headers'] != null 
          ? List<String>.from(json['Headers']) 
          : [],
      values: json['Values'] != null
          ? (json['Values'] as List)
              .map((row) => List<String>.from(row))
              .toList()
          : [],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Headers': headers,
      'Values': values,
    };
  }
}