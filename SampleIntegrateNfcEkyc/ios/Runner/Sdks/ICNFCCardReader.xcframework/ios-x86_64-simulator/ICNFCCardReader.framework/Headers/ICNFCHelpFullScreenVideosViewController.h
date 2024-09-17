//
//  ICNFCHelpFullScreenVideosViewController.h
//  ICNFCCardReader
//
//  Created by Minh Minh iOS on 22/07/2021.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ICNFCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ICNFCHelpFullScreenVideosDelegate <NSObject>

@required
- (void) pressButtonSkipICNFCHelpFullScreenVideos;

@end

@interface ICNFCHelpFullScreenVideosViewController : ICNFCBaseViewController

@property (weak, nonatomic) id<ICNFCHelpFullScreenVideosDelegate> helpDelegate;


@property (nonatomic) BOOL isEnableGotIt;
@property (nonatomic) UIColor *colorEkycPrimaryBackground;
@property (nonatomic) NSString *nameVideoHelpNFC;

@end

NS_ASSUME_NONNULL_END
