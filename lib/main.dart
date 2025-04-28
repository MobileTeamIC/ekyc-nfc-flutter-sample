import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sampleintegrateekyc/log_screen.dart';

void main() {
  runApp(const SampleIntegrateEkycApp());
}

class SampleIntegrateEkycApp extends StatelessWidget {
  const SampleIntegrateEkycApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integrate eKYC Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Tích hợp SDK VNPT eKYC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MethodChannel _channel;
  late TextEditingController _textIdController;
  late TextEditingController _textDobController;
  late TextEditingController _textExpireController;

  @override
  void initState() {
    super.initState();
    _channel = const MethodChannel('flutter.sdk.ekyc/integrate');
    _textIdController = TextEditingController();
    _textDobController = TextEditingController();
    _textExpireController = TextEditingController();
  }

  Future<Map<String, dynamic>> _startEkycByNameMethod({required String methodName}) async {
    final json = await _channel.invokeMethod(methodName, {
      "access_token": "<ACCESS_TOKEN> including bearer",
      "token_id": "<TOKEN_ID>",
      "token_key": "<TOKEN_KEY>",
      "access_token_ekyc": "<ACCESS_TOKEN> including bearer",
      "token_id_ekyc": "<TOKEN_ID>",
      "token_key_ekyc": "<TOKEN_KEY>",
      "card_id": _textIdController.text.trim(),
      "card_dob": _textDobController.text.trim(),
      "card_expire_date": _textExpireController.text.trim(),
    });
    return jsonDecode(json);
  }

  _navigateToLog(Map<String, dynamic> json, {bool removeDialog = false}) {
    if (json.isNotEmpty) {
      if (removeDialog) {
        Navigator.of(context).pop();
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LogScreen(json: json),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _buildButton(
              title: 'Thực hiện OCR giấy tờ',
              onPressed: () async {
                _navigateToLog(
                    await _startEkycByNameMethod(methodName: "startEkycOcr"));
              },
            ),
            _buildButton(
              title: 'Thực hiện kiểm tra khuôn mặt',
              onPressed: () async {
                _navigateToLog(
                    await _startEkycByNameMethod(methodName: "startEkycFace"));
              },
            ),
            _buildButton(
              title: 'Thực hiện quét NFC QR code',
              onPressed: () async {
                _navigateToLog(
                    await _startEkycByNameMethod(methodName: "startNfcQrCode"));
              },
            ),
            _buildButton(
              title: 'Thực hiện quét NFC không QR',
              onPressed: () async {
                _showMyDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nhập thông tin'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _textIdController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nhập số ID',
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textDobController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nhập ngày sinh',
                    helperText: "* Định dạng: yyMMdd, vd: 950614",
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textExpireController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nhập ngày hết hạn',
                    helperText: "* Định dạng: yyMMdd, vd: 950614",
                    counterText: "",
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
              _navigateToLog(await _startEkycByNameMethod(methodName: "startNfcNoQr"), removeDialog: true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton({required String title, VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(24, 214, 150, 1),
            elevation: 0,
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
