import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = 'Hey there!';
  bool isUrl = false;

  Future _scanQR() async {
    try {
      final qrResult = await BarcodeScanner.scan();
      print(qrResult.type);
      print(qrResult.format);
      print(qrResult.formatNote);
      print(qrResult.rawContent);
      if (qrResult.type == ResultType.Cancelled) {
        setState(() {
          result = "Scan the QR code and Get Information";
          isUrl = false;
        });
      } else if (qrResult.type == ResultType.Error) {
        setState(() {
          result = "Error Occured ${qrResult.rawContent}";
          isUrl = false;
        });
      } else {
        setState(() {
          result = qrResult.rawContent;
          isUrl = true;
        });
      }
    } on PlatformException catch (error) {
      if (error.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result = 'Camera Permission Denied';
          isUrl = false;
        });
      } else {
        setState(() {
          result = 'Unknown Error $error';
          isUrl = false;
        });
      }
    } on FormatException {
      setState(() {
        result = 'Please scan the QR';
        isUrl = false;
      });
    } catch (error) {
      setState(() {
        result = 'Unknown Error $error';
        isUrl = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
      ),
      body: Center(
        child: InkWell(
          onTap: () async {
            if (isUrl) {
              try {
                if (await canLaunch(result)) {
                  await launch(result);
                } else {
                  throw 'error';
                }
              } catch (error) {
                setState(() {
                  result = 'Could not launch $result';
                  isUrl = false;
                });
              }
            }
          },
          child: Text(
            result,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUrl ? Colors.lightBlueAccent : Colors.black,
              decoration: isUrl ? TextDecoration.underline : null,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQR,
        icon: Icon(Icons.camera),
        label: Text('scan'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
