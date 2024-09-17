//
//  ICMainNFCReaderViewController.h
//  ICNFCCardReader
//
//  Created by Minh Minh iOS on 02/07/2021.
//  Copyright © 2021 Innovation Center - VNPT IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMainNFCReaderProtocols.h"
#import "ICMainNFCReaderPresenter.h"
#import "ICNFCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@protocol ICMainNFCReaderDelegate <NSObject>

@required

- (void) icNFCMainDismissed;

- (void) icNFCCardReaderGetResult;

@end


API_AVAILABLE(ios(13.0))
@interface ICMainNFCReaderViewController : ICNFCBaseViewController<ICMainNFCReaderViewProtocol>

@property (nonatomic) ICMainNFCReaderPresenter *presenter;

@property (weak, nonatomic) id<ICMainNFCReaderDelegate> icMainNFCDelegate;

// Giá trị này xác định ngôn ngữ được sử dụng trong SDK. Mặc định là icekyc_vi
// - icnfc_vi: Tiếng Việt
// - icnfc_en: Tiếng Anh
@property (nonatomic) NSString *languageSdk;

// Giá trị này xác định việc có hiển thị màn hình trợ giúp hay không. Mặc định là false
@property (nonatomic) BOOL isShowTutorial;

// Bật chức năng hiển thị nút bấm "Bỏ qua hướng dẫn" tại các màn hình hướng dẫn bằng video. Mặc định false
@property (nonatomic) BOOL isEnableGotIt;

// Thực hiện quét NFC trực tiếp với dữ liệu truyền vào là: số ID, ngày sinh, ngày hết hạn
@property (nonatomic) CardReaderStep cardReaderStep;
// Số giấy tờ căn cước, là dãy số gồm 12 ký tự. Mặc định ""
@property (nonatomic) NSString *idNumberCard;
// Ngày sinh của người dùng được in trên Căn cước, có định dạng YYMMDD (ví dụ 18 tháng 5 năm 1978 thì giá trị là 780518). Mặc định ""
@property (nonatomic) NSString *birthdayCard;
// Ngày hết hạn của Căn cước, có định dạng YYMMDD (ví dụ 18 tháng 5 năm 2047 thì giá trị là 470518). Mặc định ""
@property (nonatomic) NSString *expiredDateCard;

// bật chức năng tải ảnh chân dung trong CCCD. Mặc định false
@property (nonatomic) BOOL isEnableUploadAvatarImage;

// Bật tính năng Matching Postcode. Mặc định false
@property (nonatomic) BOOL isGetPostcodeMatching;

// bật tính năng xác thực thẻ. Mặc định false
@property (nonatomic) BOOL isEnableVerifyChip;

// bật hoặc tắt tính năng Call Service. Mặc định false
@property (nonatomic) BOOL isTurnOffCallService;

// Giá trị này được truyền vào để xác định nhiều luồng giao dịch trong một phiên. Mặc định ""
@property (nonatomic) NSString *inputClientSession;

// Giá trị này được truyền vào để xác định các thông tin cần để đọc. Các phần tử truyền vào là các giá trị của CardReaderValues. Mặc định []
@property (nonatomic) NSArray<id> *readingTagsNFC;


/*========== CÁC THUỘC TÍNH VỀ MÔI TRƯỜNG PHÁT TRIỂN - URL TÁC VỤ TRONG SDK ==========*/

// Giá trị tên miền chính của SDK. Mặc định ""
@property (nonatomic) NSString *baseDomain;

// Đường dẫn đầy đủ thực hiện tải ảnh chân dung lên phía máy chủ để nhận mã ảnh. Mặc định ""
@property (nonatomic) NSString *urlUploadImageFormData;

// Đường dẫn đầy đủ thực hiện tải thông tin dữ liệu đọc được lên máy chủ. Mặc định ""
@property (nonatomic) NSString *urlUploadDataNFC;

// Đường dẫn đầy đủ thực hiện kiểm tra mã bưu chính của thông tin giấy tờ như Quê quán, Nơi thường trú. Mặc định ""
@property (nonatomic) NSString *urlMatchingPostcode;



/*========== CÁC THUỘC TÍNH VỀ CÀI ĐẶT MÀU SẮC GIAO DIỆN TRONG SDK ==========*/

// Thanh header: PA 1 nút đóng bên phải. PA 2 nút đóng bên trái. mặc định là PA 1
@property (nonatomic) NSInteger styleHeader;

// màu nền Thanh header. mặc định là trong suốt
@property (nonatomic) UIColor *colorBackgroundHeader;

// 2. Màu nội dung thanh header (Màu chữ và màu nút đóng). mặc định là FFFFFF
@property (nonatomic) UIColor *colorContentHeader;

// 3. Màu văn bản chính, Tiêu đề & Văn bản phụ (màu text ở màn Hướng dẫn, ở các màn Quét MRZ, QR, NFC). mặc định là FFFFFF
@property (nonatomic) UIColor *colorContentMain;

// 4. Màu nền (bao gồm màu nền Hướng dẫn, màu nền lúc quét NFC). mặc định 142730
@property (nonatomic) UIColor *colorBackgroundMain;

// Đường line trên hướng dẫn chụp GTTT. mặc định D9D9D9
@property (nonatomic) UIColor *colorLine;

// 6. Màu nút bấm (bao gồm nút Tôi đã hiểu, Hướng dẫn, Quét lại (riêng iOS)). mặc định là FFFFFF
@property (nonatomic) UIColor *colorBackgroundButton;

// 7. Màu text của nút bấm (bao gồm nút Tôi đã hiểu, Quét lại (riêng iOS)) và thanh hướng dẫn khi đưa mặt vào khung oval. mặc định 142730
@property (nonatomic) UIColor *colorTitleButton;

// Màu nền chụp (màu nền quét QR, MRZ). mặc định 142730
@property (nonatomic) UIColor *colorBackgroundCapture;

// 9. Màu hiệu ứng Bình thường (màu animation QR, ĐỌc thẻ chip NFC, màu thanh chạy ở màn NFC, màu nút Hướng dẫn). mặc định 18D696
@property (nonatomic) UIColor *colorEffectAnimation;

// 10. Màu hiệu ứng thất bại (khi xảy ra lỗi Quét NFC)
@property (nonatomic) UIColor *colorEffectAnimationFailed;

// Hiển thị Họa tiết dưới nền. Mặc định false
@property (nonatomic) BOOL isUsingPatternUnderBackground;

// màu Họa tiết dưới nền. mặc định 18D696
@property (nonatomic) UIColor *colorPatternUnderBackgound;

// Hiển thị ảnh thương hiệu ở góc dưới màn hình. Mặc định false
@property (nonatomic) BOOL isShowTrademark;

// Ảnh thương hiệu hiển thị cuối màn hình. Mặc định là ảnh thương hiệu VNPT
@property (nonatomic) UIImage *imageTrademark;

// 15. Kích thước Logo (phần này cần bổ sung giới hạn chiều rộng và chiều cao). Kích thước logo mặc định NAx24
@property (nonatomic) CGSize sizeImageTrademark;

// Màu nền cho popup. Mặc định FFFFFF
@property (nonatomic) UIColor *colorBackgroundPopup;

// Màu văn bản trên popup. Mặc định 142730
@property (nonatomic) UIColor *colorTextPopup;


/*========== CHỈNH SỬA TÊN CÁC TỆP TIN HIỆU ỨNG - VIDEO HƯỚNG DẪN ==========*/

// Tên video hướng dẫn quét NFC. Mặc định ""
@property (nonatomic) NSString *nameVideoHelpNFC;


@end

NS_ASSUME_NONNULL_END
