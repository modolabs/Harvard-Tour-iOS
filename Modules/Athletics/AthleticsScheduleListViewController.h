#import <UIKit/UIKit.h>
#import "AthleticsDataController.h"
#import "KGOTableViewController.h"
@interface AthleticsScheduleListViewController : KGOTableViewController <AthleticsDataDelegate>{
    IBOutlet UITableView *_scheduleListView;
    
    
}
@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *schedules;
@end
