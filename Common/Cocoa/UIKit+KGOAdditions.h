#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KGOHTMLTemplate.h"

#define IS_IPAD_OR_PORTRAIT(orientation) (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || (orientation) == UIInterfaceOrientationPortrait)

@interface UIImage (KGOAdditions)

+ (UIImage *)imageWithPathName:(NSString *)pathName;
+ (UIImage *)blankImageOfSize:(CGSize)size;
- (UIImage *)imageAtRect:(CGRect)rect;
@end

@interface UIColor (KGOAdditions)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

@interface UIImageView (KGOAdditions)

- (void)showLoadingIndicator;
- (void)hideLoadingIndicator;

@end

@interface UIButton (KGOAdditions)

+ (UIButton *)genericButtonWithTitle:(NSString *)title;
+ (UIButton *)genericButtonWithImage:(UIImage *)image;

@end

@interface UITableViewCell (KGOAdditions)

- (void)applyBackgroundThemeColorForIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

@interface UIWebView (KGOAdditions)

- (void)loadTemplate:(KGOHTMLTemplate *)template values:(NSDictionary *)values;

@end

@interface UITableView (KGOAdditions)

- (CGFloat)marginWidth;

@end

@interface UITabBar (KGOAdditions)

- (void)drawRect:(CGRect)rect;

@end


