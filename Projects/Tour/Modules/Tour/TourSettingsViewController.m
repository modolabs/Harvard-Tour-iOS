//
//  TourSettingsViewController.m
//  Tour
//
//  Created by Jim Kang on 6/7/11.
//  Copyright 2011 Modo Labs. All rights reserved.
//

#import "TourSettingsViewController.h"
#import <MapKit/MapKit.h>

typedef enum {
    kMapSegment = 0,
    kSatelliteSegment,
    kHybridSegment
} SegmentIndexes;


@interface TourSettingsViewController (Private)

- (IBAction)segmentedControlChanged:(id)sender;

@end

@implementation TourSettingsViewController (Private)

- (IBAction)segmentedControlChanged:(id)sender {
    NSInteger mapType = MKMapTypeStandard;
    switch (self.segmentedControl.selectedSegmentIndex) {
        case kMapSegment:
            break;
        case kSatelliteSegment:
            mapType = MKMapTypeSatellite;
            break;
        case kHybridSegment:
            mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] 
     setInteger:mapType forKey:@"mapType"];
}

@end


@implementation TourSettingsViewController

@synthesize segmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [segmentedControl release];
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
    // Do any additional setup after loading the view from its nib.
    
    // Sync the segmented control to the map type.
    NSInteger mapType = 
    [[NSUserDefaults standardUserDefaults] integerForKey:@"mapType"];
    
    switch (mapType) {
        case MKMapTypeStandard:
            self.segmentedControl.selectedSegmentIndex = kMapSegment;
            break;
        case MKMapTypeSatellite:
            self.segmentedControl.selectedSegmentIndex = kSatelliteSegment;
            break;
        case MKMapTypeHybrid:
            self.segmentedControl.selectedSegmentIndex = kHybridSegment;
            break;            
        default:
            break;
    }
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

@end
