// ---------------- WriteParameterModel ----------------
class WriteParameterModel {
  String? code;
  String? unit;
  String? newValue;
  String? oldValue;
  String? description;

  WriteParameterModel({
    this.code,
    this.unit,
    this.newValue,
    this.oldValue,
    this.description,
  });

  factory WriteParameterModel.fromJson(Map<String, dynamic> json) =>
      WriteParameterModel(
        code: json['code'],
        unit: json['unit'],
        newValue: json['new_value'],
        oldValue: json['old_value'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'unit': unit,
        'new_value': newValue,
        'old_value': oldValue,
        'description': description,
      };
}

// ---------------- WriteParameter_Status ----------------
class WriteParameterStatus {
  String? status;
  List<int>? dataArray;

  WriteParameterStatus({
    this.status,
    this.dataArray,
  });

  // Optional: fromJson
  factory WriteParameterStatus.fromJson(Map<String, dynamic> json) {
    return WriteParameterStatus(
      status: json['Status'],
      dataArray: json['DataArray'] != null
          ? List<int>.from(json['DataArray'])
          : null,
    );
  }

  // Optional: toJson
  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'DataArray': dataArray,
    };
  }
}