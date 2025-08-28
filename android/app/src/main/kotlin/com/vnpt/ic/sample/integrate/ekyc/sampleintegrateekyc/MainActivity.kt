package com.vnpt.ic.sample.integrate.ekyc.sampleintegrateekyc

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.nfc.NfcManager
import androidx.core.content.ContextCompat.getSystemService
import com.vnpt.ic.sample.integrate.nfc.sampleintegratenfcekyc.KeyArgumentMethodChannel
import com.vnptit.idg.sdk.activity.VnptIdentityActivity
import com.vnptit.idg.sdk.activity.VnptOcrActivity
import com.vnptit.idg.sdk.activity.VnptPortraitActivity
import com.vnptit.idg.sdk.activity.VnptQRCodeActivity
import com.vnptit.idg.sdk.utils.KeyIntentConstants
import com.vnptit.idg.sdk.utils.KeyResultConstants
import com.vnptit.idg.sdk.utils.SDKEnum
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import com.vnptit.nfc.activity.VnptScanNFCActivity
import com.vnptit.nfc.utils.KeyIntentConstantsNFC
import com.vnptit.nfc.utils.KeyResultConstantsNFC
import com.vnptit.nfc.utils.SDKEnumNFC
import io.flutter.embedding.android.FlutterActivity.NFC_SERVICE

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
   companion object {
      private const val CHANNEL = "flutter.sdk.ekyc/integrate"
      private const val EKYC_REQUEST_CODE = 100
      private const val NFC_REQUEST_CODE = 101
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
      val intentPair = when (call.method) {
         "startEkycOcr" -> Pair(getIntentEkycOcr(json), EKYC_REQUEST_CODE)
         "startEkycFace" -> Pair(getIntentEkycFace(json), EKYC_REQUEST_CODE)
         "startEkycFull" -> Pair(getIntentEkycFull(json), EKYC_REQUEST_CODE)
         "startEkycScanQr" -> Pair(getIntentEkycScanQr(json), EKYC_REQUEST_CODE)
         "startNfcQrCode" -> {
            if (isDeviceSupportedNfc()) {
               Pair(startNfcQrCode(json), NFC_REQUEST_CODE)
            } else {
               result.error("NFC", "Device not supported NFC", null)
               null
            }
         }
         "startNfcNoQr" -> {
             if (isDeviceSupportedNfc()) {
                Pair(startNfcNoQr(this, json), NFC_REQUEST_CODE)
             } else {
             result.error("NFC", "Device not supported NFC", null)
             }
             null
         }
         else -> {
            result.notImplemented()
            null
         }
      }
        intentPair?.let {
             startActivityForResult(it.first, it.second)
        }
   }

   override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
      super.onActivityResult(requestCode, resultCode, data)
      if (requestCode == EKYC_REQUEST_CODE) {
         if (resultCode == Activity.RESULT_OK) {
            if (data != null) {
               val json = JSONObject().apply {
                  putSafe(KeyResultConstants.OCR_RESULT, data.getStringExtra(KeyResultConstants.OCR_RESULT))
                  putSafe(KeyResultConstants.LIVENESS_CARD_FRONT_RESULT, data.getStringExtra(KeyResultConstants.LIVENESS_CARD_FRONT_RESULT))
                  putSafe(KeyResultConstants.LIVENESS_CARD_BACK_RESULT, data.getStringExtra(KeyResultConstants.LIVENESS_CARD_BACK_RESULT))
                  putSafe(KeyResultConstants.COMPARE_FACE_RESULT, data.getStringExtra(KeyResultConstants.COMPARE_FACE_RESULT))
                  putSafe(KeyResultConstants.LIVENESS_FACE_RESULT, data.getStringExtra(KeyResultConstants.LIVENESS_FACE_RESULT))
                  putSafe(KeyResultConstants.MASKED_FACE_RESULT, data.getStringExtra(KeyResultConstants.MASKED_FACE_RESULT))
               }
               result.success(json.toString())
            }
         }
      } else if (requestCode == NFC_REQUEST_CODE) {
         if (resultCode == Activity.RESULT_OK) {
            if (data != null) {
               val json = JSONObject().apply {
                  putSafe(KeyResultConstantsNFC.PATH_IMAGE_AVATAR, data.getStringExtra(KeyResultConstantsNFC.PATH_IMAGE_AVATAR))
                  putSafe(KeyResultConstantsNFC.CLIENT_SESSION_RESULT, data.getStringExtra(KeyResultConstantsNFC.CLIENT_SESSION_RESULT))
                  putSafe(KeyResultConstantsNFC.DATA_NFC_RESULT, data.getStringExtra(KeyResultConstantsNFC.DATA_NFC_RESULT))
                  putSafe(KeyResultConstantsNFC.HASH_IMAGE_AVATAR, data.getStringExtra(KeyResultConstantsNFC.HASH_IMAGE_AVATAR))
                  putSafe(
                     KeyResultConstantsNFC.POST_CODE_ORIGINAL_LOCATION_RESULT,
                        data.getStringExtra(KeyResultConstantsNFC.POST_CODE_ORIGINAL_LOCATION_RESULT)
                  )
                  putSafe(
                     KeyResultConstantsNFC.POST_CODE_RECENT_LOCATION_RESULT,
                        data.getStringExtra(KeyResultConstantsNFC.POST_CODE_RECENT_LOCATION_RESULT)
                  )
                  putSafe(KeyResultConstantsNFC.TIME_SCAN_NFC, data.getStringExtra(KeyResultConstantsNFC.TIME_SCAN_NFC))
                  putSafe(KeyResultConstantsNFC.STATUS_CHIP_AUTHENTICATION, data.getStringExtra(KeyResultConstantsNFC.STATUS_CHIP_AUTHENTICATION))
                  putSafe(KeyResultConstantsNFC.STATUS_ACTIVE_AUTHENTICATION, data.getStringExtra(KeyResultConstantsNFC.STATUS_ACTIVE_AUTHENTICATION))
                  putSafe(KeyResultConstantsNFC.QR_CODE_RESULT, data.getStringExtra(KeyResultConstantsNFC.QR_CODE_RESULT))
               }
               result.success(json.toString())
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
      intent.putExtra(KeyIntentConstants.IS_ENABLE_COMPARE, true)

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
         KeyIntentConstants.VALIDATE_DOCUMENT_TYPE,
         SDKEnum.ValidateDocumentType.Basic.value
      )

      return intent
   }

   // Phương thức thực hiện eKYC luồng đầy đủ
   private fun Activity.getIntentEkycFull(json: JSONObject): Intent {
      val intent = getBaseIntent(VnptIdentityActivity::class.java, json)

      // Giá trị này xác định kiểu giấy tờ để sử dụng:
      intent.putExtra(
         KeyIntentConstants.DOCUMENT_TYPE,
         SDKEnum.DocumentTypeEnum.IDENTITY_CARD.value
      )

      // Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
      intent.putExtra(KeyIntentConstants.IS_CHECK_LIVENESS_CARD, true)

      // Bật/[Tắt] chức năng So sánh ảnh trong thẻ và ảnh chân dung
      intent.putExtra(KeyIntentConstants.IS_ENABLE_COMPARE, true)

      // Bật/Tắt chức năng kiểm tra che mặt
      intent.putExtra(KeyIntentConstants.IS_CHECK_MASKED_FACE, true)

      // Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
      intent.putExtra(
         KeyIntentConstants.CHECK_LIVENESS_FACE,
         SDKEnum.ModeCheckLiveNessFace.iBETA.value
      )

      return intent
   }

   // Phương thức thực hiện eKYC luồng quét QR
   private fun Activity.getIntentEkycScanQr(json: JSONObject): Intent {
      val intent = getBaseIntent(VnptQRCodeActivity::class.java, json)
      return intent
   }

   private fun <T : Activity> Activity.getBaseIntent(clazz: Class<T>, json: JSONObject): Intent {
      val intent = Intent(this, clazz)

      // ACCESS_TOKEN
      intent.putExtra(
         KeyIntentConstants.ACCESS_TOKEN,
         if (json.has(KeyArgumentMethodChannel.ACCESS_TOKEN)) json.getString(KeyArgumentMethodChannel.ACCESS_TOKEN) else ""
      )
      intent.putExtra(
         KeyIntentConstants.TOKEN_ID,
         if (json.has(KeyArgumentMethodChannel.TOKEN_ID)) json.getString(KeyArgumentMethodChannel.TOKEN_ID) else ""
      )
      intent.putExtra(
         KeyIntentConstants.TOKEN_KEY,
         if (json.has(KeyArgumentMethodChannel.TOKEN_KEY)) json.getString(KeyArgumentMethodChannel.TOKEN_KEY) else ""
      )

      // Challenge code
      intent.putExtra(KeyIntentConstants.CHALLENGE_CODE, "INNOVATIONCENTER")

      // Ngôn ngữ sử dụng trong SDK
      // - VIETNAMESE: Tiếng Việt
      // - ENGLISH: Tiếng Anh
      intent.putExtra(
         KeyIntentConstants.LANGUAGE_SDK,
         mapLanguage(json.optString("language_sdk")).value
      )

      // is_show_tutorial
      intent.putExtra(KeyIntentConstants.IS_SHOW_TUTORIAL, json.optBoolean("is_show_tutorial", true))

      // is_enable_gotit
      intent.putExtra(KeyIntentConstants.IS_ENABLE_GOT_IT, json.optBoolean("is_enable_gotit", true))

      // is_show_logo
      intent.putExtra(KeyIntentConstants.IS_SHOW_LOGO, json.optBoolean("is_show_logo", true))

      // Camera front for portrait
      intent.putExtra(
         KeyIntentConstants.CAMERA_POSITION_FOR_PORTRAIT,
         SDKEnum.CameraTypeEnum.FRONT.value
      )

      return intent
   }

   private fun startNfcQrCode(json: JSONObject): Intent {
      return Intent(this, VnptScanNFCActivity::class.java).also {
         /**
          * Truyền access token chứa bearer
          */
         it.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, json.optString(KeyArgumentMethodChannel.ACCESS_TOKEN, ""))
         /**
          * Truyền token id
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_ID, json.optString(KeyArgumentMethodChannel.TOKEN_ID, ""))
         /**
          * Truyền token key
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_KEY, json.optString(KeyArgumentMethodChannel.TOKEN_KEY, ""))
         /**
          * Truyền access token ekyc chứa bearer
          */
         it.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN_EKYC, json.optString(KeyArgumentMethodChannel.ACCESS_TOKEN_EKYC, ""))
         /**
          * Truyền token id ekyc
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_ID_EKYC, json.optString(KeyArgumentMethodChannel.TOKEN_ID_EKYC, ""))
         /**
          * Truyền token key ekyc
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_KEY_EKYC, json.optString(KeyArgumentMethodChannel.TOKEN_KEY_EKYC, ""))
         /**
          * điều chỉnh ngôn ngữ tiếng việt
          *    - vi: tiếng việt
          *    - en: tiếng anh
          */
         it.putExtra(KeyIntentConstantsNFC.LANGUAGE_SDK, SDKEnumNFC.LanguageEnum.VIETNAMESE.value)
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
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_POSTCODE_MATCHING, true)
         /**
          * truyền các giá trị đọc thẻ
          *    - nếu không truyền gì mặc định sẽ đọc tất cả (MRZ,Verify Document,Image Avatar)
          *    - giá trị truyền vào là 1 mảng int: nếu muốn đọc giá trị nào sẽ truyền
          *      giá trị đó vào mảng
          * eg: chỉ đọc thông tin MRZ
          *    intArrayOf(SDKEnumNFC.ReadingNFCTags.MRZInfo.value)
          */
         it.putExtra(
            KeyIntentConstantsNFC.READING_TAGS_NFC,
            intArrayOf(
               SDKEnumNFC.ReadingNFCTags.MRZInfo.value,
               SDKEnumNFC.ReadingNFCTags.VerifyDocumentInfo.value,
               SDKEnumNFC.ReadingNFCTags.ImageAvatarInfo.value
            )
         )
         /**
          * set baseDomain="" => sử dụng mặc định là Product của VNPT
          */
         it.putExtra(KeyIntentConstantsNFC.BASE_URL, "")
      }
   }

   private fun startNfcNoQr(ctx: Context, json: JSONObject): Intent {
      return Intent(ctx, VnptScanNFCActivity::class.java).also {
         /**
          * Truyền access token chứa bearer
          */
         it.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, json.optString(KeyArgumentMethodChannel.ACCESS_TOKEN, ""))
         /**
          * Truyền token id
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_ID, json.optString(KeyArgumentMethodChannel.TOKEN_ID, ""))
         /**
          * Truyền token key
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_KEY, json.optString(KeyArgumentMethodChannel.TOKEN_KEY, ""))
         /**
          * Truyền access token ekyc chứa bearer
          */
         it.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN_EKYC, json.optString(KeyArgumentMethodChannel.ACCESS_TOKEN_EKYC, ""))
         /**
          * Truyền token id ekyc
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_ID_EKYC, json.optString(KeyArgumentMethodChannel.TOKEN_ID_EKYC, ""))
         /**
          * Truyền token key ekyc
          */
         it.putExtra(KeyIntentConstantsNFC.TOKEN_KEY_EKYC, json.optString(KeyArgumentMethodChannel.TOKEN_KEY_EKYC, ""))
         /**
          * điều chỉnh ngôn ngữ tiếng việt
          *    - vi: tiếng việt
          *    - en: tiếng anh
          */
         it.putExtra(KeyIntentConstantsNFC.LANGUAGE_SDK, SDKEnumNFC.LanguageEnum.VIETNAMESE.value)
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
         it.putExtra(KeyIntentConstantsNFC.IS_ENABLE_POSTCODE_MATCHING, true)
         /**
          * truyền các giá trị đọc thẻ
          *    - nếu không truyền gì mặc định sẽ đọc tất cả (MRZ,Verify Document,Image Avatar)
          *    - giá trị truyền vào là 1 mảng int: nếu muốn đọc giá trị nào sẽ truyền
          *      giá trị đó vào mảng
          * eg: chỉ đọc thông tin MRZ
          *    intArrayOf(SDKEnumNFC.ReadingNFCTags.MRZInfo.value)
          */
         it.putExtra(
            KeyIntentConstantsNFC.READING_TAGS_NFC,
            intArrayOf(
               SDKEnumNFC.ReadingNFCTags.MRZInfo.value,
               SDKEnumNFC.ReadingNFCTags.VerifyDocumentInfo.value,
               SDKEnumNFC.ReadingNFCTags.ImageAvatarInfo.value
            )
         )
         /**
          * Truyền chế độ đọc thẻ
          */
         it.putExtra(KeyIntentConstantsNFC.READER_CARD_MODE, SDKEnumNFC.ReaderCardMode.NONE.getValue())
         // set baseDomain="" => sử dụng mặc định là Product
         it.putExtra(KeyIntentConstantsNFC.BASE_URL, "")
         // truyền id định danh căn cước công dân
         it.putExtra(KeyIntentConstantsNFC.ID_NUMBER_CARD, json.optString(KeyArgumentMethodChannel.ID_NUMBER, ""))
         // truyền ngày sinh ghi trên căn cước công dân
         it.putExtra(KeyIntentConstantsNFC.BIRTHDAY_CARD, json.optString(KeyArgumentMethodChannel.BIRTHDAY, ""))
         // truyền ngày hết hạn căn cước công dân
         it.putExtra(KeyIntentConstantsNFC.EXPIRED_DATE_CARD, json.optString(KeyArgumentMethodChannel.EXPIRED_DATE, ""))
      }
   }


   private fun isDeviceSupportedNfc(): Boolean {
      val adapter = (getSystemService(NFC_SERVICE) as? NfcManager)?.defaultAdapter
      return adapter != null && adapter.isEnabled
   }

   private fun parseJsonFromArgs(call: MethodCall): JSONObject {
      return JSONObject().apply {
         call.arguments<Map<String, Any>>()?.forEach { (key, value) ->
            put(key, value)
         }
      }
   }

   private fun JSONObject.putSafe(key: String, value: String?) {
      if (!value.isNullOrEmpty()) {
         put(key, value)
      }
   }
   /**
    * put value to [JSONObject] with null-safety
    */
   private fun JSONObject.putSafe(key: String, value: String?, prettify: Boolean = true) {
      value?.let {
         if (prettify) {
            put(key, JsonUtil.prettify(it))
         } else {
            put(key, it)
         }
      }
   }

   // region Mappers from Dart/iOS-friendly strings to Android SDK enums
   private fun mapVersionSdk(value: String?): Int {
      return when (value?.lowercase()) {
         "normal" -> SDKEnum.VersionSDKEnum.STANDARD.value
         "prooval" -> SDKEnum.VersionSDKEnum.ADVANCED.value
         else -> SDKEnum.VersionSDKEnum.STANDARD.value
      }
   }

   private fun mapDocumentType(value: String?): Int {
      return when (value?.lowercase()) {
         "identitycard" -> SDKEnum.DocumentTypeEnum.IDENTITY_CARD.value
         "idcardchipbased" -> SDKEnum.DocumentTypeEnum.IDENTITY_CARD_CHIP.value
         "passport" -> SDKEnum.DocumentTypeEnum.PASSPORT.value
         "driverlicense" -> SDKEnum.DocumentTypeEnum.DRIVER_LICENSE.value
         "militaryidcard" -> SDKEnum.DocumentTypeEnum.MILITARY_CARD.value
         else -> SDKEnum.DocumentTypeEnum.IDENTITY_CARD.value
      }
   }

   private fun mapValidateDocument(value: String?): Int {
      return when (value?.lowercase()) {
         "none" -> SDKEnum.ValidateDocumentType.None.value
         "basic" -> SDKEnum.ValidateDocumentType.Basic.value
         "medium" -> SDKEnum.ValidateDocumentType.Medium.value
         "advance" -> SDKEnum.ValidateDocumentType.Advance.value
         else -> SDKEnum.ValidateDocumentType.Basic.value
      }
   }

   private fun mapLivenessFace(value: String?): Int {
      return when (value?.lowercase()) {
         "nonecheckface" -> SDKEnum.ModeCheckLiveNessFace.NONE.value
         "ibeta" -> SDKEnum.ModeCheckLiveNessFace.iBETA.value
         "standard" -> SDKEnum.ModeCheckLiveNessFace.STANDARD.value
         else -> SDKEnum.ModeCheckLiveNessFace.NONE.value
      }
   }

   private fun mapLanguage(value: String?): SDKEnum.LanguageEnum {
      return when (value?.lowercase()) {
         "icekyc_en" -> SDKEnum.LanguageEnum.ENGLISH
         else -> SDKEnum.LanguageEnum.VIETNAMESE
      }
   }

}