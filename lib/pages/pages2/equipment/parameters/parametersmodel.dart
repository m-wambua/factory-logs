import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/pages2/equipment/spares/spartpartsmodel.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

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
      const basDir =
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
          equipmentDirPath, '${sanitizedEquipmentName}_parameters.json');
      final file = File(filePath);

      final jsonList = parameterList.map((pl) => pl.toJson()).toList();

      await file.writeAsString(json.encode(jsonList));
      print("Parameter list saved successfully");
    } catch (e) {
      print("Error saving parameter list: $e");
      rethrow;
    }
  }

  static Future<List<ParameterStorage>> loadParameterList(
      String equipmentName) async {
    try {
      const basDir =
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
      rethrow;
    }
  }

  static Future<void> deleteParameterEntry(String equipmentName) async {
    try {
      const baseDir =
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
      rethrow;
    }
  }
}

class SparePartsService{
  final String baseUrl='http://0.0.0.0:8000';

  Future<SparePart> createSparePart(SparePart sparePart) async{
    final response=await http.post(
      Uri.parse('$baseUrl/spare-parts/'),
      headers: {'Content-Type':'application/json'},
      body: json.encode(sparePart.toJson())
    );
    if(response.statusCode==200){
      return SparePart.fromJson(json.decode(response.body));

    }else{
      throw Exception('Failed to create spare part: ${response.statusCode}');
    }
  }

  Future<List<SparePart>> getSparePartsByEquipment(String equipmentName) async{
    final response= await http.get(Uri.parse('$baseUrl/spare-parts/$equipmentName'));

    if(response.statusCode==200){
      final List<dynamic> body=json.decode(response.body);
      return body.map((dynamic item)=>SparePart.fromJson(item)).toList();
  }else{
    throw Exception('Failed to load spare parts: ${response.statusCode}');
  }
  }

  Future<void> deleteSparePart(String id) async{
    final response=await http.delete(Uri.parse('$baseUrl/spare-parts/$id'));

    if(response.statusCode!=200){
      throw Exception('Failed to delete spare part: ${response.statusCode}');
    }
  }
  Future<SparePart> updateSparePart(SparePart sparePart, String partNumber) async{
    final response=await http.put(
      Uri.parse('$baseUrl/spare-parts/${partNumber}'),
      headers: {'Content-Type':'application/json'},
      body: json.encode(sparePart.toJson())
    );
    if(response.statusCode==200){
      return SparePart.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to update spare part: ${response.statusCode}');
    }
  }
}
