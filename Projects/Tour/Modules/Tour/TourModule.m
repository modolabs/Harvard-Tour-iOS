#import "TourModule.h"
#import "TourHomeViewController.h"
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
        TourHomeViewController *tourHomeVC = [[[TourHomeViewController alloc] initWithNibName:@"TourHomeViewController" bundle:nil] autorelease];
        vc = [[UINavigationController alloc] initWithRootViewController:tourHomeVC];
        [(UINavigationController *)vc setNavigationBarHidden:YES];
    }
    return vc;
}

@end
