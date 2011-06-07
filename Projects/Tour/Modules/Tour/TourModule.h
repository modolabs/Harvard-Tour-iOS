#import "KGOModule.h"

@class TourDataManager;

@interface TourModule : KGOModule {

}

@end

@interface TourModule (UINavigationBarModification)

- (void)setUpNavigationBar:(UINavigationBar *)navBar;
- (void)setUpNavBarTitle:(NSString *)title navItem:(UINavigationItem *)navItem;

@end
