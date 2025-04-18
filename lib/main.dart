import 'dart:io';

import 'package:collector/pages/authorization.dart';
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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String ADMIN_USERNAME_KEY = 'admin_factorylogs';
const String ADMIN_PASSWORD_KEY = 'Summerday1998';
const String IS_FIRST_RUN_KEY = 'is_first_run';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isFirstRun = true;
  try {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    final adminConfigFile = File('${directory.path}/admin_config.json');
    isFirstRun = !(await adminConfigFile.exists());
  } catch (e) {
    print("Error checking admin config: $e");
    isFirstRun = true;
  }

  // Create AuthProvider to initialize data
  final authProvider = AuthProvider();

  // Register a shutdown hook for clean app closure if possible
  // Note: This depends on platform capabilities and may not be ideal
  // Consider alternative approaches for production
  WidgetsBinding.instance.addObserver(AppLifecycleObserver(authProvider));

  runApp(MyApp(isFirstRun: isFirstRun, authProvider: authProvider));
  
  await Supabase.initialize(
      url: 'https://jqboxiqvoujgjaxzxtlv.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxYm94aXF2b3VqZ2pheHp4dGx2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1NTY5MDgsImV4cCI6MjA2MDEzMjkwOH0.l5e56UM-3f5uPVY9UG5bV67ya1x_RaMEltDRG7EOBL0');

 
}
class AppLifecycleObserver extends WidgetsBindingObserver {
  final AuthProvider authProvider;

  AppLifecycleObserver(this.authProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      authProvider.recordNormalShutdown();
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;
  final AuthProvider authProvider;
  const MyApp({super.key, required this.isFirstRun, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      
       ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MaterialApp(
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
        home: isFirstRun ? const AdminSetupPage() : const WelcomePage(),
      ),
    );
  }
}

class AdminSetupPage extends StatefulWidget {
  const AdminSetupPage({super.key});

  @override
  _AdminSetupPageState createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initial Admin Setup'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome! Please set up your admin credentials.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 4) {
                    return 'Username must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Admin Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setupAdmin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Complete Setup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setupAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Store admin credentials
      await prefs.setString(ADMIN_USERNAME_KEY, _usernameController.text);
      await prefs.setString(ADMIN_PASSWORD_KEY, _passwordController.text);
      await prefs.setBool(IS_FIRST_RUN_KEY, false);

      // Initialize admin user in AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAdmin(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // Navigate to sign in page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error setting up admin account'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
