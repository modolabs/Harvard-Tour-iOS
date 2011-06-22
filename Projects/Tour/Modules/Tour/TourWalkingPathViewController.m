#import "TourWalkingPathViewController.h"
#import "TourStopDetailsViewController.h"
#import "TourOverviewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"
#import "TourSettingsViewController.h"
#import "TourFinishViewController.h"

@interface TourWalkingPathViewController (Private)

- (void)deallocViews;
- (void)refreshUI;
- (void)loadMapControllerForCurrentStop;
- (void)loadStopDetailsControllerForCurrentStop;
- (BOOL)isLastStop;
- (void)skipToStop:(TourStop *)stop;
- (void)navigateToCurrentStopWithoutPromptingUserShouldAnimate:(BOOL)animated;
- (void)promptUserAboutSkippingToStop:(TourStop *)stop 
                   actualSkippingCode:(StopChoiceCompletionBlock)skipBlock;
- (CGRect)frameForContent;
- (CGRect)frameForPreviousContent;
- (CGRect)frameForNextContent;
- (void)settingsButtonTapped:(id)sender;

@end

@implementation TourWalkingPathViewController
@synthesize contentView;
@synthesize currentContent;
@synthesize previousBarItem;
@synthesize nextBarItem;
@synthesize actionSheetStop;
@synthesize tourStopMode;
@synthesize tourFinishController;
@synthesize tourMapController;
@synthesize tourStopDetailsController;
@synthesize alternateCurrentStop;
@synthesize stopChoiceBlock;

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
    [self deallocViews];
    
    self.currentStop = nil;
    self.initialStop = nil;
    self.actionSheetStop = nil;
    self.tourMapController = nil;
    self.tourStopDetailsController = nil;
    self.contentView = nil;
    self.currentContent = nil;
    self.tourFinishController = nil;
    self.alternateCurrentStop = nil;
    self.stopChoiceBlock = nil;
    
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
        
    // this gets rid of the back button
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithCustomView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]] autorelease];
    
    self.navigationItem.rightBarButtonItem = 
    [[[UIBarButtonItem alloc] 
      initWithImage:[UIImage imageNamed:@"common/button-icon-settings"] 
      style:UIBarButtonItemStyleBordered 
      target:self action:@selector(settingsButtonTapped:)] autorelease];
    
    [self refreshUI];
    [self loadMapControllerForCurrentStop];
    self.tourMapController.view.frame = [self frameForContent];
    [self.contentView addSubview:self.tourMapController.view];
    self.currentContent = self.tourMapController.view;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tourMapController syncMapType];
}

- (void)deallocViews {
    self.previousBarItem = nil;
    self.nextBarItem = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deallocViews];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshUI {
    self.nextBarItem.enabled = (self.tourFinishController == nil);
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    
    if (self.tourFinishController != nil) {
        [module setUpNavBarTitle:@"Thank You" navItem:self.navigationItem];        
    }
    else {
        [module updateNavBarTitle:self.currentStop.title
                          navItem:self.navigationItem];                
        if (self.tourStopMode == TourStopModeApproach) {                
            self.previousBarItem.enabled = (self.currentStop != self.initialStop);
        }
        else if(self.tourStopMode == TourStopModeLenses) {
            self.previousBarItem.enabled = YES;
        }
    }
}

- (IBAction)previous {
    UIView *previousView = nil;
    self.tourFinishController = nil;
    
    if (self.tourStopMode == TourStopModeLenses) {
        self.tourStopMode = TourStopModeApproach;
        [self loadMapControllerForCurrentStop];
        previousView = self.tourMapController.view;
    }
    else if(self.tourStopMode == TourStopModeApproach) {
        self.tourStopMode = TourStopModeLenses;
        self.currentStop = [[TourDataManager sharedManager] previousStopForTourStop:self.currentStop];
        [self loadStopDetailsControllerForCurrentStop];
        previousView = self.tourStopDetailsController.view;
    }
    previousView.frame = [self frameForPreviousContent];
    [self.contentView addSubview:previousView];
    
    [UIView animateWithDuration:0.25 animations:^(void) {
        previousView.frame = [self frameForContent];
        self.currentContent.frame = [self frameForNextContent];
    } completion:^(BOOL finished) {
        [self.currentContent removeFromSuperview];
        self.currentContent = previousView;
        [self refreshUI];
    }];
}

- (IBAction)next {
    if (self.alternateCurrentStop) {
        // Ask if the user wants to go to this stop instead.
        [self promptUserAboutSkippingToStop:self.alternateCurrentStop 
                         actualSkippingCode:
         ^(TourStop *stop) {
             self.currentStop = stop;
             [self navigateToCurrentStopWithoutPromptingUserShouldAnimate:YES];
         }];
    }
    else {
        [self navigateToCurrentStopWithoutPromptingUserShouldAnimate:YES];
    }
}

