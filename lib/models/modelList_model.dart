class ModelListModel {
  Map<String, ModelName>? models;
  List<NaClass>? naNa;

  ModelListModel({
    this.models,
    this.naNa,
  });

  // Factory constructor to create an instance from a Map (JSON)
  factory ModelListModel.fromJson(Map<String, dynamic> json) {
    return ModelListModel(
      // Handle the Dictionary mapping
      models: json['models'] != null
          ? (json['models'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, ModelName.fromJson(value)),
            )
          : null,
      // Handle the List mapping
      naNa: json['NA_NA'] != null
          ? (json['NA_NA'] as List).map((i) => NaClass.fromJson(i)).toList()
          : null,
    );
  }

  // Method to convert the instance back to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'models': models?.map((key, value) => MapEntry(key, value.toJson())),
      'NA_NA': naNa?.map((i) => i.toJson()).toList(),
    };
  }
}

class ModelName {
  // Add properties here if ModelName has any, for example:
  // int? id;
  // String? name;

  ModelName();

  factory ModelName.fromJson(Map<String, dynamic> json) {
    return ModelName();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

class RootObject {
  List<ModelName>? key;

  RootObject({this.key});

  // Equivalent to your C# Constructor initialization
  RootObject.init() {
    key = [];
  }

  factory RootObject.fromJson(Map<String, dynamic> json) {
    return RootObject(
      key: json['Key'] != null
          ? (json['Key'] as List).map((i) => ModelName.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Key': key?.map((i) => i.toJson()).toList(),
    };
  }
}

class NaClass {
  int? modelId;

  NaClass({this.modelId});

  // Factory constructor to create an instance from a Map (JSON)
  factory NaClass.fromJson(Map<String, dynamic> json) {
    return NaClass(
      // Maps the JSON key 'model_id' to the Dart variable modelId
      modelId: json['model_id'] as int?,
    );
  }

  // Method to convert the instance back to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
    };
  }
}

class ModelNameClass {
  String? modelName;
  int? id;

  ModelNameClass({
    this.modelName,
    this.id,
  });

  // Factory constructor to create an instance from a Map (JSON)
  factory ModelNameClass.fromJson(Map<String, dynamic> json) {
    return ModelNameClass(
      // Maps the JSON key 'ModelName' (from your C# property) to the Dart variable
      modelName: json['ModelName'] as String?,
      id: json['id'] as int?,
    );
  }

  // Method to convert the instance back to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'ModelName': modelName,
      'id': id,
    };
  }
}
