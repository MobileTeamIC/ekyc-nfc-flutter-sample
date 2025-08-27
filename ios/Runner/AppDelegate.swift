import UIKit
import Flutter
import ICSdkEKYC
import ICNFCCardReader

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var methodChannel: FlutterResult?

    let channelName = "flutter.sdk.ekyc/integrate"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        self.setupMethodChannel()

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupMethodChannel() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: channelName,
                                           binaryMessenger: controller.binaryMessenger)
           
           channel.setMethodCallHandler({
               [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
               guard let self = self else { return }
               self.methodChannel = result
               
               guard let args = call.arguments as? [String: Any] else { return }
               switch call.method {
               case "startEkycOcr":
                   self.startEkycOcr(controller, args: args)
               case "startEkycFace":
                   self.startEkycFace(controller, args: args)
               case "startEkycFull":
                   self.startEkycFull(controller, args: args)
               case "startEkycScanQr":
                   self.startEkycScanQr(controller, args: args)
               case "startNfcQrCode":
                   self.startNfcQrCode(controller, args: args)
               case "startNfcNoQr":
                   self.startNfcNoQr(controller, args: args)
               default:
                   break
               }
           })
       }
    
    //MARK: - eKYC OCR
    private func startEkycOcr(_ controller: UIViewController, args: [String: Any]) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        /// Đăng ký nhận kết quả
        camera.cameraDelegate = self
        
        /// Nhập thông tin bộ mã truy cập
        camera.accessToken = args["accessTokenEKYC"] as? String ?? ""
        camera.tokenId = args["tokenIdEKYC"] as? String ?? ""
        camera.tokenKey = args["tokenKeyEKYC"] as? String ?? ""
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng
        camera.documentType = IdentityCard
        
        /// Xác định luồng thực hiện eKYC
        camera.flowType = ocr
        
        /// Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
        camera.isCheckLivenessCard = true
        
        /// Lựa chọn chế độ kiểm tra ảnh giấy tờ
        camera.validateDocumentType = Basic
        
        camera.modalPresentationStyle = .fullScreen
        camera.modalTransitionStyle = .coverVertical
        controller.present(camera, animated: true, completion: nil)
    }
    
    //MARK: - eKYC Face
    private func startEkycFace(_ controller: UIViewController, args: [String: Any]) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        /// Đăng ký nhận kết quả
        camera.cameraDelegate = self
        
        /// Nhập thông tin bộ mã truy cập
        camera.accessToken = args["accessTokenEKYC"] as? String ?? ""
        camera.tokenId = args["tokenIdEKYC"] as? String ?? ""
        camera.tokenKey = args["tokenKeyEKYC"] as? String ?? ""
        
        /// Xác định luồng thực hiện eKYC
        camera.flowType = face
        
        /// Bật/[Tắt] chức năng So sánh ảnh trong thẻ và ảnh chân dung
        camera.isEnableCompare = true
        
        /// Bật/Tắt chức năng kiểm tra che mặt
        camera.isCheckMaskedFace = true
        
        /// Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
        camera.checkLivenessFace = IBeta
        
        camera.modalPresentationStyle = .fullScreen
        camera.modalTransitionStyle = .coverVertical
        controller.present(camera, animated: true, completion: nil)
    }
    
    //MARK: - eKYC Full
    private func startEkycFull(_ controller: UIViewController, args: [String: Any]) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        /// Đăng ký nhận kết quả
        camera.cameraDelegate = self
        
        /// Nhập thông tin bộ mã truy cập
        camera.accessToken = args["accessTokenEKYC"] as? String ?? ""
        camera.tokenId = args["tokenIdEKYC"] as? String ?? ""
        camera.tokenKey = args["tokenKeyEKYC"] as? String ?? ""
        
        /// Giá trị này xác định kiểu giấy tờ để sử dụng
        camera.documentType = IdentityCard
        
        /// Xác định luồng thực hiện eKYC
        camera.flowType = full
        
        /// Bật/Tắt chức năng kiểm tra ảnh giấy tờ chụp trực tiếp (liveness card)
        camera.isCheckLivenessCard = true
        
        /// Bật/[Tắt] chức năng So sánh ảnh trong thẻ và ảnh chân dung
        camera.isEnableCompare = true
        
        /// Bật/Tắt chức năng kiểm tra che mặt
        camera.isCheckMaskedFace = true
        
        /// Lựa chọn chức năng kiểm tra ảnh chân dung chụp trực tiếp (liveness face)
        camera.checkLivenessFace = IBeta
        
        camera.modalPresentationStyle = .fullScreen
        camera.modalTransitionStyle = .coverVertical
        controller.present(camera, animated: true, completion: nil)
    }
    
    //MARK: - eKYC Scan QR
    private func startEkycScanQr(_ controller: UIViewController, args: [String: Any]) {
        let camera = ICEkycCameraRouter.createModule() as! ICEkycCameraViewController
        
        /// Đăng ký nhận kết quả
        camera.cameraDelegate = self
        
        /// Nhập thông tin bộ mã truy cập
        camera.accessToken = args["accessTokenEKYC"] as? String ?? ""
        camera.tokenId = args["tokenIdEKYC"] as? String ?? ""
        camera.tokenKey = args["tokenKeyEKYC"] as? String ?? ""
        
        /// Xác định luồng thực hiện eKYC
        camera.flowType = scanQR
        
        camera.modalPresentationStyle = .fullScreen
        camera.modalTransitionStyle = .coverVertical
        controller.present(camera, animated: true, completion: nil)
    }
    
    //MARK: - NFC QR Code
    private func startNfcQrCode(_ controller: UIViewController, args: [String: Any]) {
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            let accessToken = args["accessToken"] as? String ?? ""
            let tokenId = args["tokenId"] as? String ?? ""
            let tokenKey = args["tokenKey"] as? String ?? ""
            let accessTokenEKYC = args["accessTokenEKYC"] as? String ?? ""
            let tokenIdEKYC = args["tokenIdEKYC"] as? String ?? ""
            let tokenKeyEKYC = args["tokenKeyEKYC"] as? String ?? ""

            let languageSdk = args["languageSdk"] as? String ?? "icekyc_vi"
            let isShowTutorial = args["isShowTutorial"] as? Bool ?? false
            let isEnableGotIt = args["isEnableGotIt"] as? Bool ?? false

            // Mã bảo mật khi thực hiện sử dụng dịch vụ NFC
            objICMainNFCReader.accessToken = accessToken
            objICMainNFCReader.tokenId = tokenId
            objICMainNFCReader.tokenKey = tokenKey

            // Mã bảo mật khi thực hiện sử dụng dịch vụ eKYC
            objICMainNFCReader.accessTokenEKYC = accessTokenEKYC
            objICMainNFCReader.tokenIdEKYC = tokenIdEKYC
            objICMainNFCReader.tokenKeyEKYC = tokenKeyEKYC

            /*========== CÁC THUỘC TÍNH CHÍNH ==========*/
            
            // Đặt giá trị DELEGATE để nhận kết quả trả về
            objICMainNFCReader.icMainNFCDelegate = self
            
            // Giá trị này xác định ngôn ngữ được sử dụng trong SDK
            objICMainNFCReader.languageSdk = languageSdk
            
            // Giá trị này xác định việc có hiển thị màn hình trợ giúp hay không
            objICMainNFCReader.isShowTutorial = isShowTutorial
            
            // Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn"
            objICMainNFCReader.isEnableGotIt = isEnableGotIt
            
            // Thuộc tính quy định việc đọc thông tin NFC
            objICMainNFCReader.readerCardMode = QRCode
            
            // bật chức năng tải ảnh chân dung trong CCCD để lấy mã ảnh
            objICMainNFCReader.isEnableUploadImage = true
            
            // Bật tính năng Matching Postcode, để lấy thông tin mã khu vực
            objICMainNFCReader.isEnablePostcodeMatching = false
            
            // Giá trị này được truyền vào để xác định nhiều luồng giao dịch trong một phiên
            objICMainNFCReader.inputClientSession = ""
            
            // Giá trị này được truyền vào để xác định các thông tin cần để đọc
            let tagsNFC = [CardReaderValues.VerifyDocumentInfo.rawValue, CardReaderValues.MRZInfo.rawValue, CardReaderValues.ImageAvatarInfo.rawValue, CardReaderValues.SecurityDataInfo.rawValue]
            objICMainNFCReader.readingTagsNFC = tagsNFC
            
            objICMainNFCReader.modalPresentationStyle = .fullScreen
            objICMainNFCReader.modalTransitionStyle = .coverVertical
            
            controller.present(objICMainNFCReader, animated: true, completion: nil)
        } else {
            debugPrint("Fallback on earlier versions")
        }
    }
    
    //MARK: - NFC Manual
    private func startNfcNoQr(_ controller: UIViewController, args: [String: Any]) {
        let accessToken = args["accessToken"] as? String ?? ""
        let tokenId = args["tokenId"] as? String ?? ""
        let tokenKey = args["tokenKey"] as? String ?? ""
        let accessTokenEKYC = args["accessTokenEKYC"] as? String ?? ""
        let tokenIdEKYC = args["tokenIdEKYC"] as? String ?? ""
        let tokenKeyEKYC = args["tokenKeyEKYC"] as? String ?? ""

        let idNumber = args["idNumber"] as? String ?? ""
        let birthday = args["birthday"] as? String ?? ""
        let expiredDate = args["expiredDate"] as? String ?? ""

        let languageSdk = args["languageSdk"] as? String ?? "icekyc_vi"
        let isShowTutorial = args["isShowTutorial"] as? Bool ?? false
        let isEnableGotIt = args["isEnableGotIt"] as? Bool ?? false

        
        if idNumber == "" || idNumber.count != 12 || birthday == "" || birthday.count != 6 || expiredDate == "" || expiredDate.count != 6 {
            debugPrint("Bạn cần nhập thông tin Số thẻ (12 số), ngày sinh hoặc ngày hết hạn")
            return
        }

        
        // Chức năng đọc thông tin thẻ chip bằng NFC, từ iOS 13.0 trở lên
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            // Mã bảo mật khi thực hiện sử dụng dịch vụ NFC
            objICMainNFCReader.accessToken = accessToken
            objICMainNFCReader.tokenId = tokenId
            objICMainNFCReader.tokenKey = tokenKey

            // Mã bảo mật khi thực hiện sử dụng dịch vụ eKYC
            objICMainNFCReader.accessTokenEKYC = accessTokenEKYC
            objICMainNFCReader.tokenIdEKYC = tokenIdEKYC
            objICMainNFCReader.tokenKeyEKYC = tokenKeyEKYC
            
            /*========== CÁC THUỘC TÍNH CHÍNH ==========*/
            
            // Đặt giá trị DELEGATE để nhận kết quả trả về
            objICMainNFCReader.icMainNFCDelegate = self
            
            // Giá trị này xác định ngôn ngữ được sử dụng trong SDK
            objICMainNFCReader.languageSdk = languageSdk
            
            // Giá trị này xác định việc có hiển thị màn hình trợ giúp hay không
            objICMainNFCReader.isShowTutorial = isShowTutorial
            
            // Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn"
            objICMainNFCReader.isEnableGotIt = isEnableGotIt
            
            // Thuộc tính quy định việc đọc thông tin NFC
            objICMainNFCReader.readerCardMode = NFCReader
            
            // Số giấy tờ căn cước, là dãy số gồm 12 ký tự
            objICMainNFCReader.idNumberCard = idNumber
            // Ngày sinh trên Căn cước, có định dạng YYMMDD
            objICMainNFCReader.birthdayCard = birthday
            // Ngày hết hạn của Căn cước, có định dạng YYMMDD
            objICMainNFCReader.expiredDateCard = expiredDate
            
            // bật chức năng tải ảnh chân dung trong CCCD để lấy mã ảnh
            objICMainNFCReader.isEnableUploadImage = true
            
            // Bật tính năng Matching Postcode, để lấy thông tin mã khu vực
            objICMainNFCReader.isEnablePostcodeMatching = false
            
            // Giá trị này được truyền vào để xác định nhiều luồng giao dịch trong một phiên
            objICMainNFCReader.inputClientSession = ""
            
            // Giá trị này được truyền vào để xác định các thông tin cần để đọc
            let tagsNFC = [CardReaderValues.VerifyDocumentInfo.rawValue, CardReaderValues.MRZInfo.rawValue, CardReaderValues.ImageAvatarInfo.rawValue, CardReaderValues.SecurityDataInfo.rawValue]
            objICMainNFCReader.readingTagsNFC = tagsNFC
            
            objICMainNFCReader.modalPresentationStyle = .fullScreen
            objICMainNFCReader.modalTransitionStyle = .coverVertical
            controller.present(objICMainNFCReader, animated: true, completion: nil)
        } else {
            debugPrint("Fallback on earlier versions")
        }
    }
    
}

