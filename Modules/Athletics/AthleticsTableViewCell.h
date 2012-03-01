#import <UIKit/UIKit.h>
#import "KGOLabel.h"
#import "MITThumbnailView.h"
#import "AthleticsStory.h"
@interface AthleticsTableViewCell : UITableViewCell <MITThumbnailDelegate>{
    
    IBOutlet MITThumbnailView *_thumbnailView;
    IBOutlet KGOLabel *_titleLabel;
    IBOutlet KGOLabel *_dekLabel;
    
    AthleticsStory *_story;
}
+ (NSString *)commonReuseIdentifier;
- (NSString *)reuseIdentifier;
- (void)configureLabelsTheme;
- (void)setStory:(AthleticsStory *)story;
@end
