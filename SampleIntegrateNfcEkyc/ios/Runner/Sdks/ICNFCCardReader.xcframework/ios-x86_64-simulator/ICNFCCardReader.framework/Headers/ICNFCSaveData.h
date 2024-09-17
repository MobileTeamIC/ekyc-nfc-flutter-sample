//
//  ICNFCSaveData.h
//  ICNFCCardReader
//
//  Created by Minh Nguyễn on 19/12/2021.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICNFCSaveData : NSObject

+ (ICNFCSaveData *)shared;

@property (nonatomic) NSString *SDAuthorization;
@property (nonatomic) NSString *SDTokenId;
@property (nonatomic) NSString *SDTokenKey;

@property (nonatomic) BOOL isPrintLogRequest;

- (void) resetOrInitAllData;


// Ảnh mã QR chụp được khi quét thành công mã.
@property (nonatomic) UIImage *imageQRCode;

// Đường dẫn Ảnh mã QR chụp được khi quét thành công mã.
@property (nonatomic) NSURL *pathImageQRCode;

// Ảnh mã QR đã cắt, chụp được khi quét thành công mã.
@property (nonatomic) UIImage *imageCropedQRCode;

// Đường dẫn Ảnh mã QR đã cắt
@property (nonatomic) NSURL *pathImageCropedQRCode;

// Mã ảnh QR sau khi tải ảnh lên máy chủ
@property (nonatomic) NSString *hashImageQRCode;


// Ảnh đại diện của chủ giấy tờ, lấy được sau khi đọc thông tin qua NFC
@property (nonatomic) UIImage *imageAvatar;

// Đường dẫn ảnh đại diện
@property (nonatomic) NSURL *pathImageAvatar;

// Mã ảnh đại diện sau khi tải ảnh lên phía máy chủ
@property (nonatomic) NSString *hashImageAvatar;


// Giá trị được trả ra để ghép vào các luồng khác để đảm bảo các giao dịch cùng trong một phiên
@property (nonatomic) NSString *clientSessionResult;

// Dữ liệu đọc thông tin thẻ căn cước bằng NFC như số giấy tờ, họ tên, ngày sinh
@property (nonatomic) NSDictionary<NSString *, id> *dataNFCResult;

// Dữ liệu nguyên bản sau khi đọc thông tin thẻ căn cước bằng NFC, bao gồm các mã: COM, DG1, DG2, … DG14, DG15
@property (nonatomic) NSDictionary<NSString *, id> *dataGroupsResult;

// Dữ liệu sau khi kiểm tra mã bưu chính của Quê quán
@property (nonatomic) NSDictionary<NSString *, id> *postcodePlaceOfOriginResult;

// Dữ liệu sau khi kiểm tra mã bưu chính của Nơi thường trú
@property (nonatomic) NSDictionary<NSString *, id> *postcodePlaceOfResidenceResult;

// Dữ liệu quét mã QR
@property (nonatomic) NSString *scanQRCodeResult;

// Dữ liệu sau khi xác thực thông tin C06
@property (nonatomic) NSDictionary<NSString *, id> *verifyNFCCardResult;

@end

NS_ASSUME_NONNULL_END
