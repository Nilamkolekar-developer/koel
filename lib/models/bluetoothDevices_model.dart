class BluetoothDevicesModel {
  String? name;
  String? ip;
  String? macAddress;

  BluetoothDevicesModel({
    this.name,
    this.ip,
    this.macAddress,
  });

  // JSON -> Object
  factory BluetoothDevicesModel.fromJson(Map<String, dynamic> json) {
    return BluetoothDevicesModel(
      name: json['Name'],
      ip: json['Ip'],
      macAddress: json['Mac_Address'],
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Ip': ip,
      'Mac_Address': macAddress,
    };
  }
}
