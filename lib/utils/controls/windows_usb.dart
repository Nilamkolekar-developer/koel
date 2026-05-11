import 'dart:convert';
import 'dart:typed_data';
import 'package:ap_dongle_commcore/ap_dongle_commcore.dart';
import 'package:ap_dongle_commcore/enums/connectivity.dart';
import 'package:ap_dongle_commcore/enums/platform.dart';
import 'package:ap_dongle_diagnostic_core/ap_diagnostic_core.dart';
import 'package:ap_dongle_diagnostic_core/enums/readDTCIndex.dart';
import 'package:ap_dongle_diagnostic_core/enums/writeParameterIndex.dart';
import 'package:ap_dongle_diagnostic_core/model/flashingMatrixModel.dart';
import 'package:ap_dongle_diagnostic_core/model/freezeFrameModel.dart';
import 'package:ap_dongle_diagnostic_core/model/readMappedPidModel.dart';
import 'package:ap_dongle_diagnostic_core/model/readParameterPidModel.dart';
import 'package:ap_dongle_diagnostic_core/model/writeParameterPidModel.dart';
import 'package:ap_dongle_diagnostic_core/structure/flashConfig.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/envSet_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart'
    hide
        FreezeFrameModel,
        FreezeFrameCode,
        FreezeFrameResponseModel,
        FreezeFrame;
import 'package:autopeepal/models/liveParameter_model.dart'
    hide SelectedParameterMessage, FrameOfPidMessage;
import 'package:autopeepal/models/mappedPidRoot_model.dart' hide PidCode;
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';
import 'package:autopeepal/utils/interfaces/hardwareManager.dart';
import 'package:autopeepal/utils/interfaces/iConnectionUsb.dart';
import 'package:ecu_seedkeypcl_core/ecu_seedkeypcl_core.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class UsbWindows implements IConnectionUSB {
  // ── state ────────────────────────────────────────────────────────────────
  //BluetoothSocket? socket;

// In Dart, class names usually follow PascalCase, and variables follow camelCase
  DongleCommWin? dongleCommWin;
  DongleCommWin? dongleComm;
  UDSDiagnostic? udsDiagnostic;
  ECUCalculateSeedkey? calculateSeedkey;

// Dart doesn't have a built-in 'SerialInputOutputManager',
// this would typically be a custom class or part of a serial package
  dynamic serialIoManager;

// USB Serial Port equivalent
// In many Flutter USB plugins, this is simply 'SerialPort'
  dynamic port;
  dynamic inputOutputManager;

