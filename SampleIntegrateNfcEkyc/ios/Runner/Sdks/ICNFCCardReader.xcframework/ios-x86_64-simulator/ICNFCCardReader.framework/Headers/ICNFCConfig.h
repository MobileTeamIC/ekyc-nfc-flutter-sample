//
//  ICNFCConfig.h
//  ICNFCCardReader
//
//  Created by MinhMinh on 07/12/2022.
//  Copyright © 2022 Innovation Center - VNPT IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICNFCConfig : NSObject

+ (ICNFCConfig *)shared;

@property (nonatomic) NSString *languageSdk;

@property (nonatomic) NSString *clientSession;
@property (nonatomic) NSString *baseDomain;
@property (nonatomic) NSString *urlUploadImageFormData;
@property (nonatomic) NSString *urlUploadDataNFC;
@property (nonatomic) NSString *urlMatchingPostcode;
@property (nonatomic) NSString *urlVerifyNFCCard;

// Thanh header: PA 1 nút đóng bên phải. PA 2 nút đóng bên trái. mặc định là 1
@property (nonatomic) NSInteger styleHeader;

// màu nội dung Thanh header: Màu chữ và màu nút đóng. mặc định là FFFFFF
@property (nonatomic) UIColor *colorContentHeader;

// màu nen Thanh header. mặc định là trong suốt
@property (nonatomic) UIColor *colorBackgroundHeader;

// Màu văn bản chính - Tiêu đề & Văn bản phụ. mặc định là FFFFFF
@property (nonatomic) UIColor *colorContentMain;

// Màu nền: dùng cho màn help + preview
@property (nonatomic) UIColor *colorBackgroundMain;

// Đường line trên hướng dẫn chụp GTTT. mặc định D9D9D9
@property (nonatomic) UIColor *colorLine;

// Button và Thanh hướng dẫn khi đưa mặt vào khung oval. mặc định 18D696. hiện đang thừa (Thanh hướng dẫn khi đưa mặt vào khung oval)
@property (nonatomic) UIColor *colorBackgroundButton;

//Màu text cho button và thanh hướng dẫn khi đưa mặt vào khung oval. mặc định 142730
@property (nonatomic) UIColor *colorTitleButton;

// Màu nền chụp. document thì alpha = 0.5. face thì alpha = 1.0. mặc định 142730
@property (nonatomic) UIColor *colorBackgroundCapture;

// Màu hiệu ứng hiện đang thiếu (Thanh hướng dẫn khi đưa mặt vào khung oval). mặc định 18D696
@property (nonatomic) UIColor *colorEffectAnimation;

//
@property (nonatomic) UIColor *colorEffectAnimationFailed;

// Họa tiết dưới nền mặc định có hiện
@property (nonatomic) BOOL isUsingPatternUnderBackground;

// màu Họa tiết dưới nền. mặc định 18D696
@property (nonatomic) UIColor *colorPatternUnderBackgound;

// hiển thị logo
@property (nonatomic) BOOL isShowTrademark;

// Logo mặc định là logo vnpt
@property (nonatomic) UIImage *imageTrademark;

// Kích thước logo mặc định 38x12
@property (nonatomic) CGSize sizeImageTrademark;

// Màu nền cho pop up mặc định FFFFFF
@property (nonatomic) UIColor *colorBackgroundPopup;

// Màu văn bản trên popup. mặc định 142730
@property (nonatomic) UIColor *colorTextPopup;

@end

NS_ASSUME_NONNULL_END
