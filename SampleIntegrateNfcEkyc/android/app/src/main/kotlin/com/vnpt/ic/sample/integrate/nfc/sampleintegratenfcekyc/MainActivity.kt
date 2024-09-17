package com.vnpt.ic.sample.integrate.nfc.sampleintegratenfcekyc

import android.app.Activity
import android.content.Intent
import android.nfc.NfcManager
import com.vnptit.idg.sdk.activity.VnptIdentityActivity
import com.vnptit.idg.sdk.activity.VnptOcrActivity
import com.vnptit.idg.sdk.activity.VnptPortraitActivity
import com.vnptit.idg.sdk.utils.KeyIntentConstants
import com.vnptit.idg.sdk.utils.KeyResultConstants
import com.vnptit.idg.sdk.utils.SDKEnum
import com.vnptit.nfc.activity.VnptScanNFCActivity
import com.vnptit.nfc.utils.KeyIntentConstantsNFC
import com.vnptit.nfc.utils.KeyResultConstantsNFC
import com.vnptit.nfc.utils.SDKEnumNFC
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
   companion object {
      private const val CHANNEL = "flutter.sdk.ekyc/integrate"
      private const val EKYC_REQUEST_CODE = 100
      private const val ERROR_NFC_CODE = "69"
   }

   private lateinit var channel: MethodChannel
   private lateinit var result: MethodChannel.Result

   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
      super.configureFlutterEngine(flutterEngine)
      channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      channel.setMethodCallHandler(this)
   }

   override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
      super.cleanUpFlutterEngine(flutterEngine)
      channel.setMethodCallHandler(null)
   }

   override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
      this.result = result

      val json = parseJsonFromArgs(call)
      val (intent, checkNfc) = when (call.method) {
         "startEkycFull" -> activity.getIntentEkycFull(json) to false
         "startEkycOcr" -> activity.getIntentEkycOcr(json) to false
         "startEkycFace" -> activity.getIntentEkycFace(json) to false
         "navigateToNfcQrCode" -> navigateToNfcQrCode(json) to true
         "navigateToScanNfc" -> navigateToScanNfc(json) to true
         else -> {
            result.notImplemented()
            null to false
         }
      }

      intent?.let {
         if (checkNfc && !isDeviceSupportedNfc()) {
            result.error(ERROR_NFC_CODE, "Thiết bị không hỗ trợ NFC", null)
            return
         }

         activity.startActivityForResult(it, EKYC_REQUEST_CODE)
      }
   }

   override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
      super.onActivityResult(requestCode, resultCode, data)
      if (requestCode == EKYC_REQUEST_CODE) {
         if (resultCode == Activity.RESULT_OK) {
            if (data != null) {
               /**
                * Dữ liệu bóc tách thông tin OCR
                * [KeyResultConstants.INFO_RESULT]
                */
               val dataInfoResult = data.getStringExtra(KeyResultConstants.INFO_RESULT)

               /**
                * Dữ liệu bóc tách thông tin Liveness card mặt trớc
                * [KeyResultConstants.LIVENESS_CARD_FRONT_RESULT]
                */
               val dataLivenessCardFrontResult =
                  data.getStringExtra(KeyResultConstants.LIVENESS_CARD_FRONT_RESULT)

               /**
                * Dữ liệu bóc tách thông tin liveness card mặt sau
                * [KeyResultConstants.LIVENESS_CARD_REAR_RESULT]
                */
               val dataLivenessCardRearResult =
                  data.getStringExtra(KeyResultConstants.LIVENESS_CARD_REAR_RESULT)

               /**
                * Dữ liệu bóc tách thông tin compare face
                * [KeyResultConstants.COMPARE_RESULT]
                */
               val dataCompareResult = data.getStringExtra(KeyResultConstants.COMPARE_RESULT)

               /**
                * Dữ liệu bóc tách thông tin liveness face
                * [KeyResultConstants.LIVENESS_FACE_RESULT]
                */
               val dataLivenessFaceResult =
                  data.getStringExtra(KeyResultConstants.LIVENESS_FACE_RESULT)

               /**
                * Dữ liệu bóc tách thông tin mask face
                * [KeyResultConstants.MASKED_FACE_RESULT]
                */
               val dataMaskedFaceResult = data.getStringExtra(KeyResultConstants.MASKED_FACE_RESULT)

               /**
                * đường dẫn ảnh mặt trước trong thẻ chip lưu trong cache
                * [KeyResultConstantsNFC.IMAGE_AVATAR_CARD_NFC]
                */
               val avatarPath = data.getStringExtra(KeyResultConstantsNFC.IMAGE_AVATAR_CARD_NFC)

               /**
                * chuỗi thông tin cua SDK
                * [KeyResultConstantsNFC.CLIENT_SESSION_RESULT]
                */
               val clientSession =
                  data.getStringExtra(KeyResultConstantsNFC.CLIENT_SESSION_RESULT)

               /**
                * kết quả NFC
                * [KeyResultConstantsNFC.LOG_NFC]
                */
               val logNFC = data.getStringExtra(KeyResultConstantsNFC.LOG_NFC)

               /**
                * mã hash avatar
                * [KeyResultConstantsNFC.HASH_AVATAR]
                */
               val hashAvatar = data.getStringExtra(KeyResultConstantsNFC.HASH_AVATAR)

               /**
                * chuỗi json string chứa thông tin post code của quê quán
                * [KeyResultConstantsNFC.POST_CODE_ORIGINAL_LOCATION_RESULT]
                */
               val postCodeOriginalLocation =
                  data.getStringExtra(KeyResultConstantsNFC.POST_CODE_ORIGINAL_LOCATION_RESULT)

               /**
                * chuỗi json string chứa thông tin post code của nơi thường trú
                * [KeyResultConstantsNFC.POST_CODE_RECENT_LOCATION_RESULT]
                */
               val postCodeRecentLocation =
                  data.getStringExtra(KeyResultConstantsNFC.POST_CODE_RECENT_LOCATION_RESULT)

               /**
                * time scan nfc
                * [KeyResultConstantsNFC.TIME_SCAN_NFC]
                */
               val timeScanNfc = data.getStringExtra(KeyResultConstantsNFC.TIME_SCAN_NFC)

               /**
                * kết quả check chip căn cước công dân
                * [KeyResultConstantsNFC.CHECK_AUTH_CHIP_RESULT]
                */
               val checkAuthChipResult =
                  data.getStringExtra(KeyResultConstantsNFC.CHECK_AUTH_CHIP_RESULT)

               /**
                * kết quả quét QRCode căn cước công dân
                * [KeyResultConstantsNFC.QR_CODE_RESULT_NFC]
                */
               val qrCodeResult = data.getStringExtra(KeyResultConstantsNFC.QR_CODE_RESULT_NFC)

               result.success(
                  JSONObject().apply {
                     // eKYC
                     putSafe(KeyResultConstants.INFO_RESULT, dataInfoResult)
                     putSafe(KeyResultConstants.LIVENESS_CARD_FRONT_RESULT, dataLivenessCardFrontResult)
                     putSafe(KeyResultConstants.LIVENESS_CARD_REAR_RESULT, dataLivenessCardRearResult)
                     putSafe(KeyResultConstants.COMPARE_RESULT, dataCompareResult)
                     putSafe(KeyResultConstants.LIVENESS_FACE_RESULT, dataLivenessFaceResult)
                     putSafe(KeyResultConstants.MASKED_FACE_RESULT, dataMaskedFaceResult)
                     // NFC
                     putSafe(KeyResultConstantsNFC.IMAGE_AVATAR_CARD_NFC, avatarPath)
                     putSafe(KeyResultConstantsNFC.CLIENT_SESSION_RESULT, clientSession)
                     putSafe(KeyResultConstantsNFC.LOG_NFC, logNFC)
                     putSafe(KeyResultConstantsNFC.HASH_AVATAR, hashAvatar)
                     putSafe(
                        KeyResultConstantsNFC.POST_CODE_ORIGINAL_LOCATION_RESULT,
                        postCodeOriginalLocation
                     )
                     putSafe(
                        KeyResultConstantsNFC.POST_CODE_RECENT_LOCATION_RESULT,
                        postCodeRecentLocation
                     )
                     putSafe(KeyResultConstantsNFC.TIME_SCAN_NFC, timeScanNfc)
                     putSafe(KeyResultConstantsNFC.CHECK_AUTH_CHIP_RESULT, checkAuthChipResult)
                     putSafe(KeyResultConstantsNFC.QR_CODE_RESULT_NFC, qrCodeResult)
                  }.toString()
               )
            }
         }
      }
   }


   // Phương thức thực hiện eKYC luồng đầy đủ bao gồm: Chụp ảnh giấy tờ và chụp ảnh chân dung
   // Bước 1 - chụp ảnh chân dung xa gần
   // Bước 2 - hiển thị kết quả
   private fun Activity.getIntentEkycFace(json: JSONObject): Intent {
      val intent = getBaseIntent(VnptPortraitActivity::class.java, json)

      // Giá trị này xác định phiên bản khi sử dụng Máy ảnh tại bước chụp ảnh chân dung luồng full. Mặc định là Normal ✓
      // - Normal: chụp ảnh chân dung 1 hướng
      // - ADVANCED: chụp ảnh chân dung xa gần
      intent.putExtra(KeyIntentConstants.VERSION_SDK, SDKEnum.VersionSDKEnum.ADVANCED.value)

      // Bật/[Tắt] chức năng So sánh ảnh trong thẻ và ảnh chân dung
      intent.putExtra(KeyIntentConstants.IS_COMPARE_FLOW, false)

      // Bật/Tắt chức năng kiểm tra che mặt
      intent.putExtra(KeyIntentConstants.IS_CHECK_MASKED_FACE, true)

      // Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
      // - NoneCheckFace: Không thực hiện kiểm tra ảnh chân dung chụp trực tiếp hay không
      // - IBeta: Kiểm tra ảnh chân dung chụp trực tiếp hay không iBeta (phiên bản hiện tại)
      // - Standard: Kiểm tra ảnh chân dung chụp trực tiếp hay không Standard (phiên bản mới)
      intent.putExtra(
         KeyIntentConstants.CHECK_LIVENESS_FACE,
         SDKEnum.ModeCheckLiveNessFace.iBETA.value
      )

      return intent
   }


   // Phương thức thực hiện eKYC luồng "Chụp ảnh giấy tờ"
   // Bước 1 - chụp ảnh giấy tờ
   // Bước 2 - hiển thị kết quả
   private fun Activity.getIntentEkycOcr(json: JSONObject): Intent {
      val intent = getBaseIntent(VnptOcrActivity::class.java, json)

      // Giá trị này xác định kiểu giấy tờ để sử dụng:
      // - IdentityCard: Chứng minh thư nhân dân, Căn cước công dân
      // - IDCardChipBased: Căn cước công dân gắn Chip
      // - Passport: Hộ chiếu
      // - DriverLicense: Bằng lái xe
      // - MilitaryIdCard: Chứng minh thư quân đội
      intent.putExtra(
         KeyIntentConstants.DOCUMENT_TYPE,
         SDKEnum.DocumentTypeEnum.IDENTITY_CARD.value
      )

      // Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
      intent.putExtra(KeyIntentConstants.IS_CHECK_LIVENESS_CARD, true)

      // Lựa chọn chế độ kiểm tra ảnh giấy tờ ngay từ SDK
      // - None: Không thực hiện kiểm tra ảnh khi chụp ảnh giấy tờ
      // - Basic: Kiểm tra sau khi chụp ảnh
      // - MediumFlip: Kiểm tra ảnh hợp lệ trước khi chụp (lật giấy tờ thành công → hiển thị nút chụp)
      // - Advance: Kiểm tra ảnh hợp lệ trước khi chụp (hiển thị nút chụp)
      intent.putExtra(
         KeyIntentConstants.TYPE_VALIDATE_DOCUMENT,
         SDKEnum.TypeValidateDocument.Basic.value
      )

      return intent
   }


   // Phương thức thực hiện eKYC luồng đầy đủ bao gồm: Chụp ảnh giấy tờ và chụp ảnh chân dung
   // Bước 1 - chụp ảnh giấy tờ
   // Bước 2 - chụp ảnh chân dung xa gần
   // Bước 3 - hiển thị kết quả
   private fun Activity.getIntentEkycFull(json: JSONObject): Intent {
      val intent = getBaseIntent(VnptIdentityActivity::class.java, json)

      // Giá trị này xác định kiểu giấy tờ để sử dụng:
      // - IDENTITY_CARD: Chứng minh thư nhân dân, Căn cước công dân
      // - IDCardChipBased: Căn cước công dân gắn Chip
      // - Passport: Hộ chiếu
      // - DriverLicense: Bằng lái xe
      // - MilitaryIdCard: Chứng minh thư quân đội
      intent.putExtra(
         KeyIntentConstants.DOCUMENT_TYPE,
         SDKEnum.DocumentTypeEnum.IDENTITY_CARD.value
      )

      // Bật/Tắt chức năng So sánh ảnh trong thẻ và ảnh chân dung
      intent.putExtra(KeyIntentConstants.IS_COMPARE_FLOW, true)

      // Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
      intent.putExtra(KeyIntentConstants.IS_CHECK_LIVENESS_CARD, true)

      // Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
      // - NoneCheckFace: Không thực hiện kiểm tra ảnh chân dung chụp trực tiếp hay không
      // - iBETA: Kiểm tra ảnh chân dung chụp trực tiếp hay không iBeta (phiên bản hiện tại)
      // - Standard: Kiểm tra ảnh chân dung chụp trực tiếp hay không Standard (phiên bản mới)
      intent.putExtra(
         KeyIntentConstants.CHECK_LIVENESS_FACE,
         SDKEnum.ModeCheckLiveNessFace.iBETA.value
      )

      // Bật/Tắt chức năng kiểm tra che mặt
      intent.putExtra(KeyIntentConstants.IS_CHECK_MASKED_FACE, true)

      // Lựa chọn chế độ kiểm tra ảnh giấy tờ ngay từ SDK
      // - None: Không thực hiện kiểm tra ảnh khi chụp ảnh giấy tờ
      // - Basic: Kiểm tra sau khi chụp ảnh
      // - MediumFlip: Kiểm tra ảnh hợp lệ trước khi chụp (lật giấy tờ thành công → hiển thị nút chụp)
      // - Advance: Kiểm tra ảnh hợp lệ trước khi chụp (hiển thị nút chụp)
      intent.putExtra(
         KeyIntentConstants.TYPE_VALIDATE_DOCUMENT,
         SDKEnum.TypeValidateDocument.Advance.value
      )

      // Giá trị này xác định việc có xác thực số ID với mã tỉnh thành, quận huyện, xã phường tương ứng hay không.
      intent.putExtra(KeyIntentConstants.IS_VALIDATE_POSTCODE, true)

      // Giá trị này xác định phiên bản khi sử dụng Máy ảnh tại bước chụp ảnh chân dung luồng full. Mặc định là Normal ✓
      // - Normal: chụp ảnh chân dung 1 hướng
      // - ProOval: chụp ảnh chân dung xa gần
      intent.putExtra(KeyIntentConstants.VERSION_SDK, SDKEnum.VersionSDKEnum.ADVANCED.value)

      return intent
   }

   private fun <T : Activity> Activity.getBaseIntent(clazz: Class<T>, json: JSONObject): Intent {
      val intent = Intent(this, clazz)

      // Nhập thông tin bộ mã truy cập. Lấy tại mục Quản lý Token https://ekyc.vnpt.vn/admin-dashboard/console/project-manager
      intent.putExtra(
         KeyIntentConstants.ACCESS_TOKEN,
         if (json.has("access_token")) json.getString("access_token") else ""
      )
      intent.putExtra(
         KeyIntentConstants.TOKEN_ID,
         if (json.has("token_id")) json.getString("token_id") else ""
      )
      intent.putExtra(
         KeyIntentConstants.TOKEN_KEY,
         if (json.has("token_key")) json.getString("token_key") else ""
      )

      // Giá trị này dùng để đảm bảo mỗi yêu cầu (request) từ phía khách hàng sẽ không bị thay đổi.
      intent.putExtra(KeyIntentConstants.CHALLENGE_CODE, "INNOVATIONCENTER")

      // Ngôn ngữ sử dụng trong SDK
      // - VIETNAMESE: Tiếng Việt
      // - ENGLISH: Tiếng Anh
      intent.putExtra(KeyIntentConstants.LANGUAGE_SDK, SDKEnum.LanguageEnum.VIETNAMESE.value)

      // Bật/Tắt Hiển thị màn hình hướng dẫn
      intent.putExtra(KeyIntentConstants.IS_SHOW_TUTORIAL, true)

      // Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video
      intent.putExtra(KeyIntentConstants.IS_ENABLE_GOT_IT, true)

      // Sử dụng máy ảnh mặt trước
      // - FRONT: Camera trước
      // - BACK: Camera trước
      intent.putExtra(
         KeyIntentConstants.CAMERA_POSITION_FOR_PORTRAIT,
         SDKEnum.CameraTypeEnum.FRONT.value
      )

      return intent
   }

   private fun isDeviceSupportedNfc(): Boolean {
      val adapter = (getSystemService(NFC_SERVICE) as? NfcManager)?.defaultAdapter
      return adapter != null && adapter.isEnabled
   }

   private fun navigateToNfcQrCode(json: JSONObject): Intent {
      return Intent(this, VnptScanNFCActivity::class.java).also {
         /**
          * Truyền access token chứa bearer
          */
         it.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, json.getString("access_token"))
         /**
          * Truyền token id
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_ID, json.getString("token_id"))
         /**
          * Truyền token key
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_KEY, json.getString("token_key"))
         /**
          * điều chỉnh ngôn ngữ tiếng việt
          *    - vi: tiếng việt
          *    - en: tiếng anh
          */
         it.putExtra(KeyIntentConstantsNFC.LANGUAGE_NFC, SDKEnumNFC.LanguageEnum.VIETNAMESE.value)
         /**
          * hiển thị màn hình hướng dẫn + hiển thị nút bỏ qua hướng dẫn
          * - mặc định luôn luôn hiển thị màn hình hướng dẫn
          *    - true: hiển thị nút bỏ qua
          *    - false: ko hiển thị nút bỏ qua
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_GOT_IT, true)
         /**
          * bật tính năng upload ảnh
          *    - true: bật tính năng
          *    - false: tắt tính năng
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_UPLOAD_IMAGE, true)
         /**
          * bật tính năng get Postcode
          *    - true: bật tính năng
          *    - false: tắt tính năng
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_MAPPING_ADDRESS, true)
         /**
          * bật tính năng xác thực chip
          *    - true: bật tính năng
          *    - false: tắt tính năng
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_VERIFY_CHIP, true)
         /**
          * truyền các giá trị đọc thẻ
          *    - nếu không truyền gì mặc định sẽ đọc tất cả (MRZ,Verify Document,Image Avatar)
          *    - giá trị truyền vào là 1 mảng int: nếu muốn đọc giá trị nào sẽ truyền
          *      giá trị đó vào mảng
          * eg: chỉ đọc thông tin MRZ
          *    intArrayOf(SDKEnumNFC.ReadingNFCTags.MRZInfo.value)
          */
         it.putExtra(
            KeyIntentConstantsNFC.READING_TAG_NFC,
            intArrayOf(
               SDKEnumNFC.ReadingNFCTags.MRZInfo.value,
               SDKEnumNFC.ReadingNFCTags.VerifyDocumentInfo.value,
               SDKEnumNFC.ReadingNFCTags.ImageAvatarInfo.value
            )
         )
         /**
          * truyền giá trị bật quét QRCode
          *    - true: tắt quét QRCode
          *    - false: bật quét QRCode
          */
         it.putExtra(KeyIntentConstantsNFC.IS_TURN_OFF_QR_CODE, false)
         // set baseDomain="" => sử dụng mặc định là Product
         it.putExtra(KeyIntentConstantsNFC.CHANGE_BASE_URL_NFC, "")
      }
   }

   private fun navigateToScanNfc(json: JSONObject): Intent {
      return Intent(this, VnptScanNFCActivity::class.java).also {
         /**
          * Truyền access token chứa bearer
          */
         it.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, json.getString("access_token"))
         /**
          * Truyền token id
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_ID, json.getString("token_id"))
         /**
          * Truyền token key
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_KEY, json.getString("token_key"))
         /**
          * điều chỉnh ngôn ngữ tiếng việt
          *    - vi: tiếng việt
          *    - en: tiếng anh
          */
         it.putExtra(KeyIntentConstantsNFC.LANGUAGE_NFC, SDKEnumNFC.LanguageEnum.VIETNAMESE.value)
         /**
          * hiển thị màn hình hướng dẫn + hiển thị nút bỏ qua hướng dẫn
          * - mặc định luôn luôn hiển thị màn hình hướng dẫn
          *    - true: hiển thị nút bỏ qua
          *    - false: ko hiển thị nút bỏ qua
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_GOT_IT, true)
         /**
          * bật tính năng upload ảnh
          *    - true: bật tính năng
          *    - false: tắt tính năng
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_UPLOAD_IMAGE, true)
         /**
          * bật tính năng get Postcode
          *    - true: bật tính năng
          *    - false: tắt tính năng
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_MAPPING_ADDRESS, true)
         /**
          * bật tính năng xác thực chip
          *    - true: bật tính năng
          *    - false: tắt tính năng
          */
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_VERIFY_CHIP, true)
         /**
          * truyền các giá trị đọc thẻ
          *    - nếu không truyền gì mặc định sẽ đọc tất cả (MRZ,Verify Document,Image Avatar)
          *    - giá trị truyền vào là 1 mảng int: nếu muốn đọc giá trị nào sẽ truyền
          *      giá trị đó vào mảng
          * eg: chỉ đọc thông tin MRZ
          *    intArrayOf(SDKEnumNFC.ReadingNFCTags.MRZInfo.value)
          */
         it.putExtra(
            KeyIntentConstantsNFC.READING_TAG_NFC,
            intArrayOf(
               SDKEnumNFC.ReadingNFCTags.MRZInfo.value,
               SDKEnumNFC.ReadingNFCTags.VerifyDocumentInfo.value,
               SDKEnumNFC.ReadingNFCTags.ImageAvatarInfo.value
            )
         )
         /**
          * truyền giá trị bật quét QRCode
          *    - true: tắt quét QRCode
          *    - false: bật quét QRCode
          */
         it.putExtra(KeyIntentConstantsNFC.IS_TURN_OFF_QR_CODE, true)
         // set baseDomain="" => sử dụng mặc định là Product
         it.putExtra(KeyIntentConstantsNFC.CHANGE_BASE_URL_NFC, "")
         // truyền id định danh căn cước công dân
         it.putExtra(KeyIntentConstantsNFC.ID_NUMBER_CARD, json.getString("card_id"))
         // truyền ngày sinh ghi trên căn cước công dân
         it.putExtra(KeyIntentConstantsNFC.BIRTHDAY_CARD, json.getString("card_dob"))
         // truyền ngày hết hạn căn cước công dân
         it.putExtra(KeyIntentConstantsNFC.EXPIRED_CARD, json.getString("card_expire_date"))
      }
   }

   private fun parseJsonFromArgs(call: MethodCall): JSONObject {
      return try {
         @Suppress("UNCHECKED_CAST")
         (JSONObject(call.arguments as Map<String, Any>))
      } catch (e: Exception) {
         JSONObject(mapOf<String, Any>())
      }
   }

   /**
    * put value to [JSONObject] with null-safety
    */
   private fun JSONObject.putSafe(key: String, value: String?) {
      value?.let { put(key, it) }
   }
}
