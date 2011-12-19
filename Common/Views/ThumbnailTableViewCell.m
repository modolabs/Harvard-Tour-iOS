#import "NewsStoryTableViewCell.h"
#import "NewsModel.h"
#import "UIKit+KGOAdditions.h"
#import "CoreDataManager.h"

@implementation NewsStoryTableViewCell

@synthesize titleLabel = _titleLabel, subtitleLabel = _dekLabel, thumbView = _thumbnailView;

- (void)configureDefaultTheme {
    self.titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyMediaListTitle];
    self.titleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyMediaListTitle];
    
    self.subtitleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyMediaListSubtitle];
    self.subtitleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyMediaListSubtitle];

    self.titleLabel.backgroundColor = [UIColor greenColor];
    self.subtitleLabel.backgroundColor = [UIColor orangeColor];
    
    _thumbnailPadding = 0;
    _thumbnailSize = self.thumbView.frame.size;
    _customLayoutComplete = NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureDefaultTheme];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureDefaultTheme];
    }
    return self;
}
/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/
- (void)dealloc
{
    [super dealloc];
}

- (void)thumbnailFrameDidChange
{
    CGRect frame = CGRectMake(_thumbnailPadding, _thumbnailPadding, _thumbnailSize.width, _thumbnailSize.height);
    self.thumbView.frame = frame;
    self.indentationWidth = _thumbnailSize.width + 2 * _thumbnailPadding;
}

- (CGFloat)thumbnailPadding
{
    return _thumbnailPadding;
}

- (void)setThumbnailPadding:(CGFloat)padding
{
    _thumbnailPadding = padding;
    [self thumbnailFrameDidChange];
}

- (CGSize)thumbnailSize
{
    return _thumbnailSize;
}

- (void)setThumbnailSize:(CGSize)size
{
    _thumbnailSize = size;
    [self thumbnailFrameDidChange];
}

- (NSString *)reuseIdentifier
{
    return [[self class] commonReuseIdentifier];
}

+ (NSString *)commonReuseIdentifier
{
    static NSString *reuseIdentifier = @"faheuif23";
    return reuseIdentifier;
}

- (void)layoutSubviews
{
    CGFloat topPadding = 7;
    CGFloat bottomPadding = 7;
    CGFloat insideHeight = CGRectGetHeight(self.frame) - topPadding - bottomPadding;

    if (!_customLayoutComplete) {
//        CGFloat topPadding = 7;
//        CGFloat bottomPadding = 7;
        CGFloat rightPadding = 7;
        CGFloat leftPadding = 7 - _thumbnailPadding; // don't be additive with thumbnail padding
        
//        CGFloat insideHeight = CGRectGetHeight(self.frame) - topPadding - bottomPadding;
        CGFloat maxTitleHeight = insideHeight - self.subtitleLabel.font.lineHeight;
        
        CGFloat titleX = self.indentationWidth + leftPadding;
        CGFloat titleWidth = CGRectGetWidth(self.frame) - self.indentationWidth - leftPadding - rightPadding;
        
        CGSize maxTitleSize = CGSizeMake(titleWidth, maxTitleHeight);
        CGSize approxTitleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:maxTitleSize];
        
        self.titleLabel.frame = CGRectMake(titleX, topPadding, titleWidth, approxTitleSize.height);
        self.subtitleLabel.frame = CGRectMake(titleX, topPadding + approxTitleSize.height,
                                              titleWidth, insideHeight - approxTitleSize.height);
        _customLayoutComplete = YES;
    } else {
        CGFloat maxTitleHeight = insideHeight - self.subtitleLabel.font.lineHeight;
        
        CGFloat titleX = CGRectGetMinX(self.titleLabel.frame);
        CGFloat titleWidth = CGRectGetWidth(self.titleLabel.frame);
        
        CGSize maxTitleSize = CGSizeMake(titleWidth, maxTitleHeight);
        CGSize approxTitleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:maxTitleSize];
        
        self.titleLabel.frame = CGRectMake(titleX, topPadding, titleWidth, approxTitleSize.height);
        self.subtitleLabel.frame = CGRectMake(titleX, topPadding + approxTitleSize.height,
                                              titleWidth, insideHeight - approxTitleSize.height);
    }
    [super layoutSubviews];
}

/*
- (void)setStory:(NewsStory *)story
{
    [_story release];
    _story = [story retain];

    // title
    // TODO: make generic string method to do this
    NSString *title = [_story.title stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&apos;"] withString:@"'"];
    _titleLabel.text = title;
    CGSize constraint = CGSizeMake(_titleLabel.frame.size.width, self.frame.size.height - 10);
    CGSize size = [_story.title sizeWithFont:_titleLabel.font constrainedToSize:constraint];
    CGRect frame = _titleLabel.frame;
    frame.size.height = size.height;
    _titleLabel.frame = frame;

    // dek
    // 2 gives the tiniest amount of bottom padding for the dek
    CGFloat constraintHeight = self.frame.size.height - _titleLabel.frame.size.height - _titleLabel.frame.origin.y - 2;
    CGSize constraintSize = CGSizeMake(CGRectGetHeight(_dekLabel.frame), constraintHeight);
    if (constraintHeight >= _dekLabel.font.lineHeight) {
        CGSize dekSize = [_story.summary sizeWithFont:_dekLabel.font constrainedToSize:constraintSize];
        _dekLabel.text = _story.summary;
        CGRect dekFrame = _dekLabel.frame;
        dekFrame.origin.y = _titleLabel.frame.size.height;
        dekFrame.size.height = dekSize.height;
        _dekLabel.frame = dekFrame;
    } else {
        // if not even one line will fit, don't show the deck at all
        _dekLabel.text = nil;
    }
    
    if (_story.thumbImage) {
        _thumbnailView.delegate = self;
        _thumbnailView.imageURL = _story.thumbImage.url;
        _thumbnailView.imageData = _story.thumbImage.data;
        [_thumbnailView loadImage];
        
    } else {
        _thumbnailView.imageURL = nil;
        [_thumbnailView setPlaceholderImage:[UIImage imageWithPathName:@"modules/news/news-placeholder.png"]];
    }
}

- (NewsStory *)story
{
    return _story;
}

- (void)thumbnail:(MITThumbnailView *)thumbnail didLoadData:(NSData *)data
{
    self.story.thumbImage.data = data;
    [[CoreDataManager sharedManager] saveData];
}
*/
@end
