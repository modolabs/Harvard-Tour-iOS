//
//  TourOverviewController.h
//  Tour
//
//  Created by Brian Patt on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TourStop;
@class TourDataManager;

@interface TourMapController : UIViewController {
    NSInteger numberOfStops;
    TourStop *_selectedStop;
    UIImageView *_thumbnailView;
}

@property (nonatomic, retain) TourStop *selectedStop;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, retain) IBOutlet UILabel *stopTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *mapTipLabel;
@property (nonatomic) BOOL showMapTip;

@end
