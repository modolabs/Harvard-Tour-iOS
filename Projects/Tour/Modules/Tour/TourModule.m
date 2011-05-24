#import "TourModule.h"
#import "TourDataManager.h"

@implementation TourModule
@synthesize dataManager;

- (id)initWithDictionary:(NSDictionary *)moduleDict {
  self = [super initWithDictionary:moduleDict];
  if (self) {        
    NSLog(@"tour: %@", moduleDict);
  }
  return self;
}

- (void)initDataManager {
    if (!self.dataManager) {
        self.dataManager = [[[TourDataManager alloc] init] autorelease];
        [self.dataManager loadStopSummarys];
    }
}


#pragma mark Data

- (NSArray *)objectModelNames {
    return [NSArray arrayWithObject:@"Tour"];
}


- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params {
    UIViewController *vc = nil;
    [self initDataManager];
    return vc;
}

@end
