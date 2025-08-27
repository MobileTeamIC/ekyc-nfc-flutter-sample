import 'ekyc_config.dart';

/// Predefined configurations for common eKYC use cases
class EkycPresets {
  /// OCR flow (document scanning)
  static EkycConfig ocr({
    String languageSdk = 'icekyc_vi',
    bool isShowTutorial = true,
    bool isEnableGotIt = true,
    String documentType = 'IdentityCard',
  }) {
    return EkycConfig(
      languageSdk: languageSdk,
      isShowTutorial: isShowTutorial,
      isEnableGotIt: isEnableGotIt,
      flowType: 'ocr',
      documentType: documentType,
    );
  }

  /// Face verification flow
  static EkycConfig face({
    String languageSdk = 'icekyc_vi',
    bool isShowTutorial = true,
    bool isEnableGotIt = true,
  }) {
    return EkycConfig(
      languageSdk: languageSdk,
      isShowTutorial: isShowTutorial,
      isEnableGotIt: isEnableGotIt,
      flowType: 'face',
    );
  }

  /// Full eKYC flow (OCR + Face)
  static EkycConfig full({
    String languageSdk = 'icekyc_vi',
    bool isShowTutorial = true,
    bool isEnableGotIt = true,
    String documentType = 'IdentityCard',
  }) {
    return EkycConfig(
      languageSdk: languageSdk,
      isShowTutorial: isShowTutorial,
      isEnableGotIt: isEnableGotIt,
      flowType: 'full',
      documentType: documentType,
    );
  }

  /// QR Code scanning flow
  static EkycConfig scanQr({
    String languageSdk = 'icekyc_vi',
    bool isShowTutorial = true,
    bool isEnableGotIt = true,
  }) {
    return EkycConfig(
      languageSdk: languageSdk,
      isShowTutorial: isShowTutorial,
      isEnableGotIt: isEnableGotIt,
      flowType: 'scanQR',
    );
  }

  /// NFC QR Code flow
  static EkycConfig nfcQrCode({
    String languageSdk = 'icekyc_vi',
    bool isShowTutorial = true,
    bool isEnableGotIt = true,
  }) {
    return EkycConfig(
      languageSdk: languageSdk,
      isShowTutorial: isShowTutorial,
      isEnableGotIt: isEnableGotIt,
      flowType: 'nfcQrCode',
    );
  }

  /// Manual NFC with manual input
  static EkycConfig nfcManual({
    required String idNumber,
    required String birthday,
    required String expiredDate,
    String languageSdk = 'icekyc_vi',
    bool isShowTutorial = true,
    bool isEnableGotIt = true,
  }) {
    return EkycConfig(
      idNumber: idNumber,
      birthday: birthday,
      expiredDate: expiredDate,
      languageSdk: languageSdk,
      isShowTutorial: isShowTutorial,
      isEnableGotIt: isEnableGotIt,
      flowType: 'nfcManual',
    );
  }
}
