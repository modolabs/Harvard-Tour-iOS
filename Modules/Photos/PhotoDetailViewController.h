#import <UIKit/UIKit.h>
#import "KGOShareButtonController.h"
#import "KGODetailPager.h"

@class MITThumbnailView, Photo;

@interface PhotoDetailViewController : UIViewController <KGODetailPagerController, KGODetailPagerDelegate> {
    
}

@property (nonatomic, retain) IBOutlet MITThumbnailView *imageView;
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;

@property (nonatomic, retain)  KGOShareButtonController *shareController;

- (IBAction)shareButtonPressed:(id)sender;

- (void)displayPhoto:(Photo *)photo;

@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) Photo *photo;

@end
