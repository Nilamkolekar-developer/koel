import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/liveParameter_model.dart';

/// =======================================================
/// StaticData  (equivalent of C# static class)
/// =======================================================
class StaticData {
  static List<EcuDataSet> ecuInfo = [];
  static List<PidGroupModel> pidGroups = [];
  static List<StaticRunTimeLicence> runTimeLicenceList = [];
  static bool dtcGuidedDiagnostics = false;
}
/// =======================================================
/// ECU DATA SET
/// =======================================================
class EcuDataSet {
  int? ecuId;
  String? ecuName;
  String? chasisId;
  int? dtcDatasetId;
  int? pidDatasetId;
  int? mappedPidDatasetId;
  int? ivnPidDatasetId;
  int? ivnDtcDatasetId;
  String? clearDtcIndex;
  String? readDtcIndex;
  String? writePidIndex;
  String? iorTestFnIndex;
  String? seedKeyIndex;
  String? txHeader;
  String? rxHeader;
  String? swPartNo;
  String? swVerPid;
  Protocol? protocol;

  List<VersionDataset>? versionDataset;
  List<PidCode>? pidList;

  EcuDataSet({
    this.ecuId,
    this.ecuName,
    this.chasisId,
    this.dtcDatasetId,
    this.pidDatasetId,
    this.mappedPidDatasetId,
    this.ivnPidDatasetId,
    this.ivnDtcDatasetId,
    this.clearDtcIndex,
    this.readDtcIndex,
    this.writePidIndex,
    this.iorTestFnIndex,
    this.seedKeyIndex,
    this.txHeader,
    this.rxHeader,
    this.swPartNo,
    this.swVerPid,
    this.protocol,
    this.versionDataset,
    this.pidList,
  });

  factory EcuDataSet.fromJson(Map<String, dynamic> json) {
    return EcuDataSet(
      ecuId: json['ecu_ID'],
      ecuName: json['ecu_name'],
      chasisId: json['chasis_id'],
      dtcDatasetId: json['dtc_dataset_id'],
      pidDatasetId: json['pid_dataset_id'],
      mappedPidDatasetId: json['mapped_pid_dataset_id'],
      ivnPidDatasetId: json['ivn_pid_dataset_id'],
      ivnDtcDatasetId: json['ivn_dtc_dataset_id'],
      clearDtcIndex: json['clear_dtc_index'],
      readDtcIndex: json['read_dtc_index'],
      writePidIndex: json['write_pid_index'],
      iorTestFnIndex: json['ior_test_fn_index'],
      seedKeyIndex: json['seed_key_index'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      swPartNo: json['sw_part_no'],
      swVerPid: json['sw_ver_pid'],
      protocol: json['protocol'] != null
          ? Protocol.fromJson(json['protocol'])
          : null,
      versionDataset: json['version_dataset'] != null
          ? (json['version_dataset'] as List)
              .map((e) => VersionDataset.fromJson(e))
              .toList()
          : [],
      pidList: json['pid_list'] != null
          ? (json['pid_list'] as List)
              .map((e) => PidCode.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ecu_ID": ecuId,
      "ecu_name": ecuName,
      "chasis_id": chasisId,
      "dtc_dataset_id": dtcDatasetId,
      "pid_dataset_id": pidDatasetId,
      "mapped_pid_dataset_id": mappedPidDatasetId,
      "ivn_pid_dataset_id": ivnPidDatasetId,
      "ivn_dtc_dataset_id": ivnDtcDatasetId,
      "clear_dtc_index": clearDtcIndex,
      "read_dtc_index": readDtcIndex,
      "write_pid_index": writePidIndex,
      "ior_test_fn_index": iorTestFnIndex,
      "seed_key_index": seedKeyIndex,
      "tx_header": txHeader,
      "rx_header": rxHeader,
      "sw_part_no": swPartNo,
      "sw_ver_pid": swVerPid,
      "protocol": protocol?.toJson(),
      "version_dataset": versionDataset?.map((e) => e.toJson()).toList(),
      "pid_list": pidList?.map((e) => e.toJson()).toList(),
    };
  }
}

/// =======================================================
/// SESSION STATIC DATA
/// =======================================================
class StaticRunTimeLicence {
  String? name;
  String? image; // Flutter uses asset path instead of ImageSource
  String? type;
  int? id;

  StaticRunTimeLicence({
    this.name,
    this.image,
    this.type,
    this.id,
  });

  factory StaticRunTimeLicence.fromJson(Map<String, dynamic> json) {
    return StaticRunTimeLicence(
      name: json['name'],
      image: json['image'],
      type: json['type'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "image": image,
      "type": type,
      "id": id,
    };
  }
}