extension AppDelegate: ICEkycCameraDelegate {
    
    func icekycCameraDismissed() {
        print("Close eKYC Camera")
        self.methodChannel!(FlutterMethodNotImplemented)
    }
    
    func icEkycGetResult() {
        let dict = [
            // Thông tin OCR
            "OCR_RESULT": ICEKYCSavedData.shared().ocrResult,
            "LIVENESS_CARD_FRONT_RESULT": ICEKYCSavedData.shared().livenessCardFrontResult,
            "LIVENESS_CARD_BACK_RESULT": ICEKYCSavedData.shared().livenessCardBackResult,
            "COMPARE_FACE_RESULT": ICEKYCSavedData.shared().compareFaceResult,
            "LIVENESS_FACE_RESULT": ICEKYCSavedData.shared().livenessFaceResult,
            "MASKED_FACE_RESULT": ICEKYCSavedData.shared().maskedFaceResult,
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            self.methodChannel!(jsonString)
            
        } catch {
            print(error.localizedDescription)
            self.methodChannel!(FlutterMethodNotImplemented)
        }
    }
}

extension AppDelegate: ICMainNFCReaderDelegate {
    // Phương thức khi người dùng nhấn xác nhận thoát SDK
    func icNFCMainDismissed() {
        print("Close NFC")
        self.methodChannel!(FlutterMethodNotImplemented)
    }
    
