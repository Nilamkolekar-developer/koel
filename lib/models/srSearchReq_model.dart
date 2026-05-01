class SRSearchRequestModel {
  Body? body;

  SRSearchRequestModel({
    this.body,
  });

  // JSON -> Object
  factory SRSearchRequestModel.fromJson(Map<String, dynamic> json) {
    return SRSearchRequestModel(
      body: json['body'] != null ? Body.fromJson(json['body']) : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'body': body?.toJson(),
    };
  }
}

class Body {
  SiebelMessage? siebelMessage;

  Body({
    this.siebelMessage,
  });

  // JSON -> Object
  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      siebelMessage: json['SiebelMessage'] != null
          ? SiebelMessage.fromJson(json['SiebelMessage'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'SiebelMessage': siebelMessage?.toJson(),
    };
  }
}

class SiebelMessage {
  final String messageId = "";
  final String messageType = "Integration Object";
  final String intObjectName = "Service Request Connect IO";
  final String intObjectFormat = "Siebel Hierarchical";

  ListOfServiceRequestConnectIo? listOfServiceRequestConnectIo;

  SiebelMessage({
    this.listOfServiceRequestConnectIo,
  });

  // JSON -> Object
  factory SiebelMessage.fromJson(Map<String, dynamic> json) {
    return SiebelMessage(
      listOfServiceRequestConnectIo:
          json['ListOfService Request Connect IO'] != null
              ? ListOfServiceRequestConnectIo.fromJson(
                  json['ListOfService Request Connect IO'])
              : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'MessageId': messageId,
      'MessageType': messageType,
      'IntObjectName': intObjectName,
      'IntObjectFormat': intObjectFormat,
      'ListOfService Request Connect IO':
          listOfServiceRequestConnectIo?.toJson(),
    };
  }
}

class ListOfServiceRequestConnectIo {
  ServiceRequestConnect? serviceRequestConnect;

  ListOfServiceRequestConnectIo({
    this.serviceRequestConnect,
  });

  // JSON -> Object
  factory ListOfServiceRequestConnectIo.fromJson(Map<String, dynamic> json) {
    return ListOfServiceRequestConnectIo(
      serviceRequestConnect: json['Service Request Connect'] != null
          ? ServiceRequestConnect.fromJson(json['Service Request Connect'])
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Service Request Connect': serviceRequestConnect?.toJson(),
    };
  }
}

class ServiceRequestConnect {
  String? srNumber;

  ServiceRequestConnect({
    this.srNumber,
  });

  // JSON -> Object
  factory ServiceRequestConnect.fromJson(Map<String, dynamic> json) {
    return ServiceRequestConnect(
      srNumber: json['SR Number'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'SR Number': srNumber,
    };
  }
}
