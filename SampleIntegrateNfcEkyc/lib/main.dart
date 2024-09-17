import 'package:flutter/material.dart';
import 'package:sampleintegratenfcekyc/log_screen.dart';
import 'package:sampleintegratenfcekyc/sdk_ekyc_nfc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EkycNfcApp());
}

class EkycNfcApp extends StatelessWidget {
  const EkycNfcApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const EkycNfcPage(),
    );
  }
}

class EkycNfcPage extends StatefulWidget {
  const EkycNfcPage({super.key});

  @override
  State<EkycNfcPage> createState() => _EkycNfcPageState();
}

class _EkycNfcPageState extends State<EkycNfcPage> {
  late TextEditingController _textIdController;
  late TextEditingController _textDobController;
  late TextEditingController _textExpireController;

  @override
  void initState() {
    _textIdController = TextEditingController();
    _textDobController = TextEditingController();
    _textExpireController = TextEditingController();
    super.initState();
  }

  _showSnackBar(String error) {
    var snackBar = SnackBar(
      content: Text(error),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _startEkyc(MethodEkyc method) async {
    final res = await SDKEkycNfc.instance.startEkyc(method: method);
    if (res.containsKey('error')) {
      _showSnackBar(res['error']);
    } else {
      _navigateToLog(res);
    }
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
        title: const Text(
          'Tích hợp SDK VNPT eKYC NFC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _startEkyc(MethodEkyc.full),
                child: const Text('eKYC luồng đầy đủ'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _startEkyc(MethodEkyc.ocr),
                child: const Text('Thực hiện OCR giấy tờ'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _startEkyc(MethodEkyc.face),
                child: const Text('Thực hiện kiểm tra khuôn mặt'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async {
                  final res = await SDKEkycNfc.instance.startNfcQrCode();
                  if (res.containsKey('error')) {
                    _showSnackBar(res['error']);
                  } else {
                    _navigateToLog(res);
                  }
                },
                child: const Text('Thực hiện quét QR => Đọc chip NFC'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async => _showMyDialog(),
                child: const Text('Thực hiện Đọc chip NFC'),
              ),
            ),
          ),
        ],
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
                final res = await SDKEkycNfc.instance.startScanNfc(
                  cardId: _textIdController.text,
                  cardDob: _textDobController.text,
                  cardExpireDate: _textExpireController.text,
                );
                if (res.containsKey('error')) {
                  _showSnackBar(res['error']);
                } else {
                  _navigateToLog(res, removeDialog: true);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
