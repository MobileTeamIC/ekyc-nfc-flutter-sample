import UIKit
import Flutter
import ICSdkEKYC
import ICNFCCardReader


@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var methodChannel: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UIDevice.current.isProximityMonitoringEnabled = false
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        // let controller = FlutterViewController()
        // let nav = UINavigationController.init(rootViewController: controller)
        // nav.isNavigationBarHidden = true
        // self.window.rootViewController = nav
        let channel = FlutterMethodChannel(name: "flutter.sdk.ekyc/integrate",
                                           binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            // Handle battery messages.
            DispatchQueue.global(qos: .userInitiated).async {
                self.methodChannel = result
                if let info = call.arguments as? [String: String] {
                    // print(self.convertToDictionary(text: info))
                    // input key - get from flutter
                    if call.method == "startEkycOcr" {
                        self.startEkycOcr(controller, info: info)
                    } else if call.method == "startEkycFace" {
                        self.startEkycFace(controller, info: info)
                    } else if call.method == "startNfcQrCode" {
                        self.navigateToNfcQrCode(controller, info: info)
                    } else {
                        self.navigateToNfc(controller, info: info)
                    }
                }
            }
            
            print("channel.setMethodCallHandler")
            
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    /// Luồng chỉ thực hiện đọc giấy tờ: Ocr
    /// - Parameters:
    ///   - controller: root viewcontroller
    ///   - info: thông tin truyền vào
    func startEkycOcr(_ controller: UIViewController, info: [String: String]) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        /// Đăng ký nhận kết quả
        camera.cameraDelegate = self
        
        /// Nhập thông tin bộ mã truy cập. Lấy tại mục Quản lý Token https://ekyc.vnpt.vn/admin-dashboard/console/project-manager
        camera.accessToken = info["access_token_ekyc"] ?? ""
        camera.tokenId = info["token_id_ekyc"] ?? ""
        camera.tokenKey = info["token_key_ekyc"] ?? ""
        
        /// Thay đổi đường dẫn mặc định
        // camera.changeBaseUrl = ""
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng:
        /// - IDENTITY_CARD: Chứng minh thư nhân dân, Căn cước công dân
        /// - IDCardChipBased: Căn cước công dân gắn Chip
        /// - Passport: Hộ chiếu
        /// - DriverLicense: Bằng lái xe
        /// - MilitaryIdCard: Chứng minh thư quân đội
        camera.documentType = IdentityCard
        
        /// Xác định luồng thực hiện eKYC
        /// Giá trị mặc định là none
        /// - none: không thực hiện luồng nào cả
        /// - full: thực hiện eKYC đầy đủ các bước: chụp giấy tờ và chụp ảnh chân dung
        /// - scanQR: thực hiện quét QR và trả ra kết quả
        /// - ocrFront: thực hiện OCR giấy tờ một bước: chụp mặt trước giấy tờ
        /// - ocrBack: thực hiện OCR giấy tờ một bước: chụp mặt sau giấy tờ
        /// - ocr: thực hiện OCR giấy tờ
        /// - face: thực hiện chụp ảnh Oval xa gần và thực hiện các chức năng tuỳ vào Bật/Tắt: Compare, Verify, Mask, Liveness Face
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
        /// - icekyc_vi: Tiếng Việt
        /// - icekyc_en: Tiếng Anh
        camera.languageSdk = "icekyc_vi"
        
        /// Bật/Tắt Hiển thị màn hình hướng dẫn
        camera.isShowTutorial = true
        
        /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video
        camera.isEnableGotIt = true
        
        /// Sử dụng máy ảnh mặt trước
        /// - PositionFront: Camera trước
        /// - PositionBack: Camera sau
        camera.cameraPositionForPortrait = PositionFront
        
        /// Cho phép quét QRCode
        camera.isEnableScanQRCode = true
        
        DispatchQueue.main.async {
            camera.modalTransitionStyle = .coverVertical
            camera.modalPresentationStyle = .fullScreen
            controller.present(camera, animated: true)
        }
        
    }
    
    /// Luồng chỉ thực hiện xác thực khuôn mặt
    /// - Parameters:
    ///   - controller: root viewcontroller
    ///   - info: thông tin truyền vào
    func startEkycFace(_ controller: UIViewController, info: [String: String]) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        /// Đăng ký nhận kết quả
        camera.cameraDelegate = self
        
        /// Nhập thông tin bộ mã truy cập. Lấy tại mục Quản lý Token https://ekyc.vnpt.vn/admin-dashboard/console/project-manager
        camera.accessToken = info["access_token_ekyc"] ?? ""
        camera.tokenId = info["token_id_ekyc"] ?? ""
        camera.tokenKey = info["token_key_ekyc"] ?? ""
        
        /// Thay đổi đường dẫn mặc định
        // camera.changeBaseUrl = ""
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng:
        /// - IDENTITY_CARD: Chứng minh thư nhân dân, Căn cước công dân
        /// - IDCardChipBased: Căn cước công dân gắn Chip
        /// - Passport: Hộ chiếu
        /// - DriverLicense: Bằng lái xe
        /// - MilitaryIdCard: Chứng minh thư quân đội
        camera.documentType = IdentityCard
        
        /// Xác định luồng thực hiện eKYC
        /// Giá trị mặc định là none
        /// - none: không thực hiện luồng nào cả
        /// - full: thực hiện eKYC đầy đủ các bước: chụp giấy tờ và chụp ảnh chân dung
        /// - scanQR: thực hiện quét QR và trả ra kết quả
        /// - ocrFront: thực hiện OCR giấy tờ một bước: chụp mặt trước giấy tờ
        /// - ocrBack: thực hiện OCR giấy tờ một bước: chụp mặt sau giấy tờ
        /// - ocr: thực hiện OCR giấy tờ
        /// - face: thực hiện chụp ảnh Oval xa gần và thực hiện các chức năng tuỳ vào Bật/Tắt: Compare, Verify, Mask, Liveness Face
        camera.flowType = face
        
        /// xác định xác thực khuôn mặt bằng oval xa gần
        /// - Normal: chụp ảnh chân dung 1 hướng
        /// - ProOval: chụp ảnh chân dung xa gần
        camera.versionSdk = ProOval
        
        /// Bật/Tắt chức năng So sánh ảnh trong thẻ và ảnh chân dung
        camera.isEnableCompare = true
        
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
        /// - icekyc_vi: Tiếng Việt
        /// - icekyc_en: Tiếng Anh
        camera.languageSdk = "icekyc_vi"
        
        /// Bật/Tắt Hiển thị màn hình hướng dẫn
        camera.isShowTutorial = true
        
        /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video
        camera.isEnableGotIt = true
        
        /// Sử dụng máy ảnh mặt trước
        /// - PositionFront: Camera trước
        /// - PositionBack: Camera sau
        camera.cameraPositionForPortrait = PositionFront;
        
        DispatchQueue.main.async {
            camera.modalTransitionStyle = .coverVertical
            camera.modalPresentationStyle = .fullScreen
            controller.present(camera, animated: true)
        }
    }
    
    
    /// Thực hiện quét NFC QR code
    /// - Parameters:
    ///   - controller: root viewcontroller
    ///   - info: thông tin truyền vào
    func navigateToNfcQrCode(_ controller: UIViewController, info: [String: String]) {
        // Chức năng đọc thông tin thẻ chip bằng NFC, từ iOS 13.0 trở lên
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            /// Đặt giá trị DELEGATE để nhận kết quả trả về
            objICMainNFCReader.icMainNFCDelegate = self
            
            /// Nhập thông tin bộ mã truy cập. Lấy tại mục Quản lý Token https://ekyc.vnpt.vn/admin-dashboard/console/project-manager
            objICMainNFCReader.accessToken = info["access_token"] ?? ""
            objICMainNFCReader.tokenId = info["token_id"] ?? ""
            objICMainNFCReader.tokenKey = info["token_key"] ?? ""
            
            objICMainNFCReader.accessTokenEKYC = info["access_token_ekyc"] ?? ""
            objICMainNFCReader.tokenIdEKYC = info["token_id_ekyc"] ?? ""
            objICMainNFCReader.tokenKeyEKYC = info["token_key_ekyc"] ?? ""
            
            /// Hiển thị màn hình trợ giúp
            objICMainNFCReader.isShowTutorial = true
            
            /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video.
            objICMainNFCReader.isEnableGotIt = true
            
            /// Thuộc tính quy định việc đọc thông tin NFC
            /// - QRCode: Hiển thị giao diện quét mã QR sau đó thực hiện đọc thông tin bằng NFC
            /// - MRZCode: Hiển thị giao diện quét mã MRZ sau đó thực hiện đọc thông tin bằng NFC
            /// - NFCReader: Hiển thị giao diện đọc thông tin bằng NFC. Dữ liệu truyền vào là: số ID, ngày sinh, ngày hết hạn
            /// - NFCOutside: Đọc thông tin bằng NFC ngay tại app (không mở giao diện). Dữ liệu truyền vào là: số ID, ngày sinh, ngày hết hạn
            objICMainNFCReader.readerCardMode = QRCode
            
            /// bật chức năng tải ảnh chân dung trong CCCD
            objICMainNFCReader.isEnableUploadImage = true
            
            /// Bật tính năng Matching Postcode
            objICMainNFCReader.isEnablePostcodeMatching = true
            
            /// Giá trị này được truyền vào để xác định các thông tin cần để đọc. Các phần tử truyền vào là các giá trị của CardReaderValues.
            /// Security Object Document (SOD)
            /// MRZ Code (DG1)
            /// Image Base64 (DG2)
            /// Security Data (DG14, DG15)
            /// ** Lưu Ý: Nếu không truyền dữ liệu hoặc truyền mảng rỗng cho readingTagsNFC. SDK sẽ đọc hết các thông tin trong thẻ
            objICMainNFCReader.readingTagsNFC = [CardReaderValues.VerifyDocumentInfo.rawValue,
                                                 CardReaderValues.MRZInfo.rawValue,
                                                 CardReaderValues.SecurityDataInfo.rawValue,
                                                 CardReaderValues.ImageAvatarInfo.rawValue]
            
            /// Giá trị tên miền chính của SDK
            /// Giá trị "" hoặc không cấu hình => gọi đến môi trường Product
            // objICMainNFCReader.baseUrl = ""
            
            /// Giá trị này xác định ngôn ngữ được sử dụng trong SDK.
            /// - icnfc_vi: Tiếng Việt
            /// - icnfc_en: Tiếng Anh
            objICMainNFCReader.languageSdk = "icnfc_vi"
            
            DispatchQueue.main.async {
                objICMainNFCReader.modalPresentationStyle = .fullScreen
                objICMainNFCReader.modalTransitionStyle = .coverVertical
                controller.present(objICMainNFCReader, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
            self.methodChannel!(FlutterMethodNotImplemented)
        }
    }
    
    /// Thực hiện quét NFC không QR (truyền thông tin)
    /// - Parameters:
    ///   - controller: root viewcontroller
    ///   - info: thông tin truyền vào
    func navigateToNfc(_ controller: UIViewController, info: [String: String]) {
        // Chức năng đọc thông tin thẻ chip bằng NFC, từ iOS 13.0 trở lên
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            /// Đặt giá trị DELEGATE để nhận kết quả trả về
            objICMainNFCReader.icMainNFCDelegate = self
            
            /// Nhập thông tin bộ mã truy cập. Lấy tại mục Quản lý Token https://ekyc.vnpt.vn/admin-dashboard/console/project-manager
            objICMainNFCReader.accessToken = info["access_token"] ?? ""
            objICMainNFCReader.tokenId = info["token_id"] ?? ""
            objICMainNFCReader.tokenKey = info["token_key"] ?? ""
            
            objICMainNFCReader.accessTokenEKYC = info["access_token_ekyc"] ?? ""
            objICMainNFCReader.tokenIdEKYC = info["token_id_ekyc"] ?? ""
            objICMainNFCReader.tokenKeyEKYC = info["token_key_ekyc"] ?? ""
            
            
            /// Hiển thị màn hình trợ giúp
            objICMainNFCReader.isShowTutorial = true
            
            /// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video.
            objICMainNFCReader.isEnableGotIt = true
            
            /// Thuộc tính quy định việc đọc thông tin NFC
            /// - QRCode: Hiển thị giao diện quét mã QR sau đó thực hiện đọc thông tin bằng NFC
            /// - MRZCode: Hiển thị giao diện quét mã MRZ sau đó thực hiện đọc thông tin bằng NFC
            /// - NFCReader: Hiển thị giao diện đọc thông tin bằng NFC. Dữ liệu truyền vào là: số ID, ngày sinh, ngày hết hạn
            /// - NFCOutside: Đọc thông tin bằng NFC ngay tại app (không mở giao diện). Dữ liệu truyền vào là: số ID, ngày sinh, ngày hết hạn
            objICMainNFCReader.readerCardMode = NFCReader
            
            /// Số giấy tờ căn cước, là dãy số gồm 12 ký tự.
            objICMainNFCReader.idNumberCard = info["card_id"] ?? ""
            /// Ngày sinh của người dùng được in trên Căn cước, có định dạng YYMMDD (ví dụ 18 tháng 5 năm 1978 thì giá trị là 780518).
            objICMainNFCReader.birthdayCard = info["card_dob"] ?? ""
            /// Ngày hết hạn của Căn cước, có định dạng YYMMDD (ví dụ 18 tháng 5 năm 2047 thì giá trị là 470518). nếu Không thời hạn thì sẽ là 991231
            objICMainNFCReader.expiredDateCard = info["card_expire_date"] ?? ""
            
            /// bật chức năng tải ảnh chân dung trong CCCD
            objICMainNFCReader.isEnableUploadImage = true
            
            /// Bật tính năng Matching Postcode.
            objICMainNFCReader.isEnablePostcodeMatching = true
            
            /// Giá trị này được truyền vào để xác định các thông tin cần để đọc. Các phần tử truyền vào là các giá trị của CardReaderValues.
            /// Security Object Document (SOD)
            /// MRZ Code (DG1)
            /// Image Base64 (DG2)
            /// Security Data (DG14, DG15)
            /// ** Lưu Ý: Nếu không truyền dữ liệu hoặc truyền mảng rỗng cho readingTagsNFC. SDK sẽ đọc hết các thông tin trong thẻ
            objICMainNFCReader.readingTagsNFC = [CardReaderValues.VerifyDocumentInfo.rawValue,
                                                 CardReaderValues.MRZInfo.rawValue,
                                                 CardReaderValues.SecurityDataInfo.rawValue,
                                                 CardReaderValues.ImageAvatarInfo.rawValue]
            
            /// Giá trị tên miền chính của SDK
            /// Giá trị "" hoặc không truyền => gọi đến môi trường Product
            // objICMainNFCReader.baseUrl = ""
            
            /// Giá trị này xác định ngôn ngữ được sử dụng trong SDK.
            /// - icnfc_vi: Tiếng Việt
            /// - icnfc_en: Tiếng Anh
            objICMainNFCReader.languageSdk = "icnfc_vi"
            
            DispatchQueue.main.async {
                objICMainNFCReader.modalPresentationStyle = .fullScreen
                objICMainNFCReader.modalTransitionStyle = .coverVertical
                controller.present(objICMainNFCReader, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
            self.methodChannel!(FlutterMethodNotImplemented)
        }
    }
    
}

extension AppDelegate: ICEkycCameraDelegate {
    
    func icEkycGetResult() {
        UIDevice.current.isProximityMonitoringEnabled = false /// tắt cảm biến làm tối màn hình
        let dataInfoResult = ICEKYCSavedData.shared().ocrResult;
        let dataLivenessCardFrontResult = ICEKYCSavedData.shared().livenessCardFrontResult;
        let dataLivenessCardRearResult = ICEKYCSavedData.shared().livenessCardBackResult;
        let dataCompareResult = ICEKYCSavedData.shared().compareFaceResult;
        let dataLivenessFaceResult = ICEKYCSavedData.shared().livenessFaceResult;
        let dataMaskedFaceResult = ICEKYCSavedData.shared().maskedFaceResult;
        let clientSessionResult = ICEKYCSavedData.shared().clientSessionResult;
        
        let dict = [
            "INFO_RESULT": dataInfoResult,
            "LIVENESS_CARD_FRONT_RESULT": dataLivenessCardFrontResult,
            "LIVENESS_CARD_REAR_RESULT": dataLivenessCardRearResult,
            "COMPARE_RESULT": dataCompareResult,
            "LIVENESS_FACE_RESULT": dataLivenessFaceResult,
            "CLIENT_SESSION_RESULT": clientSessionResult,
            "MASKED_FACE_RESULT": dataMaskedFaceResult]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
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
    
    func icNFCCardReaderGetResult() {
        
        /// Hiển thị thông tin kết quả QUÉT QR
        print("scanQRCodeResult = \(ICNFCSaveData.shared().qrCodeResult)")
        
        /// Hiển thị thông tin đọc thẻ chip dạng chi tiết
        print("dataNFCResult = \(ICNFCSaveData.shared().dataNFCResult)")
        
        /// Hiển thị thông tin POSTCODE
        print("postcodePlaceOfOriginResult = \(ICNFCSaveData.shared().postcodeOriginalLocationResult)")
        print("postcodePlaceOfResidenceResult = \(ICNFCSaveData.shared().postcodeRecentLocationResult)")
        
        /// Hiển thị thông tin ảnh chân dung đọc từ thẻ
        print("imageAvatar = \(ICNFCSaveData.shared().imageAvatar)")
        print("hashImageAvatar = \(ICNFCSaveData.shared().hashImageAvatar)")
        
        /// Hiển thị thông tin Client Session
        print("clientSessionResult = \(ICNFCSaveData.shared().clientSessionResult)")
        
        /// Hiển thị thông tin đọc dữ liệu nguyên bản của thẻ CHIP: COM, DG1, DG2, … DG14, DG15
        print("dataGroupsResult = \(ICNFCSaveData.shared().dataGroupsResult)")
        
        var dataNFCResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().dataNFCResult, options: [])
            dataNFCResult = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var postcodePlaceOfOriginResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().postcodeOriginalLocationResult, options: [])
            postcodePlaceOfOriginResult = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var postcodePlaceOfResidenceResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().postcodeRecentLocationResult, options: [])
            postcodePlaceOfResidenceResult = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        let dict = [
            "QR_CODE_RESULT": ICNFCSaveData.shared().qrCodeResult,
            "HASH_IMAGE_AVATAR": ICNFCSaveData.shared().hashImageAvatar,
            "CLIENT_SESSION_RESULT": ICNFCSaveData.shared().clientSessionResult,
            "DATA_NFC_RESULT": dataNFCResult,
            "POST_CODE_ORIGINAL_LOCATION_RESULT": postcodePlaceOfOriginResult,
            "POST_CODE_RECENT_LOCATION_RESULT": postcodePlaceOfResidenceResult
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            self.methodChannel!(jsonString)
            
        } catch {
            print(error.localizedDescription)
            self.methodChannel!(FlutterMethodNotImplemented)
        }
        
    }
    
    /**
     * Phương thức được gọi khi người dùng chủ động ĐÓNG SDK
     * Nhấn vào phương thức để xem chi tiết chức năng.
     */
    func icNFCMainDismissed(_ lastStep: ICNFCLastStep) {
        print("Close SDK with lastStep = \(lastStep)")
    }
    
    
    /**
     * Phương thức được gọi khi thực hiện đọc thông tin NFC
     * Nhấn vào phương thức để xem chi tiết chức năng.
     */
    func icNFCCardReader(_ state: ICNFCReaderState, progress: Int, error: String) {
        //
    }
    
    
    /**
     * Phương thức được gọi khi Bottom Sheet đọc NFC đã tắt
     * Nhấn vào phương thức để xem chi tiết chức năng.
     */
    func icNFCPopupReaderChipDisappear() {
        //
    }
}
