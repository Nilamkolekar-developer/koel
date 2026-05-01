import 'dart:async';

import 'package:autopeepal/models/fileUpload_model.dart';



abstract class IFilePicker {
  /// Equivalent to Task<FileUploadModel> PickFileAsync()
  Future<FileUploadModel?> pickFileAsync();
}