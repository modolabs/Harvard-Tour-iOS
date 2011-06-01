#import <UIKit/UIKit.h>
@class TourStop;
@class TourMapController;

typedef enum  {
    TourOverviewModeStart,
    TourOverviewModeContinue
} TourOverviewMode;

@interface TourOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UIView *_contentView;
    UITableView *_stopsTableView;
    UIView *_mapContainerView;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) UIView *mapContainerView;
@property (nonatomic, retain) TourStop *selectedStop;
@property (nonatomic, retain) TourMapController *tourMapController;
@property (nonatomic, retain) IBOutlet UITableView *stopsTableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *stopCell;
@property (nonatomic, retain) NSArray *tourStops;

@property (nonatomic) TourOverviewMode mode;

- (IBAction)mapListToggled:(id)sender;

+ (void)layoutLensesLegend:(UIView *)legendView forStop:(TourStop *)stop withIconSize:(CGFloat)size;


@end