// Standard types
  String txHeaderTemp = ""; // Use "" instead of string.Empty
  String rxHeaderTemp = "";
  int protocolValue = 0;

  Future<String> getDongleMacID(bool isLengthFFF, bool isChannel,
      String channelId, bool isObdCharger) async {
    try {
      String macId = "";

      // ── 1. GET/VALIDATE PORT ─────────────────────────────────────
      if (port == null || !port!.isOpen) {
        final availablePorts = SerialPort.availablePorts;
        print("🔌 Available COM ports: $availablePorts");

        if (availablePorts.isEmpty) {
          print("❌ No serial ports found.");
          return "";
        }

        for (final portName in availablePorts) {
          SerialPort? candidate;
          try {
            candidate = SerialPort(portName);
            print("🔍 Trying: $portName | ${candidate.description}");

            if (candidate.openReadWrite()) {
              // 1. Get current config from the port
              final config = candidate.config;

              config.baudRate = 460800;
              config.bits = 8;
              config.stopBits = 1;
              config.parity = SerialPortParity.none;
              config.setFlowControl(SerialPortFlowControl.none);

              // 2. SET DTR and RTS on the CONFIG object
              // This is where the CP210x wake-up signals actually live
              config.dtr = 1;
              config.rts = 1;

              // 3. Apply the modified configuration to the hardware
              candidate.config = config;

              // Wait for hardware boot/reset cycle
              print("⏳ Stabilizing hardware (1.5s)...");
              await Future.delayed(const Duration(milliseconds: 1500));

              // 4. Clear any boot-up noise or junk data
              // Note: SerialPortBuffer is an enum, ensure both is accessed correctly
              candidate.flush(SerialPortBuffer.both);

              port = candidate;
              print("✅ Port ready: $portName");
              break;
            } else {
              print("⚠️ Could not open $portName: ${SerialPort.lastError}");
              candidate.dispose();
            }
          } catch (e) {
            print("⚠️ Error on $portName: $e");
            candidate?.dispose();
          }
        }
      }

      if (port == null || !port!.isOpen) {
        print("❌ Communication failure: No valid port opened.");
        return "";
      }
      // ────────────────────────────────────────────────────────────

      // ── 2. PROTOCOL DATA & MAPPING ──────────────────────────────
      if (StaticData.ecuInfo.isEmpty) {
        print("❌ ECU Info is empty.");
        return "";
      }

      var ecuInfo = StaticData.ecuInfo.first;
      String protocolNameValue = ecuInfo.protocol?.name ?? '';
      String value = protocolNameValue.replaceAll("-", "_");

      txHeaderTemp = ecuInfo.txHeader ?? '';
      rxHeaderTemp = ecuInfo.rxHeader ?? '';

      // Protocol mapping logic
      int protocolValue = _mapProtocolToValue(value);
      // ────────────────────────────────────────────────────────────

      // ── 3. INITIALIZE DONGLECOMM ─────────────────────────────────
      // Re-initialize to ensure fresh state with the current port
      dongleCommWin = DongleCommWin.usb(
        null,
        null,
        port!,
        protocolValue,
        isLengthFFF ? channelId : null,
      );

      dongleCommWin!.isChannel = isChannel;
      dongleCommWin!.channelId = channelId;
      dongleCommWin!.initializePlatform(
        PlatformType.windows,
        ConnectivityType.usb,
        App.userEmail == "cansimulate@atpl.com",
      );
      calculateSeedkey = ECUCalculateSeedkey();
      udsDiagnostic = UDSDiagnostic(
        dongleComm: dongleCommWin!,
        calculateSeedkey: calculateSeedkey, // This must not be null!
      );

      print("✅ UDSDiagnostic initialized with Comm and Calculator");
      // ────────────────────────────────────────────────────────────

      // ── 4. EXECUTE SEQUENCE ──────────────────────────────────────
      print("🔐 Executing Security Access...");
      await dongleCommWin!.securityAccess();

      // Tiny gap between distinct functional commands
      await Future.delayed(const Duration(milliseconds: 200));

      print("📡 Fetching Mac ID...");
      var rawMacId = await dongleCommWin!.getWifiMacId();

      if (rawMacId != null && rawMacId is List<int> && rawMacId.length >= 9) {
        // Typically: [Header1][Header2][Header3][M1][M2][M3][M4][M5][M6]...
        // We skip the first 3 bytes (headers) and take the next 6
        macId = rawMacId
            .sublist(3, 9)
            .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join(':');
        print("✅ MAC ID: $macId");
      } else {
        print("⚠️ Invalid or Null MAC response: $rawMacId");
      }
      // ────────────────────────────────────────────────────────────

      return macId;
    } catch (ex) {
      print("❌ Error in getDongleMacID: $ex");
      _cleanupPort();
      return "";
    }
  }

  /// Helper to map string protocols to hex values
  int _mapProtocolToValue(String protocol) {
    final mapping = {
      "ISO15765_250KB_11BIT_CAN": 0x00,
      "ISO15765_250Kb_29BIT_CAN": 0x01,
      "ISO15765_500KB_11BIT_CAN": 0x02,
      "ISO15765_500KB_29BIT_CAN": 0x03,
      "ISO15765_1MB_11BIT_CAN": 0x04,
      "ISO15765_1MB_29BIT_CAN": 0x05,
      "I250KB_11BIT_CAN": 0x06,
      "I250Kb_29BIT_CAN": 0x07,
      "I500KB_11BIT_CAN": 0x08,
      "I500KB_29BIT_CAN": 0x09,
      "I1MB_11BIT_CAN": 0x0A,
      "I1MB_29BIT_CAN": 0x0B,
    };

    if (protocol.startsWith("OE_IVN")) {
      txHeaderTemp = "07E0";
      rxHeaderTemp = "07E8";
      if (protocol.contains("250KBPS_11BIT")) return 0x0C;
      if (protocol.contains("250KBPS_29BIT")) return 0x0D;
      if (protocol.contains("500KBPS_11BIT")) return 0x0E;
      if (protocol.contains("500KBPS_29BIT")) return 0x0F;
      if (protocol.contains("1MBPS_11BIT")) return 0x10;
      if (protocol.contains("1MBPS_29BIT")) return 0x11;
    }

    return mapping[protocol] ?? 0x00;
  }

  void _cleanupPort() {
    try {
      if (port != null) {
        port!.close();
        port!.dispose();
        port = null;
      }
    } catch (e) {
      print("Error during port cleanup: $e");
    }
  }

  Future<dynamic> setDongleProperties({
    String? protocolName,
    String? rxHeaderTemp,
    String? txHeaderTemp,
  }) async {
    try {
      print("=========== setDongleProperties START ===========");

      // Print incoming values
      print("Protocol Name : $protocolName");
      print("TX Header     : $txHeaderTemp");
      print("RX Header     : $rxHeaderTemp");

      // Null check
      if (protocolName == null ||
          txHeaderTemp == null ||
          rxHeaderTemp == null) {
        print("❌ One or more parameters are NULL");
        return;
      }

      // Convert protocol hex string to int
      int protocolValue = int.parse(protocolName, radix: 16);

      print("Parsed Protocol Value : $protocolValue");
      print("Dongle Instance Null? : ${dongleCommWin == null}");

      if (dongleCommWin != null) {
        print("➡️ Setting Protocol...");
        var protocolRes = await dongleCommWin!.dongleSetProtocol(protocolValue);
        print("✅ Protocol Set Result : $protocolRes");

        print("➡️ Setting TX Header...");
        var txRes = await dongleCommWin!.canSetTxHeader(txHeaderTemp);
        print("✅ TX Header Result : $txRes");

        print("➡️ Setting RX Header Mask...");
        var rxRes = await dongleCommWin!.canSetRxHeaderMask(rxHeaderTemp);
        print("✅ RX Header Result : $rxRes");

        print("➡️ Starting CAN Padding...");
        var paddingRes = await dongleCommWin!.canStartPadding("00");
        print("✅ Padding Result : $paddingRes");

        print("🎉 Dongle Properties Configured Successfully");
      } else {
        print("❌ dongleCommWin is NULL");
      }

      print("=========== setDongleProperties END ===========");
    } catch (ex, stack) {
      print("❌ Exception in setDongleProperties: $ex");
      print("STACKTRACE: $stack");
    }
  }

  Future<bool> writeSSID(String routerSSID) async {
    try {
      // 1. Convert the plain text SSID to a Hex string
      String hexSSID = stringToHex(routerSSID);

      // 2. Call the dongle communication method
      // Expecting a result that can be treated as a list of bytes
      var setHotspot = await dongleCommWin?.wifiWriteSSID(hexSSID);

      if (setHotspot != null && setHotspot is Uint8List) {
        // 3. Convert the response bytes to a Hex string for comparison
        String resp = byteArrayToHex(setHotspot);

        // 4. Check for the specific success magic string
        if (resp.contains("20010000E1F0")) {
          return true;
        }
      }

      return false;
    } catch (ex) {
      print("Error writing SSID: $ex");
      return false;
    }
  }

  Future<bool> writePassword(String routerPassword) async {
    try {
      // 1. Convert the plain text password string to a Hex string
      // This uses the stringToHex helper we defined previously
      String hexPassword = stringToHex(routerPassword);

      // 2. Call the hardware communication method
      var setHotspot = await dongleCommWin?.wifiWritePw(hexPassword);

      if (setHotspot != null && setHotspot is Uint8List) {
        // 3. Convert response bytes to Hex string for validation
        // This uses the byteArrayToHex helper defined in your UsbWindows class
        String resp = byteArrayToHex(setHotspot);

        // 4. Check for the specific success magic string (Same as SSID success)
        if (resp.contains("20010000E1F0")) {
          return true;
        }
      }

      return false;
    } catch (ex) {
      print("Windows Hardware Error (Write Password): $ex");
      return false;
    }
  }

  Future<String> setDongleProperties1() async {
    try {
      String firmwareVersionStr = "";

      // Ensure the communication object is initialized
      if (dongleCommWin != null) {
        // 1. Configure Hardware Protocols and Headers
        await dongleCommWin!.dongleSetProtocol(protocolValue);
        await dongleCommWin!.canSetTxHeader(txHeaderTemp);
        await dongleCommWin!.canSetRxHeaderMask(rxHeaderTemp);
        await dongleCommWin!.canStartPadding("00");

        // 2. Request Firmware Version
        var firmwareVersionRaw =
            await dongleCommWin!.dongleGetFirmwareVersion();

        if (firmwareVersionRaw is Uint8List) {
          // C# "D2" formats the integer as a 2-digit decimal string
          // Dart uses padLeft(2, '0') to achieve the same result
          String major = firmwareVersionRaw[3].toString().padLeft(2, '0');
          String minor = firmwareVersionRaw[4].toString().padLeft(2, '0');
          String patch = firmwareVersionRaw[5].toString().padLeft(2, '0');

          firmwareVersionStr = "$major.$minor.$patch";
        }
      }

      return firmwareVersionStr;
    } catch (ex) {
      print("Error in setDongleProperties: $ex");
      return "";
    }
  }

  @override
  Future<void> disconnectUSB() async {
    try {
      if (dongleCommWin != null) {
        // 1. Send the software reset command to the dongle firmware
        await dongleCommWin!.dongleReset();

        // 2. Perform the hardware-level disconnection
        // (Closing streams and releasing the COM port handle)
        await dongleCommWin!.usbDisconnect();
      }
    } catch (ex) {
      // Silent catch as per your C# implementation,
      // though logging is usually recommended for hardware debugging.
      print("Error during USB disconnection: $ex");
    }
  }

  Future<String> connectOld() async {
    try {
      String firmwareVersionStr = "";

      // Using HardwareManager singleton for Windows instead of MainActivity
      final hardware = HardwareManager.instance;
      var port = hardware.returnPort();
      var inputOutputManager = hardware.inputOutputManager;

      if (port != null && inputOutputManager != null) {
        // Ensure the communication object exists
        if (dongleCommWin != null) {
          // Initialize Platform as Windows
          await dongleCommWin!.initializePlatform(
            PlatformType.windows,
            ConnectivityType.usb,
            App.userEmail == "cansimulate@atpl.com",
          );

          udsDiagnostic = UDSDiagnostic(dongleComm: dongleCommWin!);

          // 1. Security Access
          var securityAccess = await dongleCommWin!.securityAccess();
          if (securityAccess is Uint8List) {
            String securityResponse = byteArrayToHex(securityAccess);
            // Logging response just like ByteArrayToString in C#
            print("Security Response: $securityResponse");
          }

          // 2. Set Protocol (2 = ISO15765_500KB_11BIT_CAN usually)
          var setProtocol = await dongleCommWin!.dongleSetProtocol(2);
          if (setProtocol is Uint8List) {
            print("Protocol Response: ${byteArrayToHex(setProtocol)}");
          }

          // 3. Set Tx Header
          var setHeader = await dongleCommWin!.canSetTxHeader("07e0");
          if (setHeader is Uint8List) {
            print("Header Response: ${byteArrayToHex(setHeader)}");
          }

          // 4. Set Rx Mask
          var setHeaderMask = await dongleCommWin!.canSetRxHeaderMask("07e8");
          if (setHeaderMask is Uint8List) {
            print("Header Mask Response: ${byteArrayToHex(setHeaderMask)}");
          }

          // 5. Get Firmware Version
          var firmwareVersion = await dongleCommWin!.dongleGetFirmwareVersion();
          if (firmwareVersion is Uint8List) {
            // Maintaining the D2 (2-digit decimal) formatting from previous logic
            firmwareVersionStr = firmwareVersion[3].toString().padLeft(2, '0') +
                "." +
                firmwareVersion[4].toString().padLeft(2, '0') +
                "." +
                firmwareVersion[5].toString().padLeft(2, '0');
          }
        }
      }

      return firmwareVersionStr;
    } catch (ex) {
      print("ConnectOld Exception: $ex");
      return "";
    }
  }

  Future<ReadDtcResponseModel?> readDtc(String dtcIndex) async {
    print("🔹 [readDtc] Start - Received index string: $dtcIndex");

    try {
      // 1️⃣ Map string index to enum
      ReadDTCIndex index = ReadDTCIndex.values.firstWhere(
        (e) => e.toString().split('.').last == dtcIndex,
        orElse: () {
          print("❌ No matching ReadDtcIndex enum found for: $dtcIndex");
          throw Exception("Invalid DTC index: $dtcIndex");
        },
      );
      print("✅ [readDtc] Mapped string '$dtcIndex' to enum: $index");

      // 2️⃣ Prepare response model
      ReadDtcResponseModel readDtcResponseModel = ReadDtcResponseModel();

      int attempt = 0;

      // 3️⃣ Retry loop for BUSY or invalid dongle responses
      do {
        attempt++;
        print("⏳ [readDtc] Attempt #$attempt to read DTC...");

        // Call UDS diagnostic layer
        final rawResponse = await udsDiagnostic!.readDTC(index);

        // Map raw response to our UI model
        readDtcResponseModel.dtcs = rawResponse.dtcs;
        readDtcResponseModel.status = rawResponse.status;
        readDtcResponseModel.noOfDtc = rawResponse.noOfDtc;

        print("📡 [readDtc] Status received: ${readDtcResponseModel.status}");
        print(
            "📡 [readDtc] Number of DTCs: ${readDtcResponseModel.dtcs?.length ?? 0}");

        if (readDtcResponseModel.status ==
                "GENERALERROR_INVALIDRESPFROMDONGLE" ||
            readDtcResponseModel.status?.contains("BUSY") == true) {
          print("⏳ [readDtc] ECU busy or invalid response, retrying...");
          await Future.delayed(const Duration(milliseconds: 100));
        } else {
          break;
        }
      } while (attempt < 10);

      if (readDtcResponseModel.dtcs != null) {
        print(
            "✅ [readDtc] Success - DTCs parsed: ${readDtcResponseModel.dtcs!.length}");
      } else {
        print("⚠️ [readDtc] Warning - dtcs array is null");
      }

      return readDtcResponseModel;
    } catch (e, st) {
      print("❌ [readDtc] EXCEPTION: $e");
      print("❌ StackTrace: $st");
      return null;
    }
  }

  @override
  Future<FreezeFrameResponseModel> getFreezeFrame(
    String dtcCode,
    FreezeFrameResult frameServerResult,
    List<EnvironmentSnapshotCode>
        envSnapshotCodes, // Removed '?' to match interface
  ) async {
    FreezeFrameResponseModel freezeFrameResponseModel =
        FreezeFrameResponseModel();

    try {
      // 1. Initialize internal diagnostic models
      var ffCodeList = <FreezeFrameCode>[];
      List<ReadParameterPID> envSnapshotList = [];

      // Note: Ensuring field names match your Dart Model (e.g., ffSet vs ff_set)
      FreezeFrameModel freezeFrameModel = FreezeFrameModel(
        ffSet: frameServerResult.ffSet,
        id: frameServerResult.id,
        isActive: frameServerResult.isActive,
        freezeFrameCode: [],
      );

      // 2. Map Freeze Frame Codes
      // We use ?? [] so the loop doesn't break if the server returns a null list
      for (var item in frameServerResult.freezeFrameCode ?? []) {
        var messageValueList = <FFMessage>[];
        if (item.freezframeMessages != null) {
          for (var messageItem in item.freezframeMessages!) {
            messageValueList.add(FFMessage(
              code: messageItem.code,
              message: messageItem.message,
            ));
          }
        }

        // Convert num to int for bit calculations
        int startBit = (item.startBitPosition ?? 0).toInt();
        int endBit = (item.endBitPosition ?? 0).toInt();

        ffCodeList.add(FreezeFrameCode(
          noofBits: endBit - startBit + 1,
          startBit: startBit,
          bitcoded: item.bitcoded,
          bytePosition: item.bytePosition,
          code: item.code,
          desc: item.desc,
          endian: item.endian,
          priority: item.priority,
          endBitPosition: item.endBitPosition,
          freezeFrameMessages: messageValueList,
          id: item.id,
          messageType: item.messageType,
          length: item.length,
          numType: item.numType,
          offset: item.offset,
          resolution: item.resolution,
          startBitPosition: item.startBitPosition,
          unit: item.unit,
        ));
      }

      if (ffCodeList.isNotEmpty) {
        // Sort in-place by priority
        ffCodeList.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
        freezeFrameModel.freezeFrameCode = ffCodeList;
      }

      // 3. Map Environment Snapshots (PIDs)
      if (envSnapshotCodes.isNotEmpty) {
        List<ReadParameterPID> tempList = [];
        for (var item in envSnapshotCodes) {
          List<PidVariable> variables = [];

          for (var vari in item.pidCode?.piCodeVariable ?? []) {
            int vStartBit = (vari.startBitPosition ?? 0).toInt();
            int vEndBit = (vari.endBitPosition ?? 0).toInt();

            PidVariable pidVariable = PidVariable(
              datatype: vari.messageType,
              isBitcoded: vari.bitcoded,
              noofBits: vEndBit - vStartBit + 1,
              noOfBytes: vari.length,
              offset: vari.offset,
              resolution: vari.resolution,
              startBit: vStartBit,
              startByte: vari.bytePosition,
              pidNumber: vari.id,
              pidName: vari.shortName,
            );

            var pidMessages = <SelectedParameterMessage>[];
            if (vari.messages != null) {
              for (var mItem in vari.messages!) {
                pidMessages.add(SelectedParameterMessage(
                  code: mItem.code,
                  message: mItem.message,
                ));
              }
            }
            pidVariable.messages = pidMessages;
            variables.add(pidVariable);
          }

          String rawPid = item.pidCode?.code ?? "";
          // C# item.pid_code.code[2..] equivalent
          String pidCode =
              rawPid.startsWith("22") ? rawPid.substring(2) : rawPid;
          int totalLen = pidCode.length ~/ 2; // Integer division

          tempList.add(ReadParameterPID(
            pidId: item.id,
            variables: variables,
            totalLen: totalLen,
            pid: pidCode,
            priority: item.priority,
          ));
        }
        tempList.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
        envSnapshotList = tempList;
      }

      // 4. Call Diagnostic Library
      if (udsDiagnostic != null) {
        var freezeFrameResponse = await udsDiagnostic!.getFreezeFrame(
          dtcCode,
          freezeFrameModel,
          envSnapshotList,
        );

        // 5. Final Mapping to UI Model
        if (freezeFrameResponse.status == "NOERROR") {
          freezeFrameResponseModel.dtcs = [];
          for (var item in (freezeFrameResponse.dtcs ?? [])) {
            freezeFrameResponseModel.dtcs!.add(FreezeFrame(
              code: item.code,
              priority: item.priority,
              value: item.value,
            ));
          }
        }
        freezeFrameResponseModel.status = freezeFrameResponse.status;
      }

      return freezeFrameResponseModel;
    } catch (ex) {
      // Return error message in status field to handle in UI
      return FreezeFrameResponseModel(status: ex.toString());
    }
  }

  @override
  Future<String> clearDtc(
    String dtcIndex,
    String seedKeyIndex,
    String writePidIndex,
  ) async {
    try {
      String status = "";

      // 1. Parse Strings to Enums
      // Dart equivalent of (Enum.Parse)
      ClearDTCIndex index = ClearDTCIndex.values.firstWhere(
        (e) => e.name == dtcIndex,
        orElse: () => ClearDTCIndex.none,
      );

      SeedKeyIndexType sKeyIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKeyIndex,
      );

      WriteParameterIndex wPidIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.name == writePidIndex,
      );

      // 2. Execute Diagnostic Command
      if (udsDiagnostic != null) {
        // udsDiagnostic.clearDTC should return the response model
        var result = await udsDiagnostic!.clearDTC(index, sKeyIndex, wPidIndex);

        if (result != null) {
          // In Dart, we don't need to Serialize/Deserialize like the C# snippet
          // We can access the property directly from the result object
          status = result.ecuResponseStatus ?? "";
        }
      }

      return status;
    } catch (ex) {
      print("Error in clearDtc: $ex");
      return "";
    }
  }

  // ============================================================
