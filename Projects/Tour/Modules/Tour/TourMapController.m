#import "TourOverviewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"
#import "TourLense.h"
#import "UIKit+KGOAdditions.h"

@interface TourMapController (Private) 

- (void)showSelectedStop;
- (MKCoordinateRegion)stopsRegion:(NSArray *)tourStops;
- (MKCoordinateRegion)upcomingStopRegion;
- (MKCoordinateRegion)regionEnclosingUserLocationAndStop:(TourStop *)stop;
- (void)deallocViews;

@end

@implementation TourMapController
@synthesize thumbnailView = _thumbnailView;
@synthesize imageViewControl;
@synthesize zoomInOutIcon;
@synthesize mapView;
@synthesize selectedAnnotationView;
@synthesize showMapTip;
@synthesize mapInitialFocusMode;
@synthesize upcomingStop;
@synthesize stopTitleLabel;
@synthesize stopCaptionLabel;
@synthesize lenseIconsContainer;
@synthesize mapTipLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        photoZoomedInFrame = CGRectNull;
        photoZoomedOutFrame = CGRectNull;
    }
    return self;
}

- (void)dealloc
{
    [self deallocViews];
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
        
    if(!showMapTip) {
        self.mapTipLabel.hidden = YES;
    }
    [self showSelectedStop];
    NSArray *tourStops = [[TourDataManager sharedManager] getAllTourStops];
    MKCoordinateRegion initialRegion = { { 0.0f , 0.0f }, {90, 90} };
    if(self.mapInitialFocusMode == MapInitialFocusModeAllStops) {
        initialRegion = [self stopsRegion:tourStops];
    } else if(self.mapInitialFocusMode == MapInitialFocusModeUpcomingStop) {
        initialRegion = [self upcomingStopRegion];
    }
    [self.mapView setRegion:initialRegion animated:NO];
    [self.mapView addAnnotations:tourStops];
}

- (void)deallocViews {
    self.imageViewControl = nil;
    self.thumbnailView = nil;
    self.zoomInOutIcon = nil;
    self.stopTitleLabel = nil;
    self.stopCaptionLabel = nil;
    self.lenseIconsContainer = nil;
    self.mapTipLabel = nil;
    self.mapView = nil;
}

- (void)syncMapType {
    self.mapView.mapType = 
    [[NSUserDefaults standardUserDefaults] integerForKey:@"mapType"];
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

- (void)setSelectedStop:(TourStop *)stop {
    if(_selectedStop != stop) {
        [_selectedStop release];
        _selectedStop = [stop retain];
        [self showSelectedStop];
    }
}

- (TourStop *)selectedStop {
    return _selectedStop;
}

- (void)showSelectedStop {
    if(approachPhotoZoomedIn) {
        self.imageViewControl.frame = photoZoomedOutFrame;
        approachPhotoZoomedIn = NO;
    }
    _thumbnailView.image = [(TourMediaItem *)_selectedStop.thumbnail image]; 
    self.zoomInOutIcon.image = [UIImage imageWithPathName:@"modules/tour/zoomicon-in"];
    self.stopTitleLabel.text = _selectedStop.title;
    self.stopCaptionLabel.text = _selectedStop.subtitle;

    [TourOverviewController layoutLensesLegend:self.lenseIconsContainer forStop:_selectedStop withIconSize:12];
    
    // make sure annotation is visible
    NSSet *visibleAnnotations = [mapView annotationsInMapRect:[mapView visibleMapRect]];
    if(![visibleAnnotations containsObject:_selectedStop]) {
        // move annotation into view
        [mapView setCenterCoordinate:_selectedStop.coordinate animated:YES];
    }
    [mapView selectAnnotation:_selectedStop animated:YES];
}

- (IBAction)photoTapped:(id)sender {
    if(!approachPhotoZoomedIn) {
        if (CGRectIsNull(photoZoomedOutFrame)) {
            photoZoomedOutFrame = self.imageViewControl.frame;
        }
        if (CGRectIsNull(photoZoomedInFrame)) {
            CGFloat width = self.view.frame.size.width;
            CGFloat height = width / photoZoomedOutFrame.size.width * photoZoomedOutFrame.size.height;
            photoZoomedInFrame = photoZoomedOutFrame;
            photoZoomedInFrame.size = CGSizeMake(width, height);
            photoZoomedInFrame.origin.y = photoZoomedOutFrame.origin.y + photoZoomedOutFrame.size.height - height;
        }
    }
    
    approachPhotoZoomedIn = !approachPhotoZoomedIn;
    if (approachPhotoZoomedIn) {
        _thumbnailView.image = [(TourMediaItem *)self.selectedStop.photo image];
    }
    
    [UIView animateWithDuration:0.75 animations:^(void) {
       self.imageViewControl.frame = approachPhotoZoomedIn ? photoZoomedInFrame : photoZoomedOutFrame;
    } completion:^(BOOL finished) {
        if (!approachPhotoZoomedIn) {
            _thumbnailView.image = [(TourMediaItem *)self.selectedStop.thumbnail image];
            self.zoomInOutIcon.image = [UIImage imageWithPathName:@"modules/tour/zoomicon-in"];
        } else {
            self.zoomInOutIcon.image = [UIImage imageWithPathName:@"modules/tour/zoomicon-out"];
        }
    }];
}

- (MKCoordinateRegion)upcomingStopRegion {
    // Show the user location and the upcoming stop if possible.
    // If not, show the previous stop and the upcoming stop.
    
    // mapView.userLocation.updating doesn't seem to be reliable. It seems to 
    // be YES all the time.
    if (receivedUserLocation) {
        return [self regionEnclosingUserLocationAndStop:self.upcomingStop];        
    }
    else {
        TourStop *previousStop = [[TourDataManager sharedManager] 
                                  previousStopForTourStop:self.upcomingStop];
        return [self stopsRegion:[NSArray arrayWithObjects:self.upcomingStop, 
                                  previousStop, nil]];
    }
}

- (MKCoordinateRegion)regionEnclosingUserLocationAndStop:(TourStop *)stop {
    CLLocationDegrees minLatitude = [stop.latitude floatValue];
    CLLocationDegrees maxLatitude = [stop.latitude floatValue];
    CLLocationDegrees minLongitude = [stop.longitude floatValue];
    CLLocationDegrees maxLongitude = [stop.longitude floatValue];
    
    CLLocationDegrees latitude = self.mapView.userLocation.coordinate.latitude;
    CLLocationDegrees longitude = self.mapView.userLocation.coordinate.longitude;
    
    if (latitude > maxLatitude) {
        maxLatitude = latitude;
    }
    
    if (latitude < minLatitude) {
        minLatitude = latitude;
    }
    
    if (longitude > maxLongitude) {
        maxLongitude = longitude;
    }
    
    if (longitude < minLongitude) {
        minLongitude = longitude;
    }

    CGFloat marginFactor = 1.1;
    return 
    MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.5*(minLatitude+maxLatitude), 
                                                      0.5*(minLongitude+maxLongitude)),
                           MKCoordinateSpanMake(marginFactor * 
                                                (maxLatitude - minLatitude), 
                                                marginFactor * 
                                                (maxLongitude - minLongitude)));    
}

