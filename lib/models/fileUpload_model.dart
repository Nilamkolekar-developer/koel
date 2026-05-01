import 'dart:convert';
import 'dart:typed_data';

class FileUploadModel {
  String? fileName;
  Uint8List? fileData;

  FileUploadModel({
    this.fileName,
    this.fileData,
  });

  // JSON -> Object
  factory FileUploadModel.fromJson(Map<String, dynamic> json) {
    return FileUploadModel(
      fileName: json['FileName'],
      // Decodes the Base64 string back into bytes
      fileData: json['FileData'] != null 
          ? base64Decode(json['FileData']) 
          : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'FileName': fileName,
      // Encodes bytes into a Base64 string for JSON transport
      'FileData': fileData != null 
          ? base64Encode(fileData!) 
          : null,
    };
  }
}