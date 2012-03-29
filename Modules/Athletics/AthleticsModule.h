#import <Foundation/Foundation.h>
#import "KGOModule.h"
#import "AthleticsDataController.h"

@interface AthleticsModule : KGOModule <AthleticsDataDelegate>{
    AthleticsDataController *_dataManager;
    NSString *_searchText;
}
@property (nonatomic, retain)  AthleticsDataController *dataManager;

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params;

@end
