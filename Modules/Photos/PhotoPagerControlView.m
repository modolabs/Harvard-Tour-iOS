#import "PhotoPagerControlView.h"
#import "UIKit+KGOAdditions.h"

@implementation PhotoPagerControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _leftLabel.text = NSLocalizedString(@"Previous", @"photo pager left label");
        _rightLabel.text = NSLocalizedString(@"Next", @"photo pager right label");
        [_leftButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background"]
                               forState:UIControlStateNormal];
        [_leftButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background-pressed"]
                               forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background"]
                                forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background-pressed"]
                                forState:UIControlStateNormal];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _leftLabel.text = NSLocalizedString(@"Previous", @"photo pager left label");
        _rightLabel.text = NSLocalizedString(@"Next", @"photo pager right label");
        [_leftButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background"]
                               forState:UIControlStateNormal];
        [_leftButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background-pressed"]
                               forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background"]
                                forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageWithPathName:@"common/generic-button-background-pressed"]
                                forState:UIControlStateNormal];
    }
    return self;
}

@end
