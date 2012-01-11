#import <UIKit/UIKit.h>


@interface VideoWebViewController : UIViewController {

}

- (id)initWithURL:(NSURL *)theURL;

@property (nonatomic, retain) NSURL *URL;

@end
