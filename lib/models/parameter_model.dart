import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/liveParameter_model.dart';

class ParameterModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<ParameterResult>? results;

  ParameterModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory ParameterModel.fromJson(Map<String, dynamic> json) {
    return ParameterModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => ParameterResult.fromJson(i))
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

class ParameterResult {
  int? id;
  String? parameter;
  String? description;
  List<ParameterId>? parameterIds;
  String? isActive;

  // Backing fields for observable properties
  String? _unit;
  String? _value;

  ParameterResult({
    this.id,
    this.parameter,
    this.description,
    String? unit,
    String? value,
    this.parameterIds,
    this.isActive,
  }) {
    _unit = unit;
    _value = value;
  }

  // Getter and Setter for unit
  String? get unit => _unit;
  set unit(String? newValue) {
    _unit = newValue;
    // notifyListeners(); // If using ChangeNotifier
  }

  // Getter and Setter for value
  String? get value => _value;
  set value(String? newValue) {
    _value = newValue;
    // notifyListeners(); // If using ChangeNotifier
  }

  // JSON -> Object
  factory ParameterResult.fromJson(Map<String, dynamic> json) {
    return ParameterResult(
      id: json['id'],
      parameter: json['parameter'],
      description: json['description'],
      unit: json['unit'],
      value: json['value'],
      parameterIds: json['parameter_ids'] != null
          ? (json['parameter_ids'] as List)
              .map((i) => ParameterId.fromJson(i))
              .toList()
          : null,
      isActive: json['is_active'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parameter': parameter,
      'description': description,
      'unit': _unit,
      'value': _value,
      'parameter_ids': parameterIds?.map((v) => v.toJson()).toList(),
      'is_active': isActive,
    };
  }
}

class ParameterId {
  int? id;
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  int? ecu;
  int? pidCode;

  ParameterId({
    this.id,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    this.ecu,
    this.pidCode,
  });

  // JSON -> Object
  factory ParameterId.fromJson(Map<String, dynamic> json) {
    return ParameterId(
      id: json['id'],
      vehicleModel: json['vehicle_model'],
      subModel: json['sub_model'],
      modelYear: json['model_year'],
      ecu: json['ecu'],
      pidCode: json['pid_code'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_model': vehicleModel,
      'sub_model': subModel,
      'model_year': modelYear,
      'ecu': ecu,
      'pid_code': pidCode,
    };
  }
}

class ParameterEcuModel {
  String? ecuName;
  int? ecuId;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;

  // Backing fields for observable properties
  List<PidCode>? _parameterList;
  List<PiCodeVariable>? _variableList;
  double? _opacity;
  String? _errorMessage;
  bool? _visibleView;
  double? _listHeight;

  ParameterEcuModel({
    this.ecuName,
    this.ecuId,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    List<PidCode>? parameterList,
    List<PiCodeVariable>? variableList,
    double? opacity,
    String? errorMessage,
    bool? visibleView,
    double? listHeight,
  }) {
    _parameterList = parameterList;
    _variableList = variableList;
    _opacity = opacity;
    _errorMessage = errorMessage;
    _visibleView = visibleView;
    _listHeight = listHeight;
  }

  // Getters and Setters with logic for PropertyChanged
  List<PidCode>? get parameterList => _parameterList;
  set parameterList(List<PidCode>? value) {
    _parameterList = value;
    // notifyListeners();
  }

  List<PiCodeVariable>? get variableList => _variableList;
  set variableList(List<PiCodeVariable>? value) {
    _variableList = value;
    // notifyListeners();
  }

  double? get opacity => _opacity;
  set opacity(double? value) {
    _opacity = value;
    // notifyListeners();
  }

  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    _errorMessage = value;
    // notifyListeners();
  }

  bool? get visibleView => _visibleView;
  set visibleView(bool? value) {
    _visibleView = value;
    // notifyListeners();
  }

  double? get listHeight => _listHeight;
  set listHeight(double? value) {
    _listHeight = value;
    // notifyListeners();
  }

  // JSON -> Object
  factory ParameterEcuModel.fromJson(Map<String, dynamic> json) {
    return ParameterEcuModel(
      ecuName: json['ecu_name'],
      ecuId: json['ecu_id'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      protocol:
          json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
      parameterList: json['parameter_list'] != null
          ? (json['parameter_list'] as List)
              .map((i) => PidCode.fromJson(i))
              .toList()
          : null,
      variableList: json['variable_list'] != null
          ? (json['variable_list'] as List)
              .map((i) => PiCodeVariable.fromJson(i))
              .toList()
          : null,
      opacity: json['opacity']?.toDouble(),
      errorMessage: json['error_message'],
      visibleView: json['visible_view'],
      listHeight: json['list_height']?.toDouble(),
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecu_name': ecuName,
      'ecu_id': ecuId,
      'tx_header': txHeader,
      'rx_header': rxHeader,
      'protocol': protocol?.toJson(),
      'parameter_list': _parameterList?.map((v) => v.toJson()).toList(),
      'variable_list': _variableList?.map((v) => v.toJson()).toList(),
      'opacity': _opacity,
      'error_message': _errorMessage,
      'visible_view': _visibleView,
      'list_height': _listHeight,
    };
  }
}
