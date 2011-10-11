
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <UIKit/UIKit.h>
#import "HTMLTemplateBasedViewController.h"

@interface TourWelcomeBackViewController : HTMLTemplateBasedViewController {
}

- (IBAction)leftButtonTapped;
- (IBAction)rightButtonTapped;

@property (assign) BOOL newTourMode;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIButton *rightLabelButton;
@property (nonatomic, retain) IBOutlet UIButton *rightIconButton;

@property (nonatomic, retain) IBOutlet UIButton *leftLabelButton;
@property (nonatomic, retain) IBOutlet UIButton *leftIconButton;

@end