// FIX 1: readPid — use ReadParameterPID directly, no cast needed
// ============================================================

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
// ============================================================
// FIX 2: setRoutineValue — same snake_case → camelCase fixes
// ============================================================

  @override
  Future<List<ReadPidResponseModel>> setRoutineValue(
    List<PidCode> pidList,
    String pidByAddrSeq,
    Uint8List actualResponse,
  ) async {
    try {
      List<ReadParameterPID> list = [];
      List<ReadParameterPID> listOfAddrPid = [];

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

          // ✅ FIX: camelCase
          int startBit = (vari.startBitPosition ?? 0).toInt();
          int endBit = (vari.endBitPosition ?? 0).toInt();

          PidVariable pidVariable = PidVariable(
            datatype: vari.messageType, // ✅ message_type → messageType
            isBitcoded: vari.bitcoded,
            noofBits: endBit - startBit + 1,
            noOfBytes: vari.length,
            offset: vari.offset,
            resolution: vari.resolution,
            startBit: startBit,
            startByte: vari.bytePosition, // ✅ byte_position → bytePosition
            pidNumber: vari.id,
            pidName: vari.shortName, // ✅ short_name → shortName
            messages: messageValueList,
          );
          variables.add(pidVariable);
        }

        var diagnosticPid = ReadParameterPID(
          pidId: item.id,
          variables: variables,
          totalLen: (item.code?.length ?? 0) ~/ 2,
          pid: item.code,
        );

        if (item.memoryAddress != true) {
          list.add(diagnosticPid);
        } else {
          listOfAddrPid.add(diagnosticPid);
        }
      }

      if (udsDiagnostic != null) {
        var result = await udsDiagnostic!.setRoutineValue(
          list.length,
          list,
          actualResponse,
        );

        List<ReadPidResponseModel> finalResponseList = [];

        if (result is List<ReadPidResponseModel>) {
          finalResponseList = result.cast<ReadPidResponseModel>();
        } else
          finalResponseList =
              result.map((e) => e as ReadPidResponseModel).toList();

        return finalResponseList;
      } else {
        return [];
      }
    } catch (ex) {
      print("Error in setRoutineValue: $ex");
      return [];
    }
  }

  @override
  Future<List<MappedPidResponseModel>> readMappedPid(
      List<MappedPiCodeVariable> mappedPiCodeVariable) async {
    try {
      // 1. Map the incoming UI models to the Diagnostic Library models
      List<ReadMappedPID> list = [];

      for (var item in mappedPiCodeVariable) {
        ReadMappedPID pid = ReadMappedPID(
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
        list.add(pid);
      }

      // 2. Call the diagnostic service
      // In Dart, Task.Run is unnecessary for I/O bound operations like this
      if (udsDiagnostic != null) {
        var result = await udsDiagnostic!.readMappedParameters(list);

        // 3. Map the diagnostic results back to your Response Model
        List<MappedPidResponseModel> resList = [];

        for (var item in result ?? []) {
          resList.add(MappedPidResponseModel(
            id: item.id,
            name: item.name,
            pidCode: item.pid_code,
            status: item.status,
            values: item.values,
            unit: item.unit,
          ));
        }

        return resList;
      } else {
        print("Error: Diagnostic service not initialized.");
        return [];
      }
    } catch (ex) {
      print("Exception in ReadMappedPid: $ex");
      // Returning an empty list instead of null to stay non-nullable
      // and prevent 'null is not a subtype of List' errors.
      return [];
    }
  }

  @override
  Future<List<WriteParameterStatus>> writePid(
    String writePidIndexStr,
    List<WriteParameterPid> pidList,
    String pidByAddrSeq,
  ) async {
    try {
      // ── Parse top-level index ─────────────────────────────────────────────

      // Parse write parameter index
      final WriteParameterIndex mainIndex = WriteParameterIndex.values
          .firstWhere((e) => e.toString().split('.').last == writePidIndexStr);

      print("🔑 writePidIndexStr: '$writePidIndexStr' → mainIndex: $mainIndex");

      // ✅ Print ALL available enum values so we can match exactly
      print(
          "🔑 Available SeedKeyIndexType values: ${SeedKeyIndexType.values.map((e) => e.toString().split('.').last).toList()}");
      print(
          "🔑 Available WriteParameterIndex values: ${WriteParameterIndex.values.map((e) => e.toString().split('.').last).toList()}");

      List<WriteParameterPID> standardList = [];
      List<WriteParameterPID> addrList = [];

      for (var item in pidList) {
        // ✅ Print incoming values before matching
        print("🔑 incoming seedKeyIndex: '${item.seedKeyIndex}'");
        print("🔑 incoming writePamIndex: '${item.writePamIndex}'");

        // ✅ Parse seed key index safely
        final seedIndex = SeedKeyIndexType.fromApi(item.seedKeyIndex);

        if (seedIndex == null) {
          throw Exception(
            "Unknown SeedKeyIndexType: ${item.seedKeyIndex}",
          );
        }

        print("✅ Parsed SeedKeyIndex Enum: $seedIndex");

// ✅ Parse write parameter index safely
        final writeIndex = WriteParameterIndex.values.firstWhere(
          (e) => e.toString().split('.').last == item.writePamIndex,
          orElse: () {
            throw Exception(
              "Unknown WriteParameterIndex: ${item.writePamIndex}",
            );
          },
        );

        print("✅ Parsed WriteParameterIndex Enum: $writeIndex");

        // Map variants
        List<VariantDataList> variantDataLists = [];
        for (var v in item.variantList!) {
          print("  ---- Variant ----");
          print("  pidId: ${v.pidId}");
          print("  pidName: ${v.pidName}");
          print("  datatype: ${v.datatype}");
          print("  isBitcoded: ${v.isBitcoded}");
          print("  noOfBits: ${v.noofBits}");
          print("  noOfBytes: ${v.noOfBytes}");
          print("  startByte: ${v.startByte}");
          print("  startBit: ${v.startBit}");
          print("  offset: ${v.offset}");
          print("  resolution: ${v.resolution}");
          print("  unit: ${v.unit}");

          variantDataLists.add(VariantDataList(
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
          ));
        }

        // ✅ Library uses String? for seedKeyIndex and writePamIndex
        //    Pass .name which gives the enum member name as a string
        //    e.g. SeedKeyIndexType.UDS_LEVEL_1 → "UDS_LEVEL_1"
        var diagPid = WriteParameterPID(
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

        if (item.memory_address == "true") {
          addrList.add(diagPid);
        } else {
          standardList.add(diagPid);
        }
      }

      print("🔑 standardList count: ${standardList.length}");
      print("🔑 addrList count: ${addrList.length}");

      List<WriteParameterStatus> finalResults = [];

      // ── Standard PIDs ─────────────────────────────────────────────────────
      if (standardList.isNotEmpty && udsDiagnostic != null) {
        var rawResult = await udsDiagnostic!.writeParameters(
          pidList.length,
          mainIndex,
          standardList,
        );

        print("🔑 writeParameters runtimeType: ${rawResult.runtimeType}");

        if (rawResult != null) {
          try {
            final jsonStr = jsonEncode(rawResult);
            print("🔑 writeParameters JSON: $jsonStr");

            final jsonList = jsonDecode(jsonStr) as List;
            final mapped = jsonList
                .map((e) =>
                    WriteParameterStatus.fromJson(e as Map<String, dynamic>))
                .toList();
            finalResults.addAll(mapped);

            for (var r in mapped) {
              print("🔑   status: ${r.status}");
            }
          } catch (e) {
            print("🔑 JSON mapping error: $e");
          }
        }
      }

      // ── Memory Address PIDs ───────────────────────────────────────────────
      if (addrList.isNotEmpty && udsDiagnostic != null) {
        for (var item in addrList) {
          var rawResult = await udsDiagnostic!.writeParametersFromAddr(
            item,
            pidByAddrSeq,
          );

          if (rawResult != null) {
            try {
              final jsonStr = jsonEncode(rawResult);
              final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
              final mapped = WriteParameterStatus.fromJson(jsonMap);
              finalResults.add(mapped);
              print("🔑 addr status: ${mapped.status}");
            } catch (e) {
              print("🔑 addr JSON mapping error: $e");
            }
          }
        }
      }

      print("🔑 finalResults count: ${finalResults.length}");
      return finalResults;
    } catch (ex) {
      print("Error in writePid: $ex");
      return [];
    }
  }

  Future<void> cancel() async {
    throw UnimplementedError(
        "The cancel method has not been implemented for Windows yet.");
  }

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

        response = (await udsDiagnostic!.flashInterpreter(
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

  Future<void> txHeader(String txHeader) async {
    try {
      // 1. Call the hardware communication method
      // Assuming CAN_SetTxHeader returns dynamic or Uint8List
      var setHeader = await dongleCommWin!.canSetTxHeader(txHeader);

      // 2. Cast result to Uint8List (Dart's equivalent of byte[])
      if (setHeader is Uint8List) {
        // 3. Convert the byte array back to a Hex String for logging
        // Using the helper method we defined earlier
        String headerResponse = byteArrayToHex(setHeader);

        // 4. Debug Output
        print("------DTC TX Header Set------ $txHeader");
        print("Header Response-- $headerResponse");
      }
    } catch (e) {
      print("Error setting TX Header: $e");
    }
  }

  Future<void> rxHeader(String rxHeader) async {
    try {
      // 1. Call the hardware communication method for the Rx Mask/Header
      // Note: canSetRxHeaderMask usually configures the acceptance filter
      var setHeader = await dongleCommWin!.canSetRxHeaderMask(rxHeader);

      // 2. Cast result to Uint8List (Dart's byte[])
      if (setHeader is Uint8List) {
        // 3. Convert response bytes to Hex String for logging
        // Uses the same helper method: byteArrayToHex
        String headerResponse = byteArrayToHex(setHeader);

        // 4. Debug Output
        print("------DTC RX Header Set------ $rxHeader");
        print("RX Header Response-- $headerResponse");
      }
    } catch (e) {
      print("Error setting RX Header/Mask: $e");
    }
  }

  Future<List<String>> sendTerminalCommands(List<String> commands) async {
    try {
      // 1. Initialize Response Array (Fixed size of 7 like C# vs_res)
      List<String> vsRes = List.filled(7, "");
      String firmwareVersionStr = "";

      // 2. Initialize Hardware Class
      // In Windows, we use the already discovered 'port' and 'inputOutputManager'
      // commands[0] is typically the Protocol index
      int protocolIndex = int.tryParse(commands[0]) ?? 0;

      // Assuming dongleCommWin and udsDiagnostic are already defined in your class
      // dongleCommWin = DongleCommWin(
      //   serialInputOutputManager: inputOutputManager,
      //   port: serialPort, // The LibSerialPort instance
      //   protocol: protocolIndex,
      // );

      // Initialize platform as Windows
      await dongleCommWin!.initializePlatform(
        PlatformType.windows,
        ConnectivityType.usb,
        false, // canSimulate flag
      );

      udsDiagnostic = udsDiagnostic!;

      if (dongleCommWin != null) {
        // 3. Security Access
        var securityAccess = await dongleCommWin!.securityAccess();
        if (securityAccess is Uint8List) {
          String securityResponse = byteArrayToHex(securityAccess);
          print("Security Response: $securityResponse");
        }

        // 4. Get Firmware Version
        // C# logic: firmwareResult[3].ToString("D2") + "." + firmwareResult[4]...
        var firmwareVersion = await dongleCommWin!.dongleGetFirmwareVersion();
        if (firmwareVersion is Uint8List && firmwareVersion.length >= 6) {
          firmwareVersionStr =
              "${firmwareVersion[3].toString().padLeft(2, '0')}."
              "${firmwareVersion[4].toString().padLeft(2, '0')}."
              "${firmwareVersion[5].toString().padLeft(2, '0')}";
          vsRes[6] = firmwareVersionStr;
        }

        // 5. Set Protocol
        var setProtocol = await dongleCommWin!.dongleSetProtocol(protocolIndex);
        vsRes[0] = commands[0];
        vsRes[5] = commands[5];

        // 6. Set TX Header (commands[1])
        await dongleCommWin!.canSetTxHeader(commands[1]);
        vsRes[1] = commands[1];

        // 7. Set RX Header Mask (commands[2])
        await dongleCommWin!.canSetRxHeaderMask(commands[2]);
        vsRes[2] = commands[2];

        // 8. Handle Padding (commands[3])
        if (commands[3].isNotEmpty) {
          await dongleCommWin!.canStartPadding(commands[3]);
          vsRes[3] = "Enabled";
        } else {
          vsRes[3] = "Disabled";
        }
      }

      return vsRes;
    } catch (ex) {
      print("Error in sendTerminalCommands: $ex");
      return List.filled(7, "Error");
    }
  }

  Future<String> setData(String commands) async {
    String responseCommand = "";
    try {
      // 1. Send raw data command to the Diagnostic Service
      // 'setDataData' usually sends a raw frame and waits for the ECU response
      var response = await udsDiagnostic!.setDataData(commands);

      if (response == null) {
        // Replacing Android Toast with debug log for Windows
        print("Diagnostic Response: NULL");
        return "NULL";
      }

      // 2. Check for successful ECU communication
      // We check for "NOERROR" which indicates a valid positive response (e.g., 0x62)
      if (response.ecuResponseStatus?.contains("NOERROR") ?? false) {
        // 3. Convert response bytes to Hex string
        if (response.actualDataBytes != null) {
          responseCommand = byteArrayToHex(response.actualDataBytes!);
        } else {
          responseCommand = "NO DATA BYTES RECEIVED";
        }
      } else {
        // Return the specific error status (e.g., "7F 22 31" - Request Out of Range)
        responseCommand = response.ecuResponseStatus ?? "UNKNOWN ERROR";
      }

      return responseCommand;
    } catch (ex, stacktrace) {
      // Return detailed error info for debugging on Windows
      return "STACKMESSAGE : ${ex.toString()}\n\n${stacktrace.toString()}";
    }
  }

  @override
  Future<String> unlockEcu(ResultUnlock unlockData) async {
    try {
      // 1. Extract values from the data model
      // Using null-aware operators to prevent crashes if unlockData is incomplete
      String txId = unlockData.txId ?? "";
      String txFrame = unlockData.txFrame ?? "";
      String txFrequency = unlockData.txFrequency ?? "";
      String txTotalTime = unlockData.txTotalTime ?? "";
      String rxId = unlockData.rxId ?? "";
      String protocolValue = unlockData.protocol?.autopeepal ?? "";

      // 2. Configure the Dongle
      // This sets the protocol, Tx ID, and Rx ID on the Windows COM port
      await setDongleProperties(
          protocolName: protocolValue, txHeaderTemp: txId, rxHeaderTemp: rxId);

      String response = "";

      // 3. Execute the Unlocking Sequence
      if (udsDiagnostic != null) {
        // This library call typically handles the timing-sensitive
        // transmission required to wake up or unlock certain ECUs
        response = (await udsDiagnostic!.startEcuUnlocking(
          txFrame,
          txFrequency,
          txTotalTime,
        ))!;
      }

      return response;
    } catch (ex) {
      print("Error during ECU Unlock: $ex");
      return "ERROR: ${ex.toString()}";
    }
  }

  @override
  Future<WriteParameterStatus> writeAtuatorTest(
    String writeParaIndex,
    String seedKeyIndex,
    List<Uint8List> command,
    bool isStartTest,
  ) async {
    try {
      // 1. Parse Enums from String values
      WriteParameterIndex writeIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.name == writeParaIndex,
      );

      SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKeyIndex,
      );

      // 2. Execute the Actuator Test call
      if (udsDiagnostic != null) {
        // The library returns a WriteParameterResponse object
        var result = await udsDiagnostic!.atuatorTestWriteParameters(
          writeIndex as int,
          seedIndex as WriteParameterIndex,
          command.cast<WriteParameterPID>(),
          isStartTest,
        );

        // 3. Map WriteParameterResponse fields to WriteParameterStatus
        // Adjust field names (e.g., result.status vs result.ecuResponseStatus)
        // based on your specific Windows library definition.
        // return WriteParameterStatus(
        //   status: result.status, // From WriteParameterResponse
        //   dataArray: result.dataArray., // From WriteParameterResponse
        // );
      }

      return WriteParameterStatus(status: "DIAGNOSTIC_SERVICE_UNAVAILABLE");
    } catch (ex) {
      print("Error in WriteAtuatorTest: $ex");
      return WriteParameterStatus(status: "EXCEPTION: ${ex.toString()}");
    }
  }

  @override
  Future<TestRoutineResponseModel?> setTestRoutineCommand({
    required String seedKey,
    required String writeParaIndex,
    required String startCommand,
    String? requestCommand,
    String? stopCommand,
    bool? testCondition,
    int? bitPosition,
    List<String>? activeCommand,
    String? stoppedCommand,
    String? failCommand,
    bool? isStop,
    int? timeBase,
  }) async {
    try {
      // 1. Parse Enums safely
      SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKey,
      );

      WriteParameterIndex writeIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.name == writeParaIndex,
      );

      if (udsDiagnostic != null) {
        // 2. Call the Diagnostic Service
        // We pass the parameters provided in the named arguments.
        // We use the ?? operator to provide default values if the optional params are null.
        var result = await udsDiagnostic!.iorTestParameters1(
          seedKeyIndex: seedIndex,
          writeParameterIndex: writeIndex,
          startCommand: startCommand,
          requestCommand: requestCommand ?? '',
          stopCommand: stopCommand ?? '',
          initialTestCondition: testCondition ?? false,
          bitPosition: bitPosition ?? 0,
          // activeCommand: activeCommand, // Uncomment if supported by your library
          failCommand: failCommand ?? '',
          isStop: isStop ?? false,
          timeBase: timeBase ?? 0,
          completeCommand: stoppedCommand ?? '',
        );

        // 3. Map result to the Response Model
        if (result is TestRoutineResponseModel) {
          //  return result;
        } else if (result != null) {
          // return TestRoutineResponseModel(
          //   status: result.status?.toString(),
          //   message: result.message?.toString(),
          // );
        }
      }

      return null;
    } catch (ex) {
      print("Error in SetTestRoutineCommand: $ex");
      return null;
    }
  }

  @override
  Future<TestRoutineResponseModel?> continueIorTest(
    String seedKey,
    String writeParaIndex,
    String startCommand,
    String requestCommand,
    String stopCommand,
    bool testCondition,
    int bitPosition,
    List<String> activeCommand,
    String stoppedCommand,
    String failCommand,
    bool isStop,
    int timeBase,
    bool isTimebase,
  ) async {
    try {
      // 1. Parse Enums from String values
      SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKey,
      );

      WriteParameterIndex writeIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.name == writeParaIndex,
      );

      if (udsDiagnostic != null) {
        // 2. Execute the continued IOR Test
        // We pass the new isTimebase parameter to the library
        var result = await udsDiagnostic!.iorTestParameters2(
          seedKeyIndex: seedIndex,
          writeParameterIndex: writeIndex,
          startCommand: startCommand,
          requestCommand: requestCommand,
          stopCommand: stopCommand,
          initialTestCondition: testCondition,
          bitPosition: bitPosition,
          activeCommands: activeCommand,
          failCommand: failCommand,
          isStop: isStop,
          timeBase: timeBase,
          isTimebase: isTimebase,
        );

        // 3. Handle result mapping
        // if (result is TestRoutineResponseModel) {
        //   return result;
        // } else if (result != null) {
        //   // Manual mapping if the library returns a raw object
        //   return TestRoutineResponseModel(
        //     status: result.status,
        //     message: result.message,
        //     // Map other properties as defined in your model
        //   );
        // }
      }

      return null;
    } catch (ex) {
      print("Error in ContinueIorTest: $ex");
      return null;
    }
  }

  @override
  Future<void> startTesterPresent() async {
    try {
      if (dongleCommWin != null) {
        // 1. Call the hardware method to start the periodic 0x3E frame
        // Most dongles handle the 2000ms-3000ms timing internally once started
        await dongleCommWin!.canStartTp();
        print("------ Tester Present Started ------");
      }
    } catch (e) {
      print("Error starting Tester Present: $e");
    }
  }

  @override
  Future<void> stopTesterPresent() async {
    try {
      if (dongleCommWin != null) {
        // 2. Call the hardware method to stop the periodic 0x3E frame
        await dongleCommWin!.canStopTp();
        print("------ Tester Present Stopped ------");
      }
    } catch (e) {
      print("Error stopping Tester Present: $e");
    }
  }

  @override
  Future<TestRoutineResponseModel?> setTestRoutineCommand1({
    required String seedKey,
    required String writeParaIndex,
    required String startCommand,
    String? requestCommand,
    String? stopCommand,
    bool? testCondition,
    int? bitPosition,
    List<String>? activeCommand,
    String? stoppedCommand,
    String? failCommand,
    bool? isStop,
    int? timeBase,
  }) async {
    try {
      // 1. Parse Enums from the incoming strings
      SeedKeyIndexType seedIndex = SeedKeyIndexType.values.firstWhere(
        (e) => e.name == seedKey,
      );

      WriteParameterIndex writeIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.name == writeParaIndex,
      );

      if (udsDiagnostic != null) {
        // 2. Call the Diagnostic Service
        // Note: We use the required parameters here.
        // If your library needs the others, pass them along as well.
        var result = await udsDiagnostic!.startIdIOR(
          seedIndex,
          writeIndex,
          startCommand,
        );

        // 3. Mapping the result
        if (result is TestRoutineResponseModel) {
          //return result;
        } else if (result != null) {
          // return TestRoutineResponseModel(
          //   status: result.status?.toString(),
          //   message: result.message?.toString(),
          // );
        }
      }

      return null;
    } catch (ex) {
      print("Error in SetTestRoutineCommand: $ex");
      return null;
    }
  }

  Future<TestRoutineResponseModel?> requestIorTest(
      String requestCommand) async {
    try {
      if (udsDiagnostic != null) {
        // 1. Execute the Request call to get current test status
        // This sends the specific requestCommand (e.g., "31 03 XX XX")
        var result = await udsDiagnostic!.requestIdIOR(requestCommand);

        // 2. Map result to the Response Model
        // Using direct casting instead of the expensive JSON serialization used in C#
        if (result is TestRoutineResponseModel) {
          //return result;
        } else if (result != null) {
          // Fallback manual mapping if the library returns a raw data object
          // return TestRoutineResponseModel(
          //   status: result.status,
          //   message: result.message,
          //   // Map other specific fields from your TestRoutineResponseModel
          // );
        }
      }

      return null;
    } catch (ex) {
      print("Error in RequestIorTest: $ex");
      // Return null to maintain consistency with the C# implementation
      return null;
    }
  }

  @override
  Future<TestRoutineResponseModel?> stopIorTest(String stopCommand) async {
    try {
      if (udsDiagnostic != null) {
        // 1. Execute the Stop call to terminate the test
        // Typically sends a 0x31 02 (Stop Routine) or 0x2F (Return Control)
        var result = await udsDiagnostic!.stopIdIOR(stopCommand);

        // 2. Map the library result to the Response Model
        // Direct casting is used here to replace the C# Serialize/Deserialize logic
        if (result is TestRoutineResponseModel) {
          //return result;
        } else if (result != null) {
          // Fallback manual mapping if the library returns a generic data object
          // return TestRoutineResponseModel(
          //   status: result.status,
          //   message: result.message,
          //   // Map any other properties specific to your TestRoutineResponseModel
          // );
        }
      }

      return null;
    } catch (ex) {
      print("Error in StopIorTest: $ex");
      // Return null to maintain consistency with the original C# catch block
      return null;
    }
  }

  @override
  Future<List<IvnReadDtcResponseModel>> ivnReadDtc(
      List<String> frameIdc) async {
    try {
      List<IvnReadDtcResponseModel> frameResponseList = [];

      // 1. Send the Frame IDs to the dongle via the hardware abstraction layer
      // setIvnFrame usually returns a list of raw response objects from the CAN bus
      var ivnReadDtcResponse = await dongleCommWin!.setIvnFrame(frameIdc);

      if (ivnReadDtcResponse != null && ivnReadDtcResponse.isNotEmpty) {
        // 2. Iterate through each hardware response item
        for (var item in ivnReadDtcResponse) {
          final ivnReadDtcResponseModel = IvnReadDtcResponseModel();

          // 3. Map raw byte data (Uint8List)
          // This is the payload of the CAN frame
          ivnReadDtcResponseModel.actualDataBytes = item.actualDataBytes;

          // 4. Convert the ECU Response byte array to a Hex String
          // This makes the response human-readable in the UI (e.g., "55 AA 00")
          if (item.ecuResponse != null) {
            ivnReadDtcResponseModel.ecuResponse =
                byteArrayToHex(item.ecuResponse!);
          } else {
            ivnReadDtcResponseModel.ecuResponse = "";
          }

          // 5. Map Diagnostic Status and the specific CAN Frame ID
          ivnReadDtcResponseModel.ecuResponseStatus =
              item.ecuResponseStatus ?? "UNKNOWN";
          ivnReadDtcResponseModel.frame = item.frame;

          // 6. Add the mapped model to our final results list
          frameResponseList.add(ivnReadDtcResponseModel);
        }
      }

      // Return the list (will be empty if no response was received)
      return frameResponseList;
    } catch (ex) {
      // Log the error for Windows debugging
      print("Error in IVN_ReadDtc: $ex");

      // Return an empty list instead of null to satisfy the non-nullable interface
      return [];
    }
  }

  @override
  Future<List<ReadPidPresponseModel>?> ivnReadPid(
      List<IvnSelectedPid> ivnPidList) async {
    try {
      // 1. Prepare the list for the Diagnostic Library
      // Using the library-specific type directly if possible, or mapping as you did
      List<IvnSelectedPid> diagnosticList = [];

      for (var item in ivnPidList) {
        List<PidFrameId> frameIdModels = [];

        for (var item1 in item.frameIds ?? []) {
          List<FrameOfPidMessage> frameMessages = [];
          for (var item2 in item1.frameOfPidMessage ?? []) {
            frameMessages.add(FrameOfPidMessage(
              code: item2.code,
              message: item2.message,
            ));
          }

          frameIdModels.add(PidFrameId(
            framId: item1.framID,
            pidDescription: item1.pidDescription,
            startByte: item1.startByte,
            byteValue:
                item1.byte, // Ensure this matches the field in PidFrameId
            bitCoded: item1.bitCoded,
            startBit: item1.startBit,
            noOfBits: item1.noOfBits,
            resolution: item1.resolution,
            offset: item1.offset,
            unit: item1.unit,
            messageType: item1.messageType,
            endian: item1.endian,
            numType: item1.numType,
          ));
        }

        diagnosticList.add(IvnSelectedPid(
          frameId: item.frameId,
          frameIds: frameIdModels,
        ));
      }

      // 2. Execute the asynchronous library call
      if (udsDiagnostic != null) {
        // Use .cast() carefully or ensure diagnosticList is the correct type from the start
        var result = await udsDiagnostic!.ivnReadParameters(
          ivnPidList.length,
          diagnosticList.cast<IVNSelectedPID>(),
        );

        // 3. Handle result mapping
        if (result is List<ReadPidPresponseModel>) {
          // return result;
        } else if (result is List) {
          // If it's a generic list, try to map it
          return result.map((e) => e as ReadPidPresponseModel).toList();
        }
      }

      return null;
    } catch (ex) {
      // Using debugPrint for Windows console output
      print("Error in IVN_ReadPid: $ex");
      return null;
    }
  }

