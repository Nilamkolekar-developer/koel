class LatestDbVersionModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<LatestDbVersionResultModel>? results;

  LatestDbVersionModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory LatestDbVersionModel.fromJson(Map<String, dynamic> json) {
    return LatestDbVersionModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => LatestDbVersionResultModel.fromJson(i))
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

class LatestDbVersionResultModel {
  String? dbVersion;
  String? descriptions;
  String? date;
  bool? isLatest;

  LatestDbVersionResultModel({
    this.dbVersion,
    this.descriptions,
    this.date,
    this.isLatest,
  });

  // JSON -> Object
  factory LatestDbVersionResultModel.fromJson(Map<String, dynamic> json) {
    return LatestDbVersionResultModel(
      dbVersion: json['db_version'],
      descriptions: json['descriptions'],
      date: json['date'],
      isLatest: json['is_latest'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'db_version': dbVersion,
      'descriptions': descriptions,
      'date': date,
      'is_latest': isLatest,
    };
  }
}
