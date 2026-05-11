class ConnectionCondition {
  bool? isLengthFFF;
  bool? isChannels;
  String? channelId;
  bool? isObdCharger;

  ConnectionCondition({
    this.isLengthFFF,
    this.isChannels,
    this.channelId,
    this.isObdCharger,
  });

  factory ConnectionCondition.fromJson(Map<String, dynamic> json) => ConnectionCondition(
        isLengthFFF: json['IsLengthFFF'],
        isChannels: json['IsChannels'],
        channelId: json['ChannelId'],
        isObdCharger: json['IsObdCharger'],
      );

  Map<String, dynamic> toJson() => {
        'IsLengthFFF': isLengthFFF,
        'IsChannels': isChannels,
        'ChannelId': channelId,
        'IsObdCharger': isObdCharger,
      };
}