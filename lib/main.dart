// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:techne_scanner/helpers/sharedPrefs.dart';
import 'package:techne_scanner/scanner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPrefsUtils prefs = SharedPrefsUtils.getInstance();
  await SharedPrefsUtils.init();

  if (prefs.getData("qr_count") != int) {
    await prefs.saveData("qr_count", 0);
  }
  await Hive.initFlutter();
  await Hive.openBox('qr_data');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Techne Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Techne Drifts Scanner"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Scan'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scanner(),
              ),
            );
          },
        ),
      ),
    );
  }
}