// Navigate to stop without prompting the user about anything. Do your 
// user-asking before calling this.
- (void)navigateToCurrentStopWithoutPromptingUserShouldAnimate:(BOOL)animated {
    
    UIView *nextView = nil;
    
    if (self.tourStopMode == TourStopModeApproach) {
        self.tourStopMode = TourStopModeLenses;
        [self loadStopDetailsControllerForCurrentStop];
        nextView = self.tourStopDetailsController.view;
    }
    else if(self.tourStopMode == TourStopModeLenses) {
        if ([self isLastStop]) {
            self.tourStopMode = TourStopModeLenses;
            self.tourFinishController = 
            [[[TourFinishViewController alloc] 
              initWithNibName:@"TourFinishViewController" 
              bundle:[NSBundle mainBundle]]
             autorelease];
            nextView = self.tourFinishController.view;
        }
        else {
            self.tourStopMode = TourStopModeApproach;
            self.currentStop = [[TourDataManager sharedManager] 
                                nextStopForTourStop:self.currentStop];
            [self loadMapControllerForCurrentStop];
            nextView = self.tourMapController.view;
        }
    }
    
    void (^completionBlock)(BOOL) = ^(BOOL finished) {
        [self.currentContent removeFromSuperview];
        self.currentContent = nextView;
        [self refreshUI];
        // Clear alternate stop.
        self.alternateCurrentStop = nil;
    };
    
    if (animated) {
        nextView.frame = [self frameForNextContent];
        [self.contentView addSubview:nextView];
        [UIView animateWithDuration:0.25 animations:^(void) {
            nextView.frame = [self frameForContent];
            self.currentContent.frame = [self frameForPreviousContent];
        } 
                         completion:completionBlock];
    }
    else {
        completionBlock(YES);
    }    
}

- (void)tourOverview:(TourOverviewController *)tourOverview 
     stopWasSelected:(TourStop *)stop {
    if ([stop isEqual:self.currentStop]) {
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    [self promptUserAboutSkippingToStop:stop 
                     actualSkippingCode:
     ^(TourStop *stop) {
         // TODO: Make navigateToCurrentStopWithoutPromptingUserShouldAnimate 
         // and this share code.
         self.tourStopMode = TourStopModeApproach;
         self.currentStop = stop;
         [self.currentContent removeFromSuperview];
         [self loadMapControllerForCurrentStop];
         self.currentContent = self.tourMapController.view;
         self.currentContent.frame = [self frameForContent];
         [self.contentView addSubview:self.currentContent];
         [self refreshUI];         
     }];
}

// stop: The stop that we intend to skip to if the user says yes.
// actualSkippingCode: The 
- (void)promptUserAboutSkippingToStop:(TourStop *)stop 
                   actualSkippingCode:(StopChoiceCompletionBlock)skipBlock {
    
    NSArray *tourStops = 
    [[TourDataManager sharedManager] getTourStopsForInitialStop:self.initialStop];
    NSInteger currentIndex = [tourStops indexOfObject:self.currentStop];
    NSInteger selectedIndex = [tourStops indexOfObject:stop];
    
    NSString *title;
    if (currentIndex < selectedIndex) {
        title = [NSString stringWithFormat:
                 @"Are you sure you want to jump ahead %i stops?", 
                 selectedIndex-currentIndex];
    } else {
        title = [NSString stringWithFormat:
                 @"Are you sure you want to go back %i stops?", 
                 currentIndex-selectedIndex];
    }
    
    UIActionSheet *actionSheet = 
    [[UIActionSheet alloc] 
     initWithTitle:title delegate:self cancelButtonTitle:@"NO" 
     destructiveButtonTitle:nil otherButtonTitles:@"YES", nil];
    
    self.stopChoiceBlock = [[skipBlock copy] autorelease];
    self.actionSheetStop = stop;
    [actionSheet showInView:self.contentView];
    [actionSheet release];
}

- (IBAction)cameraButtonTapped:(id)sender {
    if ([UIImagePickerController 
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];        
        [self presentModalViewController:picker animated:YES];   
        [picker release];
    }
}

#pragma - mark UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (self.stopChoiceBlock) {
            self.stopChoiceBlock(self.actionSheetStop);
            self.stopChoiceBlock = nil;
        }
    }
    else {
        // Don't move on. Change the selection to the designated current stop.
        self.alternateCurrentStop = nil;
        [self.tourMapController.mapView 
         selectAnnotation:self.currentStop animated:YES];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)tourOverview {
    TourOverviewController *tourOverviewController = [[[TourOverviewController alloc] initWithNibName:@"TourOverviewController" bundle:nil] autorelease];
    tourOverviewController.mode = TourOverviewModeContinue;
    tourOverviewController.selectedStop = self.currentStop;
    tourOverviewController.tourStops = [[TourDataManager sharedManager] getTourStopsForInitialStop:self.initialStop];
    tourOverviewController.delegate = self;
    UINavigationController *dummyNavController = [[[UINavigationController alloc] initWithRootViewController:tourOverviewController] autorelease];
    [self presentModalViewController:dummyNavController animated:YES];
}

