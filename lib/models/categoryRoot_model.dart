import 'dart:convert';

class CategoryRootModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<Category>? results;
  String? message;

  CategoryRootModel({
    this.count,
    this.next,
    this.previous,
    this.results,
    this.message,
  });

  // JSON -> Object
  factory CategoryRootModel.fromJson(Map<String, dynamic> json) {
    return CategoryRootModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((i) => Category.fromJson(i)).toList()
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

class Category {
  int? id;
  String? name;
  List<Subcategory>? _subcategory;

  Category({
    this.id,
    this.name,
    List<Subcategory>? subcategory,
  }) {
    _subcategory = subcategory;
  }

  // Getter and Setter to mirror OnPropertyChanged logic
  List<Subcategory>? get subcategory => _subcategory;
  set subcategory(List<Subcategory>? value) {
    _subcategory = value;
    // notifyListeners(); // Call this if using ChangeNotifier/Provider
  }

  // JSON -> Object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      subcategory: json['subcategory'] != null
          ? (json['subcategory'] as List)
              .map((i) => Subcategory.fromJson(i))
              .toList()
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subcategory': _subcategory?.map((v) => v.toJson()).toList(),
    };
  }
}



class Subcategory {
  int? id;
  String? name;

  Subcategory({
    this.id,
    this.name,
  });

  // JSON -> Object
  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}