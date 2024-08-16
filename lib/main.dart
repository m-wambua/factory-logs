import 'package:collector/pages/history/maintenance/dynamichistorypage.dart';
import 'package:collector/pages/homepage.dart';
import 'package:collector/pages/manuals/dynamicmanualspage.dart';
import 'package:collector/pages/parameters/dynamicparameterspage.dart';
import 'package:collector/pages/tableloader.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:collector/pages/history/historypage.dart';
import 'package:collector/pages/trends/trendspage.dart';
import 'package:collector/pages/manuals/manuelspage.dart';
import 'package:collector/pages/parameters/parameterspage.dart';
import 'package:collector/pages/welcome_page.dart';

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

            return MaterialPageRoute(
                builder: (context) => DynamicPageLoader(
                    processName: processName, subprocesses: subprocesses));
          } else if (settings.arguments is String) {
            final equipmentName = settings.arguments as String;

            // Handle routes where only a string argument is passed
            switch (routeName) {
              case '/history':
                return MaterialPageRoute(builder: (context) => DynamicHistoryPage(equipmentName: equipmentName,));
              case '/manuals':
                return MaterialPageRoute(builder: (context) => DynamicManualsPage(equipmentName: equipmentName,));
              case '/parameters':
                return MaterialPageRoute(builder: (context) => DynamicParametersPage(equipmentName: equipmentName,));
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

class DynamicPageLoader extends StatefulWidget {
  final String processName;
  final List<String> subprocesses; // Add subprocesses as a parameter

  DynamicPageLoader({
    required this.processName,
    required this.subprocesses, // Initialize subprocesses
  });

  @override
  State<DynamicPageLoader> createState() => _DynamicPageLoaderState();
}

class _DynamicPageLoaderState extends State<DynamicPageLoader> {
  bool _productionSelected = false;
  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  String? _eventDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.processName),
      ),
      body: FutureBuilder<Widget>(
        future: _loadDynamicPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading page'));
          } else {
            return snapshot.data ?? Center(child: Text('Page not found'));
          }
        },
      ),
    );
  }

  Future<Widget> _loadDynamicPage() async {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loaded Page for ${widget.processName}'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chrome_reader_mode),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.cable_outlined)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.power_settings_new)),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Radio Buttons for production selection
              Row(
                children: [
                  Radio(
                      value: true,
                      groupValue: _productionSelected,
                      onChanged: (value) {
                        setState(() {
                          _productionSelected = value!;
                        });
                      }),
                  const Text('Production'),
                  Radio(
                      value: false,
                      groupValue: _productionSelected,
                      onChanged: (value) {
                        setState(() {
                          _productionSelected = value!;
                        });
                      }),
                  const Text('No Production'),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Display subprocess buttons only if production was selected
              if (_productionSelected)
                Column(
                  children: _buildElevatedButtonsForSubprocesses(),
                ),
              if (!_productionSelected)
                Column(
                  children: _buildElevatedButtonsForSubprocessesNoProduction(),
                ),
              const SizedBox(
                height: 100,
              ),
              const Text(
                  ' ODS Occurrence During Shift (Delay Please Indicate time)'),
              TextFormField(
                maxLines: 20,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    filled: true,
                    fillColor: Colors.grey[200]),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      saveButtonClickTime = DateTime.now();
                    });
                  },
                  child: const Text('Save Current Values')),
              if (saveButtonClickTime != null)
                Text('The Data was Saved at$saveButtonClickTime'),
              const SizedBox(
                height: 50,
              ),
              CheckboxListTile(
                  title: const Text(' Was the Shift eventfull'),
                  value: _eventfulShift,
                  onChanged: (value) {
                    setState(() {
                      _eventfulShift = value!;
                    });
                  }),
              if (_eventfulShift)
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Describe the event...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _eventDescription = value;
                    });
                  },
                )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildElevatedButtonsForSubprocesses() {
    return widget.subprocesses.map((subprocess) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _navigateToSubprocess(subprocess);
            },
            child: Text(subprocess),
          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  void _navigateToSubprocess(String subprocess) {
    // Navigate to the specific subprocess page
    print("Navigating to subprocess: $subprocess");
  }

  ///////////////////////////////////////////////////////////////

  List<Widget> _buildElevatedButtonsForSubprocessesNoProduction() {
    return widget.subprocesses.map((subprocess) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _navigateToSubprocessNoProduction(subprocess);
            },
            child: Text(subprocess),
          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  void _navigateToSubprocessNoProduction(String subprocess) {
    // Navigate to the specific subprocess page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TableLoaderPage(subprocessName: subprocess)));
    print("Navigating to subprocess: $subprocess");
  }
}
