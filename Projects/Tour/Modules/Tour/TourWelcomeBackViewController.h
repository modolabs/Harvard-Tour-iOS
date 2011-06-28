#import <UIKit/UIKit.h>
#import "HTMLTemplateBasedViewController.h"

@interface TourWelcomeBackViewController : HTMLTemplateBasedViewController {
    IBOutlet UIButton *resumeLabelButton;
    IBOutlet UIButton *resumeIconButton;
}

- (IBAction)startOver;
- (IBAction)resumeTour;

@property (assign) BOOL newTourMode;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *resumeLabelButton;
@property (nonatomic, retain) IBOutlet UIButton *resumeIconButton;


@end
