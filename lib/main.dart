import 'package:collector/pages/pages2/dynamicpage.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/dynamichistorypage.dart';
import 'package:collector/pages/pages2/equipment/spares/spartpartsinputpage.dart';
import 'package:collector/pages/pages2/homepage.dart';
import 'package:collector/pages/pages2/equipment/manuals/dynamicmanualspage.dart';
import 'package:collector/pages/pages2/equipment/parameters/dynamicparameterspage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:collector/pages/pages2/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        final routeName = settings.name;

        // Handle dynamic routes
        if (routeName != null && routeName.startsWith('/')) {
          if (settings.arguments is Map<String, dynamic>) {
            final args = settings.arguments as Map<String, dynamic>;

            // Check if this is a manuals route first
            if (routeName == '/manuals') {
              return MaterialPageRoute(
                  builder: (context) => DynamicManualsPage(
                        equipmentName: args['equipmentName'] as String,
                        processName: args['processName'] as String,
                        subprocessName: args['subprocessName'] as String,
                      ));
            }

            if (routeName == '/history') {
              return MaterialPageRoute(
                  builder: (context) => DynamicHistoryPage(
                        equipmentName: args['equipmentName'] as String,
                        processName: args['processName'] as String,
                        subprocessName: args['subprocessName'] as String,
                      ));
            }

            if (routeName == '/parameters') {
              return MaterialPageRoute(
                  builder: (context) => DynamicParametersPage(
                        equipmentName: args['equipmentName'] as String,
                        processName: args['processName'] as String,
                        subprocessName: args['subprocessName'] as String,
                      ));
            }

            if (routeName == '/spares') {
              return MaterialPageRoute(
                  builder: (context) => EquipmentSparePartsPage(
                        equipmentName: args['equipmentName'] as String,
                        processName: args['processName'] as String,
                        subprocessName: args['subprocessName'] as String,
                      ));
            }

            // Handle the original dynamic routes case
            if (args.containsKey('processName') &&
                args.containsKey('subprocesses')) {
              final processName = args['processName'] as String;
              final subprocesses = args['subprocesses'] as List<String>;
              List<String> subdeltas = [];
              if (args['subDeltas'] != null) {
                subdeltas = (args['subDeltas'] as List)
                    .map((e) => e.toString())
                    .toList();
              }
              return MaterialPageRoute(
                  builder: (context) => DynamicPageLoader(
                        processName: processName,
                        subprocesses: subprocesses,
                        subdeltas: subdeltas,
                      ));
            }
          } else if (settings.arguments is String) {
            final equipmentName = settings.arguments as String;
          }
        }

        // Fallback if route is not found
        return MaterialPageRoute(
          builder: (context) => const LandingPage(username: ''),
        );
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}
