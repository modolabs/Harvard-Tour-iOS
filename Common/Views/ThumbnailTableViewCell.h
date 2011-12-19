#import <UIKit/UIKit.h>
#import "MITThumbnailView.h"
#import "KGOLabel.h"

@interface ThumbnailTableViewCell : UITableViewCell
{
    KGOLabel *_titleLabel;
    KGOLabel *_dekLabel;
    MITThumbnailView *_thumbnailView;

    CGFloat _thumbnailPadding;
    CGSize _thumbnailSize;
    
    BOOL _customLayoutComplete;
}

// use KGOLabel because these are top-aligned by default
@property (nonatomic, retain) IBOutlet KGOLabel *titleLabel;
@property (nonatomic, retain) IBOutlet KGOLabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet MITThumbnailView *thumbView;

@property (nonatomic) CGFloat thumbnailPadding;
@property (nonatomic) CGSize thumbnailSize;

+ (NSString *)commonReuseIdentifier;

@end
