import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class SparePart {
  final String name;
  final String partNumber;
  final String description;
  final int minimumStock;
  final int maximumStock;
  final String leadTime;
  final String supplierInfo;
  final String criticality;
  final String condition;
  final String warranty;
  final String usageRate;

  SparePart({
    required this.name,
    required this.partNumber,
    required this.description,
    required this.minimumStock,
    required this.maximumStock,
    required this.leadTime,
    required this.supplierInfo,
    required this.criticality,
    required this.condition,
    required this.warranty,
    required this.usageRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'partNumber': partNumber,
      'description': description,
      'minimumStock': minimumStock,
      'maximumStock': maximumStock,
      'leadTime': leadTime,
      'supplierInfo': supplierInfo,
      'criticality': criticality,
      'condition': condition,
      'warranty': warranty,
      'usageRate': usageRate,
    };
  }

  static SparePart fromJson(Map<String, dynamic> json) {
    return SparePart(
      name: json['name'],
      partNumber: json['partNumber'],
      description: json['description'],
      minimumStock: json['minimumStock'],
      maximumStock: json['maximumStock'],
      leadTime: json['leadTime'],
      supplierInfo: json['supplierInfo'],
      criticality: json['criticality'],
      condition: json['condition'],
      warranty: json['warranty'],
      usageRate: json['usageRate'],
    );
  }

  static Future<void> saveSparePartsList(
      List<SparePart> spareParts, String equipmentName) async {
    try {
      // Define the base directory
      const baseDir =
          'lib/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/sparesstorage';

      // Sanitize the equipmentName to replace slashes with a safe character (e.g., underscore)
      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      // Create the full directory path
      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      // Check if the equipment folder exists, if not create it
      if (!await equipmentDir.exists()) {
        print("Creating equipment folder at: $equipmentDirPath");
        await equipmentDir.create(recursive: true);
        if (await equipmentDir.exists()) {
          print("Created equipment folder: $equipmentDirPath");
        } else {
          print("Failed to create equipment folder.");
          return;
        }
      }

      // Define the file path for saving spare parts list
      final filePath =
          path.join(equipmentDirPath, '${sanitizedEquipmentName}_spares.json');
      final file = File(filePath);

      // Convert the spare parts list to JSON and save to the file
      final jsonList = spareParts.map((sp) => sp.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print(
          "Successfully wrote ${spareParts.length} spare parts to file: $filePath");
    } catch (e) {
      print("Error saving spare parts: $e");
      rethrow; // Re-throw the error for further handling if necessary
    }
  }

  static Future<List<SparePart>> loadSparePartsList(
      String equipmentName) async {
    try {
      // Define the base directory
      const baseDir =
          'lib/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/sparesstorage';

      // Sanitize the equipmentName to replace slashes with a safe character (e.g., underscore)
      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      // Create the full file path to load the spare parts
      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final filePath =
          path.join(equipmentDirPath, '${sanitizedEquipmentName}_spares.json');
      final file = File(filePath);

      // Check if the file exists
      if (await file.exists()) {
        // Read the file contents and convert to list of SparePart objects
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        final spareParts =
            jsonList.map((json) => SparePart.fromJson(json)).toList();
        print("Loaded ${spareParts.length} spare parts from file");
        return spareParts;
      } else {
        print("No existing spare parts file found at: $filePath");
        return [];
      }
    } catch (e) {
      print("Error loading spare parts: $e");
      rethrow; // Re-throw the error for further handling if necessary
    }
  }

  // New Delete method
  static Future<void> deleteSparePartsEntry(String equipmentName) async {
    try {
      // Define the base directory
      const baseDir =
          'lib/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/sparesstorage';

      // Sanitize the equipmentName to replace slashes with a safe character (e.g., underscore)
      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      // Create the full directory path
      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      // Check if the equipment folder exists
      if (await equipmentDir.exists()) {
        // Recursively delete the equipment directory and all its contents
        await equipmentDir.delete(recursive: true);
        print("Successfully deleted equipment folder: $equipmentDirPath");
      } else {
        print("No equipment folder found to delete at: $equipmentDirPath");
      }
    } catch (e) {
      print("Error deleting spare parts entry: $e");
      rethrow; // Re-throw the error for further handling if necessary
    }
  }
}
