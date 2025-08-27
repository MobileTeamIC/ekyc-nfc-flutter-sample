import 'dart:convert';
import 'package:flutter/services.dart';

import 'ekyc_config.dart';

/// Main eKYC method channel service
class EkycMethodChannel {
  static const MethodChannel _channel =
      MethodChannel('flutter.sdk.ekyc/integrate');

  const EkycMethodChannel();

  /// OCR flow (startEkycOcr)
  Future<Map<String, dynamic>> startOcr(EkycConfig config) async {
    return _invokeMethod('startEkycOcr', config);
  }

  /// Face verification flow (startEkycFace)
  Future<Map<String, dynamic>> startFace(EkycConfig config) async {
    return _invokeMethod('startEkycFace', config);
  }

  /// Full eKYC flow (startEkycFull)
  Future<Map<String, dynamic>> startFull(EkycConfig config) async {
    return _invokeMethod('startEkycFull', config);
  }

  /// QR Code scanning flow (startEkycScanQr)
  Future<Map<String, dynamic>> startScanQr(EkycConfig config) async {
    return _invokeMethod('startEkycScanQr', config);
  }

  /// NFC QR Code flow (startNfcQrCode)
  Future<Map<String, dynamic>> startNfcQrCode(EkycConfig config) async {
    return _invokeMethod('startNfcQrCode', config);
  }

  /// Manual NFC flow (startNfcNoQr)
  Future<Map<String, dynamic>> startNfcManual(EkycConfig config) async {
    return _invokeMethod('startNfcNoQr', config);
  }

  Future<Map<String, dynamic>> _invokeMethod(
      String methodName, EkycConfig config) async {
    try {
      final dynamic result =
          await _channel.invokeMethod(methodName, config.toMap());

      if (result == null) return {};

      final decoded = jsonDecode(result as String);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to invoke $methodName: ${e.message}',
        details: e.details,
      );
    } catch (e) {
      throw PlatformException(
        code: 'UNKNOWN_ERROR',
        message: 'Unknown error occurred: $e',
      );
    }
  }
}
