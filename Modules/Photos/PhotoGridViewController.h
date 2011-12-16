#import <UIKit/UIKit.h>
#import "IconGrid.h"
#import "PhotoPagerControlView.h"
#import "PhotoDataManager.h"

@interface PhotoGridViewController : UIViewController <PhotoDataManagerDelegate, IconGridDelegate> {
    
    IBOutlet IconGrid *_iconGrid;
    IBOutlet UIView *_titleView;
    IBOutlet UILabel *_titleLabel;
    //IBOutlet PhotoPagerControlView *_gridHeaderView;
    IBOutlet PhotoPagerControlView *_gridPagerView;
    IBOutlet UIView *_gridHeaderContainer;
    //IBOutlet PhotoPagerControlView *_gridFooterView;
    IBOutlet UIView *_gridFooterContainer;
    
    IBOutletCollection(PhotoPagerControlView) NSArray *pagerCollection;
}

@property (nonatomic, retain) PhotoAlbum *album;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, assign) PhotoDataManager *dataManager;

@end
