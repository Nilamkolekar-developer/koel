class UploadEngineHrsModel {
  int? session;
  String? hrs;
  String? date;

  UploadEngineHrsModel({
    this.session,
    this.hrs,
    this.date,
  });

  // JSON -> Object
  factory UploadEngineHrsModel.fromJson(Map<String, dynamic> json) {
    return UploadEngineHrsModel(
      session: json['session'],
      hrs: json['hrs'],
      date: json['date'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'hrs': hrs,
      'date': date,
    };
  }
}
