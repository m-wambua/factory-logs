import 'package:collector/pages/tableloader.dart';
import 'package:flutter/material.dart';

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
  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  bool _productionSelected = false;

  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  String? _eventDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.processName),
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
