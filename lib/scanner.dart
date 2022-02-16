// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, empty_constructor_bodies, use_function_type_syntax_for_parameters, unused_field

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:techne_scanner/helpers/sharedPrefs.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final SharedPrefsUtils prefs = SharedPrefsUtils.getInstance();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  late bool _isNotTheSameQR;
  Box box = Hive.box("qr_data");

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int _count = prefs.getData("qr_count");

    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text('Scanned QRs: $_count'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    int _count = prefs.getData("qr_count");
    this.controller = controller;
    controller.scannedDataStream.listen(
      (Barcode scanData) async {
        controller.pauseCamera();
        String data = scanData.code!;
        if (box.values.contains(data)) {
          setState(() {
            _isNotTheSameQR = false;
          });
        } else {
          setState(() {
            _isNotTheSameQR = true;
          });
        }
        if (_count == 0 || _isNotTheSameQR) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Scanned Successfully'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Barcode Type: ${describeEnum(scanData.format)}'),
                      Text('Data: ${scanData.code}'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Ok'),
                    onPressed: () async {
                      box.add(data);
                      _count++;
                      await prefs.saveData("qr_count", _count);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ).then(
            (value) => controller.resumeCamera(),
          );
        } else if (_isNotTheSameQR == false) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'This QR was scanned before!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Barcode Type: ${describeEnum(scanData.format)}'),
                      Text('Data: ${scanData.code}'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Scan again'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ).then(
            (value) => controller.resumeCamera(),
          );
        }
      },
    );
  }
}
