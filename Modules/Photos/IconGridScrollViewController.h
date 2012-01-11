#import <UIKit/UIKit.h>
#import "IconGridScrollView.h"
#import "PhotoDataManager.h"

@interface IconGridScrollViewController : UIViewController
<IconGridScrollViewDataSource, UIScrollViewDelegate, PhotoDataManagerDelegate>
{
}

@property (nonatomic, retain) IBOutlet IconGridScrollView *gridView;
@property (nonatomic, retain) NSArray *albums;

@property (nonatomic, assign) PhotoDataManager *dataManager;

@end
