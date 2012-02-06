#import "OverScrollFooterView.h"
#import "KGOTheme.h"

@implementation OverScrollFooterView

@synthesize triggerLabel, loadingLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.loadingLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
        self.loadingLabel.text = NSLocalizedString(@"Loading...", nil);
        self.triggerLabel.text = NSLocalizedString(@"Pull down to load more", nil);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.loadingLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
        self.loadingLabel.text = NSLocalizedString(@"Loading...", nil);
        self.triggerLabel.text = NSLocalizedString(@"Pull down to load more", nil);
    }
    return self;
}

- (void)startLoading
{
    self.triggerLabel.hidden = YES;
    self.loadingLabel.hidden = NO;
}

- (void)stopLoading
{
    self.loadingLabel.hidden = YES;
    self.triggerLabel.hidden = NO;
}

@end
