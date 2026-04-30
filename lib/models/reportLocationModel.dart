class ReportLocationModel {
  int? session;
  String? location;
  String? date;

  ReportLocationModel({
    this.session,
    this.location,
    this.date,
  });

  // JSON -> Object
  factory ReportLocationModel.fromJson(Map<String, dynamic> json) {
    return ReportLocationModel(
      session: json['session'],
      location: json['location'],
      date: json['date'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'location': location,
      'date': date,
    };
  }
}
