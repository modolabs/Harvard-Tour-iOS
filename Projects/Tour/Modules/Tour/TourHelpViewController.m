//
//  TourHelpViewController.m
//  Tour
//

#import "TourHelpViewController.h"
#import "TourDataManager.h"

@implementation TourHelpViewController

#pragma mark - View lifecycle


#pragma mark HTMLTemplateBasedViewController
// The template file under resources/modules/tour.
- (NSString *)templateFilename {
    return @"home_template.html";
}

// Keys: Stubs to replace in the template. Values: Strings to replace them.
- (NSDictionary *)replacementsForStubs {
    NSDictionary *replacementsDict = nil;
    NSArray *welcomeTextArray = 
    [[TourDataManager sharedManager] retrieveWelcomeText];
    if ((welcomeTextArray.count > 2) && 
        [[welcomeTextArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
        
        replacementsDict = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         [welcomeTextArray objectAtIndex:0], @"__WELCOME_TEXT",
         [[super class] htmlForTopicSection:[welcomeTextArray objectAtIndex:1]], 
         @"__TOPICS__",
         [welcomeTextArray objectAtIndex:2], @"__DISCLAIMER__",
         nil];
    }
    return replacementsDict;
}

#pragma mark Action
- (IBAction)doneTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
