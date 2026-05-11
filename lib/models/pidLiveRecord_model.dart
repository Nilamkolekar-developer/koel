// ---------------- PidLive ----------------
class PidLive {
  String? created;
  List<String>? xAxisPoint;
  List<YAxisPointName>? yAxisPointName;

  PidLive({
    this.created,
    this.xAxisPoint,
    this.yAxisPointName,
  });

  factory PidLive.fromJson(Map<String, dynamic> json) {
    return PidLive(
      created: json['created'],
      xAxisPoint: json['x_axis_point'] != null
          ? List<String>.from(json['x_axis_point'])
          : null,
      yAxisPointName: json['y_axis_point_name'] != null
          ? (json['y_axis_point_name'] as List)
              .map((e) => YAxisPointName.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'x_axis_point': xAxisPoint,
      'y_axis_point_name': yAxisPointName?.map((e) => e.toJson()).toList(),
    };
  }
}

class YAxisPointName {
  String? pidName;
  String? unit;
  String? min;
  String? max;
  List<String>? value;

  YAxisPointName({
    this.pidName,
    this.unit,
    this.min,
    this.max,
    this.value,
  });

  factory YAxisPointName.fromJson(Map<String, dynamic> json) {
    return YAxisPointName(
      pidName: json['pid_name'],
      unit: json['unit'],
      min: json['min'],
      max: json['max'],
      value: json['value'] != null ? List<String>.from(json['value']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid_name': pidName,
      'unit': unit,
      'min': min,
      'max': max,
      'value': value,
    };
  }
}

class PIDLiveRecord {
  String? created;
  List<PidLive>? pidLive;

  PIDLiveRecord({
    this.created,
    this.pidLive,
  });

  factory PIDLiveRecord.fromJson(Map<String, dynamic> json) {
    return PIDLiveRecord(
      created: json['created'],
      pidLive: json['pid_live'] != null
          ? (json['pid_live'] as List).map((e) => PidLive.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'pid_live': pidLive?.map((e) => e.toJson()).toList(),
    };
  }
}
