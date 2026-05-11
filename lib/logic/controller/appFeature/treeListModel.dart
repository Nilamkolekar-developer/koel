// tree_list_model.dart

import 'package:get/get.dart';

// ─────────────────────────────────────────────
// TreeListModel
// ─────────────────────────────────────────────
class TreeListModel {
  // ✅ Explicitly typed Rx fields — no nullable inference
  final RxInt    _id                         = 0.obs;
  final RxInt    _okPageNodeId               = 0.obs;
  final RxInt    _notOkPageNodeId            = 0.obs;
  final RxString _topic                      = ''.obs;
  final RxString _description                = ''.obs;
  final RxString _groupName                  = ''.obs;
  final RxDouble _viewHeight                 = 0.0.obs;
  final RxString _descriptionTextColor       = '#4d4d4d'.obs;
  final RxString _descriptionBackgroundColor = '#FFFFFF'.obs;
  final RxBool   _pageVisible                = false.obs;
  final RxBool   _isCommentBoxVisible        = false.obs;
  final RxString _comment                    = ''.obs;

  final RxList<GroupListModel>    groupList        = <GroupListModel>[].obs;
  final RxList<DecissionModel>    decissionList    = <DecissionModel>[].obs;
  final RxList<LastQueCheckModel> lastQuestionList = <LastQueCheckModel>[].obs;

  // ── Getters ───────────────────────────────────────────────
  int    get id                         => _id.value;
  int    get okPageNodeId               => _okPageNodeId.value;
  int    get notOkPageNodeId            => _notOkPageNodeId.value;
  String get topic                      => _topic.value;
  String get description                => _description.value;
  String get groupName                  => _groupName.value;
  double get viewHeight                 => _viewHeight.value;
  String get descriptionTextColor       => _descriptionTextColor.value;
  String get descriptionBackgroundColor => _descriptionBackgroundColor.value;
  bool   get pageVisible                => _pageVisible.value;
  bool   get isCommentBoxVisible        => _isCommentBoxVisible.value;
  String get comment                    => _comment.value;

  // ── Setters ───────────────────────────────────────────────
  set id(int v)                            => _id.value = v;
  set okPageNodeId(int v)                  => _okPageNodeId.value = v;
  set notOkPageNodeId(int v)               => _notOkPageNodeId.value = v;
  set topic(String v)                      => _topic.value = v;
  set description(String v)                => _description.value = v;
  set groupName(String v)                  => _groupName.value = v;
  set viewHeight(double v)                 => _viewHeight.value = v;
  set descriptionTextColor(String v)       => _descriptionTextColor.value = v;
  set descriptionBackgroundColor(String v) => _descriptionBackgroundColor.value = v;
  set pageVisible(bool v)                  => _pageVisible.value = v;
  set isCommentBoxVisible(bool v)          => _isCommentBoxVisible.value = v;
  set comment(String v)                    => _comment.value = v;

  // ── Constructor ───────────────────────────────────────────
  TreeListModel({
    int    id                         = 0,
    int    okPageNodeId               = -1,
    int    notOkPageNodeId            = -1,
    String topic                      = '',
    String description                = '',
    String groupName                  = '',
    double viewHeight                 = 0,
    String descriptionTextColor       = '#4d4d4d',
    String descriptionBackgroundColor = '#FFFFFF',
    bool   pageVisible                = false,
    bool   isCommentBoxVisible        = false,
    String comment                    = '',
    List<GroupListModel>?    groupList,
    List<DecissionModel>?    decissionList,
    List<LastQueCheckModel>? lastQuestionList,
  }) {
    _id.value                         = id;
    _okPageNodeId.value               = okPageNodeId;
    _notOkPageNodeId.value            = notOkPageNodeId;
    _topic.value                      = topic;
    _description.value                = description;
    _groupName.value                  = groupName;
    _viewHeight.value                 = viewHeight;
    _descriptionTextColor.value       = descriptionTextColor;
    _descriptionBackgroundColor.value = descriptionBackgroundColor;
    _pageVisible.value                = pageVisible;
    _isCommentBoxVisible.value        = isCommentBoxVisible;
    _comment.value                    = comment;

    if (groupList != null)        this.groupList.assignAll(groupList);
    if (decissionList != null)    this.decissionList.assignAll(decissionList);
    if (lastQuestionList != null) this.lastQuestionList.assignAll(lastQuestionList);
  }
}

// ─────────────────────────────────────────────
// GroupListModel
// ─────────────────────────────────────────────
class GroupListModel {
  final RxString _upperLimit             = ''.obs;
  final RxString _lowerLimit             = ''.obs;
  final RxBool   _upperLowerValueVisible = false.obs;
  final RxString _unit                   = ''.obs;
  final RxString _groupName              = ''.obs;
  final RxString _currentLimit           = ''.obs;
  final RxString _statusColor            = '#000000'.obs;
  final RxString _entryDescription       = ''.obs;

