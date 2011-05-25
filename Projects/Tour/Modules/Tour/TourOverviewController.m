//
//  TourOverviewController.m
//  Tour
//
//  Created by Brian Patt on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TourOverviewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"

#define CellThumbnailViewTag 1

@interface TourOverviewController (Private)
- (void)showMapAnimated:(BOOL)animated;
- (void)showListAnimated:(BOOL)animated;
@end

@implementation TourOverviewController
@synthesize selectedStop;
@synthesize tourStops;
@synthesize tourMapController;
@synthesize contentView = _contentView;
@synthesize stopsTableView = _stopsTableView;
@synthesize stopCell;

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
    self.stopsTableView.rowHeight = 50;
    if(!self.tourStops) {
        self.tourStops = [[TourDataManager sharedManager] getAllTourStops];
    }
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

- (IBAction)mapListToggled:(id)sender {
    UISegmentedControl *mapListToggle = sender;
    if(mapListToggle.selectedSegmentIndex == 0) {
        [self showMapAnimated:YES];
    } else if(mapListToggle.selectedSegmentIndex == 1) {
        [self showListAnimated:YES];
    }
}

- (void)showMapAnimated:(BOOL)animated {
    if([self.tourMapController.view superview] != _contentView) {
        self.tourMapController.view.frame = _contentView.bounds;
        NSTimeInterval duration = animated ? 0.75 : -1;
        [UIView transitionFromView:_stopsTableView 
            toView:self.tourMapController.view duration:duration 
            options:UIViewAnimationOptionTransitionFlipFromLeft 
            completion:NULL];
    }
}

- (void)showListAnimated:(BOOL)animated {
    if([self.stopsTableView superview] != _contentView) {
        NSTimeInterval duration = animated ? 0.75 : -1;
        [UIView transitionFromView:self.tourMapController.view
                            toView:_stopsTableView
                          duration:duration 
                           options:UIViewAnimationOptionTransitionFlipFromRight 
                        completion:NULL];
    }
}
# pragma TableView dataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tourStopCellIdentifier = @"TourStepCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tourStopCellIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TourStopCell" owner:self options:nil];
        cell = self.stopCell;
        self.stopCell = nil;
    }
    
    UIImageView *thumbnailView = (UIImageView *)[cell viewWithTag:CellThumbnailViewTag];
    TourStop *stop = [self.tourStops objectAtIndex:indexPath.row];
    thumbnailView.image = [(TourMediaItem *)stop.thumbnail image];
    return cell;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tourStops.count;
}
@end
