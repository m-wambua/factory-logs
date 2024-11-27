import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/pages2/equipment/equipmentmenu.dart';
import 'package:path/path.dart' as path;

class ParameterStorage {
  final String name;
  final String description;

  ParameterStorage({required this.name, required this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  static ParameterStorage fromJson(Map<String, dynamic> json) {
    return ParameterStorage(
        name: json['name'], description: json['description']);
  }

  static Future<void> saveParamterList(
      List<ParameterStorage> parameterList, String equipmentName) async {
    try {
      final basDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/parameters/parameterstore';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(basDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      if (!await equipmentDir.exists()) {
        print("Creating equipment folder at: $equipmentDirPath");
        await equipmentDir.create(recursive: true);
        if (await equipmentDir.exists()) {
          print("Equipment folder created successfully");
        } else {
          print("Failed to create equipment folder");
          return;
        }
      }
      final filePath = path.join(
          equipmentDirPath, '${sanitizedEquipmentName}_paramaters.json');
      final file = File(filePath);

      final jsonList = parameterList.map((pl) => pl.toJson()).toList();

      await file.writeAsString(json.encode(jsonList));
      print("Parameter list saved successfully");
    } catch (e) {
      print("Error saving parameter list: $e");
      throw e;
    }
  }

  static Future<List<ParameterStorage>> loadParameterList(
      String equipmentName) async {
    try {
      final basDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/parameters/parameterstore';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(basDir, sanitizedEquipmentName);
      final filePath = path.join(
          equipmentDirPath, '${sanitizedEquipmentName}_parameters.json');
      final file = File(filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);

        final parameters =
            jsonList.map((json) => ParameterStorage.fromJson(json)).toList();
        print("Loaded ${parameters.length} parameters");
        return parameters;
      } else {
        print("No existing parameter list found");
        return [];
      }
    } catch (e) {
      print("Error loading parameter list: $e");
      throw e;
    }
  }

  static Future<void> deleteParameterEntry(String equipmentName) async {
    try {
      final baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/parameters/parameterstore';

      final sanitzedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitzedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      if (await equipmentDir.exists()) {
        await equipmentDir.delete(recursive: true);
        print("Parameter list deleted successfully");
      } else {
        print("Parameter list not found at : $equipmentDir");
      }
    } catch (e) {
      print("Error deleting parameter list: $e");
      throw e;
    }
  }
}
