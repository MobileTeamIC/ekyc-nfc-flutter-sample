import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'log_screen.dart';
import 'services/ekyc_method_channel.dart';
import 'services/ekyc_presentation.dart';

class EkycScreen extends StatefulWidget {
  const EkycScreen({super.key});

  @override
  State<EkycScreen> createState() => _EkycScreenState();
}

class _EkycScreenState extends State<EkycScreen> {
  final EkycMethodChannel _ekycService = const EkycMethodChannel();
  late TextEditingController _textIdController;
  late TextEditingController _textDobController;
  late TextEditingController _textExpireController;

  @override
  void initState() {
    _textIdController =
        TextEditingController(text: dotenv.env['ID_NUMBER'] ?? '');
    _textDobController = TextEditingController(text: dotenv.env['DOB'] ?? '');
    _textExpireController =
        TextEditingController(text: dotenv.env['EXPIRE'] ?? '');
    super.initState();
  }

  _navigateToLog(Map<String, dynamic> json) {
    if (json.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LogScreen(json: json),
        ),
      );
    }
  }

  Map<String, dynamic> _parseResult(final Map<String, dynamic> json) {
    // Align with iOS AppDelegate keys
    return {
      'OCR Result': json['OCR_RESULT'],
      'Liveness Card Front': json['LIVENESS_CARD_FRONT_RESULT'],
      'Liveness Card Back': json['LIVENESS_CARD_BACK_RESULT'],
      'Compare Face': json['COMPARE_FACE_RESULT'],
      'Liveness Face': json['LIVENESS_FACE_RESULT'],
      'Masked Face': json['MASKED_FACE_RESULT'],
      'QR Code': json['QR_CODE_RESULT_NFC'],
      'Avatar NFC': json['IMAGE_AVATAR_CARD_NFC'],
      'Hash avatar': json['HASH_AVATAR'],
      'Client session': json['CLIENT_SESSION_RESULT'],
      'Data NFC': json['LOG_NFC'],
      'Postcode original location': json['POST_CODE_ORIGINAL_LOCATION_RESULT'],
      'Postcode recent location': json['POST_CODE_RECENT_LOCATION_RESULT'],
    }..removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty));
  }

  Future<Map<String, dynamic>> _startOcr() async {
    try {
      final config = EkycPresets.ocr();
      final json = await _ekycService.startOcr(config);
      return json.isEmpty ? {} : _parseResult(json);
    } on PlatformException catch (e) {
      _showError(e.message);
      return {};
    }
  }

  Future<Map<String, dynamic>> _startFace() async {
    try {
      final config = EkycPresets.face();
      final json = await _ekycService.startFace(config);
      return json.isEmpty ? {} : _parseResult(json);
    } on PlatformException catch (e) {
      _showError(e.message);
      return {};
    }
  }

  Future<Map<String, dynamic>> _startFull() async {
    try {
      final config = EkycPresets.full();
      final json = await _ekycService.startFull(config);
      return json.isEmpty ? {} : _parseResult(json);
    } on PlatformException catch (e) {
      _showError(e.message);
      return {};
    }
  }

  Future<Map<String, dynamic>> _startScanQr() async {
    try {
      final config = EkycPresets.scanQr();
      final json = await _ekycService.startScanQr(config);
      return json.isEmpty ? {} : _parseResult(json);
    } on PlatformException catch (e) {
      _showError(e.message);
      return {};
    }
  }

  Future<Map<String, dynamic>> _startNfcQrCode() async {
    try {
      final config = EkycPresets.nfcQrCode();
      final json = await _ekycService.startNfcQrCode(config);
      return json.isEmpty ? {} : _parseResult(json);
    } on PlatformException catch (e) {
      _showError(e.message);
      return {};
    }
  }

  Future<Map<String, dynamic>> _startNfcManual() async {
    final id = _textIdController.text.trim();
    final dob = _textDobController.text.trim();
    final exp = _textExpireController.text.trim();

    if (id.isEmpty || dob.isEmpty || exp.isEmpty) {
      _showError(
          'Thiếu thông tin, Vui lòng nhập Số thẻ, Ngày sinh, Ngày hết hạn');
      return {};
    }
    if (id.length != 12 || dob.length != 6 || exp.length != 6) {
      _showError(
          'Định dạng không hợp lệ, Số thẻ 12 số, ngày sinh và hết hạn YYMMDD');
      return {};
    }

    try {
      final config = EkycPresets.nfcManual(
        idNumber: id,
        birthday: dob,
        expiredDate: exp,
      );
      final json = await _ekycService.startNfcManual(config);
      return json.isEmpty ? {} : _parseResult(json);
    } on PlatformException catch (e) {
      _showError(e.message);
      return {};
    }
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Có lỗi xảy ra'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tích hợp SDK VNPT eKYC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),
            const Text('Số căn cước'),
            const SizedBox(height: 8),
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
            const Text('Ngày sinh YYMMDD'),
            const SizedBox(height: 8),
            TextField(
              controller: _textDobController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'yyMMdd, ví dụ: 950614',
                counterText: "",
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ngày hết hạn YYMMDD'),
            const SizedBox(height: 8),
            TextField(
              controller: _textExpireController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'yyMMdd, ví dụ: 950614',
                counterText: "",
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async => _navigateToLog(await _startOcr()),
              child: const Text('Thực hiện OCR giấy tờ'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => _navigateToLog(await _startFace()),
              child: const Text('Thực hiện kiểm tra khuôn mặt'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => _navigateToLog(await _startFull()),
              child: const Text('Thực hiện eKYC đầy đủ'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => _navigateToLog(await _startScanQr()),
              child: const Text('Quét mã QR'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => _navigateToLog(await _startNfcQrCode()),
              child: const Text('Quét QR -> Đọc chip NFC'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async => _navigateToLog(await _startNfcManual()),
              child: const Text('Nhập thông tin -> Đọc NFC'),
            ),
          ],
        ),
      ),
    );
  }
}
