class TreeListModel {
  int? id;
  int? okPageNodeId;
  int? notOkPageNodeId;
  String? topic;
  String? description;
  String? groupName;
  double? viewHeight;
  String? descriptionTextColor;
  String? descriptionBackgroundColor;
  bool? pageVisible;

  List<GroupListModel>? groupList;
  List<DecissionModel>? decissionList;
  List<LastQueCheckModel>? lastQuestionList;

  bool? isCommentBoxVisible;
  String? comment;

  TreeListModel({
    this.id,
    this.okPageNodeId,
    this.notOkPageNodeId,
    this.topic,
    this.description,
    this.groupName,
    this.viewHeight,
    this.descriptionTextColor,
    this.descriptionBackgroundColor,
    this.pageVisible,
    this.groupList,
    this.decissionList,
    this.lastQuestionList,
    this.isCommentBoxVisible,
    this.comment,
  });

  factory TreeListModel.fromJson(Map<String, dynamic> json) {
    return TreeListModel(
      id: json['id'],
      okPageNodeId: json['ok_page_node_id'],
      notOkPageNodeId: json['not_ok_page_node_id'],
      topic: json['topic'],
      description: json['description'],
      groupName: json['group_name'],
      viewHeight: (json['view_height'] as num?)?.toDouble(),
      descriptionTextColor: json['description_text_color'],
      descriptionBackgroundColor: json['description_background_color'],
      pageVisible: json['page_visible'],
      groupList: json['group_list'] != null
          ? List<GroupListModel>.from(
              json['group_list'].map((x) => GroupListModel.fromJson(x)))
          : [],
      decissionList: json['decission_list'] != null
          ? List<DecissionModel>.from(
              json['decission_list'].map((x) => DecissionModel.fromJson(x)))
          : [],
      lastQuestionList: json['last_question_list'] != null
          ? List<LastQueCheckModel>.from(
              json['last_question_list'].map((x) => LastQueCheckModel.fromJson(x)))
          : [],
      isCommentBoxVisible: json['is_comment_box_visible'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ok_page_node_id': okPageNodeId,
      'not_ok_page_node_id': notOkPageNodeId,
      'topic': topic,
      'description': description,
      'group_name': groupName,
      'view_height': viewHeight,
      'description_text_color': descriptionTextColor,
      'description_background_color': descriptionBackgroundColor,
      'page_visible': pageVisible,
      'group_list': groupList?.map((x) => x.toJson()).toList(),
      'decission_list': decissionList?.map((x) => x.toJson()).toList(),
      'last_question_list': lastQuestionList?.map((x) => x.toJson()).toList(),
      'is_comment_box_visible': isCommentBoxVisible,
      'comment': comment,
    };
  }
}
class GroupListModel {
  String? upperLimit;
  String? lowerLimit;
  bool? upperLowerValueVisible;
  String? unit;
  String? groupName;
  String? currentLimit;
  String? statusColor;
  String? entryDescription;

  GroupListModel({
    this.upperLimit,
    this.lowerLimit,
    this.upperLowerValueVisible,
    this.unit,
    this.groupName,
    this.currentLimit,
    this.statusColor,
    this.entryDescription,
  });

  factory GroupListModel.fromJson(Map<String, dynamic> json) {
    return GroupListModel(
      upperLimit: json['upper_limit'],
      lowerLimit: json['lower_limit'],
      upperLowerValueVisible: json['upper_lower_value_visible'],
      unit: json['unit'],
      groupName: json['group_name'],
      currentLimit: _validateNumber(json['current_limit']),
      statusColor: json['status_color'],
      entryDescription: json['entry_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upper_limit': upperLimit,
      'lower_limit': lowerLimit,
      'upper_lower_value_visible': upperLowerValueVisible,
      'unit': unit,
      'group_name': groupName,
      'current_limit': currentLimit,
      'status_color': statusColor,
      'entry_description': entryDescription,
    };
  }

  static String? _validateNumber(String? value) {
    if (value == null) return null;
    return RegExp(r'^\d+$').hasMatch(value) ? value : "";
  }
}
class LastQueCheckModel {
  bool? isCheck;
  String? describe;
  int? id;

  LastQueCheckModel({
    this.isCheck,
    this.describe,
    this.id,
  });

  factory LastQueCheckModel.fromJson(Map<String, dynamic> json) {
    return LastQueCheckModel(
      isCheck: json['isCheck'],
      describe: json['describe'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCheck': isCheck,
      'describe': describe,
      'id': id,
    };
  }
}
class DecissionModel {
  bool? isCheck;
  String? textValue;
  String? newTextValue;
  int? nextNode;
  String? type;
  int? id;

  DecissionModel({
    this.isCheck,
    this.textValue,
    this.newTextValue,
    this.nextNode,
    this.type,
    this.id,
  });

  factory DecissionModel.fromJson(Map<String, dynamic> json) {
    return DecissionModel(
      isCheck: json['isCheck'],
      textValue: json['text_value'],
      newTextValue: json['new_text_value'],
      nextNode: json['next_node'],
      type: json['type'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCheck': isCheck,
      'text_value': textValue,
      'new_text_value': newTextValue,
      'next_node': nextNode,
      'type': type,
      'id': id,
    };
  }
}