- (MKCoordinateRegion)stopsRegion:(NSArray *)tourStops {
    if (tourStops.count == 0) {
         [NSException raise:@"Invalid Region" format:@"attempting to compute a region for zero points"];
    }
    
    TourStop *firstPoint = [tourStops objectAtIndex:0];
    CLLocationDegrees minLatitude = [firstPoint.latitude floatValue];
    CLLocationDegrees maxLatitude = [firstPoint.latitude floatValue];
    CLLocationDegrees minLongitude = [firstPoint.longitude floatValue];
    CLLocationDegrees maxLongitude = [firstPoint.longitude floatValue];
    
    for (TourStop *stop in tourStops) {
        CLLocationDegrees latitude = [stop.latitude floatValue];
        CLLocationDegrees longitude = [stop.longitude floatValue];
        if (latitude > maxLatitude) {
            maxLatitude = latitude;
        }
        
        if (latitude < minLatitude) {
            minLatitude = latitude;
        }
        
        if (longitude > maxLongitude) {
            maxLongitude = longitude;
        }
        
        if (longitude < minLongitude) {
            minLongitude = longitude;
        }
    }
    
    CGFloat marginFactor = 1.1;
    return MKCoordinateRegionMake(
        CLLocationCoordinate2DMake(0.5*(minLatitude+maxLatitude), 0.5*(minLongitude+maxLongitude)),
        MKCoordinateSpanMake(marginFactor * (maxLatitude - minLatitude), marginFactor * (maxLongitude - minLongitude)));
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    receivedUserLocation = YES;
    [self.mapView setRegion:[self upcomingStopRegion] animated:NO];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // old selected annotation
    if([self.selectedStop.visited boolValue]) {
        self.selectedAnnotationView.image = [UIImage imageWithPathName:@"modules/tour/map-pin-past.png"];
    } else {
        self.selectedAnnotationView.image = [UIImage imageWithPathName:@"modules/tour/map-pin.png"];
    }
    // new selected annotation
    view.image = [UIImage imageWithPathName:@"modules/tour/map-pin-current.png"]; 
    self.selectedAnnotationView = view;
    self.selectedStop = (TourStop *)view.annotation;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [aMapView dequeueReusableAnnotationViewWithIdentifier:@"pins"];
    if (!annotationView) {
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pins"] autorelease];
        annotationView.canShowCallout = NO;
    }
    annotationView.annotation = annotation;
    if (annotation == _selectedStop) {
        annotationView.image = [UIImage imageWithPathName:@"modules/tour/map-pin-current.png"];
        self.selectedAnnotationView = annotationView;
    }
    else if (annotation == mapView.userLocation) {
        return nil; //default to blue dot
    }
    else if ([annotation isKindOfClass:[TourStop class]]) {
        TourStop *stop = (TourStop *)annotation;
        if([stop.visited boolValue]) {
            annotationView.image = 
            [UIImage imageWithPathName:@"modules/tour/map-pin-past.png"];
        } else {
            annotationView.image = 
            [UIImage imageWithPathName:@"modules/tour/map-pin.png"];
        }
    }

    return annotationView;
}

@end
