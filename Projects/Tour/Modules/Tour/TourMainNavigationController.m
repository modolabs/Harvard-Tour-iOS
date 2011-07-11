#import "TourMainNavigationController.h"
#import <MediaPlayer/MediaPlayer.h>


@implementation TourMainNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if(self) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(videoWillEnterFullScreenMode)
                                                         name:MPMoviePlayerWillEnterFullscreenNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(videoWillExitFullScreenMode)
                                                         name:MPMoviePlayerWillExitFullscreenNotification
                                                       object:nil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - fullscreen video related methods

- (void)videoWillEnterFullScreenMode {
    fullScreenModeActive = YES;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    
    // preserve frame for exiting full screen mode
    normalFrame = self.view.frame;    
    self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void)videoWillExitFullScreenMode {
    fullScreenModeActive = NO;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    self.view.transform = CGAffineTransformMakeRotation(0);
    self.view.frame = normalFrame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if(fullScreenModeActive) {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