// Class-level variable to track progress
  double flashingPercent = 0.0;

  @override
  Future<double> flashingData() async {
    try {
      if (udsDiagnostic != null) {
        // 1. Fetch the current percentage from the diagnostic engine
        // In Dart, 'double' is used instead of 'float'
        final double result = await udsDiagnostic!.getRuntimeFlashPercent();

        // 2. Update the local tracking variable
        flashingPercent = result;

        return flashingPercent;
      }
      return 0.0;
    } catch (ex) {
      print("Error fetching flash progress: $ex");
      return 0.0;
    }
  }

  @override
  Future<double> resetPercentage() async {
    try {
      if (udsDiagnostic != null) {
        // 1. Tell the diagnostic engine to reset its internal counters
        await udsDiagnostic!.resetPercentage();

        // 2. Reset our local tracking variable as well
        flashingPercent = 0.0;

        return 0.0;
      }
      return 0.0;
    } catch (ex) {
      print("Error resetting progress percentage: $ex");
      return 0.0;
    }
  }

  /// Helper to convert a plain string (SSID) to a Hex string
  String stringToHex(String input) {
    return input.codeUnits
        .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
        .join('')
        .toUpperCase();
  }

  String byteArrayToHex(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join('');
  }

  String toHex(String input) {
    // .codeUnits provides the UTF-16 values of the characters
    return input.codeUnits
        .map((unit) => unit.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join('')
        .trim();
  }
}
