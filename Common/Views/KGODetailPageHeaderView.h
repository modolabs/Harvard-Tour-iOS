#import <UIKit/UIKit.h>

@class KGODetailPageHeaderView;

@protocol KGODetailPageHeaderDelegate <NSObject>

@optional

- (void)headerViewFrameDidChange:(KGODetailPageHeaderView *)headerView;
- (void)headerView:(KGODetailPageHeaderView *)headerView shareButtonPressed:(id)sender;

@end

@protocol KGOSearchResult;

@interface KGODetailPageHeaderView : UIView
{
    id<KGOSearchResult> _detailItem;
}

@property(nonatomic, retain) NSMutableArray *actionButtons;

@property(nonatomic, assign) id<KGODetailPageHeaderDelegate> delegate;
@property(nonatomic, retain) id<KGOSearchResult> detailItem;

@property(nonatomic, assign) BOOL showsSubtitle;
@property(nonatomic) BOOL showsShareButton;
@property(nonatomic) BOOL showsBookmarkButton;

@property(nonatomic, retain) IBOutlet UIButton *bookmarkButton;
@property(nonatomic, retain) IBOutlet UIButton *shareButton;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property(nonatomic, retain) IBOutlet UIView *buttonContainer;

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *subtitle;

- (void)addButtonWithImage:(UIImage *)image
              pressedImage:(UIImage *)pressedImage
                    target:(id)target
                    action:(SEL)action;

- (void)layoutActionButtons;
- (void)setupBookmarkButtonImages;

- (IBAction)toggleBookmark:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;

@end
