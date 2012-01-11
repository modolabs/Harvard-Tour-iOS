#import "ThumbnailTableViewCell.h"
#import "NewsModel.h"
#import "UIKit+KGOAdditions.h"
#import "CoreDataManager.h"

@implementation ThumbnailTableViewCell

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
    CGFloat maxTitleHeight = insideHeight - self.subtitleLabel.font.lineHeight;
    
    CGFloat titleX, titleWidth;

    if (!_customLayoutComplete) {
        CGFloat rightPadding = 7;
        CGFloat leftPadding = 7 - _thumbnailPadding; // don't be additive with thumbnail padding
        
        titleX = self.indentationWidth + leftPadding;
        titleWidth = CGRectGetWidth(self.frame) - self.indentationWidth - leftPadding - rightPadding;
        
        _customLayoutComplete = YES;

    } else {
        titleX = CGRectGetMinX(self.titleLabel.frame);
        titleWidth = CGRectGetWidth(self.titleLabel.frame);
    }
    
    CGSize maxTitleSize = CGSizeMake(titleWidth, maxTitleHeight);
    CGSize approxTitleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:maxTitleSize];
    
    self.titleLabel.frame = CGRectMake(titleX, topPadding, titleWidth, approxTitleSize.height);
    self.subtitleLabel.frame = CGRectMake(titleX, topPadding + approxTitleSize.height,
                                          titleWidth, insideHeight - approxTitleSize.height);
    
    [super layoutSubviews];
}


@end
