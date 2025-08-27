# eKYC NFC Flutter Sample

**Lưu ý**: Ứng dụng này sử dụng FVM version 3.29.2

## Cài đặt & Tích hợp SDK

### Yêu cầu trước khi bắt đầu
- **Quan trọng**: Liên hệ với chúng tôi qua [https://ekyc.vnpt.vn/vi](https://ekyc.vnpt.vn/vi) hoặc email **vnptai@vnpt.vn** để lấy các token và SDK cần thiết. Ứng dụng sẽ không hoạt động nếu không có những thứ này.

### Tích hợp SDK iOS

#### Bước 1: Tạo thư mục Fws
1. Điều hướng đến thư mục dự án iOS: `ios/Runner/`
2. Tạo một thư mục mới tên `Fws` (nếu chưa có)
3. Thư mục này sẽ chứa tất cả các framework SDK iOS

#### Bước 2: Thêm SDK Frameworks
1. **Kéo thả** các framework SDK sau vào thư mục `Fws`:
   - `ICNFCCardReader.xcframework` - SDK đọc thẻ NFC
   - `ICSdkEKYC.xcframework` - SDK eKYC
   - `OpenSSL.xcframework` - Thư viện OpenSSL (nếu được cung cấp)

#### Bước 3: Cấu hình Dự án Xcode
1. Mở dự án trong Xcode: `ios/Runner.xcworkspace`
2. Chọn dự án trong navigator
3. Chọn target **Runner**
4. Vào tab **General** → **Frameworks, Libraries, and Embedded Content**
5. Nhấn nút **+** và thêm các framework từ thư mục `Fws`
6. Đặt **Embed** thành **"Embed & Sign"** cho mỗi framework

#### Bước 4: Cập nhật Podfile (nếu sử dụng CocoaPods)
```ruby
# ios/Podfile
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Thêm local frameworks
  pod 'ICNFCCardReader', :path => 'Runner/Fws/ICNFCCardReader.xcframework'
  pod 'ICSdkEKYC', :path => 'Runner/Fws/ICSdkEKYC.xcframework'
end
```

#### Bước 5: Build và Test
1. Chạy `cd ios && pod install` (nếu sử dụng CocoaPods)
2. Clean và rebuild: `flutter clean && flutter pub get`
3. Test tích hợp: `flutter run`

### Tích hợp SDK Android

#### Bước 1: Thêm file AAR SDK
1. Điều hướng đến thư mục dự án Android: `android/`
2. Tạo các thư mục sau nếu chưa có:
   ```
   android/
   ├── ekyc/
   ├── nfc/
   └── scanqr/
   ```

#### Bước 2: Đặt file SDK
1. **eKYC SDK**: Đặt file AAR eKYC vào `android/ekyc/`
2. **NFC SDK**: Đặt file AAR NFC vào `android/nfc/`
3. **ScanQR SDK**: Đặt file AAR ScanQR vào `android/scanqr/`

#### Bước 3: Cấu hình file build.gradle

**Root build.gradle** (`android/build.gradle`):
```gradle
buildscript {
    ext.kotlin_version = '1.8.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}

```

**App build.gradle** (`android/app/build.gradle`):
```gradle
android {
    compileSdkVersion 35
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
}

dependencies {
    implementation project(':ekyc')
    implementation project(':scanqr')
    implementation project(':nfc')
    implementation 'androidx.multidex:multidex:2.0.0'
    implementation 'androidx.exifinterface:exifinterface:1.0.0'
    implementation 'com.google.code.gson:gson:2.8.2'
    implementation 'com.squareup.okhttp3:okhttp:4.9.0'
    implementation 'com.airbnb.android:lottie:6.0.1'
    implementation 'androidx.core:core-ktx:1.8.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.6.1'

    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'

    // NFC
    implementation 'org.jmrtd:jmrtd:0.7.24'
    implementation 'com.madgag.spongycastle:prov:1.58.0.0'
    implementation 'net.sf.scuba:scuba-sc-android:0.0.23'
    implementation group: 'org.ejbca.cvc', name: 'cert-cvc', version: '1.4.6'
    implementation 'org.bouncycastle:bcpkix-jdk15on:1.67'

    implementation 'commons-io:commons-io:2.6'
//    implementation 'com.github.mhshams:jnbis:2.0.2'
    implementation 'com.airbnb.android:lottie:6.0.1'
    implementation "androidx.lifecycle:lifecycle-extensions:2.0.0"
    implementation "android.arch.lifecycle:extensions:1.1.1"

    implementation "com.google.zxing:core:3.5.1"
    implementation "androidx.camera:camera-core:1.2.1"
    implementation "androidx.camera:camera-camera2:1.2.1"
    implementation "androidx.camera:camera-lifecycle:1.2.1"
    implementation "androidx.camera:camera-view:1.2.1"
    implementation "com.squareup.okhttp3:okhttp:4.11.0"
    implementation 'com.google.code.gson:gson:2.10.1'
}

```


#### Bước 6: Build và Test
1. Clean dự án: `flutter clean`
2. Lấy dependencies: `flutter pub get`
3. Test tích hợp: `flutter run`

## Hướng dẫn Tích hợp Flutter

### Thiết lập Method Channel

Dự án sử dụng một method channel duy nhất cho tất cả các thao tác eKYC và NFC:

```dart
static const MethodChannel _channel = MethodChannel('flutter.sdk.ekyc/integrate');
```

### Các Method Có Sẵn

#### Methods eKYC
- `startEkycOcr` - Quét và trích xuất văn bản từ tài liệu
- `startEkycFace` - Xác thực khuôn mặt
- `startEkycFull` - Luồng eKYC hoàn chỉnh
- `startEkycScanQr` - Quét mã QR

#### Methods NFC
- `startNfcQrCode` - Đọc mã QR NFC
- `startNfcNoQr` - Đọc NFC với đầu vào thủ công

### Tham số Cấu hình

Tất cả các method đều nhận một object cấu hình với các tham số sau:

```dart
{
  // Tokens eKYC
  "accessTokenEKYC": "your_ekyc_access_token",
  "tokenIdEKYC": "your_ekyc_token_id", 
  "tokenKeyEKYC": "your_ekyc_token_key",
  
  // Tokens NFC
  "accessToken": "your_nfc_access_token",
  "tokenId": "your_nfc_token_id",
  "tokenKey": "your_nfc_token_key",
  
  // Đầu vào thủ công (cho NFC)
  "idNumber": "<idNumber>",
  "birthday": "<yyMMdd>",
  "expiredDate": "yyMMdd",
  
  // Cấu hình UI
  "languageSdk": "icekyc_vi",
  "isShowTutorial": true,
  "isEnableGotIt": true
}
```

### Định dạng Phản hồi

Tất cả các method trả về một chuỗi JSON với cấu trúc sau:

```json
{
  "OCR_RESULT": "ocr_result_data",
  "LIVENESS_CARD_FRONT_RESULT": "liveness_front_data",
  "LIVENESS_CARD_BACK_RESULT": "liveness_back_data",
  "COMPARE_FACE_RESULT": "face_compare_data",
  "LIVENESS_FACE_RESULT": "liveness_face_data",
  "MASKED_FACE_RESULT": "masked_face_data",
  "QR_CODE_RESULT_NFC": "qr_code_data",
  "IMAGE_AVATAR_CARD_NFC": "avatar_image_path",
  "HASH_AVATAR": "avatar_hash",
  "CLIENT_SESSION_RESULT": "client_session",
  "LOG_NFC": "nfc_log_data",
  "POST_CODE_ORIGINAL_LOCATION_RESULT": "original_location",
  "POST_CODE_RECENT_LOCATION_RESULT": "recent_location"
}
```

### Xử lý Lỗi

SDK cung cấp xử lý lỗi toàn diện:

```dart
try {
  final result = await _channel.invokeMethod('startEkycOcr', config);
  // Xử lý thành công
} on PlatformException catch (e) {
  // Xử lý lỗi đặc thù platform
  print('Error: ${e.code} - ${e.message}');
} catch (e) {
  // Xử lý lỗi chung
  print('General error: $e');
}
```

## Tính năng

### Luồng eKYC
- **OCR Flow**: Quét và trích xuất văn bản từ tài liệu
- **Face Verification**: Chụp và xác thực khuôn mặt
- **Full eKYC**: Luồng OCR + Xác thực khuôn mặt hoàn chỉnh
- **QR Code Scanning**: Chức năng quét mã QR

### Luồng NFC
- **NFC QR Code**: Quét mã QR sau đó đọc chip NFC
- **NFC Manual**: Nhập thông tin thẻ thủ công để đọc NFC

## Kiến trúc

### Service Layer
- **EkycConfig**: Lớp cấu hình chứa tất cả các tham số SDK
- **EkycPresets**: Cấu hình định sẵn cho các trường hợp sử dụng phổ biến
- **EkycMethodChannel**: Dịch vụ method channel sạch sẽ cho giao tiếp native

### Quản lý Cấu hình
Dự án sử dụng cách tiếp cận cấu hình tập trung:
- Tất cả các tham số SDK được quản lý thông qua `EkycConfig`
- Cấu hình phổ biến có sẵn thông qua `EkycPresets`
- Dễ dàng mở rộng và sửa đổi cho các trường hợp sử dụng khác nhau

### Tích hợp Native
- **Android**: Triển khai Kotlin sạch sẽ với xử lý lỗi phù hợp
- **iOS**: Triển khai Swift có cấu trúc với delegate patterns
- Interface method channel nhất quán trên các platform

## Sử dụng

### Thiết lập Cơ bản

1. **Cấu hình Tham số SDK**:
```dart
final config = EkycPresets.ocr(
  languageSdk: 'icekyc_vi',
  isShowTutorial: true,
  isEnableGotIt: true,
);
```


2. **Bắt đầu Luồng eKYC**:
```dart
final ekycService = EkycMethodChannel();
final result = await ekycService.startOcr(config);
```
3. **Thiet lap .env**
  - Tao file assets/config/.env
```
  ID_NUMBER=<idNumber>
  BIRTHDAY=<yyMMdd>
  EXPIRE=<yyMMdd>
```

### Các Preset Có Sẵn

#### Luồng eKYC
```dart
// OCR Flow
EkycPresets.ocr()

// Face Verification
EkycPresets.face()

// Full eKYC
EkycPresets.full()

// QR Code Scanning
EkycPresets.scanQr()
```

#### Luồng NFC
```dart
// NFC QR Code
EkycPresets.nfcQrCode()

// NFC Manual Input
EkycPresets.nfcManual(
  idNumber: '030201008790',
  birthday: '010211',
  expiredDate: '260211',
)
```

## Tham số Cấu hình

### Tham số eKYC
- `accessTokenEKYC`: Access token dịch vụ eKYC
- `tokenIdEKYC`: Token ID dịch vụ eKYC
- `tokenKeyEKYC`: Token key dịch vụ eKYC
- `languageSdk`: Ngôn ngữ SDK ('icekyc_vi' | 'icekyc_en')
- `isShowTutorial`: Hiển thị màn hình hướng dẫn
- `isEnableGotIt`: Bật nút "Đã hiểu"
- `flowType`: Loại luồng eKYC
- `documentType`: Loại tài liệu cho OCR

### Tham số NFC
- `accessToken`: Access token dịch vụ NFC
- `tokenId`: Token ID dịch vụ NFC
- `tokenKey`: Token key dịch vụ NFC
- `idNumber`: Số thẻ 12 chữ số
- `birthday`: Ngày sinh (định dạng YYMMDD)
- `expiredDate`: Ngày hết hạn (định dạng YYMMDD)

## Xử lý Lỗi

Dự án bao gồm xử lý lỗi toàn diện:
- Xử lý exception platform trong method channel
- Xác thực đầu vào cho luồng NFC thủ công
- Thông báo lỗi thân thiện với người dùng
- Fallback nhẹ nhàng cho các tính năng không được hỗ trợ

### Hỗ trợ

Để được hỗ trợ kỹ thuật hoặc truy cập SDK, liên hệ:
- Website: [https://ekyc.vnpt.vn/vi](https://ekyc.vnpt.vn/vi)
- Email: **vnptai@vnpt.vn**

## Giấy phép

Dự án này được cung cấp như một mẫu để tích hợp SDK eKYC và NFC của VNPT. 