#import <UIKit/UIKit.h>

@class TourOverviewController;
@class TourDataManager;

@interface TourHomeViewController : UIViewController {
    TourOverviewController *_tourOverviewController;
    
    IBOutlet UILabel * welcomeTextLabel;
    IBOutlet UILabel * welcomeDisclaimerTextLabel;
    
    IBOutlet UILabel * topicLabel1;
    IBOutlet UILabel * topicLabel2;
    IBOutlet UILabel * topicLabel3;
    IBOutlet UILabel * topicLabel4;
    
    IBOutlet UILabel * topicLabelDetails1;
    IBOutlet UILabel * topicLabelDetails2;
    IBOutlet UILabel * topicLabelDetails3;
    IBOutlet UILabel * topicLabelDetails4;
    
    NSString * welcomeText;
    NSString * welcomeDisclaimerText;
    
    NSString * topicText1;
    NSString * topicText2;
    NSString * topicText3;
    NSString * topicText4;
    
    NSString * topicTextDetails1;
    NSString * topicTextDetails2;
    NSString * topicTextDetails3;
    NSString * topicTextDetails4;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction) startTour:(id)sender;

- (void) assignTexts;

@end
