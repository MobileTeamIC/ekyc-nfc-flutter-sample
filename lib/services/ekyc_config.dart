import 'package:flutter/foundation.dart';

/// Configuration class for eKYC SDK parameters
class EkycConfig {
  final String? accessToken;
  final String? tokenId;
  final String? tokenKey;

  final String? accessTokenEKYC;
  final String? tokenIdEKYC;
  final String? tokenKeyEKYC;

  // Optional SDK presentation options
  final String? languageSdk; // "icekyc_vi" | "icekyc_en"
  final bool? isShowTutorial;
  final bool? isEnableGotIt;

  // Manual input requirements for NFC
  final String? idNumber; // 12 digits
  final String? birthday; // yymmdd
  final String? expiredDate; // yymmdd

  // eKYC flow type
  final String?
      flowType; // "ocr", "face", "full", "scanQR", "ocrFront", "ocrBack"
  final String?
      documentType; // "IdentityCard", "IDCardChipBased", "Passport", "DriverLicense", "MilitaryIdCard"

  const EkycConfig({
    this.accessToken,
    this.tokenId,
    this.tokenKey,
    this.accessTokenEKYC,
    this.tokenIdEKYC,
    this.tokenKeyEKYC,
    this.languageSdk,
    this.isShowTutorial,
    this.isEnableGotIt,
    this.idNumber,
    this.birthday,
    this.expiredDate,
    this.flowType,
    this.documentType,
  });

  /// Convert to Map for method channel. Only non-null fields included.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (accessToken != null) {
      map['accessToken'] = accessToken;
    }
    if (tokenId != null) {
      map['tokenId'] = tokenId;
    }
    if (tokenKey != null) {
      map['tokenKey'] = tokenKey;
    }

    if (accessTokenEKYC != null) {
      map['accessTokenEKYC'] = accessTokenEKYC;
    }
    if (tokenIdEKYC != null) {
      map['tokenIdEKYC'] = tokenIdEKYC;
    }
    if (tokenKeyEKYC != null) {
      map['tokenKeyEKYC'] = tokenKeyEKYC;
    }

    if (idNumber != null) {
      map['idNumber'] = idNumber;
    }
    if (birthday != null) {
      map['birthday'] = birthday;
    }
    if (expiredDate != null) {
      map['expiredDate'] = expiredDate;
    }

    if (languageSdk != null) {
      map['languageSdk'] = languageSdk;
    }
    if (isShowTutorial != null) {
      map['isShowTutorial'] = isShowTutorial;
    }
    if (isEnableGotIt != null) {
      map['isEnableGotIt'] = isEnableGotIt;
    }

    if (flowType != null) {
      map['flowType'] = flowType;
    }
    if (documentType != null) {
      map['documentType'] = documentType;
    }

    return map;
  }

  /// Quick validator used by UI before invoking native methods
  bool get hasValidManualInput {
    if (idNumber == null || birthday == null || expiredDate == null) {
      return false;
    }
    return idNumber!.trim().length == 12 &&
        birthday!.trim().length == 6 &&
        expiredDate!.trim().length == 6;
  }

  EkycConfig copyWith({
    String? accessToken,
    String? tokenId,
    String? tokenKey,
    String? accessTokenEKYC,
    String? tokenIdEKYC,
    String? tokenKeyEKYC,
    String? languageSdk,
    bool? isShowTutorial,
    bool? isEnableGotIt,
    String? idNumber,
    String? birthday,
    String? expiredDate,
    String? flowType,
    String? documentType,
  }) {
    return EkycConfig(
      accessToken: accessToken ?? this.accessToken,
      tokenId: tokenId ?? this.tokenId,
      tokenKey: tokenKey ?? this.tokenKey,
      accessTokenEKYC: accessTokenEKYC ?? this.accessTokenEKYC,
      tokenIdEKYC: tokenIdEKYC ?? this.tokenIdEKYC,
      tokenKeyEKYC: tokenKeyEKYC ?? this.tokenKeyEKYC,
      languageSdk: languageSdk ?? this.languageSdk,
      isShowTutorial: isShowTutorial ?? this.isShowTutorial,
      isEnableGotIt: isEnableGotIt ?? this.isEnableGotIt,
      idNumber: idNumber ?? this.idNumber,
      birthday: birthday ?? this.birthday,
      expiredDate: expiredDate ?? this.expiredDate,
      flowType: flowType ?? this.flowType,
      documentType: documentType ?? this.documentType,
    );
  }

  @override
  String toString() => describeIdentity(this);
}
