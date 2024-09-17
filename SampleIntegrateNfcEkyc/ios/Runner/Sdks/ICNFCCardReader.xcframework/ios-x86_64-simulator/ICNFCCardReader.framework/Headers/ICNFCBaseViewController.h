//
//  ICNFCBaseViewController.h
//  ICNFCCardReader
//
//  Created by Minh Minh iOS on 02/07/2021.
//

#import <UIKit/UIKit.h>
#import "ICNFCLocalizeHelper.h"

NS_ASSUME_NONNULL_BEGIN

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface ICNFCBaseViewController : UIViewController

@property UIActivityIndicatorView *indicatorBase;
@property NSBundle* bundleSDK;

- (NSString *) convertObjectToString:(id) object;

- (CGFloat)sizeScaleIpad:(CGFloat)size;
- (CGFloat)sizeScale:(CGFloat)size;
- (CGFloat)heightScale:(CGFloat)height;
- (CGFloat)fontSizeScale:(NSInteger)size;

- (UIColor *)UIColorFromRGB:(int)rgbValue alpha:(CGFloat)alpha;
- (NSString *)setICNFCLocalizedString:(NSString *)key inputLanguage:(NSString*)inputLanguage;
- (CGFloat)getStatusBarHeight;
- (CGFloat)getBottomPadding;
- (CGFloat)getLabelHeight:(UILabel*)label width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
