#import "TourMapController.h"
#import "TourDataManager.h"

@interface TourMapController (Private) 
- (void)showSelectedStop;
- (MKCoordinateRegion)stopsRegion:(NSArray *)tourStops;
- (void)deallocViews;
@end

@implementation TourMapController
@synthesize thumbnailView = _thumbnailView;
@synthesize imageViewControl;
@synthesize mapView;
@synthesize showMapTip;
@synthesize stopTitleLabel;
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
    MKCoordinateRegion initialRegion = [self stopsRegion:tourStops];
    [self.mapView setRegion:initialRegion animated:NO];
    [self.mapView addAnnotations:tourStops];
}

- (void)deallocViews {
    self.imageViewControl = nil;
    self.thumbnailView = nil;
    self.stopTitleLabel = nil;
    self.mapTipLabel = nil;
    self.mapView = nil;
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
    self.stopTitleLabel.text = _selectedStop.title;
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
        }
    }];
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
    
    return MKCoordinateRegionMake(
        CLLocationCoordinate2DMake(0.5*(minLatitude+maxLatitude), 0.5*(minLongitude+maxLongitude)),
        MKCoordinateSpanMake(maxLatitude - minLatitude, maxLongitude - minLongitude));
}

#pragma MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.selectedStop = (TourStop *)view.annotation;
}
@end
