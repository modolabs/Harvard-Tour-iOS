
#import <UIKit/UIKit.h>
#import "KGOTableViewController.h"
#import "AthleticsSchedule.h"
@interface AthleticsScheduleDetailViewController : KGOTableViewController {
    UITableView *_scheduleTable;
    
    NSInteger activeMenuCategoryIdx;
}
@property (nonatomic, retain)  AthleticsSchedule *currentSchedule;

@end
