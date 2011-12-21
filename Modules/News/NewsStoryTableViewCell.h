#import <UIKit/UIKit.h>
#import "MITThumbnailView.h"
#import "KGOLabel.h"

//@class NewsStory;

@interface NewsStoryTableViewCell : UITableViewCell// <MITThumbnailDelegate> 
{
    KGOLabel *_titleLabel;
    KGOLabel *_dekLabel;
    MITThumbnailView *_thumbnailView;

    CGFloat _thumbnailPadding;
    CGSize _thumbnailSize;
    
    BOOL _customLayoutComplete;
    
//    NewsStory *_story;
}

// use KGOLabel because these are top-aligned by default
@property (nonatomic, retain) IBOutlet KGOLabel *titleLabel;
@property (nonatomic, retain) IBOutlet KGOLabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet MITThumbnailView *thumbView;

@property (nonatomic) CGFloat thumbnailPadding;
@property (nonatomic) CGSize thumbnailSize;

//@property (nonatomic, retain) NewsStory *story;

+ (NSString *)commonReuseIdentifier;

@end
