//
//  TourOverviewController.m
//  Tour
//
//  Created by Brian Patt on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TourOverviewController.h"
#import "TourMapController.h"

@interface TourOverviewController (Private)
- (void)showMapAnimated:(BOOL)animated;
@end

@implementation TourOverviewController
@synthesize selectedStop;
@synthesize tourMapController;
@synthesize contentView = _contentView;
@synthesize stopsTableView = _stopsTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tourMapController = [[[TourMapController alloc] initWithNibName:@"TourMapController" bundle:nil] autorelease];
        self.tourMapController.showMapTip = YES;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tourMapController.selectedStop = self.selectedStop;
    [self showMapAnimated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showMapAnimated:(BOOL)animated {
    if([self.tourMapController.view superview] != _contentView) {
        [_stopsTableView removeFromSuperview];
        self.tourMapController.view.frame = _contentView.bounds;
        [_contentView addSubview:self.tourMapController.view];
    }
}
@end
