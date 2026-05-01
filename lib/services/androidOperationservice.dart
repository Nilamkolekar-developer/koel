import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart'; // This 'as p' is what defines the name 'p'

class AndroidOperationsService {
  /// Checks if the device has a valid internet connection path.
  /// Replaces the C# InternetNetwork extension method.
  static Future<bool> hasInternet() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    // connectivity_plus returns a list because a device can have
    // multiple connections (e.g., Wifi + VPN)
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.vpn)) {
      return true;
    }

    return false;
  }

  static Future<String> getVersionNumber() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // .version corresponds to VersionName on Android
      return packageInfo.version;
    } catch (e) {
      // In case of error, return a default value or empty string
      // similar to your C# catch block
      return '';
    }
  }

  static Future<List<String>> getDeviceUniqueId() async {
    List<String> uniqueId = ["false", "Device id not found."];

    try {
      // Check if the current platform is actually Windows
      if (Platform.isWindows) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;

        // machineId is the unique identifier for the Windows installation
        String id = windowsInfo.deviceId;

        if (id.isNotEmpty) {
          uniqueId = ["true", id.toUpperCase()];
        }
      } else {
        uniqueId = ["false", "Platform not supported."];
      }
    } catch (e) {
      // Logic mirrors your C# catch block (returning the default failure state)
    }

    return uniqueId;
  }

  static Future<String?> getData(String fileName) async {
    try {
      // 1. Get the local application documents directory
      final directory = await getApplicationDocumentsDirectory();

      // 2. Construct path using path.join for Windows backslash compatibility
      // This results in: C:\Users\<User>\Documents\<fileName>.txt
      final filePath = p.join(directory.path, '$fileName.txt');
      final file = File(filePath);

      // 3. Check if file exists (Windows-safe check)
      if (!await file.exists()) {
        return null;
      }

      // 4. Read all lines
      // Note: For very large files, a Stream is better, but for .txt config,
      // readAsLines is efficient.
      List<String> lines = await file.readAsLines();

      // 5. Return the last line (Matches C# 'while' loop behavior)
      if (lines.isNotEmpty) {
        return lines.last;
      }

      return "";
    } catch (e) {
      // Catching system IO exceptions or Permission denied errors
      return null;
    }
  }

  static Future<void> saveData(String fileName, [String data = ""]) async {
    try {
      // 1. Get the directory (Documents folder on Windows)
      final directory = await getApplicationDocumentsDirectory();

      // 2. Construct the full path
      final filePath = p.join(directory.path, '$fileName.txt');
      final file = File(filePath);

      // 3. Write the data
      // mode: FileMode.write replaces existing content (like File.CreateText)
      // We add \n to mimic WriteLineAsync
      await file.writeAsString('$data\n', mode: FileMode.write, flush: true);
    } catch (e) {
      // Logic mirrors your C# empty catch block
      // In production, consider logging 'e'
    }
  }

  static Future<bool> requestPermissionAsync() async {
    try {
      // 1. Check current status of 'Location When In Use'
      PermissionStatus status = await Permission.locationWhenInUse.status;

      // 2. Handle Denied Status
      if (status.isDenied) {
        // 'shouldShowRequestRationale' in Android
        if (await Permission.locationWhenInUse.shouldShowRequestRationale) {
          // You can use a standard Flutter showDialog here instead of UserDialogs
          print("Please grant access to Location: Need Permissions");
        }

        // Request the permission
        status = await Permission.locationWhenInUse.request();

        if (!status.isGranted) {
          print("Please grant access to Location: Need Permissions");
        }
        return true;
      }

      // 3. Handle Granted Status
      else if (status.isGranted) {
        // Check if GPS/Location Services are enabled on the device
        bool isLocationServiceEnabled =
            await Geolocator.isLocationServiceEnabled();

        if (!isLocationServiceEnabled) {
          if (Platform.isAndroid) {
            // Opens the Android Location settings page
            await Geolocator.openLocationSettings();

            // To mimic your 'while' loop, we wait until services are enabled
            // WARNING: Be careful with infinite loops in production.
            while (!(await Geolocator.isLocationServiceEnabled())) {
              await Future.delayed(const Duration(milliseconds: 500));
            }
          } else if (Platform.isWindows) {
            // Windows specific: Open settings or just inform user
            await Geolocator.openLocationSettings();
          }
          return true;
        }
        return true;
      }
    } catch (e) {
      // Catching any platform exceptions
    }
    return false;
  }

  static Future<String> getCurrentAddress() async {
    String address = '';

    try {
      // 1. Request Permission (Using the method we converted previously)
      // In Flutter, we don't need 'InvokeOnMainThread' for this; it's handled by the framework.
      bool hasPermission = await requestPermissionAsync();

      if (hasPermission) {
        // Small delay to ensure hardware is ready, matching your C# logic
        await Future.delayed(const Duration(milliseconds: 200));

        // 2. Get current GPS Coordinates
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Fallback address in case geocoding fails
        address = "Lat: ${position.latitude}, Long: ${position.longitude}";

        // 3. Get Placemarks (Reverse Geocoding)
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks[0];
          List<String> parts = [];

          // Adding address components if they are not null or empty
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            parts.add(p.subLocality!);
          if (p.thoroughfare != null && p.thoroughfare!.isNotEmpty)
            parts.add(p.thoroughfare!);
          if (p.locality != null && p.locality!.isNotEmpty)
            parts.add(p.locality!);
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            parts.add(p.administrativeArea!);
          if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);

          address = parts.join(', ');
        }
      }
    } on LocationServiceDisabledException {
      // Handle "FeatureNotEnabled" equivalent
    } catch (e) {
      // Handle general exceptions (Permissions, Timeout, etc.)
    }

    return address;
  }
}

extension ToastExtension on String {
  /// Shows a toast message.
  /// Mimics the C# ShowMessage extension.
  Future<void> showMessage() async {
    try {
      await Fluttertoast.showToast(
        msg: this,
        toastLength: Toast.LENGTH_SHORT, // Equivalent to ToastDuration.Short
        gravity: ToastGravity.BOTTOM, // Position on screen
        fontSize: 14.0, // Matches your 14 fontSize
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } catch (e) {
      // Logic mirrors your empty catch block
    }
  }
}
