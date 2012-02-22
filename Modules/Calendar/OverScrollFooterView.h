#import <UIKit/UIKit.h>

@interface OverScrollFooterView : UIView

@property(nonatomic, retain) IBOutlet UILabel *triggerLabel;
@property(nonatomic, retain) IBOutlet UILabel *loadingLabel;

- (void)startLoading;
- (void)stopLoading;

@end
