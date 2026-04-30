import 'dart:async';

abstract class ISaveLocalData {
  /// Equivalent to string GetData(string file_name)
  String getData(String fileName);

  /// Equivalent to Task SaveData(string file_name, string Data)
  Future<void> saveData(String fileName, String data);

  /// Equivalent to Task CreateExcelFile(string file_name, string data)
  Future<void> createExcelFile(String fileName, String data);
}