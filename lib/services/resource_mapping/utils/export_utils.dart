import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../data/models/resource.dart';

class ExportUtils {
  static void exportToCSV(List<Resource> resources) {
    List<List<dynamic>> csvData = [];
    
    // Add header
    csvData.add([
      'Name',
      'Category',
      'Description',
      'Latitude',
      'Longitude',
      'Available',
      'Owner',
      'Organization',
      'Created At'
    ]);
    
    // Add data
    for (var resource in resources) {
      csvData.add([
        resource.name,
        resource.category,
        resource.description,
        resource.latitude,
        resource.longitude,
        resource.isAvailable,
        resource.owner,
        resource.organization,
        resource.createdAt.toString()
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(csvData);
    
    // Save file
    _saveAndOpenFile(csv, 'resources.csv', 'text/csv');
  }

  static void exportToExcel(List<Resource> resources) async {
    // Create a new Excel document
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    
    // Add header
    sheet.getRangeByIndex(1, 1).setText('Name');
    sheet.getRangeByIndex(1, 2).setText('Category');
    sheet.getRangeByIndex(1, 3).setText('Description');
    sheet.getRangeByIndex(1, 4).setText('Latitude');
    sheet.getRangeByIndex(1, 5).setText('Longitude');
    sheet.getRangeByIndex(1, 6).setText('Available');
    sheet.getRangeByIndex(1, 7).setText('Owner');
    sheet.getRangeByIndex(1, 8).setText('Organization');
    sheet.getRangeByIndex(1, 9).setText('Created At');
    
    // Add data
    for (int i = 0; i < resources.length; i++) {
      Resource resource = resources[i];
      sheet.getRangeByIndex(i + 2, 1).setText(resource.name);
      sheet.getRangeByIndex(i + 2, 2).setText(resource.category);
      sheet.getRangeByIndex(i + 2, 3).setText(resource.description);
      sheet.getRangeByIndex(i + 2, 4).setNumber(resource.latitude);
      sheet.getRangeByIndex(i + 2, 5).setNumber(resource.longitude);
      sheet.getRangeByIndex(i + 2, 6).setText(resource.isAvailable ? 'Yes' : 'No');
      sheet.getRangeByIndex(i + 2, 7).setText(resource.owner);
      sheet.getRangeByIndex(i + 2, 8).setText(resource.organization);
      sheet.getRangeByIndex(i + 2, 9).setText(resource.createdAt.toString());
    }
    
    // Save and launch the file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    
    _saveAndOpenFile(bytes, 'resources.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  static void _saveAndOpenFile(dynamic data, String fileName, String mimeType) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/$fileName');
    
    if (data is String) {
      await file.writeAsString(data);
    } else if (data is List<int>) {
      await file.writeAsBytes(data);
    }
    
    OpenFile.open('$path/$fileName', type: mimeType);
  }
}