//
//  TourOverviewController.h
//  Tour
//
//  Created by Brian Patt on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TourStop;
@class TourMapController;

@interface TourOverviewController : UIViewController {
    UIView *_contentView;
    UITableView *_stopsTableView;
}

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) TourStop *selectedStop;
@property (nonatomic, retain) TourMapController *tourMapController;
@property (nonatomic, retain) IBOutlet UITableView *stopsTableView;

@end
