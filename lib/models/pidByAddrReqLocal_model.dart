class PidByAddrSeqLocalModel {
  int? ecuId;
  String? pidByAddrFsq;

  PidByAddrSeqLocalModel({
    this.ecuId,
    this.pidByAddrFsq,
  });

  // JSON -> Object
  factory PidByAddrSeqLocalModel.fromJson(Map<String, dynamic> json) {
    return PidByAddrSeqLocalModel(
      ecuId: json['ecuId'],
      pidByAddrFsq: json['pid_by_addr_fsq'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ecuId': ecuId,
      'pid_by_addr_fsq': pidByAddrFsq,
    };
  }
}
