import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ap_dongle_commcore/helper/crc16_ccitt_kermit.dart'
    show Crc16CcittKermit;
import 'package:ap_dongle_diagnostic_core/ap_diagnostic_core.dart';
import 'package:autopeepal/models/freezeFrame_model.dart'
    hide FreezeFrameCode, FreezeFrameModel;
import 'package:ap_dongle_commcore/ap_dongle_commcore.dart';
import 'package:ap_dongle_commcore/enums/connectivity.dart';
import 'package:ap_dongle_commcore/enums/platform.dart';
import 'package:ap_dongle_commcore/model/responseArrayStatusModel.dart';
import 'package:ap_dongle_diagnostic_core/enums/readDTCIndex.dart';
import 'package:ap_dongle_diagnostic_core/enums/seedKeyIndexType.dart'
    hide SeedKeyIndexType;
import 'package:ap_dongle_diagnostic_core/enums/writeParameterIndex.dart';
import 'package:ap_dongle_diagnostic_core/model/freezeFrameModel.dart'
    hide FreezeFrameResponseModel, FreezeFrame;
import 'package:ap_dongle_diagnostic_core/model/readMappedPidModel.dart';
import 'package:ap_dongle_diagnostic_core/model/readParameterPidModel.dart'
    hide FrameOfPidMessage;
import 'package:ap_dongle_diagnostic_core/model/writeParameterPidModel.dart';
import 'package:ap_dongle_diagnostic_core/structure/flashConfig.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/bluetoothDevices_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:ap_dongle_diagnostic_core/model/flashingMatrixModel.dart';
import 'package:autopeepal/models/liveParameter_model.dart'
    hide SelectedParameterMessage;
import 'package:autopeepal/models/mappedPidRoot_model.dart' hide PidCode;
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';
import 'package:autopeepal/utils/interfaces/iConnectionWifi.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecu_seedkeypcl_core/ecu_seedkeypcl_core.dart';
import 'package:intl/intl.dart';

// import your models here
// import 'models.dart';

class WifiConnector implements IConnectionWifi {
  Socket? clients;

  // These would be your translated diagnostic classes
  DongleCommWin? dongleCommWin;
  DongleCommWin? dongleComm;
  UDSDiagnostic? udsDiagnostic;
  ReadDtcResponseModel? readDTCResponse;
   ECUCalculateSeedkey? calculateSeedkey;

  connectDongle() {
    // Windows URI scheme for Wi-Fi settings
    const String url = 'ms-settings:network-wifi';

    if (Platform.isWindows) {
      // Use the 'start' command via the system shell to open the settings page
      Process.run('cmd', ['/c', 'start', url]);
    } else {
      print("Current platform is not Windows.");
    }
  }

  Future<List<BluetoothDevicesModel>?> enableHotspots() async {
    // ignore: unused_local_variable
    String str = "";

    // On Windows, enabling a hotspot usually requires 'netsh' commands
    // or calling Windows-specific APIs.
    // Returning null to match your provided C# printic.
    return null;
  }

  Future<List<BluetoothDevicesModel>?> getDeviceList() async {
    try {
      // 1. Initialize the list (Equivalent to new ObservableCollection)
      List<BluetoothDevicesModel> availableDongles = [];

      // 2. Wrap discovery printic (Equivalent to Task.Run)
      return await Future<List<BluetoothDevicesModel>?>.sync(() async {
        final MdnsDiscoveryService mdns =
            MdnsDiscoveryService(serviceType: "_http._tcp");
        final completer = Completer<List<BluetoothDevicesModel>?>();
        bool isFound = false;

        // Start a stopwatch/timer printic

        late StreamSubscription sub;
        sub = mdns.discoveredServices.listen((service) {
          final name = service.name?.toLowerCase() ?? "";

          // Same filtering printic as your C# and previous Dart code
          if (name.contains("obd2") ||
              name.startsWith("ap") ||
              name.startsWith("vocom") ||
              name.contains("apklwu001")) {
            // Including your specific C# check

            isFound = true;

            // Duplicate check (is_double printic)
            if (!availableDongles.any((d) => d.ip == service.ip)) {
              availableDongles.add(service);
            }
          }
        });

        await mdns.startDiscovery();

        // 3. 15-second timeout printic (Equivalent to while sw.Elapsed < 15)
        Future.delayed(const Duration(seconds: 15), () async {
          await sub.cancel();
          await mdns.stopDiscovery();
          await mdns.dispose();

          if (!completer.isCompleted) {
            if (isFound) {
              completer.complete(availableDongles);
            } else {
              completer.complete(null); // Matches your C# 'return null'
            }
          }
        });

        return completer.future;
      });
    } catch (ex) {
      print("Error in getDeviceList: $ex");
      return null;
    }
  }

  /// Dart equivalent to EnumerateAllServicesFromAllHosts
  Future<List<BluetoothDevicesModel>> enumerateAllServices() async {
    // In mDNS, browsing for '_services._dns-sd._udp' is the standard way
    // to find all available service types on the network (BrowseDomainsAsync).
    final List<BluetoothDevicesModel> allHosts = [];

    // We use the common service type as a starting point.
    // Note: Unlike C# Zeroconf, Dart Bonsoir usually requires a specific type.
    final MdnsDiscoveryService mdns =
        MdnsDiscoveryService(serviceType: "_http._tcp");

    final completer = Completer<List<BluetoothDevicesModel>>();

    late StreamSubscription sub;
    sub = mdns.discoveredServices.listen((device) {
      if (!allHosts.any((h) => h.ip == device.ip)) {
        allHosts.add(device);
        print("Found Host: ${device.name} at ${device.ip}");
      }
    });

    await mdns.startDiscovery();

    // Give it a few seconds to resolve everything on the network
    Future.delayed(const Duration(seconds: 5), () async {
      await sub.cancel();
      await mdns.stopDiscovery();
      completer.complete(allHosts);
    });

    return completer.future;
  }

  /// Checks if the TCP client is initialized and connected.
  Future<bool> checkConnection() async {
    if (clients == null) {
      return false;
    }

    // Optional: In Dart, you can sometimes check if the socket is
    // closed by looking at the done property or state,
    // but a simple null check matches your C# printic.
    return true;
  }

  Future<String?> getIpAddress() async {
    try {
      // --- TCP Handshake Section ---
      // 1. TCP connection to the VCI Dongle
      Socket client = await Socket.connect("192.168.4.1", 6888,
          timeout: Duration(seconds: 5));

      // Sequence commands from your C# code
      var handshakeBytes = _hexStringToByteArray(
          "05000b0000000000000000500c47568afe56214e238000ffc315e4");
      var ssidConfigBytes = _hexStringToByteArray(
          "0600110000000000000000201216014155544f2050454550414c203200732cd49b");
      var passConfigBytes = _hexStringToByteArray(
          "0700110000000000000000201217016175746f70656570616c31323300b7565ab2");

      // Write Handshake
      client.add(handshakeBytes);
      await client.flush();
      await readData(client); // Equivalent to await ReadData(stream)

      // Write SSID Configuration
      client.add(ssidConfigBytes);
      await client.flush();
      await readData(client);

      // Write Password Configuration
      client.add(passConfigBytes);
      await client.flush();
      await readData(client);

      await client.close();

      // --- Windows WiFi Connection Section ---
      // Equivalent to wifi.AddNetwork and wifi.Reconnect
      if (Platform.isWindows) {
        String ssid = "AUTO PEEPAL 2";

        // Command to connect to the specific SSID
        // Note: For Windows, the profile must typically exist or be added via XML
        var result =
            await Process.run('netsh', ['wlan', 'connect', 'name=$ssid']);

        if (result.exitCode == 0) {
          print("✅ Connected to $ssid");
        } else {
          print("❌ Failed to connect: ${result.stderr}");
        }
      }

      // Zeroconf printic usually follows here if needed
      return null; // Matching your C# return null
    } catch (ex) {
      print("🔥 Exception: $ex");
      return "";
    }
  }

  StreamIterator<Uint8List>? _socketIterator;
  Future<Uint8List> readData(Socket socket) async {
    // 1. Initialize the iterator once for this socket.
    // This keeps the subscription alive for multiple reads.
    _socketIterator ??= StreamIterator(socket);

    try {
      // 2. moveNext() waits for the next packet of data.
      // Equivalent to: await stream.ReadAsync(...)
      if (await _socketIterator!.moveNext()) {
        // 3. Return the data current in the iterator.
        // It is already sized to exactly what was received.
        return _socketIterator!.current;
      }
    } catch (e) {
      print("Read error: $e");
    }

    // Return empty list if closed or error, matching your C# RetArray
    return Uint8List(0);
  }

