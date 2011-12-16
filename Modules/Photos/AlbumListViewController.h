#import <UIKit/UIKit.h>
#import "PhotoDataManager.h"
#import "PhotoTableViewCell.h"

@interface AlbumListViewController : UITableViewController <PhotoDataManagerDelegate> {
    
    IBOutlet PhotoTableViewCell *_photoCell;
    
}

@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, assign) PhotoDataManager *dataManager;

@end
