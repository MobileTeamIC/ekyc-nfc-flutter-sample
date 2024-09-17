//
//  ICMainNFCReaderProtocols.h
//  ICNFCCardReader
//
//  Created by Minh Minh iOS on 02/07/2021.
//  Copyright © 2021 Innovation Center - VNPT IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    QRCode, // chụp ảnh chân dung xa gần
    NFCReader, // chụp ảnh chân dung quay mặt 02 hướng phải và thẳng
} CardReaderStep;



typedef NS_ENUM(NSInteger, CardReaderValues) {
    VerifyDocumentInfo      = 100019,       // Security Object Document (SOD, COM)
    MRZInfo                 = 100020,       // MRZ Code (DG1)
    ImageAvatarInfo         = 100021,       // Image Base64 (DG2)
    SecurityDataInfo        = 100022,       // Security Data (DG14, DG15)
};



#pragma mark - WireFrameProtocol

@protocol ICMainNFCReaderWireframeProtocol <NSObject>

- (void) presentICPopupWarningWithTitle:(NSString *)title content:(NSString *)content;

- (void) presentICPopupCloseSdk;

@end

#pragma mark - ICMainNFCReaderPresenterProtocol

@protocol ICMainNFCReaderPresenterProtocol <NSObject>

@end

#pragma mark - ICMainNFCReaderInteractorProtocol

@protocol ICMainNFCReaderInteractorOutputProtocol <NSObject>

/** Interactor -> Presenter */

- (void) sendResultUploadSucceedAvatarImage:(NSString *)hash;

- (void) sendResultUploadDataNFCSucceed:(NSDictionary *)data;

- (void) sendResultGetPostcodeMatchingPlaceOfOriginSucceed:(NSDictionary *)data;

- (void) sendResultGetPostcodeMatchingPlaceOfResidenceSucceed:(NSDictionary *)data;

- (void) sendResultVerifyNFCCardSucceed:(NSDictionary *)data;

@end

@protocol ICMainNFCReaderInteractorInputProtocol <NSObject>

- (void)setOutput:(id<ICMainNFCReaderInteractorOutputProtocol>)output;
- (id<ICMainNFCReaderInteractorOutputProtocol>)getOutputProtocol;

/** Presenter -> Interactor */
- (void) handleUploadAvatarGetHashFileName:(NSString *)fileName title:(NSString *)title description:(NSString *)description dataFile:(NSData *)dataFile;

- (void) handleUploadDataNFCWithHashImage:(NSString *)imageFace dataGroups:(NSDictionary<NSString *,NSString *> *)dataGroups mrzs:(NSArray *)mrzs details:(NSDictionary *)details;

- (void) handleGetPostcodeMatchingPlaceOfOrigin:(NSString *)placeOfOrigin;
- (void) handleGetPostcodeMatchingPlaceOfResidence:(NSString *)placeOfResidence;

- (void) handleVerifyNFCCardID:(NSString *)idCard deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName deviceVersion:(NSString *)deviceVersion rawData:(NSDictionary *)rawData;


// thực hiện CÀI ĐẶT LẠI thông tin ICNFCSaveData
- (void) handleResetICNFCSaveData;

- (void) handleSaveClientSession:(NSString *)clientSession;

- (void) handleSaveQRCode:(NSString *)qrCode image:(UIImage *)image cropedImage:(UIImage *)cropedImage path:(NSURL *)path;

- (void) handleSaveAvatar:(UIImage *)avatar;


@end

#pragma mark - ICMainNFCReaderViewProtocol

@protocol ICMainNFCReaderViewProtocol <NSObject>

/** Presenter -> ViewController */

- (void) showResultUploadSucceedAvatarImage:(NSString *)hash;

- (void) showResultUploadDataNFCSucceed:(NSDictionary *)data;

- (void) showResultGetPostcodeMatchingPlaceOfOriginSucceed:(NSDictionary *)data;

- (void) showResultGetPostcodeMatchingPlaceOfResidenceSucceed:(NSDictionary *)data;

- (void) showResultVerifyNFCCardSucceed:(NSDictionary *)data;

@end
