import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SDKEkycNfc {
  static final SDKEkycNfc _singleton = SDKEkycNfc._internal();

  static SDKEkycNfc get instance {
    return _singleton;
  }

  SDKEkycNfc._internal();

  Future<Map<String, dynamic>> startEkyc({required MethodEkyc method}) async {
    try {
      final result = await Channels.channel.invokeMethodOnMobile(
        method.name,
        {
          "access_token": "<ACCESS_TOKEN> (including bearer)",
          "token_id": "<TOKEN_ID>",
          "token_key": "<TOKEN_KEY>",
        },
      );

      final Map<String, dynamic> json = jsonDecode(result);

      return json.isEmpty ? {} : json;
    } on PlatformException catch (e) {
      return {"error": e.message ?? ''};
    }
  }

  Future<Map<String, dynamic>> startScanNfc({
    required String cardId,
    required String cardDob,
    required String cardExpireDate,
  }) async {
    try {
      final result = await Channels.channel.invokeMethodOnMobile(
        "navigateToScanNfc",
        {
          "access_token": "<ACCESS_TOKEN> (including bearer)",
          "token_id": "<TOKEN_ID>",
          "token_key": "<TOKEN_KEY>",
          "card_id": cardId.trim(),
          "card_dob": cardDob.trim(),
          "card_expire_date": cardExpireDate.trim(),
        },
      );

      final Map<String, dynamic> json = jsonDecode(result);

      return json.isEmpty ? {} : json;
    } on PlatformException catch (e) {
      return {"error": e.message ?? ''};
    }
  }

  Future<Map<String, dynamic>> startNfcQrCode() async {
    try {
      final result = await Channels.channel.invokeMethodOnMobile(
        'navigateToNfcQrCode',
        {
          "access_token": "<ACCESS_TOKEN> (including bearer)",
          "token_id": "<TOKEN_ID>",
          "token_key": "<TOKEN_KEY>",
        },
      );

      final Map<String, dynamic> json = jsonDecode(result);

      return json.isEmpty ? {} : json;
    } on PlatformException catch (e) {
      return {"error": e.message ?? ''};
    }
  }
}

extension MethodChannelMobile on MethodChannel {
  Future<T?> invokeMethodOnMobile<T>(String method, [dynamic arguments]) {
    if (kIsWeb) {
      return Future.value(null);
    }

    return invokeMethod(method, arguments);
  }
}

enum MethodEkyc { full, ocr, face }

extension MethodEkycExtension on MethodEkyc {
  String get name {
    switch (this) {
      case MethodEkyc.full:
        return 'startEkycFull';
      case MethodEkyc.ocr:
        return 'startEkycOcr';
      case MethodEkyc.face:
        return 'startEkycFace';
    }
  }
}

/// Native channels.
class Channels {
  static const MethodChannel channel =
      MethodChannel('flutter.sdk.ekyc/integrate');
}
