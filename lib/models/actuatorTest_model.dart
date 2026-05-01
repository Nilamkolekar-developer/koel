class ActuatorTestModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ActuatorTestResult>? results;
  String? message;

  ActuatorTestModel(
      {this.count, this.next, this.previous, this.results, this.message});

  factory ActuatorTestModel.fromJson(Map<String, dynamic> json) =>
      ActuatorTestModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        message: json['message'],
        results: json['results'] != null
            ? List<ActuatorTestResult>.from(
                json['results'].map((x) => ActuatorTestResult.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'message': message,
        'results':
            results != null ? results!.map((x) => x.toJson()).toList() : null,
      };
}

class ActuatorTestResult {
  int? id;
  String? actuatorName;
  int? oem;
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  int? ecu;
  String? startTest;
  String? stopTest;
  String? returnControl;
  String? type;
  String? startTestTime;
  String? stopTestTime;
  String? iterations;
  String? isActive;
  int? length;
  double? min;
  double? max;

  ActuatorTestResult({
    this.id,
    this.actuatorName,
    this.oem,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    this.ecu,
    this.startTest,
    this.stopTest,
    this.returnControl,
    this.type,
    this.startTestTime,
    this.stopTestTime,
    this.iterations,
    this.isActive,
    this.length,
    this.min,
    this.max,
  });

  // JSON -> Object (Map to Object)
  factory ActuatorTestResult.fromJson(Map<String, dynamic> json) {
    return ActuatorTestResult(
      id: json['id'],
      actuatorName: json['actuator_name'],
      oem: json['oem'],
      vehicleModel: json['vehicle_model'],
      subModel: json['sub_model'],
      modelYear: json['model_year'],
      ecu: json['ecu'],
      startTest: json['start_test'],
      stopTest: json['stop_test'],
      returnControl: json['return_control'],
      type: json['type'],
      startTestTime: json['start_test_time'],
      stopTestTime: json['stop_test_time'],
      iterations: json['iterations'],
      isActive: json['is_active'],
      length: json['length'],
      // Safety check for double conversion
      min: json['min']?.toDouble(),
      max: json['max']?.toDouble(),
    );
  }

  // Object -> JSON (Object to Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actuator_name': actuatorName,
      'oem': oem,
      'vehicle_model': vehicleModel,
      'sub_model': subModel,
      'model_year': modelYear,
      'ecu': ecu,
      'start_test': startTest,
      'stop_test': stopTest,
      'return_control': returnControl,
      'type': type,
      'start_test_time': startTestTime,
      'stop_test_time': stopTestTime,
      'iterations': iterations,
      'is_active': isActive,
      'length': length,
      'min': min,
      'max': max,
    };
  }
}

class ActuatorTestAnalyzeRootModel {
  List<ActuatorTestAnalyzeModel>? actuator;

  ActuatorTestAnalyzeRootModel({this.actuator});

  // JSON -> Object
  factory ActuatorTestAnalyzeRootModel.fromJson(Map<String, dynamic> json) {
    return ActuatorTestAnalyzeRootModel(
      actuator: json['actuator'] != null
          ? (json['actuator'] as List)
              .map((i) => ActuatorTestAnalyzeModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'actuator': actuator?.map((v) => v.toJson()).toList(),
    };
  }
}

class ActuatorTestAnalyzeModel {
  String? name;
  String? status;
  String? startDate;
  String? endDate;
  String? startRequest;
  String? stopRequest;
  String? lastResponse;

  ActuatorTestAnalyzeModel({
    this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.startRequest,
    this.stopRequest,
    this.lastResponse,
  });

  factory ActuatorTestAnalyzeModel.fromJson(Map<String, dynamic> json) {
    return ActuatorTestAnalyzeModel(
      name: json['name'],
      status: json['status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      startRequest: json['start_request'],
      stopRequest: json['stop_request'],
      lastResponse: json['last_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'start_request': startRequest,
      'stop_request': stopRequest,
      'last_response': lastResponse,
    };
  }
}
