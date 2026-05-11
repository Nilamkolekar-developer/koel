import 'package:flutter_libserialport/flutter_libserialport.dart';

class HardwareManager {
  // 1. Create a private constructor
  HardwareManager._privateConstructor();

  // 2. Create the single static instance (Singleton)
  static final HardwareManager instance = HardwareManager._privateConstructor();

  // 3. Define the Windows-specific SerialPort variable
  SerialPort? activePort;

  // 4. Define your I/O manager (if you have a custom wrapper for reading/writing)
  dynamic inputOutputManager;

  // 5. Helper method to return the port, matching your C# logic
  SerialPort? returnPort() => activePort;

  // 6. Helper method to return the IO manager
  dynamic returnInputOutputManager() => inputOutputManager;
}