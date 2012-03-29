#import <UIKit/UIKit.h>
#import "PhotoDataManager.h"

@class ThumbnailTableViewCell;

@interface AlbumListViewController : UITableViewController <PhotoDataManagerDelegate> {
    
    ThumbnailTableViewCell *_photoCell;
    
}

@property (nonatomic, retain) IBOutlet ThumbnailTableViewCell *cell;

@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, assign) PhotoDataManager *dataManager;

@end
