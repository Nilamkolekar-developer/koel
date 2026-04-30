class GetAPIResponseModel {
  bool? success;
  String? data;

  GetAPIResponseModel({
    this.success,
    this.data,
  });

  // JSON -> Object
  factory GetAPIResponseModel.fromJson(Map<String, dynamic> json) {
    return GetAPIResponseModel(
      success: json['Success'],
      data: json['Data'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Success': success,
      'Data': data,
    };
  }
}
