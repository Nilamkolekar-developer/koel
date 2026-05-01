import 'package:autopeepal/models/all_models.dart';

class MappedPidRootModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<MappedPidModel>? results;

  MappedPidRootModel({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  // JSON -> Object
  factory MappedPidRootModel.fromJson(Map<String, dynamic> json) {
    return MappedPidRootModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => MappedPidModel.fromJson(i))
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
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }
}


class MappedPidResponseModel {
  int? id;
  String? name;
  String? pidCode;
  String? unit;
  String? status;
  List<String>? values;

  MappedPidResponseModel({
    this.id,
    this.name,
    this.pidCode,
    this.unit,
    this.status,
    this.values,
  });

  // JSON -> Object
  factory MappedPidResponseModel.fromJson(Map<String, dynamic> json) {
    return MappedPidResponseModel(
      id: json['id'],
      name: json['name'],
      pidCode: json['pid_code'],
      unit: json['unit'],
      status: json['status'],
      values: json['values'] != null 
          ? List<String>.from(json['values']) 
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pid_code': pidCode,
      'unit': unit,
      'status': status,
      'values': values,
    };
  }
}

class MappedPidModel {
  int? id;
  String? code;
  String? description;
  List<MappedCode>? codes;

  MappedPidModel({
    this.id,
    this.code,
    this.description,
    this.codes,
  });

  // JSON -> Object
  factory MappedPidModel.fromJson(Map<String, dynamic> json) {
    return MappedPidModel(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      codes: json['codes'] != null
          ? (json['codes'] as List).map((i) => MappedCode.fromJson(i)).toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'codes': codes?.map((v) => v.toJson()).toList(),
    };
  }
}

class MappedCode {
  int? id;
  String? code;
  bool? isActive;

  // Private backing fields
  List<MappedPiCodeVariable>? _mappedPiCodeVariable;
  bool _selected = false;

  MappedCode({
    this.id,
    this.code,
    this.isActive,
    List<MappedPiCodeVariable>? mappedPiCodeVariable,
    bool selected = false,
  }) {
    _mappedPiCodeVariable = mappedPiCodeVariable;
    _selected = selected;
  }

  // Getter and Setter for mappedPiCodeVariable
  List<MappedPiCodeVariable>? get mappedPiCodeVariable => _mappedPiCodeVariable;
  set mappedPiCodeVariable(List<MappedPiCodeVariable>? value) {
    _mappedPiCodeVariable = value;
    // notifyListeners(); // Equivalent to OnPropertyChanged
  }

  // Getter and Setter for Selected
  bool get selected => _selected;
  set selected(bool value) {
    _selected = value;
    // notifyListeners(); // Equivalent to OnPropertyChanged
  }

  // JSON -> Object
  factory MappedCode.fromJson(Map<String, dynamic> json) {
    return MappedCode(
      id: json['id'],
      code: json['code'],
      isActive: json['is_active'],
      selected: json['Selected'] ?? false,
      mappedPiCodeVariable: json['mapped_pi_code_variable'] != null
          ? (json['mapped_pi_code_variable'] as List)
              .map((i) => MappedPiCodeVariable.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'is_active': isActive,
      'Selected': _selected,
      'mapped_pi_code_variable':
          _mappedPiCodeVariable?.map((v) => v.toJson()).toList(),
    };
  }
}

class MappedPiCodeVariable {
  int? id;
  String? name;
  String? pidCode;
  int? totalLen;
  int? length;
  String? unit;
  double? resolution;
  double? offset;
  String? numType;

  MappedPiCodeVariable({
    this.id,
    this.name,
    this.pidCode,
    this.totalLen,
    this.length,
    this.unit,
    this.resolution,
    this.offset,
    this.numType,
  });

  // JSON -> Object
  factory MappedPiCodeVariable.fromJson(Map<String, dynamic> json) {
    return MappedPiCodeVariable(
      id: json['id'],
      name: json['name'],
      pidCode: json['pid_code'],
      totalLen: json['total_len'],
      length: json['length'],
      unit: json['unit'],
      // Using 'as num?' safely converts both int and double from JSON
      resolution: (json['resolution'] as num?)?.toDouble(),
      offset: (json['offset'] as num?)?.toDouble(),
      numType: json['num_type'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pid_code': pidCode,
      'total_len': totalLen,
      'length': length,
      'unit': unit,
      'resolution': resolution,
      'offset': offset,
      'num_type': numType,
    };
  }
}

class MappedPidEcuModel {
  String? ecuName;
  List<MappedCode>? mappedPidList;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;
  double _opacity = 1.0;

  MappedPidEcuModel({
    this.ecuName,
    this.mappedPidList,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    double opacity = 1.0,
  }) {
    _opacity = opacity;
  }

  // Getter and Setter for opacity (logic for OnPropertyChanged)
  double get opacity => _opacity;
  set opacity(double value) {
    _opacity = value;
    // notifyListeners(); // Call this if using Flutter's ChangeNotifier
  }

  // JSON -> Object
  factory MappedPidEcuModel.fromJson(Map<String, dynamic> json) {
    return MappedPidEcuModel(
      ecuName: json['ecu_name'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      protocol:
          json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
      mappedPidList: json['mapped_pid_list'] != null
          ? (json['mapped_pid_list'] as List)
              .map((i) => MappedCode.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecu_name': ecuName,
      'tx_header': txHeader,
      'rx_header': rxHeader,
      'opacity': _opacity,
      'protocol': protocol?.toJson(),
      'mapped_pid_list': mappedPidList?.map((v) => v.toJson()).toList(),
    };
  }
}

class PidCode {
  int? id;
  String? name;
  String? pidCode;
  String? unit;
  String? status;
  List<String>? values;

  PidCode({
    this.id,
    this.name,
    this.pidCode,
    this.unit,
    this.status,
    this.values,
  });

  // JSON -> Object
  factory PidCode.fromJson(Map<String, dynamic> json) {
    return PidCode(
      id: json['id'],
      name: json['name'],
      pidCode: json['pid_code'],
      unit: json['unit'],
      status: json['status'],
      // Safely casting the dynamic list from JSON to a List<String>
      values: json['values'] != null ? List<String>.from(json['values']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pid_code': pidCode,
      'unit': unit,
      'status': status,
      'values': values,
    };
  }
}

class TableCell {
  String? value;

  TableCell({
    this.value,
  });

  // JSON -> Object
  factory TableCell.fromJson(Map<String, dynamic> json) {
    return TableCell(
      value: json['Value'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Value': value,
    };
  }
}

class TableRow {
  String? _header;
  List<TableCell> _cells = [];

  TableRow({
    String? header,
    List<TableCell>? cells,
  }) {
    _header = header;
    _cells = cells ?? [];
  }

  // Getter and Setter for Header
  String? get header => _header;
  set header(String? value) {
    _header = value;
    // notifyListeners(); // If using Flutter's ChangeNotifier
  }

  // Getter and Setter for Cells
  List<TableCell> get cells => _cells;
  set cells(List<TableCell> value) {
    _cells = value;
    // notifyListeners(); // If using Flutter's ChangeNotifier
  }

  // JSON -> Object
  factory TableRow.fromJson(Map<String, dynamic> json) {
    return TableRow(
      header: json['Header'],
      cells: json['Cells'] != null
          ? (json['Cells'] as List).map((i) => TableCell.fromJson(i)).toList()
          : [],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Header': _header,
      'Cells': _cells.map((v) => v.toJson()).toList(),
    };
  }
}
