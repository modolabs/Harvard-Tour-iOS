
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <UIKit/UIKit.h>
#import "KGOTabbedControl.h"
@class TourStop;
@class TourMapController;
@class TourOverviewController;

typedef enum  {
    TourOverviewModeStart,
    TourOverviewModeContinue
} TourOverviewMode;

@protocol TourOverviewDelegate
- (void)tourOverview:(TourOverviewController *)tourOverview stopWasSelected:(TourStop *)stop;
@end

@interface TourOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KGOTabbedControlDelegate> {
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

@property (nonatomic, retain) id<TourOverviewDelegate> delegate;

- (IBAction)backButtonTapped:(id)sender;

+ (void)layoutLensesLegend:(UIView *)legendView forStop:(TourStop *)stop withIconSize:(CGFloat)size;


@end
