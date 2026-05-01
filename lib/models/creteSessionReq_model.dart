class CreateSessionReqModel {
  String? macId;
  String? instanceId;

  // Private Backing Fields
  String? _srNumber;
  String? _srType;
  String? _customerVoice;
  String? _latlong;
  String? _esn;
  String? _genset;
  String? _hrs;
  String? _complaint;
  String? _variant;
  String? _customerName;
  int? _createdBy;

  CreateSessionReqModel({
    this.macId,
    this.instanceId,
    String? srNumber,
    String? srType,
    String? customerVoice,
    String? latlong,
    String? esn,
    String? genset,
    String? hrs,
    String? complaint,
    String? variant,
    String? customerName,
    int? createdBy,
  }) {
    _srNumber = srNumber;
    _srType = srType;
    _customerVoice = customerVoice;
    _latlong = latlong;
    _esn = esn;
    _genset = genset;
    _hrs = hrs;
    _complaint = complaint;
    _variant = variant;
    _customerName = customerName;
    _createdBy = createdBy;
  }

  // Getters and Setters
  String? get srNumber => _srNumber;
  set srNumber(String? value) {
    _srNumber = value; /* notifyListeners(); */
  }

  String? get srType => _srType;
  set srType(String? value) {
    _srType = value; /* notifyListeners(); */
  }

  String? get customerVoice => _customerVoice;
  set customerVoice(String? value) {
    _customerVoice = value; /* notifyListeners(); */
  }

  String? get latlong => _latlong;
  set latlong(String? value) {
    _latlong = value; /* notifyListeners(); */
  }

  String? get esn => _esn;
  set esn(String? value) {
    _esn = value; /* notifyListeners(); */
  }

  String? get genset => _genset;
  set genset(String? value) {
    _genset = value; /* notifyListeners(); */
  }

  String? get hrs => _hrs;
  set hrs(String? value) {
    _hrs = value; /* notifyListeners(); */
  }

  String? get complaint => _complaint;
  set complaint(String? value) {
    _complaint = value; /* notifyListeners(); */
  }

  String? get variant => _variant;
  set variant(String? value) {
    _variant = value; /* notifyListeners(); */
  }

  String? get customerName => _customerName;
  set customerName(String? value) {
    _customerName = value; /* notifyListeners(); */
  }

  int? get createdBy => _createdBy;
  set createdBy(int? value) {
    _createdBy = value; /* notifyListeners(); */
  }

  // JSON -> Object
  factory CreateSessionReqModel.fromJson(Map<String, dynamic> json) {
    return CreateSessionReqModel(
      macId: json['mac_id'],
      instanceId: json['instance_id'],
      srNumber: json['sr_number'],
      srType: json['sr_type'],
      customerVoice: json['customer_voice'],
      latlong: json['latlong'],
      esn: json['esn'],
      genset: json['genset'],
      hrs: json['hrs'],
      complaint: json['complaint'],
      variant: json['variant'],
      customerName: json['customer_name'],
      createdBy: json['created_by'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'mac_id': macId,
      'instance_id': instanceId,
      'sr_number': _srNumber,
      'sr_type': _srType,
      'customer_voice': _customerVoice,
      'latlong': _latlong,
      'esn': _esn,
      'genset': _genset,
      'hrs': _hrs,
      'complaint': _complaint,
      'variant': _variant,
      'customer_name': _customerName,
      'created_by': _createdBy,
    };
  }
}

class CreateSessionResModel {
  int? id;
  String? srNumber;
  String? srType;
  String? latlong;
  String? esn;
  String? genset;
  String? hrs;
  String? complaint;
  int? variant;
  String? macId;
  String? customerName;
  String? message;
  bool? success;

  CreateSessionResModel({
    this.id,
    this.srNumber,
    this.srType,
    this.latlong,
    this.esn,
    this.genset,
    this.hrs,
    this.complaint,
    this.variant,
    this.macId,
    this.customerName,
    this.message,
    this.success,
  });

  // JSON -> Object
  factory CreateSessionResModel.fromJson(Map<String, dynamic> json) {
    return CreateSessionResModel(
      id: json['id'],
      srNumber: json['sr_number'],
      srType: json['sr_type'],
      latlong: json['latlong'],
      esn: json['esn'],
      genset: json['genset'],
      hrs: json['hrs'],
      complaint: json['complaint'],
      variant: json['variant'],
      macId: json['mac_id'],
      customerName: json['customer_name'],
      message: json['message'],
      success: json['success'],
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
      'mac_id': macId,
      'customer_name': customerName,
      'message': message,
      'success': success,
    };
  }
}

class GetSrModel {
  String? srNumber;

  GetSrModel({
    this.srNumber,
  });

  // JSON -> Object
  factory GetSrModel.fromJson(Map<String, dynamic> json) {
    return GetSrModel(
      srNumber: json['sr_number'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'sr_number': srNumber,
    };
  }
}
