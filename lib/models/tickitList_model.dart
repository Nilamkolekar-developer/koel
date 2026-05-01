class TicketListModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<TicketResult>? results;

  TicketListModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  // JSON -> Object
  factory TicketListModel.fromJson(Map<String, dynamic> json) {
    return TicketListModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => TicketResult.fromJson(i))
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

class TicketResult {
  String? id;
  String? ticketNo;
  DateTime? created;
  String? status;
  List<CommentHistory>? commentHistory;
  InventabUser? user;
  MarketPlace? marketPlace;
  TicketIssue? ticketIssue;
  dynamic organization;

  TicketResult({
    this.id,
    this.ticketNo,
    this.created,
    this.status,
    this.commentHistory,
    this.user,
    this.marketPlace,
    this.ticketIssue,
    this.organization,
  });

  // JSON -> Object
  factory TicketResult.fromJson(Map<String, dynamic> json) {
    return TicketResult(
      id: json['id'],
      ticketNo: json['ticket_no'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      status: json['status'],
      commentHistory: json['comment_history'] != null
          ? (json['comment_history'] as List)
              .map((i) => CommentHistory.fromJson(i))
              .toList()
          : null,
      user: json['user'] != null ? InventabUser.fromJson(json['user']) : null,
      marketPlace: json['market_place'] != null
          ? MarketPlace.fromJson(json['market_place'])
          : null,
      ticketIssue: json['ticket_issue'] != null
          ? TicketIssue.fromJson(json['ticket_issue'])
          : null,
      organization: json['organization'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_no': ticketNo,
      'created': created?.toIso8601String(),
      'status': status,
      'comment_history': commentHistory?.map((v) => v.toJson()).toList(),
      'user': user?.toJson(),
      'market_place': marketPlace?.toJson(),
      'ticket_issue': ticketIssue?.toJson(),
      'organization': organization,
    };
  }
}

class CommentHistory {
  String? id;
  TicketUser? user;
  DateTime? created;
  DateTime? modified;
  String? comment;
  String? levelStatus;
  String? ticketId;

  CommentHistory({
    this.id,
    this.user,
    this.created,
    this.modified,
    this.comment,
    this.levelStatus,
    this.ticketId,
  });

  // JSON -> Object
  factory CommentHistory.fromJson(Map<String, dynamic> json) {
    return CommentHistory(
      id: json['id'],
      user: json['user'] != null ? TicketUser.fromJson(json['user']) : null,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      comment: json['comment'],
      levelStatus: json['level_status'],
      ticketId: json['ticket_id'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'comment': comment,
      'level_status': levelStatus,
      'ticket_id': ticketId,
    };
  }
}

class TicketUser {
  String? id;
  String? email;
  String? mobile;
  String? firstName;
  String? lastName;

  TicketUser({
    this.id,
    this.email,
    this.mobile,
    this.firstName,
    this.lastName,
  });

  // JSON -> Object
  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      id: json['id'],
      email: json['email'],
      mobile: json['mobile'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'mobile': mobile,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  // Optional: Helper to get full name
  String get fullName => '${firstName ?? ""} ${lastName ?? ""}'.trim();
}

class TicketIssue {
  String? id;
  DateTime? created;
  DateTime? modified;
  String? issueRelated;

  TicketIssue({
    this.id,
    this.created,
    this.modified,
    this.issueRelated,
  });

  // JSON -> Object
  factory TicketIssue.fromJson(Map<String, dynamic> json) {
    return TicketIssue(
      id: json['id'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
      issueRelated: json['issue_related'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'issue_related': issueRelated,
    };
  }
}

class MarketPlace {
  String? id;
  String? marketplaceName;

  MarketPlace({
    this.id,
    this.marketplaceName,
  });

  // JSON -> Object
  factory MarketPlace.fromJson(Map<String, dynamic> json) {
    return MarketPlace(
      id: json['id'],
      marketplaceName: json['marketplace_name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marketplace_name': marketplaceName,
    };
  }
}

class InventabUser {
  String? id;
  String? email;
  String? mobile;
  String? firstName;
  String? lastName;

  InventabUser({
    this.id,
    this.email,
    this.mobile,
    this.firstName,
    this.lastName,
  });

  // JSON -> Object
  factory InventabUser.fromJson(Map<String, dynamic> json) {
    return InventabUser(
      id: json['id'],
      email: json['email'],
      mobile: json['mobile'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'mobile': mobile,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  // Helper to get the full name
  String get fullName => '${firstName ?? ""} ${lastName ?? ""}'.trim();
}
