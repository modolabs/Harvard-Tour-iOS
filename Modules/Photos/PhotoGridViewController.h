#import <UIKit/UIKit.h>
#import "IconGrid.h"
#import "PhotoDataManager.h"

@interface PhotoGridViewController : UIViewController <PhotoDataManagerDelegate,
IconGridDelegate, UIScrollViewDelegate>
{
    
    IBOutlet IconGrid *_iconGrid;
    IBOutlet UIView *_titleView;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UILabel *_subtitleLabel;
    
    IBOutlet UIView *_loadingFooter;
    IBOutlet UILabel *_loadingStatusLabel;
}

@property (nonatomic, retain) PhotoAlbum *album;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, assign) PhotoDataManager *dataManager;

@end
