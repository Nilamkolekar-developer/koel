class SRSearchRespModel {
  SiebelMessageResp? siebelMessage;
  String? error;

  SRSearchRespModel({
    this.siebelMessage,
    this.error,
  });

  // JSON -> Object
  factory SRSearchRespModel.fromJson(Map<String, dynamic> json) {
    return SRSearchRespModel(
      siebelMessage: json['SiebelMessage'] != null
          ? SiebelMessageResp.fromJson(json['SiebelMessage'])
          : null,
      error: json['Error'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'SiebelMessage': siebelMessage?.toJson(),
      'Error': error,
    };
  }
}

class SiebelMessageResp {
  String? intObjectFormat;
  String? messageId;
  String? intObjectName;
  String? messageType;
  ServiceRequestConnectResp? serviceRequestConnect;

  SiebelMessageResp({
    this.intObjectFormat,
    this.messageId,
    this.intObjectName,
    this.messageType,
    this.serviceRequestConnect,
  });

  // JSON -> Object
  factory SiebelMessageResp.fromJson(Map<String, dynamic> json) {
    return SiebelMessageResp(
      intObjectFormat: json['IntObjectFormat'],
      messageId: json['MessageId'],
      intObjectName: json['IntObjectName'],
      messageType: json['MessageType'],
      serviceRequestConnect: json['Service Request Connect'] != null
          ? ServiceRequestConnectResp.fromJson(json['Service Request Connect'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'IntObjectFormat': intObjectFormat,
      'MessageId': messageId,
      'IntObjectName': intObjectName,
      'MessageType': messageType,
      'Service Request Connect': serviceRequestConnect?.toJson(),
    };
  }
}

class ServiceRequestConnectResp {
  String? ibmChasisNumber;
  String? srNumber;
  String? model;
  String? comments;
  String? ibmEngine;
  String? assetNumber;
  String? srType;
  String? customerName;
  String? statusClone;
  String? ibmAssetLastSerHrs;

  ServiceRequestConnectResp({
    this.ibmChasisNumber,
    this.srNumber,
    this.model,
    this.comments,
    this.ibmEngine,
    this.assetNumber,
    this.srType,
    this.customerName,
    this.statusClone,
    this.ibmAssetLastSerHrs,
  });

  // JSON -> Object
  factory ServiceRequestConnectResp.fromJson(Map<String, dynamic> json) {
    return ServiceRequestConnectResp(
      ibmChasisNumber: json['IBM Chasis Number'],
      srNumber: json['SR Number'],
      model: json['Model'],
      comments: json['Comments'],
      ibmEngine: json['IBM Engine #'],
      assetNumber: json['Asset Number'],
      srType: json['SR Type'],
      customerName: json['Customer Name'],
      statusClone: json['Status Clone'],
      ibmAssetLastSerHrs: json['IBM Asset Last Ser Hrs'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'IBM Chasis Number': ibmChasisNumber,
      'SR Number': srNumber,
      'Model': model,
      'Comments': comments,
      'IBM Engine #': ibmEngine,
      'Asset Number': assetNumber,
      'SR Type': srType,
      'Customer Name': customerName,
      'Status Clone': statusClone,
      'IBM Asset Last Ser Hrs': ibmAssetLastSerHrs,
    };
  }
}
