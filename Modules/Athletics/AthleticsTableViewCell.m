#import "AthleticsTableViewCell.h"
#import "KGOTheme.h"
#import "UIKit+KGOAdditions.h"
#import "CoreDataManager.h"
#import "AthleticsModel.h"
@implementation AthleticsTableViewCell
- (void)dealloc {
    [_thumbnailView release];
    [_titleLabel release];
    [_dekLabel release];
    [super dealloc];
}

+ (NSString *)commonReuseIdentifier
{
    static NSString *reuseIdentifier = @"athleticscell";
    return reuseIdentifier;
}

- (NSString *)reuseIdentifier
{
    return [[self class] commonReuseIdentifier];
}

- (NSString *)titleByTrimCategoryNameWithTitle:(NSString *)title {
    NSString *subString = nil;
    subString = [title stringByReplacingOccurrencesOfString:@"W. " withString:@""];
    subString = [subString stringByReplacingOccurrencesOfString:@"M. " withString:@""];
    
    if ([subString isEqualToString:title]) {
        if ([subString rangeOfString:@"ball. "].location != NSNotFound) {
            NSArray *cuts = [subString componentsSeparatedByString:@"ball. "];
            if (cuts.count > 1) {
                return [cuts objectAtIndex:1];
            }
        } else if ([subString rangeOfString:@"Swimming & Diving."].location != NSNotFound) {
            NSArray *cuts = [subString componentsSeparatedByString:@"Swimming & Diving."];
            if (cuts.count > 1) {
                return [cuts objectAtIndex:1];
            }
        }
        return subString;
    }
    NSArray *cuts = [subString componentsSeparatedByString:@". "];
    if (cuts.count > 1) {
        NSString *prefix = [NSString stringWithFormat:@"%@. ",[cuts objectAtIndex:0]];
        subString = [subString stringByReplacingOccurrencesOfString:prefix 
                                                         withString:@""];
    }
    return subString;
}

- (NSString *)categoryNameWithTitle:(NSString *)title {
    NSString *subString = [self titleByTrimCategoryNameWithTitle:title];
    subString = [title stringByReplacingOccurrencesOfString:subString withString:@""];
    subString = subString.length > 0 ? subString : title;
    if ([[subString substringFromIndex:subString.length-2] isEqualToString:@". "]) {
        subString = [subString substringToIndex:subString.length-2];
    }
    return subString;
}

- (NSString *)titleStringForString:(NSString *)srcString {
    NSString *formattor = [NSString stringWithFormat:@"%@\n%@",
                           [self categoryNameWithTitle:srcString],
                           [self titleByTrimCategoryNameWithTitle:srcString]];
    return formattor;
}

- (void)configureLabelsTheme { 
    _titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListTitle];
    _titleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertySportListTitle];
    
    _dekLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListSubtitle];
    _dekLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertySportListSubtitle];
}

- (void)setStory:(AthleticsStory *)story
{
    [_story release];
    _story = [story retain];
    
    // title
    NSString *title = [_story.title stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&apos;"] withString:@"'"];
    _titleLabel.text = [self titleStringForString:title];
    CGSize constraint = CGSizeMake(_titleLabel.frame.size.width, self.frame.size.height - 30);
    CGSize size = [_story.title sizeWithFont:_titleLabel.font constrainedToSize:constraint];
    CGRect frame = _titleLabel.frame;
    frame.size.height = size.height;
    _titleLabel.frame = frame;
    
    // dek
    // 2 gives the tiniest amount of bottom padding for the dek
    CGFloat constraintHeight = self.frame.size.height - _titleLabel.frame.size.height - _titleLabel.frame.origin.y - 2;
    if (constraintHeight >= _dekLabel.font.lineHeight) {
        if ([_story isKindOfClass:[AthleticsStory class]]) {
            CGSize dekSize = [_story.summary sizeWithFont:_dekLabel.font constrainedToSize:CGSizeMake(_dekLabel.frame.size.width, constraintHeight)];
            _dekLabel.text = _story.summary;
            CGRect dekFrame = _dekLabel.frame;
            dekFrame.origin.y = _titleLabel.frame.size.height;
            dekFrame.size.height = dekSize.height;
            _dekLabel.frame = dekFrame;
        }
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
        [_thumbnailView setPlaceholderImage:[UIImage imageWithPathName:@"modules/athletics/athletics-placeholder.png"]];
    }
}

- (AthleticsStory *)story
{
    return _story;
}

- (void)thumbnail:(MITThumbnailView *)thumbnail didLoadData:(NSData *)data
{
    self.story.thumbImage.data = data;
    [[CoreDataManager sharedManager] saveData];
}
@end