  // IMPORTANT: Call this when you close the connection
  void cleanup() {
    _socketIterator = null;
  }

  /// Helper: Hex String to Uint8List (byte array)
  Uint8List _hexStringToByteArray(String hex) {
    hex = hex.replaceAll(" ", "");
    if (hex.length % 2 != 0) hex = "0$hex";
    return Uint8List.fromList(List.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }

  Socket? tcpClient;

  /// Equivalent to Write_SSIDPassword
  Future<String?> writeSSIDPassword(
      String routerSSID, String routerPassword) async {
    try {
      // 1. Prepare Initial Handshake
      var bytes = _hexStringToByteArray(
          "05000b0000000000000000500c47568afe56214e238000ffc315e4");

      print("-------------Tcp Start-------------");
      // Equivalent to: TcpClient client = new TcpClient("192.168.4.1", 6888);
      tcpClient = await Socket.connect("192.168.4.1", 6888,
          timeout: const Duration(seconds: 10));
      print("-------------Tcp END-------------");

      // 2. Initial Handshake Write/Read
      tcpClient!.add(bytes);
      await tcpClient!.flush();

      print("-------------First ReadData Start-------------");
      var response = await readData(tcpClient!);
      print(
          "-------------First ReadData End: ${Uint8List.fromList(response)}-------------");

      // 3. Send SSID Command
      // C#: "20" + (Len + 5).ToString("X2") + "1601" + Hex(SSID) + "00"
      String ssidHex = toHex(routerSSID);
      String ssidCommand =
          "20${(routerSSID.length + 5).toRadixString(16).padLeft(2, '0')}1601${ssidHex}00";

      String wificmd = readChecksum(routerSSID, ssidCommand);
      print("SSID Send Start ------------- $wificmd -------------");

      tcpClient!.add(_hexStringToByteArray(wificmd));
      await tcpClient!.flush();
      var ssidResponse = await readData(tcpClient!);
      print(
          "SSID Send End Response ------------- ${Uint8List.fromList(ssidResponse)} -------------");

      // 4. Send Password Command
      String pwHex = toHex(routerPassword);
      String pwCommand =
          "20${(routerPassword.length + 5).toRadixString(16).padLeft(2, '0')}1701${pwHex}00";

      String wifipwcmd = readChecksum(routerPassword, pwCommand);
      print("Password Send Start ------------- $wifipwcmd -------------");

      tcpClient!.add(_hexStringToByteArray(wifipwcmd));
      await tcpClient!.flush();
      var pwResponse = await readData(tcpClient!);
      print(
          "Password Send End Response ------------- ${Uint8List.fromList(pwResponse)} -------------");

      // Close TCP before switching Wi-Fi
      await tcpClient!.close();

      // 5. Windows Wi-Fi Connection printic
      // Replicates the Android WifiManager/Reconnect printic using 'netsh'
      if (Platform.isWindows) {
        // Note: For Windows to connect, the SSID profile must already exist.
        // If it's a new network, you'd need to add an XML profile first.
        var result =
            await Process.run('netsh', ['wlan', 'connect', 'name=$routerSSID']);

        if (result.exitCode == 0) {
          print("✅ Connected to $routerSSID");
          // Here you would trigger your Windows Diaprint/UI update
        } else {
          print("❌ Connection failed: ${result.stderr}");
          // Show "Nope" alert equivalent
        }
      }

      return null;
    } catch (ex) {
      print("🔥 Error: $ex");
      return "";
    }
  }

  String readChecksum(String input, String command) {
    // 1. Get data bytes excluding first 4 chars, calculate first CRC
    // C#: command.Substring(4)
    final dataBytes = _hexStringToByteArray(command.substring(4));
    final checksum = Crc16CcittKermit.computeChecksum(dataBytes);

    // 2. Append Checksum in Hex format (X4 equivalent)
    String commandWithCrc =
        command + checksum.toRadixString(16).padLeft(4, '0').toUpperCase();

    // 3. Prepare the header bytes
    const String byte1 = "00";
    final String byte2 = (commandWithCrc.length ~/ 2)
        .toRadixString(16)
        .padLeft(4, '0')
        .toUpperCase();

    // Use intl package for date formatting: DateTime.Now.ToString("hhmmssff")
    final String byte3 = DateFormat('hhmmssSS').format(DateTime.now());
    const String byte4 = "00000000";

    // 4. Combine and calculate the final frame CRC
    final String combinedStr = byte1 + byte2 + byte3 + byte4 + commandWithCrc;
    final dataBytesFinal = _hexStringToByteArray(combinedStr);
    final finalChecksum = Crc16CcittKermit.computeChecksumBytes(dataBytesFinal);

    // 5. Build final return string
    // Combines [0x74, 0xE5] into the integer 0x74E5 (29925)
    int checksumValue = (finalChecksum[0] << 8) | finalChecksum[1];

    return combinedStr +
        checksumValue.toRadixString(16).padLeft(4, '0').toUpperCase();
  }

  String toHex(String input) {
    return input.codeUnits
        .map((char) => char.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  String txHeaderTemp = "";
  String rxHeaderTemp = "";
  int protocolValue = 0;

  /// Equivalent to public partial async Task<string> GetDongleMacID
  Future<String> getDongleMacID(
    String ip,
    bool isLengthFFF,
    bool isChannels,
    String channelId,
  ) async {
    try {
      String macId = "";

      // 1. IP Validation and cleanup
      if (ip.isEmpty) {
        await disconnect(); // Helper to close existing clients
        return "";
      }

      // Equivalent to clients.Close() if already open
      await disconnect();

      // 2. Port Parsing (e.g., "192.168.4.1:6888")
      int port = 6888;
      String host = ip;
      if (ip.contains(':')) {
        var parts = ip.split(':');
        host = parts[0];
        port = int.parse(parts[1]);
      }

      // 3. Recreate TCP Socket (Equivalent to clients = new TcpClient)
      // We use your existing connection logic
      clients = await Socket.connect(host, port,
          timeout: const Duration(seconds: 10));
      // Disable Nagle's algorithm for diagnostic stability
      clients!.setOption(SocketOption.tcpNoDelay, true);

      // 4. Fetch ECU Info from your StaticData equivalent
      // Note: Replace 'StaticData' with your Flutter state management/model
      final ecuInfo = StaticData.ecuInfo.first;
      protocolValue = int.parse(ecuInfo.protocol!.autopeepal ?? '', radix: 16);
      txHeaderTemp = ecuInfo.txHeader ?? '';
      rxHeaderTemp = ecuInfo.rxHeader ?? '';

      // 5. Initialize Dongle Communication
      if (isLengthFFF) {
        dongleCommWin = DongleCommWin.tcpWithChannel(
          clients, // this.tcpClient
          clients, // this.stream (In Dart, the socket IS the stream)
          protocolValue, // int protocolVersion
          channelId, // String channelId
          "", // String filePath
        );
      } else {
        dongleCommWin = DongleCommWin.tcp(
          clients, // this.tcpClient
          clients, // this.stream
          protocolValue, // int protocolVersion
          "", // String filePath
        );
      }
      // Set Platform to Windows
      // dongleCommWin!.initializePlatform(
      //   PlatformType.windows,
      //   ConnectivityType.wiFi,
      //   App.userEmail == "cansimulate@atpl.com",
      // );
      // Set Platform to Windows
      dongleCommWin!.initializePlatform(
        PlatformType.windows,
        ConnectivityType.wiFi,
        App.userEmail == "cansimulate@atpl.com",
      );
calculateSeedkey = ECUCalculateSeedkey();
// ✅ ADD THIS: Initialize the diagnostic service
      udsDiagnostic = UDSDiagnostic(dongleComm: dongleCommWin!,calculateSeedkey: calculateSeedkey,);
      print("✅ [getDongleMacID] udsDiagnostic initialized");

      // 6. Execute Security Access and Fetch MAC
      await dongleCommWin!.securityAccess();

      // Equivalent to (byte[])await dongleCommWin.GetWifiMacId()
      final dynamic macResult = await dongleCommWin!.getWifiMacId();
      if (macResult is Uint8List) {
        // Formatting bytes to MAC ID String (X2 equivalent)
        macId = [3, 4, 5, 6, 7, 8]
            .map((i) =>
                macResult[i].toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(':');
      }

      return macId;
    } catch (ex) {
      print("🔥 GetDongleMacID Error: $ex");
      await disconnect();
      return "";
    }
  }

  /// Helper to close socket safely
  Future<void> disconnect() async {
    await clients?.close();
    clients = null;
  }

  Future<dynamic> setDongleProperties({
    String? protocolName,
    String? txHeaderTemp,
    String? rxHeaderTemp,
  }) async {
    try {
      if (protocolName == null || protocolName.isEmpty) return false;

      // ✅ Validation: Check if the string is valid Hex
      // This prevents the "Invalid radix-16" crash
      final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
      if (!hexRegex.hasMatch(protocolName)) {
        print("Error: protocolName '$protocolName' is not a valid Hex string.");
        return false;
      }

      final int protocolValue = int.parse(protocolName, radix: 16);

      await dongleCommWin!.dongleSetProtocol(protocolValue);
      await dongleCommWin!.canSetTxHeader(txHeaderTemp ?? "");
      await dongleCommWin!.canSetRxHeaderMask(rxHeaderTemp ?? "");
      await dongleCommWin!.canStartPadding("00");

      return true;
    } catch (ex) {
      print("Error setting dongle properties: $ex");
      return false;
    }
  }

  Future<String?> setDongleProperties1() async {
    try {
      print("🔧 [setDongleProperties1] START");
      print("🔧 [setDongleProperties1] protocolValue = $protocolValue");
      print("🔧 [setDongleProperties1] txHeaderTemp = '$txHeaderTemp'");
      print("🔧 [setDongleProperties1] rxHeaderTemp = '$rxHeaderTemp'");

      // Step 1: Set Protocol
      print(
          "🔧 [setDongleProperties1] Calling dongleSetProtocol($protocolValue)...");
      final dynamic protocolResp =
          await dongleCommWin!.dongleSetProtocol(protocolValue);
      print(
          "🔧 [setDongleProperties1] dongleSetProtocol response: $protocolResp");

      // ✅ KEY FIX: Update the protocol field so currentProtocol getter works
      dongleCommWin!.protocol = protocolValue;
      print(
          "🔧 [setDongleProperties1] dongleCommWin.protocol set to: ${dongleCommWin!.protocol}");
      print(
          "🔧 [setDongleProperties1] currentProtocol resolves to: ${dongleCommWin!.currentProtocol}");

      // Step 2: Set TX Header
      if (txHeaderTemp.isEmpty) {
        print(
            "⚠️ [setDongleProperties1] txHeaderTemp is EMPTY — skipping canSetTxHeader");
      } else {
        print(
            "🔧 [setDongleProperties1] Calling canSetTxHeader('$txHeaderTemp')...");
        final dynamic txResp =
            await dongleCommWin!.canSetTxHeader(txHeaderTemp);
        print("🔧 [setDongleProperties1] canSetTxHeader response: $txResp");
      }

      // Step 3: Set RX Header Mask
      if (rxHeaderTemp.isEmpty) {
        print(
            "⚠️ [setDongleProperties1] rxHeaderTemp is EMPTY — skipping canSetRxHeaderMask");
      } else {
        print(
            "🔧 [setDongleProperties1] Calling canSetRxHeaderMask('$rxHeaderTemp')...");
        final dynamic rxResp =
            await dongleCommWin!.canSetRxHeaderMask(rxHeaderTemp);
        print("🔧 [setDongleProperties1] canSetRxHeaderMask response: $rxResp");
      }

      // Step 5: Get Firmware Version
      print("🔧 [setDongleProperties1] Calling dongleGetFirmwareVersion()...");
      final dynamic firmwareVersion =
          await dongleCommWin!.dongleGetFirmwareVersion();
      print(
          "🔧 [setDongleProperties1] firmwareVersion raw response: $firmwareVersion");

      if (firmwareVersion is Uint8List) {
        print(
            "🔧 [setDongleProperties1] firmwareVersion bytes: ${firmwareVersion.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
        print(
            "🔧 [setDongleProperties1] firmwareVersion length: ${firmwareVersion.length}");

        if (firmwareVersion.length < 6) {
          print(
              "❌ [setDongleProperties1] Response too short to parse version (need 6 bytes, got ${firmwareVersion.length})");
          return null;
        }

        if (firmwareVersion[1] != 0x03) {
          print(
              "❌ [setDongleProperties1] Unexpected response byte[1]: 0x${firmwareVersion[1].toRadixString(16)} (expected 0x03)");
          return null;
        }

        String ver = "${firmwareVersion[3].toString().padLeft(2, '0')}."
            "${firmwareVersion[4].toString().padLeft(2, '0')}."
            "${firmwareVersion[5].toString().padLeft(2, '0')}";

        print("✅ [setDongleProperties1] Firmware version parsed: $ver");
        return ver;
      }

      print(
          "❌ [setDongleProperties1] firmwareVersion is not Uint8List — type is: ${firmwareVersion.runtimeType}");
      return null;
    } catch (ex, stack) {
      print("🔥 [setDongleProperties1] EXCEPTION: $ex");
      print("🔥 [setDongleProperties1] STACK: $stack");
      return null;
    }
  }

  String convertedByteToString(Uint8List bytes) {
    try {
      // utf8.decode converts the byte array (Uint8List) into a String.
      // allowMalformed: true prevents crashes if the VCI sends invalid characters.
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      print("Error decoding bytes to string: $e");
      return "";
    }
  }

  /// Equivalent to public partial async Task<string> GetFirmware1()
  Future<String> getFirmware1() async {
    try {
      // 1. Fetch Firmware Version
      final dynamic firmwareVersion =
          await dongleCommWin!.dongleGetFirmwareVersion();

      // 2. Validate the result
      // In Dart, byte arrays are represented as Uint8List
      if (firmwareVersion == null || !(firmwareVersion is Uint8List)) {
        return "Failed to Get FW Version";
      }

      final Uint8List firmwareResult = firmwareVersion;

      // Check if the response matches the expected protocol byte (0x03)
      if (firmwareResult.length < 6 || firmwareResult[1] != 0x03) {
        return "Failed to Get FW Version";
      }

      // 3. Format the version string (Equivalent to ToString("D2"))
      // padLeft(2, '0') ensures "1.5.9" becomes "01.05.09"
      String ver = "${firmwareResult[3].toString().padLeft(2, '0')}."
          "${firmwareResult[4].toString().padLeft(2, '0')}."
          "${firmwareResult[5].toString().padLeft(2, '0')}";

      return ver;
    } catch (ex) {
      print("Error in getFirmware1: $ex");
      return "Exception";
    }
  }

  /// Equivalent to public partial async Task<bool> UpdateFirmware(string command)
  Future<bool> updateFirmware(String command) async {
    try {
      // 1. Convert command string to Hex and call the update method
      // Uses the 'toHex' helper we defined earlier
      final dynamic resp = await dongleCommWin!.updateFirmware(toHex(command));

      // 2. Type cast and validation
      if (resp == null || !(resp is Uint8List)) {
        return false;
      }

      final Uint8List respArray = resp;

      // 3. Logic check (Equivalent to: respArray[1] == 0x01 && respArray[3] == 0x00)
      // We add a length check to ensure index 3 exists
      if (respArray.length > 3 &&
          respArray[1] == 0x01 &&
          respArray[3] == 0x00) {
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print("🔥 Firmware Update Exception: $ex");
      return false;
    }
  }

  Future<ReadDtcResponseModel?> readDtc(String dtcIndex) async {
    try {
      // 1. String normalization
      if (dtcIndex == "UDS-2BYTE-DTC") {
        dtcIndex = "UDS_2BYTE12_DTC";
      }
      String formattedIndex = dtcIndex.replaceAll('-', '_');

      // 2. Enum Parsing
      ReadDTCIndex? index;
      try {
        index = ReadDTCIndex.values.firstWhere(
            (e) => e.name == formattedIndex); // Use .name in modern Dart
      } catch (_) {
        print("❌ Invalid DTC Index: $formattedIndex");
        return null;
      }

      // 3. Safety Check: Is the diagnostic service ready?
      if (udsDiagnostic == null) {
        print("🔥 Error: udsDiagnostic is NULL. Connection might be closed.");
        return null;
      }

      final readDTCResponse = await udsDiagnostic!.readDTC(index);

      // 4. Map to Response Model Safely
      if (readDTCResponse == null) {
        print("⚠️ No response received from ECU.");
        return null;
      }

      return ReadDtcResponseModel()
        ..dtcs = readDTCResponse.dtcs
        ..status = readDTCResponse.status
        ..noOfDtc = readDTCResponse.noOfDtc; // No '!' needed here anymore
    } catch (ex) {
      print("🔥 ReadDtc Exception: $ex");
      return null;
    }
  }

  // /// Equivalent to public partial async Task<string> ClearDtc
  Future<String?> clearDtc(
    String dtcIndex,
    String seedKeyIndex,
    String writePidIndex,
  ) async {
    try {
      // 1. String normalization
      if (dtcIndex == "UDS-4BYTES") {
        dtcIndex = "UDS_4BYTES";
      }

      // 2. Enum Parsing
      // Using .byName if your enums match the string exactly,
      // or the .firstWhere approach for robustness.
      final clearIndex = ClearDTCIndex.values.firstWhere(
        (e) => e.name == dtcIndex.replaceAll('-', '_'),
        orElse: () => ClearDTCIndex.none, // Default fallback
      );

      final sKeyIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKeyIndex,
      );

      final wPidIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.name == writePidIndex,
      );

      // 3. Call the diagnostic service
      // In Dart, we don't need Task.Run for async I/O; simple await is sufficient.
      final result = await udsDiagnostic!.clearDTC(
        clearIndex,
        sKeyIndex,
        wPidIndex,
      );

      // 4. Handle Response
      // If dSDiagnostic.clearDTC returns a model directly, use it.
      // If it returns dynamic, cast it to your ClearDtcResponseModel.
      if (result is ClearDtcResponseModel) {
        return result.ecuResponseStatus;
      } else if (result is Map<String, dynamic>) {
        // If it returns a JSON map, map it to your model
        final responseModel = ClearDtcResponseModel.fromJson(result);
        return responseModel.ecuResponseStatus;
      }

      return null;
    } catch (ex) {
      print("🔥 ClearDtc Exception: $ex");
      return null;
    }
  }

  @override
  Future<FreezeFrameResponseModel> getFreezeFrame(
    // ✅ removed ?
    String dtcCode,
    FreezeFrameResult frameServerResult,
    List<EnvironmentSnapshotCode> envSnapshotCodes,
  ) async {
    final FreezeFrameResponseModel response = FreezeFrameResponseModel();
    try {
      // 1. Setup local diagnostic objects
      final List<FreezeFrameCode> ffCodeList = [];
      final List<ReadParameterPID> envSnapshotList = [];
      final FreezeFrameModel internalModel = FreezeFrameModel(
        ffSet: frameServerResult.ffSet,
        id: frameServerResult.id,
        isActive: frameServerResult.isActive,
        freezeFrameCode: [],
      );

      // 2. Map codes with safety checks
      for (final item in frameServerResult.freezeFrameCode ?? []) {
        final List<FFMessage> messages = (item.freezframe_messages ?? [])
            .map((m) => FFMessage(code: m.code, message: m.message))
            .toList();
        ffCodeList.add(FreezeFrameCode(
          noofBits:
              (item.end_bit_position ?? 0) - (item.start_bit_position ?? 0) + 1,
          startBit: item.start_bit_position?.toInt() ?? 0,
          bitcoded: item.bitcoded,
          bytePosition: item.byte_position,
          code: item.code,
          desc: item.desc,
          endian: item.endian,
          priority: item.priority,
          endBitPosition: item.end_bit_position,
          freezeFrameMessages: messages,
          id: item.id,
          messageType: item.message_type,
          length: item.length,
          numType: item.num_type,
          offset: item.offset,
          resolution: item.resolution,
          startBitPosition: item.start_bit_position,
          unit: item.unit,
        ));
      }

      // Sort by priority
      ffCodeList.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
      internalModel.freezeFrameCode = ffCodeList;

      // 3. Map Snapshots
      for (final item in envSnapshotCodes) {
        if (item.pidCode == null) continue;
        final List<PidVariable> variables =
            (item.pidCode!.piCodeVariable ?? []).map((vari) {
          return PidVariable(
            datatype: vari.messageType,
            isBitcoded: vari.bitcoded,
            noofBits:
                (vari.endBitPosition ?? 0) - (vari.startBitPosition ?? 0) + 1,
            noOfBytes: vari.length,
            offset: vari.offset,
            resolution: vari.resolution,
            startBit: vari.startBitPosition?.toInt() ?? 0,
            startByte: vari.bytePosition,
            pidNumber: vari.id,
            pidName: vari.shortName,
            messages: (vari.messages)!
                .map((m) =>
                    SelectedParameterMessage(code: m.code, message: m.message))
                .toList(),
          );
        }).toList();

        final String rawCode = item.pidCode?.code ?? "";
        final String cleanCode =
            rawCode.startsWith("22") ? rawCode.substring(2) : rawCode;
        envSnapshotList.add(ReadParameterPID(
          pidId: item.id,
          variables: variables,
          totalLen: cleanCode.length ~/ 2,
          pid: cleanCode,
          priority: item.priority,
        ));
      }

      envSnapshotList
          .sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

      // 4. Call Service
      final result = await udsDiagnostic!.getFreezeFrame(
        dtcCode,
        internalModel,
        envSnapshotList,
      );

      // 5. Final Mapping
      response.status = result.status;
      if (result.status == "NOERROR") {
        response.dtcs = result.dtcs!
            .map((e) =>
                FreezeFrame(code: e.code, priority: e.priority, value: e.value))
            .cast<FreezeFrame>()
            .toList();
      }

      return response; // ✅ always returns, never null
    } catch (e) {
      response.status = "Exception: ${e.toString()}";
      return response; // ✅ always returns, never null
    }
  }

  /// Equivalent to public partial async Task<ObservableCollection<IvnReadDtcResponseModel>> IVN_ReadDtc
  Future<List<IvnReadDtcResponseModel>?> ivnReadDtc(
      List<String> frameIDC) async {
    try {
      // 1. Initialize local lists (Replacing ObservableCollection)
      List<IvnResponseArrayStatus> ivnReadDTCResponse = [];
      List<IvnReadDtcResponseModel> frameResponseList = [];

      // 2. Call the VCI communication method
      // No need for Task.Run in Dart for asynchronous I/O
      final response = await dongleCommWin!.setIvnFrame(frameIDC);

      if (response != null) {
        ivnReadDTCResponse = response;
      }

      // 3. Process and Map the results
      if (ivnReadDTCResponse.isNotEmpty) {
        for (var item in ivnReadDTCResponse) {
          IvnReadDtcResponseModel model = IvnReadDtcResponseModel();

          // Handle ActualDataBytes null safety
          model.actualDataBytes = item.actualDataBytes;

          // Convert byte array to String using our helper
          // Assuming item.ecuResponse is a Uint8List
          if (item.ecuResponse != null) {
            model.ecuResponse = convertedByteToString(item.ecuResponse!);
          }

          model.ecuResponseStatus = item.ecuResponseStatus;
          model.frame = item.frame;

          frameResponseList.add(model);
        }
      }

      return frameResponseList;
    } catch (ex) {
      print("🔥 IVN_ReadDtc Error: $ex");
      return null;
    }
  }

  @override
  Future<List<ReadPidResponseModel>?> ivnReadPid(
      List<IvnSelectedPid> ivnPidList) async {
    try {
      // 1. Prepare diagnostic list
      List<IVNSelectedPID> diagnosticList = [];

      for (var item in ivnPidList) {
        List<PidFrameId> frameIdList = [];

        // Map frame IDs
        for (var item1 in item.frameIds ?? []) {
          PidFrameId newFrame = PidFrameId(
            framId: item1.framID,
            pidDescription: item1.pidDescription,
            startByte: item1.startByte,
            byteValue: item1.byteValue,
            bitCoded: item1.bitCoded,
            startBit: item1.startBit,
            noOfBits: item1.noOfBits,
            resolution: item1.resolution,
            offset: item1.offset,
            unit: item1.unit,
            messageType: item1.messageType,
            endian: item1.endian,
            numType: item1.numType,
            frameOfPidMessage: [],
          );

          // Map nested messages
          if (item1.frameOfPidMessage != null) {
            for (var item2 in item1.frameOfPidMessage!) {
              newFrame.frameOfPidMessage?.add(
                FrameOfPidMessage(
                  code: item2.code,
                  message: item2.message,
                ),
              );
            }
          }

          frameIdList.add(newFrame);
        }

        diagnosticList.add(
          IVNSelectedPID(
            frameId: item.frameId,
            // frameIds: frameIdList,
          ),
        );
      }

      // 2. Call diagnostic API
      final result = await udsDiagnostic?.ivnReadParameters(
        ivnPidList.length,
        diagnosticList,
      );

      // 3. Handle response
      if (result == null) {
        return null;
      }

      if (result is List<ReadPidResponseModel>) {
        //return result;
      }

      return result
          .map((e) => ReadPidResponseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (ex, stack) {
      print("🔥 IVN_ReadPid Exception: $ex");
      print(stack);
      return null;
    }
  }

  // @override
  // Future<List<ReadPidPresponseModel>?> readPid({
  //   required List<PidCode> pidList,
  //   required String pidByAddrSeq,
  //   List<ReadParameterPid>? parameterPidList,
  // }) async {
  //   try {
  //     List<ReadParameterPID> standardList = [];
  //     List<ReadParameterPID> addrPidList = [];

  //     for (var item in pidList) {
  //       List<PidVariable> variables = [];

  //       for (var vari in item.piCodeVariable ?? []) {
  //         List<SelectedParameterMessage> messageValueList = [];
  //         if (vari.messages != null) {
  //           for (var messageItem in vari.messages!) {
  //             messageValueList.add(SelectedParameterMessage(
  //               code: messageItem.code,
  //               message: messageItem.message,
  //             ));
  //           }
  //         }

  //         PidVariable pidVariable = PidVariable(
  //           datatype: vari.messageType,
  //           isBitcoded: vari.bitcoded,
  //           noofBits:
  //               (vari.endBitPosition ?? 0) - (vari.startBitPosition ?? 0) + 1,
  //           noOfBytes: vari.length,
  //           offset: vari.offset,
  //           resolution: vari.resolution,
  //           startBit: vari.startBitPosition?.toInt() ?? 0,
  //           startByte: vari.bytePosition,
  //           pidNumber: vari.id,
  //           pidName: vari.shortName,
  //           messages: messageValueList,
  //           numType: vari.numType,
  //         );
  //         variables.add(pidVariable);
  //       }

  //       if (item.memoryAddress == true) {
  //         addrPidList.add(ReadParameterPID(
  //           pidId: item.id,
  //           variables: variables,
  //           totalLen: item.totalLen,
  //           pid: item.code,
  //         ));
  //       } else {
  //         String code = item.code ?? "";
  //         standardList.add(ReadParameterPID(
  //           pidId: item.id,
  //           variables: variables,
  //           totalLen: code.length ~/ 2,
  //           pid: code,
  //         ));
  //       }
  //     }

  //     List<ReadPidPresponseModel> responseList = [];

  //     if (standardList.isNotEmpty) {
  //       final standardResult = await udsDiagnostic!.readParameters(
  //         standardList.length,
  //         standardList,
  //       );
  //       responseList.addAll(
  //         standardResult
  //             .map((e) =>
  //                 ReadPidPresponseModel.fromJson(e.toJson()))
  //       );
      
  //           }

  //     if (addrPidList.isNotEmpty) {
  //       for (var item in addrPidList) {
  //         final addrResult = await udsDiagnostic!.readParametersFromAddr(
  //           item,
  //           pidByAddrSeq,
  //         );
  //         responseList.add(ReadPidPresponseModel.fromJson(
  //             addrResult .toJson()));
  //               }
  //     }

  //     return responseList;
  //   } catch (ex) {
  //     print("🔥 ReadPid Exception: $ex");
  //     return null;
  //   }
  // }
  @override
  Future<List<ReadPidResponseModel?>> readPid({
    List<PidCode>? pidList,
    String? pidByAddrSeq,
    List<ReadParameterPid>? parameterPidList,
  }) async {
    try {
      if (pidList == null) return [];

      List<ReadParameterPID> standardPidList = [];
      List<ReadParameterPID> addrPidList = [];

      for (var item in pidList) {
        List<PidVariable> variables = [];

        for (var vari in item.piCodeVariable ?? []) {
          var messageValueList = <SelectedParameterMessage>[];
          if (vari.messages != null) {
            for (var messageItem in vari.messages!) {
              messageValueList.add(SelectedParameterMessage(
                code: messageItem.code,
                message: messageItem.message,
              ));
            }
          }

          int startBit = (vari.startBitPosition ?? 0).toInt();
          int endBit = (vari.endBitPosition ?? 0).toInt();

          PidVariable pidVariable = PidVariable(
            datatype: vari.messageType,
            isBitcoded: vari.bitcoded,
            noofBits: endBit - startBit + 1,
            noOfBytes: vari.length,
            offset: vari.offset,
            resolution: vari.resolution,
            startBit: startBit,
            startByte: vari.bytePosition,
            pidNumber: vari.id,
            pidName: vari.shortName,
            messages: messageValueList,
            numType: vari.numType,
          );
          variables.add(pidVariable);
        }

        if (item.memoryAddress == true) {
          addrPidList.add(ReadParameterPID(
            pidId: item.id,
            variables: variables,
            totalLen: item.totalLen,
            pid: item.code,
          ));
        } else {
          standardPidList.add(ReadParameterPID(
            pidId: item.id,
            variables: variables,
            totalLen: (item.code?.length ?? 0) ~/ 2,
            pid: item.code,
          ));
        }
      }

      List<ReadPidResponseModel> resList = [];

      // ── Standard PIDs ─────────────────────────────────────────────────────
      if (standardPidList.isNotEmpty && udsDiagnostic != null) {
        // ✅ FIX: Exact C# pattern:
        //    result = await dSDiagnostic.ReadParameters(list.Count, list);
        //    var res = JsonConvert.SerializeObject(result);
        //    res_list = JsonConvert.DeserializeObject<ObservableCollection<ReadPidPresponseModel>>(res);
        var result = await udsDiagnostic!.readParameters(
          standardPidList.length,
          standardPidList,
        );

        print("🔍 readParameters runtimeType: ${result.runtimeType}");

        try {
          // Serialize library result to JSON string
          final jsonStr = jsonEncode(result);
          print("🔍 readParameters JSON: $jsonStr");

          // Deserialize JSON into your model list
          final jsonList = jsonDecode(jsonStr) as List;
          final mapped = jsonList
              .map((e) =>
                  ReadPidResponseModel.fromJson(e as Map<String, dynamic>))
              .toList();
          resList.addAll(mapped);

          print("🔍 mapped count: ${mapped.length}");
          for (var r in mapped) {
            print(
                "🔍   status: ${r.status}, variables: ${r.variables?.length}");
            r.variables?.forEach((v) {
              print(
                  "🔍     pidNumber: ${v.pidNumber}, responseValue: '${v.responseValue}'");
            });
          }
        } catch (e) {
          print("🔍 JSON mapping error: $e");
        }
      }

      // ── Memory Address PIDs ───────────────────────────────────────────────
      if (addrPidList.isNotEmpty && udsDiagnostic != null) {
        for (var item in addrPidList) {
          // ✅ FIX: Exact C# pattern:
          //    result = await dSDiagnostic.ReadParametersFromAddr(item, PidByAddrSeq);
          //    var res = JsonConvert.SerializeObject(result);
          //    var resp = JsonConvert.DeserializeObject<ReadPidPresponseModel>(res);
          var result = await udsDiagnostic!.readParametersFromAddr(
            item,
            pidByAddrSeq ?? '',
          );

          print("🔍 readParametersFromAddr runtimeType: ${result.runtimeType}");

          try {
            final jsonStr = jsonEncode(result);
            print("🔍 readParametersFromAddr JSON: $jsonStr");

            final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
            final mapped = ReadPidResponseModel.fromJson(jsonMap);
            resList.add(mapped);

            print(
                "🔍 addr mapped — status: ${mapped.status}, variables: ${mapped.variables?.length}");
          } catch (e) {
            print("🔍 addr JSON mapping error: $e");
          }
        }
      }

      print("🔍 final resList count: ${resList.length}");
      return resList;
    } catch (ex) {
      print("Windows ReadPid Error: $ex");
      return [];
    }
  }

  /// Equivalent to public partial async Task<List<MappedPIDResponseModel>> ReadMappedPid
  Future<List<MappedPidResponseModel>?> readMappedPid(
      List<MappedPiCodeVariable> mappedPiCodeVariable) async {
    try {
      // 1. Prepare the diagnostic request list
      // Mapping MappedPiCodeVariable to the internal ReadMappedPID model
      final List<ReadMappedPID> diagnosticList =
          mappedPiCodeVariable.map((item) {
        return ReadMappedPID(
          id: item.id,
          name: item.name,
          pidCode: item.pidCode,
          totalLen: item.totalLen,
          length: item.length,
          resolution: item.resolution,
          offset: item.offset,
          numType: item.numType,
          unit: item.unit,
        );
      }).toList();

      // 2. Call Hardware Diagnostic Service
      // Dart's async/await handles thread management for I/O automatically
      final result = await udsDiagnostic!.readMappedParameters(diagnosticList);

      // 3. Map the response to your UI model (MappedPIDResponseModel)
      if (result != null) {
        return result.map((item) {
          return MappedPidResponseModel(
            id: item.id,
            name: item.name,
            pidCode: item.pidCode,
            status: item.status,
            values: item.values,
            unit: item.unit,
          );
        }).toList();
      }

      return []; // Return empty list if result is null
    } catch (ex) {
      print("🔥 ReadMappedPid Exception: $ex");
      return null;
    }
  }

  @override
  Future<List<ReadPidResponseModel>?> setRoutineValue(
    List<PidCode> pidList,
    String pidByAddrSeq,
    Uint8List actualResponse,
  ) async {
    try {
      // 1. Initialize local lists
      List<ReadParameterPID> standardList = [];
      List<ReadParameterPID> addrPidList = [];

      // 2. Map the input list to internal diagnostic models
      for (var item in pidList) {
        List<PidVariable> variables = [];

        for (var vari in item.piCodeVariable ?? []) {
          // Map nested message lookups
          List<SelectedParameterMessage> messageValueList = [];
          if (vari.messages != null) {
            for (var messageItem in vari.messages!) {
              messageValueList.add(SelectedParameterMessage(
                code: messageItem.code,
                message: messageItem.message,
              ));
            }
          }

          // Create the PidVariable with bit-logic: (end - start) + 1
          PidVariable pidVariable = PidVariable(
            datatype: vari.messageType,
            isBitcoded: vari.bitcoded,
            noofBits:
                (vari.endBitPosition ?? 0) - (vari.startBitPosition ?? 0) + 1,
            noOfBytes: vari.length,
            offset: vari.offset,
            resolution: vari.resolution,
            startBit: vari.startBitPosition?.toInt() ?? 0,
            startByte: vari.bytePosition,
            pidNumber: vari.id,
            pidName: vari.shortName,
            messages: messageValueList,
          );
          variables.add(pidVariable);
        }

        // Sort into Standard vs. Memory Address
        String code = item.code ?? "";
        var diagnosticPid = ReadParameterPID(
          pidId: item.id,
          variables: variables,
          totalLen: code.length ~/ 2,
          pid: code,
        );

        if (item.memoryAddress != true) {
          standardList.add(diagnosticPid);
        } else {
          addrPidList.add(diagnosticPid);
        }
      }

      // 3. Hardware Communication
      final dynamic result = await udsDiagnostic!.setRoutineValue(
        standardList.length,
        standardList,
        actualResponse,
      );

      // 4. Handle and Map the Response
      if (result is List<ReadPidResponseModel>) {
        return result; // ✅ correct type
      } else if (result is List) {
        return result
            .map((e) => ReadPidResponseModel.fromJson(e)) // ✅ correct model
            .toList();
      }

      return [];
    } catch (ex) {
      print("🔥 SetRoutineValue Error: $ex");
      return null;
    }
  }

  /// Equivalent to public partial async Task<ObservableCollection<WriteParameter_Status>> WritePid
  Future<List<WriteParameterStatus>?> writePid(
    String writePidIndex,
    List<WriteParameterPid> pidList,
    String pidByAddrSeq,
  ) async {
    try {
      // 1. Enum Parsing (Using our standard helper approach)

      final WriteParameterIndex index = WriteParameterIndex.values
          .firstWhere((e) => e.toString().split('.').last == writePidIndex);

      List<WriteParameterPID> standardList = [];
      List<WriteParameterPID> addrPidList = [];

      // 2. Map the input list to internal diagnostic models
      for (var item in pidList) {
        // Parse nested Enums for each item
        final SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
            (e) => e.toString().split('.').last == item.seedKeyIndex);

        print("Parsed SeedKeyIndex Enum: $seedIndex");

        // Parse write parameter index
        final WriteParameterIndex writeIndex = WriteParameterIndex.values
            .firstWhere(
                (e) => e.toString().split('.').last == item.writePamIndex);

        // Map nested Variant List
        List<VariantDataList> variantDataLists =
            (item.variantList ?? []).map((v) {
          return VariantDataList(
            datatype: v.datatype,
            isBitcoded: v.isBitcoded,
            noofBits: v.noofBits,
            noOfBytes: v.noOfBytes,
            offset: v.offset,
            pidId: v.pidId,
            pidName: v.pidName,
            resolution: v.resolution,
            startBit: v.startBit,
            startByte: v.startByte,
            unit: v.unit,
          );
        }).toList();

        final apPid = WriteParameterPID(
          seedKeyIndex: seedIndex,
          writePamIndex: writeIndex,
          writeInputSize: item.writeParaDataSize,
          writeInput: item.writeInput,
          writePid: item.writePid,
          readParameterPidDataType: item.readParameterPidDataType,
          pid: item.pid,
          startByte: item.startByte,
          totalBytes: item.totalBytes,
          variantList: variantDataLists,
        );

        // logic: Separate memory address writing from standard writing
        if (item.memory_address == true) {
          addrPidList.add(apPid);
        } else {
          standardList.add(apPid);
        }
      }

      // 3. Hardware Communication
      List<WriteParameterStatus> responseList = [];

      // Path A: Standard Batch Write
      if (standardList.isNotEmpty) {
        final result = await udsDiagnostic!.writeParameters(
          pidList.length,
          index,
          standardList,
        );

        if (result is List) {
          responseList.addAll(
            result!
                .map((e) =>
                    WriteParameterStatus.fromJson(e.toJson()))
                .toList(),
          );
        }
      }

      // Path B: Write by Memory Address (Individual calls)
      if (addrPidList.isNotEmpty) {
        for (var item in addrPidList) {
          final result = await udsDiagnostic!.writeParametersFromAddr(
            item,
            pidByAddrSeq,
          );

          if (result != null) {
            responseList.add(
                WriteParameterStatus.fromJson(result.toJson()));
          }
        }
      }

      return responseList;
    } catch (ex) {
      print("🔥 WritePid Exception: $ex");
      return null;
    }
  }

  // /// Equivalent to public partial async Task<WriteParameter_Status> WriteAtuatorTest
  Future<WriteParameterStatus?> writeAtuatorTest(
    String writeParaIndex,
    String seedKeyIndex,
    List<Uint8List> command,
    bool isStartTest,
  ) async {
    try {
      // 1. Enum Parsing
      // Converting the index strings to the internal diagnostic enums
      // Parse seed key index
      final SeedKeyIndexType seedIndex = SeedKeyIndexType.values
          .firstWhere((e) => e.toString().split('.').last == seedKeyIndex);

      print("Parsed SeedKeyIndex Enum: $seedIndex");

      // Parse write parameter index
      // final WriteParameterIndex writeIndex = WriteParameterIndex.values
      //     .firstWhere(
      //         (e) => e.toString().split('.').last == writePamIndex);

      // 2. Hardware Communication
      // We await the hardware response directly.
      // Dart's event loop handles the async Socket I/O without Task.Run.
      // final result = await udsDiagnostic!.atuatorTestWriteParameters(
      //  // writeIndex as int,
      //   seedIndex as WriteParameterIndex,
      //   command.cast<WriteParameterPID>(),
      //   isStartTest,
      // );

      // 3. Map Response to UI Model
      // if (result != null) {
      //   return WriteParameterStatus(
      //     status: result.status,
      //     dataArray:
      //         result.dataArray, // Ensure your model uses Uint8List or List<int>
      //   );
      // }

      return null;
    } catch (ex) {
      print("🔥 WriteAtuatorTest Exception: $ex");
      return null;
    }
  }

  /// Equivalent to public partial async Task<string> StartECUFlashing
  Future<String> startECUFlashing(String flashJson, String interpreter,
      SeedkeyalgoFnIndex sklFN, List<EcuMapFile> ecuMapFile) async {
    try {
      // ── STEP 1: Deserialize JSON ──────────────────────────────────────────
      print("🚀 startECUFlashing START");
      print("📋 flashJson length: ${flashJson.length}");
      print(
          "📋 flashJson preview: ${flashJson.length > 200 ? flashJson.substring(0, 200) : flashJson}");
      print("📋 interpreter length: ${interpreter.length}");
      print(
          "📋 interpreter preview: ${interpreter.length > 200 ? interpreter.substring(0, 200) : interpreter}");
      print("📋 sklFN: ${sklFN.toString()}");
      print("📋 sklFN.value: '${sklFN.value}'");
      print("📋 ecuMapFile count: ${ecuMapFile.length}");

      final Map<String, dynamic> decodedData = jsonDecode(flashJson);
      print("✅ JSON decoded successfully");

      final jsonData = FlashingMatrixData.fromJson(decodedData);
      print("✅ FlashingMatrixData parsed");
      print("📋 noOfSectors: ${jsonData.noOfSectors}");
      print("📋 sectorData count: ${jsonData.sectorData?.length ?? 0}");

      // ── STEP 2: Seedkey Enum Mapping ──────────────────────────────────────
      print("🔑 Resolving SeedKeyIndexType for '${sklFN.value}'");
      print(
          "🔑 Available SeedKeyIndexType values: ${SeedKeyIndexType.values.map((e) => e.toString().split('.').last).toList()}");

// ✅ FIXED — no firstWhereOrNull dependency
      SeedKeyIndexType seedkeyindx = SeedKeyIndexType.values.firstWhere(
        (e) => e.toString().split('.').last == sklFN.value,
        orElse: () {
          print("⚠️ No exact match for '${sklFN.value}'");
          final normalized = sklFN.value?.replaceAll('-', '_') ?? '';
          final strippedInput = normalized.replaceAll('_', '').toLowerCase();
          print("   🔑 strippedInput: '$strippedInput'");

          SeedKeyIndexType? match;
          try {
            match = SeedKeyIndexType.values.firstWhere(
              (e) =>
                  e.toString().split('.').last.toLowerCase() == strippedInput,
            );
          } catch (_) {
            match = null;
          }

          if (match != null) {
            print("✅ Stripped match found: $match");
            return match;
          }

          print(
              "❌ No match — falling back to first: ${SeedKeyIndexType.values.first}");
          return SeedKeyIndexType.values.first;
        },
      );
      print("✅ seedkeyindx resolved: $seedkeyindx");
      print("✅ seedkeyindx resolved: $seedkeyindx");
      print("✅ seedkeyindx resolved: $seedkeyindx");

      // ── STEP 3: Flash Config ──────────────────────────────────────────────
      var flashConfig = FlashConfig();
      print("✅ FlashConfig created");

      String response = "";

      // ── STEP 4: Flash ─────────────────────────────────────────────────────
      print(
          "🔧 udsDiagnostic is ${udsDiagnostic == null ? 'NULL ❌' : 'ready ✅'}");

      if (udsDiagnostic != null) {
        print("▶️ Starting TesterPresent...");
        await startTesterPresent();
        print("✅ TesterPresent started");

        print("▶️ Calling flashInterpreter...");
        print("   noOfSectors: ${jsonData.noOfSectors ?? 0}");
        print("   sectorData count: ${jsonData.sectorData?.length ?? 0}");
        print("   interpreter length: ${interpreter.length}");

        response = (await udsDiagnostic!.flashInterpreter1(
              flashConfig,
              jsonData.noOfSectors ?? 0,
              jsonData.sectorData ?? [],
              interpreter,
            )) ??
            "";

        print("✅ flashInterpreter returned: '$response'");

        print("⏹ Stopping TesterPresent...");
        await stopTesterPresent();
        print("✅ TesterPresent stopped");
      } else {
        print("❌ udsDiagnostic is null — flashing skipped");
        response = "ERROR : udsDiagnostic is null";
      }

      print("🏁 startECUFlashing END — response: '$response'");
      return response;
    } catch (ex, stack) {
      print("❌ startECUFlashing EXCEPTION: $ex");
      print("❌ StackTrace: $stack");
      return "ERROR : ${ex.toString()}";
    }
  }

  /// Equivalent to public async Task TXheader(string tx_header)
  Future<void> txHeader(String header) async {
    try {
      // 1. Call the VCI bridge to set the Transmit Header
      final setHeader = await dongleCommWin!.canSetTxHeader(header);

      // 2. Cast result to Uint8List (Dart's byte[])
      if (setHeader is Uint8List) {
        // 3. Convert bytes back to a hex string for logging
        final headerResponse = byteArrayToString(setHeader);

        print("------DTC TX Header Set------ $header");
        print("--Header Response-- $headerResponse");
      }
    } catch (e) {
      print("Error setting TX Header: $e");
    }
  }

  /// Equivalent to public async Task RXheader(string rx_header)
  Future<void> rxHeader(String header) async {
    try {
      // 1. Call the VCI bridge to set the Receive Header/Mask
      final setHeader = await dongleCommWin!.canSetRxHeaderMask(header);

      if (setHeader is Uint8List) {
        final headerResponse = byteArrayToString(setHeader);

        print("------DTC RX Header Set------ $header");
        print("RX Header Response-- $headerResponse");
      }
    } catch (e) {
      print("Error setting RX Header: $e");
    }
  }

  String byteArrayToString(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  /// Equivalent to public partial async Task<string> SetData
  Future<String> setData(String commands) async {
    try {
      String responseCommand = "";

      // 1. Call the diagnostic service to send the command
      // dSDiagnostic should return a model containing ECUResponseStatus and ActualDataBytes
      final result = await udsDiagnostic!.setDataData(commands);

      // 2. Check for "NOERROR" status
      if (result.ecuResponseStatus?.contains("NOERROR") ?? false) {
        // 3. Convert ActualDataBytes (Uint8List) to Hex String if not null
        if (result.actualDataBytes != null) {
          responseCommand = byteArrayToString(result.actualDataBytes!);
        } else {
          responseCommand = "NO DATA";
        }
      } else {
        // 4. Return the error status directly if it's not "NOERROR"
        responseCommand = result.ecuResponseStatus ?? "UNKNOWN ERROR";
      }

      return responseCommand;
    } catch (ex) {
      print("🔥 SetData Exception: $ex");
      return "EXCEPTION: ${ex.toString()}";
    }
  }

  /// Equivalent to public partial async Task<string[]> GetSsidPassword()
  Future<List<String>> getSsidPassword() async {
    // Initialize response with 4 empty strings (equivalent to new string[4])
    List<String> response = ["", "", "", ""];

    try {
      // 1. Get Default SSID
      final defaultSsidRaw = await dongleCommWin!.canGetDefaultSsid();
      if (defaultSsidRaw is Uint8List && defaultSsidRaw.isNotEmpty) {
        response[0] = _decodeSsidOrPassword(defaultSsidRaw);
        print("DEFAULT SSID: ${response[0]}");
      }

      // 2. Get Default Password
      final defaultPassRaw = await dongleCommWin!.canGetDefaultPassword();
      if (defaultPassRaw is Uint8List && defaultPassRaw.isNotEmpty) {
        response[1] = _decodeSsidOrPassword(defaultPassRaw);
        print("DEFAULT PASSWORD: ${response[1]}");
      }

      // 3. Get User SSID
      final userSsidRaw = await dongleCommWin!.canGetUserSsid();
      if (userSsidRaw is Uint8List && userSsidRaw.isNotEmpty) {
        response[2] = _decodeSsidOrPassword(userSsidRaw);
        print("USER SSID: ${response[2]}");
      }

      // 4. Get User Password
      final userPassRaw = await dongleCommWin!.canGetUserPassword();
      if (userPassRaw is Uint8List && userPassRaw.isNotEmpty) {
        response[3] = _decodeSsidOrPassword(userPassRaw);
        print("USER PASSWORD: ${response[3]}");
      }

      return response;
    } catch (ex) {
      print("🔥 Error in getSsidPassword: $ex");
      return response;
    }
  }

  /// Helper method to handle the logic of skipping first 4 bytes and last 2 bytes
  String _decodeSsidOrPassword(Uint8List data) {
    try {
      // Convert full byte array to ASCII to check for "NULL" string
      String decoded = ascii.decode(data);

      if (decoded.contains("NULL")) {
        return "NULL";
      }

      // Replicating your loop logic:
      // C#: if (i > 3 && i < lenth) where lenth = Length - 2
      // This means we take the middle section of the byte array.
      if (data.length > 6) {
        // sublist(start_index, end_index)
        // Start at 4 (skips 0,1,2,3), End at length - 2
        Uint8List middleSection = data.sublist(4, data.length - 2);

        // If you want the actual characters (ASCII):
        return ascii.decode(middleSection);

        // If your C# code meant to concatenate the raw numeric byte values
        // (as 'Response[0] + defaultSSID[i]' suggests in some C# versions):
        // return middleSection.join("");
      }

      return "";
    } catch (e) {
      return "NULL";
    }
  }

  /// Equivalent to public partial async Task<string> unlockEcu
  Future<String> unlockEcu(ResultUnlock unlockData) async {
    try {
      // 1. Extract data from the model
      final String txId = unlockData.txId ?? "";
      final String txFrame = unlockData.txFrame ?? "";
      final String txFrequency = unlockData.txFrequency ?? "";
      final String txTotalTime = unlockData.txTotalTime ?? "";
      final String rxId = unlockData.rxId ?? "";

      // Accessing the nested protocol value
      final String protocolValue = unlockData.protocol?.autopeepal ?? "";

      // 2. Set Dongle Properties (Protocol, CAN IDs)
      // This typically configures the VCI for the specific vehicle communication
      await setDongleProperties(
          protocolName: protocolValue, txHeaderTemp: txId, rxHeaderTemp: rxId);

      // 3. Initiate the ECU Unlocking sequence
      // This usually involves a brute-force or timed security access seed-key exchange
      String response = "";

      response = (await udsDiagnostic!.startEcuUnlocking(
        txFrame,
        txFrequency,
        txTotalTime,
      ))!;

      return response;
    } catch (ex) {
      print("🔥 unlockEcu Error: $ex");
      return "ERROR: ${ex.toString()}";
    }
  }

  /// Equivalent to public partial async Task<string> SendFotaCommand
  Future<String> sendFotaCommand(String command) async {
    try {
      // 1. Call the VCI communication bridge to trigger the FOTA command
      // Dart's await handles the asynchronous socket/serial call
      await dongleCommWin!.dongleSetFota(command);

      // 2. Return an empty string as per original C# logic
      return "";
    } catch (ex) {
      // 3. Log the error for debugging on Windows
      print("🔥 FOTA Command Exception: $ex");
      return "";
    }
  }

  // /// Equivalent to public partial async Task<TestRoutineResponseModel> SetTestRoutineCommand
  Future<TestRoutineResponseModel?> setTestRoutineCommand(
    String seedKey,
    String writeParaIndex,
    String startCommand,
  ) async {
    try {
      // 1. Enum Parsing
      // Convert the string-based indices from the database/UI into Diagnostic Enums
      final SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKey,
      );

      final WriteParameterIndex writeIndex =
          WriteParameterIndex.values.firstWhere(
        (e) => e.name == writeParaIndex,
      );

      // 2. Hardware Communication
      // StartIdIOR typically stands for "Start Identification Input Output Result"
      final dynamic result = await udsDiagnostic!.startIdIOR(
        seedIndex,
        writeIndex,
        startCommand,
      );

      // 3. Handle and Map the Response
      if (result != null) {
        if (result is TestRoutineResponseModel) {
          return result;
        } else if (result is Map<String, dynamic>) {
          // If the bridge returns a raw Map, convert it to the model
          return TestRoutineResponseModel.fromJson(result);
        }
      }

      return null;
    } catch (ex) {
      print("🔥 SetTestRoutineCommand Exception: $ex");
      return null;
    }
  }

  // / Equivalent to public async Task<TestRoutineResponseModel> ContinueIorTest
  Future<TestRoutineResponseModel?> continueIorTest({
    String? seedKey,
    String? writeParaIndex,
    String? startCommand,
    String? requestCommand,
    String? stopCommand,
    bool? testCondition,
    int? bitPosition,
    List<String>? activeCommand,
    String? stoppedCommand,
    String? failCommand,
    bool? isStop,
    int? timeBase,
    bool? isTimebase,
  }) async {
    try {
      // 1. Enum Parsing
      final SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKey,
      );

      final WriteParameterIndex writeIndex =
          WriteParameterIndex.values.firstWhere(
        (e) => e.name == writeParaIndex,
      );

      // 2. Hardware Communication
      //IORTestParameters2 handles the complex state transitions of the IOR test
      final dynamic result = await udsDiagnostic!.iorTestParameters2(
          // seedKeyIndex: seedIndex,
          // writeParameterIndex: writeIndex,
          // startCommand,
          // requestCommand,
          // stopCommand,
          // testCondition,
          // bitPosition,
          // activeCommands: activeCommand,
          // stoppedCommand,
          // failCommand,
          // isStop,
          // timeBase,
          // isTimebase,
          );

      // 3. Response Mapping
      if (result != null) {
        if (result is TestRoutineResponseModel) {
          return result;
        } else if (result is Map<String, dynamic>) {
          return TestRoutineResponseModel.fromJson(result);
        }
      }

      return null;
    } catch (ex) {
      print("🔥 ContinueIorTest Exception: $ex");
      return null;
    }
  }

  /// Equivalent to public partial async Task<TestRoutineResponseModel> RequestIorTest
  Future<TestRoutineResponseModel?> requestIorTest(
      String requestCommand) async {
    try {
      // 1. Hardware Communication
      // RequestIdIOR typically requests the results or status of an active routine
      final dynamic result = await udsDiagnostic!.requestIdIOR(requestCommand);

      // 2. Handle and Map the Response
      if (result != null) {
        if (result is TestRoutineResponseModel) {
          return result;
        } else if (result is Map<String, dynamic>) {
          // Map raw JSON data to the model using your fromJson factory
          return TestRoutineResponseModel.fromJson(result);
        }
      }

      return null;
    } catch (ex) {
      print("🔥 RequestIorTest Exception: $ex");
      return null;
    }
  }

  /// Equivalent to public partial async Task<TestRoutineResponseModel> StopIorTest
  Future<TestRoutineResponseModel?> stopIorTest(String stopCommand) async {
    try {
      // 1. Hardware Communication
      // StopIdIOR typically sends the "Stop" sub-function for a routine (e.g., UDS Service 0x31 02)
      final dynamic result = await udsDiagnostic!.stopIdIOR(stopCommand);

      // 2. Handle and Map the Response
      if (result != null) {
        if (result is TestRoutineResponseModel) {
          return result;
        } else if (result is Map<String, dynamic>) {
          // Map raw JSON/Map data to the model
          return TestRoutineResponseModel.fromJson(result);
        }
      }

      return null;
    } catch (ex) {
      print("🔥 StopIorTest Exception: $ex");
      return null;
    }
  }

  /// Equivalent to public partial async Task StartTesterPresent()
  Future<void> startTesterPresent() async {
    try {
      // 1. Call the VCI bridge to start sending 0x3E frames in the background
      // This typically starts a timer on the VCI firmware or in the bridge
      await dongleCommWin!.canStartTP();
    } catch (e) {
      print("🔥 Error starting Tester Present: $e");
    }
  }

  /// Equivalent to public partial async Task StopTesterPresent()
  Future<void> stopTesterPresent() async {
    try {
      // 1. Call the VCI bridge to stop the background 0x3E frames
      await dongleCommWin!.canStopTP();
    } catch (ex) {
      // Catch block is empty to match original C# logic,
      // but logging is recommended for Windows troubleshooting.
      print("🔥 Error stopping Tester Present: $ex");
    }
  }

  /// Manages the ECU flashing progress state

  // Static variable to match the C# 'static float flashingPercent'
  static double flashingPercent = 0.0;

  /// Equivalent to public partial async Task<float> FlashingData()
  Future<double> flashingData() async {
    try {
      // 1. Query the runtime percentage from the diagnostic bridge
      // C# float maps to Dart double
      flashingPercent = await udsDiagnostic!.getRuntimeFlashPercent();

      return flashingPercent;
    } catch (ex) {
      print("🔥 Error fetching flash percentage: $ex");
      return 0.0;
    }
  }

  /// Equivalent to public partial async Task<float> ResetPercentage()
  Future<double> resetPercentage() async {
    try {
      // 1. Tell the hardware bridge to clear the progress counter
      await udsDiagnostic!.resetPercentage();

      // 2. Reset the local static variable
      flashingPercent = 0.0;

      return 0.0;
    } catch (ex) {
      print("🔥 Error resetting flash percentage: $ex");
      return 0.0;
    }
  }
}

class NetworkCallbackHandler {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Equivalents to public Action NetworkAvailable / NetworkUnavailable
  void Function()? onNetworkAvailable;
  void Function()? onNetworkUnavailable;

  void initialize() {
    // Listening to connectivity changes
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.wifi)) {
        _handleWifiAvailable();
      } else {
        _handleUnavailable();
      }
    });
  }

  Future<void> _handleWifiAvailable() async {
    // Logic check: On Windows, we don't need to 'bind' the process.
    // However, we verify the connection to the VCI gateway (192.168.4.1).
    if (Platform.isWindows) {
      bool isDongleReachable = await _pingDongle();
      if (!isDongleReachable) return;
    }

    if (onNetworkAvailable != null) {
      onNetworkAvailable!();
    }
  }

  void _handleUnavailable() {
    if (onNetworkUnavailable != null) {
      onNetworkUnavailable!();
    }
  }

  Future<bool> _pingDongle() async {
    try {
      // Ping the dongle once to ensure Windows has updated its routing table
      final result = await Process.run('ping', ['-n', '1', '192.168.4.1']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
