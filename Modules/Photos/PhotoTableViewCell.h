#import <UIKit/UIKit.h>

@class MITThumbnailView;

@interface PhotoTableViewCell : UITableViewCell {
    
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_subtitleLabel;
    IBOutlet MITThumbnailView *_thumbView;
    
}

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UILabel *subtitleLabel;
@property (nonatomic, readonly) MITThumbnailView *thumbView;

@end
