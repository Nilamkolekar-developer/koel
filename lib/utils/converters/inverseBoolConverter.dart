class InverseBoolConverter {
  /// Equivalent to the 'Convert' method
  static bool convert(bool value) {
    return !value;
  }

  /// Equivalent to the 'ConvertBack' method
  static bool convertBack(bool value) {
    return value;
  }
}