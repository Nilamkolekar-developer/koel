class OemModel {
  int? count;
  Object? next;
  Object? previous;
  String? message;
  List<AllOemModel>? results;

  OemModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // Convert JSON Map to OemModel object
  factory OemModel.fromJson(Map<String, dynamic> json) {
    return OemModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      // Map the list of results to AllOemModel objects
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => AllOemModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Convert OemModel object to JSON Map
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

class AllOemModel {
  int? id;
  String? name;
  int? admin;
  String? oemFile;
  dynamic color;
  dynamic appName;
  bool? isActive;

  AllOemModel({
    this.id,
    this.name,
    this.admin,
    this.oemFile,
    this.color,
    this.appName,
    this.isActive,
  }) {}

  factory AllOemModel.fromJson(Map<String, dynamic> json) => AllOemModel(
        id: json['id'],
        name: json['name'],
        admin: json['admin'],
        oemFile: json['oem_file'],
        color: json['color'],
        appName: json['app_name'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'admin': admin,
        'oem_file': oemFile,
        'color': color,
        'app_name': appName,
        'is_active': isActive,
      };
}
