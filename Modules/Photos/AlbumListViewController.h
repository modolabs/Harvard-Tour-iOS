#import <UIKit/UIKit.h>
#import "PhotoDataManager.h"
//#import "PhotoTableViewCell.h"

@class NewsStoryTableViewCell;

@interface AlbumListViewController : UITableViewController <PhotoDataManagerDelegate> {
    
    NewsStoryTableViewCell *_photoCell;
    
}

@property (nonatomic, retain) IBOutlet NewsStoryTableViewCell *cell;

@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, assign) PhotoDataManager *dataManager;

@end
