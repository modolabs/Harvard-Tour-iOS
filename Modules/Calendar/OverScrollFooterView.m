#import "OverScrollFooterView.h"
#import "KGOTheme.h"

@implementation OverScrollFooterView

@synthesize triggerLabel, loadingLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.loadingLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
        self.loadingLabel.text = NSLocalizedString(@"COMMON_INDETERMINATE_LOADING", @"Loading...");
        self.triggerLabel.text = NSLocalizedString(@"CALENDAR_PULL_DOWN_TO_LOAD_MORE", @"Pull down to load more");
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.loadingLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
        self.loadingLabel.text = NSLocalizedString(@"COMMON_INDETERMINATE_LOADING", @"Loading...");
        self.triggerLabel.text = NSLocalizedString(@"CALENDAR_PULL_DOWN_TO_LOAD_MORE", @"Pull down to load more");
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