- (void)loadMapControllerForCurrentStop {
    self.tourMapController = 
    [[[TourMapController alloc] initWithNibName:@"TourMapController" bundle:nil] 
     autorelease];
    
    self.tourMapController.delegate = self;
    self.tourMapController.upcomingStop = self.currentStop;
    self.tourMapController.selectedStop = self.currentStop;
    self.tourMapController.mapInitialFocusMode = MapInitialFocusModeUpcomingStop;
}

- (void)loadStopDetailsControllerForCurrentStop {
    self.tourStopDetailsController = [[[TourStopDetailsViewController alloc] initWithNibName:@"TourStopDetailsViewController" bundle:nil] autorelease];
    self.tourStopDetailsController.tourStop = self.currentStop;
}

- (BOOL)isLastStop {
    TourStop *lastStop = [[TourDataManager sharedManager] 
                          lastTourStopForFirstTourStop:self.initialStop];
    return (self.currentStop == lastStop);    
}


- (CGRect)frameForContent {
    return self.contentView.bounds;
}

- (CGRect)frameForNextContent {
    CGRect nextContentFrame = self.contentView.bounds;
    nextContentFrame.origin.x += self.contentView.bounds.size.width;
    return nextContentFrame;
}

- (CGRect)frameForPreviousContent {
    CGRect previousContentFrame = self.contentView.bounds;
    previousContentFrame.origin.x -= self.contentView.bounds.size.width;
    return previousContentFrame;
}

- (void)settingsButtonTapped:(id)sender {
    TourSettingsViewController *settingsController = 
    [[TourSettingsViewController alloc] 
     initWithNibName:@"TourSettingsViewController" 
     bundle:[NSBundle mainBundle]];
    settingsController.delegate = self;
    UINavigationController *modalNavController = 
    [[UINavigationController alloc] 
     initWithRootViewController:settingsController];
    [settingsController release];
    [self.navigationController 
     presentModalViewController:modalNavController animated:YES];
    [modalNavController release];
}

- (void)setInitialStop:(TourStop *)stop {
    if (_initialStop != stop) {
        [_initialStop release];
        _initialStop = [stop retain];
        [[TourDataManager sharedManager] saveInitialStop:_initialStop];
    }
}

- (TourStop *)initialStop {
    return _initialStop;
}

- (void)setCurrentStop:(TourStop *)stop {
    if (_currentStop != stop) {
        [_currentStop release];
        _currentStop = [stop retain];
        [[TourDataManager sharedManager] saveCurrentStop:_currentStop];
    }
}

- (TourStop *)currentStop {
    return _currentStop;
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Save the image or video to the Photo Library.
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] 
         isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = 
        [info objectForKey:UIImagePickerControllerOriginalImage];
        [assetsLibrary 
         writeImageToSavedPhotosAlbum:image.CGImage
         metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]
         completionBlock:nil];        
    }
    else if ([[info objectForKey:UIImagePickerControllerMediaType] 
              isEqualToString:(NSString *)kUTTypeMovie]) {
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:
         [info objectForKey:UIImagePickerControllerMediaURL]
                                          completionBlock:nil];
    }
    [assetsLibrary release];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark TourMapControllerDelegate
- (void)mapController:(TourMapController *)controller 
    didSelectTourStop:(TourStop *)stop {
    // Update title.
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module updateNavBarTitle:stop.title navItem:self.navigationItem];
    if (stop != self.currentStop) {
        self.alternateCurrentStop = stop;
    }
}

#pragma mark TourSettingsControllerDelegate
- (void)endTour {
    // Set up the state that usually causes the controller to move on to the 
    // finish view.
    self.tourStopMode = TourStopModeLenses;
    self.currentStop = [[TourDataManager sharedManager] 
                        lastTourStopForFirstTourStop:self.initialStop];
    // Move on to the finish view.
    [self navigateToCurrentStopWithoutPromptingUserShouldAnimate:NO];
}

@end