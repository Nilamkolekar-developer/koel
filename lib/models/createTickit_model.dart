import 'dart:convert';
import 'dart:typed_data';

class CreateTicketModel {
  // Private Backing Fields
  String? _emailId;
  String? _applicationType;
  String? _region;
  String? _workshop;
  String? _location;
  String? _ticketIssue;
  String? _ticketIssueChoicesUuid;
  String? _invoiceNo;
  String? _levelStatus;
  String? _serialNumber;
  String? _invoiceDate;
  Uint8List? _attachment;
  String? _comment;

  // Standard Fields
  String? fileName;
  String? user;
  String? marketPlace;

  CreateTicketModel({
    String? emailId,
    String? applicationType,
    String? region,
    String? workshop,
    String? location,
    String? ticketIssue,
    String? ticketIssueChoicesUuid,
    String? invoiceNo,
    String? levelStatus,
    String? serialNumber,
    String? invoiceDate,
    Uint8List? attachment,
    this.fileName,
    this.user,
    this.marketPlace,
    String? comment,
  }) {
    _emailId = emailId;
    _applicationType = applicationType;
    _region = region;
    _workshop = workshop;
    _location = location;
    _ticketIssue = ticketIssue;
    _ticketIssueChoicesUuid = ticketIssueChoicesUuid;
    _invoiceNo = invoiceNo;
    _levelStatus = levelStatus;
    _serialNumber = serialNumber;
    _invoiceDate = invoiceDate;
    _attachment = attachment;
    _comment = comment;
  }

  // Getters and Setters (to mirror OnPropertyChanged logic)
  String? get emailId => _emailId;
  set emailId(String? value) {
    _emailId = value; /* notifyListeners(); */
  }

  String? get applicationType => _applicationType;
  set applicationType(String? value) {
    _applicationType = value;
  }

  String? get region => _region;
  set region(String? value) {
    _region = value;
  }

  String? get workshop => _workshop;
  set workshop(String? value) {
    _workshop = value;
  }

  String? get location => _location;
  set location(String? value) {
    _location = value;
  }

  String? get ticketIssue => _ticketIssue;
  set ticketIssue(String? value) {
    _ticketIssue = value;
  }

  String? get ticketIssueChoicesUuid => _ticketIssueChoicesUuid;
  set ticketIssueChoicesUuid(String? value) {
    _ticketIssueChoicesUuid = value;
  }

  String? get invoiceNo => _invoiceNo;
  set invoiceNo(String? value) {
    _invoiceNo = value;
  }

  String? get levelStatus => _levelStatus;
  set levelStatus(String? value) {
    _levelStatus = value;
  }

  String? get serialNumber => _serialNumber;
  set serialNumber(String? value) {
    _serialNumber = value;
  }

  String? get invoiceDate => _invoiceDate;
  set invoiceDate(String? value) {
    _invoiceDate = value;
  }

  Uint8List? get attachment => _attachment;
  set attachment(Uint8List? value) {
    _attachment = value;
  }

  String? get comment => _comment;
  set comment(String? value) {
    _comment = value;
  }

  // JSON -> Object
  factory CreateTicketModel.fromJson(Map<String, dynamic> json) {
    return CreateTicketModel(
      emailId: json['emailId'],
      applicationType: json['application_type'],
      region: json['region'],
      workshop: json['workshop'],
      location: json['location'],
      ticketIssue: json['ticket_issue'],
      ticketIssueChoicesUuid: json['ticketissuechoices_uuid'],
      invoiceNo: json['invoice_no'],
      levelStatus: json['level_status'],
      serialNumber: json['serial_number'],
      invoiceDate: json['invoice_date'],
      // Assuming attachment is incoming as a base64 string
      attachment:
          json['attachment'] != null ? base64Decode(json['attachment']) : null,
      fileName: json['file_name'],
      user: json['user'],
      marketPlace: json['market_place'],
      comment: json['comment'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'emailId': _emailId,
      'application_type': _applicationType,
      'region': _region,
      'workshop': _workshop,
      'location': _location,
      'ticket_issue': _ticketIssue,
      'ticketissuechoices_uuid': _ticketIssueChoicesUuid,
      'invoice_no': _invoiceNo,
      'level_status': _levelStatus,
      'serial_number': _serialNumber,
      'invoice_date': _invoiceDate,
      // Sending attachment as base64 string
      'attachment': _attachment != null ? base64Encode(_attachment!) : null,
      'file_name': fileName,
      'user': user,
      'market_place': marketPlace,
      'comment': _comment,
    };
  }
}

class CreateTicketResponseModel {
  String? message;

  CreateTicketResponseModel({
    this.message,
  });

  // JSON -> Object
  factory CreateTicketResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateTicketResponseModel(
      message: json['message'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class RegionModel {
  String? name;

  RegionModel({
    this.name,
  });

  // JSON -> Object
  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      name: json['name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class IssueModel {
  String? message;
  int? count;
  dynamic next;
  dynamic previous;
  List<IssueResultModel>? results;

  IssueModel({
    this.message,
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  // JSON -> Object
  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      message: json['message'],
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => IssueResultModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((v) => v.toJson()).toList(),
    };
  }
}

class IssueResultModel {
  String? id;
  DateTime? created;
  DateTime? modified;
  String? issueRelated;

  IssueResultModel({
    this.id,
    this.created,
    this.modified,
    this.issueRelated,
  });

  // JSON -> Object
  factory IssueResultModel.fromJson(Map<String, dynamic> json) {
    return IssueResultModel(
      id: json['id'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      issueRelated: json['issue_related'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'issue_related': issueRelated,
    };
  }
}

class RelatedIssue {
  int? count;
  dynamic next;
  dynamic previous;
  List<RelatedIssueResultModel>? results;
  String? message;

  RelatedIssue({
    this.count,
    this.next,
    this.previous,
    this.results,
    this.message,
  });

  // JSON -> Object
  factory RelatedIssue.fromJson(Map<String, dynamic> json) {
    return RelatedIssue(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => RelatedIssueResultModel.fromJson(i))
              .toList()
          : null,
      message: json['message'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((v) => v.toJson()).toList(),
      'message': message,
    };
  }
}

class RelatedIssueResultModel {
  String? id;
  DateTime? created;
  DateTime? modified;
  String? issue;
  String? ticketIssue;

  RelatedIssueResultModel({
    this.id,
    this.created,
    this.modified,
    this.issue,
    this.ticketIssue,
  });

  // JSON -> Object
  factory RelatedIssueResultModel.fromJson(Map<String, dynamic> json) {
    return RelatedIssueResultModel(
      id: json['id'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      issue: json['issue'],
      ticketIssue: json['ticket_issue'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'issue': issue,
      'ticket_issue': ticketIssue,
    };
  }
}