    func icNFCCardReaderGetResult() {
        
        // Hiển thị thông tin kết quả QUÉT QR
        print("qrCodeResult = \(ICNFCSaveData.shared().qrCodeResult)")
        
        // Hiển thị thông tin đọc thẻ chip dạng chi tiết
        print("dataNFCResult = \(ICNFCSaveData.shared().dataNFCResult)")
        
        // Hiển thị thông tin POSTCODE
        print("postcodeOriginalLocationResult = \(ICNFCSaveData.shared().postcodeOriginalLocationResult)")
        print("postcodeRecentLocationResult = \(ICNFCSaveData.shared().postcodeRecentLocationResult)")
        
        // Hiển thị thông tin ảnh chân dung đọc từ thẻ
        print("imageAvatar = \(ICNFCSaveData.shared().imageAvatar)")
        print("hashImageAvatar = \(ICNFCSaveData.shared().hashImageAvatar)")
        
        // Hiển thị thông tin Client Session
        print("clientSessionResult = \(ICNFCSaveData.shared().clientSessionResult)")
        
        // Hiển thị thông tin đọc dữ liệu nguyên bản của thẻ CHIP: COM, DG1, DG2, … DG14, DG15
        print("dataGroupsResult = \(ICNFCSaveData.shared().dataGroupsResult)")
        
        var dataNFCResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().dataNFCResult, options: .prettyPrinted)
            dataNFCResult = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var postcodePlaceOfOriginResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().postcodeOriginalLocationResult, options: .prettyPrinted)
            postcodePlaceOfOriginResult = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        var postcodePlaceOfResidenceResult = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ICNFCSaveData.shared().postcodeRecentLocationResult, options: .prettyPrinted)
            postcodePlaceOfResidenceResult = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
        }
        
        let dict = [
            // Thông tin mã QR
            "QR_CODE_RESULT_NFC": ICNFCSaveData.shared().qrCodeResult,
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
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            self.methodChannel!(jsonString)
            
        } catch {
            print(error.localizedDescription)
            self.methodChannel!(FlutterMethodNotImplemented)
        }
        
    }
}
