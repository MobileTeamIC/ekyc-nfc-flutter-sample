package com.vnpt.ic.sample.integrate.ekyc.sampleintegrateekyc

import android.app.Activity
import android.content.Intent
import android.nfc.NfcManager
import com.vnptit.idg.sdk.activity.VnptIdentityActivity
import com.vnptit.idg.sdk.activity.VnptOcrActivity
import com.vnptit.idg.sdk.activity.VnptPortraitActivity
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
                Pair(startNfcNoQr(json), NFC_REQUEST_CODE)
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
      val intent = getBaseIntent(VnptIdentityActivity::class.java, json)

      // Cấu hình cho quét QR
      intent.putExtra(KeyIntentConstants.FLOW_TYPE, "scanQR")

      return intent
   }

   private fun <T : Activity> Activity.getBaseIntent(clazz: Class<T>, json: JSONObject): Intent {
      val intent = Intent(this, clazz)

      // Nhập thông tin bộ mã truy cập. Lấy tại mục Quản lý Token https://ekyc.vnpt.vn/admin-dashboard/console/project-manager
      intent.putExtra(
         KeyIntentConstants.ACCESS_TOKEN,
         if (json.has("accessToken")) json.getString("accessToken") else ""
      )
      intent.putExtra(
         KeyIntentConstants.TOKEN_ID,
         if (json.has("tokenId")) json.getString("tokenId") else ""
      )
      intent.putExtra(
         KeyIntentConstants.TOKEN_KEY,
         if (json.has("tokenKey")) json.getString("tokenKey") else ""
      )

      // Giá trị này dùng để đảm bảo mỗi yêu cầu (request) từ phía khách hàng sẽ không bị thay đổi.
      // Mỗi lần gọi API sẽ tạo ra một giá trị mới
      intent.putExtra(KeyIntentConstants.NONCE, System.currentTimeMillis().toString())

      // Giá trị này dùng để xác định thời gian hết hạn của yêu cầu (request).
      // Đơn vị tính bằng giây
      intent.putExtra(KeyIntentConstants.TIMESTAMP, (System.currentTimeMillis() / 1000).toString())

      return intent
   }

   private fun startNfcQrCode(json: JSONObject): Intent {
      val intent = Intent(this, VnptScanNFCActivity::class.java)

      // Cấu hình NFC QR Code
      intent.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, if (json.has("accessToken")) json.getString("accessToken") else "")
      intent.putExtra(KeyIntentConstantsNFC.TOKEN_ID, if (json.has("tokenId")) json.getString("tokenId") else "")
      intent.putExtra(KeyIntentConstantsNFC.TOKEN_KEY, if (json.has("tokenKey")) json.getString("tokenKey") else "")
      intent.putExtra(KeyIntentConstantsNFC.FLOW_TYPE, SDKEnumNFC.FlowTypeEnum.QR_CODE.value)

      return intent
   }

   private fun startNfcNoQr(json: JSONObject): Intent {
      val intent = Intent(this, VnptScanNFCActivity::class.java)

      // Cấu hình NFC Manual
      intent.putExtra(KeyIntentConstantsNFC.ACCESS_TOKEN, if (json.has("accessToken")) json.getString("accessToken") else "")
      intent.putExtra(KeyIntentConstantsNFC.TOKEN_ID, if (json.has("tokenId")) json.getString("tokenId") else "")
      intent.putExtra(KeyIntentConstantsNFC.TOKEN_KEY, if (json.has("tokenKey")) json.getString("tokenKey") else "")
      intent.putExtra(KeyIntentConstantsNFC.FLOW_TYPE, SDKEnumNFC.FlowTypeEnum.NFC_READER.value)
      intent.putExtra(KeyIntentConstantsNFC.ID_NUMBER, if (json.has("idNumber")) json.getString("idNumber") else "")
      intent.putExtra(KeyIntentConstantsNFC.BIRTHDAY, if (json.has("birthday")) json.getString("birthday") else "")
      intent.putExtra(KeyIntentConstantsNFC.EXPIRED_DATE, if (json.has("expiredDate")) json.getString("expiredDate") else "")

      return intent
   }

   private fun isDeviceSupportedNfc(): Boolean {
      val nfcManager = getSystemService(NFC_SERVICE) as NfcManager
      return nfcManager.defaultAdapter != null
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
}