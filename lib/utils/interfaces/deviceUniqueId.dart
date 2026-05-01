import 'dart:async';

abstract class IDeviceUniqueId {
  /// Equivalent to Task<string[]> GetDeviceUniqueId()
  Future<List<String>> getDeviceUniqueId();
}