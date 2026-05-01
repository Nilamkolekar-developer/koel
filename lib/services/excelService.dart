import 'dart:io';
import 'package:autopeepal/models/excelStructure.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ExcelServiceWindows {
  
  /// Creates the Excel file and directory structure on Windows
  Future<List<String>> generateExcel(String fileName) async {
    List<String> returnValue = ["", ""];
    try {
      // 1. Get the Windows 'Documents' directory
      final Directory? docDir = await getApplicationDocumentsDirectory();
      if (docDir == null) throw Exception("Could not access Documents directory");

      // 2. Create the "AnalyzeData" sub-folder
      final String filePathDir = p.join(docDir.path, "AnalyzeData");
      final Directory directory = Directory(filePathDir);
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String filePath = p.join(filePathDir, fileName);

      // 3. Initialize Excel
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Analyze Records');

      // 4. Save to Disk
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }

      returnValue[0] = "true";
      returnValue[1] = filePath;
      return returnValue;
    } catch (ex) {
      returnValue[0] = "false";
      returnValue[1] = ex.toString();
      return returnValue;
    }
  }

  /// Inserts data into the Windows-based Excel file
  Future<void> insertDataIntoSheet(String filePath, String sheetName, ExcelStructure data) async {
    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      Sheet sheetObject = excel[sheetName];

      // Insert Headers at Row 0
      for (int i = 0; i < data.headers.length; i++) {
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          data.headers[i] as CellValue?,
        );
      }

      // Insert Values starting at Row 1
      for (int r = 0; r < data.values.length; r++) {
        var rowData = data.values[r];
        for (int c = 0; c < rowData.length; c++) {
          sheetObject.updateCell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
            rowData[c] as CellValue?,
          );
        }
      }

      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath).writeAsBytesSync(fileBytes);
      }
    } catch (e) {
      print("Windows Excel Write Error: $e");
    }
  }
  Future<void> deleteDataIntoSheet(String fileName, String sheetName) async {
    try {
      // 1. Read the existing file bytes
      final File file = File(fileName);
      if (!await file.exists()) {
        print("File not found: $fileName");
        return;
      }

      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);

      // 2. Check if the sheet exists
      if (excel.tables.containsKey(sheetName)) {
        // Option A: Clear all cell content in the sheet
        var sheet = excel.tables[sheetName]!;
        
        // We iterate through max rows and columns and set them to null/empty
        for (int row = 0; row < sheet.maxRows; row++) {
          for (int col = 0; col < sheet.maxRows; col++) {
            sheet.updateCell(
              CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
              null, // Setting value to null clears the cell
            );
          }
        }
        
        /* 
        Option B: If you want to completely reset the sheet 
        (similar to removing SheetData in OpenXML):
        excel.delete(sheetName);
        excel.createSheet(sheetName);
        */
      }

      // 3. Save the changes back to the Windows file system
      var fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
      }
      
      print("Data in '$sheetName' deleted successfully.");
    } catch (e) {
      // Replicates the lack of an explicit catch-return in your C# snippet
      print("Error deleting data from Excel: ${e.toString()}");
    }
  }
}