  // ── Getters ───────────────────────────────────────────────
  String get upperLimit             => _upperLimit.value;
  String get lowerLimit             => _lowerLimit.value;
  bool   get upperLowerValueVisible => _upperLowerValueVisible.value;
  String get unit                   => _unit.value;
  String get groupName              => _groupName.value;
  String get currentLimit           => _currentLimit.value;
  String get statusColor            => _statusColor.value;
  String get entryDescription       => _entryDescription.value;

  // ── Setters ───────────────────────────────────────────────
  set upperLimit(String v)           => _upperLimit.value = v;
  set lowerLimit(String v)           => _lowerLimit.value = v;
  set upperLowerValueVisible(bool v) => _upperLowerValueVisible.value = v;
  set unit(String v)                 => _unit.value = v;
  set groupName(String v)            => _groupName.value = v;
  set statusColor(String v)          => _statusColor.value = v;
  set entryDescription(String v)     => _entryDescription.value = v;

  // ✅ currentLimit setter — digits only validation
  set currentLimit(String v) {
    _currentLimit.value = _isDigitsOnly(v) ? v : '';
  }

  bool _isDigitsOnly(String str) {
    if (str.isEmpty) return true;
    return str.split('').every(
        (c) => c.compareTo('0') >= 0 && c.compareTo('9') <= 0);
  }

  // ── Constructor ───────────────────────────────────────────
  GroupListModel({
    String upperLimit             = '',
    String lowerLimit             = '',
    bool   upperLowerValueVisible = false,
    String unit                   = '',
    String groupName              = '',
    String currentLimit           = '',
    String statusColor            = '#000000',
    String entryDescription       = '',
  }) {
    _upperLimit.value             = upperLimit;
    _lowerLimit.value             = lowerLimit;
    _upperLowerValueVisible.value = upperLowerValueVisible;
    _unit.value                   = unit;
    _groupName.value              = groupName;
    _currentLimit.value           = currentLimit;
    _statusColor.value            = statusColor;
    _entryDescription.value       = entryDescription;
  }
}

// ─────────────────────────────────────────────
// LastQueCheckModel
// ─────────────────────────────────────────────
class LastQueCheckModel {
  final RxBool   _isCheck  = false.obs;
  final RxString _describe = ''.obs;
  final RxInt    _id       = 0.obs;

  // ── Getters ───────────────────────────────────────────────
  bool   get isCheck  => _isCheck.value;
  String get describe => _describe.value;
  int    get id       => _id.value;

  // ── Setters ───────────────────────────────────────────────
  set isCheck(bool v)    => _isCheck.value = v;
  set describe(String v) => _describe.value = v;
  set id(int v)          => _id.value = v;

  // ── Constructor ───────────────────────────────────────────
  LastQueCheckModel({
    bool   isCheck  = false,
    String describe = '',
    int    id       = 0,
  }) {
    _isCheck.value  = isCheck;
    _describe.value = describe;
    _id.value       = id;
  }
}

// ─────────────────────────────────────────────
// DecissionModel
// ─────────────────────────────────────────────
class DecissionModel {
  final RxBool   _isCheck      = false.obs;
  final RxString _textValue    = ''.obs;
  final RxString _newTextValue = ''.obs;
  final RxInt    _nextNode     = 0.obs;
  final RxString _type         = ''.obs;
  final RxInt    _id           = 0.obs;

  // ── Getters ───────────────────────────────────────────────
  bool   get isCheck      => _isCheck.value;
  String get textValue    => _textValue.value;
  String get newTextValue => _newTextValue.value;
  int    get nextNode     => _nextNode.value;
  String get type         => _type.value;
  int    get id           => _id.value;

  // ── Setters ───────────────────────────────────────────────
  set isCheck(bool v)        => _isCheck.value = v;
  set textValue(String v)    => _textValue.value = v;
  set newTextValue(String v) => _newTextValue.value = v;
  set nextNode(int v)        => _nextNode.value = v;
  set type(String v)         => _type.value = v;
  set id(int v)              => _id.value = v;

  // ── Constructor ───────────────────────────────────────────
  DecissionModel({
    bool   isCheck      = false,
    String textValue    = '',
    String newTextValue = '',
    int    nextNode     = 0,
    String type         = '',
    int    id           = 0,
  }) {
    _isCheck.value      = isCheck;
    _textValue.value    = textValue;
    _newTextValue.value = newTextValue;
    _nextNode.value     = nextNode;
    _type.value         = type;
    _id.value           = id;
  }
}