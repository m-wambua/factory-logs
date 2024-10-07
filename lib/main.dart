import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/dynamicpage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/history/maintenance/dynamichistorypage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/spartpartsinputpage.dart';
import 'package:collector/pages/welcomePage/homepage/homepage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/manuals/dynamicmanualspage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/parameters/dynamicparameterspage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/datafortables/tableloader.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/history/historypage.dart';
import 'package:collector/pages/trends/trendspage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/manuals/manuelspage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/parameters/parameterspage.dart';
import 'package:collector/pages/welcomePage/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  runApp(MyApp());
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
            final processName = args['processName'] as String;
            final subprocesses = args['subprocesses'] as List<String>;
            List<String> subdeltas = [];
            if (args['subDeltas'] != null) {
              subdeltas =
                  (args['subDeltas'] as List).map((e) => e.toString()).toList();
            }
            return MaterialPageRoute(
                builder: (context) => DynamicPageLoader(
                      processName: processName,
                      subprocesses: subprocesses,
                      subdeltas: subdeltas,
                    ));
          } else if (settings.arguments is String) {
            final equipmentName = settings.arguments as String;

            // Handle routes where only a string argument is passed
            switch (routeName) {
              case '/history':
                return MaterialPageRoute(
                    builder: (context) => DynamicHistoryPage(
                          equipmentName: equipmentName,
                        ));
              case '/manuals':
                return MaterialPageRoute(
                    builder: (context) => DynamicManualsPage(
                          equipmentName: equipmentName,
                        ));
              case '/parameters':
                return MaterialPageRoute(
                    builder: (context) => DynamicParametersPage(
                          equipmentName: equipmentName,
                        ));
              case '/spares':
                return MaterialPageRoute(
                    builder: (context) =>
                        EquipmentSparePartsPage(equipmentName: equipmentName));
            }
          }
        }
        // Handle static routes
        final routes = {
          '/history': (context) => const HistoryPage(),
          '/trends': (context) => const TrendsPage(),
          '/manuals': (context) => ManualsPage(),
          '/parameters': (context) => ParameterPage(),
        };

        if (routes.containsKey(routeName)) {
          return MaterialPageRoute(builder: routes[routeName]!);
        }

        // Fallback if route is not found
        return MaterialPageRoute(
          builder: (context) => const LandingPage(username: ''),
        );
      },

      // Handle static routes

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
