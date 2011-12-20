#import <UIKit/UIKit.h>

@class MITThumbnailView, Photo;

@interface PhotoDetailViewController : UIViewController {
    
    Photo *_photo;
}

@property (nonatomic, retain) IBOutlet MITThumbnailView *imageView;
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIView *pagerView;
@property (nonatomic, retain) IBOutlet MITThumbnailView *prevThumbView;
@property (nonatomic, retain) IBOutlet MITThumbnailView *nextThumbView;
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *pagerLabel;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;

- (IBAction)prevButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;

@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) Photo *photo;

@end
