class LatestAppVersionModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<LatestAppVersionResultModel>? results;

  LatestAppVersionModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory LatestAppVersionModel.fromJson(Map<String, dynamic> json) {
    return LatestAppVersionModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => LatestAppVersionResultModel.fromJson(i))
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

class LatestAppVersionResultModel {
  String? revisionNumber;
  String? appVersion;
  String?
      apkAttachment; // Fixed typo from 'attechment' to 'attachment' in property name
  String? descriptions;
  String? readCaseDate;
  String? featureList;
  String? bugFix;
  bool? isLatest;

  LatestAppVersionResultModel({
    this.revisionNumber,
    this.appVersion,
    this.apkAttachment,
    this.descriptions,
    this.readCaseDate,
    this.featureList,
    this.bugFix,
    this.isLatest,
  });

  // JSON -> Object
  factory LatestAppVersionResultModel.fromJson(Map<String, dynamic> json) {
    return LatestAppVersionResultModel(
      revisionNumber: json['revision_number'],
      appVersion: json['app_version'],
      apkAttachment: json['apk_attechment'], // Keep exact key from C#
      descriptions: json['descriptions'],
      readCaseDate: json['read_case_date'],
      featureList: json['feature_list'],
      bugFix: json['bug_fix'],
      isLatest: json['is_latest'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'revision_number': revisionNumber,
      'app_version': appVersion,
      'apk_attechment': apkAttachment,
      'descriptions': descriptions,
      'read_case_date': readCaseDate,
      'feature_list': featureList,
      'bug_fix': bugFix,
      'is_latest': isLatest,
    };
  }
}
