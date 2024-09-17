import UIKit
import Flutter
import ICSdkEKYC
import ICNFCCardReader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var methodChannel: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UIDevice.current.isProximityMonitoringEnabled = false
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "flutter.sdk.ekyc/integrate",
                                           binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            // Handle battery messages.
            self.methodChannel = result
            
            var id = ""
            var dob = ""
            var doe = ""
            
            if let info = call.arguments as? [String: String] {
                //print(self.convertToDictionary(text: info))
                // input key - get from flutter
                ICEKYCSavedData.shared().tokenId = info["token_id"] ?? ""
                ICEKYCSavedData.shared().tokenKey = info["token_key"] ?? ""
                ICEKYCSavedData.shared().authorization = info["access_token"] ?? ""
                
                ICNFCSaveData.shared().sdTokenId = info["token_id"] ?? ""
                ICNFCSaveData.shared().sdTokenKey = info["token_key"] ?? ""
                ICNFCSaveData.shared().sdAuthorization = info["access_token"] ?? ""
                ICNFCSaveData.shared().isPrintLogRequest = true
                
                id = info["card_id"] ?? ""
                dob = info["card_dob"] ?? ""
                doe = info["card_expire_date"] ?? ""
            }
            
            DispatchQueue.main.async {
                if call.method == "startEkycFull" {
                    self.startEkycFull(controller)
                } else if call.method == "startEkycOcr" {
                    self.startEkycOcr(controller)
                } else if call.method == "startEkycFace" {
                    self.startEkycFace(controller)
                } else if call.method == "navigateToNfcQrCode" {
                    self.navigateToNfcQrCode(controller)
                } else if call.method == "navigateToScanNfc" {
                    self.navigateToNfc(controller, id: id, dob: dob, doe: doe)
                }
            }
            
            print("channel.setMethodCallHandler")
            
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Luồng đầy đủ: Ocr + Face
    /// - Parameter controller: root viewcontroller
    func startEkycFull(_ controller: UIViewController) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        camera.cameraDelegate = self
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng:
        /// - IDENTITY_CARD: Chứng minh thư nhân dân, Căn cước công dân
        /// - IDCardChipBased: Căn cước công dân gắn Chip
        /// - Passport: Hộ chiếu
        /// - DriverLicense: Bằng lái xe
        /// - MilitaryIdCard: Chứng minh thư quân đội
        camera.documentType = IdentityCard
        
        /// Luồng đầy đủ
        /// Bước 1 - chụp ảnh giấy tờ
        /// Bước 2 - chụp ảnh chân dung xa gần
        camera.flowType = full
        
        /// xác định xác thực khuôn mặt bằng oval xa gần
        camera.versionSdk = ProOval
        
        /// Bật/Tắt chức năng So sánh ảnh trong thẻ và ảnh chân dung
        camera.isCompareFaces = true
        
        /// Bật/Tắt chức năng kiểm tra che mặt
        camera.isCheckMaskedFace = true
        
        /// Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
        camera.isCheckLivenessCard = true
        
        /// Lựa chọn chế độ kiểm tra ảnh giấy tờ ngay từ SDK
        /// - None: Không thực hiện kiểm tra ảnh khi chụp ảnh giấy tờ
        /// - Basic: Kiểm tra sau khi chụp ảnh
        /// - MediumFlip: Kiểm tra ảnh hợp lệ trước khi chụp (lật giấy tờ thành công → hiển thị nút chụp)
        /// - Advance: Kiểm tra ảnh hợp lệ trước khi chụp (hiển thị nút chụp)
        camera.validateDocumentType = Basic
        
        /// Giá trị này xác định việc có xác thực số ID với mã tỉnh thành, quận huyện, xã phường tương ứng hay không.
        camera.isValidatePostcode = true
        
        /// Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
        /// - NoneCheckFace: Không thực hiện kiểm tra ảnh chân dung chụp trực tiếp hay không
        /// - iBETA: Kiểm tra ảnh chân dung chụp trực tiếp hay không iBeta (phiên bản hiện tại)
        /// - Standard: Kiểm tra ảnh chân dung chụp trực tiếp hay không Standard (phiên bản mới)
        camera.checkLivenessFace = IBeta;
        
        /// Giá trị này dùng để đảm bảo mỗi yêu cầu (request) từ phía khách hàng sẽ không bị thay đổi.
        camera.challengeCode = "INNOVATIONCENTER"
        
        /// Ngôn ngữ sử dụng trong SDK
        /// - vi: Tiếng Việt
        /// - en: Tiếng Anh
        camera.languageSdk = "vi"
        
        /// Bật/Tắt Hiển thị màn hình hướng dẫn
        camera.isShowTutorial = true
        
        /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video
        camera.isEnableGotIt = true
        
        /// Sử dụng máy ảnh mặt trước
        /// - PositionFront: Camera trước
        /// - PositionBack: Camera sau
        camera.cameraPositionForPortrait = PositionFront;
        
        camera.modalTransitionStyle = .coverVertical
        camera.modalPresentationStyle = .fullScreen
        controller.present(camera, animated: true)
    }
    
    
    /// Luồng chỉ thực hiện đọc giấy tờ: Ocr
    /// - Parameter controller: root viewcontroller
    func startEkycOcr(_ controller: UIViewController) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        camera.cameraDelegate = self
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng:
        /// - IDENTITY_CARD: Chứng minh thư nhân dân, Căn cước công dân
        /// - IDCardChipBased: Căn cước công dân gắn Chip
        /// - Passport: Hộ chiếu
        /// - DriverLicense: Bằng lái xe
        /// - MilitaryIdCard: Chứng minh thư quân đội
        camera.documentType = IdentityCard
        
        /// Luồng đầy đủ
        /// Bước 1 - chụp ảnh giấy tờ
        /// Bước 2 - chụp ảnh chân dung xa gần
        camera.flowType = ocr
        
        /// Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
        camera.isCheckLivenessCard = true
        
        /// Lựa chọn chế độ kiểm tra ảnh giấy tờ ngay từ SDK
        /// - None: Không thực hiện kiểm tra ảnh khi chụp ảnh giấy tờ
        /// - Basic: Kiểm tra sau khi chụp ảnh
        /// - MediumFlip: Kiểm tra ảnh hợp lệ trước khi chụp (lật giấy tờ thành công → hiển thị nút chụp)
        /// - Advance: Kiểm tra ảnh hợp lệ trước khi chụp (hiển thị nút chụp)
        camera.validateDocumentType = Basic
        
        /// Giá trị này xác định việc có xác thực số ID với mã tỉnh thành, quận huyện, xã phường tương ứng hay không.
        camera.isValidatePostcode = true
        
        /// Giá trị này dùng để đảm bảo mỗi yêu cầu (request) từ phía khách hàng sẽ không bị thay đổi.
        camera.challengeCode = "INNOVATIONCENTER"
        
        /// Ngôn ngữ sử dụng trong SDK
        /// - vi: Tiếng Việt
        /// - en: Tiếng Anh
        camera.languageSdk = "vi"
        
        /// Bật/Tắt Hiển thị màn hình hướng dẫn
        camera.isShowTutorial = true
        
        /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video
        camera.isEnableGotIt = true
        
        /// Sử dụng máy ảnh mặt trước
        /// - PositionFront: Camera trước
        /// - PositionBack: Camera sau
        camera.cameraPositionForPortrait = PositionFront
        
        camera.modalTransitionStyle = .coverVertical
        camera.modalPresentationStyle = .fullScreen
        controller.present(camera, animated: true)
        
    }
    
    /// Luồng chỉ thực hiện xác thực khuôn mặt
    /// - Parameter controller: root viewcontroller
    func startEkycFace(_ controller: UIViewController) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        camera.cameraDelegate = self
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng:
        /// - IDENTITY_CARD: Chứng minh thư nhân dân, Căn cước công dân
        /// - IDCardChipBased: Căn cước công dân gắn Chip
        /// - Passport: Hộ chiếu
        /// - DriverLicense: Bằng lái xe
        /// - MilitaryIdCard: Chứng minh thư quân đội
        camera.documentType = IdentityCard
        
        /// Luồng đầy đủ
        /// Bước 1 - chụp ảnh giấy tờ
        /// Bước 2 - chụp ảnh chân dung xa gần
        camera.flowType = face
        
        /// xác định xác thực khuôn mặt bằng oval xa gần
        camera.versionSdk = ProOval
        
        /// Bật/Tắt chức năng So sánh ảnh trong thẻ và ảnh chân dung
        camera.isCompareFaces = true
        
        /// Bật/Tắt chức năng kiểm tra che mặt
        camera.isCheckMaskedFace = true
        
        /// Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
        /// - NoneCheckFace: Không thực hiện kiểm tra ảnh chân dung chụp trực tiếp hay không
        /// - iBETA: Kiểm tra ảnh chân dung chụp trực tiếp hay không iBeta (phiên bản hiện tại)
        /// - Standard: Kiểm tra ảnh chân dung chụp trực tiếp hay không Standard (phiên bản mới)
        camera.checkLivenessFace = IBeta
        
        /// Giá trị này dùng để đảm bảo mỗi yêu cầu (request) từ phía khách hàng sẽ không bị thay đổi.
        camera.challengeCode = "INNOVATIONCENTER"
        
        /// Ngôn ngữ sử dụng trong SDK
        /// - vi: Tiếng Việt
        /// - en: Tiếng Anh
        camera.languageSdk = "vi"
        
        /// Bật/Tắt Hiển thị màn hình hướng dẫn
        camera.isShowTutorial = true
        
        /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video
        camera.isEnableGotIt = true
        
        /// Sử dụng máy ảnh mặt trước
        /// - PositionFront: Camera trước
        /// - PositionBack: Camera sau
        camera.cameraPositionForPortrait = PositionFront;
        
        camera.modalTransitionStyle = .coverVertical
        camera.modalPresentationStyle = .fullScreen
        controller.present(camera, animated: true)
    }
    
    func navigateToNfcQrCode(_ controller: UIViewController) {
        // Chức năng đọc thông tin thẻ chip bằng NFC, từ iOS 13.0 trở lên
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            // Đặt giá trị DELEGATE để nhận kết quả trả về
            objICMainNFCReader.icMainNFCDelegate = self
            
            // Hiển thị màn hình trợ giúp
            objICMainNFCReader.isShowTutorial = true
            
            // Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video.
            objICMainNFCReader.isEnableGotIt = true
            
            // Thuộc tính quy định việc đọc thông tin NFC
            // - QRCode: Quét mã QR sau đó đọc thông tin thẻ Chip NFC
            // - NFCReader: Nhập thông tin cho idNumberCard, birthdayCard và expiredDateCard => sau đó đọc thông tin thẻ Chip NFC
            objICMainNFCReader.cardReaderStep = QRCode
            
            // bật chức năng tải ảnh chân dung trong CCCD
            objICMainNFCReader.isEnableUploadAvatarImage = true
            
            // Bật tính năng Matching Postcode.
            objICMainNFCReader.isGetPostcodeMatching = true
            
            // bật tính năng xác thực thẻ.
            objICMainNFCReader.isEnableVerifyChip = true
            
            // Giá trị này được truyền vào để xác định các thông tin cần để đọc. Các phần tử truyền vào là các giá trị của CardReaderValues.
            // Security Object Document (SOD, COM)
            // MRZ Code (DG1)
            // Image Base64 (DG2)
            // Security Data (DG14, DG15)
            // ** Lưu Ý: Nếu không truyền dữ liệu hoặc truyền mảng rỗng cho readingTagsNFC. SDK sẽ đọc hết các thông tin trong thẻ
            objICMainNFCReader.readingTagsNFC = [CardReaderValues.VerifyDocumentInfo.rawValue, CardReaderValues.MRZInfo.rawValue, CardReaderValues.SecurityDataInfo.rawValue]
            
            // Giá trị tên miền chính của SDK
            // Giá trị "" => gọi đến môi trường Product
            objICMainNFCReader.baseDomain = ""
            
            // Giá trị này xác định ngôn ngữ được sử dụng trong SDK.
            // - icnfc_vi: Tiếng Việt
            // - icnfc_en: Tiếng Anh
            objICMainNFCReader.languageSdk = "icekyc_vi"
            
            
            objICMainNFCReader.modalPresentationStyle = .fullScreen
            objICMainNFCReader.modalTransitionStyle = .coverVertical
            
            controller.present(objICMainNFCReader, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func navigateToNfc(_ controller: UIViewController, id: String, dob: String, doe: String) {
        // Chức năng đọc thông tin thẻ chip bằng NFC, từ iOS 13.0 trở lên
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            // Đặt giá trị DELEGATE để nhận kết quả trả về
            objICMainNFCReader.icMainNFCDelegate = self
            
            // Hiển thị màn hình trợ giúp
            objICMainNFCReader.isShowTutorial = true
            
            // Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video.
            objICMainNFCReader.isEnableGotIt = true
            
            // Thuộc tính quy định việc đọc thông tin NFC
            // - QRCode: Quét mã QR sau đó đọc thông tin thẻ Chip NFC
            // - NFCReader: Nhập thông tin cho idNumberCard, birthdayCard và expiredDateCard => sau đó đọc thông tin thẻ Chip NFC
            objICMainNFCReader.cardReaderStep = NFCReader
            // Số giấy tờ căn cước, là dãy số gồm 12 ký tự.
            objICMainNFCReader.idNumberCard = id
            // Ngày sinh của người dùng được in trên Căn cước, có định dạng YYMMDD (ví dụ 18 tháng 5 năm 1978 thì giá trị là 780518).
            objICMainNFCReader.birthdayCard = dob
            // Ngày hết hạn của Căn cước, có định dạng YYMMDD (ví dụ 18 tháng 5 năm 2047 thì giá trị là 470518).
            objICMainNFCReader.expiredDateCard = doe
            
            
            // bật chức năng tải ảnh chân dung trong CCCD
            objICMainNFCReader.isEnableUploadAvatarImage = true
            
            // Bật tính năng Matching Postcode.
            objICMainNFCReader.isGetPostcodeMatching = true
            
            // bật tính năng xác thực thẻ.
            objICMainNFCReader.isEnableVerifyChip = true
            
            // Giá trị này được truyền vào để xác định các thông tin cần để đọc. Các phần tử truyền vào là các giá trị của CardReaderValues.
            // Security Object Document (SOD, COM)
            // MRZ Code (DG1)
            // Image Base64 (DG2)
            // Security Data (DG14, DG15)
            // ** Lưu Ý: Nếu không truyền dữ liệu hoặc truyền mảng rỗng cho readingTagsNFC. SDK sẽ đọc hết các thông tin trong thẻ
            objICMainNFCReader.readingTagsNFC = [CardReaderValues.VerifyDocumentInfo.rawValue, CardReaderValues.MRZInfo.rawValue, CardReaderValues.SecurityDataInfo.rawValue]
            
            // Giá trị tên miền chính của SDK
            // Giá trị "" => gọi đến môi trường Product
            objICMainNFCReader.baseDomain = ""
            
            // Giá trị này xác định ngôn ngữ được sử dụng trong SDK.
            // - icnfc_vi: Tiếng Việt
            // - icnfc_en: Tiếng Anh
            objICMainNFCReader.languageSdk = "icekyc_vi"
            
            
            objICMainNFCReader.modalPresentationStyle = .fullScreen
            objICMainNFCReader.modalTransitionStyle = .coverVertical
            controller.present(objICMainNFCReader, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}


// MARK: - ICEkycCameraDelegate
extension AppDelegate: ICEkycCameraDelegate {
    
    func icEkycGetResult() {
        UIDevice.current.isProximityMonitoringEnabled = false /// tắt cảm biến làm tối màn hình
        let dataInfoResult = ICEKYCSavedData.shared().ocrResult;
        let dataLivenessCardFrontResult = ICEKYCSavedData.shared().livenessCardFrontResult;
        let dataLivenessCardRearResult = ICEKYCSavedData.shared().livenessCardBackResult;
        let dataCompareResult = ICEKYCSavedData.shared().compareFaceResult;
        let dataLivenessFaceResult = ICEKYCSavedData.shared().livenessFaceResult;
        let dataMaskedFaceResult = ICEKYCSavedData.shared().maskedFaceResult;
        
        let dict = [
            "INFO_RESULT": dataInfoResult,
            "LIVENESS_CARD_FRONT_RESULT": dataLivenessCardFrontResult,
            "LIVENESS_CARD_REAR_RESULT": dataLivenessCardRearResult,
            "COMPARE_RESULT": dataCompareResult,
            "LIVENESS_FACE_RESULT": dataLivenessFaceResult,
            "MASKED_FACE_RESULT": dataMaskedFaceResult]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
            self.methodChannel!(jsonString)
            
        } catch {
            print(error.localizedDescription)
            self.methodChannel!(FlutterMethodNotImplemented)
        }
      
    }
    
    func icEkycCameraClosed(with type: ScreenType) {
        UIDevice.current.isProximityMonitoringEnabled = false
        self.methodChannel!(FlutterMethodNotImplemented)
    }
    
}


// MARK: - ICMainNFCReaderDelegate
extension AppDelegate: ICMainNFCReaderDelegate {
    
    func icNFCMainDismissed() {
        print("Close")
        self.methodChannel!(FlutterMethodNotImplemented)
    }
    
    func icNFCCardReaderGetResult() {
        
        // Hiển thị thông tin kết quả QUÉT QR
        print("scanQRCodeResult = \(ICNFCSaveData.shared().scanQRCodeResult)")
        
        // Hiển thị thông tin đọc thẻ chip dạng chi tiết
        print("dataNFCResult = \(ICNFCSaveData.shared().dataNFCResult)")
        
        // Hiển thị thông tin POSTCODE
        print("postcodePlaceOfOriginResult = \(ICNFCSaveData.shared().postcodePlaceOfOriginResult)")
        print("postcodePlaceOfResidenceResult = \(ICNFCSaveData.shared().postcodePlaceOfResidenceResult)")
        
        // Hiển thị thông tin xác thực C06
        print("verifyNFCCardResult = \(ICNFCSaveData.shared().verifyNFCCardResult)")
        
        // Hiển thị thông tin ảnh chân dung đọc từ thẻ
        print("imageAvatar = \(ICNFCSaveData.shared().imageAvatar)")
        print("hashImageAvatar = \(ICNFCSaveData.shared().hashImageAvatar)")
        
        // Hiển thị thông tin Client Session
        print("clientSessionResult = \(ICNFCSaveData.shared().clientSessionResult)")
        
        // Hiển thị thông tin đọc dữ liệu nguyên bản của thẻ CHIP: COM, DG1, DG2, … DG14, DG15
        print("dataGroupsResult = \(ICNFCSaveData.shared().dataGroupsResult)")
        
        var verifyNFCCardResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().verifyNFCCardResult, options: .prettyPrinted)
            verifyNFCCardResult = String(data: jsonData, encoding: .ascii) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var dataNFCResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().dataNFCResult, options: .prettyPrinted)
            dataNFCResult = String(data: jsonData, encoding: .ascii) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var postcodePlaceOfOriginResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().postcodePlaceOfOriginResult, options: .prettyPrinted)
            postcodePlaceOfOriginResult = String(data: jsonData, encoding: .ascii) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var postcodePlaceOfResidenceResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().postcodePlaceOfResidenceResult, options: .prettyPrinted)
            postcodePlaceOfResidenceResult = String(data: jsonData, encoding: .ascii) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        let dict = [
            // Thông tin mã QR
            "QR_CODE_RESULT_NFC": ICNFCSaveData.shared().scanQRCodeResult,
            // Thông tin verify C06
            "CHECK_AUTH_CHIP_RESULT": verifyNFCCardResult,
            // Thông tin ẢNH chân dung
            "IMAGE_AVATAR_CARD_NFC": ICNFCSaveData.shared().pathImageAvatar.absoluteString,
            "HASH_AVATAR": ICNFCSaveData.shared().hashImageAvatar,
            // Thông tin Client Session
            "CLIENT_SESSION_RESULT": ICNFCSaveData.shared().clientSessionResult,
            // Thông tin NFC
            "LOG_NFC": dataNFCResult,
            // Thông tin postcode
            "POST_CODE_ORIGINAL_LOCATION_RESULT": postcodePlaceOfOriginResult,
            "POST_CODE_RECENT_LOCATION_RESULT": postcodePlaceOfResidenceResult
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
            self.methodChannel!(jsonString)
            
        } catch {
            print(error.localizedDescription)
            self.methodChannel!(FlutterMethodNotImplemented)
        }
        
    }
}
