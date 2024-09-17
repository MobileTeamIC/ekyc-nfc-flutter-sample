//
//  ICMainNFCReaderPresenter.h
//  ICNFCCardReader
//
//  Created by Minh Minh iOS on 02/07/2021.
//  Copyright © 2021 Innovation Center - VNPT IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMainNFCReaderProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICMainNFCReaderPresenter : NSObject<ICMainNFCReaderInteractorOutputProtocol, ICMainNFCReaderPresenterProtocol>

@property (nonatomic, weak, nullable) id<ICMainNFCReaderViewProtocol> view;
@property (nonatomic) id<ICMainNFCReaderInteractorInputProtocol> interactor;
@property (nonatomic) id<ICMainNFCReaderWireframeProtocol> router;

- (instancetype)initWithInterface:(id<ICMainNFCReaderViewProtocol>)interface
                       interactor:(id<ICMainNFCReaderInteractorInputProtocol>)interactor
                           router:(id<ICMainNFCReaderWireframeProtocol>)router;

- (void) gotoICPopupWarningWithTitle:(NSString *)title content:(NSString *)content;

- (void) gotoICPopupCloseSdk;


- (void) callApiUploadAvatarGetHashFileName:(NSString *)fileName title:(NSString *)title description:(NSString *)description dataFile:(NSData *)dataFile;

- (void) callApiUploadDataNFCWithHashImage:(NSString *)imageFace dataGroups:(NSDictionary<NSString *,NSString *> *)dataGroups mrzs:(NSArray *)mrzs details:(NSDictionary *)details;

- (void) callApiGetPostcodeMatchingPlaceOfOrigin:(NSString *)placeOfOrigin;
- (void) callApiGetPostcodeMatchingPlaceOfResidence:(NSString *)placeOfResidence;

- (void) callApiVerifyNFCCardID:(NSString *)idCard deviceType:(NSString *)deviceType deviceName:(NSString *)deviceName deviceVersion:(NSString *)deviceVersion rawData:(NSDictionary *)rawData;


- (void) resetICNFCSaveData;

- (void) saveClientSession:(NSString *)clientSession;

- (void) saveQRCode:(NSString *)qrCode image:(UIImage *)image cropedImage:(UIImage *)cropedImage path:(NSURL *)path;

- (void) saveAvatar:(UIImage *)avatar;

@end

NS_ASSUME_NONNULL_END
