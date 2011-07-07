//
//  TourHelpViewController.m
//  Tour
//

#import "TourHelpViewController.h"
#import "TourDataManager.h"


typedef enum {
    kDescription = 0,
    kTabs,
    kTourContactInfo,
    kTourContacts,
    kHarvardContactInfo,
    kHarvardContacts,
    kCredits
}
HelpTextArrayIndexes;

@implementation TourHelpViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        ((UILabel *)self.navigationItem.titleView).textColor = 
        [UIColor whiteColor];
    }
    
    self.navigationItem.leftBarButtonItem = 
    [[[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self action:@selector(doneTapped:)] autorelease];
}

#pragma mark HTMLTemplateBasedViewController
// The template file under resources/modules/tour.
- (NSString *)templateFilename {
    return @"help_template.html";
}

// Keys: Stubs to replace in the template. Values: Strings to replace them.
- (NSDictionary *)replacementsForStubs {
    NSDictionary *replacementsDict = nil;    
    NSArray *helpTextArray = 
    [[TourDataManager sharedManager] pagesTextArray:@"help"];

    if ((helpTextArray.count > 6) && 
        [[helpTextArray objectAtIndex:kTabs] 
         isKindOfClass:[NSArray class]] && 
        [[helpTextArray objectAtIndex:kTourContacts] 
         isKindOfClass:[NSArray class]] && 
        [[helpTextArray objectAtIndex:kHarvardContacts] 
         isKindOfClass:[NSArray class]]) {
        
        replacementsDict = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         
         [helpTextArray objectAtIndex:kDescription], @"__DESCRIPTION_TEXT__",
         
         [[super class] htmlForTopicSection:
          [helpTextArray objectAtIndex:kTabs]], @"__TAB_DESCRIPTIONS__",
         
         [helpTextArray objectAtIndex:kTourContactInfo], 
         @"__TOUR_CONTACT_INFO__",
         
         [[super class] htmlForContactsSection:
          [helpTextArray objectAtIndex:kTourContacts]], @"__TOUR_CONTACTS__",
         
         [helpTextArray objectAtIndex:kHarvardContactInfo], 
         @"__HARVARD_CONTACT_INFO__",
         
         [[super class] htmlForContactsSection:
          [helpTextArray objectAtIndex:kHarvardContacts]], 
         @"__HARVARD_CONTACTS__",
         
         [helpTextArray objectAtIndex:kCredits], 
         @"__CREDITS__",
         
         nil];
    }
    return replacementsDict;
}

#pragma mark Action
- (IBAction)doneTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
