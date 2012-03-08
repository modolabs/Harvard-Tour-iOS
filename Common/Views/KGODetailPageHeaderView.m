#import "KGODetailPageHeaderView.h"
#import "KGOSearchModel.h"
#import "KGOTheme.h"
#import "UIKit+KGOAdditions.h"

#define LABEL_PADDING 10
#define MAX_TITLE_LINES 4
#define MAX_SUBTITLE_LINES 5

@interface KGODetailPageHeaderView (Private)

// triggered when title or subtitle changes so the height needs to be recalculated
- (void)contentDidChange;

@end

@implementation KGODetailPageHeaderView

@synthesize showsShareButton, showsBookmarkButton, delegate;

@synthesize showsSubtitle;
@synthesize actionButtons = _actionButtons;
@synthesize bookmarkButton = _bookmarkButton, shareButton = _shareButton,
titleLabel = _titleLabel, subtitleLabel = _subtitleLabel, buttonContainer = _buttonContainer;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.actionButtons = [NSMutableArray array];
        self.showsSubtitle = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.actionButtons = [NSMutableArray array];
        self.showsSubtitle = YES;
    }
    return self;
}

- (void)dealloc
{
    [_detailItem release];
    self.actionButtons = nil;
    self.delegate = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.shareButton = nil;
    self.bookmarkButton = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    if (self.showsShareButton) {
        UIImage *buttonImage = [UIImage imageWithPathName:@"common/share"];
        UIImage *pressedButtonImage = [UIImage imageWithPathName:@"common/share_pressed"];
        [self.shareButton setTitle:nil forState:UIControlStateNormal];
        [self.shareButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.shareButton setBackgroundImage:pressedButtonImage forState:UIControlStateHighlighted];
        [self.actionButtons addObject:self.shareButton];
    }
    
    if (self.showsBookmarkButton) {
        [self.bookmarkButton setTitle:nil forState:UIControlStateNormal];
        [self setupBookmarkButtonImages];
        [self.actionButtons addObject:self.bookmarkButton];
    }
    
    self.titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyContentTitle];
    self.subtitleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyContentSubtitle];
}

// triggered when title or subtitle changes so the height needs to be recalculated
- (void)contentDidChange
{
    CGFloat y = fmaxf(CGRectGetMaxY(self.buttonContainer.frame), CGRectGetMaxY(self.subtitleLabel.frame)) + 10;
    if (y != CGRectGetMaxY(self.frame)) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame),
                                CGRectGetWidth(self.frame), y);
        if ([self.delegate respondsToSelector:@selector(headerViewFrameDidChange:)]) {
            [self.delegate headerViewFrameDidChange:self];
        }
    }
}

- (BOOL)showsShareButton
{
    return !self.shareButton.hidden;
}

- (BOOL)showsBookmarkButton
{
    return !self.bookmarkButton.hidden;
}

- (void)setShowsShareButton:(BOOL)shows
{
    if (shows == self.shareButton.hidden) {
        self.shareButton.hidden = !shows;
        [self layoutActionButtons];
    }
}

- (void)setShowsBookmarkButton:(BOOL)shows
{
    if (shows == self.bookmarkButton.hidden) {
        self.bookmarkButton.hidden = !shows;
        [self layoutActionButtons];
    }
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (NSString *)subtitle
{
    return self.subtitleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    
    self.titleLabel.text = _detailItem.title;
    if (self.titleLabel.text.length) {
        CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                       constrainedToSize:CGSizeMake(CGRectGetWidth(self.titleLabel.frame), 200)
                                           lineBreakMode:UILineBreakModeWordWrap];
        self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMinY(self.titleLabel.frame),
                                           CGRectGetWidth(self.titleLabel.frame), size.height);

        // subtitle and button go 10px below bottom of title
        CGFloat y = CGRectGetMaxY(self.titleLabel.frame) + 10;
        CGRect frame = self.buttonContainer.frame;
        frame.origin.y = y;
        self.buttonContainer.frame = frame;

        frame = self.subtitleLabel.frame;
        frame.origin.y = y;
        self.subtitleLabel.frame = frame;
    }
    [self contentDidChange];
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;

    if (self.showsSubtitle && self.subtitleLabel.text) {
        CGFloat subWidth = CGRectGetMinX(self.buttonContainer.frame) - 10;
        CGSize size = [self.subtitleLabel.text sizeWithFont:self.subtitleLabel.font
                                          constrainedToSize:CGSizeMake(subWidth, 200)];
        self.subtitleLabel.frame = CGRectMake(CGRectGetMinX(self.subtitleLabel.frame),
                                              CGRectGetMinY(self.subtitleLabel.frame),
                                              subWidth, size.height);
        self.subtitleLabel.hidden = NO;
    } else {
        self.subtitleLabel.hidden = YES;
    }
    [self contentDidChange];
}

- (id<KGOSearchResult>)detailItem
{
    return _detailItem;
}

- (void)setDetailItem:(id<KGOSearchResult>)item
{
    [_detailItem release];
    _detailItem = [item retain];
    
    self.title = _detailItem.title;

    if ([_detailItem respondsToSelector:@selector(subtitle)]) {
        self.subtitle = [_detailItem subtitle];
    }
}

- (IBAction)toggleBookmark:(id)sender
{
    if ([self.detailItem isBookmarked]) {
        [self.detailItem removeBookmark];
    } else {
        [self.detailItem addBookmark];
    }

    [self setupBookmarkButtonImages];
}

- (IBAction)shareButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(headerView:shareButtonPressed:)]) {
        [self.delegate headerView:self shareButtonPressed:sender];
    }
}

- (void)setupBookmarkButtonImages
{    
    UIImage *buttonImage, *pressedButtonImage;
    if ([self.detailItem isBookmarked]) {
        buttonImage = [UIImage imageWithPathName:@"common/bookmark_on.png"];
        pressedButtonImage = [UIImage imageWithPathName:@"common/bookmark_on_pressed.png"];
    } else {
        buttonImage = [UIImage imageWithPathName:@"common/bookmark_off.png"];
        pressedButtonImage = [UIImage imageWithPathName:@"common/bookmark_off_pressed.png"];
    }
    [self.bookmarkButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.bookmarkButton setBackgroundImage:pressedButtonImage forState:UIControlStateHighlighted];
}

- (void)addButtonWithImage:(UIImage *)image pressedImage:(UIImage *)pressedImage target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    if (pressedImage) {
        [button setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
    }
    if (target && [target respondsToSelector:action]) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [self.actionButtons addObject:button];
    [self layoutActionButtons];
}

- (void)layoutActionButtons
{
    for (UIView *aView in self.buttonContainer.subviews) {
        [aView removeFromSuperview];
    }

    CGFloat x = 0;
    CGFloat width = 0;
    CGFloat spacing = 6;
    for (UIButton *aButton in self.actionButtons) {
        if (!aButton.hidden) {
            width = CGRectGetWidth(aButton.frame);
            aButton.frame = CGRectMake(x, 0, width, CGRectGetHeight(aButton.frame));
            x += width + spacing;
            [self.buttonContainer addSubview:aButton];
        }
    }
    
    width = x - spacing;
    x = CGRectGetWidth(self.frame) - width - 10;

    CGFloat y = self.titleLabel.hidden ? CGRectGetMinY(self.titleLabel.frame) : CGRectGetMaxY(self.titleLabel.frame);
    
    // TODO: in the future we might move this below the subtitle
    self.buttonContainer.frame = CGRectMake(x, y, width, CGRectGetHeight(self.buttonContainer.frame));
}

@end
