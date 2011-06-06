#import "TourModule.h"
#import "TourHomeViewController.h"
#import "TourWelcomeBackViewController.h"
#import "TourDataManager.h"

@implementation TourModule

- (id)initWithDictionary:(NSDictionary *)moduleDict {
  self = [super initWithDictionary:moduleDict];
  if (self) {        
    NSLog(@"tour: %@", moduleDict);
  }
  return self;
}

#pragma mark Data

- (NSArray *)objectModelNames {
    return [NSArray arrayWithObject:@"Tour"];
}


- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params {
    UIViewController *vc = nil;
    [[TourDataManager sharedManager] loadStopSummarys];
    
    if([pageName isEqualToString:LocalPathPageNameHome]) {
        UIViewController *rootVC;
        if([[TourDataManager sharedManager] getCurrentStop] == nil) {
            rootVC = [[[TourHomeViewController alloc] initWithNibName:@"TourHomeViewController" bundle:nil] autorelease];
        } else {
            rootVC = [[[TourWelcomeBackViewController alloc] initWithNibName:@"TourWelcomeBackViewController" bundle:nil] autorelease];
        }
        vc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    }
    return vc;
}

@end
