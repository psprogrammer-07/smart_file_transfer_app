import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'file_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Default to light mode

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Info Example',
      theme: ThemeData.light(),
      darkTheme:ThemeData.dark(),
      themeMode: _themeMode,
      home: StorageInfoScreen(toggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StorageInfoScreen extends StatefulWidget {
  final void Function(bool) toggleTheme;

  StorageInfoScreen({required this.toggleTheme});

  @override
  _StorageInfoScreenState createState() => _StorageInfoScreenState();
}

class _StorageInfoScreenState extends State<StorageInfoScreen> {
  static const platform = MethodChannel('storage_info');
  Map<String, dynamic> storageInfo = {};


@override
  void initState() {

    super.initState();
    _requestPermissionsAndLoadStorageInfo();
  }

  Future<void> _requestPermissionsAndLoadStorageInfo() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    await getStorageInfo();
  }


  Future<void> getStorageInfo() async {

    try {
      final result = await platform.invokeMethod('getStorageInfo');
      setState(() {
        storageInfo = Map<String, dynamic>.from(result);
        print("Storage Info: $storageInfo");
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FileManagerHome(
      internal_fullspace: storageInfo['internal']?['total'] ?? "",
      internal_usedspace: storageInfo['internal']?['used'] ?? "",
      internal_available: storageInfo['internal']?['available'] ?? "",
      external_available: storageInfo['sdCard']?['available'] ?? "",
      external_fullspace:  storageInfo['sdCard']?['total'] ?? "",  //storageInfo['sdCard']?['total'] ?? ""
      external_usedspace: storageInfo['sdCard']?['used'] ?? "",
      video: storageInfo.keys.map((key) => key.toString()).toList(),
      toggleTheme: widget.toggleTheme,
    );
  }
}



/*Text('Total: ${storageInfo['internal']['total']}'),
Text('Available: ${storageInfo['internal']['available']}'),
Text('Used: ${storageInfo['internal']['used']}'),
SizedBox(height: 20),
Text('SD Card:'),
Text('Total: ${storageInfo['sdCard']['total']}'),
Text('Available: ${storageInfo['sdCard']['available']}'),
Text('Used: ${storageInfo['sdCard']['used']}'),*/